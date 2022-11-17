//-----------------------------------------------
// Space Cubics SC-OBC-A1 FPGA
//  Testcase: Check SRAM Controller
//-----------------------------------------------
// Copyright © 2022 Space Cubics, LLC.
//-----------------------------------------------

`timescale 1ps/1ps

module tb_top;

parameter TB_SRAM_ENABLE = 0;
parameter TB_CFG_MEM1_ENABLE = 0;
parameter TB_CFG_MEM2_ENABLE = 0;
parameter TB_DATA_MEM1_ENABLE = 0;
parameter TB_DATA_MEM2_ENABLE = 0;
parameter TB_FRAM1_ENABLE = 0;
parameter TB_FRAM2_ENABLE = 0;

`include "tb_top_main.vh"
`include "sc_verification_task_pkg.vh"
`include "sc_obc_a1_fpga_task.vh"
`include "scvip_ahb_master_pkg.vh"
`include "dut_register_map.vh"

reg [31:0] boot_data_in = 0;
integer i;

wire internal_sig = 0;
wire external_sig = 0;
reg mode00_en = 0;
reg mode01_en = 0;

task GPIO_CTRL_CHK;
  input [31:0] gpio_ctrl_adr;
  input [31:0] gpio_moni_adr;
  input [4:0]  moni_bit;
  input        mode00_nochk_flg;
