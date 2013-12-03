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

wire [7:0] gauss_in;
wire [7:0] gauss_out;
reg [19:0] shiftCounter;
wire write_gauss;
wire write_FIFO;
wire reset_gauss;
wire gauss_valid_out;
assign rd_en_down = valid;
assign gauss_in = din;
assign write_gauss = valid & (shiftCounter < 20'd120000);
assign write_FIFO = gauss_valid_out & valid;
assign reset_gauss = rst | (shiftCounter == 20'd120000);

GAUSSIAN g1(
	.clk(clk),
	.din(gauss_in),
	.valid_in(write_gauss),
	.valid_out(gauss_valid_out),
	.rst(reset_gauss),
	.clk_en(write_gauss), //only shifts through if valid
	.dout(gauss_out));

DOWN_SAMPLE_FIFO dsf(
	//From ImageBufferWriter
	.rst(rst),
	.wr_clk(clk),
	.din(gauss_out),
	.wr_en(write_FIFO), //my logic
	.full(), //need to take care of this
	//To Gaussian Module
	.empty(),
	.rd_clk(clk),
	.rd_en(rd_en_up),
	.dout(dout),
	.valid(valid_out));

always@(posedge clk) begin
	if (rst) begin
		shiftCounter <= 20'd0;
	end
	else begin
		if ((shiftCounter < 20'd120000) & valid)
			shiftCounter <= shiftCounter + 20'd1;
		else if (valid)
			shiftCounter <= 20'd0;
	end
end

endmodule
