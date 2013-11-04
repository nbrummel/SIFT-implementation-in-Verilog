//  Module: PatternGeneratorTest
//  Desc:   Test bench for the pattern generator unit
//  Feel free to edit this testbench to add additional functionality
//  
// If #1 is in the initial block of your testbench, time advances by
// 1ns rather than 1ps
`timescale 1ns / 1ps

module PatternGeneratorTest();

  	parameter Halfcycle = 100; //half period is 100ns
  	localparam Cycle = 2*Halfcycle,
  				WISTERIA = {8'd142, 8'd68, 8'd173},//8e44ad
		   		MIDNIGHTBLUE = {8'd44, 8'd62, 8'd80},//2c3e50
		   		GREENSEA = {8'd22, 8'd160, 8'd133},//16a085
		   		BELIZE = {8'd41, 8'd128, 8'd185},//2980b9
		   		colors1 = {WISTERIA, MIDNIGHTBLUE, GREENSEA, BELIZE},
  			  	TURQUOISE = {8'd26, 8'd188, 8'd156},//1abc9c
		   		CARROT = {8'd230, 8'd126, 8'd34},//e67e22
		   		SUNFLOWER = {8'd241, 8'd196, 8'd15},//f1c40f
		   		EMERALD = {8'd46, 8'd204, 8'd113},//2ecc71
				colors2 = {TURQUOISE, CARROT, SUNFLOWER, EMERALD};

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

  	reg PassTest = 1'b1;
  	reg [7:0] shiftColor2;
    reg [7:0] shiftColor1;
	reg [23:0]	LastReadyVideo;
	reg			VideoReadyIn;
	wire  		VideoValidOut;
	wire [23:0] VideoOut;

 	//This is where the module being tested are instantiated. 
  	PatternGenerator pg(
	 	/* Ready/Valid interface for 24-bit pixel values */
	 	.Clock ( Clock ),
	 	.Reset ( Reset ),
	 	.VideoReady ( 1'b1 ),
	 	//.VideoValid ( VideoValidOut ),
	 	.Video (VideoOut)
		);

  	assign VideoValidOut = 1'b1;
  

  	// Task for checking output
  	task dviOutputCheck;

		input [23:0] TestVideoOut;
		input TestVideoValidOut, TestVideoReady;// TestReset;

		begin
		  	// Initialize test case signals here

		  	// Wire DUT signals to task input
		  	assign VideoReadyIn = TestVideoReady;
		  	//assign Reset = TestReset;
		  	
		  	if ({TestVideoReady}) begin  

		  		if ({TestVideoOut} != {VideoOut}) begin
		  			$display("%c[1;31m",27);
				  	$display("FAIL:Test VideoReady for TestVideoOut 0x%h, VideoReady 0x%b",
						TestVideoOut, TestVideoReady);
				  	$display("\tExpected Video Output: 0x%h, ValidOut: 0x%b\n\tResulting Output: 0x%h, 0x%b,",
						TestVideoOut, TestVideoValidOut, VideoOut, VideoValidOut);
				  	$display("%c[0m",27);
				  	PassTest = 1'b0;
				  	
				end
				else begin
					assign LastReadyVideo = TestVideoOut;
					$display("%c[1;32m",27);
					$display("PASSED: Test VideoReady for TestVideoOut 0x%h, VideoReady 0x%b",
						TestVideoOut, TestVideoReady);
				  	$display("\tExpected Video Output: 0x%h, ValidOut: 0x%b\n\tResulting Output: 0x%h, 0x%b,",
						TestVideoOut, TestVideoValidOut, VideoOut, VideoValidOut);
				  	$display("%c[0m",27);
				  	PassTest = 1'b1;
				  	
				end
			end
			else if (!{TestVideoReady})  begin

				if ({ LastReadyVideo } != { VideoOut }) begin
					$display("%c[1;31m",27);
				  	$display("FAIL: Test VideoReady for TestVideoOut 0x%h, VideoReady 0x%b",
						TestVideoOut, TestVideoReady);
				  	$display("\tExpected Video Output: 0x%h, ValidOut: 0x%b\n\tResulting Output: 0x%h, 0x%b,",
						TestVideoOut, TestVideoValidOut, VideoOut, VideoValidOut);
				  	$display("%c[0m",27);
				  	PassTest = 1'b0;
				  	
				end
				else begin
					$display("%c[1;32m",27);
					$display("PASSED: Test VideoReady for TestVideoOut 0x%h, VideoReady 0x%b",
						TestVideoOut, TestVideoReady);
				  	$display("\tExpected Video Output: 0x%h, ValidOut: 0x%b\n\tResulting Output: 0x%h, 0x%b,",
						TestVideoOut, TestVideoValidOut, VideoOut, VideoValidOut);
				  	$display("%c[0m",27);
				  	PassTest = 1'b1;
				  	
				end	
			end	
			else begin

				$display("%c[1;34m",27);	
      			$display("************************** VALID VIDEO READY TEST ****************************\n");
		  		$display("%c[0m",27);

				if ({VideoValidOut} != {TestVideoValidOut}) begin
					$display("%c[1;31m",27);
				  	$display("FAIL: Test VideoReady for TestVideoOut 0x%h, VideoReady 0x%b",
						TestVideoOut, TestVideoReady);
				  	$display("\tExpected Video Output: 0x%h, ValidOut: 0x%b\n\tResulting Output: 0x%h, 0x%b,",
						TestVideoOut, TestVideoValidOut, VideoOut, VideoValidOut);
				  	$display("%c[0m",27);
				  	PassTest = 1'b0;
				  	
				end
				else begin
					$display("%c[1;32m",27);
					$display("PASSED: Test VideoReady for TestVideoOut 0x%h, VideoReady 0x%b",
						TestVideoOut, TestVideoReady);
				  	$display("\tExpected Video Output: 0x%h, ValidOut: 0x%b\n\tResulting Output: 0x%h, 0x%b,",
						TestVideoOut, TestVideoValidOut, VideoOut, VideoValidOut);
				  	$display("%c[0m",27);
				  	PassTest = 1'b1;
				  	
				end	
			end	
		end	
  	endtask

    integer a;
    integer b;
    integer c;
    integer i;
    integer j;
    
    


  // Testing logic:
    initial begin 
  	$display("%c[1;34m",27);	
  	$display("**********************************************************************");
	$display("************************ TEST CASES BEGIN ****************************");
	$display("**********************************************************************\n\n\n");
  	$display("%c[0m",27);
			
	
	//Test Reset
	//dviOutputCheck( 1'b0, 1'b0, 1'b1, 1'b1 );

	//Test Pattern
	$display("%c[1;34m",27);	
	$display("************************** PATTERN TEST ****************************\n");
	$display("%c[0m",27);

	for (j = 0; j < 72; j = j + 1) begin
		if (j == 0) begin
		for (i = 0; i < 6; i = i + 1) begin
			for( a = 0; a < 100; a = a + 1 ) begin 
				$display("!!!!!!!!!!!!!!!!!!!!!!!!!");
				$display(">>> CHECKING NEW ROW <<<");
				$display("!!!!!!!!!!!!!!!!!!!!!!!!!");
				if(a < 50) begin
					$display("Checking for: 8e44ad and 2c3e50");
					for(b = 0; b < 5; b = b + 1) begin
					#(Cycle);
					dviOutputCheck( WISTERIA, 1'b1, 1'b1);
					#(79*Cycle);
					#(Cycle);
					dviOutputCheck( MIDNIGHTBLUE, 1'b1, 1'b1);
				  	#(79*Cycle);
				  	end
				end
				else begin
					$display("Checking for: 16a085 and 2980b9");
				  	for(b = 0; b < 5; b = b + 1) begin
					#(Cycle);
					dviOutputCheck( GREENSEA, 1'b1, 1'b1);
					#(79*Cycle);
					#(Cycle);
					dviOutputCheck( BELIZE, 1'b1, 1'b1);
				  	#(79*Cycle);
				  	end
				end
			end
		end
		end
		else begin 
		for (i = 0; i < 6; i = i + 1) begin
			for( a = 0; a < 100; a = a + 1 ) begin 
				if(a < 50) begin
					for(b = 0; b < 5; b = b + 1) begin
					#(Cycle);
					#(79*Cycle);
					#(Cycle);
				  	#(79*Cycle);
				  	end
				end
				else begin
				  	for(b = 0; b < 5; b = b + 1) begin
					#(Cycle);
					#(79*Cycle);
					#(Cycle);
				  	#(79*Cycle);
				  	end
				end
			end
		end
		end
	end

	for (j = 0; j < 72; j = j + 1) begin
		if (j == 0) begin
		for (i = 0; i < 6; i = i + 1) begin
			for( a = 0; a < 100; a = a + 1 ) begin 
				$display("!!!!!!!!!!!!!!!!!!!!!!!!!");
				$display(">>> CHECKING NEW PAGE <<<");
				$display("!!!!!!!!!!!!!!!!!!!!!!!!!");
				if(a < 50) begin
					$display("Checking for: 1abc9c and e67e22");
					for(b = 0; b < 5; b = b + 1) begin
					#(Cycle);
					dviOutputCheck( TURQUOISE, 1'b1, 1'b1);
					#(79*Cycle);
					#(Cycle);
					dviOutputCheck( CARROT, 1'b1, 1'b1);
				  	#(79*Cycle);
				  	end
				end
				else begin
					$display("Checking for: f1c40f and 2ecc71");
				  	for(b = 0; b < 5; b = b + 1) begin
					#(Cycle);
					dviOutputCheck( SUNFLOWER, 1'b1, 1'b1);
					#(79*Cycle);
					#(Cycle);
					dviOutputCheck( EMERALD, 1'b1, 1'b1);
				  	#(79*Cycle);
				  	end
				end
			end
		end
		end
		else begin 
		for (i = 0; i < 6; i = i + 1) begin
			for( a = 0; a < 100; a = a + 1 ) begin 
				if(a < 50) begin
					for(b = 0; b < 5; b = b + 1) begin
					#(Cycle);
					#(79*Cycle);
					#(Cycle);
				  	#(79*Cycle);
				  	end
				end
				else begin
				  	for(b = 0; b < 5; b = b + 1) begin
					#(Cycle);
					#(79*Cycle);
					#(Cycle);
				  	#(79*Cycle);
				  	end
				end
			end
		end
		end
	end

	Reset = 1;
	#(Cycle);
	Reset = 0;
	#(Cycle);

	$display("%c[1;34m",27);	
  	$display("\n\n\n**********************************************************************");
	$display("************************ TEST CASES END ****************************");
	$display("**********************************************************************");
  	$display("%c[0m",27);
		  
	if(PassTest) begin
		$display("%c[5;32m",27);
		$display("\n\nALL TESTS PASSED!");
		$display("%c[0m",27);
	end
	else begin
		$display("%c[5;31m",27);
		$display("\n\nSOME TESTS FAILED!");
		$display("%c[0m",27);
	end

	$finish();
  end
endmodule
