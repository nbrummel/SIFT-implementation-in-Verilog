`timescale 1ns / 1ps

module SramArbiterTest();

	localparam 	component_half = 100,
	 			arbiter_half = 50,
	 			Cycle = 200;

	reg 	component_clock,
	 		arbiter_clock,
	 		reset;

	initial begin
		component_clock = 0;
		arbiter_clock = 0;
		Reset = 1;
		#(Cycle);
		reset = 0;
	end
	always #(component_half) component_clock = ~component_clock;
	always #(arbiter_half) arbiter_clock = ~arbiter_clock;

	SramArbiter(
		.reset(),
		.w0_clock(),
		.w0_din_ready(),
		.w0_din_valid(),
		.w0_din(),

		.w1_clock(),
		.w1_din_ready(),
		.w1_din_valid(),
		.w1_din(),

		.r0_clock(),
		.r0_din_ready(),
		.r0_din_valid(),
		.r0_din(),
		.r0_dout_ready(),
		.r0_dout_valid(),
		.r0_dout(),

		.r1_clock(),
		.r1_din_ready(),
		.r1_din_valid(),
		.r1_din(),
		.r1_dout_ready(),
		.r1_dout_valid(),
		.r1_dout(),

		.sram_clock(),
		.sram_addr_valid(),
		.sram_ready(),
		

		);

endmodule