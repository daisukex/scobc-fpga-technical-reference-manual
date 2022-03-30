//-----------------------------------------------
// Space Cubics OBC A1 FPGA
//  SC-OBC-A1 Task Package
//  Module: sc_obc_a1_fpga_task.vh
//-----------------------------------------------
// Copyright © 2022 Space Cubics, LLC.
//-----------------------------------------------

// Skip SRAM initialization
task skip_sram_init;
begin
  if (dut.obc_core.hrmem_sram.ram_init_ctrl.RAM_INIT_REQ !== 1'b1)
    @(posedge dut.obc_core.hrmem_sram.ram_init_ctrl.RAM_INIT_REQ);
  repeat(20) @(posedge SYS_CLK);
  dut.obc_core.hrmem_sram.ram_init_ctrl.RAM_INIT_ADDR = (2**20) - 8;
  display_text("Skip SRAM initialization", 1, 1); @(posedge SYS_CLK);
end
endtask

// System Re-Configuration
task system_reconfig;
begin
  force dut.sysctrl.clk_gen.refclk_sel.clksel_latch = 0;
  #100;
  release dut.sysctrl.clk_gen.refclk_sel.clksel_latch;
end
endtask
