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

localparam 	STATE_IDLE = 3'd1,
			STATE_WRITE = 3'd2,
			STATE_BUFFER = 3'd3;

localparam shift_value = 10'd799;

reg [2:0] CurrentState;
reg [2:0] NextState;

wire [7:0] gauss_in;
wire [7:0] gauss_out;
reg [8:0] counter;
reg [9:0] shiftCounter;
wire write_gauss;
wire write_FIFO;
assign rd_en_down = (CurrentState == STATE_WRITE) & valid;
assign gauss_in = (CurrentState == STATE_BUFFER) ? 8'd0 : din;
assign write_gauss = (CurrentState != STATE_IDLE) & valid;// & (shiftCounter == shift_value);
assign write_FIFO = write_gauss & (shiftCounter == shift_value);

GAUSSIAN g(
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
		CurrentState <= STATE_IDLE;
		counter <= 9'd0;
		shiftCounter <= 10'd0;
	end
	else begin
		CurrentState <= NextState;
		if (counter == 9'd400)
			counter <= 9'd0;
		if ((shiftCounter < shift_value) & write_gauss)
			shiftCounter <= shiftCounter + 10'd1;
		//else if (NextState != STATE_IDLE)
			//counter <= counter + 9'd1;
	end
end

always @(*) begin
	case (CurrentState)
		STATE_IDLE: begin
			if (counter == 9'd399)
				NextState = STATE_BUFFER;
			else if (valid)
				NextState = STATE_WRITE;
			else
				NextState = STATE_IDLE;
		end
		STATE_WRITE: begin
			if (counter == 9'd399)
				NextState = STATE_BUFFER;
			else if (valid)
				NextState = STATE_WRITE;
			else
				NextState = STATE_IDLE;
		end
		STATE_BUFFER: begin
			if (counter == 9'd400)
				NextState = STATE_BUFFER;
			else if (valid)
				NextState = STATE_WRITE;
			else
				NextState = STATE_IDLE;
		end
	endcase
end

endmodule
