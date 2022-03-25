//-----------------------------------------------
// Space Cubics SC-OBC-A1 FPGA
//  Testcase: Check UART-Lite
//-----------------------------------------------
// Copyright © 2022 Space Cubics, LLC.
//-----------------------------------------------

`timescale 1ps/1ps

module tb_top;

parameter TB_CFG_MEM1_ENABLE = 0;
parameter TB_CFG_MEM2_ENABLE = 0;
parameter TB_DATA_MEM1_ENABLE = 0;
parameter TB_DATA_MEM2_ENABLE = 0;
parameter TB_FRAM1_ENABLE = 0;
parameter TB_FRAM2_ENABLE = 0;

`include "tb_top_main.vh"
`include "sc_verification_task_pkg.vh"
`include "cm3_task.vh"
`include "scvip_ahb_master_pkg.vh"
`include "dut_register_map.vh"

reg [31:0] BRP;
reg [3:0] TS1;
reg [2:0] TS2;
reg [1:0] SJW;
reg [10:0] ID;
reg [17:0] EXT_ID;
reg RTR;
reg [3:0] DLC;
reg [63:0] DW;

assign testcase_name = "Check UART-Lite";
initial begin
  timeout_ms = 100;
  @ (posedge SYS_RSTB);

  //--------------------------------------------------
  label    = "Initialize and Boot System";
  simcount = 0;
  //--------------------------------------------------
  cm3_console.FINISH_CTRL(1);
  cm3_console.UART_CLK_PERIOD_CTL(32'd104167); // 9.6Mbps
  cm3_console.RX_DATA_EXP_COMP_EN(1);
  @ (posedge CMC_REQ);
  @ (posedge CMC_ACK);
  @ (posedge PLLLOCK);
  @ (negedge CMC_REQ);
  @ (negedge CMC_ACK);
  display_text("SC-OBC-CORE System Bootup Done", 1, 1);
  @(posedge SYS_CLK);

  //--------------------------------------------------
  label    = "Console UART Accsess Check";
  simcount = 1;
  //--------------------------------------------------
  @(posedge SYS_CLK);
  display_subcount_text(1, "Set Baudrate 9.6Mbp", 1);
  write_transaction(.master(2), .addr(`UARTLITE_BASE+`AHBUUBRSR),       .data(16'h0009<<`AHBUUDIVSET));

  //--------------------------------------------------
  label    = "Set Interrupt Enable";
  simcount = 2;
  //--------------------------------------------------
  @(posedge SYS_CLK);
  write_transaction(.master(2), .addr(`UARTLITE_BASE+`AHBUCTRLR),       .data(1<<`AHBUINTENACTL));

  //--------------------------------------------------
  label    = "UART TX Check";
  simcount = 3;
  //--------------------------------------------------
  @(posedge SYS_CLK);
  cm3_console.RX_DATA_EXP_VAL_SET(8'hF1);
  cm3_console.RX_DATA_EXP_VAL_SET(8'h23);
  cm3_console.RX_DATA_EXP_VAL_SET(8'h45);
  display_subcount_text(1, "UART Transmit Data Write to TxFIFO", 1);
  write_transaction(.master(2), .addr(`UARTLITE_BASE+`AHBUTXFIFOR),     .data(32'h0000_00F1));
  write_transaction(.master(2), .addr(`UARTLITE_BASE+`AHBUTXFIFOR),     .data(32'h0000_0023));
  write_transaction(.master(2), .addr(`UARTLITE_BASE+`AHBUTXFIFOR),     .data(32'h0000_0045));

  display_subcount_text(2, "Interrupt Assert Check", 1);
  cm3_isr_check(`CM3_ISR_UARTLITE, 20000);

  display_subcount_text(3, "Check TxFIFO Status", 1);
  read_transaction( .master(2), .addr(`UARTLITE_BASE+`AHBUSTATR),    .expdata(1<<`AHBUINTENAMON
                                                                            | 1<<`AHBUTXFIFOEMP), .check(1));

  //--------------------------------------------------
  label    = "UART RX Check";
  simcount = 4;
  //--------------------------------------------------
  @(posedge SYS_CLK);
  display_subcount_text(1, "UART Receive Data Read from RxFIFO", 1);
  cm3_console.UART_TX_TRANS(8'h67, 0, 0); @(posedge SYS_CLK);
  cm3_isr_check(`CM3_ISR_UARTLITE, 20000);
  read_transaction( .master(2), .addr(`UARTLITE_BASE+`AHBUSTATR),    .expdata(1<<`AHBUINTENAMON
                                                                            | 1<<`AHBUTXFIFOEMP
                                                                            | 1<<`AHBURXFIFOVAL), .check(1));
  read_transaction( .master(2), .addr(`UARTLITE_BASE+`AHBURXFIFOR),  .expdata(32'h0000_0067),     .check(1));

  cm3_console.UART_TX_TRANS(8'h89, 0, 0); @(posedge SYS_CLK);
  cm3_isr_check(`CM3_ISR_UARTLITE, 20000);
  read_transaction( .master(2), .addr(`UARTLITE_BASE+`AHBUSTATR),    .expdata(1<<`AHBUINTENAMON
                                                                            | 1<<`AHBUTXFIFOEMP
                                                                            | 1<<`AHBURXFIFOVAL), .check(1));
  read_transaction( .master(2), .addr(`UARTLITE_BASE+`AHBURXFIFOR),  .expdata(32'h0000_0089),     .check(1));

  cm3_console.UART_TX_TRANS(8'hAB, 0, 0); @(posedge SYS_CLK);
  cm3_isr_check(`CM3_ISR_UARTLITE, 20000);
  read_transaction( .master(2), .addr(`UARTLITE_BASE+`AHBUSTATR),    .expdata(1<<`AHBUINTENAMON
                                                                            | 1<<`AHBUTXFIFOEMP
                                                                            | 1<<`AHBURXFIFOVAL), .check(1));
  read_transaction( .master(2), .addr(`UARTLITE_BASE+`AHBURXFIFOR),  .expdata(32'h0000_00AB),     .check(1));

  read_transaction( .master(2), .addr(`UARTLITE_BASE+`AHBUSTATR),    .expdata(1<<`AHBUINTENAMON
                                                                            | 1<<`AHBUTXFIFOEMP), .check(1));

  repeat (100) @ (posedge SYS_CLK);
  simfinish(0);
end

endmodule
