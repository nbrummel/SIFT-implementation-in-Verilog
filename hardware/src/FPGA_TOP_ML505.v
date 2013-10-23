module FPGA_TOP_ML505(
  input   GPIO_SW_C,
  input   USER_CLK,

  output [7:0] GPIO_LED,

  // DVI Controller
  output [11:0] DVI_D,
  output        DVI_DE,
  output        DVI_H,
  output        DVI_RESET_B,
  output        DVI_V,
  output        DVI_XCLK_N,
  output        DVI_XCLK_P,
  inout         IIC_SCL_VIDEO,
  inout         IIC_SDA_VIDEO);
  
  //--|Parameters|--------------------------------------------------------------

  parameter   UserClockFreq = 100000000;  // 100 MHz
  parameter   DVIClockFreq  =  50000000;  // 50 MHz

  //--|Clock| -----------------------------------------------------------------

  wire clk_100M_g;
  wire clk_50M_pre, clk_50M;
  wire clk_200M_pre, clk_200M;
  wire clk_10M_pre, clk_10M;
  wire pll_fb, pll_lock;

  IBUFG clk_buf_user  (.I(USER_CLK),.O(clk_100M_g));
  
  PLL_BASE #(
    .BANDWIDTH("OPTIMIZED"),
    .CLKFBOUT_MULT(24),
    .CLKFBOUT_PHASE(0.0),
    .CLKIN_PERIOD(10.0),
    .COMPENSATION("SYSTEM_SYNCHRONOUS"),
    .DIVCLK_DIVIDE(4),
    .REF_JITTER(0.100),

    .CLKOUT0_DIVIDE(12),
    .CLKOUT0_DUTY_CYCLE(0.5),
    .CLKOUT0_PHASE(0.0),
    
    .CLKOUT1_DIVIDE(3),
    .CLKOUT1_DUTY_CYCLE(0.5),
    .CLKOUT1_PHASE(0.0),
    
    .CLKOUT2_DIVIDE(60),
    .CLKOUT2_DUTY_CYCLE(0.5),
    .CLKOUT2_PHASE(0.0))
  clk_pll (
    .RST(1'b0),
    .CLKIN(clk_100M_g),
    .CLKFBOUT(pll_fb),
    .CLKFBIN(pll_fb),
    .LOCKED(pll_lock),
    .CLKOUT0(clk_50M_pre),
    .CLKOUT1(clk_200M_pre),
    .CLKOUT2(clk_10M_pre));

  // Global buffers for output clocks
  BUFG  clk_buf_50M   (.I(clk_50M_pre),.O(clk_50M));
  BUFG  clk_buf_200M  (.I(clk_200M_pre),.O(clk_200M));
  BUFG  clk_buf_10M  (.I(clk_10M_pre),.O(clk_10M));

  // -- |Reset| ---------------------------------------------------------------
  
  wire Reset;
  Debouncer #(
    .Width(20))
  reset_debounce(
    .Clock(clk_10M),
    .Reset(1'b0),
    .Enable(1'b1),
    .In(GPIO_SW_C),
    .Out(Reset));
  /*ButtonParse        #( .Width(           1),
                        .DebWidth(        20),
                        .EdgeOutWidth(    1),
                        .Continuous(      1)) 
            resetParse( .Clock(           clk_50M_g),
                        .Reset(           1'b0),
                        .Enable(          1'b1),
                        .In(              GPIO_SW_C),
                        .Out(             Reset));*/

  
  // -- [DVI Controller] ----------------------------------------------------
  
  `define DVI_ENABLE
  
  `ifdef DVI_ENABLE
    wire [23:0] video;
    wire video_ready,video_valid;
    
    // REMOVE THESE WHEN TEST PATTERN GENERATOR IS DONE
    //assign video = {8'h0, 8'h0, 8'hFF};
    assign video_valid = 1'b1;

    PatternGenerator pg (
        .Clock(clk_50M),
        .VideoReady(video_ready),
        .video(video),
        .Reset(Reset)
      );

    DVI #(
     .ClockFreq(                 50000000),
     .Width(                     1040),
     .FrontH(                    56),
     .PulseH(                    120),
     .BackH(                     64),
     .Height(                    666),
     .FrontV(                    37),
     .PulseV(                    6),
     .BackV(                     23)
    ) dvi(
     .Clock(                     clk_50M),
     .Reset(                     Reset),
     .DVI_D(                     DVI_D),
     .DVI_DE(                    DVI_DE),
     .DVI_H(                     DVI_H),
     .DVI_V(                     DVI_V),
     .DVI_RESET_B(               DVI_RESET_B),
     .DVI_XCLK_N(                DVI_XCLK_N),
     .DVI_XCLK_P(                DVI_XCLK_P),
     .I2C_SCL_DVI(               IIC_SCL_VIDEO),
     .I2C_SDA_DVI(               IIC_SDA_VIDEO),
     /* Ready/Valid interface for 24-bit pixel values */
     .Video(                     video),
     .VideoReady(                video_ready),
     .VideoValid(                video_valid)
    );
  `else
    assign DVI_D = 0;
    assign DVI_DE = 0;
    assign DVI_H = 0;
    assign DVI_V = 0;
    assign DVI_RESET_B = 1;
    assign DVI_XCLK_N = 0;
    assign DVI_XCLK_P = 0;
    assign IIC_SCL_VIDEO = 1;
    assign IIC_SDA_VIDEO = 1;
  `endif // DVI_ENABLE
  
  assign GPIO_LED = {~Reset, GPIO_SW_C, pll_lock, 5'b0};
endmodule
