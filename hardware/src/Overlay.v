/*module Overlay #(
  parameter N_ROW = 300,
            N_COL = 400,
            N_PIXEL = N_COL * N_ROW * 256,
            MASK_MAP = "mask.hex")
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
reg [7:0] video;
reg [9:0] row;

// Generate Horizontal gradient of pixels
reg [7:0] count;
wire [31:0] pixel;
assign pixel = {count + {video[5:0], 2'd3},
                count + {video[5:0], 2'd2},
                count + {video[5:0], 2'd1},
                count + {video[5:0], 2'd0}};

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
    addr <= MAX_ADDR+1;
    frame <= 1'b1;
    done <= 1'b0;
    start_ack <= 1'b0;
    start_ack_r <= 1'b0;
    video <= 8'd0;
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
      video <= 8'd0;
      addr <= 17'd0;
      row <= 8'd0;
    end else if (inc) begin
      addr <= addr + 17'd1;
      if (video == 8'd199) begin
        video <= 8'd0;
        row <= row + 10'd1;
      end else
        video <= video + 1;
    end
  end
end

endmodule
*/
module Overlay #(
  parameter ROW_P = 300,
            COL_P = 100,
            MAX_ADDR = (ROW_P + 4)*(COL_P + 16),
            MIN_ADDR = ROW_P * COL_P,
            MASK_MAP = "mask.hex")
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

  reg [11:0] mask_map [63:0];
  initial begin
    $readmemh(MASK_MAP, mask_map);
  end

  reg frame;
  wire [16:0] addr;


  // Generate Horizontal gradient of pixels
  reg [7:0] count;
  wire [31:0] pixel;
  reg [3:0] mask;
  
  reg [16:0] Y;
  reg [16:0] X;
  reg [8:0] i;

  assign addr = (ROW_P + Y) * (COL_P + X);
  assign pixel = count + 32'h010101;
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
      else if ((i == 8'd63) & ready) begin
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
        Y <= mask_map[8'd0][11:8];
        X <= mask_map[8'd0][7:4];
        mask <= mask_map[i][3:0];
      end else if (inc) begin
       // Y <= mask_map[i][11:8];
       // X <= mask_map[i][7:4];
        mask <= mask_map[i][3:0];
        i <= i + 8'd1;
      end
    end
  end
endmodule
