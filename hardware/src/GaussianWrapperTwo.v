module GaussianWrapperTwo(
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

localparam shift_value = 11'd1612;

wire [7:0] gauss_in;
wire [7:0] gauss_out;
reg [10:0] shiftCounter;
wire write_gauss;
wire write_FIFO;
assign rd_en_down = valid;
assign gauss_in = din;
assign write_gauss = valid;
assign write_FIFO = write_gauss & (shiftCounter == shift_value);
wire [7:0] mid_gauss;

wire [7:0] c1, c2;
reg [7:0] c3, c4, c5, c6;
wire [7:0] in_fifo;

assign in_fifo = (gauss_out - c6) + 128;

GAUSSIAN g1(
	.clk(clk),
	.din(gauss_in),
	.rst(rst),
	.clk_en(write_gauss), //only shifts through if valid
	.dout(mid_gauss));

shift_ram_400 sr1(
    .clk(clk), 
    .ce(write_gauss), 
    .sclr(rst), 
    .q(c1),
    .d(mid_gauss)
);

shift_ram_400 sr2(
    .clk(clk), 
    .ce(write_gauss), 
    .sclr(rst), 
    .q(c2),
    .d(c1)
);

GAUSSIAN g2(
	.clk(clk),
	.din(mid_gauss),
	.rst(rst),
	.clk_en(write_gauss), //only shifts through if valid
	.dout(gauss_out));

DOWN_SAMPLE_FIFO dsf(
	//From ImageBufferWriter
	.rst(rst),
	.wr_clk(clk),
	.din(in_fifo),
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
		c3 <= 8'd0;
		c4 <= 8'd0;
		c5 <= 8'd0;
		c6 <= 8'd0;
	end
	else begin
		c3 <= c2;
		c4 <= c3;
		c5 <= c4;
		c6 <= c5;
		if ((shiftCounter < shift_value) & valid)
			shiftCounter <= shiftCounter + 11'd1;
	end
end

endmodule
