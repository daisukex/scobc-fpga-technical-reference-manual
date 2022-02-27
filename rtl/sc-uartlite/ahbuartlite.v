//-----------------------------------------------
// Module: ahbuartlite
//  AHB UART Lite Controller
//-----------------------------------------------
// Copyright © 2020 Space Cubics, LLC.
//-----------------------------------------------
module ahbuartlite # (
  parameter [15:0] P_UDIV_INIT = 16'h0363,
  parameter [2:0] P_UART_DATA_W = 3'h7,
  parameter P_UART_STOP_W = 1'b0,
  parameter P_UART_PRTY_EN = 1'b0,
  parameter [1:0] P_UART_PRTY_TYPE = 2'h0,
  parameter P_FIFO_DEPTH = 4
) (
  // System Interface
  input SYSCLK,
  input RESETB,
  input MODULE_RSTN,
  output INTERRUPT,

  // AHB Interface
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

  // UART Interface
  output UART_TX,
  input UART_RX
);

wire ahb_uart_resetn;

wire w_ahb_rd;
wire [31:0] w_ahb_addr;
wire w_ahb_wait;
wire w_reg_dphase;
wire w_reg_w1r0;
wire [31:0] w_reg_addr;
wire  [3:0] w_reg_byteen;
wire [31:0] w_reg_wdata;
wire [31:0] w_reg_rdata;
wire w_reg_accerr;

wire w_reg_txf_full;
wire w_reg_txf_empty;
wire w_reg_rxf_full;
wire w_reg_rxf_dvalid;
wire w_reg_rxf_overrun;
wire w_reg_txf_wen;
wire [7:0] w_reg_txf_wdata;
wire w_reg_txf_rst;
wire w_reg_rxf_ren;
wire [7:0] w_reg_rxf_rdata;
wire w_reg_rxf_rst;
wire [15:0] w_reg_uart_div_rate;
wire w_reg_uart_rxprtyerr;
wire w_reg_uart_rxfrmerr;

wire w_main_txf_ren;
wire [7:0] w_main_txf_rdata;
wire [4:0] w_txf_dcount;
wire w_main_rxf_wen;
wire [7:0] w_main_rxf_wdata;
wire [4:0] w_rxf_dcount;

wire w_uart_txvalid;
wire [7:0] w_uart_txdata;
wire w_uart_txready;
wire w_uart_txcomplite;
wire w_uart_rxvalid;
wire [7:0] w_uart_rxdata;
wire w_uart_rxdetect;
wire w_uart_rxcomplite;
wire w_uart_rxfrmerr;

assign ahb_uart_resetn = RESETB & MODULE_RSTN;

// AHB Slave
sc_ahb_slave ahb_slave (
  // AHB Interface
  .HCLK(SYSCLK),             // input
  .HRESETN(ahb_uart_resetn), // input
  .HSEL(SHSEL),              // input
  .HADDR(SHADDR),            // input  [31:0]
  .HTRANS(SHTRANS),          // input  [1:0]
  .HSIZE(SHSIZE),            // input  [2:0]
  .HBURST(SHBURST),          // input  [2:0]
  .HWRITE(SHWRITE),          // input
  .HREADYIN(SHREADYIN),      // input
  .HREADYOUT(SHREADYOUT),    // output
  .HWDATA(SHWDATA),          // input  [31:0]
  .HRDATA(SHRDATA),          // output [31:0]
  .HRESP(SHRESP),            // output [1:0]

  // Register Interface
  .AHB_WR(/*open*/),         // output
  .AHB_RD(w_ahb_rd),         // output
  .AHB_ADDR(w_ahb_addr),     // output [31:0]
  .AHB_WAIT(w_ahb_wait),     // input
  .REG_DPHASE(w_reg_dphase), // output
  .REG_W1R0(w_reg_w1r0),     // output
  .REG_ADDR(w_reg_addr),     // output [31:0]
  .REG_BYTEEN(w_reg_byteen), // output [3:0]
  .REG_WDATA(w_reg_wdata),   // output [31:0]
  .REG_RDATA(w_reg_rdata),   // input  [31:0]
  .REG_ACCERR(w_reg_accerr)  // input
);

