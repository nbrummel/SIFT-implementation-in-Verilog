module SwapController(
  input clock,
  input reset,

  output reg swap,
  input swap_ack,

  output reg bg_start,
  input bg_start_ack,

  input bg_done,
  output reg bg_done_ack);

reg bg_done_ack_r;

wire bg_done_edge;
assign bg_done_edge = bg_done_ack & ~bg_done_ack_r;

always @(posedge clock) begin
  if(reset) begin
    swap <= 1'b0;
    bg_start <= 1'b1;
    bg_done_ack <= 1'b0;
    bg_done_ack_r <= 1'b0;
  end else begin
    if(bg_start & bg_start_ack)
      bg_start <= 1'b0;
    else if(swap & swap_ack)
      bg_start <= 1'b1;

    // Synchronize ack
    bg_done_ack <= bg_done;
    bg_done_ack_r <= bg_done_ack;

    if(swap & swap_ack)
      swap <= 1'b0;
    else if (bg_done_edge)
      swap <= 1'b1;

  end
end

endmodule
