`timescale 1ps/1ps

module tb_top;

parameter TB_CFG_MEM1_ENABLE = 0;
parameter TB_CFG_MEM2_ENABLE = 0;
parameter TB_DATA_MEM1_ENABLE = 0;
parameter TB_DATA_MEM2_ENABLE = 0;
parameter TB_FRAM1_ENABLE = 1;
parameter TB_FRAM2_ENABLE = 1;

`include "tb_top_main.vh"
`include "sc_verification_task_pkg.vh"
`include "cm3_task.vh"
`include "scvip_ahb_master_pkg.vh"
`include "dut_register_map.vh"

task FRAM_QSPI_RDSR_TRANS;
  input [1:0]  IO_MODE;
  input        chk_flg;
  input [31:0] EXP_DATA;
begin

  write_transaction(.master(2), .addr(`FRM_QSPI_BASE+`SPIACR), .data(IO_MODE<<`SPIIOMODE | 1<<`SPISSCTL));
  cm3_isr_check(`CM3_ISR_FRM_QSPI, 100);
  cm3_sys_ipcore_interrupt_check_and_write_clear(`FRM_QSPI_BASE+`SPIISR, 1<<`SPICTRLDN);

  write_transaction(.master(2), .addr(`FRM_QSPI_BASE+`SPITDR), .data(32'h0000_0005));
  cm3_isr_check(`CM3_ISR_FRM_QSPI, 100);
  cm3_sys_ipcore_interrupt_check_and_write_clear(`FRM_QSPI_BASE+`SPIISR, 1<<`SPICTRLDN);

  write_transaction(.master(2), .addr(`FRM_QSPI_BASE+`SPIRDR), .data(32'h0000_0000));
  cm3_isr_check(`CM3_ISR_FRM_QSPI, 100);
  cm3_sys_ipcore_interrupt_check_and_write_clear(`FRM_QSPI_BASE+`SPIISR, 1<<`SPICTRLDN);

  write_transaction(.master(2), .addr(`FRM_QSPI_BASE+`SPIACR), .data(32'h0000_0000));
  cm3_isr_check(`CM3_ISR_FRM_QSPI, 100);
  cm3_sys_ipcore_interrupt_check_and_write_clear(`FRM_QSPI_BASE+`SPIISR, 1<<`SPICTRLDN);

  if (chk_flg)
    read_transaction( .master(2), .addr(`FRM_QSPI_BASE+`SPIRDR), .expdata(EXP_DATA), .check(1));
  read_transaction( .master(2), .addr(`FRM_QSPI_BASE+`SPIISR), .expdata(32'h0000_0000), .check(1));
end
endtask

task FRAM_QSPI_WREN_TRANS;
input [1:0] IO_MODE;
begin
  write_transaction(.master(2), .addr(`FRM_QSPI_BASE+`SPIACR), .data(IO_MODE<<`SPIIOMODE | 1<<`SPISSCTL));
  cm3_isr_check(`CM3_ISR_FRM_QSPI, 100);
  cm3_sys_ipcore_interrupt_check_and_write_clear(`FRM_QSPI_BASE+`SPIISR, 1<<`SPICTRLDN);

  write_transaction(.master(2), .addr(`FRM_QSPI_BASE+`SPITDR), .data(32'h0000_0006));
  cm3_isr_check(`CM3_ISR_FRM_QSPI, 100);
  cm3_sys_ipcore_interrupt_check_and_write_clear(`FRM_QSPI_BASE+`SPIISR, 1<<`SPICTRLDN);

  write_transaction(.master(2), .addr(`FRM_QSPI_BASE+`SPIACR), .data(32'h0000_0000));
  cm3_isr_check(`CM3_ISR_FRM_QSPI, 100);
  cm3_sys_ipcore_interrupt_check_and_write_clear(`FRM_QSPI_BASE+`SPIISR, 1<<`SPICTRLDN);

  read_transaction( .master(2), .addr(`FRM_QSPI_BASE+`SPIISR), .expdata(32'h0000_0000), .check(1));
end
endtask

task FRAM_QSPI_QPI_ON_TRANS;
begin
  write_transaction(.master(2), .addr(`FRM_QSPI_BASE+`SPIACR), .data(0<<`SPIIOMODE | 1<<`SPISSCTL));
  cm3_isr_check(`CM3_ISR_FRM_QSPI, 100);
  cm3_sys_ipcore_interrupt_check_and_write_clear(`FRM_QSPI_BASE+`SPIISR, 1<<`SPICTRLDN);

  write_transaction(.master(2), .addr(`FRM_QSPI_BASE+`SPITDR), .data(32'h0000_0071));
  write_transaction(.master(2), .addr(`FRM_QSPI_BASE+`SPITDR), .data(32'h0000_0000));
  write_transaction(.master(2), .addr(`FRM_QSPI_BASE+`SPITDR), .data(32'h0000_0000));
  write_transaction(.master(2), .addr(`FRM_QSPI_BASE+`SPITDR), .data(32'h0000_0003));
  write_transaction(.master(2), .addr(`FRM_QSPI_BASE+`SPITDR), .data(32'h0000_0040));
  cm3_isr_check(`CM3_ISR_FRM_QSPI, 100);
  cm3_sys_ipcore_interrupt_check_and_write_clear(`FRM_QSPI_BASE+`SPIISR, 1<<`SPICTRLDN);

  write_transaction(.master(2), .addr(`FRM_QSPI_BASE+`SPIACR), .data(32'h0000_0000));
  cm3_isr_check(`CM3_ISR_FRM_QSPI, 100);
  cm3_sys_ipcore_interrupt_check_and_write_clear(`FRM_QSPI_BASE+`SPIISR, 1<<`SPICTRLDN);

  read_transaction( .master(2), .addr(`FRM_QSPI_BASE+`SPIISR), .expdata(32'h0000_0000), .check(1));
  write_transaction(.master(2), .addr(`FRM_QSPI_BASE+`SPIACR), .data(2<<`SPIIOMODE | 1<<`SPISSCTL));
  cm3_isr_check(`CM3_ISR_FRM_QSPI, 100);
  cm3_sys_ipcore_interrupt_check_and_write_clear(`FRM_QSPI_BASE+`SPIISR, 1<<`SPICTRLDN);

  write_transaction(.master(2), .addr(`FRM_QSPI_BASE+`SPITDR), .data(32'h0000_003F));
  cm3_isr_check(`CM3_ISR_FRM_QSPI, 100);
  cm3_sys_ipcore_interrupt_check_and_write_clear(`FRM_QSPI_BASE+`SPIISR, 1<<`SPICTRLDN);

  write_transaction(.master(2), .addr(`FRM_QSPI_BASE+`SPIRDR), .data(32'h0000_0000));
  cm3_isr_check(`CM3_ISR_FRM_QSPI, 100);
  cm3_sys_ipcore_interrupt_check_and_write_clear(`FRM_QSPI_BASE+`SPIISR, 1<<`SPICTRLDN);

  write_transaction(.master(2), .addr(`FRM_QSPI_BASE+`SPIACR), .data(32'h0000_0000));
  cm3_isr_check(`CM3_ISR_FRM_QSPI, 100);
  cm3_sys_ipcore_interrupt_check_and_write_clear(`FRM_QSPI_BASE+`SPIISR, 1<<`SPICTRLDN);

  read_transaction( .master(2), .addr(`FRM_QSPI_BASE+`SPIRDR), .expdata(32'h0000_0040), .check(1));
  read_transaction( .master(2), .addr(`FRM_QSPI_BASE+`SPIISR), .expdata(32'h0000_0000), .check(1));
end
endtask

task FRAM_QSPI_QPI_OFF_TRANS;
begin

  write_transaction(.master(2), .addr(`FRM_QSPI_BASE+`SPIACR), .data(2<<`SPIIOMODE | 1<<`SPISSCTL));
  cm3_isr_check(`CM3_ISR_FRM_QSPI, 100);
  cm3_sys_ipcore_interrupt_check_and_write_clear(`FRM_QSPI_BASE+`SPIISR, 1<<`SPICTRLDN);

  write_transaction(.master(2), .addr(`FRM_QSPI_BASE+`SPITDR), .data(32'h0000_0071));
  write_transaction(.master(2), .addr(`FRM_QSPI_BASE+`SPITDR), .data(32'h0000_0000));
  write_transaction(.master(2), .addr(`FRM_QSPI_BASE+`SPITDR), .data(32'h0000_0000));
  write_transaction(.master(2), .addr(`FRM_QSPI_BASE+`SPITDR), .data(32'h0000_0003));
  write_transaction(.master(2), .addr(`FRM_QSPI_BASE+`SPITDR), .data(32'h0000_0000));
  cm3_isr_check(`CM3_ISR_FRM_QSPI, 100);
  cm3_sys_ipcore_interrupt_check_and_write_clear(`FRM_QSPI_BASE+`SPIISR, 1<<`SPICTRLDN);

  write_transaction(.master(2), .addr(`FRM_QSPI_BASE+`SPIACR), .data(32'h0000_0000));
  cm3_isr_check(`CM3_ISR_FRM_QSPI, 100);
  cm3_sys_ipcore_interrupt_check_and_write_clear(`FRM_QSPI_BASE+`SPIISR, 1<<`SPICTRLDN);

  read_transaction( .master(2), .addr(`FRM_QSPI_BASE+`SPIISR), .expdata(32'h0000_0000), .check(1));
  write_transaction(.master(2), .addr(`FRM_QSPI_BASE+`SPIACR), .data(0<<`SPIIOMODE | 1<<`SPISSCTL));
  cm3_isr_check(`CM3_ISR_FRM_QSPI, 100);
  cm3_sys_ipcore_interrupt_check_and_write_clear(`FRM_QSPI_BASE+`SPIISR, 1<<`SPICTRLDN);

  write_transaction(.master(2), .addr(`FRM_QSPI_BASE+`SPITDR), .data(32'h0000_003F));
  cm3_isr_check(`CM3_ISR_FRM_QSPI, 100);
  cm3_sys_ipcore_interrupt_check_and_write_clear(`FRM_QSPI_BASE+`SPIISR, 1<<`SPICTRLDN);

  write_transaction(.master(2), .addr(`FRM_QSPI_BASE+`SPIRDR), .data(32'h0000_0000));
  cm3_isr_check(`CM3_ISR_FRM_QSPI, 100);
  cm3_sys_ipcore_interrupt_check_and_write_clear(`FRM_QSPI_BASE+`SPIISR, 1<<`SPICTRLDN);

  write_transaction(.master(2), .addr(`FRM_QSPI_BASE+`SPIACR), .data(32'h0000_0000));
  cm3_isr_check(`CM3_ISR_FRM_QSPI, 100);
  cm3_sys_ipcore_interrupt_check_and_write_clear(`FRM_QSPI_BASE+`SPIISR, 1<<`SPICTRLDN);

  read_transaction( .master(2), .addr(`FRM_QSPI_BASE+`SPIRDR), .expdata(32'h0000_0000), .check(1));
  read_transaction( .master(2), .addr(`FRM_QSPI_BASE+`SPIISR), .expdata(32'h0000_0000), .check(1));
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
    FRAM_QSPI_RDSR_TRANS(2, 0, 0);
    read_transaction( .master(2), .addr(`FRM_QSPI_BASE+`SPIRDR), .expdata(32'h0000_0000), .check(0));
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

assign testcase_name = "Check FRAM Controller";
initial begin
  timeout_ms = 5;
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

  display_subcount_text(1, "Set the quad bit in the FRAM model", 1);
  fram1.fram.CR1_NV = 8'h02;
  fram2.fram.CR1_NV = 8'h02;

  display_subcount_text(2, "Wait 500 us", 1);
  #500_000_000;

  //--------------------------------------------------
  label    = "FRAM QSPI Accsess Check";
  simcount = 1;
  //--------------------------------------------------
  @(posedge SYS_CLK);
  display_subcount_text(1, "Set Interrupt Enable", 1);
  write_transaction(.master(2), .addr(`FRM_QSPI_BASE+`SPIIER), .data(32'h0707_0001));

  //--------------------------------------------------
  label    = "FRAM_MEM1 WRITE(QPI) (4Byte)";
  simcount = 2;
  //--------------------------------------------------
  display_subcount_text(1, "Set FRAM WREN", 1);
  FRAM_QSPI_RDSR_TRANS(0, 1, 0);
  FRAM_QSPI_WREN_TRANS(0);
  FRAM_QSPI_RDSR_TRANS(0, 1, 8'h02);

  display_subcount_text(2, "QPI Mode On", 1);
  FRAM_QSPI_QPI_ON_TRANS();

  display_subcount_text(3, "Set WREN", 1);
  FRAM_QSPI_RDSR_TRANS(2, 1, 0);
  FRAM_QSPI_WREN_TRANS(2);
  FRAM_QSPI_RDSR_TRANS(2, 1, 8'h02);

  display_subcount_text(4, "Set Quad & SS", 1);
  write_transaction(.master(2), .addr(`FRM_QSPI_BASE+`SPIACR), .data(2<<`SPIIOMODE | 1<<`SPISSCTL));
  cm3_isr_check(`CM3_ISR_FRM_QSPI, 100);
  cm3_sys_ipcore_interrupt_check_and_write_clear(`FRM_QSPI_BASE+`SPIISR, 1<<`SPICTRLDN);

  display_subcount_text(5, "Instruction & Address & Mode SPI Transfer", 1);
  write_transaction(.master(2), .addr(`FRM_QSPI_BASE+`SPITDR), .data(32'h0000_0002));
  write_transaction(.master(2), .addr(`FRM_QSPI_BASE+`SPITDR), .data(32'h0000_0000));
  write_transaction(.master(2), .addr(`FRM_QSPI_BASE+`SPITDR), .data(32'h0000_0000));
  write_transaction(.master(2), .addr(`FRM_QSPI_BASE+`SPITDR), .data(32'h0000_0000));
  cm3_isr_check(`CM3_ISR_FRM_QSPI, 100);
  cm3_sys_ipcore_interrupt_check_and_write_clear(`FRM_QSPI_BASE+`SPIISR, 1<<`SPICTRLDN);

  display_subcount_text(6, "Data SPI Transfer", 1);
  write_transaction(.master(2), .addr(`FRM_QSPI_BASE+`SPITDR), .data(32'h0000_0013));
  write_transaction(.master(2), .addr(`FRM_QSPI_BASE+`SPITDR), .data(32'h0000_0057));
  write_transaction(.master(2), .addr(`FRM_QSPI_BASE+`SPITDR), .data(32'h0000_009A));
  write_transaction(.master(2), .addr(`FRM_QSPI_BASE+`SPITDR), .data(32'h0000_00CE));
  cm3_isr_check(`CM3_ISR_FRM_QSPI, 100);
  cm3_sys_ipcore_interrupt_check_and_write_clear(`FRM_QSPI_BASE+`SPIISR, 1<<`SPICTRLDN);

  display_subcount_text(7, "SS Clear", 1);
  write_transaction(.master(2), .addr(`FRM_QSPI_BASE+`SPIACR), .data(32'h0000_0000));
  cm3_isr_check(`CM3_ISR_FRM_QSPI, 100);
  cm3_sys_ipcore_interrupt_check_and_write_clear(`FRM_QSPI_BASE+`SPIISR, 1<<`SPICTRLDN);

  display_subcount_text(8, "Program Complite Wait", 1);
  FLASH_DEVICE_STATUS_BIT_CHECK(100);
  FRAM_QSPI_RDSR_TRANS(2, 1, 8'h00);

  display_subcount_text(9, "Set WREN", 1);
  FRAM_QSPI_RDSR_TRANS(2, 1, 0);
  FRAM_QSPI_WREN_TRANS(2);
  FRAM_QSPI_RDSR_TRANS(2, 1, 8'h02);

  display_subcount_text(10, "QSPI Mode OFF", 1);
  FRAM_QSPI_QPI_OFF_TRANS();
  read_transaction( .master(2), .addr(`FRM_QSPI_BASE+`SPIISR), .expdata(32'h0000_0000), .check(1));

  //--------------------------------------------------
  label    = "FRAM_MEM1 Quad I/O Read(QPI) (4Byte)";
  simcount = 2;
  //--------------------------------------------------
  display_subcount_text(1, "Set FRAM WREN", 1);
  FRAM_QSPI_RDSR_TRANS(0, 1, 0);
  FRAM_QSPI_WREN_TRANS(0);
  FRAM_QSPI_RDSR_TRANS(0, 1, 8'h02);

  display_subcount_text(2, "QPI Mode On", 1);
  FRAM_QSPI_QPI_ON_TRANS();

  display_subcount_text(3, "Set Quad & SS", 1);
  write_transaction(.master(2), .addr(`FRM_QSPI_BASE+`SPIACR), .data(2<<`SPIIOMODE | 1<<`SPISSCTL));
  cm3_isr_check(`CM3_ISR_FRM_QSPI, 100);
  cm3_sys_ipcore_interrupt_check_and_write_clear(`FRM_QSPI_BASE+`SPIISR, 1<<`SPICTRLDN);

  display_subcount_text(4, "Instruction & Address & Mode SPI Transfer", 1);
  write_transaction(.master(2), .addr(`FRM_QSPI_BASE+`SPITDR), .data(32'h0000_00EB));
  write_transaction(.master(2), .addr(`FRM_QSPI_BASE+`SPITDR), .data(32'h0000_0000));
  write_transaction(.master(2), .addr(`FRM_QSPI_BASE+`SPITDR), .data(32'h0000_0000));
  write_transaction(.master(2), .addr(`FRM_QSPI_BASE+`SPITDR), .data(32'h0000_0000));
  write_transaction(.master(2), .addr(`FRM_QSPI_BASE+`SPITDR), .data(32'h0000_0000));
  cm3_isr_check(`CM3_ISR_FRM_QSPI, 100);
  cm3_sys_ipcore_interrupt_check_and_write_clear(`FRM_QSPI_BASE+`SPIISR, 1<<`SPICTRLDN);

  display_subcount_text(5, "SPI Receive", 1);
  write_transaction(.master(2), .addr(`FRM_QSPI_BASE+`SPIRDR), .data(32'h0000_0000));
  write_transaction(.master(2), .addr(`FRM_QSPI_BASE+`SPIRDR), .data(32'h0000_0000));
  write_transaction(.master(2), .addr(`FRM_QSPI_BASE+`SPIRDR), .data(32'h0000_0000));
  write_transaction(.master(2), .addr(`FRM_QSPI_BASE+`SPIRDR), .data(32'h0000_0000));
  cm3_isr_check(`CM3_ISR_FRM_QSPI, 100);
  cm3_sys_ipcore_interrupt_check_and_write_clear(`FRM_QSPI_BASE+`SPIISR, 1<<`SPICTRLDN);

  display_subcount_text(6, "Clear SS", 1);
  write_transaction(.master(2), .addr(`FRM_QSPI_BASE+`SPIACR), .data(32'h0000_0000));
  cm3_isr_check(`CM3_ISR_FRM_QSPI, 100);
  cm3_sys_ipcore_interrupt_check_and_write_clear(`FRM_QSPI_BASE+`SPIISR, 1<<`SPICTRLDN);

  display_subcount_text(7, "Data Read", 1);
  read_transaction( .master(2), .addr(`FRM_QSPI_BASE+`SPIRDR), .expdata(32'h0000_0013), .check(0));
  read_transaction( .master(2), .addr(`FRM_QSPI_BASE+`SPIRDR), .expdata(32'h0000_0057), .check(1));
  read_transaction( .master(2), .addr(`FRM_QSPI_BASE+`SPIRDR), .expdata(32'h0000_009A), .check(1));
  read_transaction( .master(2), .addr(`FRM_QSPI_BASE+`SPIRDR), .expdata(32'h0000_00CE), .check(1));
  read_transaction( .master(2), .addr(`FRM_QSPI_BASE+`SPIISR), .expdata(32'h0000_0000), .check(1));

  display_subcount_text(8, "Set WREN", 1);
  FRAM_QSPI_RDSR_TRANS(2, 1, 0);
  FRAM_QSPI_WREN_TRANS(2);
  FRAM_QSPI_RDSR_TRANS(2, 1, 8'h02);

  display_subcount_text(9, "QPI Mode Off", 1);
  FRAM_QSPI_QPI_OFF_TRANS();
  read_transaction( .master(2), .addr(`FRM_QSPI_BASE+`SPIISR), .expdata(32'h0000_00000), .check(1));

  repeat (100) @ (posedge SYS_CLK);
  simfinish(0);
end

endmodule
