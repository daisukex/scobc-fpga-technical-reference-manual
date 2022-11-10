//-----------------------------------------------
// Space Cubics SC-OBC-A1 FPGA
//  Testcase: Check System Monitor (XADC)
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

integer i;

assign testcase_name = "Check System Monitor (XADC)";
initial begin
  timeout_ms = 100;
  skip_sram_init();
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
  label    = "XADC Read Access (Initial Value)";
  simcount = 1;
  //--------------------------------------------------
  @(posedge SYS_CLK);
  read_transaction (.master(2), .addr(`SYS_MON_BASE+`SYSMON_XADC_BASE+12'h400), .expdata(32'h0000_0000), .check(1));
  read_transaction (.master(2), .addr(`SYS_MON_BASE+`SYSMON_XADC_BASE+12'h410), .expdata(32'h0000_2ff0), .check(1));
  read_transaction (.master(2), .addr(`SYS_MON_BASE+`SYSMON_XADC_BASE+12'h420), .expdata(32'h0000_0400), .check(1));

  read_transaction (.master(2), .addr(`SYS_MON_BASE+`SYSMON_XADC_BASE+12'h480), .expdata(32'h0000_4701), .check(1));
  read_transaction (.master(2), .addr(`SYS_MON_BASE+`SYSMON_XADC_BASE+12'h490), .expdata(32'h0000_0000), .check(1));
  read_transaction (.master(2), .addr(`SYS_MON_BASE+`SYSMON_XADC_BASE+12'h4A0), .expdata(32'h0000_0000), .check(1));
  read_transaction (.master(2), .addr(`SYS_MON_BASE+`SYSMON_XADC_BASE+12'h4B0), .expdata(32'h0000_0000), .check(1));
  read_transaction (.master(2), .addr(`SYS_MON_BASE+`SYSMON_XADC_BASE+12'h4C0), .expdata(32'h0000_0000), .check(1));
  read_transaction (.master(2), .addr(`SYS_MON_BASE+`SYSMON_XADC_BASE+12'h4D0), .expdata(32'h0000_0000), .check(1));
  read_transaction (.master(2), .addr(`SYS_MON_BASE+`SYSMON_XADC_BASE+12'h4E0), .expdata(32'h0000_0000), .check(1));
  read_transaction (.master(2), .addr(`SYS_MON_BASE+`SYSMON_XADC_BASE+12'h4F0), .expdata(32'h0000_0000), .check(1));

  read_transaction (.master(2), .addr(`SYS_MON_BASE+`SYSMON_XADC_BASE+12'h500), .expdata(32'h0000_b5ed), .check(1));
  read_transaction (.master(2), .addr(`SYS_MON_BASE+`SYSMON_XADC_BASE+12'h510), .expdata(32'h0000_5999), .check(1));
  read_transaction (.master(2), .addr(`SYS_MON_BASE+`SYSMON_XADC_BASE+12'h520), .expdata(32'h0000_a147), .check(1));
  read_transaction (.master(2), .addr(`SYS_MON_BASE+`SYSMON_XADC_BASE+12'h530), .expdata(32'h0000_ca30), .check(1));
  read_transaction (.master(2), .addr(`SYS_MON_BASE+`SYSMON_XADC_BASE+12'h540), .expdata(32'h0000_a93a), .check(1));
  read_transaction (.master(2), .addr(`SYS_MON_BASE+`SYSMON_XADC_BASE+12'h550), .expdata(32'h0000_5111), .check(1));
  read_transaction (.master(2), .addr(`SYS_MON_BASE+`SYSMON_XADC_BASE+12'h560), .expdata(32'h0000_91eb), .check(1));
  read_transaction (.master(2), .addr(`SYS_MON_BASE+`SYSMON_XADC_BASE+12'h570), .expdata(32'h0000_ae4e), .check(1));
  read_transaction (.master(2), .addr(`SYS_MON_BASE+`SYSMON_XADC_BASE+12'h580), .expdata(32'h0000_5999), .check(1));

  //--------------------------------------------------
  label    = "Read ADC Data (1st)";
  simcount = 2;
  //--------------------------------------------------
  while ($stime <= 50_000_000)
    @(posedge SYS_CLK);
  display_subcount_text(1, "Read Temperature (25C)", 1);
  read_transaction (.master(2), .addr(`SYS_MON_BASE+`SYSMON_XADC_BASE+12'h000), .expdata(32'h0000_9770), .check(1),
                                                                                .chkbit(32'h0000_FFF0));

  display_subcount_text(2, "Read VCCINT (1.00V)", 1);
  read_transaction (.master(2), .addr(`SYS_MON_BASE+`SYSMON_XADC_BASE+12'h010), .expdata(32'h0000_5550), .check(1),
                                                                                .chkbit(32'h0000_FFF0));

  display_subcount_text(3, "Read VCCACX (1.80V)", 1);
  read_transaction (.master(2), .addr(`SYS_MON_BASE+`SYSMON_XADC_BASE+12'h020), .expdata(32'h0000_9990), .check(1),
                                                                                .chkbit(32'h0000_FFF0));

  display_subcount_text(4, "Read VCCBRAM (0.98V)", 1);
  read_transaction (.master(2), .addr(`SYS_MON_BASE+`SYSMON_XADC_BASE+12'h060), .expdata(32'h0000_53a0), .check(1),
                                                                                .chkbit(32'h0000_FFF0));

  //--------------------------------------------------
  label    = "Read ADC Data (2nd)";
  simcount = 3;
  //--------------------------------------------------
  while ($stime <= 150_000_000)
    @(posedge SYS_CLK);

  display_subcount_text(1, "Read Temperature (30C)", 1);
  read_transaction (.master(2), .addr(`SYS_MON_BASE+`SYSMON_XADC_BASE+12'h000), .expdata(32'h0000_99F0), .check(1),
                                                                                .chkbit(32'h0000_FFF0));

  display_subcount_text(2, "Read VCCINT (1.01V)", 1);
  read_transaction (.master(2), .addr(`SYS_MON_BASE+`SYSMON_XADC_BASE+12'h010), .expdata(32'h0000_5620), .check(1),
                                                                                .chkbit(32'h0000_FFF0));

  display_subcount_text(3, "Read VCCACX (1.81V)", 1);
  read_transaction (.master(2), .addr(`SYS_MON_BASE+`SYSMON_XADC_BASE+12'h020), .expdata(32'h0000_9a70), .check(1),
                                                                                .chkbit(32'h0000_FFF0));

  display_subcount_text(4, "Read VCCBRAM (1.00V)", 1);
  read_transaction (.master(2), .addr(`SYS_MON_BASE+`SYSMON_XADC_BASE+12'h060), .expdata(32'h0000_5550), .check(1),
                                                                                .chkbit(32'h0000_FFF0));

  //--------------------------------------------------
  label    = "Read ADC Data (3rd)";
  simcount = 4;
  //--------------------------------------------------
  while ($stime <= 250_000_000)
    @(posedge SYS_CLK);
  display_subcount_text(1, "Read Temperature (85C)", 1);
  read_transaction (.master(2), .addr(`SYS_MON_BASE+`SYSMON_XADC_BASE+12'h000), .expdata(32'h0000_B5E0), .check(1),
                                                                                .chkbit(32'h0000_FFF0));

  display_subcount_text(2, "Read VCCINT (0.98V)", 1);
  read_transaction (.master(2), .addr(`SYS_MON_BASE+`SYSMON_XADC_BASE+12'h010), .expdata(32'h0000_53a0), .check(0),
                                                                                .chkbit(32'h0000_FFF0));

  display_subcount_text(3, "Read VCCACX (1.84V)", 1);
  read_transaction (.master(2), .addr(`SYS_MON_BASE+`SYSMON_XADC_BASE+12'h020), .expdata(32'h0000_9d00), .check(0),
                                                                                .chkbit(32'h0000_FFF0));

  display_subcount_text(4, "Read VCCBRAM (1.05V)", 1);
  read_transaction (.master(2), .addr(`SYS_MON_BASE+`SYSMON_XADC_BASE+12'h060), .expdata(32'h0000_5990), .check(0),
                                                                                .chkbit(32'h0000_FFF0));

  //--------------------------------------------------
  label    = "Read ADC Min/Max";
  simcount = 5;
  //--------------------------------------------------
  display_subcount_text(1, "Read Temperature Max (85C)", 1);
  read_transaction (.master(2), .addr(`SYS_MON_BASE+`SYSMON_XADC_BASE+12'h200), .expdata(32'h0000_B5E0), .check(1),
                                                                                .chkbit(32'h0000_FFF0));
  display_subcount_text(2, "Read VCCINT Max (1.01V)", 1);
  read_transaction (.master(2), .addr(`SYS_MON_BASE+`SYSMON_XADC_BASE+12'h210), .expdata(32'h0000_5620), .check(1),
                                                                                .chkbit(32'h0000_FFF0));
  display_subcount_text(3, "Read VCCAUX Max (1.84V)", 1);
  read_transaction (.master(2), .addr(`SYS_MON_BASE+`SYSMON_XADC_BASE+12'h220), .expdata(32'h0000_9d00), .check(1),
                                                                                .chkbit(32'h0000_FFF0));
  display_subcount_text(4, "Read VCCBRAM Max (1.05V)", 1);
  read_transaction (.master(2), .addr(`SYS_MON_BASE+`SYSMON_XADC_BASE+12'h230), .expdata(32'h0000_5990), .check(0),
                                                                                .chkbit(32'h0000_FFF0));
  display_subcount_text(5, "Read Temperature Min (25C)", 1);
  read_transaction (.master(2), .addr(`SYS_MON_BASE+`SYSMON_XADC_BASE+12'h240), .expdata(32'h0000_9770), .check(1),
                                                                                .chkbit(32'h0000_FFF0));
  display_subcount_text(6, "Read VCCINT Min (0.98V)", 1);
  read_transaction (.master(2), .addr(`SYS_MON_BASE+`SYSMON_XADC_BASE+12'h250), .expdata(32'h0000_53a0), .check(0),
                                                                                .chkbit(32'h0000_FFF0));
  display_subcount_text(7, "Read VCCACX Min (1.80V)", 1);
  read_transaction (.master(2), .addr(`SYS_MON_BASE+`SYSMON_XADC_BASE+12'h260), .expdata(32'h0000_9990), .check(1),
                                                                                .chkbit(32'h0000_FFF0));
  display_subcount_text(8, "Read VCCBRAM Min (0.98V)", 1);
  read_transaction (.master(2), .addr(`SYS_MON_BASE+`SYSMON_XADC_BASE+12'h270), .expdata(32'h0000_53a0), .check(1),
                                                                                .chkbit(32'h0000_FFF0));
  repeat (200) @ (posedge SYS_CLK);

  simfinish(0);
end

endmodule
