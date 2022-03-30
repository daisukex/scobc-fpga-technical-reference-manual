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

integer i, j;
reg [7:0] dbyte0, dbyte1, dbyte2, dbyte3;
reg [31:0] regdata;

assign testcase_name = "Check ITCM Address Range";
initial begin
  timeout_ms = 5;
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

  //--------------------------------------------------
  label    = "Write/Read ITCM D-Code Bus";
  simcount = 1;
  //--------------------------------------------------
  @(posedge SYS_CLK);

  display_subcount_text(1, "Write ITCM from D-Code Bus", 1);
  j=0;
  for (i=0; i<8192; i=i+4) begin
    dbyte0 = j;
    dbyte1 = j + 1;
    dbyte2 = j + 2;
    dbyte3 = j + 3;
    regdata = {dbyte3, dbyte2, dbyte1, dbyte0};
    write_transaction(.master(1), .addr(i), .data(regdata));
    j=j+1;
  end

  j=0;
  for (i=0; i<8192; i=i+4) begin
    dbyte0 = j;
    dbyte1 = j + 1;
    dbyte2 = j + 2;
    dbyte3 = j + 3;
    regdata = {dbyte3, dbyte2, dbyte1, dbyte0};
    read_transaction( .master(1), .addr(i), .expdata(regdata), .check(1));
    j=j+1;
  end

  //--------------------------------------------------
  label    = "Write/Read ITCM I-Code Bus";
  simcount = 2;
  //--------------------------------------------------
  @(posedge SYS_CLK);

  display_subcount_text(1, "Read ITCM from I-Code Bus", 1);
  j=0;
  for (i=0; i<8192; i=i+4) begin
    dbyte0 = j;
    dbyte1 = j + 1;
    dbyte2 = j + 2;
    dbyte3 = j + 3;
    regdata = {dbyte3, dbyte2, dbyte1, dbyte0};
    read_transaction( .master(0), .addr(i), .expdata(regdata), .check(1));
    j=j+1;
  end

  //--------------------------------------------------
  label    = "ITCM Access Range Over";
  simcount = 3;
  //--------------------------------------------------
  write_transaction(.master(1), .addr(32'h0000_2000),    .data(32'hFCFD_FEFF));
  read_transaction (.master(1), .addr(32'h0000_2000), .expdata(32'hFCFD_FEFF), .check(1));
  read_transaction (.master(0), .addr(32'h0000_2000), .expdata(32'hFCFD_FEFF), .check(1));
  read_transaction (.master(1), .addr(32'h0000_0000), .expdata(32'hFCFD_FEFF), .check(1));
  read_transaction (.master(0), .addr(32'h0000_0000), .expdata(32'hFCFD_FEFF), .check(1));
  repeat (100) @ (posedge SYS_CLK);
  simfinish(0);
end

endmodule
