module GaussianWrapper(
	//Global
	input rst,
	input clk,
	//From the Down Sampler
	input valid,
	input [7:0] din,
	output rd_en_down,
	//To the Up Sampler
	output valid_out_DOG,
	output [7:0] dout_DOG,
	output valid_out_g1,
	output [7:0] dout_g1,
	output valid_out_g2,
	output [7:0] dout_g2,
	output empty,
	input rd_en_up_DOG,
	input rd_en_up_g1,
	input rd_en_up_g2);

localparam shift_value = 11'd1612;

assign rd_en_down = valid;
wire [7:0] gauss_out;
reg [10:0] shiftCounter;
wire [7:0] mid_gauss;
wire [7:0] mid_gauss_2;
wire [7:0] shift_output;
wire [7:0] into_fifo;
wire [7:0] c1, c2;
wire write_gauss;
wire write_FIFO;
assign write_FIFO = valid & (shiftCounter == shift_value);

reg [7:0] delay_1, delay_2;

GAUSSIAN g1(
	.clk(clk),
	.din(din),
	.rst(rst),
	.clk_en(valid), //only shifts through if valid
	.dout(mid_gauss));

shift_ram_800 sr(
	.clk(clk),
	.ce(valid),
	.sclr(rst),
	.d(mid_gauss),
	.q(mid_gauss_2));

shift_ram_400 sr2(
	.clk(clk),
	.ce(valid),
	.sclr(rst),
	.d(mid_gauss_2),
	.q(shift_output));

GAUSSIANTWO g2(
	.clk(clk),
	.din(mid_gauss),
	.rst(rst),
	.clk_en(valid), //only shifts through if valid
	.dout(gauss_out));

assign into_fifo = (delay_2 - gauss_out)*8 + 64;

DOWN_SAMPLE_FIFO dsf_DOG(
	//From ImageBufferWriter
	.rst(rst),
	.wr_clk(clk),
	.din(into_fifo),
	.wr_en(write_FIFO), //my logic
	.full(), //need to take care of this
	//To Gaussian Module
	.empty(),
	.rd_clk(clk),
	.rd_en(rd_en_up_DOG),
	.dout(dout_DOG),
	.valid(valid_out_DOG));

DOWN_SAMPLE_FIFO dsf_g1(
	//From ImageBufferWriter
	.rst(rst),
	.wr_clk(clk),
	.din(mid_gauss),
	.wr_en(write_FIFO), //my logic
	.full(), //need to take care of this
	//To Gaussian Module
	.empty(),
	.rd_clk(clk),
	.rd_en(rd_en_up_g1),
	.dout(dout_g1),
	.valid(valid_out_g1));

DOWN_SAMPLE_FIFO dsf_g2(
	//From ImageBufferWriter
	.rst(rst),
	.wr_clk(clk),
	.din(gauss_out),
	.wr_en(write_FIFO), //my logic
	.full(), //need to take care of this
	//To Gaussian Module
	.empty(),
	.rd_clk(clk),
	.rd_en(rd_en_up_g2),
	.dout(dout_g2),
	.valid(valid_out_g2));

always@(posedge clk) begin
	if (rst) begin
		shiftCounter <= 11'd0;
		delay_1 <= 8'd0;
		delay_2 <= 8'd0;
	end
	else begin
		delay_1 <= shift_output;
		delay_2 <= delay_1;
		if ((shiftCounter < shift_value) & valid)
			shiftCounter <= shiftCounter + 11'd1;
	end
end

endmodule
