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

localparam shift_value = 11'd806;

assign rd_en_down = valid;
wire [7:0] gauss_out;
reg [10:0] shiftCounter;
wire [7:0] mid_gauss;
wire [7:0] shift_output;
wire [7:0] into_fifo;
wire [7:0] c1, c2;
wire write_gauss;
wire write_FIFO;
assign write_FIFO = valid & (shiftCounter == shift_value);

GAUSSIAN g1(
	.clk(clk),
	.din(din),
	.rst(rst),
	.clk_en(valid), //only shifts through if valid
	.dout(mid_gauss));

shift_ram_800 sr (
	.clk(clk),
	.ce(valid),
	.sclr(rst),
	.d(mid_gauss),
	.q(shift_output));

GAUSSIANTWO g2(
	.clk(clk),
	.din(mid_gauss),
	.rst(rst),
	.clk_en(valid), //only shifts through if valid
	.dout(gauss_out));

assign into_fifo = shift_output - gauss_out + 128;

DOWN_SAMPLE_FIFO dsf(
	//From ImageBufferWriter
	.rst(rst),
	.wr_clk(clk),
	.din(into_fifo),
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
		shiftCounter <= 11'd0;
	end
	else begin
		if ((shiftCounter < shift_value) & valid)
			shiftCounter <= shiftCounter + 11'd1;
	end
end

endmodule
