module GAUSSIAN(
	input clk,
	input [7:0] din,
	input rst,
	input clk_en,
	output [7:0] dout);

localparam 	h0 = 8'd6,
			h1 = 8'd58,
			h2 = 8'd128;

reg [7:0] reg1;
reg [7:0] reg2;
reg [7:0] reg3;
reg [7:0] reg4;
wire [15:0] sum1;

assign sum1 = h0*din + h1*reg1 + h2*reg2 + h1*reg3 + h0*reg4;

always @(posedge clk)
	if (rst) begin
		reg1 <= 8'd0;
		reg2 <= 8'd1;
		reg3 <= 8'd2;
		reg4 <= 8'd3;
	end
	else begin
		reg1 <= din;
		reg2 <= reg1;
		reg3 <= reg2;
		reg4 <= reg3;
	end

wire [7:0] in_sr1;
wire [7:0] in_sr2;
wire [7:0] in_sr3;
wire [7:0] in_sr4;
wire [7:0] out_sr4;
wire [15:0] sum2;

assign in_sr1 = sum1[15:8];
assign sum2 = h0*in_sr1 + h1*in_sr2 + h2*in_sr3 + h1*in_sr4 + h0*out_sr4;
assign dout = sum2[15:8];

ShiftReg_8x400 sr1 (
	.clk(clk),
	.ce(clk_en),
	.sclr(rst),
	.d(in_sr1),
	.q(in_sr2));

ShiftReg_8x400 sr2 (
	.clk(clk),
	.ce(clk_en),
	.sclr(rst),
	.d(in_sr2),
	.q(in_sr3));

ShiftReg_8x400 sr3 (
	.clk(clk),
	.ce(clk_en),
	.sclr(rst),
	.d(in_sr3),
	.q(in_sr4));

ShiftReg_8x400 sr4 (
	.clk(clk),
	.ce(clk_en),
	.sclr(rst),
	.d(in_sr4),
	.q(out_sr4));

endmodule