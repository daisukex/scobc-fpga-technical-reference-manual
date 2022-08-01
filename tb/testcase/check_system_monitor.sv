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

integer i;
reg [31:0] fpga_toggle_counter = 0;

task clear_toggle_counter;
begin
  fpga_toggle_counter = 0;
end
endtask

always @ (posedge FPGA_WATCHDOG or negedge FPGA_WATCHDOG) begin
  fpga_toggle_counter = fpga_toggle_counter + 1;
end

assign testcase_name = "Check System Monitor";
initial begin
  timeout_ms = 10;
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
  label    = "Watchdog Signal fast mode";
  simcount = 1;
  //--------------------------------------------------
  @(posedge SYS_CLK);
  force dut.obc_core.lpahb.system_monitor.sysmon_reg.SWDOG_LOWCUP_VALUE = 24'h01546;
  repeat (10) @(posedge SYS_CLK);

  @(posedge SYS_CLK);
  read_transaction( .master(2), .addr(`SYS_MON_BASE+`SYSMON_WDOG_SIVAL), .expdata(20'h03A97F<<`SM_WDOG_SIVAL), .check(1));
  write_transaction(.master(2), .addr(`SYS_MON_BASE+`SYSMON_WDOG_SIVAL),    .data(20'h00095F<<`SM_WDOG_SIVAL));
  read_transaction( .master(2), .addr(`SYS_MON_BASE+`SYSMON_WDOG_SIVAL), .expdata(20'h00095F<<`SM_WDOG_SIVAL), .check(1));
  repeat (10) @(posedge SYS_CLK);

  //--------------------------------------------------
  label    = "Check Watchdog Signal (Not Incriment)";
  simcount = 2;
  //--------------------------------------------------
  clear_toggle_counter;
  i = 1;
  repeat (20) begin
    #(10_000_000);
    display_subcount_text(i, "Watchdog Wait", 1);
    i = i + 1;
  end
  if (fpga_toggle_counter != 0) begin
    display_text("Watchdog Toggle Error", 1, 1);
    $finish();
  end
  repeat (10) @(posedge SYS_CLK);

  //--------------------------------------------------
  label    = "Check Software Watchdog";
  simcount = 3;
  //--------------------------------------------------
  @(posedge SYS_CLK);
  read_transaction( .master(2), .addr(`SYS_MON_BASE+`SYSMON_WDOG_CTRL), .expdata(1'b0  <<`SM_WDOG_START |
                                                                                 1'b0  <<`SM_TRCH_WDOG_SE |
                                                                                 1'b0  <<`SM_SW_WDOG_RESET |
                                                                                 1'b0  <<`SM_HW_WDOG_RESET |
                                                                                 8'h00 <<`SM_SW_WDOG_TIME), .check(1));
  write_transaction(.master(2), .addr(`SYS_MON_BASE+`SYSMON_WDOG_CTRL),    .data(1'b1  <<`SM_WDOG_START |
                                                                                 1'b1  <<`SM_TRCH_WDOG_SE |
                                                                                 1'b1  <<`SM_SW_WDOG_RESET |
                                                                                 1'b0  <<`SM_HW_WDOG_RESET |
                                                                                 8'h00 <<`SM_SW_WDOG_TIME));
  read_transaction( .master(2), .addr(`SYS_MON_BASE+`SYSMON_WDOG_CTRL), .expdata(1'b1  <<`SM_WDOG_START |
                                                                                 1'b1  <<`SM_TRCH_WDOG_SE |
                                                                                 1'b1  <<`SM_SW_WDOG_RESET |
                                                                                 1'b0  <<`SM_HW_WDOG_RESET |
                                                                                 8'h00 <<`SM_SW_WDOG_TIME), .check(1));
  repeat (20) @ (posedge SYS_CLK);
  i=1;
  repeat (20) begin
    display_subcount_text(i, "Software Watchdog Kick", 1);
    write_transaction(.master(2), .addr(`SYS_MON_BASE+`SYSMON_WDOG_WSR),     .data(16'h5A5A <<`SM_WDOG_WSR));
    #(10_000_000);
    i = i + 1;

    display_subcount_text(i, "Software Watchdog Kick", 1);
    write_transaction(.master(2), .addr(`SYS_MON_BASE+`SYSMON_WDOG_WSR),     .data(16'hA5A5 <<`SM_WDOG_WSR));
    #(10_000_000);
    i = i + 1;
  end

  if (fpga_toggle_counter == 0) begin
    display_text("Watchdog Toggle Error", 1, 1);
    $finish();
  end
  repeat (10) @(posedge SYS_CLK);

  //--------------------------------------------------
  label    = "Software Watchdog Kick Stop (Software Reset)";
  simcount = 4;
  //--------------------------------------------------
  @ (posedge dut.obc_core.lpahb.system_monitor.sysmon_reg.wdog_expire);
  @ (posedge dut.obc_core.lpahb.system_monitor.sysmon_reg.HRESETN);

  //--------------------------------------------------
  label    = "System Restart";
  simcount = 11;
  //--------------------------------------------------
  @(posedge SYS_CLK);
  force dut.obc_core.lpahb.system_monitor.sysmon_reg.SWDOG_LOWCUP_VALUE = 24'h01546;
  repeat (10) @(posedge SYS_CLK);

  @(posedge SYS_CLK);
  read_transaction( .master(2), .addr(`SYS_MON_BASE+`SYSMON_WDOG_SIVAL), .expdata(20'h03A97F<<`SM_WDOG_SIVAL), .check(1));
  write_transaction(.master(2), .addr(`SYS_MON_BASE+`SYSMON_WDOG_SIVAL),    .data(20'h00095F<<`SM_WDOG_SIVAL));
  read_transaction( .master(2), .addr(`SYS_MON_BASE+`SYSMON_WDOG_SIVAL), .expdata(20'h00095F<<`SM_WDOG_SIVAL), .check(1));
  repeat (10) @(posedge SYS_CLK);

  //--------------------------------------------------
  label    = "Check Software Watchdog";
  simcount = 12;
  //--------------------------------------------------
  @(posedge SYS_CLK);
  read_transaction( .master(2), .addr(`SYS_MON_BASE+`SYSMON_WDOG_CTRL), .expdata(1'b0  <<`SM_WDOG_START |
                                                                                 1'b0  <<`SM_TRCH_WDOG_SE |
                                                                                 1'b0  <<`SM_SW_WDOG_RESET |
                                                                                 1'b0  <<`SM_HW_WDOG_RESET |
                                                                                 8'h00 <<`SM_SW_WDOG_TIME), .check(1));
  write_transaction(.master(2), .addr(`SYS_MON_BASE+`SYSMON_WDOG_CTRL),    .data(1'b1  <<`SM_WDOG_START |
                                                                                 1'b1  <<`SM_TRCH_WDOG_SE |
                                                                                 1'b0  <<`SM_SW_WDOG_RESET |
                                                                                 1'b0  <<`SM_HW_WDOG_RESET |
                                                                                 8'h00 <<`SM_SW_WDOG_TIME));
  read_transaction( .master(2), .addr(`SYS_MON_BASE+`SYSMON_WDOG_CTRL), .expdata(1'b1  <<`SM_WDOG_START |
                                                                                 1'b1  <<`SM_TRCH_WDOG_SE |
                                                                                 1'b0  <<`SM_SW_WDOG_RESET |
                                                                                 1'b0  <<`SM_HW_WDOG_RESET |
                                                                                 8'h00 <<`SM_SW_WDOG_TIME), .check(1));

  repeat (20) @ (posedge SYS_CLK);
  i=1;
  repeat (20) begin
    display_subcount_text(i, "Software Watchdog Kick", 1);
    write_transaction(.master(2), .addr(`SYS_MON_BASE+`SYSMON_WDOG_WSR),     .data(16'h5A5A <<`SM_WDOG_WSR));
    #(10_000_000);
    i = i + 1;

    display_subcount_text(i, "Software Watchdog Kick", 1);
    write_transaction(.master(2), .addr(`SYS_MON_BASE+`SYSMON_WDOG_WSR),     .data(16'hA5A5 <<`SM_WDOG_WSR));
    #(10_000_000);
    i = i + 1;
  end

  if (fpga_toggle_counter == 0) begin
    display_text("Watchdog Toggle Error", 1, 1);
    $finish();
  end
  repeat (10) @(posedge SYS_CLK);

  //--------------------------------------------------
  label    = "Software Watchdog Kick Stop (Watchdog Expire)";
  simcount = 13;
  //--------------------------------------------------
  @ (posedge dut.obc_core.lpahb.system_monitor.sysmon_reg.wdog_expire);
  clear_toggle_counter;
  i = 1;
  repeat (20) begin
    #(10_000_000);
    display_subcount_text(i, "Watchdog Wait", 0);
    i = i + 1;
  end
  if (fpga_toggle_counter != 0) begin
    display_text("Watchdog Toggle Error", 1, 1);
    $finish();
  end

  //--------------------------------------------------
  label    = "TRCH Watchdog Stop Enable OFF";
  simcount = 14;
  //--------------------------------------------------
  @(posedge SYS_CLK);
  write_transaction(.master(2), .addr(`SYS_MON_BASE+`SYSMON_WDOG_CTRL),    .data(1'b1  <<`SM_WDOG_START |
                                                                                 1'b0  <<`SM_TRCH_WDOG_SE |
                                                                                 1'b0  <<`SM_SW_WDOG_RESET |
                                                                                 1'b0  <<`SM_HW_WDOG_RESET |
                                                                                 8'h00 <<`SM_SW_WDOG_TIME));
  read_transaction( .master(2), .addr(`SYS_MON_BASE+`SYSMON_WDOG_CTRL), .expdata(1'b1  <<`SM_WDOG_START |
                                                                                 1'b0  <<`SM_TRCH_WDOG_SE |
                                                                                 1'b0  <<`SM_SW_WDOG_RESET |
                                                                                 1'b0  <<`SM_HW_WDOG_RESET |
                                                                                 8'h00 <<`SM_SW_WDOG_TIME), .check(1));

  clear_toggle_counter;
  i = 1;
  repeat (20) begin
    #(10_000_000);
    display_subcount_text(i, "Watchdog Wait", 0);
    i = i + 1;
  end
  if (fpga_toggle_counter == 0) begin
    display_text("Watchdog Toggle Error", 1, 1);
    $finish();
  end

  repeat (200) @ (posedge SYS_CLK);

  simfinish(0);
end

endmodule
