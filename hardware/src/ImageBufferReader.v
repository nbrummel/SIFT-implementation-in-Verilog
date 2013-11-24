module ImageBufferReader #(
  parameter START_FRAME = 1'b0,
  parameter N_PIXEL = 480000,
  parameter COLOR_MAP = "colormap.hex")
(
  // Controller interface
  input clock,
  input reset,
  input swap,
  output reg swap_ack,

  // DVI Interface
  output [23:0] video,
  output video_valid,
  input video_ready,

  // SRAM Arbiter Interface
  output reg addr_valid,
  output [17:0] addr,
  input addr_ready,
  output data_ready,
  input [31:0] data,
  input data_valid);

reg [7:0] curr_pixel;
reg [1:0] pixel_idx;

reg [23:0] color_map [255:0];
initial begin
  $readmemh(COLOR_MAP, color_map);
end

always @(*) begin
  case(pixel_idx[1:0])
    2'd0: curr_pixel <= data[7:0];
    2'd1: curr_pixel <= data[15:8];
    2'd2: curr_pixel <= data[23:16];
    2'd3: curr_pixel <= data[31:24];
  endcase
end

assign video = color_map[curr_pixel];
assign video_valid = data_valid;
assign data_ready = video_ready & (pixel_idx == 2'd3);

// Pixel selection state machine
always @(posedge clock) begin
  if (reset | ~video_valid) begin
    pixel_idx <= 2'd0;
  end else if(video_ready) begin
    pixel_idx <= pixel_idx + 2'd1;
  end
end

// Address logic
reg [16:0] pixel_addr;
reg frame, swap_r;
assign addr = {frame, pixel_addr};

localparam MAX_ADDR = (N_PIXEL/4)-1;

// Synchronize swap to swap_r
always @(posedge clock) begin
  if (reset)
    swap_r <= 1'b0;
  else
    swap_r <= swap;
end

always @(posedge clock) begin
  if(reset) begin
    pixel_addr <= MAX_ADDR;
    frame <= START_FRAME;
    addr_valid <= 1'b0;
    swap_ack <= 1'b0;
  end else if(addr_ready) begin
    if(pixel_addr == MAX_ADDR) begin
      if(swap_r) begin
        swap_ack <= 1'b1;
        frame <= ~frame;
        addr_valid <= 1'b1;
      end
      
      if (swap_r | addr_valid)
        pixel_addr <= 17'd0;
    end else begin
      if(~swap_r)
        swap_ack <= 1'b0;

      pixel_addr <= pixel_addr + 17'd1;
    end
  end
end

endmodule
