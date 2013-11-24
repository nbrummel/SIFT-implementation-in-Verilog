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
reg [2:0] CurrentState;
reg [2:0] NextState;

wire [7:0] gauss_data;
reg [8:0] counter;
wire write_gauss;

assign rd_en_down = (CurrentState == STATE_WRITE) & valid;
assign gauss_data = din;
assign write_gauss = (CurrentState == STATE_WRITE) & valid;

DOWN_SAMPLE_FIFO dsf(
	//From ImageBufferWriter
	.rst(rst),
	.wr_clk(clk),
	.din(gauss_data),
	.wr_en(write_gauss), //my logic
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
	end
	else begin
		CurrentState <= NextState;
		counter <= counter + 9'd1;
	end
end

always @(*) begin
	case (CurrentState)
		STATE_IDLE: begin
			if (valid)
				NextState = STATE_WRITE;
			else
				NextState = STATE_IDLE;
		end
		STATE_WRITE: begin
			if (valid)
				NextState = STATE_WRITE;
			else
				NextState = STATE_IDLE;
		end
	endcase
end

endmodule