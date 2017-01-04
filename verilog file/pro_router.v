module pro_router #(parameter WIDTH=31, DEPTH=16)
(input clk, input reset, 
 input writeE, 
 input writeW, 
 input writeN, 
 input writeS,//write ports
 input [WIDTH-1:0] dataInE, 
 input [WIDTH-1:0] dataInW, 
 input [WIDTH-1:0] dataInN,
 input [WIDTH-1:0] dataInS, //write data ports
 output  writetoE,
 output  writetoW,
 output  writetoS,
 output  [WIDTH-1:0] dataOutE,
 output  [WIDTH-1:0] dataOutW,
 output  [WIDTH-1:0] dataOutN,
 output  [WIDTH-1:0] dataOutS, //output ports
 output  fullE, 
 output   almost_fullE, 
 output   fullW, 
 output   almost_fullW, 
 output   fullN, 
 output   almost_fullN,
 output   fullS, 
 output   almost_fullS //full outputs from FIFOs
 );

parameter ADDWIDTH = $clog2(DEPTH);
wire readE, readW, readN, readS; //output from arbiter, input to FIFO
wire writetoE_temp, writetoW_temp, writetoS_temp;//output from arbiter, input to outport
wire [WIDTH-1:0] dataOutFifoE, dataOutFifoW, dataOutFifoN, dataOutFifoS; //output from FIFO, input to arbiter
wire emptyE, almost_emptyE, emptyW, almost_emptyW, emptyN, almost_emptyN, emptyS, almost_emptyS; //output from FIFO, input to arbiter
wire [WIDTH-1:0] dataOutE_temp, dataOutW_temp, dataOutN_temp, dataOutS_temp; //output from arbiter, input to outport 

fifo_improved #(WIDTH,DEPTH,ADDWIDTH) fifoE (clk,  reset,  writeE,  readE, dataInE, dataOutFifoE, fullE, almost_fullE, emptyE, almost_emptyE);

fifo_improved #(WIDTH,DEPTH,ADDWIDTH) fifoW (clk,  reset,  writeW,  readW, dataInW, dataOutFifoW, fullW, almost_fullW, emptyW, almost_emptyW);

fifo_improved #(WIDTH,DEPTH,ADDWIDTH) fifoN (clk,  reset,  writeN,  readN, dataInN, dataOutFifoN, fullN, almost_fullN, emptyN, almost_emptyN);

fifo_improved #(WIDTH,DEPTH,ADDWIDTH) fifoS (clk,  reset,  writeS,  readS, dataInS, dataOutFifoS, fullS, almost_fullS, emptyS, almost_emptyS);

arbiter #(WIDTH) a(clk, reset, emptyE, almost_emptyE, dataOutFifoE, 
                      emptyW, almost_emptyW, dataOutFifoW,  
                      emptyN, almost_emptyN, dataOutFifoN, 
                      emptyS, almost_emptyS, dataOutFifoS, 
		      writetoE_temp, writetoW_temp, writetoS_temp,
                      readE, readW, readN, readS,
		      dataOutE_temp, dataOutW_temp, dataOutN_temp, dataOutS_temp); 

 
outport #(WIDTH) o(clk, reset, writetoE_temp, writetoW_temp, writetoS_temp, dataOutE_temp, dataOutW_temp, dataOutN_temp, dataOutS_temp, writetoE, writetoW, writetoS, dataOutE, dataOutW, dataOutN, dataOutS);

endmodule

module outport #(parameter WIDTH = 31) (input clk, input reset, input writetoE_temp, input writetoW_temp, input writetoS_temp,
	       input [WIDTH-1:0] dataOutE_temp,input [WIDTH-1:0] dataOutW_temp,input [WIDTH-1:0] dataOutN_temp,input [WIDTH-1:0] dataOutS_temp,
	        output reg writetoE, output reg writetoW, output reg writetoS,
		output reg [WIDTH-1:0] dataOutE, output reg [WIDTH-1:0] dataOutW, output reg [WIDTH-1:0] dataOutN, output reg [WIDTH-1:0] dataOutS);


