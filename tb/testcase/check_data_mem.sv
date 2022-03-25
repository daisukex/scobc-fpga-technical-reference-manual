//-----------------------------------------------
// Space Cubics SC-OBC-A1 FPGA
//  Testcase: Check NOR Flash Memory Controller 
//                                for Data Memory
//-----------------------------------------------
// Copyright © 2022 Space Cubics, LLC.
//-----------------------------------------------

`timescale 1ps/1ps

module tb_top;

parameter TB_SRAM_ENABLE = 0;
parameter TB_CFG_MEM1_ENABLE = 0;
parameter TB_CFG_MEM2_ENABLE = 0;
parameter TB_DATA_MEM1_ENABLE = 1;
parameter TB_DATA_MEM2_ENABLE = 0;
parameter TB_FRAM1_ENABLE = 0;
parameter TB_FRAM2_ENABLE = 0;

`include "tb_top_main.vh"
`include "sc_verification_task_pkg.vh"
`include "cm3_task.vh"
`include "sc_obc_a1_fpga_task.vh"
`include "scvip_ahb_master_pkg.vh"
`include "dut_register_map.vh"

task DAT_QSPI_RDSR_TRANS;
  input chk_flg;
  input [31:0] EXP_DATA;
begin
  display_text("aaa", 1, 1);
  write_transaction(.master(2), .addr(`DAT_QSPI_BASE+`SPIACR),   .data(0<<`SPIIOMODE | 1<<`SPISSCTL));
  cm3_isr_check(`CM3_ISR_DAT_QSPI, 100);
  cm3_sys_ipcore_interrupt_check_and_write_clear(`DAT_QSPI_BASE+`SPIISR, 1<<`SPICTRLDN);

  write_transaction(.master(2), .addr(`DAT_QSPI_BASE+`SPITDR),   .data(32'h0000_0005));
  cm3_isr_check(`CM3_ISR_DAT_QSPI, 100);
  cm3_sys_ipcore_interrupt_check_and_write_clear(`DAT_QSPI_BASE+`SPIISR, 1<<`SPICTRLDN);

  write_transaction(.master(2), .addr(`DAT_QSPI_BASE+`SPIRDR),   .data(32'h0000_0000));
  write_transaction(.master(2), .addr(`DAT_QSPI_BASE+`SPIRDR),   .data(32'h0000_0000));
  cm3_isr_check(`CM3_ISR_DAT_QSPI, 100);
  cm3_sys_ipcore_interrupt_check_and_write_clear(`DAT_QSPI_BASE+`SPIISR, 1<<`SPICTRLDN);

  write_transaction(.master(2), .addr(`DAT_QSPI_BASE+`SPIACR),   .data(32'h0000_0000));
  cm3_isr_check(`CM3_ISR_DAT_QSPI, 100);
  cm3_sys_ipcore_interrupt_check_and_write_clear(`DAT_QSPI_BASE+`SPIISR, 1<<`SPICTRLDN);
  if (chk_flg) begin
    read_transaction( .master(2), .addr(`DAT_QSPI_BASE+`SPIRDR), .expdata(EXP_DATA), .check(1));
    read_transaction( .master(2), .addr(`DAT_QSPI_BASE+`SPIRDR), .expdata(EXP_DATA), .check(1));
  end
  read_transaction( .master(2), .addr(`DAT_QSPI_BASE+`SPIISR),   .expdata(32'h0000_0000), .check(1));
end
endtask

task DAT_QSPI_WREN_TRANS;
begin
  write_transaction(.master(2), .addr(`DAT_QSPI_BASE+`SPIACR), .data(0<<`SPIIOMODE | 1<<`SPISSCTL));
  cm3_isr_check(`CM3_ISR_DAT_QSPI, 100);
  cm3_sys_ipcore_interrupt_check_and_write_clear(`DAT_QSPI_BASE+`SPIISR, 1<<`SPICTRLDN);

  write_transaction(.master(2), .addr(`DAT_QSPI_BASE+`SPITDR), .data(32'h0000_0006));
  cm3_isr_check(`CM3_ISR_DAT_QSPI, 100);
  cm3_sys_ipcore_interrupt_check_and_write_clear(`DAT_QSPI_BASE+`SPIISR, 1<<`SPICTRLDN);

  write_transaction(.master(2), .addr(`DAT_QSPI_BASE+`SPIACR), .data(32'h0000_0000));
  cm3_isr_check(`CM3_ISR_DAT_QSPI, 100);
  cm3_sys_ipcore_interrupt_check_and_write_clear(`DAT_QSPI_BASE+`SPIISR, 1<<`SPICTRLDN);

  read_transaction( .master(2), .addr(`DAT_QSPI_BASE+`SPIISR), .expdata(32'h0000_0000), .check(1));
end
endtask

task FLASH_DEVICE_STATUS_BIT_CHECK;
  input [31:0] timeout;
  reg busy_bit;
  reg [31:0] count;
begin
  count = 0;
  busy_bit = 1;
  while (busy_bit) begin
    repeat (100) @ (posedge SYS_CLK);
    DAT_QSPI_RDSR_TRANS(0, 0);
    read_transaction( .master(2), .addr(`DAT_QSPI_BASE+`SPIRDR), .expdata(32'h0000_0000), .check(0));
    read_transaction( .master(2), .addr(`DAT_QSPI_BASE+`SPIRDR), .expdata(32'h0000_0000), .check(0));
    @ (posedge SYS_CLK);
    busy_bit = TRANSDATA[0][0];
    count = count + 1;
    if (count >= 100) begin
      display_text("Flash Device Busy Status Check Fail", 1, 1);
      repeat(100) @ (posedge SYS_CLK);
      simfinish(1);
    end
  end
end
endtask

assign testcase_name = "Check NOR Flash Memory Controller for Data Memory";
initial begin
  timeout_ms = 100;
  skip_sram_init();
  @ (posedge SYS_RSTB);

  //--------------------------------------------------
  label    = "Initialize and Boot System";
  simcount = 0;
  //--------------------------------------------------
  @ (posedge CMC_REQ);
  @ (posedge CMC_ACK);
  @ (posedge PLLLOCK);
  @ (negedge CMC_REQ);
  @ (negedge CMC_ACK);
  display_text("SC-OBC-CORE System Bootup Done", 1, 1);
  @(posedge SYS_CLK);

  display_subcount_text(2, "Wait 500 us", 1);
  #500_000_000;

  //--------------------------------------------------
  label    = "CFG QSPI Flash Accsess Check";
  simcount = 1;
  //--------------------------------------------------
  @(posedge SYS_CLK);
  display_subcount_text(1, "Set Interrupt Enable", 1);
  write_transaction(.master(2), .addr(`DAT_QSPI_BASE+`SPIIER), .data(32'h0707_0001));

  //--------------------------------------------------
  label    = "DAT_MEM1 Quad Page Program (4Byte)";
  simcount = 2;
  //--------------------------------------------------
  @(posedge SYS_CLK);
  display_subcount_text(1, "Set Flash WREN", 1);
  DAT_QSPI_RDSR_TRANS(1, 0);
  DAT_QSPI_WREN_TRANS();
  DAT_QSPI_RDSR_TRANS(1, 8'h02);

  display_subcount_text(2, "Set Flash SS", 1);
  write_transaction(.master(2), .addr(`DAT_QSPI_BASE+`SPIACR), .data(0<<`SPIIOMODE | 1<<`SPISSCTL));
  cm3_isr_check(`CM3_ISR_DAT_QSPI, 100);
  cm3_sys_ipcore_interrupt_check_and_write_clear(`DAT_QSPI_BASE+`SPIISR, 1<<`SPICTRLDN);

  display_subcount_text(3, "Instruction & Address & SPI Transfer", 1);
  write_transaction(.master(2), .addr(`DAT_QSPI_BASE+`SPITDR), .data(32'h0000_0032));
  write_transaction(.master(2), .addr(`DAT_QSPI_BASE+`SPITDR), .data(32'h0000_0000));
  write_transaction(.master(2), .addr(`DAT_QSPI_BASE+`SPITDR), .data(32'h0000_0000));
  write_transaction(.master(2), .addr(`DAT_QSPI_BASE+`SPITDR), .data(32'h0000_0000));
  cm3_isr_check(`CM3_ISR_DAT_QSPI, 100);
  cm3_sys_ipcore_interrupt_check_and_write_clear(`DAT_QSPI_BASE+`SPIISR, 1<<`SPICTRLDN);

  display_subcount_text(4, "I/O MODE Change", 1);
  simcount = 12;
  write_transaction(.master(2), .addr(`DAT_QSPI_BASE+`SPIACR), .data(2<<`SPIIOMODE | 1<<`SPISSCTL));
  display_subcount_text(5, "Data SPI Transfer", 1);
  write_transaction(.master(2), .addr(`DAT_QSPI_BASE+`SPITDR), .data(32'h0000_0034));
  write_transaction(.master(2), .addr(`DAT_QSPI_BASE+`SPITDR), .data(32'h0000_0056));
  write_transaction(.master(2), .addr(`DAT_QSPI_BASE+`SPITDR), .data(32'h0000_0078));
  write_transaction(.master(2), .addr(`DAT_QSPI_BASE+`SPITDR), .data(32'h0000_009A));
  cm3_isr_check(`CM3_ISR_DAT_QSPI, 100);
  cm3_sys_ipcore_interrupt_check_and_write_clear(`DAT_QSPI_BASE+`SPIISR, 1<<`SPICTRLDN);

  display_subcount_text(6, "Flash SS Clear", 1);
  write_transaction(.master(2), .addr(`DAT_QSPI_BASE+`SPIACR), .data(32'h0000_0000));
  cm3_isr_check(`CM3_ISR_DAT_QSPI, 100);
  cm3_sys_ipcore_interrupt_check_and_write_clear(`DAT_QSPI_BASE+`SPIISR, 1<<`SPICTRLDN);

  display_subcount_text(7, "Flash Program Complite Wait", 1);
  repeat (10000 )@ (posedge SYS_CLK);
  FLASH_DEVICE_STATUS_BIT_CHECK(100);
  DAT_QSPI_RDSR_TRANS(1, 0);
  read_transaction( .master(2), .addr(`DAT_QSPI_BASE+`SPIISR), .expdata(32'h0000_0000), .check(1));

  //--------------------------------------------------
  label    = "DAT_MEM1 Quad I/O Read(QPI) (4Byte)";
  simcount = 3;
  //--------------------------------------------------
  @(posedge SYS_CLK);
  display_subcount_text(1, "Set Flash SS", 1);
  write_transaction(.master(2), .addr(`DAT_QSPI_BASE+`SPIACR), .data(0<<`SPIIOMODE | 1<<`SPISSCTL));
  cm3_isr_check(`CM3_ISR_DAT_QSPI, 100);
  cm3_sys_ipcore_interrupt_check_and_write_clear(`DAT_QSPI_BASE+`SPIISR, 1<<`SPICTRLDN);

  display_subcount_text(2, "Instruction SPI Transfer", 1);
  write_transaction(.master(2), .addr(`DAT_QSPI_BASE+`SPITDR), .data(32'h0000_00EB));
  cm3_isr_check(`CM3_ISR_DAT_QSPI, 100);
  cm3_sys_ipcore_interrupt_check_and_write_clear(`DAT_QSPI_BASE+`SPIISR, 1<<`SPICTRLDN);

  display_subcount_text(3, "I/O MODE Change", 1);
  write_transaction(.master(2), .addr(`DAT_QSPI_BASE+`SPIACR), .data(2<<`SPIIOMODE | 1<<`SPISSCTL));

  display_subcount_text(4, "Address & Mode & Dummy SPI Transfer", 1);
  write_transaction(.master(2), .addr(`DAT_QSPI_BASE+`SPITDR), .data(32'h0000_0000));
  write_transaction(.master(2), .addr(`DAT_QSPI_BASE+`SPITDR), .data(32'h0000_0000));
  write_transaction(.master(2), .addr(`DAT_QSPI_BASE+`SPITDR), .data(32'h0000_0000));
  write_transaction(.master(2), .addr(`DAT_QSPI_BASE+`SPITDR), .data(32'h0000_0000));
  write_transaction(.master(2), .addr(`DAT_QSPI_BASE+`SPITDR), .data(32'h0000_0000));
  write_transaction(.master(2), .addr(`DAT_QSPI_BASE+`SPITDR), .data(32'h0000_0000));
  write_transaction(.master(2), .addr(`DAT_QSPI_BASE+`SPITDR), .data(32'h0000_0000));
  write_transaction(.master(2), .addr(`DAT_QSPI_BASE+`SPITDR), .data(32'h0000_0000));
  cm3_isr_check(`CM3_ISR_DAT_QSPI, 100);
  cm3_sys_ipcore_interrupt_check_and_write_clear(`DAT_QSPI_BASE+`SPIISR, 1<<`SPICTRLDN);

  display_subcount_text(5, "SPI Receive & Data Read", 1);
  write_transaction(.master(2), .addr(`DAT_QSPI_BASE+`SPIRDR), .data(32'h0000_0000));
  write_transaction(.master(2), .addr(`DAT_QSPI_BASE+`SPIRDR), .data(32'h0000_0000));
  write_transaction(.master(2), .addr(`DAT_QSPI_BASE+`SPIRDR), .data(32'h0000_0000));
  write_transaction(.master(2), .addr(`DAT_QSPI_BASE+`SPIRDR), .data(32'h0000_0000));
  cm3_isr_check(`CM3_ISR_DAT_QSPI, 100);
  cm3_sys_ipcore_interrupt_check_and_write_clear(`DAT_QSPI_BASE+`SPIISR, 1<<`SPICTRLDN);

  display_text("Data Read", 1, 1);
  read_transaction( .master(2), .addr(`DAT_QSPI_BASE+`SPIRDR), .expdata(32'h0000_0034), .check(1));
  read_transaction( .master(2), .addr(`DAT_QSPI_BASE+`SPIRDR), .expdata(32'h0000_0056), .check(1));
  read_transaction( .master(2), .addr(`DAT_QSPI_BASE+`SPIRDR), .expdata(32'h0000_0078), .check(1));
  read_transaction( .master(2), .addr(`DAT_QSPI_BASE+`SPIRDR), .expdata(32'h0000_009A), .check(1));

  display_subcount_text(6, "Clear Flash SS", 1);
  write_transaction(.master(2), .addr(`DAT_QSPI_BASE+`SPIACR), .data(32'h0000_0000));
  cm3_isr_check(`CM3_ISR_DAT_QSPI, 100);
  cm3_sys_ipcore_interrupt_check_and_write_clear(`DAT_QSPI_BASE+`SPIISR, 1<<`SPICTRLDN);

  read_transaction( .master(2), .addr(`DAT_QSPI_BASE+`SPIISR), .expdata(32'h0000_0000), .check(1));

  repeat (100) @ (posedge SYS_CLK);
  simfinish(0);
end

endmodule
