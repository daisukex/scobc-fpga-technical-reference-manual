//-----------------------------------------------
// Space Cubics SC-OBC-A1 FPGA
//  Testcase: Check Board Health Monitor function in System Monitor
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
reg [7:0] reg_adr;
reg [15:0] i2c_data;

task DEV_REG_WR_EXP_SET;
  input [2:0] set_devsel;
  input [7:0] set_regad;
  input [15:0] set_wdata;
  begin
    if (set_devsel == 0) begin
      cvm1.RX_EXP_VAL_SET(0, set_regad);
      cvm1.RX_EXP_VAL_SET(1, set_wdata[15:8]);
      cvm1.RX_EXP_VAL_SET(2, set_wdata[7:0]);
      cvm2.RX_EXP_VAL_SET(0, 8'h00);
      temp1.RX_EXP_VAL_SET(0, 8'h00);
      temp2.RX_EXP_VAL_SET(0, 8'h00);
      temp3.RX_EXP_VAL_SET(0, 8'h00);
    end
    else if (set_devsel == 1) begin
      cvm2.RX_EXP_VAL_SET(0, set_regad);
      cvm2.RX_EXP_VAL_SET(1, set_wdata[15:8]);
      cvm2.RX_EXP_VAL_SET(2, set_wdata[7:0]);
      cvm1.RX_EXP_VAL_SET(0, 8'h00);
      temp1.RX_EXP_VAL_SET(0, 8'h00);
      temp2.RX_EXP_VAL_SET(0, 8'h00);
      temp3.RX_EXP_VAL_SET(0, 8'h00);
    end
    else if (set_devsel == 2) begin
      temp1.RX_EXP_VAL_SET(0, set_regad);
      temp1.RX_EXP_VAL_SET(1, set_wdata[15:8]);
      temp1.RX_EXP_VAL_SET(2, set_wdata[7:0]);
      cvm1.RX_EXP_VAL_SET(0, 8'h00);
      cvm2.RX_EXP_VAL_SET(0, 8'h00);
      temp2.RX_EXP_VAL_SET(0, 8'h00);
      temp3.RX_EXP_VAL_SET(0, 8'h00);
    end
    else if (set_devsel == 3) begin
      temp2.RX_EXP_VAL_SET(0, set_regad);
      temp2.RX_EXP_VAL_SET(1, set_wdata[15:8]);
      temp2.RX_EXP_VAL_SET(2, set_wdata[7:0]);
      cvm1.RX_EXP_VAL_SET(0, 8'h00);
      cvm2.RX_EXP_VAL_SET(0, 8'h00);
      temp1.RX_EXP_VAL_SET(0, 8'h00);
      temp3.RX_EXP_VAL_SET(0, 8'h00);
    end
    else begin
      temp3.RX_EXP_VAL_SET(0, set_regad);
      temp3.RX_EXP_VAL_SET(1, set_wdata[15:8]);
      temp3.RX_EXP_VAL_SET(2, set_wdata[7:0]);
      cvm1.RX_EXP_VAL_SET(0, 8'h00);
      cvm2.RX_EXP_VAL_SET(0, 8'h00);
      temp1.RX_EXP_VAL_SET(0, 8'h00);
      temp2.RX_EXP_VAL_SET(0, 8'h00);
    end
  end
endtask

task DEV_REG_RD_DAT_SET;
  input [2:0] set_devsel;
  input [7:0] set_regad;
  input [15:0] set_rdata;
  begin
    if (set_devsel == 0) begin
      cvm1.RX_EXP_VAL_SET(0, set_regad);
      cvm1.TX_VAL_SET(0, set_rdata[15:8]);
      cvm1.TX_VAL_SET(1, set_rdata[7:0]);
      cvm2.RX_EXP_VAL_SET(0, 8'h00);
      temp1.RX_EXP_VAL_SET(0, 8'h00);
      temp2.RX_EXP_VAL_SET(0, 8'h00);
      temp3.RX_EXP_VAL_SET(0, 8'h00);
      cvm2.TX_VAL_SET(0, 8'h00);
      temp1.TX_VAL_SET(0, 8'h00);
      temp2.TX_VAL_SET(0, 8'h00);
      temp3.TX_VAL_SET(0, 8'h00);
    end
    else if (set_devsel == 1) begin
      cvm2.RX_EXP_VAL_SET(0, set_regad);
      cvm2.TX_VAL_SET(0, set_rdata[15:8]);
      cvm2.TX_VAL_SET(1, set_rdata[7:0]);
      cvm1.RX_EXP_VAL_SET(0, 8'h00);
      temp1.RX_EXP_VAL_SET(0, 8'h00);
      temp2.RX_EXP_VAL_SET(0, 8'h00);
      temp3.RX_EXP_VAL_SET(0, 8'h00);
      cvm1.TX_VAL_SET(0, 8'h00);
      temp1.TX_VAL_SET(0, 8'h00);
      temp2.TX_VAL_SET(0, 8'h00);
      temp3.TX_VAL_SET(0, 8'h00);
    end
    else if (set_devsel == 2) begin
      temp1.RX_EXP_VAL_SET(0, set_regad);
      temp1.TX_VAL_SET(0, set_rdata[15:8]);
      temp1.TX_VAL_SET(1, set_rdata[7:0]);
      cvm1.RX_EXP_VAL_SET(0, 8'h00);
      cvm2.RX_EXP_VAL_SET(0, 8'h00);
      temp2.RX_EXP_VAL_SET(0, 8'h00);
      temp3.RX_EXP_VAL_SET(0, 8'h00);
      cvm1.TX_VAL_SET(0, 8'h00);
      cvm2.TX_VAL_SET(0, 8'h00);
      temp2.TX_VAL_SET(0, 8'h00);
      temp3.TX_VAL_SET(0, 8'h00);
    end
    else if (set_devsel == 3) begin
      temp2.RX_EXP_VAL_SET(0, set_regad);
      temp2.TX_VAL_SET(0, set_rdata[15:8]);
      temp2.TX_VAL_SET(1, set_rdata[7:0]);
      cvm1.RX_EXP_VAL_SET(0, 8'h00);
      cvm2.RX_EXP_VAL_SET(0, 8'h00);
      temp1.RX_EXP_VAL_SET(0, 8'h00);
      temp3.RX_EXP_VAL_SET(0, 8'h00);
      cvm1.TX_VAL_SET(0, 8'h00);
      cvm2.TX_VAL_SET(0, 8'h00);
      temp1.TX_VAL_SET(0, 8'h00);
      temp3.TX_VAL_SET(0, 8'h00);
    end
    else begin
      temp3.RX_EXP_VAL_SET(0, set_regad);
      temp3.TX_VAL_SET(0, set_rdata[15:8]);
      temp3.TX_VAL_SET(1, set_rdata[7:0]);
      cvm1.RX_EXP_VAL_SET(0, 8'h00);
      cvm2.RX_EXP_VAL_SET(0, 8'h00);
      temp1.RX_EXP_VAL_SET(0, 8'h00);
      temp2.RX_EXP_VAL_SET(0, 8'h00);
      cvm1.TX_VAL_SET(0, 8'h00);
      cvm2.TX_VAL_SET(0, 8'h00);
      temp1.TX_VAL_SET(0, 8'h00);
      temp2.TX_VAL_SET(0, 8'h00);
    end
  end
endtask

assign testcase_name = "Check Board Health Monitor function in System Monitor";
initial begin
  timeout_ms = 10;
  skip_sram_init();
  @ (posedge SYS_RSTB);

  //--------------------------------------------------
  label    = "Initialize and Boot System";
  simcount = 0;
  //--------------------------------------------------
  cvm1.FINISH_CTRL(1);
  cvm2.FINISH_CTRL(1);
  temp1.FINISH_CTRL(1);
  temp2.FINISH_CTRL(1);
  temp3.FINISH_CTRL(1);
  cvm1.RX_EXP_COMP_EN(1);
  cvm2.RX_EXP_COMP_EN(1);
  temp1.RX_EXP_COMP_EN(1);
  temp2.RX_EXP_COMP_EN(1);
  temp3.RX_EXP_COMP_EN(1);
  cvm1.SET_DEVADR(0, 7'h40);
  cvm2.SET_DEVADR(0, 7'h41);
  temp1.SET_DEVADR(0, 7'h4C);
  temp2.SET_DEVADR(0, 7'h4D);
  temp3.SET_DEVADR(0, 7'h4E);
  @ (posedge CMC_REQ);
  @ (posedge CMC_ACK);
  @ (posedge PLLLOCK);
  @ (negedge CMC_REQ);
  @ (negedge CMC_ACK);
  display_text("SC-OBC-CORE System Bootup Done", 1, 1);
  @(posedge SYS_CLK);

  //--------------------------------------------------
  label    = "Check Initialize Setting I2C Accsess";
  simcount = 1;
  //--------------------------------------------------
  @(posedge SYS_CLK);
  display_subcount_text(1, "Initialize Setting Access Request Set", 1);
  write_transaction(.master(2), .addr(`SYS_MON_BASE+`SYSMON_BHM_INICTLR),    .data((1        << `SYSMON_BHM_INITREQ) |
                                                                                   (5'b11111 << `SYSMON_BHM_INITEN) ));
  read_transaction( .master(2), .addr(`SYS_MON_BASE+`SYSMON_BHM_INICTLR), .expdata((1        << `SYSMON_BHM_INITREQ) |
                                                                                   (5'b11111 << `SYSMON_BHM_INITEN) ), .check(1));
  for (i=0; i<23; i=i+1) begin
    case (i)                   // devsel, regad, exp_wdata
       0:      DEV_REG_WR_EXP_SET(0,      8'h07, 16'h2710);
       1:      DEV_REG_WR_EXP_SET(0,      8'h08, 16'h1770);
       2:      DEV_REG_WR_EXP_SET(0,      8'h09, 16'h2710);
       3:      DEV_REG_WR_EXP_SET(0,      8'h0A, 16'h1770);
       4:      DEV_REG_WR_EXP_SET(0,      8'h0B, 16'h2710);
       5:      DEV_REG_WR_EXP_SET(0,      8'h0C, 16'h1770);
       6:      DEV_REG_WR_EXP_SET(0,      8'h0F, 16'h0C00);
       7:      DEV_REG_WR_EXP_SET(1,      8'h07, 16'h2710);
       8:      DEV_REG_WR_EXP_SET(1,      8'h08, 16'h1770);
       9:      DEV_REG_WR_EXP_SET(1,      8'h09, 16'h2710);
      10:      DEV_REG_WR_EXP_SET(1,      8'h0A, 16'h1770);
      11:      DEV_REG_WR_EXP_SET(1,      8'h0B, 16'h2710);
      12:      DEV_REG_WR_EXP_SET(1,      8'h0C, 16'h1770);
      13:      DEV_REG_WR_EXP_SET(1,      8'h0F, 16'h0C00);
      14:      DEV_REG_WR_EXP_SET(2,      8'h01, 16'h0200);
      15:      DEV_REG_WR_EXP_SET(2,      8'h02, 16'h4B00);
      16:      DEV_REG_WR_EXP_SET(2,      8'h03, 16'h5000);
      17:      DEV_REG_WR_EXP_SET(3,      8'h01, 16'h0200);
      18:      DEV_REG_WR_EXP_SET(3,      8'h02, 16'h4B00);
      19:      DEV_REG_WR_EXP_SET(3,      8'h03, 16'h5000);
      20:      DEV_REG_WR_EXP_SET(4,      8'h01, 16'h0200);
      21:      DEV_REG_WR_EXP_SET(4,      8'h02, 16'h4B00);
      default: DEV_REG_WR_EXP_SET(4,      8'h03, 16'h5000);
    endcase
    if (i != 22) @(posedge dut.obc_core.lpahb.system_monitor.sysmon_bhm.i2c_comp);
  end
  // Interrupt Check
  write_transaction(.master(2), .addr(`SYS_MON_BASE+`SYSMON_BHM_IER), .data(1<<`SYSMON_BHM_INITACCENDENB));

  display_subcount_text(2, "Initialization Access End Interrupt Check", 1);
  cm3_isr_check(`CM3_ISR_SMON_BHM, 10000);

  display_subcount_text(3, "System Monitor Board Health Monitor Interrupt Status Register Check", 1);
  cm3_sys_ipcore_interrupt_check_and_write_clear(`SYS_MON_BASE+`SYSMON_BHM_ISR, 1<<`SYSMON_BHM_INITACCEND);
  write_transaction(.master(2), .addr(`SYS_MON_BASE+`SYSMON_BHM_IER), .data(32'h00000000));

  display_subcount_text(4, "Check Initialize Setting Access Request Bit Clear", 1);
  read_transaction( .master(2), .addr(`SYS_MON_BASE+`SYSMON_BHM_INICTLR), .expdata(5'b11111 << `SYSMON_BHM_INITEN), .check(1));

  //--------------------------------------------------
  label    = "Check Current Voltage Monitor and Temperature Sensor Measurement Data Monitoring I2C Accsess";
  simcount = 2;
  //--------------------------------------------------
  @(posedge SYS_CLK);
  display_subcount_text(1, "Check Initial Status", 1);
  read_transaction( .master(2), .addr(`SYS_MON_BASE+`SYSMON_BHM_MONCTLR),      .expdata(32'h00000000), .check(1));
  read_transaction( .master(2), .addr(`SYS_MON_BASE+`SYSMON_BHM_1V0SNTVR),     .expdata(1 << `SYSMON_BHM_1V0SNTV_NUPD),     .check(1));
  read_transaction( .master(2), .addr(`SYS_MON_BASE+`SYSMON_BHM_1V0BUSVR),     .expdata(1 << `SYSMON_BHM_1V0BUSV_NUPD),     .check(1));
  read_transaction( .master(2), .addr(`SYS_MON_BASE+`SYSMON_BHM_1V8SNTVR),     .expdata(1 << `SYSMON_BHM_1V8SNTV_NUPD),     .check(1));
  read_transaction( .master(2), .addr(`SYS_MON_BASE+`SYSMON_BHM_1V8BUSVR),     .expdata(1 << `SYSMON_BHM_1V8BUSV_NUPD),     .check(1));
  read_transaction( .master(2), .addr(`SYS_MON_BASE+`SYSMON_BHM_3V3SNTVR),     .expdata(1 << `SYSMON_BHM_3V3SNTV_NUPD),     .check(1));
  read_transaction( .master(2), .addr(`SYS_MON_BASE+`SYSMON_BHM_3V3BUSVR),     .expdata(1 << `SYSMON_BHM_3V3BUSV_NUPD),     .check(1));
  read_transaction( .master(2), .addr(`SYS_MON_BASE+`SYSMON_BHM_3V3SYSASNTVR), .expdata(1 << `SYSMON_BHM_3V3SYSASNTV_NUPD), .check(1));
  read_transaction( .master(2), .addr(`SYS_MON_BASE+`SYSMON_BHM_3V3SYSABUSVR), .expdata(1 << `SYSMON_BHM_3V3SYSABUSV_NUPD), .check(1));
  read_transaction( .master(2), .addr(`SYS_MON_BASE+`SYSMON_BHM_3V3SYSBSNTVR), .expdata(1 << `SYSMON_BHM_3V3SYSBSNTV_NUPD), .check(1));
  read_transaction( .master(2), .addr(`SYS_MON_BASE+`SYSMON_BHM_3V3SYSBBUSVR), .expdata(1 << `SYSMON_BHM_3V3SYSBBUSV_NUPD), .check(1));
  read_transaction( .master(2), .addr(`SYS_MON_BASE+`SYSMON_BHM_3V3IOSNTVR),   .expdata(1 << `SYSMON_BHM_3V3IOSNTV_NUPD),   .check(1));
  read_transaction( .master(2), .addr(`SYS_MON_BASE+`SYSMON_BHM_3V3IOBUSVR),   .expdata(1 << `SYSMON_BHM_3V3IOBUSV_NUPD),   .check(1));
  read_transaction( .master(2), .addr(`SYS_MON_BASE+`SYSMON_BHM_TEMP1R),       .expdata(1 << `SYSMON_BHM_TEMP1_NUPD),       .check(1));
  read_transaction( .master(2), .addr(`SYS_MON_BASE+`SYSMON_BHM_TEMP2R),       .expdata(1 << `SYSMON_BHM_TEMP2_NUPD),       .check(1));
  read_transaction( .master(2), .addr(`SYS_MON_BASE+`SYSMON_BHM_TEMP3R),       .expdata(1 << `SYSMON_BHM_TEMP3_NUPD),       .check(1));

  display_subcount_text(2, "Set Monitoring Enable", 1);
  write_transaction(.master(2), .addr(`SYS_MON_BASE+`SYSMON_BHM_MONCTLR), .data(5'b11111 << `SYSMON_BHM_MONIEN));

  display_subcount_text(3, "Insert Current Voltage Monitor Data Monitoring Access Request Trigger", 1);
  @(posedge SYS_CLK); #1;
  force dut.obc_core.lpahb.system_monitor.CVM_DATA_REQ_TRG = 1'b1;
  @(posedge SYS_CLK); #1;
  release dut.obc_core.lpahb.system_monitor.CVM_DATA_REQ_TRG;
  for (i=0; i<12; i=i+1) begin
    case (i)                   // devsel, regad, rdata
       0:      DEV_REG_RD_DAT_SET(0,      8'h01, 16'h1234);
       1:      DEV_REG_RD_DAT_SET(0,      8'h02, 16'h5678);
       2:      DEV_REG_RD_DAT_SET(0,      8'h03, 16'h9ABC);
       3:      DEV_REG_RD_DAT_SET(0,      8'h04, 16'hDEF1);
       4:      DEV_REG_RD_DAT_SET(0,      8'h05, 16'h2345);
       5:      DEV_REG_RD_DAT_SET(0,      8'h06, 16'h6789);
       6:      DEV_REG_RD_DAT_SET(1,      8'h01, 16'hABCD);
       7:      DEV_REG_RD_DAT_SET(1,      8'h02, 16'hEF12);
       8:      DEV_REG_RD_DAT_SET(1,      8'h03, 16'h3456);
       9:      DEV_REG_RD_DAT_SET(1,      8'h04, 16'h789A);
      10:      DEV_REG_RD_DAT_SET(1,      8'h05, 16'hBCDE);
      default: DEV_REG_RD_DAT_SET(1,      8'h06, 16'hF123);
    endcase
    repeat(2) @(posedge dut.obc_core.lpahb.system_monitor.sysmon_bhm.i2c_comp);
  end

  display_subcount_text(4, "Check Current Voltage Monitor Data", 1);
  read_transaction( .master(2), .addr(`SYS_MON_BASE+`SYSMON_BHM_1V0SNTVR),     .expdata(16'h1234 << `SYSMON_BHM_1V0SNTV),     .check(1));
  read_transaction( .master(2), .addr(`SYS_MON_BASE+`SYSMON_BHM_1V0BUSVR),     .expdata(16'h5678 << `SYSMON_BHM_1V0BUSV),     .check(1));
  read_transaction( .master(2), .addr(`SYS_MON_BASE+`SYSMON_BHM_1V8SNTVR),     .expdata(16'h9ABC << `SYSMON_BHM_1V8SNTV),     .check(1));
  read_transaction( .master(2), .addr(`SYS_MON_BASE+`SYSMON_BHM_1V8BUSVR),     .expdata(16'hDEF1 << `SYSMON_BHM_1V8BUSV),     .check(1));
  read_transaction( .master(2), .addr(`SYS_MON_BASE+`SYSMON_BHM_3V3SNTVR),     .expdata(16'h2345 << `SYSMON_BHM_3V3SNTV),     .check(1));
  read_transaction( .master(2), .addr(`SYS_MON_BASE+`SYSMON_BHM_3V3BUSVR),     .expdata(16'h6789 << `SYSMON_BHM_3V3BUSV),     .check(1));
  read_transaction( .master(2), .addr(`SYS_MON_BASE+`SYSMON_BHM_3V3SYSASNTVR), .expdata(16'hABCD << `SYSMON_BHM_3V3SYSASNTV), .check(1));
  read_transaction( .master(2), .addr(`SYS_MON_BASE+`SYSMON_BHM_3V3SYSABUSVR), .expdata(16'hEF12 << `SYSMON_BHM_3V3SYSABUSV), .check(1));
  read_transaction( .master(2), .addr(`SYS_MON_BASE+`SYSMON_BHM_3V3SYSBSNTVR), .expdata(16'h3456 << `SYSMON_BHM_3V3SYSBSNTV), .check(1));
  read_transaction( .master(2), .addr(`SYS_MON_BASE+`SYSMON_BHM_3V3SYSBBUSVR), .expdata(16'h789A << `SYSMON_BHM_3V3SYSBBUSV), .check(1));
  read_transaction( .master(2), .addr(`SYS_MON_BASE+`SYSMON_BHM_3V3IOSNTVR),   .expdata(16'hBCDE << `SYSMON_BHM_3V3IOSNTV),   .check(1));
  read_transaction( .master(2), .addr(`SYS_MON_BASE+`SYSMON_BHM_3V3IOBUSVR),   .expdata(16'hF123 << `SYSMON_BHM_3V3IOBUSV),   .check(1));

  display_subcount_text(5, "Insert Temperature Sensor Data Monitoring Access Request Trigger", 1);
  @(posedge SYS_CLK); #1;
  force dut.obc_core.lpahb.system_monitor.TEMP_DATA_REQ_TRG = 1'b1;
  @(posedge SYS_CLK); #1;
  release dut.obc_core.lpahb.system_monitor.TEMP_DATA_REQ_TRG;
  for (i=0; i<3; i=i+1) begin
    case (i)                   // devsel, regad, rdata
       0:      DEV_REG_RD_DAT_SET(2,      8'h00, 16'h4567);
       1:      DEV_REG_RD_DAT_SET(3,      8'h00, 16'h89AB);
      default: DEV_REG_RD_DAT_SET(4,      8'h00, 16'hCDEF);
    endcase
    repeat(2) @(posedge dut.obc_core.lpahb.system_monitor.sysmon_bhm.i2c_comp);
  end

  display_subcount_text(6, "Check Temperature Sensor Data", 1);
  read_transaction( .master(2), .addr(`SYS_MON_BASE+`SYSMON_BHM_TEMP1R), .expdata(16'h4567 << `SYSMON_BHM_TEMP1), .check(1));
  read_transaction( .master(2), .addr(`SYS_MON_BASE+`SYSMON_BHM_TEMP2R), .expdata(16'h89AB << `SYSMON_BHM_TEMP2), .check(1));
  read_transaction( .master(2), .addr(`SYS_MON_BASE+`SYSMON_BHM_TEMP3R), .expdata(16'hCDEF << `SYSMON_BHM_TEMP3), .check(1));

  display_subcount_text(7, "Check Status", 1);
  read_transaction( .master(2), .addr(`SYS_MON_BASE+`SYSMON_BHM_MONCTLR), .expdata(5'b11111 << `SYSMON_BHM_MONIEN), .check(1));
  read_transaction( .master(2), .addr(`SYS_MON_BASE+`SYSMON_BHM_ISR), .expdata(32'h00000000), .check(1));

  //--------------------------------------------------
  label    = "Check Software Instructions I2C Write Accsess";
  simcount = 3;
  //--------------------------------------------------
  @(posedge SYS_CLK);
  for (i=0; i<5; i=i+1) begin
    if (i == 0) begin display_subcount_text(1,  "CVM1 I2C Write Access Request Set", 1);  reg_adr = 8'h12; i2c_data = 16'hFEDC; end
    if (i == 1) begin display_subcount_text(11, "CVM2 I2C Write Access Request Set", 1);  reg_adr = 8'h34; i2c_data = 16'hBA98; end
    if (i == 2) begin display_subcount_text(21, "TEMP1 I2C Write Access Request Set", 1); reg_adr = 8'h56; i2c_data = 16'h7654; end
    if (i == 3) begin display_subcount_text(31, "TEMP2 I2C Write Access Request Set", 1); reg_adr = 8'h78; i2c_data = 16'h321F; end
    if (i == 4) begin display_subcount_text(41, "TEMP3 I2C Write Access Request Set", 1); reg_adr = 8'h9A; i2c_data = 16'hEDCB; end
    DEV_REG_WR_EXP_SET(i, reg_adr, i2c_data);
    write_transaction(.master(2), .addr(`SYS_MON_BASE+`SYSMON_BHM_SWWDTR),    .data(i2c_data << `SYSMON_BHM_SWWRDATA));
    write_transaction(.master(2), .addr(`SYS_MON_BASE+`SYSMON_BHM_SWCTLR),    .data((1       << `SYSMON_BHM_SWACCREQ) |
                                                                                    (i       << `SYSMON_BHM_SWDEVSEL) |
                                                                                    (reg_adr << `SYSMON_BHM_SWREGADR) |
                                                                                    (0       << `SYSMON_BHM_SWRWSEL) ));
    read_transaction( .master(2), .addr(`SYS_MON_BASE+`SYSMON_BHM_SWCTLR), .expdata((1       << `SYSMON_BHM_SWACCREQ) |
                                                                                    (i       << `SYSMON_BHM_SWDEVSEL) |
                                                                                    (reg_adr << `SYSMON_BHM_SWREGADR) |
                                                                                    (0       << `SYSMON_BHM_SWRWSEL)), .check(1));
    // Interrupt Check
    write_transaction(.master(2), .addr(`SYS_MON_BASE+`SYSMON_BHM_IER), .data(1<<`SYSMON_BHM_SWACCENDENB));

    display_subcount_text(2+(i*10), "Software Access End Interrupt Check", 1);
    cm3_isr_check(`CM3_ISR_SMON_BHM, 10000);

    display_subcount_text(3+(i*10), "System Monitor Board Health Monitor Interrupt Status Register Check", 1);
    cm3_sys_ipcore_interrupt_check_and_write_clear(`SYS_MON_BASE+`SYSMON_BHM_ISR, 1<<`SYSMON_BHM_SWACCEND);
    write_transaction(.master(2), .addr(`SYS_MON_BASE+`SYSMON_BHM_IER), .data(32'h00000000));

    display_subcount_text(4+(i*10), "Check Software Access Request Bit Clear", 1);
    read_transaction( .master(2), .addr(`SYS_MON_BASE+`SYSMON_BHM_SWCTLR), .expdata((i       << `SYSMON_BHM_SWDEVSEL) |
                                                                                    (reg_adr << `SYSMON_BHM_SWREGADR) |
                                                                                    (0       << `SYSMON_BHM_SWRWSEL)), .check(1));
  end

  //--------------------------------------------------
  label    = "Check Software Instructions I2C Read Accsess";
  simcount = 4;
  //--------------------------------------------------
  @(posedge SYS_CLK);
  for (i=0; i<5; i=i+1) begin
    if (i == 0) begin display_subcount_text(1,  "CVM1 I2C Read Access Request Set", 1);  reg_adr = 8'hBC; i2c_data = 16'hA987; end
    if (i == 1) begin display_subcount_text(11, "CVM2 I2C Read Access Request Set", 1);  reg_adr = 8'hDE; i2c_data = 16'h6543; end
    if (i == 2) begin display_subcount_text(21, "TEMP1 I2C Read Access Request Set", 1); reg_adr = 8'hF1; i2c_data = 16'h21FE; end
    if (i == 3) begin display_subcount_text(31, "TEMP2 I2C Read Access Request Set", 1); reg_adr = 8'h23; i2c_data = 16'hDCBA; end
    if (i == 4) begin display_subcount_text(41, "TEMP3 I2C Read Access Request Set", 1); reg_adr = 8'h45; i2c_data = 16'h9876; end
    DEV_REG_RD_DAT_SET(i, reg_adr, i2c_data);
    write_transaction(.master(2), .addr(`SYS_MON_BASE+`SYSMON_BHM_SWCTLR),    .data((1       << `SYSMON_BHM_SWACCREQ) |
                                                                                    (i       << `SYSMON_BHM_SWDEVSEL) |
                                                                                    (reg_adr << `SYSMON_BHM_SWREGADR) |
                                                                                    (1       << `SYSMON_BHM_SWRWSEL) ));
    read_transaction( .master(2), .addr(`SYS_MON_BASE+`SYSMON_BHM_SWCTLR), .expdata((1       << `SYSMON_BHM_SWACCREQ) |
                                                                                    (i       << `SYSMON_BHM_SWDEVSEL) |
                                                                                    (reg_adr << `SYSMON_BHM_SWREGADR) |
                                                                                    (1       << `SYSMON_BHM_SWRWSEL) ), .check(1));
    // Interrupt Check
    write_transaction(.master(2), .addr(`SYS_MON_BASE+`SYSMON_BHM_IER), .data(1<<`SYSMON_BHM_SWACCENDENB));

    display_subcount_text(2+(i*10), "Software Access End Interrupt Check", 1);
    cm3_isr_check(`CM3_ISR_SMON_BHM, 10000);

    display_subcount_text(3+(i*10), "System Monitor Board Health Monitor Interrupt Status Register Check", 1);
    cm3_sys_ipcore_interrupt_check_and_write_clear(`SYS_MON_BASE+`SYSMON_BHM_ISR, 1<<`SYSMON_BHM_SWACCEND);
    write_transaction(.master(2), .addr(`SYS_MON_BASE+`SYSMON_BHM_IER), .data(32'h00000000));

    display_subcount_text(4+(i*10), "Check Software Access Request Bit Clear", 1);
    read_transaction( .master(2), .addr(`SYS_MON_BASE+`SYSMON_BHM_SWCTLR), .expdata((i       << `SYSMON_BHM_SWDEVSEL) |
                                                                                    (reg_adr << `SYSMON_BHM_SWREGADR) |
                                                                                    (1       << `SYSMON_BHM_SWRWSEL) ), .check(1));

    display_subcount_text(5+(i*10), "Check Read Data", 1);
    read_transaction( .master(2), .addr(`SYS_MON_BASE+`SYSMON_BHM_SWRDTR), .expdata(i2c_data << `SYSMON_BHM_SWRDDATA), .check(1));
  end

  repeat (100) @ (posedge SYS_CLK);
  simfinish(0);
end

endmodule