begin
  if (~mode00_nochk_flg) begin
    // GPIO Mode == 0b00
    mode00_en = 1;
    write_transaction(.master(2), .addr(gpio_ctrl_adr), .data(32'h0000_0000));
    read_transaction( .master(2), .addr(gpio_ctrl_adr), .expdata(32'h0000_0000), .check(1));
    force internal_sig = 1'b1;
    repeat (3) @ (posedge SYS_CLK);
    read_transaction( .master(2), .addr(gpio_moni_adr), .expdata(32'h0000_0000 | (1 << moni_bit)), .check(1));
    force internal_sig = 0;
    repeat (3) @ (posedge SYS_CLK);
    read_transaction( .master(2), .addr(gpio_moni_adr), .expdata(32'h0000_0000), .check(1));
    release internal_sig;
    repeat (3) @ (posedge SYS_CLK);
    mode00_en = 0;
    @ (posedge SYS_CLK);
  end
  // GPIO Mode == 0b01
  mode01_en = 1;
  write_transaction(.master(2), .addr(gpio_ctrl_adr), .data(32'h0000_0001));
  read_transaction( .master(2), .addr(gpio_ctrl_adr), .expdata(32'h0000_0001), .check(1));
  force external_sig = 1'b1;
  repeat (3) @ (posedge SYS_CLK);
  read_transaction( .master(2), .addr(gpio_moni_adr), .expdata(32'h0000_0000 | (1 << moni_bit)), .check(1));
  force external_sig = 0;
  repeat (3) @ (posedge SYS_CLK);
  read_transaction( .master(2), .addr(gpio_moni_adr), .expdata(32'h0000_0000), .check(1));
  release external_sig;
  repeat (3) @ (posedge SYS_CLK);
  mode01_en = 0;
  // GPIO Mode == 0b10
  write_transaction(.master(2), .addr(gpio_ctrl_adr), .data(32'h0000_0002));
  read_transaction( .master(2), .addr(gpio_ctrl_adr), .expdata(32'h0000_0002), .check(1));
  read_transaction( .master(2), .addr(gpio_moni_adr), .expdata(32'h0000_0000), .check(1));
  // GPIO Mode == 0b11
  write_transaction(.master(2), .addr(gpio_ctrl_adr), .data(32'h0000_0003));
  read_transaction( .master(2), .addr(gpio_ctrl_adr), .expdata(32'h0000_0003), .check(1));
  read_transaction( .master(2), .addr(gpio_moni_adr), .expdata(32'h0000_0000 | (1 << moni_bit)), .check(1));
  write_transaction(.master(2), .addr(gpio_ctrl_adr), .data(32'h0000_0002));
  read_transaction( .master(2), .addr(gpio_moni_adr), .expdata(32'h0000_0000), .check(1));
end
endtask

assign testcase_name = "Check Debug Controller";
initial begin
  timeout_ms = 5;
  @ (posedge SYS_RSTB);

  //--------------------------------------------------
  label    = "Boot System";
  simcount = 0;
  //--------------------------------------------------
  @ (posedge CMC_REQ);
  @ (posedge CMC_ACK);
  @ (posedge PLLLOCK);
  @ (negedge CMC_REQ);
  @ (negedge CMC_ACK);
  display_text("SC-OBC-CORE System Bootup Done", 1, 1);

  //--------------------------------------------------
  label    = "Debug Register Initial Value Check ";
  simcount = 1;
  //--------------------------------------------------
  @(posedge SYS_CLK);
  display_subcount_text(1, "SRAM I/F", 1);
  read_transaction( .master(2), .addr(`DEBUG_BASE+16'h0000), .expdata(32'h0000_0000), .check(1));
  read_transaction( .master(2), .addr(`DEBUG_BASE+16'h0004), .expdata(32'h0000_0000), .check(1));
  read_transaction( .master(2), .addr(`DEBUG_BASE+16'h0008), .expdata(32'h0000_0000), .check(1));
  read_transaction( .master(2), .addr(`DEBUG_BASE+16'h000C), .expdata(32'h0000_0000), .check(1));
  read_transaction( .master(2), .addr(`DEBUG_BASE+16'h0010), .expdata(32'h0000_0000), .check(1));
  read_transaction( .master(2), .addr(`DEBUG_BASE+16'h0014), .expdata(32'h0000_0000), .check(1));
  read_transaction( .master(2), .addr(`DEBUG_BASE+16'h0018), .expdata(32'h0000_0000), .check(1));
  read_transaction( .master(2), .addr(`DEBUG_BASE+16'h001C), .expdata(32'h0000_0000), .check(1));
  read_transaction( .master(2), .addr(`DEBUG_BASE+16'h0020), .expdata(32'h0000_0000), .check(1));
  read_transaction( .master(2), .addr(`DEBUG_BASE+16'h0024), .expdata(32'h0000_0000), .check(1));
  read_transaction( .master(2), .addr(`DEBUG_BASE+16'h0028), .expdata(32'h0000_0000), .check(1));
  read_transaction( .master(2), .addr(`DEBUG_BASE+16'h002C), .expdata(32'h0000_0000), .check(1));
  read_transaction( .master(2), .addr(`DEBUG_BASE+16'h0030), .expdata(32'h0000_0000), .check(1));
  read_transaction( .master(2), .addr(`DEBUG_BASE+16'h0034), .expdata(32'h0000_0000), .check(1));
  read_transaction( .master(2), .addr(`DEBUG_BASE+16'h0038), .expdata(32'h0000_0000), .check(1));
  read_transaction( .master(2), .addr(`DEBUG_BASE+16'h003C), .expdata(32'h0000_0000), .check(1));
  read_transaction( .master(2), .addr(`DEBUG_BASE+16'h0040), .expdata(32'h0000_0000), .check(1));
  read_transaction( .master(2), .addr(`DEBUG_BASE+16'h0044), .expdata(32'h0000_0000), .check(1));
  read_transaction( .master(2), .addr(`DEBUG_BASE+16'h0048), .expdata(32'h0000_0000), .check(1));
  read_transaction( .master(2), .addr(`DEBUG_BASE+16'h004C), .expdata(32'h0000_0000), .check(1));
  read_transaction( .master(2), .addr(`DEBUG_BASE+16'h0050), .expdata(32'h0000_0000), .check(1));
  read_transaction( .master(2), .addr(`DEBUG_BASE+16'h0054), .expdata(32'h0000_0000), .check(1));
  read_transaction( .master(2), .addr(`DEBUG_BASE+16'h0058), .expdata(32'h0000_0000), .check(1));
  read_transaction( .master(2), .addr(`DEBUG_BASE+16'h005C), .expdata(32'h0000_0000), .check(1));
  read_transaction( .master(2), .addr(`DEBUG_BASE+16'h0060), .expdata(32'h0000_0000), .check(1));
  read_transaction( .master(2), .addr(`DEBUG_BASE+16'h0064), .expdata(32'h0000_0000), .check(1));
  read_transaction( .master(2), .addr(`DEBUG_BASE+16'h0068), .expdata(32'h0000_0000), .check(1));
  read_transaction( .master(2), .addr(`DEBUG_BASE+16'h006C), .expdata(32'h0000_0000), .check(1));
  read_transaction( .master(2), .addr(`DEBUG_BASE+16'h0070), .expdata(32'h0000_0000), .check(1));
  read_transaction( .master(2), .addr(`DEBUG_BASE+16'h0074), .expdata(32'h0000_0000), .check(1));
  read_transaction( .master(2), .addr(`DEBUG_BASE+16'h0078), .expdata(32'h0000_03FF), .check(1));
  display_subcount_text(2, "QSPI I/F(CFG Flash)", 1);
  read_transaction( .master(2), .addr(`DEBUG_BASE+16'h0100), .expdata(32'h0000_0000), .check(1));
  read_transaction( .master(2), .addr(`DEBUG_BASE+16'h0104), .expdata(32'h0000_0000), .check(1));
  read_transaction( .master(2), .addr(`DEBUG_BASE+16'h0108), .expdata(32'h0000_0000), .check(1));
  read_transaction( .master(2), .addr(`DEBUG_BASE+16'h010C), .expdata(32'h0000_0000), .check(1));
  read_transaction( .master(2), .addr(`DEBUG_BASE+16'h0110), .expdata(32'h0000_0000), .check(1));
  read_transaction( .master(2), .addr(`DEBUG_BASE+16'h0114), .expdata(32'h0000_001F), .check(1));
  display_subcount_text(3, "QSPI I/F(DATA Flash)", 1);
  read_transaction( .master(2), .addr(`DEBUG_BASE+16'h0200), .expdata(32'h0000_0000), .check(1));
  read_transaction( .master(2), .addr(`DEBUG_BASE+16'h0204), .expdata(32'h0000_0000), .check(1));
  read_transaction( .master(2), .addr(`DEBUG_BASE+16'h0208), .expdata(32'h0000_0000), .check(1));
  read_transaction( .master(2), .addr(`DEBUG_BASE+16'h020C), .expdata(32'h0000_0000), .check(1));
  read_transaction( .master(2), .addr(`DEBUG_BASE+16'h0210), .expdata(32'h0000_0000), .check(1));
  read_transaction( .master(2), .addr(`DEBUG_BASE+16'h0214), .expdata(32'h0000_0000), .check(1));
  read_transaction( .master(2), .addr(`DEBUG_BASE+16'h0218), .expdata(32'h0000_0000), .check(1));
  read_transaction( .master(2), .addr(`DEBUG_BASE+16'h021C), .expdata(32'h0000_0000), .check(1));
  read_transaction( .master(2), .addr(`DEBUG_BASE+16'h0220), .expdata(32'h0000_0000), .check(1));
  read_transaction( .master(2), .addr(`DEBUG_BASE+16'h0224), .expdata(32'h0000_0000), .check(1));
  read_transaction( .master(2), .addr(`DEBUG_BASE+16'h0228), .expdata(32'h0000_03FF), .check(1));
  display_subcount_text(4, "QSPI I/F(FRAM)", 1);
  read_transaction( .master(2), .addr(`DEBUG_BASE+16'h0300), .expdata(32'h0000_0000), .check(1));
  read_transaction( .master(2), .addr(`DEBUG_BASE+16'h0304), .expdata(32'h0000_0000), .check(1));
  read_transaction( .master(2), .addr(`DEBUG_BASE+16'h0308), .expdata(32'h0000_0000), .check(1));
  read_transaction( .master(2), .addr(`DEBUG_BASE+16'h030C), .expdata(32'h0000_0000), .check(1));
  read_transaction( .master(2), .addr(`DEBUG_BASE+16'h0310), .expdata(32'h0000_0000), .check(1));
  read_transaction( .master(2), .addr(`DEBUG_BASE+16'h0314), .expdata(32'h0000_0000), .check(1));
  read_transaction( .master(2), .addr(`DEBUG_BASE+16'h0318), .expdata(32'h0000_0000), .check(1));
  read_transaction( .master(2), .addr(`DEBUG_BASE+16'h031C), .expdata(32'h0000_0000), .check(1));
  read_transaction( .master(2), .addr(`DEBUG_BASE+16'h0320), .expdata(32'h0000_0000), .check(1));
  read_transaction( .master(2), .addr(`DEBUG_BASE+16'h0324), .expdata(32'h0000_0000), .check(1));
  read_transaction( .master(2), .addr(`DEBUG_BASE+16'h0328), .expdata(32'h0000_03FF), .check(1));
  display_subcount_text(5, "OSC I/F", 1);
  read_transaction( .master(2), .addr(`DEBUG_BASE+16'h0400), .expdata(32'h0000_0003), .check(1));
  display_subcount_text(6, "INT I2C I/F", 1);
  read_transaction( .master(2), .addr(`DEBUG_BASE+16'h0500), .expdata(32'h0000_0007), .check(1));
  display_subcount_text(7, "EXT I2C I/F", 1);
  read_transaction( .master(2), .addr(`DEBUG_BASE+16'h0600), .expdata(32'h0000_0003), .check(1));
  read_transaction( .master(2), .addr(`DEBUG_BASE+16'h0604), .expdata(32'h0000_0001), .check(1));
  read_transaction( .master(2), .addr(`DEBUG_BASE+16'h0608), .expdata(32'h0000_0003), .check(1));
  display_subcount_text(8, "TRCH I/F", 1);
  read_transaction( .master(2), .addr(`DEBUG_BASE+16'h0704), .expdata(32'h0000_0000), .check(1));
  read_transaction( .master(2), .addr(`DEBUG_BASE+16'h0708), .expdata(32'h0000_0000), .check(1));
  read_transaction( .master(2), .addr(`DEBUG_BASE+16'h070C), .expdata(32'h0000_0001), .check(1));
  read_transaction( .master(2), .addr(`DEBUG_BASE+16'h0710), .expdata(32'h0000_0001), .check(1));
  display_subcount_text(9, "ULPI I/F", 1);
  read_transaction( .master(2), .addr(`DEBUG_BASE+16'h0800), .expdata(32'h0000_0001), .check(1));
  read_transaction( .master(2), .addr(`DEBUG_BASE+16'h0804), .expdata(32'h0000_0003), .check(1));
  read_transaction( .master(2), .addr(`DEBUG_BASE+16'h0808), .expdata(32'h0000_0002), .check(1));
  read_transaction( .master(2), .addr(`DEBUG_BASE+16'h080C), .expdata(32'h0000_0002), .check(1));
  display_subcount_text(10, "FPGA Config I/F", 1);
  read_transaction( .master(2), .addr(`DEBUG_BASE+16'h0B00), .expdata(32'h0000_0001), .check(1));
  display_subcount_text(11, "UIO1 I/F", 1);
  read_transaction( .master(2), .addr(`DEBUG_BASE+16'h0C00), .expdata(32'h0000_0002), .check(1));
  read_transaction( .master(2), .addr(`DEBUG_BASE+16'h0C04), .expdata(32'h0000_0002), .check(1));
  read_transaction( .master(2), .addr(`DEBUG_BASE+16'h0C08), .expdata(32'h0000_0002), .check(1));
  read_transaction( .master(2), .addr(`DEBUG_BASE+16'h0C0C), .expdata(32'h0000_0002), .check(1));
  read_transaction( .master(2), .addr(`DEBUG_BASE+16'h0C10), .expdata(32'h0000_0002), .check(1));
  read_transaction( .master(2), .addr(`DEBUG_BASE+16'h0C14), .expdata(32'h0000_0002), .check(1));
  read_transaction( .master(2), .addr(`DEBUG_BASE+16'h0C18), .expdata(32'h0000_0002), .check(1));
  read_transaction( .master(2), .addr(`DEBUG_BASE+16'h0C1C), .expdata(32'h0000_0002), .check(1));
  read_transaction( .master(2), .addr(`DEBUG_BASE+16'h0C20), .expdata(32'h0000_0002), .check(1));
  read_transaction( .master(2), .addr(`DEBUG_BASE+16'h0C24), .expdata(32'h0000_0002), .check(1));
  read_transaction( .master(2), .addr(`DEBUG_BASE+16'h0C28), .expdata(32'h0000_0002), .check(1));
  read_transaction( .master(2), .addr(`DEBUG_BASE+16'h0C2C), .expdata(32'h0000_0002), .check(1));
  read_transaction( .master(2), .addr(`DEBUG_BASE+16'h0C30), .expdata(32'h0000_0002), .check(1));
  read_transaction( .master(2), .addr(`DEBUG_BASE+16'h0C34), .expdata(32'h0000_0002), .check(1));
  read_transaction( .master(2), .addr(`DEBUG_BASE+16'h0C38), .expdata(32'h0000_0002), .check(1));
  read_transaction( .master(2), .addr(`DEBUG_BASE+16'h0C3C), .expdata(32'h0000_0002), .check(1));
  read_transaction( .master(2), .addr(`DEBUG_BASE+16'h0C40), .expdata(32'h0000_0000), .check(1));
  display_subcount_text(12, "UIO2 I/F", 1);
  read_transaction( .master(2), .addr(`DEBUG_BASE+16'h0D00), .expdata(32'h0000_0001), .check(1));
  read_transaction( .master(2), .addr(`DEBUG_BASE+16'h0D04), .expdata(32'h0000_0001), .check(1));
  read_transaction( .master(2), .addr(`DEBUG_BASE+16'h0D08), .expdata(32'h0000_0001), .check(1));
  read_transaction( .master(2), .addr(`DEBUG_BASE+16'h0D0C), .expdata(32'h0000_0001), .check(1));
  read_transaction( .master(2), .addr(`DEBUG_BASE+16'h0D10), .expdata(32'h0000_0001), .check(1));
  read_transaction( .master(2), .addr(`DEBUG_BASE+16'h0D14), .expdata(32'h0000_0001), .check(1));
  read_transaction( .master(2), .addr(`DEBUG_BASE+16'h0D18), .expdata(32'h0000_0001), .check(1));
  read_transaction( .master(2), .addr(`DEBUG_BASE+16'h0D1C), .expdata(32'h0000_0001), .check(1));
  read_transaction( .master(2), .addr(`DEBUG_BASE+16'h0D20), .expdata(32'h0000_0001), .check(1));
  read_transaction( .master(2), .addr(`DEBUG_BASE+16'h0D24), .expdata(32'h0000_0001), .check(1));
  read_transaction( .master(2), .addr(`DEBUG_BASE+16'h0D28), .expdata(32'h0000_0001), .check(1));
  read_transaction( .master(2), .addr(`DEBUG_BASE+16'h0D2C), .expdata(32'h0000_0001), .check(1));
  read_transaction( .master(2), .addr(`DEBUG_BASE+16'h0D30), .expdata(32'h0000_0001), .check(1));
  read_transaction( .master(2), .addr(`DEBUG_BASE+16'h0D34), .expdata(32'h0000_0001), .check(1));
  read_transaction( .master(2), .addr(`DEBUG_BASE+16'h0D38), .expdata(32'h0000_0001), .check(1));
  read_transaction( .master(2), .addr(`DEBUG_BASE+16'h0D3C), .expdata(32'h0000_0001), .check(1));
  read_transaction( .master(2), .addr(`DEBUG_BASE+16'h0D40), .expdata(32'h0000_0000), .check(1));
  display_subcount_text(13, "UIO4 I/F", 1);
  read_transaction( .master(2), .addr(`DEBUG_BASE+16'h0E00), .expdata(32'h0000_0002), .check(1));
  read_transaction( .master(2), .addr(`DEBUG_BASE+16'h0E04), .expdata(32'h0000_0002), .check(1));
  read_transaction( .master(2), .addr(`DEBUG_BASE+16'h0E08), .expdata(32'h0000_0002), .check(1));
  read_transaction( .master(2), .addr(`DEBUG_BASE+16'h0E0C), .expdata(32'h0000_0001), .check(1));
  read_transaction( .master(2), .addr(`DEBUG_BASE+16'h0E10), .expdata(32'h0000_0001), .check(1));
  read_transaction( .master(2), .addr(`DEBUG_BASE+16'h0E14), .expdata(32'h0000_0001), .check(1));
  read_transaction( .master(2), .addr(`DEBUG_BASE+16'h0E18), .expdata(32'h0000_0000), .check(1));
  display_subcount_text(14, "RSV I/F", 1);
  read_transaction( .master(2), .addr(`DEBUG_BASE+16'h0F00), .expdata(32'h0000_0000), .check(1));
  read_transaction( .master(2), .addr(`DEBUG_BASE+16'h0F04), .expdata(32'h0000_0000), .check(1));
  read_transaction( .master(2), .addr(`DEBUG_BASE+16'h0F08), .expdata(32'h0000_0000), .check(1));
  read_transaction( .master(2), .addr(`DEBUG_BASE+16'h0F0C), .expdata(32'h0000_0000), .check(1));
  read_transaction( .master(2), .addr(`DEBUG_BASE+16'h0F10), .expdata(32'h0000_0000), .check(1));
  read_transaction( .master(2), .addr(`DEBUG_BASE+16'h0F14), .expdata(32'h0000_0000), .check(1));
  read_transaction( .master(2), .addr(`DEBUG_BASE+16'h0F18), .expdata(32'h0000_0000), .check(1));
  read_transaction( .master(2), .addr(`DEBUG_BASE+16'h0F1C), .expdata(32'h0000_0000), .check(1));
  read_transaction( .master(2), .addr(`DEBUG_BASE+16'h0F20), .expdata(32'h0000_0000), .check(1));
  read_transaction( .master(2), .addr(`DEBUG_BASE+16'h0F24), .expdata(32'h0000_0000), .check(1));
  read_transaction( .master(2), .addr(`DEBUG_BASE+16'h0F28), .expdata(32'h0000_0000), .check(1));
  read_transaction( .master(2), .addr(`DEBUG_BASE+16'h0F2C), .expdata(32'h0000_0000), .check(1));
  read_transaction( .master(2), .addr(`DEBUG_BASE+16'h0F30), .expdata(32'h0000_0000), .check(1));
  read_transaction( .master(2), .addr(`DEBUG_BASE+16'h0F34), .expdata(32'h0000_0000), .check(1));
  read_transaction( .master(2), .addr(`DEBUG_BASE+16'h0F38), .expdata(32'h0000_0000), .check(1));
  read_transaction( .master(2), .addr(`DEBUG_BASE+16'h0F3C), .expdata(32'h0000_0000), .check(1));
  read_transaction( .master(2), .addr(`DEBUG_BASE+16'h0F40), .expdata(32'h0000_0000), .check(1));

  //--------------------------------------------------
  label    = "SRAM I/F Control Check ";
  simcount = 2;
  //--------------------------------------------------
  @(posedge SYS_CLK);
  display_subcount_text(1, "ALL '0' Output", 1);
  write_transaction(.master(2), .addr(`DEBUG_BASE+16'h0000), .data(32'h0000_0002));
  write_transaction(.master(2), .addr(`DEBUG_BASE+16'h0004), .data(32'h0000_0002));
  write_transaction(.master(2), .addr(`DEBUG_BASE+16'h0008), .data(32'h0000_0002));
  write_transaction(.master(2), .addr(`DEBUG_BASE+16'h000C), .data(32'h0000_0002));
  write_transaction(.master(2), .addr(`DEBUG_BASE+16'h0010), .data(32'h0000_0002));
  write_transaction(.master(2), .addr(`DEBUG_BASE+16'h0014), .data(32'h0000_0002));
  write_transaction(.master(2), .addr(`DEBUG_BASE+16'h0018), .data(32'h0000_0002));
  write_transaction(.master(2), .addr(`DEBUG_BASE+16'h001C), .data(32'h0000_0002));
  write_transaction(.master(2), .addr(`DEBUG_BASE+16'h0020), .data(32'h0000_0002));
  write_transaction(.master(2), .addr(`DEBUG_BASE+16'h0024), .data(32'h0000_0002));
  write_transaction(.master(2), .addr(`DEBUG_BASE+16'h0028), .data(32'h0000_0002));
  write_transaction(.master(2), .addr(`DEBUG_BASE+16'h002C), .data(32'h0000_0002));
  write_transaction(.master(2), .addr(`DEBUG_BASE+16'h0030), .data(32'h0000_0002));
  write_transaction(.master(2), .addr(`DEBUG_BASE+16'h0034), .data(32'h0000_0002));
  write_transaction(.master(2), .addr(`DEBUG_BASE+16'h0038), .data(32'h0000_0002));
  write_transaction(.master(2), .addr(`DEBUG_BASE+16'h003C), .data(32'h0000_0002));
  write_transaction(.master(2), .addr(`DEBUG_BASE+16'h0040), .data(32'h0000_0002));
  write_transaction(.master(2), .addr(`DEBUG_BASE+16'h0044), .data(32'h0000_0002));
  write_transaction(.master(2), .addr(`DEBUG_BASE+16'h0048), .data(32'h0000_0002));
  write_transaction(.master(2), .addr(`DEBUG_BASE+16'h004C), .data(32'h0000_0002));
  write_transaction(.master(2), .addr(`DEBUG_BASE+16'h0050), .data(32'h0000_0002));
  write_transaction(.master(2), .addr(`DEBUG_BASE+16'h0054), .data(32'h0000_0002));
  write_transaction(.master(2), .addr(`DEBUG_BASE+16'h0058), .data(32'h0000_0002));
  write_transaction(.master(2), .addr(`DEBUG_BASE+16'h005C), .data(32'h0000_0002));
  write_transaction(.master(2), .addr(`DEBUG_BASE+16'h0060), .data(32'h0000_0002));
  write_transaction(.master(2), .addr(`DEBUG_BASE+16'h0064), .data(32'h0000_0002));
  write_transaction(.master(2), .addr(`DEBUG_BASE+16'h0068), .data(32'h0000_0002));
  write_transaction(.master(2), .addr(`DEBUG_BASE+16'h006C), .data(32'h0000_0002));
  write_transaction(.master(2), .addr(`DEBUG_BASE+16'h0070), .data(32'h0000_0002));
  write_transaction(.master(2), .addr(`DEBUG_BASE+16'h0074), .data(32'h0000_0002));
  read_transaction( .master(2), .addr(`DEBUG_BASE+16'h0078), .expdata(32'h0000_0000), .check(1));

  display_subcount_text(2, "SRAM_A Control", 1);
  for(i=0; i<20; i=i+1) begin
    fork
      begin
        @(posedge mode00_en); force dut.obc_core.SRAM_A = internal_sig << (19-i);
        @(negedge mode00_en); release dut.obc_core.SRAM_A;
        @(posedge mode01_en); force sram_a = external_sig << (19-i);
        @(negedge mode01_en); release sram_a;
      end
                 // gpio_ctrl_adr                  gpio_moni_adr         moni_bit  mode00_nochk_flg
      GPIO_CTRL_CHK(`DEBUG_BASE+16'h0000 + (4*i),  `DEBUG_BASE+16'h0078, 29-i,     0);
    join
  end

  display_subcount_text(3, "SRAM1_CE_B Control", 1);
  fork
    begin
      @(posedge mode00_en); force dut.obc_core.SRAM1_CE_B = internal_sig;
      @(negedge mode00_en); release dut.obc_core.SRAM1_CE_B;
      @(posedge mode01_en); force sram1_ce_b = external_sig;
      @(negedge mode01_en); release sram1_ce_b;
    end
               // gpio_ctrl_adr                  gpio_moni_adr         moni_bit  mode00_nochk_flg
    GPIO_CTRL_CHK(`DEBUG_BASE+16'h0000 + (4*20), `DEBUG_BASE+16'h0078, 9,        0);
  join

  display_subcount_text(4, "SRAM1_OE_B Control", 1);
  fork
    begin
      @(posedge mode00_en); force dut.obc_core.SRAM1_OE_B = internal_sig;
      @(negedge mode00_en); release dut.obc_core.SRAM1_OE_B;
      @(posedge mode01_en); force sram1_oe_b = external_sig;
      @(negedge mode01_en); release sram1_oe_b;
    end
               // gpio_ctrl_adr                  gpio_moni_adr         moni_bit  mode00_nochk_flg
    GPIO_CTRL_CHK(`DEBUG_BASE+16'h0000 + (4*21), `DEBUG_BASE+16'h0078, 8,        0);
  join

  display_subcount_text(5, "SRAM1_WE_B Control", 1);
  fork
    begin
      @(posedge mode00_en); force dut.obc_core.SRAM1_WE_B = internal_sig;
      @(negedge mode00_en); release dut.obc_core.SRAM1_WE_B;
      @(posedge mode01_en); force sram1_we_b = external_sig;
      @(negedge mode01_en); release sram1_we_b;
    end
               // gpio_ctrl_adr                  gpio_moni_adr         moni_bit  mode00_nochk_flg
    GPIO_CTRL_CHK(`DEBUG_BASE+16'h0000 + (4*22), `DEBUG_BASE+16'h0078, 7,        0);
  join

  display_subcount_text(6, "SRAM1_BHE_B Control", 1);
  fork
    begin
      @(posedge mode00_en); force dut.obc_core.SRAM1_BHE_B = internal_sig;
      @(negedge mode00_en); release dut.obc_core.SRAM1_BHE_B;
      @(posedge mode01_en); force sram1_bhe_b = external_sig;
      @(negedge mode01_en); release sram1_bhe_b;
    end
               // gpio_ctrl_adr                  gpio_moni_adr         moni_bit  mode00_nochk_flg
    GPIO_CTRL_CHK(`DEBUG_BASE+16'h0000 + (4*23), `DEBUG_BASE+16'h0078, 6,        0);
  join

  display_subcount_text(7, "SRAM1_BLE_B Control", 1);
  fork
    begin
      @(posedge mode00_en); force dut.obc_core.SRAM1_BLE_B = internal_sig;
      @(negedge mode00_en); release dut.obc_core.SRAM1_BLE_B;
      @(posedge mode01_en); force sram1_ble_b = external_sig;
      @(negedge mode01_en); release sram1_ble_b;
    end
               // gpio_ctrl_adr                  gpio_moni_adr         moni_bit  mode00_nochk_flg
    GPIO_CTRL_CHK(`DEBUG_BASE+16'h0000 + (4*24), `DEBUG_BASE+16'h0078, 5,        0);
  join

  display_subcount_text(8, "SRAM2_CE_B Control", 1);
  fork
    begin
      @(posedge mode00_en); force dut.obc_core.SRAM2_CE_B = internal_sig;
      @(negedge mode00_en); release dut.obc_core.SRAM2_CE_B;
      @(posedge mode01_en); force sram2_ce_b = external_sig;
      @(negedge mode01_en); release sram2_ce_b;
    end
               // gpio_ctrl_adr                  gpio_moni_adr         moni_bit  mode00_nochk_flg
    GPIO_CTRL_CHK(`DEBUG_BASE+16'h0000 + (4*25), `DEBUG_BASE+16'h0078, 4,        0);
  join

  display_subcount_text(9, "SRAM2_OE_B Control", 1);
  fork
    begin
      @(posedge mode00_en); force dut.obc_core.SRAM2_OE_B = internal_sig;
      @(negedge mode00_en); release dut.obc_core.SRAM2_OE_B;
      @(posedge mode01_en); force sram2_oe_b = external_sig;
      @(negedge mode01_en); release sram2_oe_b;
    end
               // gpio_ctrl_adr                  gpio_moni_adr         moni_bit  mode00_nochk_flg
    GPIO_CTRL_CHK(`DEBUG_BASE+16'h0000 + (4*26), `DEBUG_BASE+16'h0078, 3,        0);
  join

  display_subcount_text(10, "SRAM2_WE_B Control", 1);
  fork
    begin
      @(posedge mode00_en); force dut.obc_core.SRAM2_WE_B = internal_sig;
      @(negedge mode00_en); release dut.obc_core.SRAM2_WE_B;
      @(posedge mode01_en); force sram2_we_b = external_sig;
      @(negedge mode01_en); release sram2_we_b;
    end
               // gpio_ctrl_adr                  gpio_moni_adr         moni_bit  mode00_nochk_flg
    GPIO_CTRL_CHK(`DEBUG_BASE+16'h0000 + (4*27), `DEBUG_BASE+16'h0078, 2,        0);
  join

  display_subcount_text(11, "SRAM2_BHE_B Control", 1);
  fork
    begin
      @(posedge mode00_en); force dut.obc_core.SRAM2_BHE_B = internal_sig;
      @(negedge mode00_en); release dut.obc_core.SRAM2_BHE_B;
      @(posedge mode01_en); force sram2_bhe_b = external_sig;
      @(negedge mode01_en); release sram2_bhe_b;
    end
               // gpio_ctrl_adr                  gpio_moni_adr         moni_bit  mode00_nochk_flg
    GPIO_CTRL_CHK(`DEBUG_BASE+16'h0000 + (4*28), `DEBUG_BASE+16'h0078, 1,        0);
  join

  display_subcount_text(12, "SRAM2_BLE_B Control", 1);
  fork
    begin
      @(posedge mode00_en); force dut.obc_core.SRAM2_BLE_B = internal_sig;
      @(negedge mode00_en); release dut.obc_core.SRAM2_BLE_B;
      @(posedge mode01_en); force sram2_ble_b = external_sig;
      @(negedge mode01_en); release sram2_ble_b;
    end
               // gpio_ctrl_adr                  gpio_moni_adr         moni_bit  mode00_nochk_flg
    GPIO_CTRL_CHK(`DEBUG_BASE+16'h0000 + (4*29), `DEBUG_BASE+16'h0078, 0,        0);
  join

  //--------------------------------------------------
  label    = "QSPI I/F (CFG Flash) Control Check ";
  simcount = 3;
  //--------------------------------------------------
  @(posedge SYS_CLK);
  display_subcount_text(1, "ALL '0' Output", 1);
  write_transaction(.master(2), .addr(`DEBUG_BASE+16'h0100), .data(32'h0000_0002));
  write_transaction(.master(2), .addr(`DEBUG_BASE+16'h0104), .data(32'h0000_0002));
  write_transaction(.master(2), .addr(`DEBUG_BASE+16'h0108), .data(32'h0000_0002));
  write_transaction(.master(2), .addr(`DEBUG_BASE+16'h010C), .data(32'h0000_0002));
  write_transaction(.master(2), .addr(`DEBUG_BASE+16'h0110), .data(32'h0000_0002));
  read_transaction( .master(2), .addr(`DEBUG_BASE+16'h0114), .expdata(32'h0000_0000), .check(1));

  display_subcount_text(2, "CFG_MEM_CS_B Control", 1);
  fork
    begin
      @(posedge mode00_en); force dut.obc_core.CFG_MEM_CS_B = internal_sig;
      @(negedge mode00_en); release dut.obc_core.CFG_MEM_CS_B;
      @(posedge mode01_en); force cfg_mem_cs_b = external_sig;
      @(negedge mode01_en); release cfg_mem_cs_b;
    end
               // gpio_ctrl_adr                  gpio_moni_adr         moni_bit  mode00_nochk_flg
    GPIO_CTRL_CHK(`DEBUG_BASE+16'h0100 + (4*0),  `DEBUG_BASE+16'h0114, 4,        0);
  join

  display_subcount_text(3, "CFG_MEM_IO Control", 1);
  for(i=0; i<4; i=i+1) begin
    fork
      begin
        @(posedge mode00_en); force dut.obc_core.CFG_MEM_DOUT = internal_sig << (3-i); force dut.obc_core.CFG_MEM_OE = 4'hF;
        @(negedge mode00_en); release dut.obc_core.CFG_MEM_DOUT; release dut.obc_core.CFG_MEM_OE;
        @(posedge mode01_en); force cfg_mem_io = external_sig << (3-i);
        @(negedge mode01_en); release cfg_mem_io;
      end
                 // gpio_ctrl_adr                      gpio_moni_adr         moni_bit  mode00_nochk_flg
      GPIO_CTRL_CHK(`DEBUG_BASE+16'h0100 + (4*(i+1)),  `DEBUG_BASE+16'h0114, 3-i,      0);
    join
  end

  //--------------------------------------------------
  label    = "QSPI I/F (DATA Flash) Control Check ";
  simcount = 4;
  //--------------------------------------------------
  @(posedge SYS_CLK);
  display_subcount_text(1, "ALL '0' Output", 1);
  write_transaction(.master(2), .addr(`DEBUG_BASE+16'h0200), .data(32'h0000_0002));
  write_transaction(.master(2), .addr(`DEBUG_BASE+16'h0204), .data(32'h0000_0002));
  write_transaction(.master(2), .addr(`DEBUG_BASE+16'h0208), .data(32'h0000_0002));
  write_transaction(.master(2), .addr(`DEBUG_BASE+16'h020C), .data(32'h0000_0002));
  write_transaction(.master(2), .addr(`DEBUG_BASE+16'h0210), .data(32'h0000_0002));
  write_transaction(.master(2), .addr(`DEBUG_BASE+16'h0214), .data(32'h0000_0002));
  write_transaction(.master(2), .addr(`DEBUG_BASE+16'h0218), .data(32'h0000_0002));
  write_transaction(.master(2), .addr(`DEBUG_BASE+16'h021C), .data(32'h0000_0002));
  write_transaction(.master(2), .addr(`DEBUG_BASE+16'h0220), .data(32'h0000_0002));
  write_transaction(.master(2), .addr(`DEBUG_BASE+16'h0224), .data(32'h0000_0002));
  read_transaction( .master(2), .addr(`DEBUG_BASE+16'h0228), .expdata(32'h0000_0000), .check(1));

  display_subcount_text(2, "DATA_MEM1_CS_B Control", 1);
  fork
    begin
      @(posedge mode00_en); force dut.obc_core.DATA_MEM1_CS_B = internal_sig;
      @(negedge mode00_en); release dut.obc_core.DATA_MEM1_CS_B;
      @(posedge mode01_en); force data_mem1_cs_b = external_sig;
      @(negedge mode01_en); release data_mem1_cs_b;
    end
               // gpio_ctrl_adr                  gpio_moni_adr         moni_bit  mode00_nochk_flg
    GPIO_CTRL_CHK(`DEBUG_BASE+16'h0200 + (4*0),  `DEBUG_BASE+16'h0228, 9,        0);
  join

  display_subcount_text(3, "DATA_MEM1_IO Control", 1);
  for(i=0; i<4; i=i+1) begin
    fork
      begin
        @(posedge mode00_en); force dut.obc_core.DATA_MEM1_DOUT = internal_sig << (3-i); force dut.obc_core.DATA_MEM1_OE = 4'hF;
        @(negedge mode00_en); release dut.obc_core.DATA_MEM1_DOUT; release dut.obc_core.DATA_MEM1_OE;
        @(posedge mode01_en); force data_mem1_io = external_sig << (3-i);
        @(negedge mode01_en); release data_mem1_io;
      end
                 // gpio_ctrl_adr                      gpio_moni_adr         moni_bit  mode00_nochk_flg
      GPIO_CTRL_CHK(`DEBUG_BASE+16'h0200 + (4*(i+1)),  `DEBUG_BASE+16'h0228, 8-i,      0);
    join
  end

  display_subcount_text(4, "DATA_MEM2_CS_B Control", 1);
  fork
    begin
      @(posedge mode00_en); force dut.obc_core.DATA_MEM2_CS_B = internal_sig;
      @(negedge mode00_en); release dut.obc_core.DATA_MEM2_CS_B;
      @(posedge mode01_en); force data_mem2_cs_b = external_sig;
      @(negedge mode01_en); release data_mem2_cs_b;
    end
               // gpio_ctrl_adr                  gpio_moni_adr         moni_bit  mode00_nochk_flg
    GPIO_CTRL_CHK(`DEBUG_BASE+16'h0200 + (4*5),  `DEBUG_BASE+16'h0228, 4,        0);
  join

  display_subcount_text(5, "DATA_MEM2_IO Control", 1);
  for(i=0; i<4; i=i+1) begin
    fork
      begin
        @(posedge mode00_en); force dut.obc_core.DATA_MEM2_DOUT = internal_sig << (3-i); force dut.obc_core.DATA_MEM2_OE = 4'hF;
        @(negedge mode00_en); release dut.obc_core.DATA_MEM2_DOUT; release dut.obc_core.DATA_MEM2_OE;
        @(posedge mode01_en); force data_mem2_io = external_sig << (3-i);
        @(negedge mode01_en); release data_mem2_io;
      end
                 // gpio_ctrl_adr                      gpio_moni_adr         moni_bit  mode00_nochk_flg
      GPIO_CTRL_CHK(`DEBUG_BASE+16'h0200 + (4*(i+6)),  `DEBUG_BASE+16'h0228, 3-i,      0);
    join
  end

  //--------------------------------------------------
  label    = "QSPI I/F (FRAM) Control Check ";
  simcount = 5;
  //--------------------------------------------------
  @(posedge SYS_CLK);
  display_subcount_text(1, "ALL '0' Output", 1);
  write_transaction(.master(2), .addr(`DEBUG_BASE+16'h0300), .data(32'h0000_0002));
  write_transaction(.master(2), .addr(`DEBUG_BASE+16'h0304), .data(32'h0000_0002));
  write_transaction(.master(2), .addr(`DEBUG_BASE+16'h0308), .data(32'h0000_0002));
  write_transaction(.master(2), .addr(`DEBUG_BASE+16'h030C), .data(32'h0000_0002));
  write_transaction(.master(2), .addr(`DEBUG_BASE+16'h0310), .data(32'h0000_0002));
  write_transaction(.master(2), .addr(`DEBUG_BASE+16'h0314), .data(32'h0000_0002));
  write_transaction(.master(2), .addr(`DEBUG_BASE+16'h0318), .data(32'h0000_0002));
  write_transaction(.master(2), .addr(`DEBUG_BASE+16'h031C), .data(32'h0000_0002));
  write_transaction(.master(2), .addr(`DEBUG_BASE+16'h0320), .data(32'h0000_0002));
  write_transaction(.master(2), .addr(`DEBUG_BASE+16'h0324), .data(32'h0000_0002));
  read_transaction( .master(2), .addr(`DEBUG_BASE+16'h0328), .expdata(32'h0000_0000), .check(1));

  display_subcount_text(2, "FRAM1_CS_B Control", 1);
  fork
    begin
      @(posedge mode00_en); force dut.obc_core.FRAM1_CS_B = internal_sig;
      @(negedge mode00_en); release dut.obc_core.FRAM1_CS_B;
      @(posedge mode01_en); force fram1_cs_b = external_sig;
      @(negedge mode01_en); release fram1_cs_b;
    end
               // gpio_ctrl_adr                  gpio_moni_adr         moni_bit  mode00_nochk_flg
    GPIO_CTRL_CHK(`DEBUG_BASE+16'h0300 + (4*0),  `DEBUG_BASE+16'h0328, 9,        0);
  join

  display_subcount_text(3, "FRAM1_IO Control", 1);
  for(i=0; i<4; i=i+1) begin
    fork
      begin
        @(posedge mode00_en); force dut.obc_core.FRAM1_DOUT = internal_sig << (3-i); force dut.obc_core.FRAM1_OE = 4'hF;
        @(negedge mode00_en); release dut.obc_core.FRAM1_DOUT; release dut.obc_core.FRAM1_OE;
        @(posedge mode01_en); force fram1_io = external_sig << (3-i);
        @(negedge mode01_en); release fram1_io;
      end
                 // gpio_ctrl_adr                      gpio_moni_adr         moni_bit  mode00_nochk_flg
      GPIO_CTRL_CHK(`DEBUG_BASE+16'h0300 + (4*(i+1)),  `DEBUG_BASE+16'h0328, 8-i,      0);
    join
  end

  display_subcount_text(4, "FRAM2_CS_B Control", 1);
  fork
    begin
      @(posedge mode00_en); force dut.obc_core.FRAM2_CS_B = internal_sig;
      @(negedge mode00_en); release dut.obc_core.FRAM2_CS_B;
      @(posedge mode01_en); force fram2_cs_b = external_sig;
      @(negedge mode01_en); release fram2_cs_b;
    end
               // gpio_ctrl_adr                  gpio_moni_adr         moni_bit  mode00_nochk_flg
    GPIO_CTRL_CHK(`DEBUG_BASE+16'h0300 + (4*5),  `DEBUG_BASE+16'h0328, 4,        0);
  join

  display_subcount_text(5, "FRAM2_IO Control", 1);
  for(i=0; i<4; i=i+1) begin
    fork
      begin
        @(posedge mode00_en); force dut.obc_core.FRAM2_DOUT = internal_sig << (3-i); force dut.obc_core.FRAM2_OE = 4'hF;
        @(negedge mode00_en); release dut.obc_core.FRAM2_DOUT; release dut.obc_core.FRAM2_OE;
        @(posedge mode01_en); force fram2_io = external_sig << (3-i);
        @(negedge mode01_en); release fram2_io;
      end
                 // gpio_ctrl_adr                      gpio_moni_adr         moni_bit  mode00_nochk_flg
      GPIO_CTRL_CHK(`DEBUG_BASE+16'h0300 + (4*(i+6)),  `DEBUG_BASE+16'h0328, 3-i,      0);
    join
  end

  //--------------------------------------------------
  label    = "OSC I/F Monitor Check ";
  simcount = 6;
  //--------------------------------------------------
  @(posedge SYS_CLK);
  read_transaction( .master(2), .addr(`DEBUG_BASE+16'h0400), .expdata(32'h0000_0003), .check(1));
  repeat (10) @ (posedge SYS_CLK);
  force sysclk2 = 0;
  repeat (300) @ (posedge SYS_CLK);
  read_transaction( .master(2), .addr(`DEBUG_BASE+16'h0400), .expdata(32'h0000_0001), .check(1));
  repeat (10) @ (posedge SYS_CLK);
  release sysclk2;
  repeat (10) @ (posedge SYS_CLK);
  read_transaction( .master(2), .addr(`DEBUG_BASE+16'h0400), .expdata(32'h0000_0003), .check(1));
  repeat (10) @ (posedge SYS_CLK);
  force dut.sysctrl.clk_gen.scobca1_pll.PLLRESET = 1'b1;
  #1000;
  force dut.sysctrl.clk_gen.refclk_sel.clk_d_count_en2 = 3'b111;
  force dut.sysctrl.clk_gen.refclk_sel.clk_valid[2] = 1'b1;
  force dut.sysctrl.clk_gen.refclk_sel.clksel = 1;
  force dut.sysctrl.clk_gen.refclk_sel.ref_sel = 3'b111;
  #1000;
  release dut.sysctrl.clk_gen.scobca1_pll.PLLRESET;
  repeat (10) @ (posedge SYS_CLK);
  force sysclk1 = 0;
  repeat (300) @ (posedge SYS_CLK);
  read_transaction( .master(2), .addr(`DEBUG_BASE+16'h0400), .expdata(32'h0000_0002), .check(1));
  repeat (10) @ (posedge SYS_CLK);
  release sysclk1;
  repeat (10) @ (posedge SYS_CLK);
  read_transaction( .master(2), .addr(`DEBUG_BASE+16'h0400), .expdata(32'h0000_0003), .check(1));

  //--------------------------------------------------
  label    = "INT I2C I/F Monitor Check ";
  simcount = 7;
  //--------------------------------------------------
  @(posedge SYS_CLK);
  read_transaction( .master(2), .addr(`DEBUG_BASE+16'h0500), .expdata(32'h0000_0007), .check(1));
  repeat (10) @ (posedge SYS_CLK);
  cvm_critical_b = 0;
  cvm_warning_b = 1'b1;
  temp_alert_b = 1'b1;
  repeat (10) @ (posedge SYS_CLK);
  read_transaction( .master(2), .addr(`DEBUG_BASE+16'h0500), .expdata(32'h0000_0006), .check(1));
  repeat (10) @ (posedge SYS_CLK);
  cvm_critical_b = 1'b1;
  cvm_warning_b = 0;
  temp_alert_b = 1'b1;
  repeat (10) @ (posedge SYS_CLK);
  read_transaction( .master(2), .addr(`DEBUG_BASE+16'h0500), .expdata(32'h0000_0005), .check(1));
  repeat (10) @ (posedge SYS_CLK);
  cvm_critical_b = 1'b1;
  cvm_warning_b = 1'b1;
  temp_alert_b = 0;
  repeat (10) @ (posedge SYS_CLK);
  read_transaction( .master(2), .addr(`DEBUG_BASE+16'h0500), .expdata(32'h0000_0003), .check(1));
  repeat (10) @ (posedge SYS_CLK);
  cvm_critical_b = 1'b1;
  cvm_warning_b = 1'b1;
  temp_alert_b = 1'b1;
  repeat (10) @ (posedge SYS_CLK);
  read_transaction( .master(2), .addr(`DEBUG_BASE+16'h0500), .expdata(32'h0000_0007), .check(1));

  //--------------------------------------------------
  label    = "EXT I2C I/F Control Check ";
  simcount = 8;
  //--------------------------------------------------
  @(posedge SYS_CLK);
  display_subcount_text(1, "ALL '0' Output", 1);
  write_transaction(.master(2), .addr(`DEBUG_BASE+16'h0600), .data(32'h0000_0002));
  write_transaction(.master(2), .addr(`DEBUG_BASE+16'h0604), .data(32'h0000_0002));
  read_transaction( .master(2), .addr(`DEBUG_BASE+16'h0608), .expdata(32'h0000_0000), .check(1));

  display_subcount_text(2, "EXT_I2C_SCL Control", 1);
  fork
    begin
      @(posedge mode01_en); force external_i2cm_scl = external_sig;
      @(negedge mode01_en); release external_i2cm_scl;
    end
               // gpio_ctrl_adr                  gpio_moni_adr         moni_bit  mode00_nochk_flg
    GPIO_CTRL_CHK(`DEBUG_BASE+16'h0600 + (4*0),  `DEBUG_BASE+16'h0608, 1,        1);
  join

  display_subcount_text(3, "EXT_I2C_SDA Control", 1);
  fork
    begin
      @(posedge mode01_en); force external_i2cm_sda = external_sig;
      @(negedge mode01_en); release external_i2cm_sda;
    end
               // gpio_ctrl_adr                  gpio_moni_adr         moni_bit  mode00_nochk_flg
    GPIO_CTRL_CHK(`DEBUG_BASE+16'h0600 + (4*1),  `DEBUG_BASE+16'h0608, 0,        1);
  join

  //--------------------------------------------------
  label    = "TRCH I/F Control/Monitor Check ";
  simcount = 9;
  //--------------------------------------------------
  @(posedge SYS_CLK);
  display_subcount_text(1, "FPGA_BOOT Monitor Check", 1);
  boot_data_in = 32'h1357_9BDF;
  for(i=0; i<32; i=i+1) begin
    FPGA_BOOT[0] = boot_data_in[31-i];
    @(posedge SYS_CLK);
    FPGA_BOOT[1] = 1'b1;
    @(posedge SYS_CLK);
    FPGA_BOOT[1] = 1'b0;
  end
  read_transaction( .master(2), .addr(`DEBUG_BASE+16'h0700), .expdata(32'h1357_9BDF), .check(1));
  boot_data_in = 32'hECA8_6421;
  for(i=0; i<32; i=i+1) begin
    FPGA_BOOT[0] = boot_data_in[31-i];
    @(posedge SYS_CLK);
    FPGA_BOOT[1] = 1'b1;
    @(posedge SYS_CLK);
    FPGA_BOOT[1] = 1'b0;
  end
  read_transaction( .master(2), .addr(`DEBUG_BASE+16'h0700), .expdata(32'hECA8_6421), .check(1));

  display_subcount_text(2, "ALL '0' Output", 1);
  write_transaction(.master(2), .addr(`DEBUG_BASE+16'h0704), .data(32'h0000_0002));
  write_transaction(.master(2), .addr(`DEBUG_BASE+16'h0708), .data(32'h0000_0002));
  write_transaction(.master(2), .addr(`DEBUG_BASE+16'h070C), .data(32'h0000_0002));
  read_transaction( .master(2), .addr(`DEBUG_BASE+16'h0710), .expdata(32'h0000_0000), .check(1));

  display_subcount_text(3, "FPGA_WATCHDOG Control", 1);
  fork
    begin
      @(posedge mode00_en); force dut.obc_core.FPGA_WATCHDOG = internal_sig;
      @(negedge mode00_en); release dut.obc_core.FPGA_WATCHDOG;
      @(posedge mode01_en); force FPGA_WATCHDOG = external_sig;
      @(negedge mode01_en); release FPGA_WATCHDOG;
    end
               // gpio_ctrl_adr                  gpio_moni_adr         moni_bit  mode00_nochk_flg
    GPIO_CTRL_CHK(`DEBUG_BASE+16'h0700 + (4*1),  `DEBUG_BASE+16'h0710, 2,        0);
  join

  display_subcount_text(4, "FPGA_PWR_CYCLE_REQ Control", 1);
  fork
    begin
      @(posedge mode00_en); force dut.obc_core.FPGA_PWR_CYCLE_REQ = internal_sig;
      @(negedge mode00_en); release dut.obc_core.FPGA_PWR_CYCLE_REQ;
      @(posedge mode01_en); force pwr_cycle_req = external_sig;
      @(negedge mode01_en); release pwr_cycle_req;
    end
               // gpio_ctrl_adr                  gpio_moni_adr         moni_bit  mode00_nochk_flg
    GPIO_CTRL_CHK(`DEBUG_BASE+16'h0700 + (4*2),  `DEBUG_BASE+16'h0710, 1,        0);
  join

  display_subcount_text(5, "FPGA_RESERVE Control", 1);
  fork
    begin
      @(posedge mode01_en); force fpga_reserve = external_sig;
      @(negedge mode01_en); release fpga_reserve;
    end
               // gpio_ctrl_adr                  gpio_moni_adr         moni_bit  mode00_nochk_flg
    GPIO_CTRL_CHK(`DEBUG_BASE+16'h0700 + (4*3),  `DEBUG_BASE+16'h0710, 0,        1);
  join

  //--------------------------------------------------
  label    = "ULPI I/F Control/Monitor Check ";
  simcount = 10;
  //--------------------------------------------------
  display_subcount_text(1, "ULPI_CLOCK Monitor", 1);
  @(posedge SYS_CLK);
  read_transaction( .master(2), .addr(`DEBUG_BASE+16'h0800), .expdata(32'h0000_0001), .check(1));
  repeat (10) @ (posedge SYS_CLK);
  force ulpi_clock = 0;
  repeat (300) @ (posedge SYS_CLK);
  read_transaction( .master(2), .addr(`DEBUG_BASE+16'h0800), .expdata(32'h0000_0000), .check(1));
  repeat (10) @ (posedge SYS_CLK);
  release ulpi_clock;
  repeat (10) @ (posedge SYS_CLK);
  read_transaction( .master(2), .addr(`DEBUG_BASE+16'h0800), .expdata(32'h0000_0001), .check(1));

  display_subcount_text(2, "ALL '0' Output", 1);
  write_transaction(.master(2), .addr(`DEBUG_BASE+16'h0804), .data(32'h0000_0002));
  write_transaction(.master(2), .addr(`DEBUG_BASE+16'h0808), .data(32'h0000_0002));
  read_transaction( .master(2), .addr(`DEBUG_BASE+16'h080C), .expdata(32'h0000_0000), .check(1));

  display_subcount_text(3, "ULPI_RESET_B Control", 1);
  fork
    begin
      @(posedge mode01_en); force ulpi_reset_b = external_sig;
      @(negedge mode01_en); release ulpi_reset_b;
    end
               // gpio_ctrl_adr                  gpio_moni_adr         moni_bit  mode00_nochk_flg
    GPIO_CTRL_CHK(`DEBUG_BASE+16'h0800 + (4*1),  `DEBUG_BASE+16'h080C, 1,        1);
  join

  display_subcount_text(4, "ULPI_CS Control", 1);
  fork
    begin
      @(posedge mode01_en); force ulpi_cs = external_sig;
      @(negedge mode01_en); release ulpi_cs;
    end
               // gpio_ctrl_adr                  gpio_moni_adr         moni_bit  mode00_nochk_flg
    GPIO_CTRL_CHK(`DEBUG_BASE+16'h0800 + (4*2),  `DEBUG_BASE+16'h080C, 0,        1);
  join

  //--------------------------------------------------
  label    = "FPGA Config I/F Control Check ";
  simcount = 11;
  //--------------------------------------------------
  @(posedge SYS_CLK);
  force pudc_b = 0;
  repeat (3) @ (posedge SYS_CLK);
  read_transaction( .master(2), .addr(`DEBUG_BASE+16'h0B00), .expdata(32'h0000_0000), .check(1));
  release pudc_b;
  repeat (3) @ (posedge SYS_CLK);
  read_transaction( .master(2), .addr(`DEBUG_BASE+16'h0B00), .expdata(32'h0000_0001), .check(1));

  //--------------------------------------------------
  label    = "UIO1 I/F Control Check ";
  simcount = 12;
  //--------------------------------------------------
  @(posedge SYS_CLK);
  display_subcount_text(1, "ALL '0' Output", 1);
  write_transaction(.master(2), .addr(`DEBUG_BASE+16'h0C00), .data(32'h0000_0002));
  write_transaction(.master(2), .addr(`DEBUG_BASE+16'h0C04), .data(32'h0000_0002));
  write_transaction(.master(2), .addr(`DEBUG_BASE+16'h0C08), .data(32'h0000_0002));
  write_transaction(.master(2), .addr(`DEBUG_BASE+16'h0C0C), .data(32'h0000_0002));
  write_transaction(.master(2), .addr(`DEBUG_BASE+16'h0C10), .data(32'h0000_0002));
  write_transaction(.master(2), .addr(`DEBUG_BASE+16'h0C14), .data(32'h0000_0002));
  write_transaction(.master(2), .addr(`DEBUG_BASE+16'h0C18), .data(32'h0000_0002));
  write_transaction(.master(2), .addr(`DEBUG_BASE+16'h0C1C), .data(32'h0000_0002));
  write_transaction(.master(2), .addr(`DEBUG_BASE+16'h0C20), .data(32'h0000_0002));
  write_transaction(.master(2), .addr(`DEBUG_BASE+16'h0C24), .data(32'h0000_0002));
  write_transaction(.master(2), .addr(`DEBUG_BASE+16'h0C28), .data(32'h0000_0002));
  write_transaction(.master(2), .addr(`DEBUG_BASE+16'h0C2C), .data(32'h0000_0002));
  write_transaction(.master(2), .addr(`DEBUG_BASE+16'h0C30), .data(32'h0000_0002));
  write_transaction(.master(2), .addr(`DEBUG_BASE+16'h0C34), .data(32'h0000_0002));
  write_transaction(.master(2), .addr(`DEBUG_BASE+16'h0C38), .data(32'h0000_0002));
  write_transaction(.master(2), .addr(`DEBUG_BASE+16'h0C3C), .data(32'h0000_0002));
  read_transaction( .master(2), .addr(`DEBUG_BASE+16'h0C40), .expdata(32'h0000_0000), .check(1));

  display_subcount_text(2, "UIO1 Control", 1);
  for(i=0; i<16; i=i+1) begin
    fork
      begin
        @(posedge mode01_en); force uio1 = external_sig << i;
        @(negedge mode01_en); release uio1;
      end
                 // gpio_ctrl_adr                  gpio_moni_adr         moni_bit  mode00_nochk_flg
      GPIO_CTRL_CHK(`DEBUG_BASE+16'h0C00 + (4*i),  `DEBUG_BASE+16'h0C40, i,        1);
    join
  end

  //--------------------------------------------------
  label    = "UIO2 I/F Control Check ";
  simcount = 13;
  //--------------------------------------------------
  @(posedge SYS_CLK);
  display_subcount_text(1, "ALL '0' Output", 1);
  write_transaction(.master(2), .addr(`DEBUG_BASE+16'h0D00), .data(32'h0000_0002));
  write_transaction(.master(2), .addr(`DEBUG_BASE+16'h0D04), .data(32'h0000_0002));
  write_transaction(.master(2), .addr(`DEBUG_BASE+16'h0D08), .data(32'h0000_0002));
  write_transaction(.master(2), .addr(`DEBUG_BASE+16'h0D0C), .data(32'h0000_0002));
  write_transaction(.master(2), .addr(`DEBUG_BASE+16'h0D10), .data(32'h0000_0002));
  write_transaction(.master(2), .addr(`DEBUG_BASE+16'h0D14), .data(32'h0000_0002));
  write_transaction(.master(2), .addr(`DEBUG_BASE+16'h0D18), .data(32'h0000_0002));
  write_transaction(.master(2), .addr(`DEBUG_BASE+16'h0D1C), .data(32'h0000_0002));
  write_transaction(.master(2), .addr(`DEBUG_BASE+16'h0D20), .data(32'h0000_0002));
  write_transaction(.master(2), .addr(`DEBUG_BASE+16'h0D24), .data(32'h0000_0002));
  write_transaction(.master(2), .addr(`DEBUG_BASE+16'h0D28), .data(32'h0000_0002));
  write_transaction(.master(2), .addr(`DEBUG_BASE+16'h0D2C), .data(32'h0000_0002));
  write_transaction(.master(2), .addr(`DEBUG_BASE+16'h0D30), .data(32'h0000_0002));
  write_transaction(.master(2), .addr(`DEBUG_BASE+16'h0D34), .data(32'h0000_0002));
  write_transaction(.master(2), .addr(`DEBUG_BASE+16'h0D38), .data(32'h0000_0002));
  write_transaction(.master(2), .addr(`DEBUG_BASE+16'h0D3C), .data(32'h0000_0002));
  read_transaction( .master(2), .addr(`DEBUG_BASE+16'h0D40), .expdata(32'h0000_0000), .check(1));

  display_subcount_text(2, "UIO2 Control", 1);
  for(i=0; i<16; i=i+1) begin
    fork
      begin
        @(posedge mode01_en); force uio2 = external_sig << i;
        @(negedge mode01_en); release uio2;
      end
                 // gpio_ctrl_adr                  gpio_moni_adr         moni_bit  mode00_nochk_flg
      GPIO_CTRL_CHK(`DEBUG_BASE+16'h0D00 + (4*i),  `DEBUG_BASE+16'h0D40, i,        1);
    join
  end

  //--------------------------------------------------
  label    = "UIO4 I/F Control Check ";
  simcount = 14;
  //--------------------------------------------------
  @(posedge SYS_CLK);
  display_subcount_text(1, "ALL '0' Output", 1);
  write_transaction(.master(2), .addr(`DEBUG_BASE+16'h0E00), .data(32'h0000_0002));
  write_transaction(.master(2), .addr(`DEBUG_BASE+16'h0E04), .data(32'h0000_0002));
  write_transaction(.master(2), .addr(`DEBUG_BASE+16'h0E08), .data(32'h0000_0002));
  write_transaction(.master(2), .addr(`DEBUG_BASE+16'h0E0C), .data(32'h0000_0002));
  write_transaction(.master(2), .addr(`DEBUG_BASE+16'h0E10), .data(32'h0000_0002));
  write_transaction(.master(2), .addr(`DEBUG_BASE+16'h0E14), .data(32'h0000_0002));
  read_transaction( .master(2), .addr(`DEBUG_BASE+16'h0E18), .expdata(32'h0000_0000), .check(1));

  display_subcount_text(2, "UIO4 Control", 1);
  for(i=0; i<6; i=i+1) begin
    fork
      begin
        @(posedge mode01_en); force uio4 = external_sig << i;
        @(negedge mode01_en); release uio4;
      end
                 // gpio_ctrl_adr                  gpio_moni_adr         moni_bit  mode00_nochk_flg
      GPIO_CTRL_CHK(`DEBUG_BASE+16'h0E00 + (4*i),  `DEBUG_BASE+16'h0E18, i,        1);
    join
  end

  repeat (100) @ (posedge SYS_CLK);
  simfinish(0);
end

endmodule
