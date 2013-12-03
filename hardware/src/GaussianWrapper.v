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

localparam shift_value = 10'd806;

wire [7:0] gauss_in;
wire [7:0] gauss_out;
reg [8:0] counter;
reg [9:0] shiftCounter;
wire write_gauss;
wire write_FIFO;
assign rd_en_down = valid;
assign gauss_in = din;
assign write_gauss = valid;
assign write_FIFO = write_gauss & (shiftCounter == shift_value);

GAUSSIAN g1(
	.clk(clk),
	.din(gauss_in),
	.rst(rst),
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
	.empty(empty),
	.rd_clk(clk),
	.rd_en(rd_en_up),
	.dout(dout),
	.valid(valid_out));

always@(posedge clk) begin
	if (rst) begin
		counter <= 9'd0;
		shiftCounter <= 10'd0;
	end
	else begin
		if (counter == 9'd400)
			counter <= 9'd0;
		if ((shiftCounter < shift_value) & write_gauss)
			shiftCounter <= shiftCounter + 10'd1;
		//else if (NextState != STATE_IDLE)
			//counter <= counter + 9'd1;
	end
end

endmodule
