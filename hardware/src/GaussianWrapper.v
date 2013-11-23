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

wire [7:0] gauss_dout;
wire [7:0] gauss_din;
wire gauss_wr;
wire isFull;
wire gauss_reset;
wire double_reset;
wire gauss_enable;



GAUSSIAN gauss(
	.Clk(clk),
	.din(gauss_din),
	.Reset(double_reset),
	.Clk_en(gauss_enable),
	.dout(gauss_dout)
	);

DOWN_SAMPLE_FIFO gsf(
	//From ImageBufferWriter
	.rst(rst),
	.wr_clk(clk),
	.din(gauss_dout),
	.wr_en(gauss_wr), 
	.full(isFull),
	//To Gaussian Module
	.empty(empty),
	.rd_clk(clk),
	.rd_en(rd_en_up),
	.dout(dout),
	.valid(valid_out));

assign double_reset = (rst)|(gauss_reset);

//constants
localparam START_LENGTH = 18'd2411;

//state encoding for gaussian input
localparam  STATE_IDLE = 3'd0,
			STATE_ROW = 3'd1,
			STATE_BUFFER_1 = 3'd2,
			STATE_BUFFER_2 = 3'd3,
			STATE_END = 3'd4,
			STATE_RESET = 3'd5;

reg [2:0] CurrentState;
reg [2:0] NextState;

//For counting the row
reg [9:0] rowCounter;
//For counting the frame
reg [19:0] frameCounter;

assign gauss_din = (CurrentState == STATE_ROW) ? din : 8'd0;
assign gauss_wr = (CurrentState != STATE_IDLE) & (CurrentState != STATE_RESET);
assign gauss_reset = (CurrentState == STATE_RESET);
assign rd_en_down = valid & (CurrentState == STATE_ROW);

always@(posedge clk) begin
	if (rst) begin
		CurrentState <= STATE_IDLE;
		rowCounter <= 10'd0;
		frameCounter <= 20'd0;
	end
	else if (CurrentState == STATE_RESET) begin
		rowCounter <= 10'd0;
		frameCounter <= 20'd0;
	end
	else if (CurrentState == STATE_BUFFER_2) begin
		rowCounter <= 10'd0;
	end
	else begin
		CurrentState <= NextState;
	end
end

//Input logic
always @(*) begin
	case (CurrentState)
		STATE_IDLE: begin
			if (valid) begin
				if (rowCounter == 10'd399)
					NextState = STATE_BUFFER_1;
				else
					NextState = STATE_ROW;
			end
			else
				NextState = STATE_IDLE;
		end
		STATE_ROW: begin
			if (valid) begin
				if (rowCounter == 10'd399)
					NextState = STATE_BUFFER_1;
				else
					NextState = STATE_ROW;
			end
			else
				NextState = STATE_IDLE;
		end
		STATE_BUFFER_1: begin
			NextState = STATE_BUFFER_2;
		end
		STATE_BUFFER_2: begin
			if (valid) begin
				if (frameCounter == 20'd120599)
					NextState = STATE_END;
				else
					NextState = STATE_ROW;
			end
			else
				NextState = STATE_IDLE;
		end
		STATE_END: begin
			if (rowCounter == 10'd803)
				NextState = STATE_RESET;
			else
				NextState = STATE_END;
		end
		STATE_RESET: begin
			if (valid)
				NextState = STATE_ROW;
			else
				NextState = STATE_IDLE;
		end
	endcase
end

endmodule