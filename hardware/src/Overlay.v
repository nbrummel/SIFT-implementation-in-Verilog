module Overlay #(
  parameter N_ROW = 300,
            N_COL = 400,
            N_PIXEL = N_COL * N_ROW * 256,
            MASK_MAP = "mask.binary")
  (
    input clock,
    input reset,

    input scroll,

    input start,
    output reg start_ack,

    output reg done,
    input done_ack,

    output [53:0] dout,
    output valid,
    input ready);

  localparam MAX_ADDR = (N_PIXEL/4)-1;

  reg frame;
  reg [16:0] addr;


  // Generate Horizontal gradient of pixels
  reg [7:0] count;
  wire [31:0] pixel;
  reg [15:0] mask;
  reg [23:0] mask_map [63:0];

  assign pixel = {count + {2'h02, 2'd3},
                  count + {2'h02, 2'd2},
                  count + {2'h02, 2'd1},
                  count + {2'h02, 2'd0}};

  // Concatenate mask, frame, addr, and pixel data
  assign dout = {mask, frame, addr, pixel};

  assign valid = addr <= MAX_ADDR;

  initial begin
    $readmemh(MASK_MAP, mask_map);
  end

  reg start_ack_r;

  // Have a signal for when the output is incremented
  wire inc;
  assign inc = valid & ready;

  // Simple edge dector on start condition
  wire start_edge;
  assign start_edge = start_ack & ~start_ack_r;

  integer i;

  always @(posedge clock) begin
    if(reset) begin
      addr <= MAX_ADDR+1;
      frame <= 1'b1;
      done <= 1'b0;
      start_ack <= 1'b0;
      start_ack_r <= 1'b0;
      count <= 8'd0;
    end else begin
      if (done & done_ack)
        done <= 1'b0;
      else if ((addr == MAX_ADDR) & ready) begin
        done <= 1'b1;

        // Since addr will be incremented, we avoid switching frames 
        // twice
        frame <= ~frame;

        // If selected, produce dynamic horizontal scrolling output
        if(scroll)
          count <= count + 1;
        else
          count <= 8'd0;
      end

      // Synchronize start
      start_ack <= start;
      start_ack_r <= start_ack;
      // Use edge signal so we don't submit multiple at the same addr
      if (start_edge) begin
        i = 0;
        mask <= mask_map[i][15:0];
        addr <= ( N_ROW + mask_map[i][23:20] ) * ( N_COL + mask_map[i][19:16] );
        i = i + 1;
      end else if (inc) begin
        addr <= ( N_ROW + mask_map[i][23:20] ) * ( N_COL + mask_map[i][19:16] );
        mask <= mask_map[i][15:0];
        i = i + 1;
      end
    end
  end
endmodule
