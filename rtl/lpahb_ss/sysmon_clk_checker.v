//-----------------------------------------------
// Space Cubics OBC FPGA System Monitor
//  System Monitor Clock Checker
//  Module: sysmon_clk_checker
//-----------------------------------------------
// Copyright © 2022 Space Cubics, LLC.
//-----------------------------------------------

module sysmon_clk_checker (
  // Bus clock
  input HCLK,
  input HRESETN,

  // Target clock
  input SYS_CLK,
  input MAXI_CLK,
  input ULPI_REFCLK,
  input USER_CLK1,
  input USER_CLK2,

  // Register Interface
  output SYS_CLK_STATE,
  output SYS_CLK_STOP,
  output MAXI_CLK_STATE,
  output MAXI_CLK_STOP,
  output ULPI_REFCLK_STATE,
  output ULPI_REFCLK_STOP,
  output USER_CLK1_STATE,
  output USER_CLK1_STOP,
  output USER_CLK2_STATE,
  output USER_CLK2_STOP
);

// System Clock Check
// ------------------------------
clk_checker # (
  .DIV_COUNT(8),
  .DIV_BUS_WIDTH(3),
  .CHK_LIMIT(255),
  .CHK_BUS_WIDTH(8)
) sys_clk_chk (
  .TARGET_CLK(SYS_CLK),
  .HCLK(HCLK),
  .HRESETN(HRESETN),
  .CLK_STATE(SYS_CLK_STATE),
  .CLK_STOP(SYS_CLK_STOP)
);

// Main AXI Clock Check
// ------------------------------
clk_checker # (
  .DIV_COUNT(8),
  .DIV_BUS_WIDTH(3),
  .CHK_LIMIT(255),
  .CHK_BUS_WIDTH(8)
) maxi_clk_chk (
  .TARGET_CLK(MAXI_CLK),
  .HCLK(HCLK),
  .HRESETN(HRESETN),
  .CLK_STATE(MAXI_CLK_STATE),
  .CLK_STOP(MAXI_CLK_STOP)
);

// ULPI Clock Check
// ------------------------------
clk_checker # (
  .DIV_COUNT(8),
  .DIV_BUS_WIDTH(3),
  .CHK_LIMIT(255),
  .CHK_BUS_WIDTH(8)
) ulpi_refclk_chk (
  .TARGET_CLK(ULPI_REFCLK),
  .HCLK(HCLK),
  .HRESETN(HRESETN),
  .CLK_STATE(ULPI_REFCLK_STATE),
  .CLK_STOP(ULPI_REFCLK_STOP)
);

// User Clock 1 Check
// ------------------------------
clk_checker # (
  .DIV_COUNT(8),
  .DIV_BUS_WIDTH(3),
  .CHK_LIMIT(255),
  .CHK_BUS_WIDTH(8)
) user_clk1_chk (
  .TARGET_CLK(USER_CLK1),
  .HCLK(HCLK),
  .HRESETN(HRESETN),
  .CLK_STATE(USER_CLK1_STATE),
  .CLK_STOP(USER_CLK1_STOP)
);

// User Clock 2 Check
// ------------------------------
clk_checker # (
  .DIV_COUNT(8),
  .DIV_BUS_WIDTH(3),
  .CHK_LIMIT(255),
  .CHK_BUS_WIDTH(8)
) user_clk2_chk (
  .TARGET_CLK(USER_CLK2),
  .HCLK(HCLK),
  .HRESETN(HRESETN),
  .CLK_STATE(USER_CLK2_STATE),
  .CLK_STOP(USER_CLK2_STOP)
);

endmodule
