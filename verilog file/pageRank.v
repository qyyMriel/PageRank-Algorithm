module pageRank 
#(parameter N=64,WIDTH=31) 
(input clk,input reset,input [N*N-1:0] adjacency, input [N*(WIDTH-7)-1:0] weights, 
output [10*(WIDTH-7)-1:0] top10Vals,output [10*6-1:0] top10IDs, output done);

wire [WIDTH-1:0] unsort_00, unsort_01, unsort_10, unsort_11; 

sortvals # (WIDTH,N) sort (clk,reset,
 unsort_00, unsort_01, unsort_10, unsort_11,
 top10Vals, top10IDs, done);

cpuNrouter #(N, WIDTH, 16) cNr
(clk,
reset,
adjacency,
weights,
unsort_00,
unsort_01,
unsort_10,
unsort_11);

endmodule
