module PatternGenerator (Clock, Reset, VideoReady, video);

input Clock;
input Reset;
input VideoReady;
output reg[23:0] video;

localparam STATE_1 = 3'b000,
		   STATE_2 = 3'b001,
		   STATE_3 = 3'b010,
		   STATE_4 = 3'b011,
		   STATE_5 = 3'b100,
		   STATE_6 = 3'b101,
		   STATE_7 = 3'b110,
		   STATE_8 = 3'b111,
		   WISTERIA = {8'd142, 8'd68, 8'd173},
		   MIDNIGHTBLUE = {8'd44, 8'd62, 8'd80},
		   GREENSEA = {8'd22, 8'd160, 8'd133},
		   BELIZE = {8'd41, 8'd128, 8'd185},
		   TURQUOISE = {8'd26, 8'd188, 8'd156},
		   CARROT = {8'd230, 8'd126, 8'd34},
		   SUNFLOWER = {8'd241, 8'd196, 8'd15},
		   EMERALD = {8'd46, 8'd204, 8'd113};

//10000011110101011111111111 <- new page after 1 second
//34559999

reg [31:0] page_counter;
reg [6:0] row_counter;
reg [2:0] RowState;
reg [2:0] NextRow;
reg [2:0] NextColumn;
reg [2:0] NextPage;

reg [9:0] column_counter;

always@(posedge Clock) begin 
	if (Reset) begin
		RowState <= STATE_1;
		row_counter <= 7'd0;
		column_counter <= 10'd0;
		page_counter <= 32'd0;
	end
	else if (VideoReady) begin
		if (page_counter == 32'd34559999) begin
			RowState <= NextPage;
			column_counter <= 10'd0;
			row_counter <= 7'd0;
			page_counter <= 26'd0;
		end
		else begin
			if (row_counter == 7'b1001111) begin
				row_counter <= 7'd0;

				if (column_counter == 10'd499) begin
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
			page_counter <= page_counter + 32'd1;
		end
	end
end

always@(*) begin
	case (RowState)
		STATE_1: begin
			video = WISTERIA;
			NextRow = STATE_2;
			NextColumn = STATE_3;
			NextPage = STATE_5;
		end
		STATE_2: begin
			video = MIDNIGHTBLUE;
			NextRow = STATE_1;
			NextColumn = STATE_3;
			NextPage = STATE_5;
		end
		STATE_3: begin
			video = GREENSEA;
			NextRow = STATE_4;
			NextColumn = STATE_1;
			NextPage = STATE_5;
		end
		STATE_4: begin
			video = BELIZE;
			NextRow = STATE_3;
			NextColumn = STATE_1;
			NextPage = STATE_5;
		end
		STATE_5: begin
			video = TURQUOISE;
			NextRow = STATE_6;
			NextColumn = STATE_7;
			NextPage = STATE_1;
		end
		STATE_6: begin
			video = CARROT;
			NextRow = STATE_5;
			NextColumn = STATE_7;
			NextPage = STATE_1;
		end
		STATE_7: begin
			video = SUNFLOWER;
			NextRow = STATE_8;
			NextColumn = STATE_5;
			NextPage = STATE_1;
		end
		STATE_8: begin
			video = EMERALD;
			NextRow = STATE_7;
			NextColumn = STATE_5;
			NextPage = STATE_1;
		end
	endcase
end

endmodule
