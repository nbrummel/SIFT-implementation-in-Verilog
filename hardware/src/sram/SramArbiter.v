module SramArbiter(
  // Application interface
  input reset,

  // W0
  input         w0_clock,
  output        w0_din_ready,
  input         w0_din_valid,
  input [53:0]  w0_din,// {mask,addr,data}

  // W1
  input         w1_clock,
  output        w1_din_ready,
  input         w1_din_valid,
  input [53:0]  w1_din,// {mask,addr,data}

  // R0
  input         r0_clock,
  output        r0_din_ready,
  input         r0_din_valid,
  input  [17:0] r0_din, // addr
  input         r0_dout_ready,
  output        r0_dout_valid,
  output [31:0] r0_dout, // data

  // R1
  input         r1_clock,
  output        r1_din_ready,
  input         r1_din_valid,
  input  [17:0] r1_din, // addr
  input         r1_dout_ready,
  output        r1_dout_valid,
  output [31:0] r1_dout, // data

  // SRAM Interface
  input         sram_clock,
  output        sram_addr_valid,
  input         sram_ready,
  output [17:0] sram_addr,
  output [31:0] sram_data_in,
  output  [3:0] sram_write_mask,
  input  [31:0] sram_data_out,
  input         sram_data_out_valid);

// Clock crossing FIFOs --------------------------------------------------------

// The SRAM_WRITE_FIFOis have been instantiated for you, but you must wire it
// correctly

SRAM_WRITE_FIFO w0_fifo(
  .rst(),
  .wr_clk(),
  .din(),
  .wr_en(),
  .full(),

  .rd_clk(),
  .rd_en(),
  .valid(),
  .dout(),
  .empty());

SRAM_WRITE_FIFO w1_fifo(
  .rst(),
  .wr_clk(),
  .din(),
  .wr_en(),
  .full(),

  .rd_clk(),
  .rd_en(),
  .valid(),
  .dout(),
  .empty());

// Instantiate the Read FIFOs here

// Arbiter Logic ---------------------------------------------------------------

// Put your round-robin arbitration logic here

endmodule
