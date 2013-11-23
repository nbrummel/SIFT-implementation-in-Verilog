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
	reg counter_reset;
	wire gauss_enable;

	GAUSSIAN gauss(
		.Clk(clk),
		.din(gauss_din),
		.Reset(double_reset),
		.Clk_en(gauss_enable),
		.dout(gauss_dout)
		);

	DOWN_SAMPLE_FIFO up_sample_fifo(

		//From Gaussian
		.rst(rst),
		.wr_clk(clk),
		.din(gauss_dout),
		.wr_en(gauss_wr), 
		.full(isFull),

		//To up sample module
		.empty(empty),
		.rd_clk(clk),
		.rd_en(rd_en_up),
		.dout(dout),
		.valid(valid_out));

	//constants
	localparam 	PRE_BUFF_LENGTH = 18'd802,
							DATA_OUT_LENGTH = 18'd400,
							COL_BUFF_LENGTH = 2'd2,
							ROW_BUFF_LENGTH = 18'd800,
							FRAME_LENGTH = 18'd300;

	//state encoding for gaussian input
	localparam  STATE_IDLE = 3'd0,
							PRE_BUFF = 3'd1,
							DATA_OUT = 3'd2,
							COL_BUFF = 3'd3,
							ROW_BUFF = 3'd4,
							FRAME = 3'd5,
							RESET = 3'd6;

	reg [2:0] CurrentState;
	reg [2:0] NextState;

	wire [] pre_buff_count,
				pre_buff_valid,
			 []	data_out_count,
				data_out_valid,
			  [] col_buff_count,
			  col_buff_valid,
			  [] row_buff_count,
			  row_buff_valid,
			  [] frame_count,
			  frame_valid;

	assign gauss_dout = (CurrentState == DATA_OUT) ? din : 8'd0;
	assign gauss_wr = (CurrentState != STATE_IDLE) & (CurrentState != RESET);
	assign gauss_reset = (CurrentState == RESET);
	assign rd_en_down = valid & (CurrentState == DATA_OUT);

	gauss_counter #(
					.COUNT_TO(PRE_BUFF_LENGTH))
					pre_buff_counter (
					.clk(clk),
					.reset(counter_reset),
					.enable(pre_buff_valid),
					.ctr_out(pre_buff_count));

	gauss_counter #(
        .COUNT_TO(DATA_OUT_LENGTH))
        data_out_counter (
        .clk(clk),
        .reset(counter_reset),
        .enable(data_out_valid),
        .ctr_out(data_out_count));

  gauss_counter #(
        .COUNT_TO(COL_BUFF_LENGTH))
        col_buff_counter (
        .clk(clk),
        .reset(counter_reset),
        .enable(col_buff_valid),
        .ctr_out(col_buff_count));

  gauss_counter #(
        .COUNT_TO(ROW_BUFF_LENGTH))
        row_buff_counter (
        .clk(clk),
        .reset(counter_reset),
        .enable(row_buff_valid),
        .ctr_out(row_buff_count));      

  gauss_counter #(
        .COUNT_TO(FRAME_LENGTH))
        frame_counter (
        .clk(clk),
        .reset(counter_reset),
        .enable(frame_valid),
        .ctr_out(frame_count));

  assign pre_buff_valid = (CurrentState == PRE_BUFF);
  assign data_out_valid = (currentState == DATA_OUT);
  assign col_buff_valid = (currentState == COL_BUFF);
  assign row_buff_valid = (currentState == ROW_BUFF);
  assign frame_valid = (currentState == DATA_OUT) | (currentState == COL_BUFF);
	always@(posedge clk) begin
    if (rst) begin
    	counter_reset <= 1'b1;
      CurrentState <= RESET;    
    end
    else if (valid | ~rd_en_up) 
    	
    	CurrentState <= Nextstate;
    else begin
      CurrentState <= STATE_IDLE;
	end

	//Input logic
	always @(*) begin
    case (CurrentState)
      STATE_IDLE: begin

			  end
			PRE_BUFF : begin
		
  end

  STATE_IDLE = 3'd0,
							PRE_BUFF = 3'd1,
							DATA_OUT = 3'd2,
							COL_BUFF = 3'd3,
							ROW_BUFF = 3'd4,
							FRAME = 3'd5,
							RESET = 3'd6;

endmodule