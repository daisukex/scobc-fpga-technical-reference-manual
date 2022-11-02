//-----------------------------------------------
// Module: ahbuart_reg
//  AHB UART Lite Register
//-----------------------------------------------
// Copyright © 2020 Space Cubics, LLC.
//-----------------------------------------------
`include "ahbuart_version.vh"
`include "ahbuart_reg_map.vh"

module ahbuart_reg # (
  parameter [15:0] P_UDIV_INIT = 16'h0363
) (
  // System Interface
  input SYSCLK,
  input RESETB,

  // AHB Interface
  input REG_ACC,
  input REG_W1R0,
  input [31:0] REG_ADDR,
  input [3:0] REG_BYTEEN,
  input [31:0] REG_WDATA,
  output [31:0] REG_RDATA,
  output REG_ACCERR,
  input AHB_RD,
  input [31:0] AHB_ADDR,
  output AHB_WAIT,

  // MAIN Controller Interface
  input REG_TXF_FULL,
  input REG_TXF_EMPTY,
  input REG_RXF_FULL,
  input REG_RXF_DVALID,
  input REG_RXF_OVERRUN,

  // TX FIFO Interface
  output reg REG_TXF_WEN,
  output reg [7:0] REG_TXF_WDATA,
  output reg REG_TXF_RST,

  // RX FIFO Interface
  output REG_RXF_REN,
  input [7:0] REG_RXF_RDATA,
  output reg REG_RXF_RST,

  // UART Core Interface
  output reg [15:0] REG_UART_DIV_RATE,
  input REG_UART_RXPRTYERR,
  input REG_UART_RXFRMERR,

  // Interrupt Interface
  output INTERRUPT
);

wire w_reg_write;
wire w_reg_read;
assign w_reg_write = REG_ACC &  REG_W1R0;
assign w_reg_read  = REG_ACC & !REG_W1R0;

