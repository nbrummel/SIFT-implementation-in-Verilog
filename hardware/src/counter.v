module counter #(
	parameter COUNT_TO = 800)
(
	clk,
	reset,
	enable,
	ctr_out
);

// Port definitions
input clk, reset, enable;
output [9:0] ctr_out;

// Register definitions
reg [9:0] reg_ctr;

// Assignments
assign ctr_out = reg_ctr;

// Counter behaviour - Asynchronous active-high reset
initial reg_ctr <= 0;
always @ (posedge clk or posedge reset)
begin
	if (reset)       
		reg_ctr <= 0;
	else if (enable) begin
		if (reg_ctr == COUNT_TO) 
			reg_ctr <= 0;
		else                     
			reg_ctr <= reg_ctr + 1;
	end
end

endmodule