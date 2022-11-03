//-----------------------------------------------
// Space Cubics General Purpose Timer
// Module: sc_gptmr_ahb_slave
//  AHB Slave Interface
//-----------------------------------------------
// Copyright © 2022 Space Cubics, LLC.
//-----------------------------------------------

module sc_gptmr_ahb_slave # (
  parameter GTMR_COMPARE_CHANNEL = 4,  // Global Timer Compare Channel (1-16)
  parameter SITMR_COMPARE_CHANNEL = 8, // Software Interrupt Timer Compare Channel (1-16)
  parameter HITMR_COMPARE_CHANNEL = 8  // Hardware Interrupt Timer Compare Channel (1- 8)
) (
  // System Interface
  input HRESETN,
  input HCLK,
  input TMR_RSTB,
  input TMR_CLK,

  // AHB Slave Interface
  input SHSEL,
  input [31:0] SHADDR,
  input [1:0] SHTRANS,
  input [2:0] SHSIZE,
  input [2:0] SHBURST,
  input SHWRITE,
  input SHREADYIN,
  output SHREADYOUT,
  input [31:0] SHWDATA,
  output [31:0] SHRDATA,
  output [1:0] SHRESP,

  // Register Interface
  // Timer Core Interface
  output GTMR_VALUE_SET,
  output [27:0] GTMR_VALUE,
  input [31:0] GTMR_COUNT,
  output [32*GTMR_COMPARE_CHANNEL-1:0] GTMR_COMPARE_VALUE,
  input GTMR_ROLLOVER_INT,
  input [GTMR_COMPARE_CHANNEL-1:0] GTMR_COMPARE_INT,

  // Software Interrupt Timer Register
  output SITMR_EN,
  input [31:0] SITMR_COUNT,
  output SITMR_RST,
  output SITMR_RUN_MODE,
  output SITMR_ENB_MODE,
  output [15:0] SITMR_PRESCALER,
  output [32*SITMR_COMPARE_CHANNEL-1:0] SITMR_COMPARE_VALUE,
  input SITMR_ROLLOVER_INT,
  input [SITMR_COMPARE_CHANNEL-1:0] SITMR_COMPARE_INT,

  // Hardware Interrupt Timer Register
  output HITMR_EN,
  input [31:0] HITMR_COUNT,
  output HITMR_RST,
  output HITMR_RUN_MODE,
  output HITMR_ENB_MODE,
  output [2*HITMR_COMPARE_CHANNEL-1:0] HITMR_OP_MODE,
  output [15:0] HITMR_PRESCALER,
  output [32*HITMR_COMPARE_CHANNEL-1:0] HITMR_COMPARE_VALUE,

  // Interrupt Signal
  output GTMR_INT,
  output SITMR_INT
);

wire [31:0] reg_wadr;
wire [3:0] reg_wenb;
wire [31:0] reg_wdat;
wire reg_wwat;
wire [31:0] reg_radr;
wire reg_renb;
wire [31:0] reg_rdat;
wire reg_rwat;

sc_ahbip_slave # (
  .CYCLE_MODE(1)
) ahb_slave (
  // AHB Interface
  .HCLK(HCLK),
  .HRESETN(HRESETN),
  .HSEL(SHSEL),
  .HADDR(SHADDR),
  .HTRANS(SHTRANS),
  .HSIZE(SHSIZE),
  .HBURST(SHBURST),
  .HWRITE(SHWRITE),
  .HREADYIN(SHREADYIN),
  .HREADYOUT(SHREADYOUT),
  .HWDATA(SHWDATA),
  .HRDATA(SHRDATA),
  .HRESP(SHRESP),

  // Register Interface
  .REG_WADR(reg_wadr),
  .REG_WTYP(/*open*/),
  .REG_WENB(reg_wenb),
  .REG_WDAT(reg_wdat),
  .REG_WWAT(reg_wwat),
  .REG_WERR(1'b0),

  .REG_RADR(reg_radr),
  .REG_RTYP(/*open*/),
  .REG_RENB(reg_renb),
  .REG_RDAT(reg_rdat),
  .REG_RWAT(reg_rwat),
  .REG_RERR(1'b0)
);

sc_gptmr_reg # (
  .GTMR_COMPARE_CHANNEL(GTMR_COMPARE_CHANNEL),
  .SITMR_COMPARE_CHANNEL(SITMR_COMPARE_CHANNEL),
  .HITMR_COMPARE_CHANNEL(HITMR_COMPARE_CHANNEL)
) gptmr_reg (
  // AHB Register Interface
  .HCLK(HCLK),
  .HRESETN(HRESETN),

  // Bus Interface
  .REG_WADR(reg_wadr),
  .REG_WENB(reg_wenb),
  .REG_WDAT(reg_wdat),
  .REG_WWAT(reg_wwat),
  .REG_RADR(reg_radr),
  .REG_RENB(reg_renb),
  .REG_RDAT(reg_rdat),
  .REG_RWAT(reg_rwat),

  // Register Interface
  .SYNC_CLK(TMR_CLK),
  .SYNC_RSTB(TMR_RSTB),

  // Timer Core Interface
  .GTMR_VALUE_SET(GTMR_VALUE_SET),
  .GTMR_VALUE(GTMR_VALUE),
  .GTMR_COUNT(GTMR_COUNT),
  .GTMR_COMPARE_VALUE(GTMR_COMPARE_VALUE),
  .GTMR_ROLLOVER_INT(GTMR_ROLLOVER_INT),
  .GTMR_COMPARE_INT(GTMR_COMPARE_INT),

  // Software Interrupt Timer Register
  .SITMR_EN(SITMR_EN),
  .SITMR_COUNT(SITMR_COUNT),
  .SITMR_RST(SITMR_RST),
  .SITMR_RUN_MODE(SITMR_RUN_MODE),
  .SITMR_ENB_MODE(SITMR_ENB_MODE),
  .SITMR_PRESCALER(SITMR_PRESCALER),
  .SITMR_COMPARE_VALUE(SITMR_COMPARE_VALUE),
  .SITMR_ROLLOVER_INT(SITMR_ROLLOVER_INT),
  .SITMR_COMPARE_INT(SITMR_COMPARE_INT),

  // Hardware Interrupt Timer Register
  .HITMR_EN(HITMR_EN),
  .HITMR_COUNT(HITMR_COUNT),
  .HITMR_RST(HITMR_RST),
  .HITMR_RUN_MODE(HITMR_RUN_MODE),
  .HITMR_ENB_MODE(HITMR_ENB_MODE),
  .HITMR_OP_MODE(HITMR_OP_MODE),
  .HITMR_PRESCALER(HITMR_PRESCALER),
  .HITMR_COMPARE_VALUE(HITMR_COMPARE_VALUE),

  // Interrupt Signal
  .GTMR_INT(GTMR_INT),
  .SITMR_INT(SITMR_INT)
);

endmodule
