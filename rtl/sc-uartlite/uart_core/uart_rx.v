//-----------------------------------------------
// Module: uart_rx
// Space Cubics UART Core Reciver Module
//-----------------------------------------------
// Copyright © 2018 Space Cubics, LLC.
//-----------------------------------------------
module uart_rx (
  // System Interface
  input  SYSCLK,
  input  RESETB,

  // UART Interface
  input  SYNC_RX_TIM,
  input  SYNC_RX_DATA,

  // Register Interface
  output reg [7:0] RXDATA,
  output reg RXVALID,
  input  RXDETECT,
  output RXACTIVE,
  output reg RXCOMPLITE,
  output reg ERR_PARITY,
  output reg ERR_FRAME,
  output reg ERR_OVERRUN,

  // UART Control Interface
  input  [2:0] DATA_WIDTH,
  input  STOP_WIDTH,
  input  PARITY_ENABLE,
  input  [1:0] PARITY_TYPE
);

// UART RX State Machine
parameter
  IDLE   = 4'b0001,
  DATA   = 4'b0010,
  PARITY = 4'b0100,
  STOP   = 4'b1000;
reg [3:0] rxstate;

assign RXACTIVE = (rxstate != IDLE);

reg [2:0] rxcount;
reg [7:0] rxd;
reg parbit;
reg p_err_det;
wire f_err_det;
always @ (posedge SYSCLK or negedge RESETB)
begin
  if (!RESETB) begin
    rxcount    <= 3'h0;
    rxd        <= 8'h0;
    parbit     <= 1'b0;
    p_err_det  <= 1'b0;
    rxstate    <= IDLE;
  end
  else if (SYNC_RX_TIM) begin

    // IDLE State
    if (rxstate == IDLE) begin
      if (!SYNC_RX_DATA) begin
        rxcount   <= 3'h0;
        rxd       <= 8'h0;
        parbit    <= 1'b0;
        p_err_det <= 1'b0;
        rxstate   <= DATA;
      end
    end

    // DATA State
    if (rxstate == DATA) begin
      rxd[rxcount] <= SYNC_RX_DATA;
      parbit       <= parbit ^ SYNC_RX_DATA;
      rxcount      <= rxcount + 3'h1;
      if (rxcount == (DATA_WIDTH)) begin
        if (PARITY_ENABLE) begin
          rxstate <= PARITY;
        end
        else begin
          if (STOP_WIDTH)
            rxcount <= 3'h1;
          else
            rxcount <= 3'h0;
          rxstate <= STOP;
        end
      end
    end

    // PARITY State
    if (rxstate == PARITY) begin
      if (PARITY_TYPE[1] & SYNC_RX_DATA != PARITY_TYPE[0])
        p_err_det <= 1'b1;
      else if (~PARITY_TYPE[1] & SYNC_RX_DATA != (parbit ^ PARITY_TYPE[0]))
        p_err_det <= 1'b1;

      if (STOP_WIDTH)
        rxcount <= 3'h1;
      else
        rxcount <= 3'h0;

      rxstate <= STOP;
    end

    // STOP bit State
    if (rxstate == STOP) begin
      if (rxcount != 3'h0)
        rxcount <= 3'h0;
      else if (SYNC_RX_DATA) begin
        rxstate    <= IDLE;
      end
    end
  end
end
assign f_err_det = (rxstate == STOP & !SYNC_RX_DATA);

// RX Data Handling
always @ (posedge SYSCLK or negedge RESETB)
begin
  if (!RESETB) begin
    RXCOMPLITE  <= 1'b0;
    RXVALID     <= 1'b0;
    RXDATA      <= 8'h0;
    ERR_PARITY  <= 1'b0;
    ERR_FRAME   <= 1'b0;
    ERR_OVERRUN <= 1'b0;
  end
  else if (RXCOMPLITE)
    RXCOMPLITE <= 1'b0;
  else if (SYNC_RX_TIM & rxstate == STOP & rxcount == 3'h0) begin
    if (RXVALID)
      ERR_OVERRUN <= 1'b1;

    if (f_err_det)
      ERR_FRAME <= 1'b1;

    if (SYNC_RX_DATA) begin
      RXCOMPLITE  <= 1'b1;
      RXVALID     <= 1'b1;
      RXDATA      <= rxd;
      ERR_PARITY  <= p_err_det;
    end
  end
  else if (RXDETECT) begin
    RXVALID     <= 1'b0;
    RXDATA      <= 8'h0;
    ERR_PARITY  <= 1'b0;
    ERR_FRAME   <= 1'b0;
    ERR_OVERRUN <= 1'b0;
  end
end

endmodule
