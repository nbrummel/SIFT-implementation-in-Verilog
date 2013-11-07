module Overlay #(
  parameter ROW_P = 300,
            COL_P = 100,
            N_ROW = 200,
            MAX_ADDR = ((ROW_P + 16) * N_ROW) + (COL_P + 4),
            MIN_ADDR = ROW_P * 200 + COL_P,
            MASK_MAP = "mask1.hex")
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

  reg [7:0] mask_map [63:0];
  initial begin
    $readmemh(MASK_MAP, mask_map);
  end

  reg frame;
  wire [16:0] addr;


  // Generate Horizontal gradient of pixels
  reg [7:0] count;
  wire [31:0] pixel;
  reg [3:0] mask;
  
  reg [3:0] Y;
  reg [3:0] X;
  reg [8:0] i;

  assign addr = ((ROW_P + Y) * N_ROW) + (COL_P + X);
  assign pixel = count + 32'h02020202;
  /*assign pixel = {count + {2'h01, 2'd3},
                  count + {2'h01, 2'd2},
                  count + {2'h01, 2'd1},
                  count + {2'h01, 2'd0}};
*/
  // Concatenate mask, frame, addr, and pixel data
  assign dout = {4'hF, frame, addr, pixel};

  assign valid = addr <= MAX_ADDR;

 
 
  reg start_ack_r;

  // Have a signal for when the output is incremented
  wire inc;
  assign inc = valid & ready;

  // Simple edge dector on start condition
  wire start_edge;
  assign start_edge = start_ack & ~start_ack_r;




  always @(posedge clock) begin
    if(reset) begin
      frame <= 1'b1;
      done <= 1'b0;
      start_ack <= 1'b0;
      start_ack_r <= 1'b0;
      count <= 8'd0;
      i <= 8'd0;
    end else begin
      if (done & done_ack)
        done <= 1'b0;
      else if ((i == 8'd31) & ready) begin
        done <= 1'b1;

        // Since addr will be incremented, we avoid switching frames 
        // twice
        frame <= ~frame;

        // If selected, produce dynamic horizontal scrolling output
        if(scroll)
          count <= count - 1;
        else
          count <= 8'd0;
      end

      // Synchronize start
      start_ack <= start;
      start_ack_r <= start_ack;
      // Use edge signal so we don't submit multiple at the same addr
      if (start_edge) begin
        Y <= mask_map[i][7:4];
        X <= mask_map[i][3:0];
        mask <= mask_map[i][3:0];
        i <= i + 8'd1;
      end else if (inc) begin
       Y <= mask_map[i][7:4];
       X <= mask_map[i][3:0];
        mask <= mask_map[i][3:0];
        i <= i + 8'd1;
      end
    end
  end
endmodule
