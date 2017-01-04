module cpuNrouter #(parameter N=64, WIDTH=31, DEPTH=16)
(input clk,
input reset,
input [N*N-1:0] adjacency,
input [N*(WIDTH-7)-1:0] weights,
output [WIDTH-1:0] dataOut_00,
output [WIDTH-1:0] dataOut_01,
output [WIDTH-1:0] dataOut_10,
output [WIDTH-1:0] dataOut_11);

wire [WIDTH-1:0] dataOutN_00, dataOutN_01, dataOutN_10, dataOutN_11, dataInN_00, dataInN_01, dataInN_10, dataInN_11;
wire [WIDTH-1:0] dataOutE_00, dataOutE_01, dataOutE_10, dataOutE_11;
wire [WIDTH-1:0] dataOutW_00, dataOutW_01, dataOutW_10, dataOutW_11;
wire [WIDTH-1:0] dataOutS_00, dataOutS_01, dataOutS_10, dataOutS_11;
assign dataInN_00 = dataOut_00;
assign dataInN_01 = dataOut_01;
assign dataInN_10 = dataOut_10;
assign dataInN_11 = dataOut_11;

wire writeLocal_00, writeLocal_01, writeLocal_10, writeLocal_11;
wire writeN_00, writeN_01, writeN_10, writeN_11;
assign writeN_00 = writeLocal_00;
assign writeN_01 = writeLocal_01;
assign writeN_10 = writeLocal_10;
assign writeN_11 = writeLocal_11;

cpu #(N, WIDTH, 6'b000000) cpu_00
(
clk, 
reset,
adjacency,
weights,
dataOutN_00,
writeLocal_00,//
dataOut_00);//

cpu #(N, WIDTH, 6'b010000) cpu_01
(
clk,
reset,
adjacency,
weights,
dataOutN_01,
writeLocal_01,//
dataOut_01);//

cpu #(N, WIDTH, 6'b100000) cpu_10
(
clk,
reset,
adjacency,
weights,
dataOutN_10,
writeLocal_10,//
dataOut_10);//

cpu #(N, WIDTH, 6'b110000) cpu_11
(
clk,
reset,
adjacency,
weights,
dataOutN_11,
writeLocal_11,//
dataOut_11);//


pro_router #(WIDTH, DEPTH) router_00 
(clk, 
 reset, 
 writetoW_01,//input writeE_00, 
 writetoE_11,//input writeW_00, 
 writeN_00,//input writeN_00, 
 writetoS_10,//input writeS_00,//write ports
 dataOutW_01,//input [WIDTH-1:0] dataInE, 
 dataOutE_11,//input [WIDTH-1:0] dataInW, 
 dataOut_00,//input [WIDTH-1:0] dataInN,
 dataOutS_10,//input [WIDTH-1:0] dataInS, //write data ports
 writetoE_00,//output  writetoE_00,
 writetoW_00,//output  writetoW_00,
 writetoS_00,//output  writetoS_00,
 dataOutE_00,//output  [WIDTH-1:0] dataOutE,
 dataOutW_00,//output  [WIDTH-1:0] dataOutW,
 dataOutN_00,//output  [WIDTH-1:0] dataOutN_00,
 dataOutS_00,//output  [WIDTH-1:0] dataOutS, //output ports
 fullE_00, 
 almost_fullE_00, 
 fullW_00, 
 almost_fullW_00, 
 fullN_00, 
 almost_fullN_00,
 fullS_00, 
 almost_fullS_00 //full outputs from FIFOs
 );
pro_router #(WIDTH, DEPTH) router_01 
(clk, 
 reset, 
 writetoW_10,//input writeE, 
 writetoE_00,//input writeW, 
 writeN_01,//input writeN, 
 writetoS_11,//input writeS,//write ports
 dataOutW_10,//input [WIDTH-1:0] dataInE, 
 dataOutE_00,//input [WIDTH-1:0] dataInW, 
 dataOut_01,//input [WIDTH-1:0] dataInN,
 dataOutS_11,//input [WIDTH-1:0] dataInS, //write data ports
 writetoE_01,//output  writetoE,
 writetoW_01,//output  writetoW,
 writetoS_01,//output  writetoS,
 dataOutE_01,//output  [WIDTH-1:0] dataOutE,
 dataOutW_01,//output  [WIDTH-1:0] dataOutW,
 dataOutN_01,//output  [WIDTH-1:0] dataOutN,
 dataOutS_01,//output  [WIDTH-1:0] dataOutS, //output ports
 fullE_01, 
 almost_fullE_01, 
 fullW_01, 
 almost_fullW_01, 
 fullN_01, 
 almost_fullN_01,
 fullS_01, 
 almost_fullS_01 //full outputs from FIFOs
 );
pro_router #(WIDTH, DEPTH) router_10 
(clk, 
 reset, 
 writetoW_11, 
 writetoE_01, 
 writeN_10, 
 writetoS_00,//write ports
 dataOutW_11,//input [WIDTH-1:0] dataInE, 
 dataOutE_01,//input [WIDTH-1:0] dataInW, 
 dataOut_10,//input [WIDTH-1:0] dataInN,
 dataOutS_00,//input [WIDTH-1:0] dataInS, //write data ports
 writetoE_10,
 writetoW_10,
 writetoS_10,
 dataOutE_10,
 dataOutW_10,
 dataOutN_10,
 dataOutS_10, //output ports
 fullE_10, 
 almost_fullE_10, 
 fullW_10, 
 almost_fullW_10, 
 fullN_10, 
 almost_fullN_10,
 fullS_10, 
 almost_fullS_10 //full outputs from FIFOs
 );
pro_router #(WIDTH, DEPTH) router_11 
(clk, 
 reset, 
 writetoW_00, 
 writetoE_10, 
 writeN_11, 
 writetoS_01,//write ports
 dataOutW_00, 
 dataOutE_10, 
 dataOut_11,
 dataOutS_01, //write data ports
 writetoE_11,
 writetoW_11,
 writetoS_11,
 dataOutE_11,
 dataOutW_11,
 dataOutN_11,
 dataOutS_11, //output ports
 fullE_11, 
 almost_fullE_11, 
 fullW_11, 
 almost_fullW_11, 
 fullN_11, 
 almost_fullN_11,
 fullS_11, 
 almost_fullS_11 //full outputs from FIFOs
 );
endmodule
