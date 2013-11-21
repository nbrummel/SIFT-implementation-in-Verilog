//Up_Sample.v
module DOWN_SAMPLE #(
	parameter COL = 800)
	(
		input DOG_Clk,
		input [7:0] Din,
		input valid,
		input Reset,
		input Clk_en,

		input Ext_Clk,
		input rd_en_ext,

		output valid_ext,
		output [7:0] Ext_Out
	);

	wire [9:0] count;
	wire Ready;
	wire [7:0] Dout, sec_row;

	reg rd_row;

	initial rd_row <= 0;

	always @( posedge Ext_Clk ) begin
		if ( Reset ) 
			rd_row <= 1'b0;
	end

	always @( * ) begin
		if ( count == 9'd800 )
			rd_row = ~rd_row;
	end

	counter #(
		.COUNT_TO( COL ))
		col_count ( .clk( Ext_Clk ),
		.reset( Reset ),
		.enable( 1'b1 ),
		.ctr_out( count ));

 	// -- |SHIFT_REGISTER| --------------------------------------------------
	`define SHIFT_REGISTER
	
	`ifdef SHIFT_REGISTER

		shift_ram_800 srD2 (
			.Clk( Ext_Clk ),
			.ce( rd_en_ext ),
			.Sclr( reset ),
			.d( Dout ),
			.q( sec_row ));

	`endif // SHIFT_REGISTER

	assign valid_ext = Ext_Clk & rd_row & Ready;
	assign Ext_Out = rd_row ? sec_row : Dout;

	SAMPLE_FIFO usf (

		.rst( Reset ),
  		.wr_clk( DOG_Clk ),
  		.rd_clk( OUT_Clk ),
  		.din( Din ),
  		.wr_en( valid ),
  		.rd_en( rd_en_ext & !rd_row ),
  		.dout( Dout ),
  		.full( ),
  		.empty(),
  		.valid( Ready ));

endmodule