// AHB UART Lite Register
ahbuart_reg # (
  .P_UDIV_INIT(P_UDIV_INIT)
) ahbuart_reg (
  // System Interface
  .SYSCLK(SYSCLK),                           // input
  .RESETB(ahb_uart_resetn),                  // input

  // AHB Interface
  .REG_ACC(w_reg_dphase),                    // input
  .REG_W1R0(w_reg_w1r0),                     // input
  .REG_ADDR(w_reg_addr),                     // input [31:0]
  .REG_BYTEEN(w_reg_byteen),                 // input [3:0]
  .REG_WDATA(w_reg_wdata),                   // input [31:0]
  .REG_RDATA(w_reg_rdata),                   // output [31:0]
  .REG_ACCERR(w_reg_accerr),                 // output
  .AHB_RD(w_ahb_rd),                         // input
  .AHB_ADDR(w_ahb_addr),                     // input [31:0]
  .AHB_WAIT(w_ahb_wait),                     // output

  // MAIN Controller Interface
  .REG_TXF_FULL(w_reg_txf_full),             // input
  .REG_TXF_EMPTY(w_reg_txf_empty),           // input
  .REG_RXF_FULL(w_reg_rxf_full),             // input
  .REG_RXF_DVALID(w_reg_rxf_dvalid),         // input
  .REG_RXF_OVERRUN(w_reg_rxf_overrun),       // input

  // TX FIFO Interface
  .REG_TXF_WEN(w_reg_txf_wen),               // output
  .REG_TXF_WDATA(w_reg_txf_wdata),           // output [7:0]
  .REG_TXF_RST(w_reg_txf_rst),               // output

  // RX FIFO Interface
  .REG_RXF_REN(w_reg_rxf_ren),               // output
  .REG_RXF_RDATA(w_reg_rxf_rdata),           // input [7:0]
  .REG_RXF_RST(w_reg_rxf_rst),               // output

  // UART Core Interface
  .REG_UART_DIV_RATE(w_reg_uart_div_rate),   // output [15:0]
  .REG_UART_RXPRTYERR(w_reg_uart_rxprtyerr), // input
  .REG_UART_RXFRMERR(w_reg_uart_rxfrmerr),   // input

  // Interrupt Interface
  .INTERRUPT(INTERRUPT)                      // output
);

