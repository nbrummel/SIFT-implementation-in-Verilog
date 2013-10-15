// UC Berkeley CS150
// Lab 0, Spring 2013
// Module: BehavioralAdder.v
// Desc: Parametrized behavioral adder

module BehavioralAdder #(
  parameter Width = 16
)
(
  input   [Width-1:0] A,
  input   [Width-1:0] B,
  output  [Width-1:0] Result,
  output              Cout
);
  
  assign {Cout, Result} = A + B;

endmodule
