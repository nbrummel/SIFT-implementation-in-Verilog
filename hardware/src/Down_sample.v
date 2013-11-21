//DOWN_SAMPLE
module Down_sample #(
	parameter COL = 800,
			  ROW = 600)
	(
		input VGA_Clk,
		input DOG_Clk,
		input [7:0] Din,
		input valid,
		input Reset,
		input Clk_en,

		output [7:0] Dout,
		output Ready,
		output Empty
	);

	wire data_valid, row_valid;

	reg [9:0] col_counter, row_counter;

	always @(posedge VGA_Clk) begin
		if (Reset || row_counter == ROW) 
			row_counter <= 1'b0;
		else if (col_counter == COL) 
			row_counter <= row_counter + 1;
		else
			row_counter <= row_counter;
	end

	
	counter #(
		.COUNT_TO(COL))
		cc (
		.clk(VGA_Clk),
		.reset(Reset),
		.enable(valid),
		.ctr_out(col_couter));

	assign data_valid = ~(col_couter % 2 == 0) && ~(row_counter % 2 == 0) && valid;

	// ------------------------- |SAMPLE_FIFO| -------------------------------------
	`define SAMPLE_FIFO

	`ifdef SAMPLE_FIFO
	
	SAMPLE_FIFO dsf (
		.rst(Reset),
  		.wr_clk(VGA_Clk),
  		.din(Din),
  		.wr_en(data_valid),
  		.full(),
  		
  		.rd_clk(DOG_Clk),
  		.dout(Dout),
  		.rd_en(Ready),
  		.empty(Empty),
  		.valid());

	`endif // SAMPLE_FIFO
	`endif
endmodule	