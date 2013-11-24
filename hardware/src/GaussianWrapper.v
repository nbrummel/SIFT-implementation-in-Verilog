module GaussianWrapper(
	//Global
	input rst,
	input clk,
	//From the Down Sampler
	input valid,
	input [7:0] din,
	output rd_en_down,
	//To the Up Sampler
	output valid_out,
	output [7:0] dout,
	output empty,
	input rd_en_up);

DOWN_SAMPLE_FIFO gsf(
	//From ImageBufferWriter
	.rst(rst),
	.wr_clk(clk),
	.din(din),
	.wr_en(valid), 
	.full(isFull),

	//To Gaussian Module
	.empty(empty),
	.rd_clk(clk),
	.rd_en(rd_en_up),
	.dout(dout),
	.valid(valid_out));

endmodule