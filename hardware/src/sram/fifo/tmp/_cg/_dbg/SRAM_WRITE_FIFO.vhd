--------------------------------------------------------------------------------
--    This file is owned and controlled by Xilinx and must be used solely     --
--    for design, simulation, implementation and creation of design files     --
--    limited to Xilinx devices or technologies. Use with non-Xilinx          --
--    devices or technologies is expressly prohibited and immediately         --
--    terminates your license.                                                --
--                                                                            --
--    XILINX IS PROVIDING THIS DESIGN, CODE, OR INFORMATION "AS IS" SOLELY    --
--    FOR USE IN DEVELOPING PROGRAMS AND SOLUTIONS FOR XILINX DEVICES.  BY    --
--    PROVIDING THIS DESIGN, CODE, OR INFORMATION AS ONE POSSIBLE             --
--    IMPLEMENTATION OF THIS FEATURE, APPLICATION OR STANDARD, XILINX IS      --
--    MAKING NO REPRESENTATION THAT THIS IMPLEMENTATION IS FREE FROM ANY      --
--    CLAIMS OF INFRINGEMENT, AND YOU ARE RESPONSIBLE FOR OBTAINING ANY       --
--    RIGHTS YOU MAY REQUIRE FOR YOUR IMPLEMENTATION.  XILINX EXPRESSLY       --
--    DISCLAIMS ANY WARRANTY WHATSOEVER WITH RESPECT TO THE ADEQUACY OF THE   --
--    IMPLEMENTATION, INCLUDING BUT NOT LIMITED TO ANY WARRANTIES OR          --
--    REPRESENTATIONS THAT THIS IMPLEMENTATION IS FREE FROM CLAIMS OF         --
--    INFRINGEMENT, IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A   --
--    PARTICULAR PURPOSE.                                                     --
--                                                                            --
--    Xilinx products are not intended for use in life support appliances,    --
--    devices, or systems.  Use in such applications are expressly            --
--    prohibited.                                                             --
--                                                                            --
--    (c) Copyright 1995-2013 Xilinx, Inc.                                    --
--    All rights reserved.                                                    --
--------------------------------------------------------------------------------

--------------------------------------------------------------------------------
--    Generated from core with identifier: xilinx.com:ip:fifo_generator:9.3   --
--                                                                            --
--    Rev 1. The FIFO Generator is a parameterizable first-in/first-out       --
--    memory queue generator. Use it to generate resource and performance     --
--    optimized FIFOs with common or independent read/write clock domains,    --
--    and optional fixed or programmable full and empty flags and             --
--    handshaking signals.  Choose from a selection of memory resource        --
--    types for implementation.  Optional Hamming code based error            --
--    detection and correction as well as error injection capability for      --
--    system test help to insure data integrity.  FIFO width and depth are    --
--    parameterizable, and for native interface FIFOs, asymmetric read and    --
--    write port widths are also supported.                                   --
--------------------------------------------------------------------------------
-- Source Code Wrapper
-- This file is provided to wrap around the source code (if appropriate)
-- and is designed for use with XST

-- Interfaces:
--   AXI4Stream_MASTER_M_AXIS
--   AXI4Stream_SLAVE_S_AXIS
--   AXI4_MASTER_M_AXI
--   AXI4_SLAVE_S_AXI
--   AXI4Lite_MASTER_M_AXI
--   AXI4Lite_SLAVE_S_AXI
--   master_aclk
--   slave_aclk
--   slave_aresetn

LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

LIBRARY fifo_generator_v9_3;
USE fifo_generator_v9_3.fifo_generator_v9_3;

ENTITY SRAM_WRITE_FIFO IS
  PORT (
    rst : IN STD_LOGIC;
    wr_clk : IN STD_LOGIC;
    rd_clk : IN STD_LOGIC;
    din : IN STD_LOGIC_VECTOR(53 DOWNTO 0);
    wr_en : IN STD_LOGIC;
    rd_en : IN STD_LOGIC;
    dout : OUT STD_LOGIC_VECTOR(53 DOWNTO 0);
    full : OUT STD_LOGIC;
    empty : OUT STD_LOGIC;
    valid : OUT STD_LOGIC
  );
END SRAM_WRITE_FIFO;

