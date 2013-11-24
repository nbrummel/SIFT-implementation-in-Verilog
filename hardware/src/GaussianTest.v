//  Module: GaussianTest
//  Desc:   Test bench for the gaussian wrapper unit
//  Feel free to edit this testbench to add additional functionality
//  
// If #1 is in the initial block of your testbench, time advances by
// 1ns rather than 1ps
`timescale 1ns / 1ps

module GaussianTest();

	parameter Halfcycle = 100; //half period is 100ns
	localparam Cycle = 2*Halfcycle;

	reg c1;
	reg c2;
	reg Clock;
	reg Reset;

	// Clock Signal generation:
	initial begin
		Clock = 0;
		Reset = 1;
		#( Cycle );
		Reset = 0;
	end
	always #(Halfcycle) Clock = ~Clock;

	wire [7:0] dout;
	wire valid_out, rd_en_down;
	reg [7:0] din;

	//This is where the module being tested are instantiated. 
	GaussianWrapper gwut(
		.rst(Reset),
		.clk(Clock),
		.valid(out),
		.din(din),
		.rd_en_down(rd_en_down),
		.valid_out(valid_out),
		.dout(dout),
		.empty(),
		.rd_en_up(1'b1));

	// Task for checking output
	task GaussianCheck;

		input [7:0] TestDin, TestDout;

		begin
			// Initialize test case signals here
			// Wire DUT signals to task input
			assign din = TestDin;

			if ({dout} != {TestDout}) begin
				$display("%c[1;31m",27);
				$display("FAIL:Test for TestDin 0x%h, TestDout 0x%h",
				TestDin, TestDout);
				$display("\tExpected TestDout: 0x%h\n\tResulting Output: 0x%h ",
				TestDout,dout);
				$display("%c[0m",27);
			end
			else begin
				$display("%c[1;31m",27);
				$display("PASSED:Test for TestDin 0x%h, TestDout 0x%h",
				TestDin, TestDout);
				$display("%c[0m",27);
			end
		end	
	endtask

	integer i;
	
	reg [8:0] pureImg [0:480002];
	reg [8:0] gaussImg [0:48002];

	initial $readmemh("deadmau5-grayscale_gauss.hex", gaussImg);
	initial $readmemh("deadmau5-grayscale.hex", pureImg);
		
	// Testing logic:
	initial begin 
		$display("%c[1;34m",27);	
		$display("**********************************************************************");
		$display("************************ TEST CASES BEGIN ****************************");
		$display("**********************************************************************\n\n\n");
		$display("%c[0m",27);
		
		Reset = 1;
		#(Cycle);
		Reset = 0;
		#(Cycle);  	

		for(i = 2; i < 480002; i = i + 1) begin
			//GaussianCheck(pureImg[i],gaussImg[i]);
			$display(pureImg[i] + "\t pure : gauss \t" + gaussImg[i] + "\n");
			$display("\nThis is for pixel: " + i + "\n");
			//#(Cycle*802);
		end	

		$display("%c[1;34m",27);	
		$display("\n\n\n**********************************************************************");
		$display("************************ TEST CASES END ****************************");
		$display("**********************************************************************");
		$display("%c[0m",27);
		$finish();
	end
endmodule
