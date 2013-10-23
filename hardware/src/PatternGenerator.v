module PatternGenerator (Clock, Reset, VideoReady, video);

input Clock;
input Reset;
input VideoReady;
output reg[23:0] video;

localparam STATE_1 = 3'b000,
		   STATE_2 = 3'b001,
		   STATE_3 = 3'b010,
		   STATE_4 = 3'b011,
		   TURQUOISE = {8'd26, 8'd188, 8'd156},
		   CARROT = {8'd230, 8'd126, 8'd34},
		   SUNFLOWER = {8'd241, 8'd196, 8'd15},
		   EMERALD = {8'd46, 8'd204, 8'd113};


reg [6:0] row_counter;
reg [2:0] RowState;
reg [2:0] NextRow;
reg [2:0] NextColumn;

reg [9:0] column_counter;

always@(posedge Clock) begin 
	if (Reset) begin
		RowState <= STATE_1;
		row_counter <= 7'd0;
		column_counter <= 10'd0;
	end
	else if (VideoReady) begin
		if (row_counter == 7'b1001111) begin
			row_counter <= 7'd0;

			if (column_counter == 10'd199) begin
				RowState <= NextColumn;
				column_counter <= 10'd0;
			end
			else begin
				RowState <= NextRow;
				column_counter <= column_counter + 10'd1;
			end

		end
		else begin 
			row_counter <= row_counter + 7'd1;
		end
	end
end

always@(*) begin
	case (RowState)
		STATE_1: begin
			video = TURQUOISE;
			NextRow = STATE_2;
			NextColumn = STATE_3;
		end
		STATE_2: begin
			video = CARROT;
			NextRow = STATE_1;
			NextColumn = STATE_3;
		end
		STATE_3: begin
			video = SUNFLOWER;
			NextRow = STATE_4;
			NextColumn = STATE_1;
		end
		STATE_4: begin
			video = EMERALD;
			NextRow = STATE_3;
			NextColumn = STATE_1;
		end
	endcase
end

endmodule