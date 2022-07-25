//-----------------------------------------------
// Space Cubics SC-OBC-A1 FPGA
//  Testcase: Check SRAM Controller
//-----------------------------------------------
// Copyright © 2022 Space Cubics, LLC.
//-----------------------------------------------

`timescale 1ps/1ps

module tb_top;

parameter TB_SRAM_ENABLE = 1;
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

assign testcase_name = "Check SRAM Controller";
initial begin
  timeout_ms = 5;
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
  label    = "Cortex-M3 ITCM Access Check ";
  simcount = 1;
  //--------------------------------------------------
  @(posedge SYS_CLK);
  display_subcount_text(1, "Check CFGITCMEN Initial Value", 1);
  read_transaction( .master(2), .addr(`SYSREG_BASE+`SYSREG_CODEMSEL), .expdata(1<<`SR_ITCMEN), .check(1));
  display_subcount_text(2, "ITCM Write Access", 1);
  write_transaction(.master(1), .addr(32'h0000_0000), .data(32'h1234_5678));
  write_transaction(.master(1), .addr(32'h0000_0004), .data(32'h2345_6789));
  write_transaction(.master(1), .addr(32'h0000_0008), .data(32'h3456_789A));
  write_transaction(.master(1), .addr(32'h0000_000C), .data(32'h4567_89AB));
  write_transaction(.master(1), .addr(32'h0000_0010), .data(32'h5678_9ABC));
  write_transaction(.master(1), .addr(32'h0000_0014), .data(32'h6789_ABCD));
  write_transaction(.master(1), .addr(32'h0000_0018), .data(32'h789A_BCDE));
  write_transaction(.master(1), .addr(32'h0000_001C), .data(32'h89AB_CDEF));
  display_subcount_text(3, "ITCM Read Access", 1);
  read_transaction( .master(1), .addr(32'h0000_0000), .expdata(32'h1234_5678), .check(1));
  read_transaction( .master(0), .addr(32'h0000_0004), .expdata(32'h2345_6789), .check(1));
  read_transaction( .master(1), .addr(32'h0000_0008), .expdata(32'h3456_789A), .check(1));
  read_transaction( .master(0), .addr(32'h0000_000C), .expdata(32'h4567_89AB), .check(1));
  read_transaction( .master(1), .addr(32'h0000_0010), .expdata(32'h5678_9ABC), .check(1));
  read_transaction( .master(0), .addr(32'h0000_0014), .expdata(32'h6789_ABCD), .check(1));
  read_transaction( .master(1), .addr(32'h0000_0018), .expdata(32'h789A_BCDE), .check(1));
  read_transaction( .master(0), .addr(32'h0000_001C), .expdata(32'h89AB_CDEF), .check(1));

  //--------------------------------------------------
  label    = "Change ITCM enable from 1 to 0";
  simcount = 2;
  //--------------------------------------------------
  @(posedge SYS_CLK);
  write_transaction(.master(2), .addr(`SYSREG_BASE+`SYSREG_CODEMSEL), .data(0<<`SR_ITCMEN));
  read_transaction( .master(2), .addr(`SYSREG_BASE+`SYSREG_CODEMSEL), .expdata(1<<`SR_ITCMEN), .check(1));
  write_transaction(.master(2), .addr(`SYSREG_BASE+`SYSREG_CODEMSEL), .data(16'h5A5A<<`SR_ITCMENPKC |
                                                                             0<<`SR_ITCMEN));
  @ (posedge SYS_RSTB);
  repeat (100) @(posedge SYS_CLK);
  read_transaction( .master(2), .addr(`SYSREG_BASE+`SYSREG_CODEMSEL), .expdata(0<<`SR_ITCMEN), .check(1));

  //--------------------------------------------------
  label    = "SRAM Access Check ";
  simcount = 3;
  //--------------------------------------------------
  @(posedge SYS_CLK);
  display_subcount_text(1, "Check SRAM Initial Value", 1);
  read_transaction( .master(1), .addr(32'h0000_0000), .expdata(32'h0000_0000), .check(1));
  read_transaction( .master(0), .addr(32'h0000_0004), .expdata(32'h0000_0000), .check(1));
  read_transaction( .master(1), .addr(32'h0000_0008), .expdata(32'h0000_0000), .check(1));
  read_transaction( .master(0), .addr(32'h0000_000C), .expdata(32'h0000_0000), .check(1));
  read_transaction( .master(1), .addr(32'h0000_0010), .expdata(32'h0000_0000), .check(1));
  read_transaction( .master(0), .addr(32'h0000_0014), .expdata(32'h0000_0000), .check(1));
  read_transaction( .master(1), .addr(32'h0000_0018), .expdata(32'h0000_0000), .check(1));
  read_transaction( .master(0), .addr(32'h0000_001C), .expdata(32'h0000_0000), .check(1));
  read_transaction( .master(1), .addr(32'h003F_FFE0), .expdata(32'h0000_0000), .check(1));
  read_transaction( .master(0), .addr(32'h003F_FFE4), .expdata(32'h0000_0000), .check(1));
  read_transaction( .master(1), .addr(32'h003F_FFE8), .expdata(32'h0000_0000), .check(1));
  read_transaction( .master(0), .addr(32'h003F_FFEC), .expdata(32'h0000_0000), .check(1));
  read_transaction( .master(1), .addr(32'h003F_FFF0), .expdata(32'h0000_0000), .check(1));
  read_transaction( .master(0), .addr(32'h003F_FFF4), .expdata(32'h0000_0000), .check(1));
  read_transaction( .master(1), .addr(32'h003F_FFF8), .expdata(32'h0000_0000), .check(1));
  read_transaction( .master(0), .addr(32'h003F_FFFC), .expdata(32'h0000_0000), .check(1));
  display_subcount_text(2, "SRAM Write Access from CM3 Code Bus", 1);
  write_transaction(.master(1), .addr(32'h0000_0000), .data(32'hFEDC_BA98));
  write_transaction(.master(1), .addr(32'h0000_0004), .data(32'hEDCB_A987));
  write_transaction(.master(1), .addr(32'h0000_0008), .data(32'hDCBA_9876));
  write_transaction(.master(1), .addr(32'h0000_000C), .data(32'hCBA9_8765));
  write_transaction(.master(1), .addr(32'h0000_0010), .data(32'hBA98_7654));
  write_transaction(.master(1), .addr(32'h0000_0014), .data(32'hA987_6543));
  write_transaction(.master(1), .addr(32'h0000_0018), .data(32'h9876_5432));
  write_transaction(.master(1), .addr(32'h0000_001C), .data(32'h8765_4321));
  write_transaction(.master(1), .addr(32'h003F_FFE0), .data(32'h7654_3210));
  write_transaction(.master(1), .addr(32'h003F_FFE4), .data(32'h6543_210F));
  write_transaction(.master(1), .addr(32'h003F_FFE8), .data(32'h5432_10FE));
  write_transaction(.master(1), .addr(32'h003F_FFEC), .data(32'h4321_0FED));
  write_transaction(.master(1), .addr(32'h003F_FFF0), .data(32'h3210_FEDC));
  write_transaction(.master(1), .addr(32'h003F_FFF4), .data(32'h210F_EDCB));
  write_transaction(.master(1), .addr(32'h003F_FFF8), .data(32'h10FE_DCBA));
  write_transaction(.master(1), .addr(32'h003F_FFFC), .data(32'h0FED_CBA9));
  display_subcount_text(3, "SRAM Read Access from CM3 System Bus", 1);
  read_transaction( .master(2), .addr(`HRMEM_MR_BASE+24'h00_0000), .expdata(32'hFEDC_BA98), .check(1));
  read_transaction( .master(2), .addr(`HRMEM_MR_BASE+24'h00_0004), .expdata(32'hEDCB_A987), .check(1));
  read_transaction( .master(2), .addr(`HRMEM_MR_BASE+24'h00_0008), .expdata(32'hDCBA_9876), .check(1));
  read_transaction( .master(2), .addr(`HRMEM_MR_BASE+24'h00_000C), .expdata(32'hCBA9_8765), .check(1));
  read_transaction( .master(2), .addr(`HRMEM_MR_BASE+24'h00_0010), .expdata(32'hBA98_7654), .check(1));
  read_transaction( .master(2), .addr(`HRMEM_MR_BASE+24'h00_0014), .expdata(32'hA987_6543), .check(1));
  read_transaction( .master(2), .addr(`HRMEM_MR_BASE+24'h00_0018), .expdata(32'h9876_5432), .check(1));
  read_transaction( .master(2), .addr(`HRMEM_MR_BASE+24'h00_001C), .expdata(32'h8765_4321), .check(1));
  read_transaction( .master(2), .addr(`HRMEM_MR_BASE+24'h3F_FFE0), .expdata(32'h7654_3210), .check(1));
  read_transaction( .master(2), .addr(`HRMEM_MR_BASE+24'h3F_FFE4), .expdata(32'h6543_210F), .check(1));
  read_transaction( .master(2), .addr(`HRMEM_MR_BASE+24'h3F_FFE8), .expdata(32'h5432_10FE), .check(1));
  read_transaction( .master(2), .addr(`HRMEM_MR_BASE+24'h3F_FFEC), .expdata(32'h4321_0FED), .check(1));
  read_transaction( .master(2), .addr(`HRMEM_MR_BASE+24'h3F_FFF0), .expdata(32'h3210_FEDC), .check(1));
  read_transaction( .master(2), .addr(`HRMEM_MR_BASE+24'h3F_FFF4), .expdata(32'h210F_EDCB), .check(1));
  read_transaction( .master(2), .addr(`HRMEM_MR_BASE+24'h3F_FFF8), .expdata(32'h10FE_DCBA), .check(1));
  read_transaction( .master(2), .addr(`HRMEM_MR_BASE+24'h3F_FFFC), .expdata(32'h0FED_CBA9), .check(1));
  display_subcount_text(4, "SRAM Write Access from CM3 System Bus", 1);
  write_transaction(.master(2), .addr(`HRMEM_MR_BASE+24'h00_0000), .data(32'hFDB9_7531));
  write_transaction(.master(2), .addr(`HRMEM_MR_BASE+24'h00_0004), .data(32'hDB97_531F));
  write_transaction(.master(2), .addr(`HRMEM_MR_BASE+24'h00_0008), .data(32'hB975_31FD));
  write_transaction(.master(2), .addr(`HRMEM_MR_BASE+24'h00_000C), .data(32'h9753_1FDB));
  write_transaction(.master(2), .addr(`HRMEM_MR_BASE+24'h00_0010), .data(32'h7531_FDB9));
  write_transaction(.master(2), .addr(`HRMEM_MR_BASE+24'h00_0014), .data(32'h531F_DB97));
  write_transaction(.master(2), .addr(`HRMEM_MR_BASE+24'h00_0018), .data(32'h31FD_B975));
  write_transaction(.master(2), .addr(`HRMEM_MR_BASE+24'h00_001C), .data(32'h1FDB_9753));
  write_transaction(.master(2), .addr(`HRMEM_MR_BASE+24'h3F_FFE0), .data(32'hECA8_6420));
  write_transaction(.master(2), .addr(`HRMEM_MR_BASE+24'h3F_FFE4), .data(32'hCA86_420E));
  write_transaction(.master(2), .addr(`HRMEM_MR_BASE+24'h3F_FFE8), .data(32'hA864_20EC));
  write_transaction(.master(2), .addr(`HRMEM_MR_BASE+24'h3F_FFEC), .data(32'h8642_0ECA));
  write_transaction(.master(2), .addr(`HRMEM_MR_BASE+24'h3F_FFF0), .data(32'h6420_ECA8));
  write_transaction(.master(2), .addr(`HRMEM_MR_BASE+24'h3F_FFF4), .data(32'h420E_CA86));
  write_transaction(.master(2), .addr(`HRMEM_MR_BASE+24'h3F_FFF8), .data(32'h20EC_A864));
  write_transaction(.master(2), .addr(`HRMEM_MR_BASE+24'h3F_FFFC), .data(32'h0ECA_8642));
  display_subcount_text(5, "SRAM Read Access from CM3 Code Bus", 1);
  read_transaction( .master(1), .addr(32'h0000_0000), .expdata(32'hFDB9_7531), .check(1));
  read_transaction( .master(0), .addr(32'h0000_0004), .expdata(32'hDB97_531F), .check(1));
  read_transaction( .master(1), .addr(32'h0000_0008), .expdata(32'hB975_31FD), .check(1));
  read_transaction( .master(0), .addr(32'h0000_000C), .expdata(32'h9753_1FDB), .check(1));
  read_transaction( .master(1), .addr(32'h0000_0010), .expdata(32'h7531_FDB9), .check(1));
  read_transaction( .master(0), .addr(32'h0000_0014), .expdata(32'h531F_DB97), .check(1));
  read_transaction( .master(1), .addr(32'h0000_0018), .expdata(32'h31FD_B975), .check(1));
  read_transaction( .master(0), .addr(32'h0000_001C), .expdata(32'h1FDB_9753), .check(1));
  read_transaction( .master(1), .addr(32'h003F_FFE0), .expdata(32'hECA8_6420), .check(1));
  read_transaction( .master(0), .addr(32'h003F_FFE4), .expdata(32'hCA86_420E), .check(1));
  read_transaction( .master(1), .addr(32'h003F_FFE8), .expdata(32'hA864_20EC), .check(1));
  read_transaction( .master(0), .addr(32'h003F_FFEC), .expdata(32'h8642_0ECA), .check(1));
  read_transaction( .master(1), .addr(32'h003F_FFF0), .expdata(32'h6420_ECA8), .check(1));
  read_transaction( .master(0), .addr(32'h003F_FFF4), .expdata(32'h420E_CA86), .check(1));
  read_transaction( .master(1), .addr(32'h003F_FFF8), .expdata(32'h20EC_A864), .check(1));
  read_transaction( .master(0), .addr(32'h003F_FFFC), .expdata(32'h0ECA_8642), .check(1));

  //--------------------------------------------------
  label    = "Change ITCM enable from 0 to 1";
  simcount = 4;
  //--------------------------------------------------
  @(posedge SYS_CLK);
  write_transaction(.master(2), .addr(`SYSREG_BASE+`SYSREG_CODEMSEL), .data(16'h5A5A<<`SR_ITCMENPKC |
                                                                             1<<`SR_ITCMEN));
  @ (posedge SYS_RSTB);
  repeat (100) @(posedge SYS_CLK);
  read_transaction( .master(2), .addr(`SYSREG_BASE+`SYSREG_CODEMSEL), .expdata(1<<`SR_ITCMEN), .check(1));

  //--------------------------------------------------
  label    = "Cortex-M3 ITCM Re-Access Check ";
  simcount = 5;
  //--------------------------------------------------
  @(posedge SYS_CLK);
  display_subcount_text(1, "ITCM Read Access", 1);
  read_transaction( .master(1), .addr(32'h0000_0000), .expdata(32'h1234_5678), .check(1));
  read_transaction( .master(0), .addr(32'h0000_0004), .expdata(32'h2345_6789), .check(1));
  read_transaction( .master(1), .addr(32'h0000_0008), .expdata(32'h3456_789A), .check(1));
  read_transaction( .master(0), .addr(32'h0000_000C), .expdata(32'h4567_89AB), .check(1));
  read_transaction( .master(1), .addr(32'h0000_0010), .expdata(32'h5678_9ABC), .check(1));
  read_transaction( .master(0), .addr(32'h0000_0014), .expdata(32'h6789_ABCD), .check(1));
  read_transaction( .master(1), .addr(32'h0000_0018), .expdata(32'h789A_BCDE), .check(1));
  read_transaction( .master(0), .addr(32'h0000_001C), .expdata(32'h89AB_CDEF), .check(1));
  display_subcount_text(2, "ITCM Write Access", 1);
  write_transaction(.master(1), .addr(32'h0000_0000), .data(32'h1357_9BDF));
  write_transaction(.master(1), .addr(32'h0000_0004), .data(32'h3579_BDF1));
  write_transaction(.master(1), .addr(32'h0000_0008), .data(32'h579B_DF13));
  write_transaction(.master(1), .addr(32'h0000_000C), .data(32'h79BD_F135));
  write_transaction(.master(1), .addr(32'h0000_0010), .data(32'h9BDF_1357));
  write_transaction(.master(1), .addr(32'h0000_0014), .data(32'hBDF1_3579));
  write_transaction(.master(1), .addr(32'h0000_0018), .data(32'hDF13_579B));
  write_transaction(.master(1), .addr(32'h0000_001C), .data(32'hF135_79BD));
  display_subcount_text(3, "ITCM Read Access", 1);
  read_transaction( .master(1), .addr(32'h0000_0000), .expdata(32'h1357_9BDF), .check(1));
  read_transaction( .master(0), .addr(32'h0000_0004), .expdata(32'h3579_BDF1), .check(1));
  read_transaction( .master(1), .addr(32'h0000_0008), .expdata(32'h579B_DF13), .check(1));
  read_transaction( .master(0), .addr(32'h0000_000C), .expdata(32'h79BD_F135), .check(1));
  read_transaction( .master(1), .addr(32'h0000_0010), .expdata(32'h9BDF_1357), .check(1));
  read_transaction( .master(0), .addr(32'h0000_0014), .expdata(32'hBDF1_3579), .check(1));
  read_transaction( .master(1), .addr(32'h0000_0018), .expdata(32'hDF13_579B), .check(1));
  read_transaction( .master(0), .addr(32'h0000_001C), .expdata(32'hF135_79BD), .check(1));

  //--------------------------------------------------
  label    = "HRMEM Register Access Check ";
  simcount = 6;
  //--------------------------------------------------
  @(posedge SYS_CLK);
  display_subcount_text(1, "Check Status Register", 1);
  read_transaction( .master(2), .addr(`HRMEMREG_BASE+`HRMINTSTR), .expdata(0), .check(1));
  read_transaction( .master(2), .addr(`HRMEMREG_BASE+`ECCERRCNTR), .expdata(0), .check(1));
  read_transaction( .master(2), .addr(`HRMEMREG_BASE+`ECDISCNTR), .expdata(0), .check(1));
  display_subcount_text(2, "Check ECC Enable Register", 1);
  read_transaction( .master(2), .addr(`HRMEMREG_BASE+`ECCCOLENR), .expdata(1<<`ECCCOLEN), .check(1));
  write_transaction(.master(2), .addr(`HRMEMREG_BASE+`ECCCOLENR), .data(0<<`ECCCOLEN));
  read_transaction( .master(2), .addr(`HRMEMREG_BASE+`ECCCOLENR), .expdata(0<<`ECCCOLEN), .check(1));
  display_subcount_text(3, "Check Memory Scrubing Control Register", 1);
  read_transaction( .master(2), .addr(`HRMEMREG_BASE+`MEMSCRCTRLR), .expdata(1<<`MEMSCRCYC), .check(1));
  write_transaction(.master(2), .addr(`HRMEMREG_BASE+`MEMSCRCTRLR), .data((1<<`MEMSCRBEN) |
                                                                          (1<<`COLFSRDSTPB) |
                                                                          (16'hFFFE<<`MEMSCRCYC)));
  read_transaction( .master(2), .addr(`HRMEMREG_BASE+`MEMSCRCTRLR), .expdata((1<<`MEMSCRBEN) |
                                                                             (1<<`COLFSRDSTPB) |
                                                                             (16'hFFFE<<`MEMSCRCYC)), .check(1));

  repeat (100) @ (posedge SYS_CLK);
  simfinish(0);
end

endmodule
