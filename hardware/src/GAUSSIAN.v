module GAUSSIAN(
	input clk,
	input [7:0] din,
	input rst,
	input clk_en,
	output [7:0] dout);

reg[7:0] testReg;
reg[7:0] testReg2;
reg[7:0] testReg3;
reg[7:0] testReg4;
reg[7:0] testReg5;
reg[7:0] testReg6;
reg[7:0] testReg7;
reg[7:0] testReg8;
reg[7:0] testReg9;
reg[7:0] testReg10;
reg[7:0] testReg11;
reg[7:0] testReg12;
reg[7:0] testReg13;
reg[7:0] testReg14;
reg[7:0] testReg15;
reg[7:0] testReg16;
reg[7:0] testReg17;


assign dout = testReg17;

always@(posedge clk) begin
	if (rst) begin
		testReg <= 8'd0;
		testReg2 <= 8'd0;
	end
	else begin
		testReg <= din - 8'b10000000;
		testReg2 <= testReg;
		testReg3 <= testReg2;
		testReg4 <= testReg3;
		testReg5 <= testReg4;
		testReg6 <= testReg5;
		testReg7 <= testReg6;
		testReg8 <= testReg7;
		testReg9 <= testReg8;
		testReg10 <= testReg9;
		testReg11 <= testReg10;
		testReg12 <= testReg11;
		testReg13 <= testReg12;
		testReg14 <= testReg13;
		testReg15 <= testReg14;
		testReg16 <= testReg15;
		testReg17 <= testReg16;
	end
end

endmodule