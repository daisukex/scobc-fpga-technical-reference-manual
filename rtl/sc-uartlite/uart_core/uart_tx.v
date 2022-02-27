//-----------------------------------------------
// Module: uart_tx
// Space Cubics UART Core Transmit Module
//-----------------------------------------------
// Copyright © 2018 Space Cubics, LLC.
//-----------------------------------------------
module uart_tx (
  input  SYSCLK,
  input  RESETB,
  input  TX_TIM,
  input  TXEN,
  input  TXVALID,
  input  [7:0] TXDATA,
  output reg TXREADY,
  output reg TXCOMPLITE,
  input  [2:0] DATA_WIDTH,
  input  STOP_WIDTH,
  input  PARITY_ENABLE,
  input  [1:0] PARITY_TYPE,
  output reg UART_TX
);

// TX State Machine
parameter
  IDLE   = 5'b00001,
  START  = 5'b00010,
  DATA   = 5'b00100,
  PARITY = 5'b01000,
  STOP   = 5'b10000;
reg [4:0] txstate;

// Transmit State Machine
reg parbit;
reg [2:0] txcount;
reg [7:0] txd;
always @ (posedge SYSCLK or negedge RESETB)
begin
  if (!RESETB) begin
    UART_TX    <= 1'b1;
    parbit     <= 1'b0;
    txcount    <= 0;
    txstate    <= IDLE;
  end
  else if (TX_TIM) begin

    // IDLE State
    if (txstate == IDLE) begin
      if (!TXREADY) begin
        UART_TX <= 1'b0;
        parbit  <= 1'b0;
        txcount <= 3'h0;
        txstate <= START;
      end
    end

    // START State
    if (txstate == START) begin
      UART_TX <= txd[0];
      parbit  <= txd[0];
      txcount <= 3'h0;
      txstate <= DATA;
    end

    // DATA State
    if (txstate == DATA) begin
      if (txcount == (DATA_WIDTH)) begin
        if (PARITY_ENABLE) begin
          txstate <= PARITY;
          if (PARITY_TYPE[1])
            UART_TX <= PARITY_TYPE[0];
          else
            UART_TX <= PARITY_TYPE[0] ^ parbit;
        end
        else begin
          UART_TX <= 1'b1;
          if (!STOP_WIDTH)
            txcount <= 3'h0;
          else
            txcount <= 3'h1;
          txstate <= STOP;
        end
      end
      else begin
        UART_TX <= txd[txcount + 3'h1];
        parbit  <= parbit ^ txd[txcount + 3'h1];
        txcount <= txcount + 3'h1;
      end
    end

    // PARITY State
    if (txstate == PARITY) begin
      if (!STOP_WIDTH)
        txcount <= 0;
      else
        txcount <= 1;
      UART_TX   <= 1'b1;
      txstate   <= STOP;
    end

    // STOP State
    if (txstate == STOP) begin
      if (txcount != 3'h0)
        txcount <= 3'h0;
      else begin
        txstate <= IDLE;
      end
    end
  end
end

// Transmit Buffer Control
always @ (posedge SYSCLK or negedge RESETB)
begin
  if (!RESETB) begin
    TXCOMPLITE <= 1'b0;
    TXREADY    <= 1'b1;
    txd        <= 8'h0;
  end
  else begin
    TXCOMPLITE <= 1'b0;
    if (TX_TIM & txstate == STOP & txcount == 3'h0) begin
      TXCOMPLITE <= 1'b1;
      TXREADY    <= 1'b1;
    end
    else if (TXEN & TXREADY & TXVALID & txstate == IDLE) begin
      txd     <= TXDATA;
      TXREADY <= 1'b0;
    end
  end
end

endmodule