// Address Decoder
wire w_hit_rxfifor;
wire w_hit_txfifor;
wire w_hit_statr;
wire w_hit_ctrlr;
wire w_hit_ubrsr;
wire w_hit_ahbuver;
assign w_hit_rxfifor = ({REG_ADDR[15:2] , 2'b00} == `AHBURXFIFOR);
assign w_hit_txfifor = ({REG_ADDR[15:2] , 2'b00} == `AHBUTXFIFOR);
assign w_hit_statr   = ({REG_ADDR[15:2] , 2'b00} == `AHBUSTATR);
assign w_hit_ctrlr   = ({REG_ADDR[15:2] , 2'b00} == `AHBUCTRLR);
assign w_hit_ubrsr   = ({REG_ADDR[15:2] , 2'b00} == `AHBUUBRSR);
assign w_hit_ahbuver = ({REG_ADDR[15:2] , 2'b00} == `AHBUVER);

// RX FIFO Read Wait
wire w_rxf_rd_wait;
reg r_rxf_rd_wait_p1;

assign w_rxf_rd_wait = (AHB_RD & ({AHB_ADDR[15:2] , 2'b00} == `AHBURXFIFOR) & REG_RXF_DVALID);

always @ (posedge SYSCLK or negedge RESETB) begin
  if (!RESETB) begin
    r_rxf_rd_wait_p1 <= 0;
  end else begin
    r_rxf_rd_wait_p1 <= w_rxf_rd_wait;
  end
end

assign AHB_WAIT = w_rxf_rd_wait | r_rxf_rd_wait_p1;

// Rx FIFO Register
//----------------------------------------------
wire w_rxf_rerr;
reg [1:0] r_rxf_rd_en_retim;

assign REG_RXF_REN = w_hit_rxfifor & w_reg_read & r_rxf_rd_wait_p1 & REG_RXF_DVALID;
assign w_rxf_rerr  = w_hit_rxfifor & w_reg_read & ~(REG_RXF_REN | |r_rxf_rd_en_retim);

always @ (posedge SYSCLK or negedge RESETB) begin
  if (!RESETB) begin
    r_rxf_rd_en_retim <= 0;
  end else begin
    r_rxf_rd_en_retim <= {r_rxf_rd_en_retim[0], REG_RXF_REN};
  end
end

wire [31:0] w_rd_rxfifor;
assign w_rd_rxfifor = (r_rxf_rd_en_retim[1]) ?
                     {{32-8-`AHBUUARTRXDATA{1'b0}}, REG_RXF_RDATA, {`AHBUUARTRXDATA{1'b0}}} :
                     32'h0;

// Tx FIFO Register
//----------------------------------------------
wire w_txf_werr;
assign w_txf_werr = w_hit_txfifor & w_reg_write & REG_BYTEEN[0] & REG_TXF_FULL;

always @ (*) begin
  if (w_hit_txfifor & w_reg_write & REG_BYTEEN[0] & ~REG_TXF_FULL) begin
    REG_TXF_WEN   = 1'b1;
    REG_TXF_WDATA = REG_WDATA[`AHBUUARTTXDATA +: 8];
  end else begin
    REG_TXF_WEN   = 0;
    REG_TXF_WDATA = 0;
  end
end

// Status Register
//----------------------------------------------
reg r_intena_sts;
reg r_rxf_overrun_sts;
reg r_rxfrmerr_sts;
reg r_rxprtyerr_sts;
reg r_rxf_underrun_sts;
reg r_txf_overrun_sts;
always @ (posedge SYSCLK or negedge RESETB) begin
  if (!RESETB) begin
    r_rxf_overrun_sts <= 1'b0;
    r_rxfrmerr_sts    <= 1'b0;
    r_rxprtyerr_sts   <= 1'b0;
    r_rxf_underrun_sts <= 1'b0;
    r_txf_overrun_sts <= 1'b0;
  end else begin
    if (REG_RXF_OVERRUN)
      r_rxf_overrun_sts <= 1'b1;
    if (REG_UART_RXFRMERR)
      r_rxfrmerr_sts    <= 1'b1;
    if (REG_UART_RXPRTYERR)
      r_rxprtyerr_sts   <= 1'b1;
    if (w_rxf_rerr)
      r_rxf_underrun_sts <= 1'b1;
    if (w_txf_werr)
      r_txf_overrun_sts <= 1'b1;
    if (w_hit_statr & w_reg_read) begin
      if (REG_BYTEEN[0]) begin
        r_rxf_overrun_sts <= 1'b0;
        r_rxfrmerr_sts    <= 1'b0;
        r_rxprtyerr_sts   <= 1'b0;
      end
      if (REG_BYTEEN[1]) begin
        r_rxf_underrun_sts <= 1'b0;
        r_txf_overrun_sts  <= 1'b0;
      end
    end
  end
end

wire [31:0] w_rd_statr;
assign w_rd_statr = (w_hit_statr & w_reg_read) ?
                    {{32-1-`AHBUTXOVERRUNERR{1'b0}}, r_txf_overrun_sts, {`AHBUTXOVERRUNERR{1'b0}}} |
                    {{32-1-`AHBURXUNDERRUNERR{1'b0}}, r_rxf_underrun_sts, {`AHBURXUNDERRUNERR{1'b0}}} |
                    {{32-1-`AHBUPRTYERR{1'b0}},     r_rxprtyerr_sts,    {`AHBUPRTYERR{1'b0}}}    |
                    {{32-1-`AHBUFRAMEERR{1'b0}},    r_rxfrmerr_sts,     {`AHBUFRAMEERR{1'b0}}}   |
                    {{32-1-`AHBUOVERRUNERR{1'b0}},  r_rxf_overrun_sts,  {`AHBUOVERRUNERR{1'b0}}} |
                    {{32-1-`AHBUINTENAMON{1'b0}},   r_intena_sts,       {`AHBUINTENAMON{1'b0}}}  |
                    {{32-1-`AHBUTXFIFOFULL{1'b0}},  REG_TXF_FULL,       {`AHBUTXFIFOFULL{1'b0}}} |
                    {{32-1-`AHBUTXFIFOEMP{1'b0}},   REG_TXF_EMPTY,      {`AHBUTXFIFOEMP{1'b0}}}  |
                    {{32-1-`AHBURXFIFOFULL{1'b0}},  REG_RXF_FULL,       {`AHBURXFIFOFULL{1'b0}}} |
                    {{32-1-`AHBURXFIFOVAL{1'b0}},   REG_RXF_DVALID,     {`AHBURXFIFOVAL{1'b0}}}  :
                    32'h0;

// Control Register
//----------------------------------------------
always @ (posedge SYSCLK or negedge RESETB) begin
  if (!RESETB) begin
    REG_TXF_RST  <= 1'b0;
    REG_RXF_RST  <= 1'b0;
    r_intena_sts <= 1'b0;
  end else begin
    if (w_hit_ctrlr & w_reg_write & REG_BYTEEN[0]) begin
        REG_TXF_RST  <= REG_WDATA[`AHBUTXFIFORST];
        REG_RXF_RST  <= REG_WDATA[`AHBURXFIFORST];
        r_intena_sts <= REG_WDATA[`AHBUINTENACTL];
    end else begin
      REG_TXF_RST <= 1'b0;
      REG_RXF_RST <= 1'b0;
    end
  end
end

// UART Baudrate Setting Register
//----------------------------------------------
always @ (posedge SYSCLK or negedge RESETB) begin
  if (!RESETB) begin
    REG_UART_DIV_RATE <= P_UDIV_INIT;
  end else if (w_hit_ubrsr & w_reg_write) begin
    if (REG_BYTEEN[1])
      REG_UART_DIV_RATE[15:8] <= REG_WDATA[`AHBUUDIVSET+8 +: 8];
    if (REG_BYTEEN[0])
      REG_UART_DIV_RATE[7:0]  <= REG_WDATA[`AHBUUDIVSET +: 8];
  end
end

wire [31:0] w_rd_ubrsr;
assign w_rd_ubrsr = (w_hit_ubrsr & w_reg_read) ?
                    {{32-16-`AHBUUDIVSET{1'b0}}, REG_UART_DIV_RATE, {`AHBUUDIVSET{1'b0}}} :
                    32'h0;

// IP Version Register
//----------------------------------------------
wire [31:0] w_rd_ahbuver;
assign w_rd_ahbuver = (w_hit_ahbuver & w_reg_read) ?
                      {{32- 8-`AHBUMAJVER{1'b0}},  `AHBU_MAJVERVAL,  {`AHBUMAJVER{1'b0}}} |
                      {{32- 8-`AHBUMINVER{1'b0}},  `AHBU_MINVERVAL,  {`AHBUMINVER{1'b0}}} |
                      {{32-16-`AHBUPATVER{1'b0}},  `AHBU_PATVERVAL,  {`AHBUPATVER{1'b0}}} :
                      32'h0;

// AHB Accsess Slave Error
//----------------------------------------------
assign REG_ACCERR = 1'b0;

// Interrupt
//----------------------------------------------
reg r_rxf_dvalid_p1;
reg r_txf_empty_p1;
reg r_rxf_rerr_p1;
reg r_txf_werr_p1;
always @ (posedge SYSCLK or negedge RESETB) begin
  if (!RESETB) begin
    r_rxf_dvalid_p1 <= 1'b0;
    r_txf_empty_p1  <= 1'b1;
    r_rxf_rerr_p1   <= 1'b0;
    r_txf_werr_p1   <= 1'b0;
  end else begin
    r_rxf_dvalid_p1 <= REG_RXF_DVALID;
    r_txf_empty_p1  <= REG_TXF_EMPTY;
    r_rxf_rerr_p1   <= w_rxf_rerr;
    r_txf_werr_p1   <= w_txf_werr;
  end
end

assign INTERRUPT = r_intena_sts &
                   ((REG_RXF_DVALID & ~r_rxf_dvalid_p1)|
                    (REG_TXF_EMPTY  & ~r_txf_empty_p1)|
                    (w_rxf_rerr     & ~r_rxf_rerr_p1)|
                    (w_txf_werr     & ~r_txf_werr_p1));

// AHB Read Data
//----------------------------------------------
assign REG_RDATA = w_rd_rxfifor |
                   w_rd_statr |
                   w_rd_ubrsr |
                   w_rd_ahbuver ;

endmodule
