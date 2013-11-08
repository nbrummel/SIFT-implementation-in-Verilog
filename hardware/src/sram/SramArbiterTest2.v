`timescale 1ns / 1ps

module SramArbiterTest2();

	localparam 	port_half = 1000,
				arbiter_half = 500;
	localparam 	port_cycle = 2*port_half,
				arbiter_cycle = 2*arbiter_half;

	reg port_clock;
    reg arbiter_clock;
    reg reset;

    always #(port_half) port_clock = ~port_clock;
	always #(arbiter_half) arbiter_clock = ~arbiter_clock;

	//w0
	wire w0_din_ready; //input
	reg w0_din_valid; //input
	reg [53:0] w0_din; //input

	//w1
	wire w1_din_ready; //input
	reg w1_din_valid; //input
	reg [53:0] w1_din; //input

	//r0
	wire r0_din_ready; //output
	reg r0_din_valid; //input
	reg [17:0] r0_din; //input
	reg r0_dout_ready; //input
	wire r0_dout_valid; //output
	wire [31:0] r0_dout; //output

	//r1
	wire r1_din_ready; //output
	reg r1_din_valid; //input
	reg [17:0] r1_din; //input
	reg r1_dout_ready; //input
	wire r1_dout_valid; //output
	wire [31:0] r1_dout; //output

	//Simulating the SRAM
	wire sram_addr_valid; //output
	wire [17:0] sram_addr; //output
	wire [31:0] sram_data_in; //output
	wire [3:0] sram_write_mask; //output
	reg [31:0] sram_data_out; //input
	reg sram_data_out_valid; //input

	wire [2:0] currentState;

	SramArbiter dut(
                .reset(reset),
                .theState(currentState),

		      	// W0: Image Buffer Writer
		        .w0_clock(port_clock),
		        .w0_din_ready(w0_din_ready),
		        .w0_din_valid(w0_din_valid),
		        .w0_din(w0_din),// {mask,addr,data}

		      	// W1: Overlay Writer
		        .w1_clock(port_clock),
		        .w1_din_ready(w1_din_ready),
		        .w1_din_valid(w1_din_valid),
		        .w1_din(w1_din),// {mask,addr,data}

		      	// R0: Image Buffer Reader
		        .r0_clock(port_clock),
		        .r0_din_ready(r0_din_ready), //out
		        .r0_din_valid(r0_din_valid),
		        .r0_din(r0_din),
		        .r0_dout_ready(r0_dout_ready),
		        .r0_dout_valid(r0_dout_valid), //out
		        .r0_dout(r0_dout), //out

		      	// R1
		        .r1_clock(port_clock),
		        .r1_din_ready(r1_din_ready), //out
		        .r1_din_valid(r1_din_valid),
		        .r1_din(r1_din),
		        .r1_dout_ready(r1_dout_ready),
		        .r1_dout_valid(r1_dout_valid), //out
		        .r1_dout(r1_dout), //out
				
				// SRAM Interface
                .sram_clock(arbiter_clock),
		        .sram_addr_valid(sram_addr_valid), //out
		        .sram_ready(1'b1), 
		        .sram_addr(sram_addr), //out
		        .sram_data_in(sram_data_in), //out
		        .sram_write_mask(sram_write_mask), //out
		        .sram_data_out(sram_data_out), //input
		        .sram_data_out_valid(sram_data_out_valid)); //input

	initial begin

		port_clock = 0;
  		arbiter_clock = 0;
  		reset = 1;
  		sram_data_out_valid = 0;
  		sram_data_out = 32'd0;
  		#(arbiter_cycle);
  		#(arbiter_cycle);
  		#(arbiter_cycle);
  		reset = 0;

		r0_din_valid = 0;
		r1_din_valid = 0;

		w0_din = {4'b1111, 18'd0, 32'd0};
		w0_din_valid = 1;
		w1_din = {4'b1111, 18'd1, 32'd1};
		w1_din_valid = 1;
		r0_din = {18'd3};
		r0_din_valid = 1;
		r1_din = {18'd4};
		r1_din_valid = 1;
		#(7*arbiter_cycle); //FIFO STARTUP DELAY
		#(port_cycle); //ONE FULL SET LOADED INTO FIFO
		#(port_cycle); //SECOND FULL SET LOADED INTO FIFO
		w0_din_valid = 0;
		w1_din_valid = 0;
		#(arbiter_cycle); //LOADING JUST w0 AND w1
		r0_din_valid = 0;
		r1_din_valid = 0;
		#(4*arbiter_cycle);//FIFO WRITE TO READ DELAY
		//IDLE
		$display("sram_valid: %d sram_addr: 0x%h, sram_data_in: 0x%h, sram_write_mask: 0x%h", sram_addr_valid, sram_addr, sram_data_in, sram_write_mask);
		$display("sram_data_out_valid: %d, sram_data_out: 0x%h", sram_data_out_valid, sram_data_out);
		#(arbiter_cycle);
		//W0
		$display("sram_valid: %d sram_addr: 0x%h, sram_data_in: 0x%h, sram_write_mask: 0x%h", sram_addr_valid, sram_addr, sram_data_in, sram_write_mask);
		$display("sram_data_out_valid: %d, sram_data_out: 0x%h", sram_data_out_valid, sram_data_out);
		#(arbiter_cycle);
		//W1
		$display("sram_valid: %d sram_addr: 0x%h, sram_data_in: 0x%h, sram_write_mask: 0x%h", sram_addr_valid, sram_addr, sram_data_in, sram_write_mask);
		$display("sram_data_out_valid: %d, sram_data_out: 0x%h", sram_data_out_valid, sram_data_out);
		#(arbiter_cycle);
		//R0
		$display("sram_valid: %d sram_addr: 0x%h, sram_data_in: 0x%h, sram_write_mask: 0x%h", sram_addr_valid, sram_addr, sram_data_in, sram_write_mask);
		$display("sram_data_out_valid: %d, sram_data_out: 0x%h", sram_data_out_valid, sram_data_out);
		#(arbiter_cycle);
		//R1
		$display("sram_valid: %d sram_addr: 0x%h, sram_data_in: 0x%h, sram_write_mask: 0x%h", sram_addr_valid, sram_addr, sram_data_in, sram_write_mask);
		$display("sram_data_out_valid: %d, sram_data_out: 0x%h", sram_data_out_valid, sram_data_out);
		#(arbiter_cycle);
		//W0
		$display("sram_valid: %d sram_addr: 0x%h, sram_data_in: 0x%h, sram_write_mask: 0x%h", sram_addr_valid, sram_addr, sram_data_in, sram_write_mask);
		$display("sram_data_out_valid: %d, sram_data_out: 0x%h", sram_data_out_valid, sram_data_out);
		#(arbiter_cycle);
		//W1
		sram_data_out = 32'h00000001;
		sram_data_out_valid = 1;
		$display("sram_valid: %d sram_addr: 0x%h, sram_data_in: 0x%h, sram_write_mask: 0x%h", sram_addr_valid, sram_addr, sram_data_in, sram_write_mask);
		$display("sram_data_out_valid: %d, sram_data_out: 0x%h", sram_data_out_valid, sram_data_out);
		#(arbiter_cycle);
		//R0
		sram_data_out = 32'h00000002;
		sram_data_out_valid = 1;
		$display("sram_valid: %d sram_addr: 0x%h, sram_data_in: 0x%h, sram_write_mask: 0x%h", sram_addr_valid, sram_addr, sram_data_in, sram_write_mask);
		$display("sram_data_out_valid: %d, sram_data_out: 0x%h", sram_data_out_valid, sram_data_out);
		#(arbiter_cycle);
		//R1
		sram_data_out = 32'd0;
		sram_data_out_valid = 0;
		$display("sram_valid: %d sram_addr: 0x%h, sram_data_in: 0x%h, sram_write_mask: 0x%h", sram_addr_valid, sram_addr, sram_data_in, sram_write_mask);
		$display("sram_data_out_valid: %d, sram_data_out: 0x%h", sram_data_out_valid, sram_data_out);
		#(arbiter_cycle);
		//IDLE
		sram_data_out = 32'h00000003;
		sram_data_out_valid = 1;
		$display("sram_valid: %d sram_addr: 0x%h, sram_data_in: 0x%h, sram_write_mask: 0x%h", sram_addr_valid, sram_addr, sram_data_in, sram_write_mask);
		$display("sram_data_out_valid: %d, sram_data_out: 0x%h", sram_data_out_valid, sram_data_out);
		#(arbiter_cycle);
		//IDLE
		sram_data_out = 32'h00000004;
		sram_data_out_valid = 1;
		$display("sram_valid: %d sram_addr: 0x%h, sram_data_in: 0x%h, sram_write_mask: 0x%h", sram_addr_valid, sram_addr, sram_data_in, sram_write_mask);
		$display("sram_data_out_valid: %d, sram_data_out: 0x%h", sram_data_out_valid, sram_data_out);
		#(arbiter_cycle);
		//IDLE
		sram_data_out = 32'd0;
		sram_data_out_valid = 0;
		$display("sram_valid: %d sram_addr: 0x%h, sram_data_in: 0x%h, sram_write_mask: 0x%h", sram_addr_valid, sram_addr, sram_data_in, sram_write_mask);
		$display("sram_data_out_valid: %d, sram_data_out: 0x%h", sram_data_out_valid, sram_data_out);
		#(arbiter_cycle);
		$display("sram_valid: %d sram_addr: 0x%h, sram_data_in: 0x%h, sram_write_mask: 0x%h", sram_addr_valid, sram_addr, sram_data_in, sram_write_mask);
		$display("sram_data_out_valid: %d, sram_data_out: 0x%h", sram_data_out_valid, sram_data_out);
		#(arbiter_cycle);
		$display("sram_valid: %d sram_addr: 0x%h, sram_data_in: 0x%h, sram_write_mask: 0x%h", sram_addr_valid, sram_addr, sram_data_in, sram_write_mask);
		$display("sram_data_out_valid: %d, sram_data_out: 0x%h", sram_data_out_valid, sram_data_out);
		#(arbiter_cycle);
		$display("sram_valid: %d sram_addr: 0x%h, sram_data_in: 0x%h, sram_write_mask: 0x%h", sram_addr_valid, sram_addr, sram_data_in, sram_write_mask);
		$display("sram_data_out_valid: %d, sram_data_out: 0x%h", sram_data_out_valid, sram_data_out);
		#(arbiter_cycle);
		$display("sram_valid: %d sram_addr: 0x%h, sram_data_in: 0x%h, sram_write_mask: 0x%h", sram_addr_valid, sram_addr, sram_data_in, sram_write_mask);
		$display("sram_data_out_valid: %d, sram_data_out: 0x%h", sram_data_out_valid, sram_data_out);
		#(arbiter_cycle);
		$display("sram_valid: %d sram_addr: 0x%h, sram_data_in: 0x%h, sram_write_mask: 0x%h", sram_addr_valid, sram_addr, sram_data_in, sram_write_mask);
		$display("sram_data_out_valid: %d, sram_data_out: 0x%h", sram_data_out_valid, sram_data_out);
		#(arbiter_cycle);
		$display("sram_valid: %d sram_addr: 0x%h, sram_data_in: 0x%h, sram_write_mask: 0x%h", sram_addr_valid, sram_addr, sram_data_in, sram_write_mask);
		$display("sram_data_out_valid: %d, sram_data_out: 0x%h", sram_data_out_valid, sram_data_out);
		#(arbiter_cycle);
		$display("sram_valid: %d sram_addr: 0x%h, sram_data_in: 0x%h, sram_write_mask: 0x%h", sram_addr_valid, sram_addr, sram_data_in, sram_write_mask);
		$display("sram_data_out_valid: %d, sram_data_out: 0x%h", sram_data_out_valid, sram_data_out);
		#(arbiter_cycle);
		$display("sram_valid: %d sram_addr: 0x%h, sram_data_in: 0x%h, sram_write_mask: 0x%h", sram_addr_valid, sram_addr, sram_data_in, sram_write_mask);
		$display("sram_data_out_valid: %d, sram_data_out: 0x%h", sram_data_out_valid, sram_data_out);
		#(4*arbiter_cycle);
		if (r0_dout != 32'h1 || r1_dout != 32'h2 || r0_dout_valid != 1'b1 || r1_dout_valid != 1'b1) begin
			$display("%c[1;31m",27);
			$display("TEST FAILED, r0_valid = %d, should be 1.. r1_valid = %d, should be 1.. r0_dout = 0x%h, should be 1 r1_dout = 0x%h, should be 2", r0_dout_valid, r1_dout_valid, r0_dout, r1_dout);
			$display("%c[0m",27);
		end
		else begin
			$display("SUCCESS! Output data port displays valid on both R0 data port and R1 data port with correct data");
		end
		r0_dout_ready = 1;
		r1_dout_ready = 1;
		#(port_cycle);
		if (r0_dout != 32'h4 || r1_dout != 32'h3 || r0_dout_valid != 1'b1 || r1_dout_valid != 1'b1) begin
			$display("%c[1;31m",27);
			$display("TEST FAILED, r0_valid = %d, should be 1.. r1_valid = %d, should be 1.. r0_dout = 0x%h, should be 3 r1_dout = 0x%h, should be 4", r0_dout_valid, r1_dout_valid, r0_dout, r1_dout);
			$display("%c[0m",27);
		end
		else begin
			$display("SUCCESS! Output data port displays valid on both R0 data port and R1 data port with correct data");
		end
		#(port_cycle);
		if (r0_dout_valid != 1'b0 || r1_dout_valid != 1'b0) begin
			$display("%c[1;31m",27);
			$display("TEST FAILED, r0_valid = %d, should be 0.. r1_valid = %d, should be 0..", r0_dout_valid, r1_dout_valid);
			$display("%c[0m",27);
		end
		else begin
			$display("SUCCESS! Output data port displays invalid data since now empty.");
		end
		r0_dout_ready = 0;
		r1_dout_ready = 0;
		#(port_cycle);
		if (r0_dout_valid != 1'b0 || r1_dout_valid != 1'b0) begin
			$display("%c[1;31m",27);
			$display("TEST FAILED, r0_valid = %d, should be 0.. r1_valid = %d, should be 0..", r0_dout_valid, r1_dout_valid);
			$display("%c[0m",27);
		end
		else begin
			$display("SUCCESS! Output data port displays invalid data since now empty.");
		end
		#(port_cycle);
		if (r0_dout_valid != 1'b0 || r1_dout_valid != 1'b0) begin
			$display("%c[1;31m",27);
			$display("TEST FAILED, r0_valid = %d, should be 0.. r1_valid = %d, should be 0..", r0_dout_valid, r1_dout_valid);
			$display("%c[0m",27);
		end
		else begin
			$display("SUCCESS! Output data port displays invalid data since now empty.");
		end
		
		

		$finish();

	end
endmodule