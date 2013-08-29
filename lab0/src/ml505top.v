// UC Berkeley CS150
// Lab 0, Spring 2013

module ml505top (
	input  [4:0] GPIO_COMPSW,
	input  CLK_33MHZ_FPGA,
    input  [7:0] GPIO_DIP,
    output [7:0] GPIO_LED
);

    // AND gate example (LED 0 shows (GPIO 1)*(GPIO 2)):
    and (GPIO_LED[0], GPIO_DIP[0], GPIO_DIP[1]);



    /* This shows an example of module instantiation (you will need to
    *  implement Mux2_1 for this to function). If you have correctly 
    *  implemented Mux2_1, you should be able to use switch 5 to 
    *  select whether the value of switch 3 or 4 is displayed on LED 1. */
    Mux2_1 gpio_mux(
        .A(GPIO_DIP[2]),
        .B(GPIO_DIP[3]),
        .SEL(GPIO_DIP[4]),
        .OUT(GPIO_LED[1]));



    /* Next, implement a full adder in FA.v. Then, instantiate the FA module
    *  below such that the inputs to the adder are GPIO DIP switches 6-8 
    *  (recall the number is off by one), the sum is displayed on LED 2, and the 
    *  carry is displayed on LED 3. Then delete the specified line once your done */

   /**********YOUR CODE HERE************/
   
   /**********END CODE**************/

   assign GPIO_LED [3:2] = 2'b0;  //delete this once you instantiate your full adder
	
	/* Now for the adder instantiation and testing
	*  The Adder module is already instantiated for you.
	*  A working solution will light up LED 5.
	 * A failing solution will light up LEDs 6-8
	*/
	
	parameter Width   = 8;
	localparam CWidth = Width*2;
	 
	wire                Clock;
	wire                Reset;
	reg [CWidth-1:0]    Count;
	wire [Width-1:0]    CUTResult;
	wire [Width-1:0]    ExpectedResult;
	wire                CUTCout;
	wire                ExpectedCout;	
	
	//--------------------------------------------------------------------------
  // Clock Buffer
  //   In order to get a clean, glitch free clock signal all over the FPGA,
  //   we use this special clock buffer module.  It does not change the
  //   signal functionally, it only affects timing.
  //--------------------------------------------------------------------------
  BUFG ClockBuf(
    .I(CLK_33MHZ_FPGA), 
    .O(Clock));

  assign Reset = GPIO_COMPSW[4] | GPIO_COMPSW[3] |
    GPIO_COMPSW[2] | GPIO_COMPSW[1] | GPIO_COMPSW[0];
 
  // Circuit Under Test
  Adder #(.Width(Width)) CUT (
    .A(Count[CWidth-1:Width]),
    .B(Count[Width-1:0]),
    .Result(CUTResult),
    .Cout(CUTCout)
    );
  
  BehavioralAdder #(.Width(Width)) Solution (
    .A(Count[CWidth-1:Width]),
    .B(Count[Width-1:0]),
    .Result(ExpectedResult),
    .Cout(ExpectedCout)
    );

  always @(posedge Clock) begin
    if(Reset) Count <= {CWidth{1'b0}};
    else if ((Count != {CWidth{1'b1}}) && GPIO_LED[4]) Count <= Count + 1'b1;
  end

   //Only GPIO_LED[4] will light up if your Adder.v works correctly
  assign GPIO_LED[4] = CUTResult == ExpectedResult && CUTCout == ExpectedCout;

  //GPIO LEDs 5 through 7 will light up if you Adder is wrong
  assign GPIO_LED[7:5] = {~GPIO_LED[4], ~GPIO_LED[4], ~GPIO_LED[4]};  
endmodule
