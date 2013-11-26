module ShiftReg(
	input clk,
	input ce,
	input sclr,
	input [7:0] d,
	output [7:0] q);

reg [7:0] reg_01;
reg [7:0] reg_02;
reg [7:0] reg_03;
reg [7:0] reg_04;
reg [7:0] reg_05;
reg [7:0] reg_06;
reg [7:0] reg_07;
reg [7:0] reg_08;
reg [7:0] reg_09;
reg [7:0] reg_10;

assign q = reg_10;

always@(posedge clk) begin
	if (sclr) begin
		reg_01 <= 8'd0;
		reg_02 <= 8'd0;
		reg_03 <= 8'd0;
		reg_04 <= 8'd0;
		reg_05 <= 8'd0;
		reg_06 <= 8'd0;
		reg_07 <= 8'd0;
		reg_08 <= 8'd0;
		reg_09 <= 8'd0;
		reg_10 <= 8'd0;
	end
	else begin
		if (ce) begin
			reg_01 <= d;
			reg_02 <= reg_01;
			reg_03 <= reg_02;
			reg_04 <= reg_03;
			reg_05 <= reg_04;
			reg_06 <= reg_05;
			reg_07 <= reg_06;
			reg_08 <= reg_07;
			reg_09 <= reg_08;
			reg_10 <= reg_09;
		end
	end
end

endmodule
