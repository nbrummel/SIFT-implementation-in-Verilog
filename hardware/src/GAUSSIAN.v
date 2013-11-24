module GAUSSIAN #(
	parameter 	K1 = 6,
			  	K2 = 58,
				K3 = 128,
				IDLE = 2'b0,
				SHIFT_STATE = 2'b1)
		( 	Clk, 
			din, 
			Reset, 
			Clk_en, 
			dout );
		
	input Clk;
	input [7:0] din;
	input Reset;
	input Clk_en;
	output [7:0] dout;

	wire [15:0] A, B, C, D, E;
	wire [7:0] horizontal_stage_out;
	
	reg [7:0] srA1, srB1;
	reg [15:0] srC1a, srC1b, srD1a, srD1b;
	reg Current_State;

	assign A = din * K1;
	assign B = srA1 * K2;
	assign C = srB1 * K3;
	assign E = srD1b;

	assign horizontal_stage_out = (A + B + C + D + E) >> 8;

	always @(posedge Clk) begin
		if(Reset) begin
			srA1 <= 8'd0;
			srB1 <= 8'd0;
			srC1a <= 16'd0;
			srC1b <= 16'd0;
			srD1a <= 16'd0;
			srD1b <= 16'd0;
			if(~Clk_en) 
				Current_State <= IDLE;
			else
				Current_State <= SHIFT_STATE;
		end
		else if(~Clk_en) 
			Current_State <= IDLE; 
		else
			Current_State <= SHIFT_STATE;
			srA1 <= din;
			srB1 <= srA1;
			srC1a <= B;
			srC1b <= srC1a;
			srD1a <= A;
			srD1b <= srD1a;
	end

	always @(*) begin
		if (Current_State == IDLE) begin
		end	
		else begin
		end
	end



	wire [15:0] a_2, b_2, c_2, d_2, e_2, shift_out_1_b, shift_out_2_b;

	assign a_2 = din * K1;
	assign b_2 = shift_out_1_b * K2;
	assign c_2 = shift_out_2_b * K3;
	assign dout = (a_2 + b_2 + c_2 + d_2 + e_2) >> 8;


	shift_ram_400 srA2 (
		.clk(clock),
		.ce(Clk_en),
		.sclr(reset),
		.d(horizontal_stage_out),
		.q(shift_out_1_b));


	shift_ram_400 srB2 (
		.clk(clock),
		.ce(Clk_en),
		.sclr(reset),
		.d(shift_out_1_b),
		.q(shift_out_2_b));


	shift_ram_800 srC2 (
		.clk(clock),
		.ce(Clk_en),
		.sclr(reset),
		.d(a_2),
		.q(e_2));



	shift_ram_800 srD2 (
		.clk(clock),
		.ce(Clk_en),
		.sclr(reset),
		.d(b_2),
		.q(d_2));

endmodule