//-----------------------------------------------
// Module: uart_tim_gen
// Space Cubics UART Core Timing Generator
//-----------------------------------------------
// Copyright © 2018 Space Cubics, LLC.
//-----------------------------------------------
module uart_tim_gen (
  input  SYSCLK,
  input  RESETB,
  input  TXEN,
  input  TXREADY,
  input  TXVALID,
  input  TXCOMPLITE,
  input  [15:0] DIVIDER_RATE,
  output TX_TIM
);

// Divider
reg [15:0] counter;
reg txactive;
always @ (posedge SYSCLK or negedge RESETB)
begin
  if (!RESETB)
    counter <= 16'h0;
  else if (counter == DIVIDER_RATE)
    counter <= 16'h0;
  else if (TXEN | txactive)
    counter <= counter + 1;
end

// Transmit Timing Signal
assign TX_TIM = (counter == DIVIDER_RATE);

// TXACTIVE
always @ (posedge SYSCLK or negedge RESETB)
begin
  if (!RESETB)
    txactive <= 1'b0;
  else if (TXVALID & TXREADY)
    txactive <= 1'b1;
  else if (TXCOMPLITE)
    txactive <= 1'b0;
end

endmodule
