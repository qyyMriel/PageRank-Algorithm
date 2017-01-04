module regfile #(parameter WIDTH=16, DEPTH=32, ADDWIDTH=5)
(input clk, input reset, input writeEnable, input readEnable,
 input [ADDWIDTH-1:0] dest, input [ADDWIDTH-1:0] source, 
 input [WIDTH-1:0] dataIn, output reg [WIDTH-1:0] dataOut);

reg [WIDTH-1 : 0] rf [DEPTH-1 : 0];

integer i;

always @ (posedge clk, posedge reset) begin

	if (reset) begin
		dataOut <=0;
		for (i=0;i<DEPTH;i=i+1) begin
			rf[i] <= 0;
		end
	end
	else begin 
		if (readEnable)
			dataOut <= rf[source];
		else
			dataOut <= 0;
		if(writeEnable)
			rf[dest] <= dataIn; 
	end
end

endmodule
