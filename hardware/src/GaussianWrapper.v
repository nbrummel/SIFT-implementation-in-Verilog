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

wire [7:0] gauss_data;
reg [7:0] counter;

assign rd_en_down = 1'b1;
assign gauss_data = (counter == 8'b10000000) ? 8'd0 : din;

DOWN_SAMPLE_FIFO dsf(
	//From ImageBufferWriter
	.rst(rst),
	.wr_clk(clk),
	.din(gauss_data),
	.wr_en(valid), //my logic
	.full(), //need to take care of this
	//To Gaussian Module
	.empty(empty),
	.rd_clk(clk),
	.rd_en(rd_en_up),
	.dout(dout),
	.valid(valid_out));

always@(posedge clk) begin
	if (rst) begin
		counter <= 8'd0;
	end
	else begin
		counter <= counter + 8'd1;
	end
end

endmodule