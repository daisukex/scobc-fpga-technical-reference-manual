//-----------------------------------------------
// Module: sc_uart_engine
// Space Cubics UART Core TOP Module
//-----------------------------------------------
// Copyright © 2018 Space Cubics, LLC.
//-----------------------------------------------
module sc_uart_core (
  // System Interface
  input  SYSCLK,
  input  RESETB,

  // Register Interface
  input  TXEN,
  input  TXVALID,
  input  [7:0] TXDATA,
  output TXREADY,
  output TXCOMPLITE,
  output TXCLKTIM,
  input  RXEN,
  output RXVALID,
  output RXACTIVE,
  output [7:0] RXDATA,
  input  RXDETECT,
  output RXCOMPLITE,
  output ERR_PARITY,
  output ERR_FRAME,
  output ERR_OVERRUN,

  // UART Interface
  output UART_TX,
  input  UART_RX,

  // UART Frame Configuration
  input  [15:0] DIVIDER_RATE,
  input  [2:0] DATA_WIDTH,
  input  STOP_WIDTH,
  input  PARITY_ENABLE,
  input  [1:0] PARITY_TYPE
);

wire TX_TIM;
wire SYNC_RX_DATA;
wire SYNC_RX_TIM;

uart_tim_gen uart_tim_gen (
  .SYSCLK(SYSCLK),
  .RESETB(RESETB),
  .TXEN(TXEN),
  .TXREADY(TXREADY),
  .TXVALID(TXVALID),
  .TXCOMPLITE(TXCOMPLITE),
  .DIVIDER_RATE(DIVIDER_RATE),
  .TX_TIM(TX_TIM)
);
assign TXCLKTIM = TX_TIM;

uart_tx uart_tx(
  .SYSCLK(SYSCLK),
  .RESETB(RESETB),
  .TX_TIM(TX_TIM),
  .TXEN(TXEN),
  .TXVALID(TXVALID),
  .TXDATA(TXDATA),
  .TXREADY(TXREADY),
  .TXCOMPLITE(TXCOMPLITE),
  .UART_TX(UART_TX),
  .DATA_WIDTH(DATA_WIDTH),
  .STOP_WIDTH(STOP_WIDTH),
  .PARITY_ENABLE(PARITY_ENABLE),
  .PARITY_TYPE(PARITY_TYPE)
);

uart_rx_sync uart_rx_sync (
  .SYSCLK(SYSCLK),
  .RESETB(RESETB),
  .RXEN(RXEN),
  .UART_RX(UART_RX),
  .RXCOMPLITE(RXCOMPLITE),
  .SYNC_RX_DATA(SYNC_RX_DATA),
  .SYNC_RX_TIM(SYNC_RX_TIM),
  .DIVIDER_RATE(DIVIDER_RATE)
);

uart_rx uart_rx (
  .SYSCLK(SYSCLK),
  .RESETB(RESETB),
  .SYNC_RX_TIM(SYNC_RX_TIM),
  .SYNC_RX_DATA(SYNC_RX_DATA),
  .RXDATA(RXDATA),
  .RXVALID(RXVALID),
  .RXACTIVE(RXACTIVE),
  .RXDETECT(RXDETECT),
  .RXCOMPLITE(RXCOMPLITE),
  .ERR_PARITY(ERR_PARITY),
  .ERR_FRAME(ERR_FRAME),
  .ERR_OVERRUN(ERR_OVERRUN),
  .DATA_WIDTH(DATA_WIDTH),
  .STOP_WIDTH(STOP_WIDTH),
  .PARITY_ENABLE(PARITY_ENABLE),
  .PARITY_TYPE(PARITY_TYPE)
);

endmodule
