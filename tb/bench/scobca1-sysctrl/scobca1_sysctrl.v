//-----------------------------------------------
// Space Cubics SCSAT1
// SC OBC1 System Controller
// Module: scobc1_sysctrl
//-----------------------------------------------
// Copyright © 2021 Space Cubics, LLC.
//-----------------------------------------------

module scobca1_sysctrl # (
  parameter SYSCTRL_USER_CLK1_DIVIDE = 100,
  parameter SYSCTRL_USER_CLK1_MODE = 0,
  parameter SYSCTRL_USER_CLK2_DIVIDE = 100,
  parameter SYSCTRL_USER_CLK2_MODE = 0
) (
  input SYSCLK1,
  output SYSCLK1_EN,
  input SYSCLK2,
  output SYSCLK2_EN,
  output INIT_REQ,
  input INIT_DONE,
  input [1:0] CLKMODE,
  input CMC_REQ,
  output CMC_ACK,
  output PLLLOCK,
  input SLEEPING,
  output SLEEPHOLDREQN,
  input SLEEPHOLDACKN,
  input SYS_RST_REQ,
  input REG_RST_REQ,
  input CPU_LOCKUP,
  input CPU_LOCKUP_RSTEN,
  output REF_CLK,
  output SYS_CLK,
  output MAXI_CLK,
  output ULPI_REFCLK,
  output USER_CLK1,
  output USER_CLK2,
  output POR_RSTB,
  output POR_RSTB_SYNC_REFCLK,
  output SYS_RSTB,
  output SYS_RSTB_SYNC_REFCLK,
  output SYS_RSTB_SYNC_USERCLK1,
  output SYS_RSTB_SYNC_USERCLK2,
  output BUS_RSTB
);

wire ref_rstb;
wire clk_ok;

scobca1_clk_gen # (
  .USER1_DIVIDE(SYSCTRL_USER_CLK1_DIVIDE),
  .USER1_MODE(SYSCTRL_USER_CLK1_MODE),
  .USER2_DIVIDE(SYSCTRL_USER_CLK2_DIVIDE),
  .USER2_MODE(SYSCTRL_USER_CLK2_MODE)
) clk_gen (
  .SYSCLK1(SYSCLK1),
  .SYSCLK1_EN(SYSCLK1_EN),
  .SYSCLK2(SYSCLK2),
  .SYSCLK2_EN(SYSCLK2_EN),
  .CLKMODE(CLKMODE),
  .CMC_REQ(CMC_REQ),
  .CMC_ACK(CMC_ACK),
  .PLLLOCK(PLLLOCK),
  .SLEEPING(SLEEPING),
  .SLEEPHOLDREQN(SLEEPHOLDREQN),
  .SLEEPHOLDACKN(SLEEPHOLDACKN),
  .REF_CLK(REF_CLK),
  .REF_RSTB(ref_rstb),
  .SYS_CLK(SYS_CLK),
  .MAXI_CLK(MAXI_CLK),
  .ULPI_REFCLK(ULPI_REFCLK),
  .USER_CLK1(USER_CLK1),
  .USER_CLK2(USER_CLK2),
  .CLK_OK(clk_ok)
);

scobca1_rst_gen rst_gen (
  .REF_CLK(REF_CLK),
  .SYS_CLK(SYS_CLK),
  .USER_CLK1(USER_CLK1),
  .USER_CLK2(USER_CLK2),
  .REF_RSTB(ref_rstb),
  .INIT_REQ(INIT_REQ),
  .INIT_DONE(INIT_DONE),
  .SYS_RST_REQ(SYS_RST_REQ),
  .REG_RST_REQ(REG_RST_REQ),
  .CPU_LOCKUP(CPU_LOCKUP),
  .CPU_LOCKUP_RSTEN(CPU_LOCKUP_RSTEN),
  .CLK_OK(clk_ok),
  .POR_RSTB(POR_RSTB),
  .POR_RSTB_SYNC_REFCLK(POR_RSTB_SYNC_REFCLK),
  .SYS_RSTB(SYS_RSTB),
  .SYS_RSTB_SYNC_REFCLK(SYS_RSTB_SYNC_REFCLK),
  .SYS_RSTB_SYNC_USERCLK1(SYS_RSTB_SYNC_USERCLK1),
  .SYS_RSTB_SYNC_USERCLK2(SYS_RSTB_SYNC_USERCLK2),
  .BUS_RSTB(BUS_RSTB)
);

endmodule
