//-----------------------------------------------
// Space Cubics SC-OBC-A1
// SC-OBC-A1 PLL
// Module: scobca1_pll
//-----------------------------------------------
// Copyright © 2021 Space Cubics, LLC.
//-----------------------------------------------

module scobca1_pll # (
  parameter CLKIN_PERIOD = 41.666,
  parameter CLKFBOUT_MULT = 40,
  parameter DIVCLK_DIVIDE = 1,
  parameter CLKOUT0_DIVIDE = 10,
  parameter CLKOUT1_DIVIDE = 20,
  parameter CLKOUT2_DIVIDE = 50,
  parameter USER1_DIVIDE = 100,
  parameter USER2_DIVIDE = 100
) (
  input SYSCLK1,
  input SYSCLK2,
  input REF_CLK,
  input REFCLK_SEL,
  input PLLRESET,
  input PLLPWRDWN,
  output PLLCLK96M,
  output PLLCLK48M,
  output PLLCLK19M2,
  output USERCLK1,
  output USERCLK2,
  output CLK_OK,
  output PLLLOCKED
);

wire clkinsel = ~REFCLK_SEL;

// PLLE2_ADV: Advanced Phase Locked Loop (PLL)
// 7 Series
// Xilinx HDL Libraries Guide, version 2012.4
//--------------------------------------------------
wire fbclk;
PLLE2_ADV # (
  .BANDWIDTH("OPTIMIZED"),
  .CLKFBOUT_MULT(CLKFBOUT_MULT),
  .CLKFBOUT_PHASE(0.0),
  // CLKIN_PERIOD: Input clock period in nS to ps resolution (i.e. 33.333 is 30 MHz).
  .CLKIN1_PERIOD(CLKIN_PERIOD),
  .CLKIN2_PERIOD(CLKIN_PERIOD),
  // CLKOUT0_DIVIDE - CLKOUT5_DIVIDE: Divide amount for CLKOUT (1-128)
  .CLKOUT0_DIVIDE(CLKOUT0_DIVIDE),
  .CLKOUT1_DIVIDE(CLKOUT1_DIVIDE),
  .CLKOUT2_DIVIDE(CLKOUT2_DIVIDE),
  .CLKOUT3_DIVIDE(1),
  .CLKOUT4_DIVIDE(USER1_DIVIDE),
  .CLKOUT5_DIVIDE(USER2_DIVIDE),
  // CLKOUT0_DUTY_CYCLE - CLKOUT5_DUTY_CYCLE: Duty cycle for CLKOUT outputs (0.001-0.999).
  .CLKOUT0_DUTY_CYCLE(0.5),
  .CLKOUT1_DUTY_CYCLE(0.5),
  .CLKOUT2_DUTY_CYCLE(0.5),
  .CLKOUT3_DUTY_CYCLE(0.5),
  .CLKOUT4_DUTY_CYCLE(0.5),
  .CLKOUT5_DUTY_CYCLE(0.5),
  // CLKOUT0_PHASE - CLKOUT5_PHASE: Phase offset for CLKOUT outputs (-360.000-360.000).
  .CLKOUT0_PHASE(0.0),
  .CLKOUT1_PHASE(0.0),
  .CLKOUT2_PHASE(0.0),
  .CLKOUT3_PHASE(0.0),
  .CLKOUT4_PHASE(0.0),
  .CLKOUT5_PHASE(0.0),
  .COMPENSATION("ZHOLD"), // ZHOLD, BUF_IN, EXTERNAL, INTERNAL
  .DIVCLK_DIVIDE(DIVCLK_DIVIDE), // Master division value (1-56)
  // REF_JITTER: Reference input jitter in UI (0.000-0.999).
  .REF_JITTER1(0.0),
  .REF_JITTER2(0.0),
  .STARTUP_WAIT("TRUE") // Delay DONE until PLL Locks, ("TRUE"/"FALSE")
) pll2_adv (
  // Clock Inputs
  .CLKIN1(SYSCLK1),
  .CLKIN2(SYSCLK2),
  .CLKFBIN(fbclk),
  .CLKFBOUT(fbclk),
  // Control Ports
  .CLKINSEL(clkinsel), // Clock select: High=CLKIN1 Low=CLKIN2
  .PWRDWN(PLLPWRDWN),
  .RST(PLLRESET),
  // Status Ports: 1-bit (each) output: PLL status ports
  .LOCKED(PLLLOCKED), // 1-bit output: LOCK
  // Clock Outputs
  .CLKOUT0(PLLCLK96M),
  .CLKOUT1(PLLCLK48M),
  .CLKOUT2(PLLCLK19M2),
  .CLKOUT3(/*open*/),
  .CLKOUT4(USERCLK1),
  .CLKOUT5(USERCLK2),
  // DRP Ports
  .DEN(1'b0),
  .DCLK(1'b0),
  .DADDR(7'h0),
  .DWE(1'b0),
  .DI(16'h0),
  .DO(/*open*/),
  .DRDY(/*open*/)
);

reg clock_valid;
always @ (*) begin
  if (PLLPWRDWN)
    clock_valid = ~PLLRESET;
  else
    clock_valid = PLLLOCKED;
end

tmr_syncff # (.SYNCC(2), .SRVAL(1'b0))
clk_ok_reg (.D_AS(clock_valid), .CLK(REF_CLK), .SRB(1'b1), .Q_SY(CLK_OK));

endmodule
