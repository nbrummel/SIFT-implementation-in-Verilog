module GAUSSIAN(
	input clk,
	input [7:0] din,
	input rst,
	input clk_en,
	output [7:0] dout);

wire [7:0] midStuff;

ShiftReg_8x400 sr1 (
	.clk(clk),
	.ce(clk_en),
	.sclr(rst),
	.d(din),
	.q(midStuff));

ShiftReg_8x400 sr2 (
	.clk(clk),
	.ce(clk_en),
	.sclr(rst),
	.d(midStuff),
	.q(dout));

endmodule