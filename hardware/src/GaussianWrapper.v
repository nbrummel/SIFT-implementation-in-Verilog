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

assign valid_out = valid;
assign dout = din;
assign rd_en_down = rd_en_up;

endmodule