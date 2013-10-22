module SRAM (
  // Application interface
  input clock,
  input reset,

  input   addr_valid,
  output  ready,
  input      [17:0] addr,
  input      [31:0] data_in,
  input       [3:0] write_mask,
  output reg [31:0] data_out,
  output reg        data_out_valid,

  // Physical Interface
  input       sram_clk_fb,
  output      sram_clk,
  output      sram_cs_l,
  output      sram_we_l,
  output      sram_mode,
  output      sram_adv_ld_l,
  output      sram_oe_l,
  inout      [31:0] sram_data,
  output reg [17:0] sram_addr,
  output reg  [3:0] sram_bw_l);

  // Shift registers (number of "r"s indicates delay
  reg [31:0] data_in_r,data_in_rr,data_in_rrr;
  reg valid_r,valid_rr,valid_rrr;
  reg read_rr, read_rrr;
  
  assign sram_clk = clock;

  assign sram_cs_l = 0; // Always enable SRAM
  assign sram_mode = 0; // Mode is unused since we don't do burst reads
  assign sram_adv_ld_l = 0; // Advance/Load always asserted to output data
  assign sram_oe_l = 0; // Output enable always on, chip figures out drive
  assign ready = 1; // Always ready

  assign sram_we_l = &sram_bw_l; // Write if any bits asserted in mask

  // SRAM data is bidirectional, don't drive on write operation
  assign sram_data = read_rrr ? 32'dz : data_in_rrr;

  always @(posedge clock) begin
    if (reset) begin
      valid_r <= 0;
      valid_rr <= 0;
      valid_rrr <= 0;
      data_out_valid <= 0;
    end else begin
      // Register inputs and outputs to avoid combinational stackup
      data_out <= sram_data;
      sram_addr <= addr;
      sram_bw_l <= addr_valid ? ~write_mask : 4'hF;
      
      // Assign shift register levels
      {valid_r, data_in_r} <= {addr_valid,data_in};
      {valid_rr, read_rr, data_in_rr} <= {valid_r,sram_we_l,data_in_r};
      {valid_rrr, read_rrr, data_in_rrr} <= {valid_rr,read_rr,data_in_rr};
      data_out_valid <= valid_rrr & read_rrr;
    end
  end
endmodule
