module GAUSSIAN(
	input clk,
	input [7:0] din,
	input rst,
	input clk_en,
	output [7:0] dout);

reg[7:0] testReg;
reg[7:0] testReg2;

assign dout = testReg2;

always@(posedge clk) begin
	if (rst) begin
		testReg <= 8'd0;
		testReg2 <= 8'd0;
	end
	else begin
		testReg <= din - 8'b10000000;
		testReg2 <= testReg;
	end
end

endmodule