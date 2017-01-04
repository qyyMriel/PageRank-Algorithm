module sortvals
# (parameter WIDTH = 31, N = 64)
(input clk,input reset,
 input [WIDTH-1:0] unsort_00, input [WIDTH-1:0] unsort_01, input [WIDTH-1:0] unsort_10, input [WIDTH-1:0] unsort_11,
 output reg [10*(WIDTH-7)-1:0] top10Vals, output reg [10*6-1:0] top10IDs, output reg done);

reg [WIDTH-1:0] array_2D [N-1:0];
reg [WIDTH-1:0] local_max;


integer i,j,k,l,m,n,o,p,q,loop;
//read in data and store them in array_2D, repeat for 40 times.
always@ (posedge clk, posedge reset) begin
	if (reset) begin
		i <= 0;
		j <= 0;
	end
	else begin
		if (unsort_00[0] & j<40) begin
			array_2D[i] <= unsort_00;
			array_2D[i+1] <= unsort_01;
			array_2D[i+2] <= unsort_10;
			array_2D[i+3] <= unsort_11;
			if (i==60) begin i <= 0; j <= j+1; end
			else i <= i+4;
		end
	end
end




always@(*) begin
	//Conversion from 2-D array to top10Vals and top10IDs
	if (done) begin
		top10Vals = {array_2D[9][30:7],array_2D[8][30:7],array_2D[7][30:7],array_2D[6][30:7],array_2D[5][30:7],array_2D[4][30:7],array_2D[3][30:7],array_2D[2][30:7],array_2D[1][30:7],array_2D[0][30:7]};
		top10IDs = {array_2D[9][6:1],array_2D[8][6:1],array_2D[7][6:1],array_2D[6][6:1],array_2D[5][6:1],array_2D[4][6:1],array_2D[3][6:1],array_2D[2][6:1],array_2D[1][6:1],array_2D[0][6:1]};
	end
end

always@(posedge clk, posedge reset) begin
	//bubble sort
	if(reset) begin
		done=0;
		n=62;
		loop=0;
	end
	else begin
		if(j==40) begin
			if(array_2D[n][30:7]<array_2D[n+1][30:7]) begin
				local_max=array_2D[n];
				array_2D[n]=array_2D[n+1];
				array_2D[n+1]=local_max;
			end
			if(n==0) begin
				n=62;
				loop=loop+1;
				if(loop==9) done=1;
			end
			else 	n=n-1;
		end
	end
end

endmodule 



		



 

