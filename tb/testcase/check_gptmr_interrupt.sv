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
`include "cm3_task.vh"

`define GTMR_PRESCALER dut.obc_core.lpahb.gptmr.gptmr_core.gtmr.PRESCALER

  assign testcase_name = "Check GPTMR Interrupt";
initial begin
  timeout_ms = 100;
  skip_sram_init();
  @ (posedge SYS_RSTB);

  //--------------------------------------------------
  label    = "Boot System";
  simcount = 0;
  //--------------------------------------------------
  pic.PIC_CFG_MEM = 0;
  pic.CFG_MEM_MODE(0);
  @ (posedge CMC_REQ);
  @ (posedge CMC_ACK);
  @ (posedge PLLLOCK);
  @ (negedge CMC_REQ);
  @ (negedge CMC_ACK);
  force `GTMR_PRESCALER = 21'h3A96;
  display_text("SC-OBC-CORE System Bootup Done", 1, 1);

  repeat (10) @(posedge SYS_CLK);
  //--------------------------------------------------
  label    = "Check GPTMR Version Register";
  simcount = 1;
  //--------------------------------------------------
  display_subcount_text(1, "Check Version Initial Value", 1);
  read_transaction( .master(2), .addr(`GPTMR_BASE+`GPTMR_VER), .expdata(32'h0100_0000), .check(1));

  //--------------------------------------------------
  label    = "Check Global Timer";
  simcount = 2;
  //--------------------------------------------------

  display_subcount_text(1, "Set Global Timer Interrupt Enable Register", 1);
  //--------------------------------------------------
  write_transaction(.master(2), .addr(`GPTMR_BASE+`GPTMR_GTER),           .data(4'b1111<<`GPTMR_GTOCFENB));
  read_transaction( .master(2), .addr(`GPTMR_BASE+`GPTMR_GTER),        .expdata(4'b1111<<`GPTMR_GTOCFENB), .check(1));

  display_subcount_text(2, "Set Global Timer Output Compare Register", 1);
  //--------------------------------------------------
  write_transaction(.master(2), .addr(`GPTMR_BASE+`GPTMR_GTOCR + 4*0),    .data(1<<`GPTMR_GTCOMP));
  write_transaction(.master(2), .addr(`GPTMR_BASE+`GPTMR_GTOCR + 4*1),    .data(2<<`GPTMR_GTCOMP));
  write_transaction(.master(2), .addr(`GPTMR_BASE+`GPTMR_GTOCR + 4*2),    .data(3<<`GPTMR_GTCOMP));
  write_transaction(.master(2), .addr(`GPTMR_BASE+`GPTMR_GTOCR + 4*3),    .data(4<<`GPTMR_GTCOMP));
  read_transaction( .master(2), .addr(`GPTMR_BASE+`GPTMR_GTOCR + 4*0), .expdata(1<<`GPTMR_GTCOMP), .check(1));
  read_transaction( .master(2), .addr(`GPTMR_BASE+`GPTMR_GTOCR + 4*1), .expdata(2<<`GPTMR_GTCOMP), .check(1));
  read_transaction( .master(2), .addr(`GPTMR_BASE+`GPTMR_GTOCR + 4*2), .expdata(3<<`GPTMR_GTCOMP), .check(1));
  read_transaction( .master(2), .addr(`GPTMR_BASE+`GPTMR_GTOCR + 4*3), .expdata(4<<`GPTMR_GTCOMP), .check(1));

  display_subcount_text(3, "Check GTMR Interrupt Channel 0", 1);
  //--------------------------------------------------
  cm3_isr_check(`CM3_ISR_GTMR, 32'h0005_0000);
  read_transaction( .master(2), .addr(`GPTMR_BASE+`GPTMR_GTR),         .expdata(1<<`GPTMR_GTOCFSTS), .check(1));
  cm3_sys_ipcore_interrupt_check_and_write_clear(`GPTMR_BASE+`GPTMR_GTSR, 4'b0001);

  display_subcount_text(4, "Check GTMR Interrupt Channel 1", 1);
  //--------------------------------------------------
  cm3_isr_check(`CM3_ISR_GTMR, 32'h0005_0000);
  read_transaction( .master(2), .addr(`GPTMR_BASE+`GPTMR_GTR),         .expdata(2<<`GPTMR_GTOCFSTS), .check(1));
  cm3_sys_ipcore_interrupt_check_and_write_clear(`GPTMR_BASE+`GPTMR_GTSR, 4'b0010);

  display_subcount_text(5, "Check GTMR Interrupt Channel 2", 1);
  //--------------------------------------------------
  cm3_isr_check(`CM3_ISR_GTMR, 32'h0005_0000);
  read_transaction( .master(2), .addr(`GPTMR_BASE+`GPTMR_GTR),         .expdata(3<<`GPTMR_GTOCFSTS), .check(1));
  cm3_sys_ipcore_interrupt_check_and_write_clear(`GPTMR_BASE+`GPTMR_GTSR, 4'b0100);

  display_subcount_text(6, "Check GTMR Interrupt Channel 3", 1);
  //--------------------------------------------------
  cm3_isr_check(`CM3_ISR_GTMR, 32'h0005_0000);
  read_transaction( .master(2), .addr(`GPTMR_BASE+`GPTMR_GTR),         .expdata(4<<`GPTMR_GTOCFSTS), .check(1));
  cm3_sys_ipcore_interrupt_check_and_write_clear(`GPTMR_BASE+`GPTMR_GTSR, 4'b1000);


  //--------------------------------------------------
  label    = "Check Software Interrupt Timer";
  simcount = 3;
  //--------------------------------------------------

  display_subcount_text(1, "Set Software Interrupt Timer Interrupt Enable Register", 1);
  //--------------------------------------------------
  write_transaction(.master(2), .addr(`GPTMR_BASE+`GPTMR_SITER),          .data(8'hFF<<`GPTMR_SITOCFENB));
  read_transaction( .master(2), .addr(`GPTMR_BASE+`GPTMR_SITER),       .expdata(8'hFF<<`GPTMR_SITOCFENB), .check(1));

  display_subcount_text(2, "Set Software Interrupt Timer Output Compare Register", 1);
  //--------------------------------------------------
  write_transaction(.master(2), .addr(`GPTMR_BASE+`GPTMR_SITOCR + 4*0),   .data(8<<`GPTMR_SITCOMP));
  write_transaction(.master(2), .addr(`GPTMR_BASE+`GPTMR_SITOCR + 4*1),   .data(7<<`GPTMR_SITCOMP));
  write_transaction(.master(2), .addr(`GPTMR_BASE+`GPTMR_SITOCR + 4*2),   .data(6<<`GPTMR_SITCOMP));
  write_transaction(.master(2), .addr(`GPTMR_BASE+`GPTMR_SITOCR + 4*3),   .data(5<<`GPTMR_SITCOMP));
  write_transaction(.master(2), .addr(`GPTMR_BASE+`GPTMR_SITOCR + 4*4),   .data(4<<`GPTMR_SITCOMP));
  write_transaction(.master(2), .addr(`GPTMR_BASE+`GPTMR_SITOCR + 4*5),   .data(3<<`GPTMR_SITCOMP));
  write_transaction(.master(2), .addr(`GPTMR_BASE+`GPTMR_SITOCR + 4*6),   .data(2<<`GPTMR_SITCOMP));
  write_transaction(.master(2), .addr(`GPTMR_BASE+`GPTMR_SITOCR + 4*7),   .data(1<<`GPTMR_SITCOMP));
  read_transaction( .master(2), .addr(`GPTMR_BASE+`GPTMR_SITOCR + 4*0),.expdata(8<<`GPTMR_SITCOMP), .check(1));
  read_transaction( .master(2), .addr(`GPTMR_BASE+`GPTMR_SITOCR + 4*1),.expdata(7<<`GPTMR_SITCOMP), .check(1));
  read_transaction( .master(2), .addr(`GPTMR_BASE+`GPTMR_SITOCR + 4*2),.expdata(6<<`GPTMR_SITCOMP), .check(1));
  read_transaction( .master(2), .addr(`GPTMR_BASE+`GPTMR_SITOCR + 4*3),.expdata(5<<`GPTMR_SITCOMP), .check(1));
  read_transaction( .master(2), .addr(`GPTMR_BASE+`GPTMR_SITOCR + 4*4),.expdata(4<<`GPTMR_SITCOMP), .check(1));
  read_transaction( .master(2), .addr(`GPTMR_BASE+`GPTMR_SITOCR + 4*5),.expdata(3<<`GPTMR_SITCOMP), .check(1));
  read_transaction( .master(2), .addr(`GPTMR_BASE+`GPTMR_SITOCR + 4*6),.expdata(2<<`GPTMR_SITCOMP), .check(1));
  read_transaction( .master(2), .addr(`GPTMR_BASE+`GPTMR_SITOCR + 4*7),.expdata(1<<`GPTMR_SITCOMP), .check(1));

  display_subcount_text(3, "Set Software Interrupt Timer Prescaler", 1);
  //--------------------------------------------------
  write_transaction(.master(2), .addr(`GPTMR_BASE+`GPTMR_SITPR),          .data(16'h5DB<<`GPTMR_SITOCFENB));
  read_transaction( .master(2), .addr(`GPTMR_BASE+`GPTMR_SITPR),       .expdata(16'h5DB<<`GPTMR_SITOCFENB), .check(1));

  display_subcount_text(4, "Set Software Interrupt Timer Control Register", 1);
  //--------------------------------------------------
  write_transaction(.master(2), .addr(`GPTMR_BASE+`GPTMR_SITCR),          .data(1<<`GPTMR_SITENBMD | 0<<`GPTMR_SITRUNMD));
  read_transaction( .master(2), .addr(`GPTMR_BASE+`GPTMR_SITCR),       .expdata(1<<`GPTMR_SITENBMD | 0<<`GPTMR_SITRUNMD), .check(1));

  display_subcount_text(5, "Set Timer Enable Control Register & Interrupt Test Start", 1);
  //--------------------------------------------------
  write_transaction(.master(2), .addr(`GPTMR_BASE+`GPTMR_TECR),           .data(0<<`GPTMR_HITEN | 1<<`GPTMR_SITEN));
  read_transaction( .master(2), .addr(`GPTMR_BASE+`GPTMR_TECR),        .expdata(0<<`GPTMR_HITEN | 1<<`GPTMR_SITEN), .check(1));

  display_subcount_text(6, "Check SITMR Interrupt Channel 7", 1);
  //--------------------------------------------------
  cm3_isr_check(`CM3_ISR_SITMR, 32'h0005_0000);
  read_transaction( .master(2), .addr(`GPTMR_BASE+`GPTMR_SITRR),       .expdata(1<<`GPTMR_SITCNT), .check(1));
  cm3_sys_ipcore_interrupt_check_and_write_clear(`GPTMR_BASE+`GPTMR_SITSR, 8'b1000_0000);

  display_subcount_text(7, "Check SITMR Interrupt Channel 6", 1);
  //--------------------------------------------------
  cm3_isr_check(`CM3_ISR_SITMR, 32'h0005_0000);
  read_transaction( .master(2), .addr(`GPTMR_BASE+`GPTMR_SITRR),       .expdata(2<<`GPTMR_SITCNT), .check(1));
  cm3_sys_ipcore_interrupt_check_and_write_clear(`GPTMR_BASE+`GPTMR_SITSR, 8'b0100_0000);

  display_subcount_text(8, "Check SITMR Interrupt Channel 5", 1);
  //--------------------------------------------------
  cm3_isr_check(`CM3_ISR_SITMR, 32'h0005_0000);
  read_transaction( .master(2), .addr(`GPTMR_BASE+`GPTMR_SITRR),       .expdata(3<<`GPTMR_SITCNT), .check(1));
  cm3_sys_ipcore_interrupt_check_and_write_clear(`GPTMR_BASE+`GPTMR_SITSR, 8'b0010_0000);

  display_subcount_text(9, "Check SITMR Interrupt Channel 4", 1);
  //--------------------------------------------------
  cm3_isr_check(`CM3_ISR_SITMR, 32'h0005_0000);
  read_transaction( .master(2), .addr(`GPTMR_BASE+`GPTMR_SITRR),       .expdata(4<<`GPTMR_SITCNT), .check(1));
  cm3_sys_ipcore_interrupt_check_and_write_clear(`GPTMR_BASE+`GPTMR_SITSR, 8'b0001_0000);

  display_subcount_text(3, "Check SITMR Interrupt Channel 3", 1);
  //--------------------------------------------------
  cm3_isr_check(`CM3_ISR_SITMR, 32'h0005_0000);
  read_transaction( .master(2), .addr(`GPTMR_BASE+`GPTMR_SITRR),       .expdata(5<<`GPTMR_SITCNT), .check(1));
  cm3_sys_ipcore_interrupt_check_and_write_clear(`GPTMR_BASE+`GPTMR_SITSR, 8'b0000_1000);

  display_subcount_text(4, "Check SITMR Interrupt Channel 2", 1);
  //--------------------------------------------------
  cm3_isr_check(`CM3_ISR_SITMR, 32'h0005_0000);
  read_transaction( .master(2), .addr(`GPTMR_BASE+`GPTMR_SITRR),       .expdata(6<<`GPTMR_SITCNT), .check(1));
  cm3_sys_ipcore_interrupt_check_and_write_clear(`GPTMR_BASE+`GPTMR_SITSR, 8'b0000_0100);

  display_subcount_text(5, "Check SITMR Interrupt Channel 1", 1);
  //--------------------------------------------------
  cm3_isr_check(`CM3_ISR_SITMR, 32'h0005_0000);
  read_transaction( .master(2), .addr(`GPTMR_BASE+`GPTMR_SITRR),       .expdata(7<<`GPTMR_SITCNT), .check(1));
  cm3_sys_ipcore_interrupt_check_and_write_clear(`GPTMR_BASE+`GPTMR_SITSR, 8'b0000_0010);

  display_subcount_text(6, "Check SITMR Interrupt Channel 0", 1);
  //--------------------------------------------------
  cm3_isr_check(`CM3_ISR_SITMR, 32'h0005_0000);
  read_transaction( .master(2), .addr(`GPTMR_BASE+`GPTMR_SITRR),       .expdata(0<<`GPTMR_SITCNT), .check(1));
  cm3_sys_ipcore_interrupt_check_and_write_clear(`GPTMR_BASE+`GPTMR_SITSR, 8'b0000_0001);

  repeat (100) @ (posedge SYS_CLK);
  simfinish(0);
end

endmodule
