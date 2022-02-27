//-----------------------------------------------
// Space Cubics SC-OBC-A1
// SC-OBC-A1 Clock Generator
// Module: scobca1_clk_gen
//-----------------------------------------------
// Copyright © 2021 Space Cubics, LLC.
//-----------------------------------------------

module scobca1_clk_gen # (
  parameter USER1_DIVIDE = 100,
  parameter USER1_MODE = 0,
  parameter USER2_DIVIDE = 100,
  parameter USER2_MODE = 0
) (
  input SYSCLK1,
  output SYSCLK1_EN,
  input SYSCLK2,
  output SYSCLK2_EN,
  input [1:0] CLKMODE,
  input CMC_REQ,
  output CMC_ACK,
  output PLLLOCK,
  input SLEEPING,
  output SLEEPHOLDREQN,
  input SLEEPHOLDACKN,
  output REF_CLK,
  output REF_RSTB,
  output SYS_CLK,
  output MAXI_CLK,
  output ULPI_REFCLK,
  output USER_CLK1,
  output USER_CLK2,
  output CLK_OK
);

wire sys_rst;
wire refclksel;
wire [1:0] reg_clkmode;
wire pll_pwrdwn;
wire pllclk96m;
wire pllclk48m;
wire pllclk19m2;
wire userclk1;
wire userclk2;
wire sleep_hold_ref_clk;

refclk_sel refclk_sel (
  .SYSCLK1(SYSCLK1),
  .SYSCLK1_EN(SYSCLK1_EN),
  .SYSCLK2(SYSCLK2),
  .SYSCLK2_EN(SYSCLK2_EN),
  .REFCLK(REF_CLK),
  .REFCLK_SEL(refclksel),
  .REFCLK_VALID(REF_RSTB)
);
assign sys_rst = ~REF_RSTB;

scobca1_state scobca1_state (
  .REF_CLK(REF_CLK),
  .REF_RSTB(REF_RSTB),
  .CLKMODE(CLKMODE),
  .CMC_REQ(CMC_REQ),
  .CMC_ACK(CMC_ACK),
  .REG_CLKMODE(reg_clkmode),
  .PLLLOCK(PLLLOCK),
  .PLLPWRDWN(pll_pwrdwn),
  .SLEEPING(SLEEPING),
  .SLEEPHOLDREQN(sleep_hold_ref_clk),
  .SLEEPHOLDACKN(SLEEPHOLDACKN)
);

tmr_syncff # (
  .SYNCC(4),
  .SRVAL(1'b1)
) sync_sleepholdreqn (
  .D_AS(sleep_hold_ref_clk),
  .CLK(SYS_CLK),
  .SRB(1'b1),
  .Q_SY(SLEEPHOLDREQN)
);

scobca1_pll # (
  .CLKIN_PERIOD(41.666),
  .CLKFBOUT_MULT(40),
  .DIVCLK_DIVIDE(1),
  .CLKOUT0_DIVIDE(10),
  .CLKOUT1_DIVIDE(20),
  .CLKOUT2_DIVIDE(50),
  .USER1_DIVIDE(USER1_DIVIDE),
  .USER2_DIVIDE(USER2_DIVIDE)
) scobca1_pll (
  .SYSCLK1(SYSCLK1),
  .SYSCLK2(SYSCLK2),
  .REF_CLK(REF_CLK),
  .REFCLK_SEL(refclksel),
  .PLLRESET(sys_rst),
  .PLLPWRDWN(pll_pwrdwn),
  .PLLCLK96M(pllclk96m),
  .PLLCLK48M(pllclk48m),
  .PLLCLK19M2(pllclk19m2),
  .USERCLK1(userclk1),
  .USERCLK2(userclk2),
  .CLK_OK(CLK_OK),
  .PLLLOCKED(PLLLOCK)
);

scobca1_outsel # (
  .USER1_MODE(USER1_MODE),
  .USER2_MODE(USER2_MODE)
) scobca1_outsel (
  .REF_CLK(REF_CLK),
  .REF_RSTB(REF_RSTB),
  .PLLLOCK(PLLLOCK),
  .PLLCLK96M(pllclk96m),
  .PLLCLK48M(pllclk48m),
  .PLLCLK19M2(pllclk19m2),
  .USERCLK1(userclk1),
  .USERCLK2(userclk2),
  .REG_CLKMODE(reg_clkmode),
  .SYS_CLK(SYS_CLK),
  .MAXI_CLK(MAXI_CLK),
  .USER_CLK1(USER_CLK1),
  .USER_CLK2(USER_CLK2),
  .ULPI_REFCLK(ULPI_REFCLK)
);

endmodule
