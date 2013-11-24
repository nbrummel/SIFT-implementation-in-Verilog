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

assign rd_en_down = 1'b1;

localparam 	STATE_WRITE = 3'd0,
			STATE_BUFFER = 3'd1;

reg [2:0] CurrentState;
reg [2:0] NextState;

wire [7:0] gaussian_data;
wire gauss_valid;
reg insert_buffer;
reg [7:0] counter;

//assign gauss_valid = valid | insert_buffer;
//assign gaussian_data = (CurrentState == STATE_WRITE) ? din : 8'd0;

DOWN_SAMPLE_FIFO gwf(
	//From ImageBufferWriter
	.rst(rst),
	.wr_clk(clk),
	.din(din),
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
		CurrentState <= STATE_WRITE;
		counter <= 8'd0;
		insert_buffer <= 1'b0;
	end
	else begin
		if (NextState == STATE_BUFFER)
			insert_buffer <= 1'b1;
		else
			insert_buffer <= 1'b0;
		CurrentState <= NextState;
		counter <= counter + 8'd1;
	end
end

always@(*) begin
	case (CurrentState)
		STATE_WRITE: begin
			if (counter == 8'b10000000)
				NextState = STATE_BUFFER;
			else
				NextState = STATE_WRITE;
		end
		STATE_BUFFER: begin
			NextState = STATE_WRITE;
		end
	endcase
end

endmodule