module UpSampler(
	//General
	input rst,
	//Clock
	input clk,

	//Input
	input valid,
	input [7:0] din,
	input empty,
	output rd_en,

	//Output
	output [7:0] dout,
	output valid_out
);

wire [7:0] shift_out;
wire shift_en;

shift_ram_800 srf (
	.clk(clk),
	.ce(shift_en),
	.sclr(rst),
	.q(shift_out),
	.d(din)
	);

localparam 	STATE_IDLE = 3'd0,
			STATE_WRITE = 3'd1,
			STATE_SKIP = 3'd2,
			STATE_ROW = 3'd3;

reg [2:0] CurrentState;
reg [2:0] NextState;
reg [10:0] rowCounter;

assign dout = (CurrentState == STATE_WRITE) ? din : (CurrentState == STATE_SKIP) ? din : shift_out;
assign valid_out = (valid & CurrentState == STATE_WRITE) | (CurrentState != STATE_WRITE);
assign shift_en = valid;
assign rd_en = (CurrentState == STATE_SKIP);

always@(posedge clk) begin
	if (rst) begin
		CurrentState <= STATE_WRITE;
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
		STATE_WRITE: begin
			if (valid)
				NextState = STATE_SKIP;
			else
				NextState = STATE_WRITE; //will check valid before asserting everything
		end
		STATE_SKIP: begin
			if ((rowCounter < 11'd799) & valid)
				NextState = STATE_WRITE;
			else if (valid)
				NextState = STATE_ROW;
			else
				NextState = STATE_SKIP;
		end
		STATE_ROW: begin
			if (valid && (rowCounter == 11'd1599))
				NextState = STATE_WRITE;
			else
				NextState = STATE_ROW;
		end
	endcase
end

endmodule