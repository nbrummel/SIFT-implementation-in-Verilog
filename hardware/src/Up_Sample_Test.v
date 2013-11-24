`timescale 1ns / 1ps

module Up_Sample_Test();

  	parameter Halfcycle = 100; //half period is 100ns
  	localparam Cycle = 2*Halfcycle;

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

  	reg [7:0] testDataIn;
  	wire [7:0] dout;

  	UpSampler ups (
  		.rst(Reset),
  		.clk(Clock),
  		.valid(1'b1),
  		.din(testDataIn),
  		.empty(1'b0),
  		.dout(dout),
  		.valid_out()
  		);

  	task upSampleCheck;

	input [7:0] TestDin, TestDout;

	begin

		assign testDataIn = TestDin; 

	  	if ({dout} != {TestDout}) begin
			$display("%c[1;31m",27);
		  	$display("FAIL:Test TestDin for 0x%h, TestDout 0x%h",
				TestDin, TestDout);
		  	$display("\tExpected TestDout: 0x%h, TestDin: 0x%h\n\tResulting Output: 0x%h",
				TestDout,TestDin,dout);
		  	$display("%c[0m",27);
		end
		else begin
			$display("%c[1;31m",27);
		  	$display("PASSED:Test TestDin for 0x%h, TestDout 0x%h",
				TestDin, TestDout);
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
		
		upSampleCheck(8'hcc,8'haa);	

	$display("%c[1;34m",27);	
  	$display("\n\n\n**********************************************************************");
	$display("************************ TEST CASES END ****************************");
	$display("**********************************************************************");
  	$display("%c[0m",27);	
  	$finish
  	end
endmodule
