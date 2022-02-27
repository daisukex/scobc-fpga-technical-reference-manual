//-----------------------------------------------
// Module: sc_can_reg
//  Space Cubics CAN Controller Register
//-----------------------------------------------
// Copyright © 2021 Space Cubics, LLC.
//-----------------------------------------------
`include "sc_can_version.vh"
`include "sc_can_reg_map.vh"

module sc_can_reg (
  // System Interface
  input SYSCLK,
  input SYSRST_N,

  // AXI Slave Interface
  input REG_WEN,
  input [31:0] REG_WADDR,
  input [3:0] REG_WBTEN,
  input [31:0] REG_WDATA,
  input REG_REN,
  input [31:0] REG_RADDR,
  output [31:0] REG_RDATA,
  output REG_RWAIT,

  // CAN Core Enable Signal
  output reg REG_CAN_EN,

  // Bit Timing Generator Interface
  output reg [15:0] REG_TQPDIV,
  output reg [3:0] REG_TS1,
  output reg [2:0] REG_TS2,
  output reg [1:0] REG_SJW,

  // Bit Stream Processor Interface
  output reg [3:0] REG_ACF_EN,
  output reg [31:0] REG_ACF1_ID_MASK,
  output reg [31:0] REG_ACF1_ID_VAL,
  output reg [31:0] REG_ACF2_ID_MASK,
  output reg [31:0] REG_ACF2_ID_VAL,
  output reg [31:0] REG_ACF3_ID_MASK,
  output reg [31:0] REG_ACF3_ID_VAL,
  output reg [31:0] REG_ACF4_ID_MASK,
  output reg [31:0] REG_ACF4_ID_VAL,
  output reg REG_SELF_TMODE,
  input [7:0] REG_TX_ECNT,
  input [7:0] REG_RX_ECNT,
  input REG_BUS_BUSY,
  input REG_ERRWRN,
  input [1:0] REG_ERR_STS,
  input REG_TXF_NEMPTY,
  input REG_TXF_FULL,
  input REG_RXF_FULL,
  input REG_INT_TRNSDN,
  input REG_INT_ARBLST,
  input REG_INT_RCVDN,
  input REG_INT_RXFVAL,
  input REG_INT_CRCER,
  input REG_INT_FMER,
  input REG_INT_STFER,
  input REG_INT_BITER,
  input REG_INT_ACKER,
  input REG_INT_BUSOFF,

  // TX Message FIFO Interface
  output REG_TXF1_WEN,
  output reg [31:0] REG_TXF1_WDATA,
  output REG_TXF2_WEN,
  output reg [3:0] REG_TXF2_WDATA,
  output REG_TXF3_WEN,
  output reg [31:0] REG_TXF3_WDATA,
  output REG_TXF4_WEN,
  output reg [31:0] REG_TXF4_WDATA,
  output reg REG_TXF_RST,
  input REG_INT_TXFOVF,

  // TX High Priority Message Buffer Interface
  output reg REG_TXHPB1_WEN,
  output reg [31:0] REG_TXHPB1_WDATA,
  output reg REG_TXHPB2_WEN,
  output reg [3:0] REG_TXHPB2_WDATA,
  output reg REG_TXHPB3_WEN,
  output reg [31:0] REG_TXHPB3_WDATA,
  output reg REG_TXHPB4_WEN,
  output reg [31:0] REG_TXHPB4_WDATA,
  output reg REG_TXHPB_RST,
  input REG_TXHPB_FULL,
  input REG_INT_TXHBOVF,

  // RX Message FIFO Interface
  output REG_RXF1_REN,
  input [31:0] REG_RXF1_RDATA,
  output REG_RXF2_REN,
  input [3:0] REG_RXF2_RDATA,
  output REG_RXF3_REN,
  input [31:0] REG_RXF3_RDATA,
  output REG_RXF4_REN,
  input [31:0] REG_RXF4_RDATA,
  output reg REG_RXF_RST,
  input REG_INT_RXFOVF,
  input REG_INT_RXFUDF,

  // CAN Transceiver Interface
  output reg REG_PHY_SLEEP_EN,

  // Interrupt Signal
  output CAN_INT
);

integer i;

// Address Decoder
wire w_wr_hit_can_enr;
wire w_wr_hit_can_tqpr;
wire w_wr_hit_can_btsr;
wire w_wr_hit_can_isr;
wire w_wr_hit_can_ier;
wire w_wr_hit_can_tmr1;
wire w_wr_hit_can_tmr2;
wire w_wr_hit_can_tmr3;
wire w_wr_hit_can_tmr4;
wire w_wr_hit_can_thpmr1;
wire w_wr_hit_can_thpmr2;
wire w_wr_hit_can_thpmr3;
wire w_wr_hit_can_thpmr4;
wire w_wr_hit_can_afer;
wire w_wr_hit_can_afimr1;
wire w_wr_hit_can_afivr1;
wire w_wr_hit_can_afimr2;
wire w_wr_hit_can_afivr2;
wire w_wr_hit_can_afimr3;
wire w_wr_hit_can_afivr3;
wire w_wr_hit_can_afimr4;
wire w_wr_hit_can_afivr4;
wire w_wr_hit_can_fiforr;
wire w_wr_hit_can_stmcr;
wire w_wr_hit_can_pslmcr;

wire w_rd_hit_can_enr;
wire w_rd_hit_can_tqpr;
wire w_rd_hit_can_btsr;
wire w_rd_hit_can_ecntr;
wire w_rd_hit_can_stsr;
wire w_rd_hit_can_isr;
wire w_rd_hit_can_ier;
wire w_rd_hit_can_rmr1;
wire w_rd_hit_can_rmr2;
wire w_rd_hit_can_rmr3;
wire w_rd_hit_can_rmr4;
wire w_rd_hit_can_afer;
wire w_rd_hit_can_afimr1;
wire w_rd_hit_can_afivr1;
wire w_rd_hit_can_afimr2;
wire w_rd_hit_can_afivr2;
wire w_rd_hit_can_afimr3;
wire w_rd_hit_can_afivr3;
wire w_rd_hit_can_afimr4;
wire w_rd_hit_can_afivr4;
wire w_rd_hit_can_stmcr;
wire w_rd_hit_can_pslmcr;
wire w_rd_hit_can_ver;

