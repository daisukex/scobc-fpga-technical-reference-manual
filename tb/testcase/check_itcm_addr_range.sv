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

integer i;

assign testcase_name = "Check ITCM Address Range";
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

  //--------------------------------------------------
  label    = "Write/Read ITCM D-Code Bus";
  simcount = 1;
  //--------------------------------------------------
  @(posedge SYS_CLK);

  display_subcount_text(1, "Write ITCM from D-Code Bus", 1);
  for (i=32'h0000_0000; i<32'h0001_FFFF; i=i+32'h0000_1000) begin
    write_transaction(.master(1), .addr(i),         .data(i + 8'h00));
    write_transaction(.master(1), .addr(i+8'h04),   .data(i + 8'h04));
    write_transaction(.master(1), .addr(i+8'h08),   .data(i + 8'h08));
    write_transaction(.master(1), .addr(i+8'h0C),   .data(i + 8'h0C));
    write_transaction(.master(1), .addr(i+8'h10),   .data(i + 8'h10));
    write_transaction(.master(1), .addr(i+8'h14),   .data(i + 8'h14));
    write_transaction(.master(1), .addr(i+8'h18),   .data(i + 8'h18));
    write_transaction(.master(1), .addr(i+8'h1C),   .data(i + 8'h1C));

    write_transaction(.master(1), .addr(i+12'hFE0), .data(i + 8'h20));
    write_transaction(.master(1), .addr(i+12'hFE4), .data(i + 8'h24));
    write_transaction(.master(1), .addr(i+12'hFE8), .data(i + 8'h28));
    write_transaction(.master(1), .addr(i+12'hFEC), .data(i + 8'h2C));
    write_transaction(.master(1), .addr(i+12'hFF0), .data(i + 8'h30));
    write_transaction(.master(1), .addr(i+12'hFF4), .data(i + 8'h34));
    write_transaction(.master(1), .addr(i+12'hFF8), .data(i + 8'h38));
    write_transaction(.master(1), .addr(i+12'hFFC), .data(i + 8'h3C));
  end

  display_subcount_text(2, "Read ITCM from D-Code Bus", 1);
  for (i=32'h0000_0000; i<32'h0001_FFFF; i=i+32'h0000_1000) begin
    read_transaction( .master(1), .addr(i),         .expdata(i + 8'h00), .check(1));
    read_transaction( .master(1), .addr(i+8'h04),   .expdata(i + 8'h04), .check(1));
    read_transaction( .master(1), .addr(i+8'h08),   .expdata(i + 8'h08), .check(1));
    read_transaction( .master(1), .addr(i+8'h0C),   .expdata(i + 8'h0C), .check(1));
    read_transaction( .master(1), .addr(i+8'h10),   .expdata(i + 8'h10), .check(1));
    read_transaction( .master(1), .addr(i+8'h14),   .expdata(i + 8'h14), .check(1));
    read_transaction( .master(1), .addr(i+8'h18),   .expdata(i + 8'h18), .check(1));
    read_transaction( .master(1), .addr(i+8'h1C),   .expdata(i + 8'h1C), .check(1));

    read_transaction( .master(1), .addr(i+12'hFE0), .expdata(i + 8'h20), .check(1));
    read_transaction( .master(1), .addr(i+12'hFE4), .expdata(i + 8'h24), .check(1));
    read_transaction( .master(1), .addr(i+12'hFE8), .expdata(i + 8'h28), .check(1));
    read_transaction( .master(1), .addr(i+12'hFEC), .expdata(i + 8'h2C), .check(1));
    read_transaction( .master(1), .addr(i+12'hFF0), .expdata(i + 8'h30), .check(1));
    read_transaction( .master(1), .addr(i+12'hFF4), .expdata(i + 8'h34), .check(1));
    read_transaction( .master(1), .addr(i+12'hFF8), .expdata(i + 8'h38), .check(1));
    read_transaction( .master(1), .addr(i+12'hFFC), .expdata(i + 8'h3C), .check(1));
  end

  //--------------------------------------------------
  label    = "Write/Read ITCM I-Code Bus";
  simcount = 2;
  //--------------------------------------------------

  display_subcount_text(1, "Read ITCM from I-Code Bus", 1);
  for (i=32'h0000_0000; i<32'h0001_FFFF; i=i+32'h0000_1000) begin
    read_transaction( .master(0), .addr(i),         .expdata(i + 8'h00), .check(1));
    read_transaction( .master(0), .addr(i+8'h04),   .expdata(i + 8'h04), .check(1));
    read_transaction( .master(0), .addr(i+8'h08),   .expdata(i + 8'h08), .check(1));
    read_transaction( .master(0), .addr(i+8'h0C),   .expdata(i + 8'h0C), .check(1));
    read_transaction( .master(0), .addr(i+8'h10),   .expdata(i + 8'h10), .check(1));
    read_transaction( .master(0), .addr(i+8'h14),   .expdata(i + 8'h14), .check(1));
    read_transaction( .master(0), .addr(i+8'h18),   .expdata(i + 8'h18), .check(1));
    read_transaction( .master(0), .addr(i+8'h1C),   .expdata(i + 8'h1C), .check(1));

    read_transaction( .master(0), .addr(i+12'hFE0), .expdata(i + 8'h20), .check(1));
    read_transaction( .master(0), .addr(i+12'hFE4), .expdata(i + 8'h24), .check(1));
    read_transaction( .master(0), .addr(i+12'hFE8), .expdata(i + 8'h28), .check(1));
    read_transaction( .master(0), .addr(i+12'hFEC), .expdata(i + 8'h2C), .check(1));
    read_transaction( .master(0), .addr(i+12'hFF0), .expdata(i + 8'h30), .check(1));
    read_transaction( .master(0), .addr(i+12'hFF4), .expdata(i + 8'h34), .check(1));
    read_transaction( .master(0), .addr(i+12'hFF8), .expdata(i + 8'h38), .check(1));
    read_transaction( .master(0), .addr(i+12'hFFC), .expdata(i + 8'h3C), .check(1));
  end

  //--------------------------------------------------
  label    = "Out-Of-Range Address";
  simcount = 3;
  //--------------------------------------------------
  display_subcount_text(1, "Read Address 32'h0002_0000 from D-Code Bus", 1);
  read_transaction( .master(1), .addr(32'h0002_0000),         .expdata(8'h00), .check(1));
  read_transaction( .master(1), .addr(32'h0002_0000+8'h04),   .expdata(8'h04), .check(1));
  read_transaction( .master(1), .addr(32'h0002_0000+8'h08),   .expdata(8'h08), .check(1));
  read_transaction( .master(1), .addr(32'h0002_0000+8'h0C),   .expdata(8'h0C), .check(1));
  read_transaction( .master(1), .addr(32'h0002_0000+8'h10),   .expdata(8'h10), .check(1));
  read_transaction( .master(1), .addr(32'h0002_0000+8'h14),   .expdata(8'h14), .check(1));
  read_transaction( .master(1), .addr(32'h0002_0000+8'h18),   .expdata(8'h18), .check(1));
  read_transaction( .master(1), .addr(32'h0002_0000+8'h1C),   .expdata(8'h1C), .check(1));

  read_transaction( .master(1), .addr(32'h0002_0000+12'hFE0), .expdata(8'h20), .check(1));
  read_transaction( .master(1), .addr(32'h0002_0000+12'hFE4), .expdata(8'h24), .check(1));
  read_transaction( .master(1), .addr(32'h0002_0000+12'hFE8), .expdata(8'h28), .check(1));
  read_transaction( .master(1), .addr(32'h0002_0000+12'hFEC), .expdata(8'h2C), .check(1));
  read_transaction( .master(1), .addr(32'h0002_0000+12'hFF0), .expdata(8'h30), .check(1));
  read_transaction( .master(1), .addr(32'h0002_0000+12'hFF4), .expdata(8'h34), .check(1));
  read_transaction( .master(1), .addr(32'h0002_0000+12'hFF8), .expdata(8'h38), .check(1));
  read_transaction( .master(1), .addr(32'h0002_0000+12'hFFC), .expdata(8'h3C), .check(1));

  display_subcount_text(2, "Read Address 32'h0002_0000 from I-Code Bus", 1);
  read_transaction( .master(0), .addr(32'h0002_0000),         .expdata(8'h00), .check(1));
  read_transaction( .master(0), .addr(32'h0002_0000+8'h04),   .expdata(8'h04), .check(1));
  read_transaction( .master(0), .addr(32'h0002_0000+8'h08),   .expdata(8'h08), .check(1));
  read_transaction( .master(0), .addr(32'h0002_0000+8'h0C),   .expdata(8'h0C), .check(1));
  read_transaction( .master(0), .addr(32'h0002_0000+8'h10),   .expdata(8'h10), .check(1));
  read_transaction( .master(0), .addr(32'h0002_0000+8'h14),   .expdata(8'h14), .check(1));
  read_transaction( .master(0), .addr(32'h0002_0000+8'h18),   .expdata(8'h18), .check(1));
  read_transaction( .master(0), .addr(32'h0002_0000+8'h1C),   .expdata(8'h1C), .check(1));

  read_transaction( .master(0), .addr(32'h0002_0000+12'hFE0), .expdata(8'h20), .check(1));
  read_transaction( .master(0), .addr(32'h0002_0000+12'hFE4), .expdata(8'h24), .check(1));
  read_transaction( .master(0), .addr(32'h0002_0000+12'hFE8), .expdata(8'h28), .check(1));
  read_transaction( .master(0), .addr(32'h0002_0000+12'hFEC), .expdata(8'h2C), .check(1));
  read_transaction( .master(0), .addr(32'h0002_0000+12'hFF0), .expdata(8'h30), .check(1));
  read_transaction( .master(0), .addr(32'h0002_0000+12'hFF4), .expdata(8'h34), .check(1));
  read_transaction( .master(0), .addr(32'h0002_0000+12'hFF8), .expdata(8'h38), .check(1));
  read_transaction( .master(0), .addr(32'h0002_0000+12'hFFC), .expdata(8'h3C), .check(1));

  display_subcount_text(3, "Write Address 32'h0002_0000 from D-Code Bus", 1);
  write_transaction( .master(1), .addr(32'h0002_0000),         .data(32'h0002_0000 + 8'h00));
  write_transaction( .master(1), .addr(32'h0002_0000+8'h04),   .data(32'h0002_0000 + 8'h04));
  write_transaction( .master(1), .addr(32'h0002_0000+8'h08),   .data(32'h0002_0000 + 8'h08));
  write_transaction( .master(1), .addr(32'h0002_0000+8'h0C),   .data(32'h0002_0000 + 8'h0C));
  write_transaction( .master(1), .addr(32'h0002_0000+8'h10),   .data(32'h0002_0000 + 8'h10));
  write_transaction( .master(1), .addr(32'h0002_0000+8'h14),   .data(32'h0002_0000 + 8'h14));
  write_transaction( .master(1), .addr(32'h0002_0000+8'h18),   .data(32'h0002_0000 + 8'h18));
  write_transaction( .master(1), .addr(32'h0002_0000+8'h1C),   .data(32'h0002_0000 + 8'h1C));

  write_transaction( .master(1), .addr(32'h0002_0000+12'hFE0), .data(32'h0002_0000 + 8'h20));
  write_transaction( .master(1), .addr(32'h0002_0000+12'hFE4), .data(32'h0002_0000 + 8'h24));
  write_transaction( .master(1), .addr(32'h0002_0000+12'hFE8), .data(32'h0002_0000 + 8'h28));
  write_transaction( .master(1), .addr(32'h0002_0000+12'hFEC), .data(32'h0002_0000 + 8'h2C));
  write_transaction( .master(1), .addr(32'h0002_0000+12'hFF0), .data(32'h0002_0000 + 8'h30));
  write_transaction( .master(1), .addr(32'h0002_0000+12'hFF4), .data(32'h0002_0000 + 8'h34));
  write_transaction( .master(1), .addr(32'h0002_0000+12'hFF8), .data(32'h0002_0000 + 8'h38));
  write_transaction( .master(1), .addr(32'h0002_0000+12'hFFC), .data(32'h0002_0000 + 8'h3C));

  display_subcount_text(4, "Read Address 32'h0000_0000 from D-Code Bus", 1);
  read_transaction( .master(1), .addr(32'h0000_0000),         .expdata(32'h0002_0000 + 8'h00), .check(1));
  read_transaction( .master(1), .addr(32'h0000_0000+8'h04),   .expdata(32'h0002_0000 + 8'h04), .check(1));
  read_transaction( .master(1), .addr(32'h0000_0000+8'h08),   .expdata(32'h0002_0000 + 8'h08), .check(1));
  read_transaction( .master(1), .addr(32'h0000_0000+8'h0C),   .expdata(32'h0002_0000 + 8'h0C), .check(1));
  read_transaction( .master(1), .addr(32'h0000_0000+8'h10),   .expdata(32'h0002_0000 + 8'h10), .check(1));
  read_transaction( .master(1), .addr(32'h0000_0000+8'h14),   .expdata(32'h0002_0000 + 8'h14), .check(1));
  read_transaction( .master(1), .addr(32'h0000_0000+8'h18),   .expdata(32'h0002_0000 + 8'h18), .check(1));
  read_transaction( .master(1), .addr(32'h0000_0000+8'h1C),   .expdata(32'h0002_0000 + 8'h1C), .check(1));

  read_transaction( .master(1), .addr(32'h0000_0000+12'hFE0), .expdata(32'h0002_0000 + 8'h20), .check(1));
  read_transaction( .master(1), .addr(32'h0000_0000+12'hFE4), .expdata(32'h0002_0000 + 8'h24), .check(1));
  read_transaction( .master(1), .addr(32'h0000_0000+12'hFE8), .expdata(32'h0002_0000 + 8'h28), .check(1));
  read_transaction( .master(1), .addr(32'h0000_0000+12'hFEC), .expdata(32'h0002_0000 + 8'h2C), .check(1));
  read_transaction( .master(1), .addr(32'h0000_0000+12'hFF0), .expdata(32'h0002_0000 + 8'h30), .check(1));
  read_transaction( .master(1), .addr(32'h0000_0000+12'hFF4), .expdata(32'h0002_0000 + 8'h34), .check(1));
  read_transaction( .master(1), .addr(32'h0000_0000+12'hFF8), .expdata(32'h0002_0000 + 8'h38), .check(1));
  read_transaction( .master(1), .addr(32'h0000_0000+12'hFFC), .expdata(32'h0002_0000 + 8'h3C), .check(1));

  display_subcount_text(5, "Read Address 32'h0000_0000 from I-Code Bus", 1);
  read_transaction( .master(0), .addr(32'h0000_0000),         .expdata(32'h0002_0000 + 8'h00), .check(1));
  read_transaction( .master(0), .addr(32'h0000_0000+8'h04),   .expdata(32'h0002_0000 + 8'h04), .check(1));
  read_transaction( .master(0), .addr(32'h0000_0000+8'h08),   .expdata(32'h0002_0000 + 8'h08), .check(1));
  read_transaction( .master(0), .addr(32'h0000_0000+8'h0C),   .expdata(32'h0002_0000 + 8'h0C), .check(1));
  read_transaction( .master(0), .addr(32'h0000_0000+8'h10),   .expdata(32'h0002_0000 + 8'h10), .check(1));
  read_transaction( .master(0), .addr(32'h0000_0000+8'h14),   .expdata(32'h0002_0000 + 8'h14), .check(1));
  read_transaction( .master(0), .addr(32'h0000_0000+8'h18),   .expdata(32'h0002_0000 + 8'h18), .check(1));
  read_transaction( .master(0), .addr(32'h0000_0000+8'h1C),   .expdata(32'h0002_0000 + 8'h1C), .check(1));

  read_transaction( .master(0), .addr(32'h0000_0000+12'hFE0), .expdata(32'h0002_0000 + 8'h20), .check(1));
  read_transaction( .master(0), .addr(32'h0000_0000+12'hFE4), .expdata(32'h0002_0000 + 8'h24), .check(1));
  read_transaction( .master(0), .addr(32'h0000_0000+12'hFE8), .expdata(32'h0002_0000 + 8'h28), .check(1));
  read_transaction( .master(0), .addr(32'h0000_0000+12'hFEC), .expdata(32'h0002_0000 + 8'h2C), .check(1));
  read_transaction( .master(0), .addr(32'h0000_0000+12'hFF0), .expdata(32'h0002_0000 + 8'h30), .check(1));
  read_transaction( .master(0), .addr(32'h0000_0000+12'hFF4), .expdata(32'h0002_0000 + 8'h34), .check(1));
  read_transaction( .master(0), .addr(32'h0000_0000+12'hFF8), .expdata(32'h0002_0000 + 8'h38), .check(1));
  read_transaction( .master(0), .addr(32'h0000_0000+12'hFFC), .expdata(32'h0002_0000 + 8'h3C), .check(1));
  simfinish(0);
end

endmodule
