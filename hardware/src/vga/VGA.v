module VGA (
  input reset,
  output clock,

  input start,
  output reg start_ack,
  
  output reg done,
  input done_ack,

  output [7:0] video,
  output video_valid,

  //  AD9980 Interface
  input [7:0] vga_red, vga_green, vga_blue,
  input vga_data_clk,
  input vga_hsout,
  input vga_vsout);

  // Buffer input pixel clock
  BUFG pixel_clock_buf(.I(vga_data_clk), .O(clock));
  
  // Approximate (r+b+g)/3 as (r+b+g)*(16 + 4 + 1)/64
  // Also offset by 4 to allow for colorspace mapping
  reg [7:0] red, green, blue;
  reg [9:0] sum;
  reg [13:0] div;

  assign video = div[13:6] + 8'd4;

  always @(posedge clock) begin
    red <= vga_red;
    green <= vga_green;
    blue <= vga_blue;
    
    sum <= red + green + blue;
    
    div <= (16*sum) + (4*sum) + sum;
  end

  parameter WIDTH   = 800,
            HEIGHT  = 600,
            BACK_H  = 160,
// AD9980 pixel delay of 6 + HSOUT width of 32 + conversion delay of 2
            OFFS_H  = 28, 
            BACK_V  = 21,
            OFFS_V  = 4;

  localparam  H_MAX = BACK_H + OFFS_H + WIDTH,
              V_MAX = BACK_V + OFFS_V + HEIGHT;

  reg [11:0] h_count, v_count;
  wire h_active, v_active;

  assign h_active = (h_count >= (BACK_H + OFFS_H)) & 
                    (h_count <  (BACK_H + OFFS_H + WIDTH));
  
  assign v_active = (v_count >= (BACK_V + OFFS_V)) & 
                    (v_count <  (BACK_V + OFFS_V + HEIGHT));
  
  assign video_valid = h_active & v_active;

  always @(posedge clock) begin
    if (reset) begin
      start_ack <= 1'b0;
      done <= 1'b0;

      h_count <= H_MAX;
      v_count <= V_MAX;
    end else begin
      if((v_count == V_MAX) & start & vga_vsout)
        v_count <= 12'd0;
      else if ((v_count < V_MAX) & (h_count == (H_MAX-1)))
        v_count <= v_count + 12'd1;


      if((v_count == V_MAX) & start & vga_vsout)
        start_ack <= 1'b1;
      else if (start_ack & ~start)
        start_ack <= 1'b0;

      if ((h_count == (H_MAX-1)) & (v_count == (V_MAX-1)))
        done <= 1'b1;
      else if (done & done_ack)
        done <= 1'b0;

      if(vga_hsout)
        h_count <= 12'd0;
      else if (h_count < H_MAX)
        h_count <= h_count + 12'd1;
    end
  end

endmodule