assign w_wr_hit_can_enr = {REG_WADDR[15:2], 2'b00} == `CAN_ENR;
assign w_wr_hit_can_tqpr = {REG_WADDR[15:2], 2'b00} == `CAN_TQPR;
assign w_wr_hit_can_btsr = {REG_WADDR[15:2], 2'b00} == `CAN_BTSR;
assign w_wr_hit_can_isr = {REG_WADDR[15:2], 2'b00} == `CAN_ISR;
assign w_wr_hit_can_ier = {REG_WADDR[15:2], 2'b00} == `CAN_IER;
assign w_wr_hit_can_tmr1 = {REG_WADDR[15:2], 2'b00} == `CAN_TMR1;
assign w_wr_hit_can_tmr2 = {REG_WADDR[15:2], 2'b00} == `CAN_TMR2;
assign w_wr_hit_can_tmr3 = {REG_WADDR[15:2], 2'b00} == `CAN_TMR3;
assign w_wr_hit_can_tmr4 = {REG_WADDR[15:2], 2'b00} == `CAN_TMR4;
assign w_wr_hit_can_thpmr1 = {REG_WADDR[15:2], 2'b00} == `CAN_THPMR1;
assign w_wr_hit_can_thpmr2 = {REG_WADDR[15:2], 2'b00} == `CAN_THPMR2;
assign w_wr_hit_can_thpmr3 = {REG_WADDR[15:2], 2'b00} == `CAN_THPMR3;
assign w_wr_hit_can_thpmr4 = {REG_WADDR[15:2], 2'b00} == `CAN_THPMR4;
assign w_wr_hit_can_afer = {REG_WADDR[15:2], 2'b00} == `CAN_AFER;
assign w_wr_hit_can_afimr1 = {REG_WADDR[15:2], 2'b00} == `CAN_AFIMR1;
assign w_wr_hit_can_afivr1 = {REG_WADDR[15:2], 2'b00} == `CAN_AFIVR1;
assign w_wr_hit_can_afimr2 = {REG_WADDR[15:2], 2'b00} == `CAN_AFIMR2;
assign w_wr_hit_can_afivr2 = {REG_WADDR[15:2], 2'b00} == `CAN_AFIVR2;
assign w_wr_hit_can_afimr3 = {REG_WADDR[15:2], 2'b00} == `CAN_AFIMR3;
assign w_wr_hit_can_afivr3 = {REG_WADDR[15:2], 2'b00} == `CAN_AFIVR3;
assign w_wr_hit_can_afimr4 = {REG_WADDR[15:2], 2'b00} == `CAN_AFIMR4;
assign w_wr_hit_can_afivr4 = {REG_WADDR[15:2], 2'b00} == `CAN_AFIVR4;
assign w_wr_hit_can_fiforr = {REG_WADDR[15:2], 2'b00} == `CAN_FIFORR;
assign w_wr_hit_can_stmcr = {REG_WADDR[15:2], 2'b00} == `CAN_STMCR;
assign w_wr_hit_can_pslmcr = {REG_WADDR[15:2], 2'b00} == `CAN_PSLMCR;

assign w_rd_hit_can_enr = {REG_RADDR[15:2], 2'b00} == `CAN_ENR;
assign w_rd_hit_can_tqpr = {REG_RADDR[15:2], 2'b00} == `CAN_TQPR;
assign w_rd_hit_can_btsr = {REG_RADDR[15:2], 2'b00} == `CAN_BTSR;
assign w_rd_hit_can_ecntr = {REG_RADDR[15:2], 2'b00} == `CAN_ECNTR;
assign w_rd_hit_can_stsr = {REG_RADDR[15:2], 2'b00} == `CAN_STSR;
assign w_rd_hit_can_isr = {REG_RADDR[15:2], 2'b00} == `CAN_ISR;
assign w_rd_hit_can_ier = {REG_RADDR[15:2], 2'b00} == `CAN_IER;
assign w_rd_hit_can_rmr1 = {REG_RADDR[15:2], 2'b00} == `CAN_RMR1;
assign w_rd_hit_can_rmr2 = {REG_RADDR[15:2], 2'b00} == `CAN_RMR2;
assign w_rd_hit_can_rmr3 = {REG_RADDR[15:2], 2'b00} == `CAN_RMR3;
assign w_rd_hit_can_rmr4 = {REG_RADDR[15:2], 2'b00} == `CAN_RMR4;
assign w_rd_hit_can_afer = {REG_RADDR[15:2], 2'b00} == `CAN_AFER;
assign w_rd_hit_can_afimr1 = {REG_RADDR[15:2], 2'b00} == `CAN_AFIMR1;
assign w_rd_hit_can_afivr1 = {REG_RADDR[15:2], 2'b00} == `CAN_AFIVR1;
assign w_rd_hit_can_afimr2 = {REG_RADDR[15:2], 2'b00} == `CAN_AFIMR2;
assign w_rd_hit_can_afivr2 = {REG_RADDR[15:2], 2'b00} == `CAN_AFIVR2;
assign w_rd_hit_can_afimr3 = {REG_RADDR[15:2], 2'b00} == `CAN_AFIMR3;
assign w_rd_hit_can_afivr3 = {REG_RADDR[15:2], 2'b00} == `CAN_AFIVR3;
assign w_rd_hit_can_afimr4 = {REG_RADDR[15:2], 2'b00} == `CAN_AFIMR4;
assign w_rd_hit_can_afivr4 = {REG_RADDR[15:2], 2'b00} == `CAN_AFIVR4;
assign w_rd_hit_can_stmcr = {REG_RADDR[15:2], 2'b00} == `CAN_STMCR;
assign w_rd_hit_can_pslmcr = {REG_RADDR[15:2], 2'b00} == `CAN_PSLMCR;
assign w_rd_hit_can_ver = {REG_RADDR[15:2], 2'b00} == `CAN_VER;

// RX FIFO Read Wait
wire [3:0] w_rxf_ren;
reg [1:0] r_rxf_rd_en_retim [0:3];
wire w_rxf_rd_wait;
reg r_rxf_rd_wait_p1;

assign w_rxf_ren = {REG_RXF4_REN, REG_RXF3_REN, REG_RXF2_REN, REG_RXF1_REN};

always @ (posedge SYSCLK or negedge SYSRST_N) begin
  for (i=0; i<4; i=i+1) begin
    if (!SYSRST_N) begin
      r_rxf_rd_en_retim[i] <= 0;
    end else begin
      r_rxf_rd_en_retim[i] <= {r_rxf_rd_en_retim[i][0], w_rxf_ren[i]};
    end
  end
end

assign w_rxf_rd_wait = |w_rxf_ren & ~(r_rxf_rd_en_retim[3][0] | r_rxf_rd_en_retim[2][0] |
                                      r_rxf_rd_en_retim[1][0] | r_rxf_rd_en_retim[0][0]);

always @ (posedge SYSCLK or negedge SYSRST_N) begin
  if (!SYSRST_N) begin
    r_rxf_rd_wait_p1 <= 1'b0;
  end else begin
    r_rxf_rd_wait_p1 <= w_rxf_rd_wait;
  end
end

assign REG_RWAIT = w_rxf_rd_wait | r_rxf_rd_wait_p1;

// CAN Enable Register
//----------------------------------------------
always @ (posedge SYSCLK or negedge SYSRST_N) begin
  if (!SYSRST_N) begin
    REG_CAN_EN <= 0;
  end else begin
    if (w_wr_hit_can_enr & REG_WEN & REG_WBTEN[0])
      REG_CAN_EN <= REG_WDATA[`CAN_EN];
  end
end

wire [31:0] w_rd_can_enr;
assign w_rd_can_enr = (w_rd_hit_can_enr & REG_REN) ?
                      {{32-1-`CAN_EN{1'b0}}, REG_CAN_EN, {`CAN_EN{1'b0}}} :
                      32'h0;

// CAN Time Quantum Prescaler Register
//----------------------------------------------
always @ (posedge SYSCLK or negedge SYSRST_N) begin
  if (!SYSRST_N) begin
    REG_TQPDIV <= 0;
  end else begin
    if (w_wr_hit_can_tqpr & REG_WEN & ~REG_CAN_EN) begin
      if (REG_WBTEN[1])
        REG_TQPDIV[15:8] <= REG_WDATA[`CAN_TQPSET+8 +: 8];
      if (REG_WBTEN[0])
        REG_TQPDIV[7:0]  <= REG_WDATA[`CAN_TQPSET   +: 8];
    end
  end
end

wire [31:0] w_rd_can_tqpr;
assign w_rd_can_tqpr = (w_rd_hit_can_tqpr & REG_REN) ?
                       {{32-16-`CAN_TQPSET{1'b0}}, REG_TQPDIV, {`CAN_TQPSET{1'b0}}} :
                       32'h0;

// CAN Bit Timing Setting Register
//----------------------------------------------
always @ (posedge SYSCLK or negedge SYSRST_N) begin
  if (!SYSRST_N) begin
    REG_TS1 <= 0;
    REG_TS2 <= 0;
    REG_SJW <= 0;
  end else begin
    if (w_wr_hit_can_btsr & REG_WEN & ~REG_CAN_EN) begin
      if (REG_WBTEN[1])
        REG_SJW[1] <= REG_WDATA[`CAN_SJW+1];
      if (REG_WBTEN[0]) begin
        REG_SJW[0] <= REG_WDATA[`CAN_SJW];
        REG_TS2    <= REG_WDATA[`CAN_TS2 +: 3];
        REG_TS1    <= REG_WDATA[`CAN_TS1 +: 4];
      end
    end
  end
end

wire [31:0] w_rd_can_btsr;
assign w_rd_can_btsr = (w_rd_hit_can_btsr & REG_REN) ?
                       {{32-2-`CAN_SJW{1'b0}}, REG_SJW, {`CAN_SJW{1'b0}}} |
                       {{32-3-`CAN_TS2{1'b0}}, REG_TS2, {`CAN_TS2{1'b0}}} |
                       {{32-4-`CAN_TS1{1'b0}}, REG_TS1, {`CAN_TS1{1'b0}}} :
                       32'h0;

// CAN Error Count Register
//----------------------------------------------
wire [31:0] w_rd_can_ecntr;
assign w_rd_can_ecntr = (w_rd_hit_can_ecntr & REG_REN) ?
                        {{32-8-`CAN_RXECNT{1'b0}}, REG_RX_ECNT, {`CAN_RXECNT{1'b0}}} |
                        {{32-8-`CAN_TXECNT{1'b0}}, REG_TX_ECNT, {`CAN_TXECNT{1'b0}}} :
                        32'h0;

// CAN Status Register
//----------------------------------------------
wire [31:0] w_rd_can_stsr;
assign w_rd_can_stsr = (w_rd_hit_can_stsr & REG_REN) ?
                       {{32-1-`CAN_RXFFL{1'b0}},  REG_RXF_FULL,   {`CAN_RXFFL{1'b0}}}  |
                       {{32-1-`CAN_TXFFL{1'b0}},  REG_TXF_FULL,   {`CAN_TXFFL{1'b0}}}  |
                       {{32-1-`CAN_TXHBFL{1'b0}}, REG_TXHPB_FULL, {`CAN_TXHBFL{1'b0}}} |
                       {{32-1-`CAN_TXFNEP{1'b0}}, REG_TXF_NEMPTY, {`CAN_TXFNEP{1'b0}}} |
                       {{32-2-`CAN_ESTS{1'b0}},   REG_ERR_STS,    {`CAN_ESTS{1'b0}}}   |
                       {{32-1-`CAN_EWRN{1'b0}},   REG_ERRWRN,     {`CAN_EWRN{1'b0}}}   |
                       {{32-1-`CAN_BBUSY{1'b0}},  REG_BUS_BUSY,   {`CAN_BBUSY{1'b0}}}  :
                       32'h0;

// CAN Interrput Status Register
//----------------------------------------------
reg r_int_busoff;
reg r_int_acker;
reg r_int_biter;
reg r_int_stfer;
reg r_int_fmer;
reg r_int_crcer;
reg r_int_rxfovf;
reg r_int_rxfudf;
reg r_int_rxfval;
reg r_int_rcvdn;
reg r_int_txfovf;
reg r_int_txhbovf;
reg r_int_arblst;
reg r_int_trnsdn;
always @ (posedge SYSCLK or negedge SYSRST_N) begin
  if (!SYSRST_N) begin
    r_int_busoff  <= 0;
    r_int_acker   <= 0;
    r_int_biter   <= 0;
    r_int_stfer   <= 0;
    r_int_fmer    <= 0;
    r_int_crcer   <= 0;
    r_int_rxfovf  <= 0;
    r_int_rxfudf  <= 0;
    r_int_rxfval  <= 0;
    r_int_rcvdn   <= 0;
    r_int_txfovf  <= 0;
    r_int_txhbovf <= 0;
    r_int_arblst  <= 0;
    r_int_trnsdn  <= 0;
  end else begin
    if (w_wr_hit_can_isr & REG_WEN) begin
      if (REG_WBTEN[1]) begin
        if (REG_WDATA[`CAN_BUSOFF])
          r_int_busoff <= 1'b0;
        if (REG_WDATA[`CAN_ACKER])
          r_int_acker  <= 1'b0;
        if (REG_WDATA[`CAN_BITER])
          r_int_biter  <= 1'b0;
        if (REG_WDATA[`CAN_STFER])
          r_int_stfer  <= 1'b0;
        if (REG_WDATA[`CAN_FMER])
          r_int_fmer   <= 1'b0;
        if (REG_WDATA[`CAN_CRCER])
          r_int_crcer  <= 1'b0;
      end
      if (REG_WBTEN[0]) begin
        if (REG_WDATA[`CAN_RXFOVF])
          r_int_rxfovf  <= 1'b0;
        if (REG_WDATA[`CAN_RXFUDF])
          r_int_rxfudf  <= 1'b0;
        if (REG_WDATA[`CAN_RXFVAL])
          r_int_rxfval  <= 1'b0;
        if (REG_WDATA[`CAN_RCVDN])
          r_int_rcvdn   <= 1'b0;
        if (REG_WDATA[`CAN_TXFOVF])
          r_int_txfovf  <= 1'b0;
        if (REG_WDATA[`CAN_TXHBOVF])
          r_int_txhbovf <= 1'b0;
        if (REG_WDATA[`CAN_ARBLST])
          r_int_arblst  <= 1'b0;
        if (REG_WDATA[`CAN_TRNSDN])
          r_int_trnsdn  <= 1'b0;
      end
    end
    if (REG_INT_BUSOFF)
      r_int_busoff  <= 1'b1;
    if (REG_INT_ACKER)
      r_int_acker   <= 1'b1;
    if (REG_INT_BITER)
      r_int_biter   <= 1'b1;
    if (REG_INT_STFER)
      r_int_stfer   <= 1'b1;
    if (REG_INT_FMER)
      r_int_fmer    <= 1'b1;
    if (REG_INT_CRCER)
      r_int_crcer   <= 1'b1;
    if (REG_INT_RXFOVF)
      r_int_rxfovf  <= 1'b1;
    if (REG_INT_RXFUDF)
      r_int_rxfudf  <= 1'b1;
    if (REG_INT_RXFVAL)
      r_int_rxfval  <= 1'b1;
    if (REG_INT_RCVDN)
      r_int_rcvdn   <= 1'b1;
    if (REG_INT_TXFOVF)
      r_int_txfovf  <= 1'b1;
    if (REG_INT_TXHBOVF)
      r_int_txhbovf <= 1'b1;
    if (REG_INT_ARBLST)
      r_int_arblst  <= 1'b1;
    if (REG_INT_TRNSDN)
      r_int_trnsdn  <= 1'b1;
  end
end

wire [31:0] w_rd_can_isr;
assign w_rd_can_isr = (w_rd_hit_can_isr & REG_REN) ?
                      {{32-1-`CAN_BUSOFF{1'b0}},  r_int_busoff,  {`CAN_BUSOFF{1'b0}}}  |
                      {{32-1-`CAN_ACKER{1'b0}},   r_int_acker,   {`CAN_ACKER{1'b0}}}   |
                      {{32-1-`CAN_BITER{1'b0}},   r_int_biter,   {`CAN_BITER{1'b0}}}   |
                      {{32-1-`CAN_STFER{1'b0}},   r_int_stfer,   {`CAN_STFER{1'b0}}}   |
                      {{32-1-`CAN_FMER{1'b0}},    r_int_fmer,    {`CAN_FMER{1'b0}}}    |
                      {{32-1-`CAN_CRCER{1'b0}},   r_int_crcer,   {`CAN_CRCER{1'b0}}}   |
                      {{32-1-`CAN_RXFOVF{1'b0}},  r_int_rxfovf,  {`CAN_RXFOVF{1'b0}}}  |
                      {{32-1-`CAN_RXFUDF{1'b0}},  r_int_rxfudf,  {`CAN_RXFUDF{1'b0}}}  |
                      {{32-1-`CAN_RXFVAL{1'b0}},  r_int_rxfval,  {`CAN_RXFVAL{1'b0}}}  |
                      {{32-1-`CAN_RCVDN{1'b0}},   r_int_rcvdn,   {`CAN_RCVDN{1'b0}}}   |
                      {{32-1-`CAN_TXFOVF{1'b0}},  r_int_txfovf,  {`CAN_TXFOVF{1'b0}}}  |
                      {{32-1-`CAN_TXHBOVF{1'b0}}, r_int_txhbovf, {`CAN_TXHBOVF{1'b0}}} |
                      {{32-1-`CAN_ARBLST{1'b0}},  r_int_arblst,  {`CAN_ARBLST{1'b0}}}  |
                      {{32-1-`CAN_TRNSDN{1'b0}},  r_int_trnsdn,  {`CAN_TRNSDN{1'b0}}}  :
                      32'h0;

// CAN Interrupt Enable Register
//----------------------------------------------
reg r_enb_busoff;
reg r_enb_acker;
reg r_enb_biter;
reg r_enb_stfer;
reg r_enb_fmer;
reg r_enb_crcer;
reg r_enb_rxfovf;
reg r_enb_rxfudf;
reg r_enb_rxfval;
reg r_enb_rcvdn;
reg r_enb_txfovf;
reg r_enb_txhbovf;
reg r_enb_arblst;
reg r_enb_trnsdn;
always @ (posedge SYSCLK or negedge SYSRST_N) begin
  if (!SYSRST_N) begin
    r_enb_busoff  <= 0;
    r_enb_acker   <= 0;
    r_enb_biter   <= 0;
    r_enb_stfer   <= 0;
    r_enb_fmer    <= 0;
    r_enb_crcer   <= 0;
    r_enb_rxfovf  <= 0;
    r_enb_rxfudf  <= 0;
    r_enb_rxfval  <= 0;
    r_enb_rcvdn   <= 0;
    r_enb_txfovf  <= 0;
    r_enb_txhbovf <= 0;
    r_enb_arblst  <= 0;
    r_enb_trnsdn  <= 0;
  end else begin
    if (w_wr_hit_can_ier & REG_WEN) begin
      if (REG_WBTEN[1]) begin
        r_enb_busoff  <= REG_WDATA[`CAN_BUSOFFENB];
        r_enb_acker   <= REG_WDATA[`CAN_ACKERENB];
        r_enb_biter   <= REG_WDATA[`CAN_BITERENB];
        r_enb_stfer   <= REG_WDATA[`CAN_STFERENB];
        r_enb_fmer    <= REG_WDATA[`CAN_FMERENB];
        r_enb_crcer   <= REG_WDATA[`CAN_CRCERENB];
      end
      if (REG_WBTEN[0]) begin
        r_enb_rxfovf  <= REG_WDATA[`CAN_RXFOVFENB];
        r_enb_rxfudf  <= REG_WDATA[`CAN_RXFUDFENB];
        r_enb_rxfval  <= REG_WDATA[`CAN_RXFVALENB];
        r_enb_rcvdn   <= REG_WDATA[`CAN_RCVDNENB];
        r_enb_txfovf  <= REG_WDATA[`CAN_TXFOVFENB];
        r_enb_txhbovf <= REG_WDATA[`CAN_TXHBOVFENB];
        r_enb_arblst  <= REG_WDATA[`CAN_ARBLSTENB];
        r_enb_trnsdn  <= REG_WDATA[`CAN_TRNSDNENB];
      end
    end
  end
end

wire [31:0] w_rd_can_ier;
assign w_rd_can_ier = (w_rd_hit_can_ier & REG_REN) ?
                      {{32-1-`CAN_BUSOFFENB{1'b0}},  r_enb_busoff,  {`CAN_BUSOFFENB{1'b0}}}  |
                      {{32-1-`CAN_ACKERENB{1'b0}},   r_enb_acker,   {`CAN_ACKERENB{1'b0}}}   |
                      {{32-1-`CAN_BITERENB{1'b0}},   r_enb_biter,   {`CAN_BITERENB{1'b0}}}   |
                      {{32-1-`CAN_STFERENB{1'b0}},   r_enb_stfer,   {`CAN_STFERENB{1'b0}}}   |
                      {{32-1-`CAN_FMERENB{1'b0}},    r_enb_fmer,    {`CAN_FMERENB{1'b0}}}    |
                      {{32-1-`CAN_CRCERENB{1'b0}},   r_enb_crcer,   {`CAN_CRCERENB{1'b0}}}   |
                      {{32-1-`CAN_RXFOVFENB{1'b0}},  r_enb_rxfovf,  {`CAN_RXFOVFENB{1'b0}}}  |
                      {{32-1-`CAN_RXFUDFENB{1'b0}},  r_enb_rxfudf,  {`CAN_RXFUDFENB{1'b0}}}  |
                      {{32-1-`CAN_RXFVALENB{1'b0}},  r_enb_rxfval,  {`CAN_RXFVALENB{1'b0}}}  |
                      {{32-1-`CAN_RCVDNENB{1'b0}},   r_enb_rcvdn,   {`CAN_RCVDNENB{1'b0}}}   |
                      {{32-1-`CAN_TXFOVFENB{1'b0}},  r_enb_txfovf,  {`CAN_TXFOVFENB{1'b0}}}  |
                      {{32-1-`CAN_TXHBOVFENB{1'b0}}, r_enb_txhbovf, {`CAN_TXHBOVFENB{1'b0}}} |
                      {{32-1-`CAN_ARBLSTENB{1'b0}},  r_enb_arblst,  {`CAN_ARBLSTENB{1'b0}}}  |
                      {{32-1-`CAN_TRNSDNENB{1'b0}},  r_enb_trnsdn,  {`CAN_TRNSDNENB{1'b0}}}  :
                      32'h0;

assign CAN_INT = (r_int_busoff  & r_enb_busoff ) |
                 (r_int_acker   & r_enb_acker  ) |
                 (r_int_biter   & r_enb_biter  ) |
                 (r_int_stfer   & r_enb_stfer  ) |
                 (r_int_fmer    & r_enb_fmer   ) |
                 (r_int_crcer   & r_enb_crcer  ) |
                 (r_int_rxfovf  & r_enb_rxfovf ) |
                 (r_int_rxfudf  & r_enb_rxfudf ) |
                 (r_int_rxfval  & r_enb_rxfval ) |
                 (r_int_rcvdn   & r_enb_rcvdn  ) |
                 (r_int_txfovf  & r_enb_txfovf ) |
                 (r_int_txhbovf & r_enb_txhbovf) |
                 (r_int_arblst  & r_enb_arblst ) |
                 (r_int_trnsdn  & r_enb_trnsdn ) ;

// CAN TX Message Register1
//----------------------------------------------
assign REG_TXF1_WEN = w_wr_hit_can_tmr1 & REG_WEN & |REG_WBTEN;
always @ (*) begin
  if (w_wr_hit_can_tmr1 & REG_WEN) begin
    REG_TXF1_WDATA = 0;
    if (REG_WBTEN[3]) begin
      REG_TXF1_WDATA[31:24] = REG_WDATA[`CAN_TXID1+3 +: 8];
    end
    if (REG_WBTEN[2]) begin
      REG_TXF1_WDATA[23:21] = REG_WDATA[`CAN_TXID1 +: 3];
      REG_TXF1_WDATA[20]    = REG_WDATA[`CAN_TXSRTR];
      REG_TXF1_WDATA[19]    = REG_WDATA[`CAN_TXIDE];
      REG_TXF1_WDATA[18:16] = REG_WDATA[`CAN_TXID2+15 +: 3];
    end
    if (REG_WBTEN[1]) begin
      REG_TXF1_WDATA[15:8]  = REG_WDATA[`CAN_TXID2+7 +: 8];
    end
    if (REG_WBTEN[0]) begin
      REG_TXF1_WDATA[7:1]   = REG_WDATA[`CAN_TXID2 +: 7];
      REG_TXF1_WDATA[0]     = REG_WDATA[`CAN_TXERTR];
    end
  end else begin
    REG_TXF1_WDATA = 0;
  end
end

// CAN TX Message Register2
//----------------------------------------------
assign REG_TXF2_WEN = w_wr_hit_can_tmr2 & REG_WEN & |REG_WBTEN;
always @ (*) begin
  if (w_wr_hit_can_tmr2 & REG_WEN) begin
    REG_TXF2_WDATA = 0;
    if (REG_WBTEN[0])
      REG_TXF2_WDATA = REG_WDATA[`CAN_TXDLC +: 4];
  end else begin
    REG_TXF2_WDATA = 0;
  end
end

// CAN TX Message Register3
//----------------------------------------------
assign REG_TXF3_WEN = w_wr_hit_can_tmr3 & REG_WEN & |REG_WBTEN;
always @ (*) begin
  if (w_wr_hit_can_tmr3 & REG_WEN) begin
    REG_TXF3_WDATA = 0;
    if (REG_WBTEN[3])
      REG_TXF3_WDATA[31:24] = REG_WDATA[`CAN_TXDB0 +: 8];
    if (REG_WBTEN[2])
      REG_TXF3_WDATA[23:16] = REG_WDATA[`CAN_TXDB1 +: 8];
    if (REG_WBTEN[1])
      REG_TXF3_WDATA[15:8]  = REG_WDATA[`CAN_TXDB2 +: 8];
    if (REG_WBTEN[0])
      REG_TXF3_WDATA[7:0]   = REG_WDATA[`CAN_TXDB3 +: 8];
  end else begin
    REG_TXF3_WDATA = 0;
  end
end

// CAN TX Message Register4
//----------------------------------------------
assign REG_TXF4_WEN = w_wr_hit_can_tmr4 & REG_WEN & |REG_WBTEN;
always @ (*) begin
  if (w_wr_hit_can_tmr4 & REG_WEN) begin
    REG_TXF4_WDATA = 0;
    if (REG_WBTEN[3])
      REG_TXF4_WDATA[31:24] = REG_WDATA[`CAN_TXDB4 +: 8];
    if (REG_WBTEN[2])
      REG_TXF4_WDATA[23:16] = REG_WDATA[`CAN_TXDB5 +: 8];
    if (REG_WBTEN[1])
      REG_TXF4_WDATA[15:8]  = REG_WDATA[`CAN_TXDB6 +: 8];
    if (REG_WBTEN[0])
      REG_TXF4_WDATA[7:0]   = REG_WDATA[`CAN_TXDB7 +: 8];
  end else begin
    REG_TXF4_WDATA = 0;
  end
end

// CAN TX High Priority Message Register1
//----------------------------------------------
always @ (posedge SYSCLK or negedge SYSRST_N) begin
  if (!SYSRST_N) begin
    REG_TXHPB1_WEN   <= 0;
    REG_TXHPB1_WDATA <= 0;
  end else begin
    REG_TXHPB1_WEN <= 0;
    if (w_wr_hit_can_thpmr1 & REG_WEN) begin
      REG_TXHPB1_WEN <= |REG_WBTEN;
      if (REG_WBTEN[3]) begin
        REG_TXHPB1_WDATA[31:24] <= REG_WDATA[`CAN_TXHPID1+3 +: 8];
      end
      if (REG_WBTEN[2]) begin
        REG_TXHPB1_WDATA[23:21] <= REG_WDATA[`CAN_TXHPID1 +: 3];
        REG_TXHPB1_WDATA[20]    <= REG_WDATA[`CAN_TXHPSRTR];
        REG_TXHPB1_WDATA[19]    <= REG_WDATA[`CAN_TXHPIDE];
        REG_TXHPB1_WDATA[18:16] <= REG_WDATA[`CAN_TXHPID2+15 +: 3];
      end
      if (REG_WBTEN[1]) begin
        REG_TXHPB1_WDATA[15:8]  <= REG_WDATA[`CAN_TXHPID2+7 +: 8];
      end
      if (REG_WBTEN[0]) begin
        REG_TXHPB1_WDATA[7:1]   <= REG_WDATA[`CAN_TXHPID2 +: 7];
        REG_TXHPB1_WDATA[0]     <= REG_WDATA[`CAN_TXHPERTR];
      end
    end
  end
end

// CAN TX High Priority Message Register2
//----------------------------------------------
always @ (posedge SYSCLK or negedge SYSRST_N) begin
  if (!SYSRST_N) begin
    REG_TXHPB2_WEN   <= 0;
    REG_TXHPB2_WDATA <= 0;
  end else begin
    REG_TXHPB2_WEN <= 0;
    if (w_wr_hit_can_thpmr2 & REG_WEN) begin
      REG_TXHPB2_WEN <= |REG_WBTEN;
      if (REG_WBTEN[0])
        REG_TXHPB2_WDATA <= REG_WDATA[`CAN_TXHPDLC +: 4];
    end
  end
end

// CAN TX High Priority Message Register3
//----------------------------------------------
always @ (posedge SYSCLK or negedge SYSRST_N) begin
  if (!SYSRST_N) begin
    REG_TXHPB3_WEN   <= 0;
    REG_TXHPB3_WDATA <= 0;
  end else begin
    REG_TXHPB3_WEN <= 0;
    if (w_wr_hit_can_thpmr3 & REG_WEN) begin
      REG_TXHPB3_WEN <= |REG_WBTEN;
      if (REG_WBTEN[3])
        REG_TXHPB3_WDATA[31:24] <= REG_WDATA[`CAN_TXHPDB0 +: 8];
      if (REG_WBTEN[2])
        REG_TXHPB3_WDATA[23:16] <= REG_WDATA[`CAN_TXHPDB1 +: 8];
      if (REG_WBTEN[1])
        REG_TXHPB3_WDATA[15:8]  <= REG_WDATA[`CAN_TXHPDB2 +: 8];
      if (REG_WBTEN[0])
        REG_TXHPB3_WDATA[7:0]   <= REG_WDATA[`CAN_TXHPDB3 +: 8];
    end
  end
end

// CAN TX High Priority Message Register4
//----------------------------------------------
always @ (posedge SYSCLK or negedge SYSRST_N) begin
  if (!SYSRST_N) begin
    REG_TXHPB4_WEN   <= 0;
    REG_TXHPB4_WDATA <= 0;
  end else begin
    REG_TXHPB4_WEN <= 0;
    if (w_wr_hit_can_thpmr4 & REG_WEN) begin
      REG_TXHPB4_WEN <= |REG_WBTEN;
      if (REG_WBTEN[3])
        REG_TXHPB4_WDATA[31:24] <= REG_WDATA[`CAN_TXHPDB4 +: 8];
      if (REG_WBTEN[2])
        REG_TXHPB4_WDATA[23:16] <= REG_WDATA[`CAN_TXHPDB5 +: 8];
      if (REG_WBTEN[1])
        REG_TXHPB4_WDATA[15:8]  <= REG_WDATA[`CAN_TXHPDB6 +: 8];
      if (REG_WBTEN[0])
        REG_TXHPB4_WDATA[7:0]   <= REG_WDATA[`CAN_TXHPDB7 +: 8];
    end
  end
end

// CAN RX Message Register1
//----------------------------------------------
assign REG_RXF1_REN = w_rd_hit_can_rmr1 & REG_REN;

wire [31:0] w_rd_can_rmr1;
assign w_rd_can_rmr1 = (r_rxf_rd_en_retim[0][1]) ?
                       {{32-11-`CAN_RXID1{1'b0}}, REG_RXF1_RDATA[31:21], {`CAN_RXID1{1'b0}}}  |
                       {{32-1-`CAN_RXSRTR{1'b0}}, REG_RXF1_RDATA[20],    {`CAN_RXSRTR{1'b0}}} |
                       {{32-1-`CAN_RXIDE{1'b0}},  REG_RXF1_RDATA[19],    {`CAN_RXIDE{1'b0}}}  |
                       {{32-18-`CAN_RXID2{1'b0}}, REG_RXF1_RDATA[18:1],  {`CAN_RXID2{1'b0}}}  |
                       {{32-1-`CAN_RXERTR{1'b0}}, REG_RXF1_RDATA[0],     {`CAN_RXERTR{1'b0}}} :
                       32'h0;

// CAN RX Message Register2
//----------------------------------------------
assign REG_RXF2_REN = w_rd_hit_can_rmr2 & REG_REN;

wire [31:0] w_rd_can_rmr2;
assign w_rd_can_rmr2 = (r_rxf_rd_en_retim[1][1]) ?
                       {{32-4-`CAN_RXDLC{1'b0}}, REG_RXF2_RDATA, {`CAN_RXDLC{1'b0}}} :
                       32'h0;

// CAN RX Message Register3
//----------------------------------------------
assign REG_RXF3_REN = w_rd_hit_can_rmr3 & REG_REN;

wire [31:0] w_rd_can_rmr3;
assign w_rd_can_rmr3 = (r_rxf_rd_en_retim[2][1]) ?
                       {{32-8-`CAN_RXDB0{1'b0}}, REG_RXF3_RDATA[31:24], {`CAN_RXDB0{1'b0}}} |
                       {{32-8-`CAN_RXDB1{1'b0}}, REG_RXF3_RDATA[23:16], {`CAN_RXDB1{1'b0}}} |
                       {{32-8-`CAN_RXDB2{1'b0}}, REG_RXF3_RDATA[15:8],  {`CAN_RXDB2{1'b0}}} |
                       {{32-8-`CAN_RXDB3{1'b0}}, REG_RXF3_RDATA[7:0],   {`CAN_RXDB3{1'b0}}} :
                       32'h0;

// CAN RX Message Register4
//----------------------------------------------
assign REG_RXF4_REN = w_rd_hit_can_rmr4 & REG_REN;

wire [31:0] w_rd_can_rmr4;
assign w_rd_can_rmr4 = (r_rxf_rd_en_retim[3][1]) ?
                       {{32-8-`CAN_RXDB4{1'b0}}, REG_RXF4_RDATA[31:24], {`CAN_RXDB4{1'b0}}} |
                       {{32-8-`CAN_RXDB5{1'b0}}, REG_RXF4_RDATA[23:16], {`CAN_RXDB5{1'b0}}} |
                       {{32-8-`CAN_RXDB6{1'b0}}, REG_RXF4_RDATA[15:8],  {`CAN_RXDB6{1'b0}}} |
                       {{32-8-`CAN_RXDB7{1'b0}}, REG_RXF4_RDATA[7:0],   {`CAN_RXDB7{1'b0}}} :
                       32'h0;

// CAN Acceptance Filter Enable Register
//----------------------------------------------
always @ (posedge SYSCLK or negedge SYSRST_N) begin
  if (!SYSRST_N) begin
    REG_ACF_EN <= 0;
  end else begin
    if (w_wr_hit_can_afer & REG_WEN & ~REG_CAN_EN & REG_WBTEN[0]) begin
      REG_ACF_EN[3] <= REG_WDATA[`CAN_UAF4];
      REG_ACF_EN[2] <= REG_WDATA[`CAN_UAF3];
      REG_ACF_EN[1] <= REG_WDATA[`CAN_UAF2];
      REG_ACF_EN[0] <= REG_WDATA[`CAN_UAF1];
    end
  end
end

wire [31:0] w_rd_can_afer;
assign w_rd_can_afer = (w_rd_hit_can_afer & REG_REN) ?
                       {{32-1-`CAN_UAF4{1'b0}}, REG_ACF_EN[3], {`CAN_UAF4{1'b0}}} |
                       {{32-1-`CAN_UAF3{1'b0}}, REG_ACF_EN[2], {`CAN_UAF3{1'b0}}} |
                       {{32-1-`CAN_UAF2{1'b0}}, REG_ACF_EN[1], {`CAN_UAF2{1'b0}}} |
                       {{32-1-`CAN_UAF1{1'b0}}, REG_ACF_EN[0], {`CAN_UAF1{1'b0}}} :
                       32'h0;

// CAN Acceptance Filter ID Mask Register1
//----------------------------------------------
always @ (posedge SYSCLK or negedge SYSRST_N) begin
  if (!SYSRST_N) begin
    REG_ACF1_ID_MASK <= 0;
  end else begin
    if (w_wr_hit_can_afimr1 & REG_WEN & ~REG_CAN_EN) begin
      if (REG_WBTEN[3]) begin
        REG_ACF1_ID_MASK[31:24] <= REG_WDATA[`CAN_ID1AFM1+3 +: 8];
      end
      if (REG_WBTEN[2]) begin
        REG_ACF1_ID_MASK[23:21] <= REG_WDATA[`CAN_ID1AFM1 +: 3];
        REG_ACF1_ID_MASK[20]    <= REG_WDATA[`CAN_SRTRAFM1];
        REG_ACF1_ID_MASK[19]    <= REG_WDATA[`CAN_IDEAFM1];
        REG_ACF1_ID_MASK[18:16] <= REG_WDATA[`CAN_ID2AFM1+15 +: 3];
      end
      if (REG_WBTEN[1]) begin
        REG_ACF1_ID_MASK[15:8]  <= REG_WDATA[`CAN_ID2AFM1+7 +: 8];
      end
      if (REG_WBTEN[0]) begin
        REG_ACF1_ID_MASK[7:1]   <= REG_WDATA[`CAN_ID2AFM1 +: 7];
        REG_ACF1_ID_MASK[0]     <= REG_WDATA[`CAN_ERTRAFM1];
      end
    end
  end
end

wire [31:0] w_rd_can_afimr1;
assign w_rd_can_afimr1 = (w_rd_hit_can_afimr1 & REG_REN) ?
                         {{32-11-`CAN_ID1AFM1{1'b0}}, REG_ACF1_ID_MASK[31:21], {`CAN_ID1AFM1{1'b0}}}  |
                         {{32-1-`CAN_SRTRAFM1{1'b0}}, REG_ACF1_ID_MASK[20],    {`CAN_SRTRAFM1{1'b0}}} |
                         {{32-1-`CAN_IDEAFM1{1'b0}},  REG_ACF1_ID_MASK[19],    {`CAN_IDEAFM1{1'b0}}}  |
                         {{32-18-`CAN_ID2AFM1{1'b0}}, REG_ACF1_ID_MASK[18:1],  {`CAN_ID2AFM1{1'b0}}}  |
                         {{32-1-`CAN_ERTRAFM1{1'b0}}, REG_ACF1_ID_MASK[0],     {`CAN_ERTRAFM1{1'b0}}} :
                         32'h0;

// CAN Acceptance Filter ID Value Register1
//----------------------------------------------
always @ (posedge SYSCLK or negedge SYSRST_N) begin
  if (!SYSRST_N) begin
    REG_ACF1_ID_VAL <= 0;
  end else begin
    if (w_wr_hit_can_afivr1 & REG_WEN & ~REG_CAN_EN) begin
      if (REG_WBTEN[3]) begin
        REG_ACF1_ID_VAL[31:24] <= REG_WDATA[`CAN_ID1AFV1+3 +: 8];
      end
      if (REG_WBTEN[2]) begin
        REG_ACF1_ID_VAL[23:21] <= REG_WDATA[`CAN_ID1AFV1 +: 3];
        REG_ACF1_ID_VAL[20]    <= REG_WDATA[`CAN_SRTRAFV1];
        REG_ACF1_ID_VAL[19]    <= REG_WDATA[`CAN_IDEAFV1];
        REG_ACF1_ID_VAL[18:16] <= REG_WDATA[`CAN_ID2AFV1+15 +: 3];
      end
      if (REG_WBTEN[1]) begin
        REG_ACF1_ID_VAL[15:8]  <= REG_WDATA[`CAN_ID2AFV1+7 +: 8];
      end
      if (REG_WBTEN[0]) begin
        REG_ACF1_ID_VAL[7:1]   <= REG_WDATA[`CAN_ID2AFV1 +: 7];
        REG_ACF1_ID_VAL[0]     <= REG_WDATA[`CAN_ERTRAFV1];
      end
    end
  end
end

wire [31:0] w_rd_can_afivr1;
assign w_rd_can_afivr1 = (w_rd_hit_can_afivr1 & REG_REN) ?
                         {{32-11-`CAN_ID1AFV1{1'b0}}, REG_ACF1_ID_VAL[31:21], {`CAN_ID1AFV1{1'b0}}}  |
                         {{32-1-`CAN_SRTRAFV1{1'b0}}, REG_ACF1_ID_VAL[20],    {`CAN_SRTRAFV1{1'b0}}} |
                         {{32-1-`CAN_IDEAFV1{1'b0}},  REG_ACF1_ID_VAL[19],    {`CAN_IDEAFV1{1'b0}}}  |
                         {{32-18-`CAN_ID2AFV1{1'b0}}, REG_ACF1_ID_VAL[18:1],  {`CAN_ID2AFV1{1'b0}}}  |
                         {{32-1-`CAN_ERTRAFV1{1'b0}}, REG_ACF1_ID_VAL[0],     {`CAN_ERTRAFV1{1'b0}}} :
                         32'h0;

// CAN Acceptance Filter ID Mask Register2
//----------------------------------------------
always @ (posedge SYSCLK or negedge SYSRST_N) begin
  if (!SYSRST_N) begin
    REG_ACF2_ID_MASK <= 0;
  end else begin
    if (w_wr_hit_can_afimr2 & REG_WEN & ~REG_CAN_EN) begin
      if (REG_WBTEN[3]) begin
        REG_ACF2_ID_MASK[31:24] <= REG_WDATA[`CAN_ID1AFM2+3 +: 8];
      end
      if (REG_WBTEN[2]) begin
        REG_ACF2_ID_MASK[23:21] <= REG_WDATA[`CAN_ID1AFM2 +: 3];
        REG_ACF2_ID_MASK[20]    <= REG_WDATA[`CAN_SRTRAFM2];
        REG_ACF2_ID_MASK[19]    <= REG_WDATA[`CAN_IDEAFM2];
        REG_ACF2_ID_MASK[18:16] <= REG_WDATA[`CAN_ID2AFM2+15 +: 3];
      end
      if (REG_WBTEN[1]) begin
        REG_ACF2_ID_MASK[15:8]  <= REG_WDATA[`CAN_ID2AFM2+7 +: 8];
      end
      if (REG_WBTEN[0]) begin
        REG_ACF2_ID_MASK[7:1]   <= REG_WDATA[`CAN_ID2AFM2 +: 7];
        REG_ACF2_ID_MASK[0]     <= REG_WDATA[`CAN_ERTRAFM2];
      end
    end
  end
end

wire [31:0] w_rd_can_afimr2;
assign w_rd_can_afimr2 = (w_rd_hit_can_afimr2 & REG_REN) ?
                         {{32-11-`CAN_ID1AFM2{1'b0}}, REG_ACF2_ID_MASK[31:21], {`CAN_ID1AFM2{1'b0}}}  |
                         {{32-1-`CAN_SRTRAFM2{1'b0}}, REG_ACF2_ID_MASK[20],    {`CAN_SRTRAFM2{1'b0}}} |
                         {{32-1-`CAN_IDEAFM2{1'b0}},  REG_ACF2_ID_MASK[19],    {`CAN_IDEAFM2{1'b0}}}  |
                         {{32-18-`CAN_ID2AFM2{1'b0}}, REG_ACF2_ID_MASK[18:1],  {`CAN_ID2AFM2{1'b0}}}  |
                         {{32-1-`CAN_ERTRAFM2{1'b0}}, REG_ACF2_ID_MASK[0],     {`CAN_ERTRAFM2{1'b0}}} :
                         32'h0;

// CAN Acceptance Filter ID Value Register2
//----------------------------------------------
always @ (posedge SYSCLK or negedge SYSRST_N) begin
  if (!SYSRST_N) begin
    REG_ACF2_ID_VAL <= 0;
  end else begin
    if (w_wr_hit_can_afivr2 & REG_WEN & ~REG_CAN_EN) begin
      if (REG_WBTEN[3]) begin
        REG_ACF2_ID_VAL[31:24] <= REG_WDATA[`CAN_ID1AFV2+3 +: 8];
      end
      if (REG_WBTEN[2]) begin
        REG_ACF2_ID_VAL[23:21] <= REG_WDATA[`CAN_ID1AFV2 +: 3];
        REG_ACF2_ID_VAL[20]    <= REG_WDATA[`CAN_SRTRAFV2];
        REG_ACF2_ID_VAL[19]    <= REG_WDATA[`CAN_IDEAFV2];
        REG_ACF2_ID_VAL[18:16] <= REG_WDATA[`CAN_ID2AFV2+15 +: 3];
      end
      if (REG_WBTEN[1]) begin
        REG_ACF2_ID_VAL[15:8]  <= REG_WDATA[`CAN_ID2AFV2+7 +: 8];
      end
      if (REG_WBTEN[0]) begin
        REG_ACF2_ID_VAL[7:1]   <= REG_WDATA[`CAN_ID2AFV2 +: 7];
        REG_ACF2_ID_VAL[0]     <= REG_WDATA[`CAN_ERTRAFV2];
      end
    end
  end
end

wire [31:0] w_rd_can_afivr2;
assign w_rd_can_afivr2 = (w_rd_hit_can_afivr2 & REG_REN) ?
                         {{32-11-`CAN_ID1AFV2{1'b0}}, REG_ACF2_ID_VAL[31:21], {`CAN_ID1AFV2{1'b0}}}  |
                         {{32-1-`CAN_SRTRAFV2{1'b0}}, REG_ACF2_ID_VAL[20],    {`CAN_SRTRAFV2{1'b0}}} |
                         {{32-1-`CAN_IDEAFV2{1'b0}},  REG_ACF2_ID_VAL[19],    {`CAN_IDEAFV2{1'b0}}}  |
                         {{32-18-`CAN_ID2AFV2{1'b0}}, REG_ACF2_ID_VAL[18:1],  {`CAN_ID2AFV2{1'b0}}}  |
                         {{32-1-`CAN_ERTRAFV2{1'b0}}, REG_ACF2_ID_VAL[0],     {`CAN_ERTRAFV2{1'b0}}} :
                         32'h0;

// CAN Acceptance Filter ID Mask Register3
//----------------------------------------------
always @ (posedge SYSCLK or negedge SYSRST_N) begin
  if (!SYSRST_N) begin
    REG_ACF3_ID_MASK <= 0;
  end else begin
    if (w_wr_hit_can_afimr3 & REG_WEN & ~REG_CAN_EN) begin
      if (REG_WBTEN[3]) begin
        REG_ACF3_ID_MASK[31:24] <= REG_WDATA[`CAN_ID1AFM3+3 +: 8];
      end
      if (REG_WBTEN[2]) begin
        REG_ACF3_ID_MASK[23:21] <= REG_WDATA[`CAN_ID1AFM3 +: 3];
        REG_ACF3_ID_MASK[20]    <= REG_WDATA[`CAN_SRTRAFM3];
        REG_ACF3_ID_MASK[19]    <= REG_WDATA[`CAN_IDEAFM3];
        REG_ACF3_ID_MASK[18:16] <= REG_WDATA[`CAN_ID2AFM3+15 +: 3];
      end
      if (REG_WBTEN[1]) begin
        REG_ACF3_ID_MASK[15:8]  <= REG_WDATA[`CAN_ID2AFM3+7 +: 8];
      end
      if (REG_WBTEN[0]) begin
        REG_ACF3_ID_MASK[7:1]   <= REG_WDATA[`CAN_ID2AFM3 +: 7];
        REG_ACF3_ID_MASK[0]     <= REG_WDATA[`CAN_ERTRAFM3];
      end
    end
  end
end

wire [31:0] w_rd_can_afimr3;
assign w_rd_can_afimr3 = (w_rd_hit_can_afimr3 & REG_REN) ?
                         {{32-11-`CAN_ID1AFM3{1'b0}}, REG_ACF3_ID_MASK[31:21], {`CAN_ID1AFM3{1'b0}}}  |
                         {{32-1-`CAN_SRTRAFM3{1'b0}}, REG_ACF3_ID_MASK[20],    {`CAN_SRTRAFM3{1'b0}}} |
                         {{32-1-`CAN_IDEAFM3{1'b0}},  REG_ACF3_ID_MASK[19],    {`CAN_IDEAFM3{1'b0}}}  |
                         {{32-18-`CAN_ID2AFM3{1'b0}}, REG_ACF3_ID_MASK[18:1],  {`CAN_ID2AFM3{1'b0}}}  |
                         {{32-1-`CAN_ERTRAFM3{1'b0}}, REG_ACF3_ID_MASK[0],     {`CAN_ERTRAFM3{1'b0}}} :
                         32'h0;

// CAN Acceptance Filter ID Value Register3
//----------------------------------------------
always @ (posedge SYSCLK or negedge SYSRST_N) begin
  if (!SYSRST_N) begin
    REG_ACF3_ID_VAL <= 0;
  end else begin
    if (w_wr_hit_can_afivr3 & REG_WEN & ~REG_CAN_EN) begin
      if (REG_WBTEN[3]) begin
        REG_ACF3_ID_VAL[31:24] <= REG_WDATA[`CAN_ID1AFV3+3 +: 8];
      end
      if (REG_WBTEN[2]) begin
        REG_ACF3_ID_VAL[23:21] <= REG_WDATA[`CAN_ID1AFV3 +: 3];
        REG_ACF3_ID_VAL[20]    <= REG_WDATA[`CAN_SRTRAFV3];
        REG_ACF3_ID_VAL[19]    <= REG_WDATA[`CAN_IDEAFV3];
        REG_ACF3_ID_VAL[18:16] <= REG_WDATA[`CAN_ID2AFV3+15 +: 3];
      end
      if (REG_WBTEN[1]) begin
        REG_ACF3_ID_VAL[15:8]  <= REG_WDATA[`CAN_ID2AFV3+7 +: 8];
      end
      if (REG_WBTEN[0]) begin
        REG_ACF3_ID_VAL[7:1]   <= REG_WDATA[`CAN_ID2AFV3 +: 7];
        REG_ACF3_ID_VAL[0]     <= REG_WDATA[`CAN_ERTRAFV3];
      end
    end
  end
end

wire [31:0] w_rd_can_afivr3;
assign w_rd_can_afivr3 = (w_rd_hit_can_afivr3 & REG_REN) ?
                         {{32-11-`CAN_ID1AFV3{1'b0}}, REG_ACF3_ID_VAL[31:21], {`CAN_ID1AFV3{1'b0}}}  |
                         {{32-1-`CAN_SRTRAFV3{1'b0}}, REG_ACF3_ID_VAL[20],    {`CAN_SRTRAFV3{1'b0}}} |
                         {{32-1-`CAN_IDEAFV3{1'b0}},  REG_ACF3_ID_VAL[19],    {`CAN_IDEAFV3{1'b0}}}  |
                         {{32-18-`CAN_ID2AFV3{1'b0}}, REG_ACF3_ID_VAL[18:1],  {`CAN_ID2AFV3{1'b0}}}  |
                         {{32-1-`CAN_ERTRAFV3{1'b0}}, REG_ACF3_ID_VAL[0],     {`CAN_ERTRAFV3{1'b0}}} :
                         32'h0;

// CAN Acceptance Filter ID Mask Register4
//----------------------------------------------
always @ (posedge SYSCLK or negedge SYSRST_N) begin
  if (!SYSRST_N) begin
    REG_ACF4_ID_MASK <= 0;
  end else begin
    if (w_wr_hit_can_afimr4 & REG_WEN & ~REG_CAN_EN) begin
      if (REG_WBTEN[3]) begin
        REG_ACF4_ID_MASK[31:24] <= REG_WDATA[`CAN_ID1AFM4+3 +: 8];
      end
      if (REG_WBTEN[2]) begin
        REG_ACF4_ID_MASK[23:21] <= REG_WDATA[`CAN_ID1AFM4 +: 3];
        REG_ACF4_ID_MASK[20]    <= REG_WDATA[`CAN_SRTRAFM4];
        REG_ACF4_ID_MASK[19]    <= REG_WDATA[`CAN_IDEAFM4];
        REG_ACF4_ID_MASK[18:16] <= REG_WDATA[`CAN_ID2AFM4+15 +: 3];
      end
      if (REG_WBTEN[1]) begin
        REG_ACF4_ID_MASK[15:8]  <= REG_WDATA[`CAN_ID2AFM4+7 +: 8];
      end
      if (REG_WBTEN[0]) begin
        REG_ACF4_ID_MASK[7:1]   <= REG_WDATA[`CAN_ID2AFM4 +: 7];
        REG_ACF4_ID_MASK[0]     <= REG_WDATA[`CAN_ERTRAFM4];
      end
    end
  end
end

wire [31:0] w_rd_can_afimr4;
assign w_rd_can_afimr4 = (w_rd_hit_can_afimr4 & REG_REN) ?
                         {{32-11-`CAN_ID1AFM4{1'b0}}, REG_ACF4_ID_MASK[31:21], {`CAN_ID1AFM4{1'b0}}}  |
                         {{32-1-`CAN_SRTRAFM4{1'b0}}, REG_ACF4_ID_MASK[20],    {`CAN_SRTRAFM4{1'b0}}} |
                         {{32-1-`CAN_IDEAFM4{1'b0}},  REG_ACF4_ID_MASK[19],    {`CAN_IDEAFM4{1'b0}}}  |
                         {{32-18-`CAN_ID2AFM4{1'b0}}, REG_ACF4_ID_MASK[18:1],  {`CAN_ID2AFM4{1'b0}}}  |
                         {{32-1-`CAN_ERTRAFM4{1'b0}}, REG_ACF4_ID_MASK[0],     {`CAN_ERTRAFM4{1'b0}}} :
                         32'h0;

// CAN Acceptance Filter ID Value Register4
//----------------------------------------------
always @ (posedge SYSCLK or negedge SYSRST_N) begin
  if (!SYSRST_N) begin
    REG_ACF4_ID_VAL <= 0;
  end else begin
    if (w_wr_hit_can_afivr4 & REG_WEN & ~REG_CAN_EN) begin
      if (REG_WBTEN[3]) begin
        REG_ACF4_ID_VAL[31:24] <= REG_WDATA[`CAN_ID1AFV4+3 +: 8];
      end
      if (REG_WBTEN[2]) begin
        REG_ACF4_ID_VAL[23:21] <= REG_WDATA[`CAN_ID1AFV4 +: 3];
        REG_ACF4_ID_VAL[20]    <= REG_WDATA[`CAN_SRTRAFV4];
        REG_ACF4_ID_VAL[19]    <= REG_WDATA[`CAN_IDEAFV4];
        REG_ACF4_ID_VAL[18:16] <= REG_WDATA[`CAN_ID2AFV4+15 +: 3];
      end
      if (REG_WBTEN[1]) begin
        REG_ACF4_ID_VAL[15:8]  <= REG_WDATA[`CAN_ID2AFV4+7 +: 8];
      end
      if (REG_WBTEN[0]) begin
        REG_ACF4_ID_VAL[7:1]   <= REG_WDATA[`CAN_ID2AFV4 +: 7];
        REG_ACF4_ID_VAL[0]     <= REG_WDATA[`CAN_ERTRAFV4];
      end
    end
  end
end

wire [31:0] w_rd_can_afivr4;
assign w_rd_can_afivr4 = (w_rd_hit_can_afivr4 & REG_REN) ?
                         {{32-11-`CAN_ID1AFV4{1'b0}}, REG_ACF4_ID_VAL[31:21], {`CAN_ID1AFV4{1'b0}}}  |
                         {{32-1-`CAN_SRTRAFV4{1'b0}}, REG_ACF4_ID_VAL[20],    {`CAN_SRTRAFV4{1'b0}}} |
                         {{32-1-`CAN_IDEAFV4{1'b0}},  REG_ACF4_ID_VAL[19],    {`CAN_IDEAFV4{1'b0}}}  |
                         {{32-18-`CAN_ID2AFV4{1'b0}}, REG_ACF4_ID_VAL[18:1],  {`CAN_ID2AFV4{1'b0}}}  |
                         {{32-1-`CAN_ERTRAFV4{1'b0}}, REG_ACF4_ID_VAL[0],     {`CAN_ERTRAFV4{1'b0}}} :
                         32'h0;

// CAN FIFO and Buffer Reset Register
//----------------------------------------------
always @ (posedge SYSCLK or negedge SYSRST_N) begin
  if (!SYSRST_N) begin
    REG_TXHPB_RST <= 0;
    REG_TXF_RST   <= 0;
    REG_RXF_RST   <= 0;
  end else begin
    REG_TXHPB_RST <= 0;
    REG_TXF_RST   <= 0;
    REG_RXF_RST   <= 0;
    if (w_wr_hit_can_fiforr & REG_WEN) begin
      if (REG_WBTEN[2]) begin
        REG_TXHPB_RST <= REG_WDATA[`CAN_TXHPBRST];
        REG_TXF_RST   <= REG_WDATA[`CAN_TXFIFORST];
      end
      if (REG_WBTEN[0]) begin
        REG_RXF_RST   <= REG_WDATA[`CAN_RXFIFORST];
      end
    end
  end
end

// CAN Self Test Mode Control Register
//----------------------------------------------
always @ (posedge SYSCLK or negedge SYSRST_N) begin
  if (!SYSRST_N) begin
    REG_SELF_TMODE <= 0;
  end else begin
    if (w_wr_hit_can_stmcr & REG_WEN & ~REG_CAN_EN & REG_WBTEN[0])
      REG_SELF_TMODE <= REG_WDATA[`CAN_STM];
  end
end

wire [31:0] w_rd_can_stmcr;
assign w_rd_can_stmcr = (w_rd_hit_can_stmcr & REG_REN) ?
                        {{32-1-`CAN_STM{1'b0}}, REG_SELF_TMODE, {`CAN_STM{1'b0}}} :
                        32'h0;

// CAN PHY Sleep Mode Control Register
//----------------------------------------------
always @ (posedge SYSCLK or negedge SYSRST_N) begin
  if (!SYSRST_N) begin
    REG_PHY_SLEEP_EN <= 0;
  end else begin
    if (w_wr_hit_can_pslmcr & REG_WEN & ~REG_CAN_EN & REG_WBTEN[0])
      REG_PHY_SLEEP_EN <= REG_WDATA[`CAN_PSLM];
  end
end

wire [31:0] w_rd_can_pslmcr;
assign w_rd_can_pslmcr = (w_rd_hit_can_pslmcr & REG_REN) ?
                         {{32-1-`CAN_PSLM{1'b0}}, REG_PHY_SLEEP_EN, {`CAN_PSLM{1'b0}}} :
                         32'h0;

// CAN IP Version Register
//----------------------------------------------
wire [31:0] w_rd_can_ver;
assign w_rd_can_ver = (w_rd_hit_can_ver & REG_REN) ?
                      {{32- 8-`CAN_MAJVER{1'b0}},  `CAN_MAJVERVAL,  {`CAN_MAJVER{1'b0}}} |
                      {{32- 8-`CAN_MINVER{1'b0}},  `CAN_MINVERVAL,  {`CAN_MINVER{1'b0}}} |
                      {{32-16-`CAN_PATVER{1'b0}},  `CAN_PATVERVAL,  {`CAN_PATVER{1'b0}}} :
                      32'h0;

// AXI Read Data
//----------------------------------------------
assign REG_RDATA = w_rd_can_enr |
                   w_rd_can_tqpr |
                   w_rd_can_btsr |
                   w_rd_can_ecntr |
                   w_rd_can_stsr |
                   w_rd_can_isr |
                   w_rd_can_ier |
                   w_rd_can_rmr1 |
                   w_rd_can_rmr2 |
                   w_rd_can_rmr3 |
                   w_rd_can_rmr4 |
                   w_rd_can_afer |
                   w_rd_can_afimr1 |
                   w_rd_can_afivr1 |
                   w_rd_can_afimr2 |
                   w_rd_can_afivr2 |
                   w_rd_can_afimr3 |
                   w_rd_can_afivr3 |
                   w_rd_can_afimr4 |
                   w_rd_can_afivr4 |
                   w_rd_can_stmcr |
                   w_rd_can_pslmcr |
                   w_rd_can_ver ;

endmodule
