module Gassian_Filter #(
	parameter DIV = 0.20,
						K1 = 0.80 * DIV,
						K2 = 1.01 * DIV,
						K3 = 1.27 * DIV,
						K4 = 1.60 * DIV,
						K5 = 2.02 * DIV)
	(
		input clock;
		input [7:0] Data_In;
		output [7:0] Data_Out;
	);

	wire [15:0] mult1;
	wire [15:0] mult2;

	// -- |SHIFT_REGISTER1| --------------------------------------------------
  `define SHIFT_REGISTER1
  
  `ifdef SHIFT_REGISTER1
  	localparam SHIFT = 8;

  	wire [15:0] sr1_k1;

    shift_register#(
      .SHIFT(SHIFT))
       sr1 (
      .Clock(clock),
      .Rst(),
      .Data_Out(Data_In),
      .Data_In(sr1_k1));

  `endif // SHIFT_REGISTER1	  


  // -- |SHIFT_REGISTER4| --------------------------------------------------
  `define SHIFT_REGISTER4
  
  `ifdef SHIFT_REGISTER4
  	localparam SHIFT = 16;

  	wire [15:0] sr1_k4;

    shift_register#(
      .SHIFT(SHIFT))
       sr4 (
      .Clock(clock),
      .Rst(),
      .Data_Out(mult1),
      .Data_In(sr1_k4));

  `endif // SHIFT_REGISTER4


  // -- |SHIFT_REGISTER2| --------------------------------------------------
  `define SHIFT_REGISTER2
  
  `ifdef SHIFT_REGISTER2
  	localparam SHIFT = 8;

  	wire [15:0] sr1_k2;

    shift_register#(
      .SHIFT(SHIFT))
       sr2 (
      .Clock(clock),
      .Rst(),
      .Data_Out(sr1_k1),
      .Data_In(sr1_k2));

  `endif // SHIFT_REGISTER2

  // -- |SHIFT_REGISTER3| --------------------------------------------------
  `define SHIFT_REGISTER3
  
  `ifdef SHIFT_REGISTER3
  	localparam SHIFT = 16;

  	wire [15:0] sr1_k3;

    shift_register#(
      .SHIFT(SHIFT))
       sr3 (
      .Clock(clock),
      .Rst(),
      .Data_Out(sr1_k2),
      .Data_In(sr1_k3));

  `endif // SHIFT_REGISTER3

	assign mult1 = sr1_k1 * K1;
	assign mult2 = sr1_k2 * K2;
	assign add1_out = Data_In + mult2 + mult1 + sr1_k3 + sr1_k4;
	assign Data_Out = add2_Out;

endmodule