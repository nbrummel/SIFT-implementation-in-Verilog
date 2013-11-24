module StaticImage #(
  parameter IMG_WIDTH = 200,
  parameter IMG_HEIGHT = 150)
(
  input clock,
  input reset,

  input start,
  output reg start_ack,

  input ready,
  output valid,
  output [7:0] pixel);

localparam  OUT_WIDTH = 800,
            OUT_HEIGHT = 600;

localparam  IMG_N_PIXEL = IMG_WIDTH * IMG_HEIGHT,
            IMG_X_START = (OUT_WIDTH-IMG_WIDTH)/2,
            IMG_Y_START = (OUT_HEIGHT-IMG_HEIGHT)/2;

wire [7:0] pixel_data;
reg [9:0] img_row, img_col;
reg [14:0] img_pxl;
wire row_active, col_active, pxl_active;

assign col_active = (img_col > (IMG_X_START-1)) & 
        (img_col < (IMG_X_START+IMG_WIDTH));
assign row_active = (img_row > (IMG_Y_START-1)) & 
        (img_row < (IMG_Y_START+IMG_HEIGHT));
assign pxl_active = row_active & col_active;

IMG_MEM img_mem(
  .clka(clock),
  .addra(img_pxl),
  .douta(pixel_data));

assign pixel = pxl_active ? pixel_data : 8'd0;
assign valid = (img_row < OUT_HEIGHT);

wire start_edge;
reg start_ack_r;
assign start_edge = start_ack_r & ~start_ack;

always @(posedge clock) begin
  if(reset) begin
    img_row <= OUT_HEIGHT;
    img_col <= OUT_WIDTH;
    img_pxl <= 15'd0;
    start_ack <= 1'b0;
    start_ack <= 1'b0;
  end else begin
    start_ack <= start;
    start_ack_r <= start_ack;

    if (start_edge) begin
      img_row <= 10'd0;
      img_col <= 10'd0;
    end else if (valid & ready) begin
      if (img_col == (OUT_WIDTH-1)) begin
        img_col <= 10'd0;
        img_row <= img_row + 10'd1;
      end else
        img_col <= img_col + 10'd1;
    end

    if (start_edge)
      img_pxl <= 15'd0;
    else if (pxl_active)
      img_pxl <= img_pxl + 15'd1;
  end
end

endmodule
