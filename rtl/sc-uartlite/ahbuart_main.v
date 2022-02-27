//-----------------------------------------------
// Module: ahbuart_main
//  UART Lite Main Controller
//-----------------------------------------------
// Copyright © 2020 Space Cubics, LLC.
//-----------------------------------------------
module ahbuart_main # (
  parameter P_FIFO_DEPTH = 4  // Renge: 1-15
) (
  // System Interface
  input SYSCLK,
  input RESETB,

  // Register Interface
  output reg REG_TXF_FULL,
  output reg REG_TXF_EMPTY,
  output reg REG_RXF_FULL,
  output reg REG_RXF_DVALID,
  output reg REG_RXF_OVERRUN,
  output reg REG_UART_RXFRMERR,

  // TX FIFO Interface
  output reg TX_FIFO_REN,
  input [7:0] TX_FIFO_RDATA,
  input [P_FIFO_DEPTH:0] TX_FIFO_DCOUNT,

  // RX FIFO Interface
  output reg RX_FIFO_WEN,
  input RX_FIFO_REN,
  output reg [7:0] RX_FIFO_WDATA,
  input [P_FIFO_DEPTH:0] RX_FIFO_DCOUNT,

  // UART Core Interface
  output reg UART_TXVALID,
  output reg [7:0] UART_TXDATA,
  input UART_TXREADY,
  input UART_TXCOMPLITE,
  input UART_RXVALID,
  input [7:0] UART_RXDATA,
  output reg UART_RXDETECT,
  input UART_RXCOMPLITE,
  input UART_RXFRMERR
);

reg [1:0] r_tx_read_cnt;
reg [1:0] r_uart_tx_stm;

parameter P_TX_IDLE  = 2'h0,
          P_TX_READ  = 2'h1,
          P_TX_START = 2'h2,
          P_TX_TRANS = 2'h3;

// UART TX Control
always @ (posedge SYSCLK or negedge RESETB) begin
  if (!RESETB) begin
    r_tx_read_cnt <= 0;
    TX_FIFO_REN   <= 0;
    UART_TXVALID  <= 0;
    UART_TXDATA   <= 0;
    r_uart_tx_stm <= P_TX_IDLE;
  end else begin
    case (r_uart_tx_stm)
      P_TX_IDLE : begin
        r_tx_read_cnt <= 0;
        TX_FIFO_REN   <= 0;
        UART_TXVALID  <= 0;
        UART_TXDATA   <= 0;
        if (|TX_FIFO_DCOUNT) begin
          TX_FIFO_REN   <= 1'b1;
          r_uart_tx_stm <= P_TX_READ;
        end
      end
      P_TX_READ : begin
        TX_FIFO_REN <= 0;
        if (r_tx_read_cnt >= 2'b10) begin
          r_tx_read_cnt <= 0;
          UART_TXVALID  <= 1'b1;
          UART_TXDATA   <= TX_FIFO_RDATA;
          r_uart_tx_stm <= P_TX_START;
        end else begin
          r_tx_read_cnt <= r_tx_read_cnt + 1;
        end
      end
      P_TX_START : begin
        if (UART_TXREADY) begin
          UART_TXVALID  <= 0;
          UART_TXDATA   <= 0;
          r_uart_tx_stm <= P_TX_TRANS;
        end
      end
      P_TX_TRANS : begin
        if (UART_TXCOMPLITE)
          r_uart_tx_stm <= P_TX_IDLE;
      end
      default : begin
        r_uart_tx_stm <= P_TX_IDLE;
      end
    endcase
  end
end

// TX FIFO Capacity
always @ (posedge SYSCLK or negedge RESETB) begin
  if (!RESETB) begin
    REG_TXF_FULL  <= 0;
    REG_TXF_EMPTY <= 1'b1;
  end else begin
    REG_TXF_FULL <= TX_FIFO_DCOUNT[P_FIFO_DEPTH];
    if (r_uart_tx_stm == P_TX_IDLE)
      REG_TXF_EMPTY <= ~|TX_FIFO_DCOUNT;
  end
end

// UART RX Control
always @ (posedge SYSCLK or negedge RESETB) begin
  if (!RESETB) begin
    UART_RXDETECT     <= 0;
    RX_FIFO_WEN       <= 0;
    RX_FIFO_WDATA     <= 0;
    REG_UART_RXFRMERR <= 0;
  end else begin
    UART_RXDETECT     <= 0;
    RX_FIFO_WEN       <= 0;
    RX_FIFO_WDATA     <= 0;
    REG_UART_RXFRMERR <= 0;
    if (UART_RXVALID & UART_RXCOMPLITE) begin
      UART_RXDETECT <= 1'b1;
      if (~UART_RXFRMERR) begin
        RX_FIFO_WEN   <= ~RX_FIFO_DCOUNT[P_FIFO_DEPTH];
        RX_FIFO_WDATA <= UART_RXDATA;
      end else begin
        REG_UART_RXFRMERR <= 1'b1;
      end
    end
  end
end

// RX FIFO Capacity
always @ (posedge SYSCLK or negedge RESETB) begin
  if (!RESETB) begin
    REG_RXF_FULL    <= 0;
    REG_RXF_DVALID  <= 0;
    REG_RXF_OVERRUN <= 0;
  end else begin
    REG_RXF_FULL    <= RX_FIFO_DCOUNT[P_FIFO_DEPTH];
    REG_RXF_DVALID  <= |RX_FIFO_DCOUNT & ~RX_FIFO_REN;
    REG_RXF_OVERRUN <= UART_RXVALID & UART_RXCOMPLITE & RX_FIFO_DCOUNT[P_FIFO_DEPTH];
  end
end

endmodule
