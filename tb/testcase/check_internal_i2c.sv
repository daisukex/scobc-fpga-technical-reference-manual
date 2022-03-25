//-----------------------------------------------
// Space Cubics SC-OBC-A1 FPGA
//  Testcase: Check Internal I2C Master Controller
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
`include "cm3_task.vh"
`include "sc_obc_a1_fpga_task.vh"
`include "scvip_ahb_master_pkg.vh"
`include "dut_register_map.vh"


assign testcase_name = "Check Internal I2C Master Controller";
initial begin
  timeout_ms = 100;
  skip_sram_init();
  @ (posedge SYS_RSTB);

  //--------------------------------------------------
  label    = "Initialize and Boot System";
  simcount = 0;
  //--------------------------------------------------
  internal_i2c.FINISH_CTRL(1);
  internal_i2c.RX_EXP_COMP_EN(1);
  @ (posedge CMC_REQ);
  @ (posedge CMC_ACK);
  @ (posedge PLLLOCK);
  @ (negedge CMC_REQ);
  @ (negedge CMC_ACK);
  display_text("SC-OBC-CORE System Bootup Done", 1, 1);
  @(posedge SYS_CLK);

  //--------------------------------------------------
  label    = "Internal I2C Accsess Check";
  simcount = 1;
  //--------------------------------------------------
  @(posedge SYS_CLK);
  display_subcount_text(1, "I2C Enable ON", 1);
  write_transaction(.master(2), .addr(`INT_I2CM_BASE+`I2CM_ENR),        .data(1<<`I2CM_EN));
  read_transaction( .master(2), .addr(`INT_I2CM_BASE+`I2CM_ISR),     .expdata(32'h0000_0000), .check(1));
  read_transaction( .master(2), .addr(`INT_I2CM_BASE+`I2CM_BSR),     .expdata(32'h0000_0000), .check(1));

  //--------------------------------------------------
  label    = "I2C Write Check";
  simcount = 2;
  //--------------------------------------------------
  internal_i2c.SET_DEVADR(0, 7'h12);
  internal_i2c.RX_EXP_VAL_SET(0, 8'h34);
  internal_i2c.RX_EXP_VAL_SET(1, 8'h56);
  internal_i2c.RX_EXP_VAL_SET(2, 8'h78);
  internal_i2c.RX_EXP_VAL_SET(3, 8'h9A);
  internal_i2c.RX_EXP_VAL_SET(4, 8'hBC);
  internal_i2c.RX_EXP_VAL_SET(5, 8'hDE);
  internal_i2c.RX_EXP_VAL_SET(6, 8'hF1);
  @(posedge SYS_CLK);
  write_transaction(.master(2), .addr(`INT_I2CM_BASE+`I2CM_TXFIFOR),    .data(32'h0000_0024));
  write_transaction(.master(2), .addr(`INT_I2CM_BASE+`I2CM_TXFIFOR),    .data(32'h0000_0034));
  write_transaction(.master(2), .addr(`INT_I2CM_BASE+`I2CM_TXFIFOR),    .data(32'h0000_0056));
  write_transaction(.master(2), .addr(`INT_I2CM_BASE+`I2CM_TXFIFOR),    .data(32'h0000_0078));
  write_transaction(.master(2), .addr(`INT_I2CM_BASE+`I2CM_TXFIFOR),    .data(32'h0000_009A));
  write_transaction(.master(2), .addr(`INT_I2CM_BASE+`I2CM_TXFIFOR),    .data(32'h0000_00BC));
  write_transaction(.master(2), .addr(`INT_I2CM_BASE+`I2CM_TXFIFOR),    .data(32'h0000_00DE));
  write_transaction(.master(2), .addr(`INT_I2CM_BASE+`I2CM_TXFIFOR),    .data(32'h0000_01F1));
  read_transaction( .master(2), .addr(`INT_I2CM_BASE+`I2CM_BSR),     .expdata(1<<`I2CM_SELFBUSY), .check(1));

  // Interrupt Check
  write_transaction(.master(2), .addr(`INT_I2CM_BASE+`I2CM_IER),        .data(1<<`I2CM_COMP));

  display_subcount_text(1, "Internal I2C Master Controller Interrupt Check", 1);
  cm3_isr_check(`CM3_ISR_INT_I2CM, 20000);

  display_subcount_text(2, "Internal I2C Master Controller Interrupt Status Register Check", 1);
  cm3_sys_ipcore_interrupt_check_and_write_clear(`INT_I2CM_BASE+`I2CM_ISR, 1<<`I2CM_COMP);
  write_transaction(.master(2), .addr(`INT_I2CM_BASE+`I2CM_IER),        .data(32'h00000000));

  display_subcount_text(3, "Check Clear Busy Bit", 1);
  repeat(50) @(posedge SYS_CLK);
  read_transaction_polling_wait( .master(2), .addr(`INT_I2CM_BASE+`I2CM_BSR), .expdata(32'h00000000));

  //--------------------------------------------------
  label    = "I2C Read Check";
  simcount = 2;
  //--------------------------------------------------
  // I2C Read
  display_subcount_text(3, "I2C Read Check", 1);
  internal_i2c.SET_DEVADR(0, 7'h7E);
  internal_i2c.TX_VAL_SET(0, 8'hDC);
  internal_i2c.TX_VAL_SET(1, 8'hBA);
  internal_i2c.TX_VAL_SET(2, 8'h98);
  internal_i2c.TX_VAL_SET(3, 8'h76);
  internal_i2c.TX_VAL_SET(4, 8'h54);
  internal_i2c.TX_VAL_SET(5, 8'h32);
  internal_i2c.TX_VAL_SET(6, 8'h1F);
  @(posedge SYS_CLK);
  write_transaction(.master(2), .addr(`INT_I2CM_BASE+`I2CM_TXFIFOR),    .data(32'h0000_00FD));
  write_transaction(.master(2), .addr(`INT_I2CM_BASE+`I2CM_TXFIFOR),    .data(32'h0000_0106));
  read_transaction( .master(2), .addr(`INT_I2CM_BASE+`I2CM_BSR),     .expdata(1<<`I2CM_SELFBUSY), .check(1));

  // Interrupt Check
  write_transaction(.master(2), .addr(`INT_I2CM_BASE+`I2CM_IER),        .data(1<<`I2CM_COMP));

  display_subcount_text(1, "Internal I2C Master Controller Interrupt Check", 1);
  cm3_isr_check(`CM3_ISR_INT_I2CM, 20000);

  display_subcount_text(2, "Internal I2C Master Controller Interrupt Status Register Check", 1);
  cm3_sys_ipcore_interrupt_check_and_write_clear(`INT_I2CM_BASE+`I2CM_ISR, 1<<`I2CM_COMP);
  write_transaction(.master(2), .addr(`INT_I2CM_BASE+`I2CM_IER),        .data(32'h0000_0000));

  display_subcount_text(3, "Check Clear Busy Bit", 1);
  repeat(50) @(posedge SYS_CLK);
  read_transaction_polling_wait( .master(2), .addr(`INT_I2CM_BASE+`I2CM_BSR), .expdata(32'h00000000));

  // Read Data Check
  display_subcount_text(4, "Check Read Data", 1);
  read_transaction( .master(2), .addr(`INT_I2CM_BASE+`I2CM_RXFIFOR), .expdata(32'h0000_00DC), .check(1));
  read_transaction( .master(2), .addr(`INT_I2CM_BASE+`I2CM_RXFIFOR), .expdata(32'h0000_00BA), .check(1));
  read_transaction( .master(2), .addr(`INT_I2CM_BASE+`I2CM_RXFIFOR), .expdata(32'h0000_0098), .check(1));
  read_transaction( .master(2), .addr(`INT_I2CM_BASE+`I2CM_RXFIFOR), .expdata(32'h0000_0076), .check(1));
  read_transaction( .master(2), .addr(`INT_I2CM_BASE+`I2CM_RXFIFOR), .expdata(32'h0000_0054), .check(1));
  read_transaction( .master(2), .addr(`INT_I2CM_BASE+`I2CM_RXFIFOR), .expdata(32'h0000_0032), .check(1));
  read_transaction( .master(2), .addr(`INT_I2CM_BASE+`I2CM_RXFIFOR), .expdata(32'h0000_001F), .check(1));
  repeat(50) @(posedge SYS_CLK);
  read_transaction_polling_wait( .master(2), .addr(`INT_I2CM_BASE+`I2CM_BSR), .expdata(32'h00000000));

  repeat (100) @ (posedge SYS_CLK);
  simfinish(0);
end

endmodule
