module PatternGenerator (Clock, Reset, VideoReady, video);

input Clock;
input Reset;
input VideoReady;
output reg[23:0] video;

localparam STATE_BLUE = 3'b000,
		   STATE_GREEN = 3'b001,
		   TURQUOISE = {8'd26, 8'd188, 8'd156},
		   CARROT = {8'd230, 8'd126, 8'd34},
		   SUNFLOWER = {8'd241, 8'd196, 8'd15},
		   POMEGRANATE = {8'd192, 8'd57, 8'd43};


reg [6:0] counter;
reg [2:0] CurrentState;
reg [2:0] NextState;

always@(posedge Clock) begin 
	if (Reset) begin
		CurrentState <= STATE_BLUE;
		counter <= 7'd0;
	end
	else if (VideoReady) begin
		if (counter == 7'b1111111) begin
			counter <= 7'd0;
			CurrentState <= NextState;
		end
		else begin 
			counter <= counter + 7'd1;
		end
	end
end

always@(*) begin
	case (CurrentState)
		STATE_BLUE: begin
			video = TURQUOISE;
			NextState = STATE_GREEN;
		end
		STATE_GREEN: begin
			video = CARROT;
			NextState = STATE_BLUE;
		end
	endcase
end

endmodule