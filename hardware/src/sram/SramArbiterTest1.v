`timescale 1ns / 1ps

module SramArbiterTest1();

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
  		#(arbiter_cycle);
  		#(arbiter_cycle);
  		#(arbiter_cycle);
  		reset = 0;

		r0_din_valid = 0;
		r1_din_valid = 0;

		w0_din = {4'b1111, 18'd0, 32'hFFFFFFFF};
		w0_din_valid = 1;
		w1_din = {4'b1111, 18'd0, 32'hFEFEFEFE};
		w1_din_valid = 1;
		r0_din = {32'hFFFFFFFF};
		r0_din_valid = 1;
		r1_din = {32'hFEFEFEFE};
		r1_din_valid = 1;
		#(7*arbiter_cycle); //FIFO STARTUP DELAY
		#(port_cycle); //ONE FULL SET LOADED INTO FIFO
		#(port_cycle); //SECOND FULL SET LOADED INTO FIFO
		r0_din_valid = 0;
		r1_din_valid = 0;
		#(arbiter_cycle); //LOADING JUST w0 AND w1
		w0_din_valid = 0;
		w1_din_valid = 0;
		#(4*arbiter_cycle);//FIFO WRITE TO READ DELAY
		if (currentState != 3'h0) begin
			$display("%c[1;31m",27);
			$display("TEST FAILED, Current State should be 0x0 but is 0x%h", currentState);
			$display("%c[0m",27);
		end
		else begin
			$display("TEST PASSED, Current State is 0x%h", currentState);
		end //0
		#(arbiter_cycle);
		if (currentState != 3'h1) begin
			$display("%c[1;31m",27);
			$display("TEST FAILED, Current State should be 0x1 but is 0x%h", currentState);
			$display("%c[0m",27);
		end
		else begin
			$display("TEST PASSED, Current State is 0x%h", currentState);
		end //1
		#(arbiter_cycle);
		if (currentState != 3'h2) begin
			$display("%c[1;31m",27);
			$display("TEST FAILED, Current State should be 0x2 but is 0x%h", currentState);
			$display("%c[0m",27);
		end
		else begin
			$display("TEST PASSED, Current State is 0x%h", currentState);
		end  //2
		#(arbiter_cycle);
		if (currentState != 3'h3) begin
			$display("%c[1;31m",27);
			$display("TEST FAILED, Current State should be 0x3 but is 0x%h", currentState);
			$display("%c[0m",27);
		end
		else begin
			$display("TEST PASSED, Current State is 0x%h", currentState);
		end  //3
		#(arbiter_cycle);
		if (currentState != 3'h4) begin
			$display("%c[1;31m",27);
			$display("TEST FAILED, Current State should be 0x4 but is 0x%h", currentState);
			$display("%c[0m",27);
		end
		else begin
			$display("TEST PASSED, Current State is 0x%h", currentState);
		end  //4
		#(arbiter_cycle);
		if (currentState != 3'h1) begin
			$display("%c[1;31m",27);
			$display("TEST FAILED, Current State should be 0x1 but is 0x%h", currentState);
			$display("%c[0m",27);
		end
		else begin
			$display("TEST PASSED, Current State is 0x%h", currentState);
		end  //1
		#(arbiter_cycle);
		if (currentState != 3'h2) begin
			$display("%c[1;31m",27);
			$display("TEST FAILED, Current State should be 0x2 but is 0x%h", currentState);
			$display("%c[0m",27);
		end
		else begin
			$display("TEST PASSED, Current State is 0x%h", currentState);
		end  //2
		#(arbiter_cycle);
		if (currentState != 3'h3) begin
			$display("%c[1;31m",27);
			$display("TEST FAILED, Current State should be 0x3 but is 0x%h", currentState);
			$display("%c[0m",27);
		end
		else begin
			$display("TEST PASSED, Current State is 0x%h", currentState);
		end  //3
		#(arbiter_cycle);
		if (currentState != 3'h4) begin
			$display("%c[1;31m",27);
			$display("TEST FAILED, Current State should be 0x0 but is 0x%h", currentState);
			$display("%c[0m",27);
		end
		else begin
			$display("TEST PASSED, Current State is 0x%h", currentState);
		end  //4
		#(arbiter_cycle);
		if (currentState != 3'h1) begin
			$display("%c[1;31m",27);
			$display("TEST FAILED, Current State should be 0x0 but is 0x%h", currentState);
			$display("%c[0m",27);
		end
		else begin
			$display("TEST PASSED, Current State is 0x%h", currentState);
		end  //1
		#(arbiter_cycle);
		if (currentState != 3'h2) begin
			$display("%c[1;31m",27);
			$display("TEST FAILED, Current State should be 0x0 but is 0x%h", currentState);
			$display("%c[0m",27);
		end
		else begin
			$display("TEST PASSED, Current State is 0x%h", currentState);
		end  //2
		#(2*arbiter_cycle);
		if (currentState != 3'h0) begin
			$display("%c[1;31m",27);
			$display("TEST FAILED, Current State should be 0x0 but is 0x%h", currentState);
			$display("%c[0m",27);
		end
		else begin
			$display("TEST PASSED, Current State is 0x%h", currentState);
		end  //0
		#(arbiter_cycle);
		if (currentState != 3'h0) begin
			$display("%c[1;31m",27);
			$display("TEST FAILED, Current State should be 0x0 but is 0x%h", currentState);
			$display("%c[0m",27);
		end
		else begin
			$display("TEST PASSED, Current State is 0x%h", currentState);
		end  //0
		#(arbiter_cycle);
		if (currentState != 3'h0) begin
			$display("%c[1;31m",27);
			$display("TEST FAILED, Current State should be 0x0 but is 0x%h", currentState);
			$display("%c[0m",27);
		end
		else begin
			$display("TEST PASSED, Current State is 0x%h", currentState);
		end  //0
		#(arbiter_cycle);
		if (currentState != 3'h0) begin
			$display("%c[1;31m",27);
			$display("TEST FAILED, Current State should be 0x0 but is 0x%h", currentState);
			$display("%c[0m",27);
		end
		else begin
			$display("TEST PASSED, Current State is 0x%h", currentState);
		end  //0
		#(arbiter_cycle);
		if (currentState != 3'h0) begin
			$display("%c[1;31m",27);
			$display("TEST FAILED, Current State should be 0x0 but is 0x%h", currentState);
			$display("%c[0m",27);
		end
		else begin
			$display("TEST PASSED, Current State is 0x%h", currentState);
		end  //0
		#(arbiter_cycle);
		if (currentState != 3'h0) begin
			$display("%c[1;31m",27);
			$display("TEST FAILED, Current State should be 0x0 but is 0x%h", currentState);
			$display("%c[0m",27);
		end
		else begin
			$display("TEST PASSED, Current State is 0x%h", currentState);
		end  //0



	end
endmodule