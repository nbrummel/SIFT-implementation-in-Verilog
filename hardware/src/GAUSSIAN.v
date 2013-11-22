module GAUSSIAN #(
	parameter 	K1 = 6,
			  	K2 = 58,
				K3 = 128)
		   (input Clk,
			input [7:0] din,
			input Reset,
			input Clk_en,
			output [7:0] dout);

   
	reg [7:0] dout_out;
	assign dout = dout_out;

	always @(posedge Clk) begin
		if (Reset) begin
			dout_out <= 8'd0;
		end
		else begin
			if (Clk_en) begin
				dout_out <= din;
			end
		end
	end


endmodule