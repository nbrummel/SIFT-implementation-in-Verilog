module GAUSSIANTWO (
	input clk,
	input rst,
	input [7:0] din,
	input clk_en,
	output [7:0] dout
);
    //shift_ram

    //k values
    parameter k1 = 6;
    parameter k2 = 58;
    parameter k3 = 128;

    //Row Major Variables
    reg [7:0] s1, s2, s3, s4;
    reg v1, v2, v3, v4, v5, v6;
    wire [15:0] result1;
    wire [7:0] column_input;

    //Column Major Variables
    wire [7:0] c0,c1,c2,c3,c4;
    wire [15:0] result2;

    shift_ram_400 sr1(
	    .clk(clk), 
	    .ce(clk_en), 
	    .sclr(rst), 
	    .q(c1),
	    .d(c0)
    );
    shift_ram_400 sr2(
	    .clk(clk), 
	    .ce(clk_en), 
	    .sclr(rst), 
	    .q(c2),
	    .d(c1)
    );
    shift_ram_400 sr3(
	    .clk(clk), 
	    .ce(clk_en), 
	    .sclr(rst), 
	    .q(c3),
	    .d(c2)
    );
    shift_ram_400 sr4(
	    .clk(clk), 
	    .ce(clk_en), 
	    .sclr(rst), 
	    .q(c4),
	    .d(c3)
    );

    always @(posedge clk) begin
        if (rst) begin
		    s1 <= 0;
		    s2 <= 0;
		    s3 <= 0;
		    s4 <= 0;
	    end
	    else if (clk_en) begin
		    s1 <= din;
		    s2 <= s1;
		    s3 <= s2;
		    s4 <= s3;
	    end 
	end

    assign result1 = k1*din + k2*s1 + k3*s2 + k2*s3 + k1*s4;
    assign column_input = result1[15:8];

    assign c0 = column_input;
    assign result2 = k1*column_input + k2*c1 + k3*c2 + k2*c3 + k1*c4;
    assign dout = c4;

endmodule