// TX_FIFO
sc_fifo # (
  .P_FIFO_WIDTH(8),
  .P_FIFO_DEPTH(P_FIFO_DEPTH), // Renge: 1-15
  .P_FIFO_TYPE(1)              // 0: BlockRAM 1: Shift Register
) tx_fifo (
  .CLK(SYSCLK),                          // input
  .SRST_N(ahb_uart_resetn),              // input
  .FIFO_RST(w_reg_txf_rst),              // input

  .WR_EN(w_reg_txf_wen),                 // input
  .DIN(w_reg_txf_wdata),                 // input [P_FIFO_WIDTH-1:0]
  .RD_EN(w_main_txf_ren),                // input
  .DOUT(w_main_txf_rdata),               // output [P_FIFO_WIDTH-1:0]

  .OVER_TH_LVL({P_FIFO_DEPTH+1{1'b0}}),  // input [P_FIFO_DEPTH:0]
  .UNDER_TH_LVL({P_FIFO_DEPTH+1{1'b0}}), // input [P_FIFO_DEPTH:0]

  .FULL(/* open */),                     // output
  .EMPTY(/* open */),                    // output
  .OVERFLOW(/* open */),                 // output
  .UNDERFLOW(/* open */),                // output
  .OVER_TH(/* open */),                  // output
  .UNDER_TH(/* open */),                 // output
  .DATA_COUNT(w_txf_dcount)              // output [P_FIFO_DEPTH:0]
);

// RX_FIFO
sc_fifo # (
  .P_FIFO_WIDTH(8),
  .P_FIFO_DEPTH(P_FIFO_DEPTH), // Renge: 1-15
  .P_FIFO_TYPE(1)              // 0: BlockRAM 1: Shift Register
) rx_fifo (
  .CLK(SYSCLK),                          // input
  .SRST_N(ahb_uart_resetn),              // input
  .FIFO_RST(w_reg_rxf_rst),              // input

  .WR_EN(w_main_rxf_wen),                // input
  .DIN(w_main_rxf_wdata),                // input [P_FIFO_WIDTH-1:0]
  .RD_EN(w_reg_rxf_ren),                 // input
  .DOUT(w_reg_rxf_rdata),                // output [P_FIFO_WIDTH-1:0]

  .OVER_TH_LVL({P_FIFO_DEPTH+1{1'b0}}),  // input [P_FIFO_DEPTH:0]
  .UNDER_TH_LVL({P_FIFO_DEPTH+1{1'b0}}), // input [P_FIFO_DEPTH:0]

  .FULL(/* open */),                     // output
  .EMPTY(/* open */),                    // output
  .OVERFLOW(/* open */),                 // output
  .UNDERFLOW(/* open */),                // output
  .OVER_TH(/* open */),                  // output
  .UNDER_TH(/* open */),                 // output
  .DATA_COUNT(w_rxf_dcount)              // output [P_FIFO_DEPTH:0]
);

// UART Lite Main Controller
ahbuart_main # (
  .P_FIFO_DEPTH(P_FIFO_DEPTH)  // Renge: 1-15
) ahbuart_main (
  // System Interface
  .SYSCLK(SYSCLK),                         // input
  .RESETB(ahb_uart_resetn),                // input

  // Register Interface
  .REG_TXF_FULL(w_reg_txf_full),           // output
  .REG_TXF_EMPTY(w_reg_txf_empty),         // output
  .REG_RXF_FULL(w_reg_rxf_full),           // output
  .REG_RXF_DVALID(w_reg_rxf_dvalid),       // output
  .REG_RXF_OVERRUN(w_reg_rxf_overrun),     // output
  .REG_UART_RXFRMERR(w_reg_uart_rxfrmerr), // output

  // TX FIFO Interface
  .TX_FIFO_REN(w_main_txf_ren),            // output
  .TX_FIFO_RDATA(w_main_txf_rdata),        // input [7:0]
  .TX_FIFO_DCOUNT(w_txf_dcount),           // input [P_FIFO_DEPTH:0]

  // RX FIFO Interface
  .RX_FIFO_WEN(w_main_rxf_wen),            // output
  .RX_FIFO_REN(w_reg_rxf_ren),             // input
  .RX_FIFO_WDATA(w_main_rxf_wdata),        // output [7:0]
  .RX_FIFO_DCOUNT(w_rxf_dcount),           // input [P_FIFO_DEPTH:0]

  // UART Core Interface
  .UART_TXVALID(w_uart_txvalid),           // output
  .UART_TXDATA(w_uart_txdata),             // output [7:0]
  .UART_TXREADY(w_uart_txready),           // input
  .UART_TXCOMPLITE(w_uart_txcomplite),     // input
  .UART_RXVALID(w_uart_rxvalid),           // input
  .UART_RXDATA(w_uart_rxdata),             // input [7:0]
  .UART_RXDETECT(w_uart_rxdetect),         // output
  .UART_RXCOMPLITE(w_uart_rxcomplite),     // input
  .UART_RXFRMERR(w_uart_rxfrmerr)          // input
);

// UART_CORE
sc_uart_core uart_core (
  // System Interface
  .SYSCLK(SYSCLK),                    // input
  .RESETB(ahb_uart_resetn),           // input

  // Register Interface
  .TXEN(1'b1),                        // input
  .TXVALID(w_uart_txvalid),           // input
  .TXDATA(w_uart_txdata),             // input [7:0]
  .TXREADY(w_uart_txready),           // output
  .TXCOMPLITE(w_uart_txcomplite),     // output
  .TXCLKTIM(/*open*/),                // output
  .RXEN(1'b1),                        // input
  .RXVALID(w_uart_rxvalid),           // output
  .RXACTIVE(/*open*/),                // output
  .RXDATA(w_uart_rxdata),             // output [7:0]
  .RXDETECT(w_uart_rxdetect),         // input
  .RXCOMPLITE(w_uart_rxcomplite),     // output
  .ERR_PARITY(w_reg_uart_rxprtyerr),  // output
  .ERR_FRAME(w_uart_rxfrmerr),        // output
  .ERR_OVERRUN(/*open*/),             // output

  // UART Interface
  .UART_TX(UART_TX),                  // output
  .UART_RX(UART_RX),                  // input

  // UART Frame Configuration
  .DIVIDER_RATE(w_reg_uart_div_rate), // input [15:0]
  .DATA_WIDTH(P_UART_DATA_W),         // input [2:0]
  .STOP_WIDTH(P_UART_STOP_W),         // input
  .PARITY_ENABLE(P_UART_PRTY_EN),     // input
  .PARITY_TYPE(P_UART_PRTY_TYPE)      // input [1:0]
);

endmodule