always @ (posedge clk, posedge reset)begin

	if (reset) begin
		dataOutE <= 0;
		dataOutW <= 0;
		dataOutN <= 0;
		dataOutS <= 0;
		writetoE <= 0;
		writetoW <= 0;
		writetoS <= 0;
	end
	else begin
		dataOutE <= dataOutE_temp;
	        dataOutW <= dataOutW_temp;
                dataOutN <= dataOutN_temp;
                dataOutS <= dataOutS_temp;
		writetoE <= writetoE_temp;
		writetoW <= writetoW_temp;
		writetoS <= writetoS_temp;
	end	
	
end

endmodule 	  


//this one does not dequeue items that are not transmitted
module arbiter #(parameter WIDTH=31)
		(input clk, input reset, 
	        input emptyE, input almost_emptyE, input [WIDTH-1:0] dataInFifoE,
		input emptyW, input almost_emptyW, input [WIDTH-1:0] dataInFifoW,
		input emptyN, input almost_emptyN, input [WIDTH-1:0] dataInFifoN,
		input emptyS, input almost_emptyS, input [WIDTH-1:0] dataInFifoS,
		output reg writetoE_temp, output reg writetoW_temp, output reg writetoS_temp,
		output reg readE, output reg readW, output reg readN, output reg readS,
		output reg [WIDTH-1:0] dataOutE_temp, output reg [WIDTH-1:0] dataOutW_temp, output reg [WIDTH-1:0] dataOutN_temp, output reg [WIDTH-1:0] dataOutS_temp);

localparam East = 2'b00, West = 2'b01, North = 2'b10, South = 2'b11;


reg [WIDTH-1:0] dataE, dataW, dataN, dataS; 
reg [WIDTH-1:0] dataInPrevE, dataInPrevW, dataInPrevN, dataInPrevS; //stores data that was not transmitted
reg retainE, retainW, retainN, retainS;
reg retainPrevE, retainPrevW, retainPrevN, retainPrevS;

reg readE_temp, readW_temp, readN_temp, readS_temp;

reg port;
reg grantedE, grantedW, grantedN, grantedS;

reg [1:0] pointer;//priority

//generates data at the dataInFifo* ports
always @ (posedge clk, posedge reset) begin

	if (reset) begin
		readE_temp <=1'b0;
		readW_temp <=1'b0;
		readN_temp <=1'b0;
		readS_temp <=1'b0;
	end
	else begin
		if ((almost_emptyE & readE) | (emptyE) )
			readE_temp <= 1'b0;
		else 
			readE_temp <= 1'b1;

		if ((almost_emptyW & readW) | (emptyW) )
			readW_temp <= 1'b0;
		else 
			readW_temp <= 1'b1;

		if ((almost_emptyN & readN) | (emptyN) )
			readN_temp <= 1'b0;
		else 
			readN_temp <= 1'b1;

		if ((almost_emptyS & readS) | (emptyS) )
			readS_temp <= 1'b0;
		else 
			readS_temp <= 1'b1;
	end

end

always @ (*) begin
	readE = readE_temp & (~retainE);
	readW = readW_temp & (~retainW);
	readN = readN_temp & (~retainN);
	readS = readS_temp & (~retainS);
end



always @ (posedge clk, posedge reset) begin
	if (reset) begin
		dataInPrevE <= 0;
		retainPrevE <= 0;
		dataInPrevW <= 0;
		retainPrevW <= 0;
		dataInPrevN <= 0;
		retainPrevN <= 0;
		dataInPrevS <= 0;
		retainPrevS <= 0;
	end
	else begin
		dataInPrevE <= dataE;//dataInFifoE;
		retainPrevE <= retainE;
		dataInPrevW <= dataW;//dataInFifoW;
		retainPrevW <= retainW;
		dataInPrevN <= dataN;//dataInFifoN;
		retainPrevN <= retainN;
		dataInPrevS <= dataS;//dataInFifoS;
		retainPrevS <= retainS;
	end
