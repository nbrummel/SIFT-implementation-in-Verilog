module DownSampler(
	//General
	input rst,
	//Clock
	input clk,

	//Interfacing with the ImageBufferWriter
	input [7:0] din,
	input valid,
	output ready,

	//Sending to the Gaussian Module
	output valid,
	output [7:0] dout,
	output empty,
	input rd_en);

reg down_sample_valid;
reg full_signal;

assign ready = ~full_signal;

DOWN_SAMPLE_FIFO dsf(
	//From ImageBufferWriter
	.rst(rst),
	.wr_clk(clk),
	.din(din),
	.wr_en(down_sample_valid), //my logic
	.full(full_signal), //need to take care of this
	//To Gaussian Module
	.empty(empty),
	.rd_clk(clk),
	.rd_en(rd_en),
	.dout(dout),
	.valid(valid));

assign down_sample_valid = valid & (CurrentState == STATE_WRITE)

localparam 	STATE_IDLE = 2'd0,
			STATE_WRITE = 2'd1,
			STATE_SKIP = 2'd2,
			STATE_ROW = 2'd3;

reg [1:0] CurrentState;
reg [1:0] NextState;
reg [10:0] rowCounter;

always@(posedge clk) begin
	if (reset) begin
		CurentState <= STATE_IDLE;
		rowCounter <= 11'd0;
	end
	else begin
		CurrentState <= NextState;
		if (valid)
			if (rowCounter == 11'd1599)
				rowCounter <= 11'd0;
			else
				rowCounter <= rowCounter + 11'd1;
	end
end

always @(*) begin
	case (CurrentState)
		STATE_IDLE: begin
			if (valid)
				NextState = STATE_WRITE
			else
				NextState = STATE_IDLE
		end
		STATE_WRITE: begin
			if (valid)
				NextState = STATE_SKIP
			else
				NextState = STATE_WRITE //will check valid before asserting everything
		end
		STATE_SKIP: begin
			if ((rowCounter < 11'd799) & valid)
				NextState = STATE_WRITE
			else if (valid)
				NextState = STATE_ROW
			else
				NextState = STATE_SKIP
		end
		STATE_ROW: begin
			if (valid && (rowCounter == 11'd1599))
				NextState = STATE_WRITE
			else
				NextState = STATE_ROW
		end
	end
end

