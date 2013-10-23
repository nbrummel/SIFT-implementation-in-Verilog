module PatternGenerator (Clock, Reset, VideoReady, video);

input Clock;
input Reset;
input VideoReady;
output reg[23:0] video;

localparam STATE_1 = 3'b000,
		   STATE_2 = 3'b001,
		   TURQUOISE = {8'd26, 8'd188, 8'd156},
		   CARROT = {8'd230, 8'd126, 8'd34},
		   SUNFLOWER = {8'd241, 8'd196, 8'd15},
		   POMEGRANATE = {8'd192, 8'd57, 8'd43};


reg [6:0] row_counter;
reg [2:0] RowState;
reg [2:0] NextRow;

reg [6:0] column_counter;
reg [2:0] ColumnState;
reg [2:0] NextColumn;

always@(posedge Clock) begin 
	if (Reset) begin
		RowState <= STATE_1;
		row_counter <= 7'd0;
		ColumnState <= STATE_1;
		column_counter <= 7'd0;
	end
	else if (VideoReady) begin
		if (row_counter == 7'b1001111) begin
			row_counter <= 7'd0;
			RowState <= NextRow;
		end
		else begin 
			row_counter <= row_counter + 7'd1;
		end
	end
end

always@(*) begin
	case (ColumnState)
		STATE_1: begin
			case (RowState)
				STATE_1: begin
					video = TURQUOISE;
					NextRow = STATE_2;
				end
				STATE_2: begin
					video = CARROT;
					NextRow = STATE_1;
				end
			endcase
			NextColumn = STATE_2;
		end
		STATE_2: begin
			case (RowState)
				STATE_1: begin
					video = SUNFLOWER;
					NextRow = STATE_2;
				end
				STATE_2: begin
					video = POMEGRANATE;
					NextRow = STATE_1;
				end
			endcase
			NextColumn = STATE_1;
		end
	endcase
end

endmodule