ARCHITECTURE virtex5 OF SRAM_WRITE_FIFO IS

  COMPONENT fifo_generator_v9_3 IS
    GENERIC (
      c_common_clock : INTEGER;
      c_count_type : INTEGER;
      c_data_count_width : INTEGER;
      c_default_value : STRING;
      c_din_width : INTEGER;
      c_dout_rst_val : STRING;
      c_dout_width : INTEGER;
      c_enable_rlocs : INTEGER;
      c_family : STRING;
      c_full_flags_rst_val : INTEGER;
      c_has_almost_empty : INTEGER;
      c_has_almost_full : INTEGER;
      c_has_backup : INTEGER;
      c_has_data_count : INTEGER;
      c_has_int_clk : INTEGER;
      c_has_meminit_file : INTEGER;
      c_has_overflow : INTEGER;
      c_has_rd_data_count : INTEGER;
      c_has_rd_rst : INTEGER;
      c_has_rst : INTEGER;
      c_has_srst : INTEGER;
      c_has_underflow : INTEGER;
      c_has_valid : INTEGER;
      c_has_wr_ack : INTEGER;
      c_has_wr_data_count : INTEGER;
      c_has_wr_rst : INTEGER;
      c_implementation_type : INTEGER;
      c_init_wr_pntr_val : INTEGER;
      c_memory_type : INTEGER;
      c_mif_file_name : STRING;
      c_optimization_mode : INTEGER;
      c_overflow_low : INTEGER;
      c_preload_latency : INTEGER;
      c_preload_regs : INTEGER;
      c_prim_fifo_type : STRING;
      c_prog_empty_thresh_assert_val : INTEGER;
      c_prog_empty_thresh_negate_val : INTEGER;
      c_prog_empty_type : INTEGER;
      c_prog_full_thresh_assert_val : INTEGER;
      c_prog_full_thresh_negate_val : INTEGER;
      c_prog_full_type : INTEGER;
      c_rd_data_count_width : INTEGER;
      c_rd_depth : INTEGER;
      c_rd_freq : INTEGER;
      c_rd_pntr_width : INTEGER;
      c_underflow_low : INTEGER;
      c_use_dout_rst : INTEGER;
      c_use_ecc : INTEGER;
      c_use_embedded_reg : INTEGER;
      c_use_fifo16_flags : INTEGER;
      c_use_fwft_data_count : INTEGER;
      c_valid_low : INTEGER;
      c_wr_ack_low : INTEGER;
      c_wr_data_count_width : INTEGER;
      c_wr_depth : INTEGER;
      c_wr_freq : INTEGER;
      c_wr_pntr_width : INTEGER;
      c_wr_response_latency : INTEGER;
      c_msgon_val : INTEGER;
      c_enable_rst_sync : INTEGER;
      c_error_injection_type : INTEGER;
      c_synchronizer_stage : INTEGER;
      c_interface_type : INTEGER;
      c_axi_type : INTEGER;
      c_has_axi_wr_channel : INTEGER;
      c_has_axi_rd_channel : INTEGER;
      c_has_slave_ce : INTEGER;
      c_has_master_ce : INTEGER;
      c_add_ngc_constraint : INTEGER;
      c_use_common_overflow : INTEGER;
      c_use_common_underflow : INTEGER;
      c_use_default_settings : INTEGER;
      c_axi_id_width : INTEGER;
      c_axi_addr_width : INTEGER;
      c_axi_data_width : INTEGER;
      c_has_axi_awuser : INTEGER;
      c_has_axi_wuser : INTEGER;
      c_has_axi_buser : INTEGER;
      c_has_axi_aruser : INTEGER;
      c_has_axi_ruser : INTEGER;
      c_axi_aruser_width : INTEGER;
      c_axi_awuser_width : INTEGER;
      c_axi_wuser_width : INTEGER;
      c_axi_buser_width : INTEGER;
      c_axi_ruser_width : INTEGER;
      c_has_axis_tdata : INTEGER;
      c_has_axis_tid : INTEGER;
      c_has_axis_tdest : INTEGER;
      c_has_axis_tuser : INTEGER;
      c_has_axis_tready : INTEGER;
      c_has_axis_tlast : INTEGER;
      c_has_axis_tstrb : INTEGER;
      c_has_axis_tkeep : INTEGER;
      c_axis_tdata_width : INTEGER;
      c_axis_tid_width : INTEGER;
      c_axis_tdest_width : INTEGER;
      c_axis_tuser_width : INTEGER;
      c_axis_tstrb_width : INTEGER;
      c_axis_tkeep_width : INTEGER;
      c_wach_type : INTEGER;
      c_wdch_type : INTEGER;
      c_wrch_type : INTEGER;
      c_rach_type : INTEGER;
      c_rdch_type : INTEGER;
      c_axis_type : INTEGER;
      c_implementation_type_wach : INTEGER;
      c_implementation_type_wdch : INTEGER;
      c_implementation_type_wrch : INTEGER;
      c_implementation_type_rach : INTEGER;
      c_implementation_type_rdch : INTEGER;
      c_implementation_type_axis : INTEGER;
      c_application_type_wach : INTEGER;
      c_application_type_wdch : INTEGER;
      c_application_type_wrch : INTEGER;
      c_application_type_rach : INTEGER;
      c_application_type_rdch : INTEGER;
      c_application_type_axis : INTEGER;
      c_use_ecc_wach : INTEGER;
      c_use_ecc_wdch : INTEGER;
      c_use_ecc_wrch : INTEGER;
      c_use_ecc_rach : INTEGER;
      c_use_ecc_rdch : INTEGER;
      c_use_ecc_axis : INTEGER;
      c_error_injection_type_wach : INTEGER;
      c_error_injection_type_wdch : INTEGER;
      c_error_injection_type_wrch : INTEGER;
      c_error_injection_type_rach : INTEGER;
      c_error_injection_type_rdch : INTEGER;
      c_error_injection_type_axis : INTEGER;
      c_din_width_wach : INTEGER;
      c_din_width_wdch : INTEGER;
      c_din_width_wrch : INTEGER;
      c_din_width_rach : INTEGER;
      c_din_width_rdch : INTEGER;
      c_din_width_axis : INTEGER;
      c_wr_depth_wach : INTEGER;
      c_wr_depth_wdch : INTEGER;
      c_wr_depth_wrch : INTEGER;
      c_wr_depth_rach : INTEGER;
      c_wr_depth_rdch : INTEGER;
      c_wr_depth_axis : INTEGER;
      c_wr_pntr_width_wach : INTEGER;
      c_wr_pntr_width_wdch : INTEGER;
      c_wr_pntr_width_wrch : INTEGER;
      c_wr_pntr_width_rach : INTEGER;
      c_wr_pntr_width_rdch : INTEGER;
      c_wr_pntr_width_axis : INTEGER;
      c_has_data_counts_wach : INTEGER;
      c_has_data_counts_wdch : INTEGER;
      c_has_data_counts_wrch : INTEGER;
      c_has_data_counts_rach : INTEGER;
      c_has_data_counts_rdch : INTEGER;
      c_has_data_counts_axis : INTEGER;
      c_has_prog_flags_wach : INTEGER;
      c_has_prog_flags_wdch : INTEGER;
      c_has_prog_flags_wrch : INTEGER;
      c_has_prog_flags_rach : INTEGER;
      c_has_prog_flags_rdch : INTEGER;
      c_has_prog_flags_axis : INTEGER;
      c_prog_full_type_wach : INTEGER;
      c_prog_full_type_wdch : INTEGER;
      c_prog_full_type_wrch : INTEGER;
      c_prog_full_type_rach : INTEGER;
      c_prog_full_type_rdch : INTEGER;
      c_prog_full_type_axis : INTEGER;
      c_prog_full_thresh_assert_val_wach : INTEGER;
      c_prog_full_thresh_assert_val_wdch : INTEGER;
      c_prog_full_thresh_assert_val_wrch : INTEGER;
      c_prog_full_thresh_assert_val_rach : INTEGER;
      c_prog_full_thresh_assert_val_rdch : INTEGER;
      c_prog_full_thresh_assert_val_axis : INTEGER;
      c_prog_empty_type_wach : INTEGER;
      c_prog_empty_type_wdch : INTEGER;
      c_prog_empty_type_wrch : INTEGER;
      c_prog_empty_type_rach : INTEGER;
      c_prog_empty_type_rdch : INTEGER;
      c_prog_empty_type_axis : INTEGER;
      c_prog_empty_thresh_assert_val_wach : INTEGER;
      c_prog_empty_thresh_assert_val_wdch : INTEGER;
      c_prog_empty_thresh_assert_val_wrch : INTEGER;
      c_prog_empty_thresh_assert_val_rach : INTEGER;
      c_prog_empty_thresh_assert_val_rdch : INTEGER;
      c_prog_empty_thresh_assert_val_axis : INTEGER;
      c_reg_slice_mode_wach : INTEGER;
      c_reg_slice_mode_wdch : INTEGER;
      c_reg_slice_mode_wrch : INTEGER;
      c_reg_slice_mode_rach : INTEGER;
      c_reg_slice_mode_rdch : INTEGER;
      c_reg_slice_mode_axis : INTEGER
    );
    PORT (
      rst : IN STD_LOGIC;
      wr_clk : IN STD_LOGIC;
      rd_clk : IN STD_LOGIC;
      din : IN STD_LOGIC_VECTOR(53 DOWNTO 0);
      wr_en : IN STD_LOGIC;
      rd_en : IN STD_LOGIC;
      dout : OUT STD_LOGIC_VECTOR(53 DOWNTO 0);
      full : OUT STD_LOGIC;
      empty : OUT STD_LOGIC;
      valid : OUT STD_LOGIC
    );
  END COMPONENT fifo_generator_v9_3;

  ATTRIBUTE X_CORE_INFO : STRING;
  ATTRIBUTE X_CORE_INFO OF virtex5 : ARCHITECTURE IS "fifo_generator_v9_3, Xilinx CORE Generator 14.6";

  ATTRIBUTE CHECK_LICENSE_TYPE : STRING;
  ATTRIBUTE CHECK_LICENSE_TYPE OF virtex5 : ARCHITECTURE IS "SRAM_WRITE_FIFO,fifo_generator_v9_3,{}";

  ATTRIBUTE CORE_GENERATION_INFO : STRING;
  ATTRIBUTE CORE_GENERATION_INFO OF virtex5 : ARCHITECTURE IS "SRAM_WRITE_FIFO,fifo_generator_v9_3,{c_add_ngc_constraint=0,c_application_type_axis=0,c_application_type_rach=0,c_application_type_rdch=0,c_application_type_wach=0,c_application_type_wdch=0,c_application_type_wrch=0,c_axi_addr_width=32,c_axi_aruser_width=1,c_axi_awuser_width=1,c_axi_buser_width=1,c_axi_data_width=64,c_axi_id_width=4,c_axi_ruser_width=1,c_axi_type=0,c_axi_wuser_width=1,c_axis_tdata_width=64,c_axis_tdest_width=4,c_axis_tid_width=8,c_axis_tkeep_width=4,c_axis_tstrb_width=4,c_axis_tuser_width=4,c_axis_type=0,c_common_clock=0,c_count_type=0,c_data_count_width=4,c_default_value=BlankString,c_din_width=54,c_din_width_axis=1,c_din_width_rach=32,c_din_width_rdch=64,c_din_width_wach=32,c_din_width_wdch=64,c_din_width_wrch=2,c_dout_rst_val=0,c_dout_width=54,c_enable_rlocs=0,c_enable_rst_sync=1,c_error_injection_type=0,c_error_injection_type_axis=0,c_error_injection_type_rach=0,c_error_injection_type_rdch=0,c_error_injection_type_wach=0,c_error_injection_type_wdch=0,c_error_injection_type_wrch=0,c_family=virtex5,c_full_flags_rst_val=1,c_has_almost_empty=0,c_has_almost_full=0,c_has_axi_aruser=0,c_has_axi_awuser=0,c_has_axi_buser=0,c_has_axi_rd_channel=0,c_has_axi_ruser=0,c_has_axi_wr_channel=0,c_has_axi_wuser=0,c_has_axis_tdata=0,c_has_axis_tdest=0,c_has_axis_tid=0,c_has_axis_tkeep=0,c_has_axis_tlast=0,c_has_axis_tready=1,c_has_axis_tstrb=0,c_has_axis_tuser=0,c_has_backup=0,c_has_data_count=0,c_has_data_counts_axis=0,c_has_data_counts_rach=0,c_has_data_counts_rdch=0,c_has_data_counts_wach=0,c_has_data_counts_wdch=0,c_has_data_counts_wrch=0,c_has_int_clk=0,c_has_master_ce=0,c_has_meminit_file=0,c_has_overflow=0,c_has_prog_flags_axis=0,c_has_prog_flags_rach=0,c_has_prog_flags_rdch=0,c_has_prog_flags_wach=0,c_has_prog_flags_wdch=0,c_has_prog_flags_wrch=0,c_has_rd_data_count=0,c_has_rd_rst=0,c_has_rst=1,c_has_slave_ce=0,c_has_srst=0,c_has_underflow=0,c_has_valid=1,c_has_wr_ack=0,c_has_wr_data_count=0,c_has_wr_rst=0,c_implementation_type=2,c_implementation_type_axis=1,c_implementation_type_rach=1,c_implementation_type_rdch=1,c_implementation_type_wach=1,c_implementation_type_wdch=1,c_implementation_type_wrch=1,c_init_wr_pntr_val=0,c_interface_type=0,c_memory_type=2,c_mif_file_name=BlankString,c_msgon_val=0,c_optimization_mode=0,c_overflow_low=0,c_preload_latency=0,c_preload_regs=1,c_prim_fifo_type=512x72,c_prog_empty_thresh_assert_val=4,c_prog_empty_thresh_assert_val_axis=1022,c_prog_empty_thresh_assert_val_rach=1022,c_prog_empty_thresh_assert_val_rdch=1022,c_prog_empty_thresh_assert_val_wach=1022,c_prog_empty_thresh_assert_val_wdch=1022,c_prog_empty_thresh_assert_val_wrch=1022,c_prog_empty_thresh_negate_val=5,c_prog_empty_type=0,c_prog_empty_type_axis=0,c_prog_empty_type_rach=0,c_prog_empty_type_rdch=0,c_prog_empty_type_wach=0,c_prog_empty_type_wdch=0,c_prog_empty_type_wrch=0,c_prog_full_thresh_assert_val=15,c_prog_full_thresh_assert_val_axis=1023,c_prog_full_thresh_assert_val_rach=1023,c_prog_full_thresh_assert_val_rdch=1023,c_prog_full_thresh_assert_val_wach=1023,c_prog_full_thresh_assert_val_wdch=1023,c_prog_full_thresh_assert_val_wrch=1023,c_prog_full_thresh_negate_val=14,c_prog_full_type=0,c_prog_full_type_axis=0,c_prog_full_type_rach=0,c_prog_full_type_rdch=0,c_prog_full_type_wach=0,c_prog_full_type_wdch=0,c_prog_full_type_wrch=0,c_rach_type=0,c_rd_data_count_width=4,c_rd_depth=16,c_rd_freq=1,c_rd_pntr_width=4,c_rdch_type=0,c_reg_slice_mode_axis=0,c_reg_slice_mode_rach=0,c_reg_slice_mode_rdch=0,c_reg_slice_mode_wach=0,c_reg_slice_mode_wdch=0,c_reg_slice_mode_wrch=0,c_synchronizer_stage=2,c_underflow_low=0,c_use_common_overflow=0,c_use_common_underflow=0,c_use_default_settings=0,c_use_dout_rst=0,c_use_ecc=0,c_use_ecc_axis=0,c_use_ecc_rach=0,c_use_ecc_rdch=0,c_use_ecc_wach=0,c_use_ecc_wdch=0,c_use_ecc_wrch=0,c_use_embedded_reg=0,c_use_fifo16_flags=0,c_use_fwft_data_count=0,c_valid_low=0,c_wach_type=0,c_wdch_type=0,c_wr_ack_low=0,c_wr_data_count_width=4,c_wr_depth=16,c_wr_depth_axis=1024,c_wr_depth_rach=16,c_wr_depth_rdch=1024,c_wr_depth_wach=16,c_wr_depth_wdch=1024,c_wr_depth_wrch=16,c_wr_freq=1,c_wr_pntr_width=4,c_wr_pntr_width_axis=10,c_wr_pntr_width_rach=4,c_wr_pntr_width_rdch=10,c_wr_pntr_width_wach=4,c_wr_pntr_width_wdch=10,c_wr_pntr_width_wrch=4,c_wr_response_latency=1,c_wrch_type=0}";

