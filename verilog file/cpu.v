//Read more details on the pagerank algorithm here.
//http://www.math.cornell.edu/~mec/Winter2009/RalucaRemus/Lecture3/lecture3.html
//The data in this example are based on the example in the link above.

module cpu #(parameter N=64, WIDTH=31, FSTNODE=6'b000000)
(
input clk,
input reset,
input [N*N-1:0] adjacency,
input [N*(WIDTH-7)-1:0] weights,
input [WIDTH-1:0] dataIn,
output reg writeL,
output reg [WIDTH-1:0] dataOut);


//We will use a 16 bit fixed point representation throughout.
//All values are in the range [0,(2^16-1)/2^16]. 
// For example, the 16 bit value 2'h11 corresponds to (2^16-1)/2^16.

localparam d = 24'h266666;   //d = 0.15
localparam n = N>>2; //n = 16
localparam dn = d>>$clog2(N); // d/N : NOTE --- please update based on N
localparam db = 24'hd9999a; //1-d: NOTE: --- please update based on d 

reg [WIDTH-8:0] nodeVal [n-1:0]; //value of each node
reg [WIDTH-8:0] nodeVal_next [n-1:0]; //next state node value
reg [WIDTH-8:0] nodeWeight [N-1:0]; //weight of each node
reg adj [N-1:0] [N-1:0]; //adjacency matrix
reg [N-1:0] node_No; //updated node sign


reg [N-1:0] i,j,k,p,q,r,t;
reg [5:0] s; 
wire [5:0] node_Nout; //output node number
reg [N-1:0] count;
reg update; 

reg [3*24-1:0] temp; //16bit*16bit*16bit

assign node_Nout = s + FSTNODE;
//Convert adj from 1D to 2D array
always @ (*) begin
	count = 0;
	for (p=0; p<N; p=p+1) begin
		for (q=0; q<N; q=q+1) begin
			adj[p][q] = adjacency[count];
			count = count+1;
		end
	end
end

//Convert nodeWeights from 1D to 2D array
always @ (*) begin
	for (r=0; r<N; r=r+1) begin
		nodeWeight[r] = weights[r*(WIDTH-7)+:WIDTH-7];
	end
end

