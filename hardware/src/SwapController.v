
module SwapController(
    input clock,
    input reset,

    output reg swap,
    input swap_ack,

    output reg bg_start,
    input bg_start_ack,

    input bg_done,
    output reg bg_done_ack,

    output reg ol_start,
    input ol_start_ack,

    input ol_done,
    output reg ol_done_ack);

    reg bg_done_ack_r;

    wire bg_done_edge;
    assign bg_done_edge = bg_done_ack & ~bg_done_ack_r;

    reg ol_done_ack_r;

    wire ol_done_edge;
    assign ol_done_edge = ol_done_ack & ~ol_done_ack_r;

				
  always @(posedge clock) begin
    if(reset) begin
      swap <= 1'b0;
      bg_start <= 1'b1;
      bg_done_ack <= 1'b0;
      bg_done_ack_r <= 1'b0;
      ol_start <= 1'b0;
      ol_done_ack <= 1'b0;
      ol_done_ack_r <= 1'b0;
      
    end else begin
      if(bg_start & bg_start_ack)
        bg_start <= 1'b0;
      else if(ol_start & ol_start_ack)
        ol_start <= 1'b0;
      else if(bg_done_edge) begin
        bg_done_ack <= 1'b1;
      	ol_start <= 1'b1;
      end
      else if(swap & swap_ack)
        bg_start <= 1'b1;

      // Synchronize ack
      bg_done_ack <= bg_done;
      bg_done_ack_r <= bg_done_ack;
      ol_done_ack <= ol_done;
      ol_done_ack_r <= ol_done_ack;
    
      if(swap & swap_ack)
        swap <= 1'b0; 
      else if (ol_done_edge) begin
        ol_done_ack <= 1'b1;
      	swap <= 1'b1; 
      end
    end
  end
  
endmodule
