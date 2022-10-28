//-----------------------------------------------
// Space Cubics General Purpose Timer
// Module: sc_gptmr_core
//  General Purpose Timer Core Module
//-----------------------------------------------
// Copyright © 2022 Space Cubics, LLC.
//-----------------------------------------------
module sc_gptmr_core # (
  parameter GTMR_PRESCALER_BIT_WIDTH = 21,
  parameter GTMR_COMPARE_CHANNEL = 4,
  parameter SITMR_COMPARE_CHANNEL = 8,
  parameter HITMR_COMPARE_CHANNEL = 8
) (
  // System Interface
  input TMR_RSTB,
  input TMR_CLK,

  // Register Interface
  //  Global Timer Signal
  input GTMR_VALUE_SET,
  input [27:0] GTMR_VALUE,
  output [31:0] GTMR_COUNT,
  input [GTMR_PRESCALER_BIT_WIDTH-1:0] GTMR_PRESCALER_VALUE,
  input [32*GTMR_COMPARE_CHANNEL-1:0] GTMR_COMPARE_VALUE,
  output GTMR_ROLLOVER_INT,
  output [GTMR_COMPARE_CHANNEL-1:0] GTMR_COMPARE_INT,

  // Software Interrupt Timer Signal
  input SITMR_EN,
  output [31:0] SITMR_COUNT,
  input SITMR_RST,
  input SITMR_RUN_MODE,
  input SITMR_ENB_MODE,
  input [15:0] SITMR_PRESCALER,
  input [32*SITMR_COMPARE_CHANNEL-1:0] SITMR_COMPARE_VALUE,
  output SITMR_ROLLOVER_INT,
  output [SITMR_COMPARE_CHANNEL-1:0] SITMR_COMPARE_INT,

  // Hardware Interrupt Timer Signal
  input HITMR_EN,
  output [31:0] HITMR_COUNT,
  input HITMR_RST,
  input HITMR_RUN_MODE,
  input HITMR_ENB_MODE,
  input [2*HITMR_COMPARE_CHANNEL-1:0] HITMR_OP_MODE,
  input [15:0] HITMR_PRESCALER,
  input [32*HITMR_COMPARE_CHANNEL-1:0] HITMR_COMPARE_VALUE,
  output [HITMR_COMPARE_CHANNEL-1:0] HITMR_INT_REQ,
  input [HITMR_COMPARE_CHANNEL-1:0] HITMR_INT_ACK
);

// Global Timer
// ----------------------------------------
sc_gptmr_timer_core # (
  .COMPARE_CHANNEL(GTMR_COMPARE_CHANNEL),
  .TIMER_BIT_WIDTH(32),
  .PRESCALER_BIT_WIDTH(GTMR_PRESCALER_BIT_WIDTH)
) gtmr (
  // System Interface
  .CLK(TMR_CLK),
  .RSTB(TMR_RSTB),

  // Register Interface
  .ENABLE(1'b1),
  .RESET(1'b0),
  .RUN_MODE(1'b1),
  .ENB_MODE(1'b0),
  .OP_MODE({GTMR_COMPARE_CHANNEL{2'b10}}),
  .UPDATE(GTMR_VALUE_SET),
  .UPDATE_VALUE({GTMR_VALUE, 4'h0}),
  .PRESCALER(GTMR_PRESCALER_VALUE),
  .COMPARE_VALUE(GTMR_COMPARE_VALUE),
  .COUNT(GTMR_COUNT),

  // Interrupt Signal
  .ROLLOVER_INT(GTMR_ROLLOVER_INT),
  .COMPARE_INT_REQ(GTMR_COMPARE_INT),
  .COMPARE_INT_ACK({GTMR_COMPARE_CHANNEL{1'b0}})
);

// Software Interrupt Timer
// ----------------------------------------
sc_gptmr_timer_core # (
  .COMPARE_CHANNEL(SITMR_COMPARE_CHANNEL),
  .TIMER_BIT_WIDTH(32),
  .PRESCALER_BIT_WIDTH(16)
) sitmr (
  // System Interface
  .CLK(TMR_CLK),
  .RSTB(TMR_RSTB),

  // Register Interface
  .ENABLE(SITMR_EN),
  .RESET(SITMR_RST),
  .RUN_MODE(SITMR_RUN_MODE),
  .ENB_MODE(SITMR_ENB_MODE),
  .OP_MODE({SITMR_COMPARE_CHANNEL{2'b10}}),
  .UPDATE(1'b0),
  .UPDATE_VALUE(32'h0000_0000),
  .PRESCALER(SITMR_PRESCALER),
  .COMPARE_VALUE(SITMR_COMPARE_VALUE),
  .COUNT(SITMR_COUNT),

  // Interrupt Signal
  .ROLLOVER_INT(SITMR_ROLLOVER_INT),
  .COMPARE_INT_REQ(SITMR_COMPARE_INT),
  .COMPARE_INT_ACK({SITMR_COMPARE_CHANNEL{1'b0}})
);

// Hardware Interrupt Timer
// ----------------------------------------
sc_gptmr_timer_core # (
  .COMPARE_CHANNEL(HITMR_COMPARE_CHANNEL),
  .TIMER_BIT_WIDTH(32),
  .PRESCALER_BIT_WIDTH(16)
) hitmr (
  // System Interface
  .CLK(TMR_CLK),
  .RSTB(TMR_RSTB),

  // Register Interface
  .ENABLE(HITMR_EN),
  .RESET(HITMR_RST),
  .RUN_MODE(HITMR_RUN_MODE),
  .ENB_MODE(HITMR_ENB_MODE),
  .OP_MODE(HITMR_OP_MODE),
  .UPDATE(1'b0),
  .UPDATE_VALUE(32'h0000_0000),
  .PRESCALER(HITMR_PRESCALER),
  .COMPARE_VALUE(HITMR_COMPARE_VALUE),
  .COUNT(HITMR_COUNT),

  // Interrupt Signal
  .ROLLOVER_INT(/*open*/),
  .COMPARE_INT_REQ(HITMR_INT_REQ),
  .COMPARE_INT_ACK(HITMR_INT_ACK)
);

endmodule