/*
//reg [WIDTH-1:0] node0Val;
reg [WIDTH-1:0] node1Val;
reg [WIDTH-1:0] node2Val;
reg [WIDTH-1:0] node3Val;

always @ (*) begin
	node0Val = nodeVal[0];
	node1Val = nodeVal[1];
	node2Val = nodeVal[2];
	node3Val = nodeVal[3];
end
*/
//split dataIn into score and node_No.
always @ (dataIn) begin
	if (dataIn[0]) begin
		temp = db * nodeWeight[dataIn[6:1]] * dataIn[WIDTH-1:7];
		//For each node
		for (j=FSTNODE; j<FSTNODE+n; j=j+1) begin
			//Go through adjacency matrix to find node's neighbours
				if(adj[j][dataIn[6:1]]==1'b1) begin
					//Add db*nodeval[k]*nodeWeight[k]
					nodeVal_next[j-FSTNODE] = nodeVal_next[j-FSTNODE] + temp[71:48]; 
				end
		end
		case(dataIn[6:1])
		6'b000000: node_No[0] = 1;
		6'b000001: node_No[1] = 1;
		6'b000010: node_No[2] = 1;
		6'b000011: node_No[3] = 1;
		6'b000100: node_No[4] = 1;
		6'b000101: node_No[5] = 1;
		6'b000110: node_No[6] = 1;
		6'b000111: node_No[7] = 1;
		6'b001000: node_No[8] = 1;
		6'b001001: node_No[9] = 1;
		6'b001010: node_No[10] = 1;
		6'b001011: node_No[11] = 1;
		6'b001100: node_No[12] = 1;
		6'b001101: node_No[13] = 1;
		6'b001110: node_No[14] = 1;
		6'b001111: node_No[15] = 1;
		6'b010000: node_No[16] = 1;
		6'b010001: node_No[17] = 1;
		6'b010010: node_No[18] = 1;
		6'b010011: node_No[19] = 1;
		6'b010100: node_No[20] = 1;
		6'b010101: node_No[21] = 1;
		6'b010110: node_No[22] = 1;
		6'b010111: node_No[23] = 1;
		6'b011000: node_No[24] = 1;
		6'b011001: node_No[25] = 1;
		6'b011010: node_No[26] = 1;
		6'b011011: node_No[27] = 1;
		6'b011100: node_No[28] = 1;
		6'b011101: node_No[29] = 1;
		6'b011110: node_No[30] = 1;
		6'b011111: node_No[31] = 1;
		6'b100000: node_No[32] = 1;
		6'b100001: node_No[33] = 1;
		6'b100010: node_No[34] = 1;
		6'b100011: node_No[35] = 1;
		6'b100100: node_No[36] = 1;
		6'b100101: node_No[37] = 1;
		6'b100110: node_No[38] = 1;
		6'b100111: node_No[39] = 1;
		6'b101000: node_No[40] = 1;
		6'b101001: node_No[41] = 1;
		6'b101010: node_No[42] = 1;
		6'b101011: node_No[43] = 1;
		6'b101100: node_No[44] = 1;
		6'b101101: node_No[45] = 1;
		6'b101110: node_No[46] = 1;
		6'b101111: node_No[47] = 1;
		6'b110000: node_No[48] = 1;
		6'b110001: node_No[49] = 1;
		6'b110010: node_No[50] = 1;
		6'b110011: node_No[51] = 1;
		6'b110100: node_No[52] = 1;
		6'b110101: node_No[53] = 1;
		6'b110110: node_No[54] = 1;
		6'b110111: node_No[55] = 1;
		6'b111000: node_No[56] = 1;
		6'b111001: node_No[57] = 1;
		6'b111010: node_No[58] = 1;
		6'b111011: node_No[59] = 1;
		6'b111100: node_No[60] = 1;
		6'b111101: node_No[61] = 1;
		6'b111110: node_No[62] = 1;
		6'b111111: node_No[63] = 1;
		endcase
		//val <= next and generate signal for output
		if (node_No==64'hffffffffffffffff) begin
			for (i=0; i<n;i=i+1) nodeVal[i] = nodeVal_next[i];
			update = 1;
			for (t=0; t<N;t=t+1) node_No[t]=0;
			for (t=0; t<n;t=t+1) nodeVal_next[t]=dn;
		end
	end
end
//s: the number of score to be output each clk
always @ (posedge clk, posedge reset) begin
	if (reset) begin
	s<=0;
	update<=1;
	writeL<=0;
	dataOut<=31'h00000000;
	for (t=0; t<N;t=t+1) node_No[t]<=0;
	for (t=0; t<n;t=t+1) begin nodeVal_next[t]<=dn; nodeVal[t]<=24'h040000; end
	end
	else if (update) begin
		writeL<=1;
		dataOut<={nodeVal[s],node_Nout,1'b1};
		if (s!=15) s<=s+1;
		else begin 
			s<=0;
			update<=0;
		end
	end
	else begin dataOut<=31'h00000000; writeL<=0; end
end
/*
//Combinational logic
always @ (*) begin
	//For each node
	for (j=0; j<N; j=j+1) begin
		//initialize next state node val
		nodeVal_next[j] = dn;
		//Go through adjacency matrix to find node's neighbours
		for (k=0; k<N; k=k+1) begin
			if(adj[j][k]==1'b1) begin
				//Add db*nodeval[k]*nodeWeight[k]
				temp = db * nodeWeight[k] * nodeVal[k];
				nodeVal_next[j] = nodeVal_next[j] + temp[47:32]; 
			end
		end
	end
end

//Next state = current state
always @ (posedge clk, posedge reset) begin
  if (reset) begin
	for (i=0; i<N; i=i+1) begin
		nodeVal[i] <= 16'h4000; // reset to (1/N) = 0.25. Note --- Please update based on N.
	end
   end
   else begin
	for (i=0; i<N;i=i+1) begin	
		nodeVal[i] <= nodeVal_next[i]; 
	end
   end

end	
*/
endmodule

