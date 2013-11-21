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

localparam 	STATE_IDLE = 3'd0,
			STATE_READ = 3'd1,
			STATE_W1 = 3'd2,
			STATE_W2 = 3'd3,
			STATE_W3 = 3'd4;

reg [2:0] CurrentState;
reg [2:0] NextState;

assign dout = din;
assign valid_out = 1'b1;
assign rd_en = 1'b1;

always@(posedge clk) begin
	if (rst) begin
		CurrentState <= STATE_IDLE;
	end
	else begin
		CurrentState <= NextState;
	end
end

always @(*) begin
	case (CurrentState)
		STATE_IDLE: begin
			if (valid) begin
				NextState = STATE_READ;
			end
			else begin
				NextState = STATE_IDLE;
			end
		end
		STATE_READ: begin
			NextState = STATE_W1;
		end
		STATE_W1: begin
			NextState = STATE_W2;
		end
		STATE_W2: begin
			NextState = STATE_W3;
		end
		STATE_W3: begin
			if (valid) begin
				NextState = STATE_READ;
			end
			else begin
				NextState = STATE_IDLE;
			end
		end
	endcase
end

endmodule