BEGIN

  U0 : fifo_generator_v9_3
    GENERIC MAP (
      c_add_ngc_constraint => 0,
      c_application_type_axis => 0,
      c_application_type_rach => 0,
      c_application_type_rdch => 0,
      c_application_type_wach => 0,
      c_application_type_wdch => 0,
      c_application_type_wrch => 0,
      c_axi_addr_width => 32,
      c_axi_aruser_width => 1,
      c_axi_awuser_width => 1,
      c_axi_buser_width => 1,
      c_axi_data_width => 64,
      c_axi_id_width => 4,
      c_axi_ruser_width => 1,
      c_axi_type => 0,
      c_axi_wuser_width => 1,
      c_axis_tdata_width => 64,
      c_axis_tdest_width => 4,
      c_axis_tid_width => 8,
      c_axis_tkeep_width => 4,
      c_axis_tstrb_width => 4,
      c_axis_tuser_width => 4,
      c_axis_type => 0,
      c_common_clock => 0,
      c_count_type => 0,
      c_data_count_width => 4,
      c_default_value => "BlankString",
      c_din_width => 54,
      c_din_width_axis => 1,
      c_din_width_rach => 32,
      c_din_width_rdch => 64,
      c_din_width_wach => 32,
      c_din_width_wdch => 64,
      c_din_width_wrch => 2,
      c_dout_rst_val => "0",
      c_dout_width => 54,
      c_enable_rlocs => 0,
      c_enable_rst_sync => 1,
      c_error_injection_type => 0,
      c_error_injection_type_axis => 0,
      c_error_injection_type_rach => 0,
      c_error_injection_type_rdch => 0,
      c_error_injection_type_wach => 0,
      c_error_injection_type_wdch => 0,
      c_error_injection_type_wrch => 0,
      c_family => "virtex5",
      c_full_flags_rst_val => 1,
      c_has_almost_empty => 0,
      c_has_almost_full => 0,
      c_has_axi_aruser => 0,
      c_has_axi_awuser => 0,
      c_has_axi_buser => 0,
      c_has_axi_rd_channel => 0,
      c_has_axi_ruser => 0,
      c_has_axi_wr_channel => 0,
      c_has_axi_wuser => 0,
      c_has_axis_tdata => 0,
      c_has_axis_tdest => 0,
      c_has_axis_tid => 0,
      c_has_axis_tkeep => 0,
      c_has_axis_tlast => 0,
      c_has_axis_tready => 1,
      c_has_axis_tstrb => 0,
      c_has_axis_tuser => 0,
      c_has_backup => 0,
      c_has_data_count => 0,
      c_has_data_counts_axis => 0,
      c_has_data_counts_rach => 0,
      c_has_data_counts_rdch => 0,
      c_has_data_counts_wach => 0,
      c_has_data_counts_wdch => 0,
      c_has_data_counts_wrch => 0,
      c_has_int_clk => 0,
      c_has_master_ce => 0,
      c_has_meminit_file => 0,
      c_has_overflow => 0,
      c_has_prog_flags_axis => 0,
      c_has_prog_flags_rach => 0,
      c_has_prog_flags_rdch => 0,
      c_has_prog_flags_wach => 0,
      c_has_prog_flags_wdch => 0,
      c_has_prog_flags_wrch => 0,
      c_has_rd_data_count => 0,
      c_has_rd_rst => 0,
      c_has_rst => 1,
      c_has_slave_ce => 0,
      c_has_srst => 0,
      c_has_underflow => 0,
      c_has_valid => 1,
      c_has_wr_ack => 0,
      c_has_wr_data_count => 0,
      c_has_wr_rst => 0,
      c_implementation_type => 2,
      c_implementation_type_axis => 1,
      c_implementation_type_rach => 1,
      c_implementation_type_rdch => 1,
      c_implementation_type_wach => 1,
      c_implementation_type_wdch => 1,
      c_implementation_type_wrch => 1,
      c_init_wr_pntr_val => 0,
      c_interface_type => 0,
      c_memory_type => 2,
      c_mif_file_name => "BlankString",
      c_msgon_val => 0,
      c_optimization_mode => 0,
      c_overflow_low => 0,
      c_preload_latency => 0,
      c_preload_regs => 1,
      c_prim_fifo_type => "512x72",
      c_prog_empty_thresh_assert_val => 4,
      c_prog_empty_thresh_assert_val_axis => 1022,
      c_prog_empty_thresh_assert_val_rach => 1022,
      c_prog_empty_thresh_assert_val_rdch => 1022,
      c_prog_empty_thresh_assert_val_wach => 1022,
      c_prog_empty_thresh_assert_val_wdch => 1022,
      c_prog_empty_thresh_assert_val_wrch => 1022,
      c_prog_empty_thresh_negate_val => 5,
      c_prog_empty_type => 0,
      c_prog_empty_type_axis => 0,
      c_prog_empty_type_rach => 0,
      c_prog_empty_type_rdch => 0,
      c_prog_empty_type_wach => 0,
      c_prog_empty_type_wdch => 0,
      c_prog_empty_type_wrch => 0,
      c_prog_full_thresh_assert_val => 15,
      c_prog_full_thresh_assert_val_axis => 1023,
      c_prog_full_thresh_assert_val_rach => 1023,
      c_prog_full_thresh_assert_val_rdch => 1023,
      c_prog_full_thresh_assert_val_wach => 1023,
      c_prog_full_thresh_assert_val_wdch => 1023,
      c_prog_full_thresh_assert_val_wrch => 1023,
      c_prog_full_thresh_negate_val => 14,
      c_prog_full_type => 0,
      c_prog_full_type_axis => 0,
      c_prog_full_type_rach => 0,
      c_prog_full_type_rdch => 0,
      c_prog_full_type_wach => 0,
      c_prog_full_type_wdch => 0,
      c_prog_full_type_wrch => 0,
      c_rach_type => 0,
      c_rd_data_count_width => 4,
      c_rd_depth => 16,
      c_rd_freq => 1,
      c_rd_pntr_width => 4,
      c_rdch_type => 0,
      c_reg_slice_mode_axis => 0,
      c_reg_slice_mode_rach => 0,
      c_reg_slice_mode_rdch => 0,
      c_reg_slice_mode_wach => 0,
      c_reg_slice_mode_wdch => 0,
      c_reg_slice_mode_wrch => 0,
      c_synchronizer_stage => 2,
      c_underflow_low => 0,
      c_use_common_overflow => 0,
      c_use_common_underflow => 0,
      c_use_default_settings => 0,
      c_use_dout_rst => 0,
      c_use_ecc => 0,
      c_use_ecc_axis => 0,
      c_use_ecc_rach => 0,
      c_use_ecc_rdch => 0,
      c_use_ecc_wach => 0,
      c_use_ecc_wdch => 0,
      c_use_ecc_wrch => 0,
      c_use_embedded_reg => 0,
      c_use_fifo16_flags => 0,
      c_use_fwft_data_count => 0,
      c_valid_low => 0,
      c_wach_type => 0,
      c_wdch_type => 0,
      c_wr_ack_low => 0,
      c_wr_data_count_width => 4,
      c_wr_depth => 16,
      c_wr_depth_axis => 1024,
      c_wr_depth_rach => 16,
      c_wr_depth_rdch => 1024,
      c_wr_depth_wach => 16,
      c_wr_depth_wdch => 1024,
      c_wr_depth_wrch => 16,
      c_wr_freq => 1,
      c_wr_pntr_width => 4,
      c_wr_pntr_width_axis => 10,
      c_wr_pntr_width_rach => 4,
      c_wr_pntr_width_rdch => 10,
      c_wr_pntr_width_wach => 4,
      c_wr_pntr_width_wdch => 10,
      c_wr_pntr_width_wrch => 4,
      c_wr_response_latency => 1,
      c_wrch_type => 0
    )
    PORT MAP (
      rst => rst,
      wr_clk => wr_clk,
      rd_clk => rd_clk,
      din => din,
      wr_en => wr_en,
      rd_en => rd_en,
      dout => dout,
      full => full,
      empty => empty,
      valid => valid
    );

END virtex5;