end 

always @ (*) begin

	dataE = retainPrevE? dataInPrevE: dataInFifoE;
	dataW = retainPrevW? dataInPrevW: dataInFifoW;
	dataN = retainPrevN? dataInPrevN: dataInFifoN;
	dataS = retainPrevS? dataInPrevS: dataInFifoS;

end

always @ (posedge clk, posedge reset) begin
	
	if(reset) 
		pointer <= 2'b10;
	else begin 
		//if (~(dataN[0]|dataE[0]|dataW[0]|dataS[0])) dataOut_temp <= 0;
		if (pointer==2'b11) 
			pointer <= 2'b00;
		else pointer <= pointer + 1;
	end

end
//Looks at data at the dataInFifo* ports and pushes them to the output
//crossbar + outputreg
always @ (*) begin
	port=0;

	grantedE=0; //Updated, but note that the original code was fine for static priority.
	retainE=0;

	grantedW=0;
	retainW=0;

	grantedN=0;
	retainN=0;

	grantedS=0;
	retainS=0;

	//Highest priority
	//Always granted if it needs a port
	case (pointer)
		//E>W>N>S
		East:begin
			dataOutE_temp = 0;
			dataOutW_temp = 0;
			dataOutN_temp = 0;
			dataOutS_temp = 0;
			writetoE_temp = 0;
			writetoW_temp = 0;
			writetoS_temp = 0;
			if (dataE[0]==1) begin
				dataOutN_temp = dataE;
				port = 1;
			end
			if (dataW[0]==1) begin
				if(~port) begin
				dataOutN_temp = dataW;
				port = 1;
				grantedW=1;
				end
				if(grantedW==0)
				retainW=1;
			end
			if (dataN[0]==1) begin
				if(~port) begin
				dataOutN_temp = dataN;
				dataOutE_temp = dataN;
				dataOutW_temp = dataN;
				dataOutS_temp = dataN;
				writetoE_temp = 1;
				writetoW_temp = 1;
				writetoS_temp = 1;
				port = 1;
				grantedN=1;
				end
				if(grantedN==0)
				retainN=1;
			end
			if (dataS[0]==1) begin
				if(~port) begin
				dataOutN_temp = dataS;
				port = 1;
				grantedS=1;
				end
				if(grantedS==0)
				retainS=1;
			end
			/*if (~(dataN[0]) begin
				dataOutE_temp <= 0;
				dataOutW_temp <= 0;
				dataOutS_temp <= 0;
			end*/

		end
		//W>N>S>E
		West:begin
			dataOutE_temp = 0;
			dataOutW_temp = 0;
			dataOutN_temp = 0;
			dataOutS_temp = 0;
			writetoE_temp = 0;
			writetoW_temp = 0;
			writetoS_temp = 0;
			if (dataW[0]==1) begin
				dataOutN_temp = dataW;
				port = 1;
			end
			if (dataN[0]==1) begin
				if(~port) begin
				dataOutN_temp = dataN;
				dataOutE_temp = dataN;
				dataOutW_temp = dataN;
				dataOutS_temp = dataN;
				writetoE_temp = 1;
				writetoW_temp = 1;
				writetoS_temp = 1;
				port = 1;
				grantedN=1;
				end
				if(grantedN==0)
				retainN=1;
			end
			if (dataS[0]==1) begin
				if(~port) begin
				dataOutN_temp = dataS;
				port = 1;
				grantedS=1;
				end
				if(grantedS==0)
				retainS=1;
			end
			if (dataE[0]==1) begin
				if(~port) begin
				dataOutN_temp = dataE;
				port = 1;
				grantedE=1;
				end
				if(grantedE==0)
				retainE=1;
			end
			//if (~(dataN[0]|dataE[0]|dataW[0]|dataS[0])) dataOut_temp = 0;
		end
		//N>S>E>W
		North:begin
			dataOutE_temp = 0;
			dataOutW_temp = 0;
			dataOutN_temp = 0;
			dataOutS_temp = 0;
			writetoE_temp = 0;
			writetoW_temp = 0;
			writetoS_temp = 0;
			if (dataN[0]==1) begin
				dataOutN_temp = dataN;
				dataOutE_temp = dataN;
				dataOutW_temp = dataN;
				dataOutS_temp = dataN;
				writetoE_temp = 1;
				writetoW_temp = 1;
				writetoS_temp = 1;
				port = 1;
			end
			if (dataS[0]==1) begin
				if(~port) begin
				dataOutN_temp = dataS;
				port = 1;
				grantedS=1;
				end
				if(grantedS==0)
				retainS=1;
			end
			if (dataE[0]==1) begin
				if(~port) begin
				dataOutN_temp = dataE;
				port = 1;
				grantedE=1;
				end
				if(grantedE==0)
				retainE=1;
			end
			if (dataW[0]==1) begin
				if(~port) begin
				dataOutN_temp = dataW;
				port = 1;
				grantedW=1;
				end
				if(grantedW==0)
				retainW=1;
			end
			//if (~(dataN[0]|dataE[0]|dataW[0]|dataS[0])) dataOut_temp = 0;
		end
		//S>E>W>N
		South:begin
			dataOutE_temp = 0;
			dataOutW_temp = 0;
			dataOutN_temp = 0;
			dataOutS_temp = 0;
			writetoE_temp = 0;
			writetoW_temp = 0;
			writetoS_temp = 0;
			if (dataS[0]==1) begin
				dataOutN_temp = dataS;
				port = 1;
			end
			if (dataE[0]==1) begin
				if(~port) begin
				dataOutN_temp = dataE;
				port = 1;
				grantedE=1;
				end
				if(grantedE==0)
				retainE=1;
			end
			if (dataW[0]==1) begin
				if(~port) begin
				dataOutN_temp = dataW;
				port = 1;
				grantedW=1;
				end
				if(grantedW==0)
				retainW=1;
			end
			if (dataN[0]==1) begin
				if(~port) begin
				dataOutN_temp = dataN;
				dataOutE_temp = dataN;
				dataOutW_temp = dataN;
				dataOutS_temp = dataN;
				writetoE_temp = 1;
				writetoW_temp = 1;
				writetoS_temp = 1;
				port = 1;
				grantedN=1;
				end
				if(grantedN==0)
				retainN=1;
			end
			//if (~(dataN[0]|dataE[0]|dataW[0]|dataS[0])) dataOut_temp = 0;
		end
	endcase
/*
	if (dataE[0]==1) begin
		if (dataE[2:1]==East) begin
			dataOutE_temp = dataE;
			portE = 1;
		end
		if (dataE[2:1]==West) begin
			dataOutW_temp = dataE;
			portW = 1;
		end
		if (dataE[2:1]==Local) begin
			dataOutL_temp = dataE;
			portL=1;
		end
	end

	if (dataW[0]==1) begin
		if ((dataW[2:1]==East)&(~portE)) begin
			dataOutE_temp = dataW;
			portE = 1;
			grantedW=1;
		end
		if ((dataW[2:1]==West)&(~portW)) begin
			dataOutW_temp = dataW;
			portW = 1;
			grantedW=1;
		end
		if ((dataW[2:1]==Local)&(~portL)) begin
			dataOutL_temp = dataW;
			portL=1;
			grantedW=1;
		end
		if(grantedW==0)
			retainW=1;
	end

	if (dataL[0]==1) begin
		if ((dataL[2:1]==East) & (~portE)) begin
			dataOutE_temp = dataL; //Updated. Thanks to Daniel Chang and Minda Fang.
			portE = 1;
			grantedL=1;
		end
		if ((dataL[2:1]==West)&(~portW)) begin
			dataOutW_temp = dataL;
			portW = 1;
			grantedL=1;
		end
		if ((dataL[2:1]==Local)&(~portL)) begin
			dataOutL_temp = dataL;
			portL=1;
			grantedL=1;
		end

		if(grantedL==0)
			retainL=1;
	end
*/
	
	
end

			
endmodule







