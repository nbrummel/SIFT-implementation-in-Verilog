module GaussianControl(

//Global
input global_reset,
input clk,

//From Down Sample
input [7:0] data_in,
input valid_in,

//To Down Sample
output rd_en,

//From Up Sample
input full,

//To Up Sample
output wire [7:0] data_out, //hard wired to Gaussian
output reg wr_en,
output reg valid);

//State encoding
localparam 	STATE_IDLE = 3'd0,
			STATE_PASS_DATA = 3'd1,
			STATE_MUX_0 = 3'd2,
			STATE_FINAL_BUFFER = 3'd3;

//State reg declarations
reg [2:0] CurrentState;
reg [2:0] NextState;

//Inputs to the Gaussian module
reg enable_gaussian;
reg reset;
//The counter that keeps track of how deep we are in the pipeline
reg [17:0] counter;

//The Gaussian Module this is surrounding.
GAUSSIAN gaussian_module(
	.din(data_in),
	.dout(data_out),
	.Clk_en(enable_gaussian),
	.Clk(clk),
	.Reset(reset));

always@(posedge clk) begin
	if (global_reset) begin
		counter <= 18'd0;
		reset <= 1'b1;
		CurrentState <= STATE_IDLE;
		NextState <= STATE_IDLE;
	end
	else begin
		CurrentState <= NextState;
	end
end

//Next State Handling for Logic 1
always@(*) begin
	case (CurrentState)
		STATE_IDLE: begin
			//do stuff
		end
		STATE_PASS_DATA: begin
			//do stuff
		end
		STATE_MUX_0: begin
			//do stuff
		end
		STATE_FINAL_BUFFER: begin
			//do stuff
		end
		default: begin
			//Do stuff
		end
	endcase
end


endmodule