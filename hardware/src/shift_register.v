module shift_register#(
	parameter SHIFT = 8,
						N = SHIFT-1)
(
input Clock,
input Rst,
input Data_In,
output Data_Out,
);

//--------------------------------------------------------------
// signal definitions
//--------------------------------------------------------------

//shift register signals
reg [N:0] bitShiftReg;

//--------------------------------------------------------------
// shift register
//--------------------------------------------------------------

//shift register
always @(posedge Clock)
begin

//bit shift register
bitShiftReg <= {bitShiftReg[N-1:0],Data_In};
end
//--------------------------------------------------------------
// outputs
//--------------------------------------------------------------

//module output wires
assign Data_Out = bitShiftReg[N];
endmodule