module DownSampler(
	//General
	input rst,
	//Clock
	input wr_clk,
	input rd_clk,

	//Interfacing with the ImageBufferWriter
	input [7:0] din,
	input valid,
	output ready,

	//Sending to the Gaussian Module
	output valid_out,
	output [7:0] dout,
	output empty,
	input rd_en);

wire down_sample_valid;
wire full_signal;

DOWN_SAMPLE_FIFO dsf(
	//From ImageBufferWriter
	.rst(rst),
	.wr_clk(wr_clk),
	.din(din),
	.wr_en(down_sample_valid), //my logic
	.full(full_signal), //need to take care of this
	//To Gaussian Module
	.empty(empty),
	.rd_clk(rd_clk),
	.rd_en(rd_en),
	.dout(dout),
	.valid(valid_out));

reg [10:0] rowCounter;

assign ready = 1'b1;
assign down_sample_valid = valid & (rowCounter < 11'd799) & (rowCounter % 2 == 0);

always@(posedge wr_clk) begin
	if (rst) begin
		rowCounter <= 11'd0;
	end
	else begin
		if (valid) begin
			if (rowCounter == 11'd1599)
				rowCounter <= 11'd0;
			else
				rowCounter <= rowCounter + 11'd1;
		end
	end
end

endmodule
