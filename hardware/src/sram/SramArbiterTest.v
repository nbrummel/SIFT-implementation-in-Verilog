`timescale 1ns / 1ps

module SramArbiterTest();

        parameter component_hl = 100,
                    sram_hl = 50;
        localparam  CCycle = 2*component_hl,
        			SCycle = 2*sram_hl;

        reg 	component_clock,
                sram_clock,
                reset;

        initial begin
                component_clock = 0;
                sram_clock = 0;
                Reset = 1;
                #(CCycle);
                #(SCycle);
                reset = 0;
        end
        
        always #(component_hl) component_clock = ~component_clock;
        always #(sram_hl) sram_clock = ~sram_clock;

	    wire 	w0_din_ready,
	         	w1_din_ready,
	         	r0_din_ready,
	         	r1_din_ready,
	         	sram_ready,
				w0_din_valid,
	        	w1_din_valid,
	        	r0_din_valid,
	        	r1_din_valid,
	        	sram_addr_valid;
        
        wire 	r1_dout_valid,
        		r0_dout_valid,
        		r0_dout_ready,
         		r1_dout_ready,
        		sram_data_out_valid;

        wire [53:0]	w0_din,
					w1_din;

		wire [17:0]	sram_addr,
					r0_din,
					r1_din;

		wire [31:0]	sram_data_in;

		wire [31:0]	r0_dout,
					r1_dout,
					sram_data_out;

		wire [3:0]	sram_write_mask;

        SramArbiter(
                .reset(reset),

		      	// W0: Image Buffer Writer
		        .w0_clock(component_clock),
		        .w0_din_ready(w0_din_ready),
		        .w0_din_valid(w0_din_valid),
		        .w0_din(w0_din),// {mask,addr,data}

		      	// W1: Overlay Writer
		        .w1_clock(component_clock),
		        .w1_din_ready(w1_din_ready),
		        .w1_din_valid(w1_din_valid),
		        .w1_din(w1_din),// {mask,addr,data}

		      	// R0: Image Buffer Reader
		        .r0_clock(component_clock),
		        .r0_din_ready(r0_din_ready),
		        .r0_din_valid(r0_din_valid),
		        .r0_din(r0_din), // addr
		        .r0_dout_ready(r0_dout_ready),
		        .r0_dout_valid(r0_dout_valid),
		        .r0_dout(r0_dout), // data

		      	// R1
		        .r1_clock(component_clock),
		        .r1_din_ready(r1_din_ready),
		        .r1_din_valid(r1_din_valid),
		        .r1_din(r1_din), // addr
		        .r1_dout_ready(r1_dout_ready),
		        .r1_dout_valid(r1_dout_valid),
		        .r1_dout(r1_dout), // data
				
				// SRAM Interface
                .sram_clock(sram_clock),
		        .sram_addr_valid(sram_addr_valid),
		        .sram_ready(sram_ready),
		        .sram_addr(sram_addr),
		        .sram_data_in(sram_data_in),
		        .sram_write_mask(sram_write_mask),
		        .sram_data_out(sram_data_out),
		        .sram_data_out_valid(sram_data_out_valid));
              
        task CompSeqTest;

        	// W0
			input		  w0_din_validTest;
			input [53:0]  w0_dinTest;// {maskTest,addrTest,data}

			// W1
			input         w1_din_validTest;
			input [53:0]  w1_dinTest;// {maskTest,addrTest,data}


			// R0
			input         r0_din_validTest;
			input  [17:0] r0_dinTest; // addr
			input         r0_dout_readyTest;


			// R1
			input         r1_din_validTest;
			input  [17:0] r1_dinTest; // addr
			input         r1_dout_readyTest;


			//sram
			input         sram_readyTest;
			input  [31:0] sram_data_outTest;
			input         sram_data_out_validTest;


	        begin
			  	// Initialize test case signals here

			  	// Wire DUT signals to task input
				assign	w0_din_valid = w0_din_validTest;
				assign 	w0_din = w0_dinTest;// {maskTest,addrTest,data}

				// W1
				assign w1_din_valid	= w1_din_validTest;
				assign w1_din = w1_dinTest;// {maskTest,addrTest,data}


				// R0
				assign r0_din_valid	= r0_din_validTest;
				assign r0_din = r0_dinTest; // addr
				assign r0_dout_ready = r0_dout_readyTest;


				// R1
				assign r1_din_valid	= r1_din_validTest;
				assign r1_din = r1_dinTest; // addr
				assign r1_dout_ready = r1_dout_readyTest;


				//sram
				assign sram_ready = sram_readyTest;
				assign sram_data_out = sram_data_outTest;
				assign sram_data_out_valid = sram_data_out_validTest;
			  	
			  	$display("%c[1;34m",27);	
      			$display("************************** COMPLETE SEQUENCE TEST ****************************\n");
		  		$display("%c[0m",27);
			  	integer cst;
			  	cst = 0;
			  	while (cst < 2) begin
			  		#(SCycle)
				  	if (sram_data_in != w0_dinTest) begin
				  		$display("%c[1;31m",27);
					  	$display("FAIL: Sweep 0x%d for w0_din 0x%h",
							cst, w0_dinTest;
					  	$display("\tExpected w0_dinTest: 0x%h,\n\tResulting sram_data_in: 0x%h ",
							w0_dinTest, sram_data_in);
					  	$display("%c[0m",27);
					end else begin 
						$display("%c[1;31m",27);
					  	$display("PASSED: Sweep 0x%d for w0_din 0x%h",
							cst, w0_dinTest;
					  	$display("%c[0m",27);
					end
					#(SCycle)
					if (sram_data_in != w1_dinTest) begin
				  		$display("%c[1;31m",27);
					  	$display("FAIL: Sweep 0x%d for w1_din 0x%h",
							cst, w1_dinTest;
					  	$display("\tExpected w1_dinTest: 0x%h,\n\tResulting sram_data_in: 0x%h ",
							w1_dinTest, sram_data_in);
					  	$display("%c[0m",27);
					end else begin 
						$display("%c[1;31m",27);
					  	$display("PASSED: Sweep 0x%d for w1_din 0x%h",
							cst, w1_dinTest;
					  	$display("%c[0m",27);
					end
					#(SCycle)
					if (sram_data_outTest != r0_dout) begin
				  		$display("%c[1;31m",27);
					  	$display("FAIL: Sweep 0x%d for r0_dout 0x%h",
							cst, sram_data_outTest;
					  	$display("\tExpected sram_data_outTest: 0x%h,\n\tResulting r0_dout: 0x%h ",
							sram_data_outTest, r0_dout);
					  	$display("%c[0m",27);
					end else begin 
						$display("%c[1;31m",27);
					  	$display("PASSED: Sweep 0x%d for r0_dout 0x%h",
							cst, sram_data_outTest;
					  	$display("%c[0m",27);
					end
					#(SCycle)
					if (sram_data_outTest != r1_dout) begin
				  		$display("%c[1;31m",27);
					  	$display("FAIL: Sweep 0x%d for r1_dout 0x%h",
							cst, sram_data_outTest;
					  	$display("\tExpected sram_data_outTest: 0x%h,\n\tResulting r1_dout: 0x%h ",
							sram_data_outTest, r1_dout);
					  	$display("%c[0m",27);
					end else begin 
						$display("%c[1;31m",27);
					  	$display("PASSED: Sweep 0x%d for r1_dout 0x%h",
							cst, sram_data_outTest;
					  	$display("%c[0m",27);
					end
					cst = cst + 1;
				end
			end	
	  	endtask
	  	/*
	  	 *	Not sure how to do this one.  I think all of the other test will work.  
	  	 * 	If you have questions please call.  I will be back around 4:30 or 5:00
	  	 */
	  	task StopReadTest;

        	// W0
			input		  w0_din_validTest;
			input [53:0]  w0_dinTest;// {maskTest,addrTest,data}

			// W1
			input         w1_din_validTest;
			input [53:0]  w1_dinTest;// {maskTest,addrTest,data}


			// R0
			input         r0_din_validTest;
			input  [17:0] r0_dinTest; // addr
			input         r0_dout_readyTest;


			// R1
			input         r1_din_validTest;
			input  [17:0] r1_dinTest; // addr
			input         r1_dout_readyTest;


			//sram
			input         sram_readyTest;
			input  [31:0] sram_data_outTest;
			input         sram_data_out_validTest;


	        begin
			  	// Initialize test case signals here

			  	// Wire DUT signals to task input
				assign	w0_din_valid = w0_din_validTest;
				assign 	w0_din = w0_dinTest;// {maskTest,addrTest,data}

				// W1
				assign w1_din_valid	= w1_din_validTest;
				assign w1_din = w1_dinTest;// {maskTest,addrTest,data}


				// R0
				assign r0_din_valid	= r0_din_validTest;
				assign r0_din = r0_dinTest; // addr
				assign r0_dout_ready = r0_dout_readyTest;


				// R1
				assign r1_din_valid	= r1_din_validTest;
				assign r1_din = r1_dinTest; // addr
				assign r1_dout_ready = r1_dout_readyTest;


				//sram
				assign sram_ready = sram_readyTest;
				assign sram_data_out = sram_data_outTest;
				assign sram_data_out_valid = sram_data_out_validTest;

			  	$display("%c[1;34m",27);	
      			$display("************************** STOP READING TEST ****************************\n");
		  		$display("%c[0m",27);

			  	#(SCycle)
			  	
			  	if (sram_data_in != w0_dinTest) begin
			  		$display("%c[1;31m",27);
				  	$display("FAIL: Sweep 0x%d for w0_din 0x%h",
						cst, w0_dinTest;
				  	$display("\tExpected w0_dinTest: 0x%h,\n\tResulting sram_data_in: 0x%h ",
						w0_dinTest, sram_data_in);
				  	$display("%c[0m",27);
				end else begin 
					$display("%c[1;31m",27);
				  	$display("PASSED: Sweep 0x%d for w0_din 0x%h",
						cst, w0_dinTest;
				  	$display("\tExpected w0_dinTest: 0x%h,\n\tResulting sram_data_in: 0x%h ",
						w0_dinTest, sram_data_in);
				  	$display("%c[0m",27);
				end
				#(SCycle)
				if (sram_data_in != w1_dinTest) begin
			  		$display("%c[1;31m",27);
				  	$display("FAIL: Sweep 0x%d for w1_din 0x%h",
						cst, w1_dinTest;
				  	$display("\tExpected w1_dinTest: 0x%h,\n\tResulting sram_data_in: 0x%h ",
						w1_dinTest, sram_data_in);
				  	$display("%c[0m",27);
				end else begin 
					$display("%c[1;31m",27);
				  	$display("PASSED: Sweep 0x%d for w1_din 0x%h",
						cst, w1_dinTest;
				  	$display("\tExpected w1_dinTest: 0x%h,\n\tResulting sram_data_in: 0x%h ",
						w1_dinTest, sram_data_in);
				  	$display("%c[0m",27);
				end
				#(SCycle)
				if (sram_data_outTest != r0_dout) begin
			  		$display("%c[1;31m",27);
				  	$display("FAIL: Sweep 0x%d for r0_dout 0x%h",
						cst, sram_data_outTest;
				  	$display("\tExpected sram_data_outTest: 0x%h,\n\tResulting r0_dout: 0x%h ",
						sram_data_outTest, r0_dout);
				  	$display("%c[0m",27);
				end else begin 
					$display("%c[1;31m",27);
				  	$display("PASSED: Sweep 0x%d for r0_dout 0x%h",
						cst, sram_data_outTest;
				  	$display("\tExpected sram_data_outTest: 0x%h,\n\tResulting r0_dout: 0x%h ",
						sram_data_outTest, r0_dout);
				  	$display("%c[0m",27);
				end
				#(SCycle)
				if (sram_data_outTest != r1_dout) begin
			  		$display("%c[1;31m",27);
				  	$display("FAIL: Sweep 0x%d for r1_dout 0x%h",
						cst, sram_data_outTest;
				  	$display("\tExpected sram_data_outTest: 0x%h,\n\tResulting r1_dout: 0x%h ",
						sram_data_outTest, r1_dout);
				  	$display("%c[0m",27);
				end else begin 
					$display("%c[1;31m",27);
				  	$display("PASSED: Sweep 0x%d for r1_dout 0x%h",
						cst, sram_data_outTest;
				  	$display("\tExpected sram_data_outTest: 0x%h,\n\tResulting r1_dout: 0x%h ",
						sram_data_outTest, r1_dout);
				  	$display("%c[0m",27);
				end
				
			end
	  	endtask

	  	task StopReqTest;

        	// W0
			input		  w0_din_validTest;
			input [53:0]  w0_dinTest;// {maskTest,addrTest,data}

			// W1
			input         w1_din_validTest;
			input [53:0]  w1_dinTest;// {maskTest,addrTest,data}


			// R0
			input         r0_din_validTest;
			input  [17:0] r0_dinTest; // addr
			input         r0_dout_readyTest;


			// R1
			input         r1_din_validTest;
			input  [17:0] r1_dinTest; // addr
			input         r1_dout_readyTest;


			//sram
			input         sram_readyTest;
			input  [31:0] sram_data_outTest;
			input         sram_data_out_validTest;


	        begin
			  	// Initialize test case signals here

			  	// Wire DUT signals to task input
				assign	w0_din_valid = w0_din_validTest;
				assign 	w0_din = w0_dinTest;// {maskTest,addrTest,data}

				// W1
				assign w1_din_valid	= w0_din_validTest;
				assign w1_din = w1_dinTest;// {maskTest,addrTest,data}


				// R0
				assign r0_din_valid	= r0_din_validTest;
				assign r0_din = r0_dinTest; // addr
				assign r0_dout_ready = r0_dout_readyTest;


				// R1
				assign r1_din_valid	= 1'b0;
				assign r1_din = r1_dinTest; // addr
				assign r1_dout_ready = r1_dout_readyTest;


				//sram
				assign sram_ready = sram_readyTest;
				assign sram_data_out = sram_data_outTest;
				assign sram_data_out_valid = sram_data_out_validTest;
			  	
			  	$display("%c[1;34m",27);	
      			$display("************************** STOP REQUEST TEST ****************************\n");
		  		$display("%c[0m",27);
			  	integer cst;
			  	cst = 0
			  	while (cst < 2) begin
			  		#(SCycle)
				  	if (sram_data_in != w0_dinTest) begin
				  		if (r1_din_ready == 1'b0) begin
					  		$display("%c[1;31m",27);
						  	$display("FAIL: r1_din_ready 0x%b", 1'b0;
						  	$display("\tExpected r1_din_readyTest: 0x%b,\n\tResulting r1_din_ready: 0x%b ",
								1'b0, r1_din_ready);
						  	$display("%c[0m",27);
						end else begin 
							$display("%c[1;31m",27);
						  	$display("PASSED: r1_din_ready 0x%b", 1'b0;
						  	$display("%c[0m",27);
						end
					end else begin 
						$display("%c[1;31m",27);
					  	$display("PASSED: r1_din_ready via w0_din 0x%b", 1'b0;
					  	$display("%c[0m",27);
					end
					#(SCycle)
					$display("%c[1;31m",27);
				  	$display("w1_din";
				  	$display("%c[0m",27);
					#(SCycle)
					$display("%c[1;31m",27);
				  	$display("r1_din";
				  	$display("%c[0m",27);
					cst = cst + 1;
				end
			end	
	  	endtask

	  	task EmptyTest;

        	// W0
			input [53:0]  w0_dinTest;// {maskTest,addrTest,data}

			// W1
			input [53:0]  w1_dinTest;// {maskTest,addrTest,data}


			// R0
			input  [17:0] r0_dinTest; // addr
			input         r0_dout_readyTest;


			// R1
			input  [17:0] r1_dinTest; // addr
			input         r1_dout_readyTest;


			//sram
			input         sram_readyTest;
			input  [31:0] sram_data_outTest;
			input         sram_data_out_validTest;


	        begin
			  	// Initialize test case signals here

			  	// Wire DUT signals to task input
				assign	w0_din_valid = 1'b0;
				assign 	w0_din = w0_dinTest;// {maskTest,addrTest,data}

				// W1
				assign w1_din_valid	= 1'b0;
				assign w1_din = w1_dinTest;// {maskTest,addrTest,data}


				// R0
				assign r0_din_valid	= 1'b0;
				assign r0_din = r0_dinTest; // addr
				assign r0_dout_ready = r0_dout_readyTest;


				// R1
				assign r1_din_valid	= 1'b0;
				assign r1_din = r1_dinTest; // addr
				assign r1_dout_ready = r1_dout_readyTest;


				//sram
				assign sram_ready = sram_readyTest;
				assign sram_data_out = sram_data_outTest;
				assign sram_data_out_valid = sram_data_out_validTest;
			  	
			  	$display("%c[1;34m",27);	
      			$display("************************** EMPTY TEST ****************************\n");
		  		$display("%c[0m",27);

			  	#(SCycle)
			  	if (w0_din_ready != 1'b0) begin
			  		$display("%c[1;31m",27);
				  	$display("FAIL: w0_din 0x%b", 1'b0;
				  	$display("\tExpected w0_din_readyTest: 0x%b,\n\tResulting w0_din_ready: 0x%b ",
						1'b0, w0_din_ready);
				  	$display("%c[0m",27);
				end else begin 
					$display("%c[1;31m",27);
				  	$display("PASSED: w0_din 0x%b", 1'b0;
				  	$display("%c[0m",27);
				end
				#(SCycle)
				if (w1_din_ready!= 1'b0) begin
			  		$display("%c[1;31m",27);
				  	$display("FAIL: w1_din 0x%b", 1'b0;
				  	$display("\tExpected w1_din_readyTest: 0x%b,\n\tResulting w1_din_ready: 0x%b ",
						1'b0, w1_din_ready);
				  	$display("%c[0m",27);
				end else begin 
					$display("%c[1;31m",27);
				  	$display("PASSED: w1_din 0x%b", 1'b0;
				  	$display("%c[0m",27);
				end
				#(SCycle)
				if (r0_din_ready!= 1'b0) begin
			  		$display("%c[1;31m",27);
				  	$display("FAIL: r0_din 0x%b", 1'b0;
				  	$display("\tExpected r0_din_readyTest: 0x%b,\n\tResulting r0_din_ready: 0x%b ",
						1'b0, r0_din_ready);
				  	$display("%c[0m",27);
				end else begin 
					$display("%c[1;31m",27);
				  	$display("PASSED: r0_din 0x%b", 1'b0;
				  	$display("%c[0m",27);
				end
				#(SCycle)
				if (r1_din_ready!= 1'b0) begin
			  		$display("%c[1;31m",27);
				  	$display("FAIL: r1_din 0x%b", 1'b0;
				  	$display("\tExpected r1_din_readyTest: 0x%b,\n\tResulting r1_din_ready: 0x%b ",
						1'b0, r1_din_ready);
				  	$display("%c[0m",27);
				end else begin 
					$display("%c[1;31m",27);
				  	$display("PASSED: r1_din 0x%b", 1'b0;
				  	$display("%c[0m",27);
				end
			end	
	  	endtask

	  	// Testing logic:
    initial begin 
	  	$display("%c[1;34m",27);	
	  	$display("**********************************************************************");
		$display("************************ TEST CASES BEGIN ****************************");
		$display("**********************************************************************\n\n\n");
	  	$display("%c[0m",27);
				
		CompSeqTest();
		StopReqTest();
		StopReadTest();	
		EmptyTest();	

		$display("%c[1;34m",27);	
	  	$display("\n\n\n**********************************************************************");
		$display("************************ TEST CASES END ****************************");
		$display("**********************************************************************");
	  	$display("%c[0m",27);
	  	$finish();
	end

endmodule
