//-----------------------------------------------
// Module: i2cm_reg
//  I2C Master Controller Register
//-----------------------------------------------
// Copyright © 2021 Space Cubics, LLC.
//-----------------------------------------------
`include "i2cm_version.vh"
`include "i2cm_reg_map.vh"

module i2cm_reg # (
  parameter P_FIFO_DPTBW = 4, // Renge: 1-15
  parameter [15:0] P_INIT_THDSTA = 16'h0027,
  parameter [15:0] P_INIT_TSUSTO = 16'h0027,
  parameter [15:0] P_INIT_TSUSTA = 16'h0027,
  parameter [15:0] P_INIT_THIGH  = 16'h002D,
  parameter [15:0] P_INIT_THDDAT = 16'h0003,
  parameter [15:0] P_INIT_TSUDAT = 16'h002D,
  parameter [15:0] P_INIT_TBUF   = 16'h0037
) (
  // System Interface
  input  SYSCLK,
  input  SYSRST_N,

  // AHB Interface
  input  REG_ACC,
  input  REG_W1R0,
  input  [31:0] REG_ADDR,
  input  [3:0] REG_BYTEEN,
  input  [31:0] REG_WDATA,
  output [31:0] REG_RDATA,
  input  AHB_RD,
  input  [31:0] AHB_ADDR,
  output AHB_WAIT,

  // MAIN Controller Interface
  output reg REG_I2CM_EN,
  input  REG_I2CM_SBUSY,
  input  REG_I2CM_OBUSY,
  output reg [15:0] REG_SCL_TOPROD,
  output reg [15:0] REG_THDSTA,
  output reg [15:0] REG_TSUSTO,
  output reg [15:0] REG_TSUSTA,
  output reg [15:0] REG_THIGH,
  output reg [15:0] REG_THDDAT,
  output reg [15:0] REG_TSUDAT,
  output reg [15:0] REG_TBUF,
  output reg [15:0] REG_SMPL_DELAY,
  input  REG_INT_COMP,
  input  REG_INT_ARB_LST,
  input  REG_INT_ACK_ERR,
  input  REG_INT_BIT_ERR,
  input  REG_INT_SCL_TO,
  input  REG_I2CM_EN_OFF,

  // TX FIFO Interface
  output reg REG_TXF_WEN,
  output reg [9:0] REG_TXF_WDATA,
  output reg REG_TXF_RST,
  output reg [P_FIFO_DPTBW:0] REG_TXF_UTHL,
  input  [P_FIFO_DPTBW:0] REG_TXF_CAP,
  input  REG_INT_TXF_UTH,
  input  REG_INT_TXF_OVF,

  // RX FIFO Interface
  output REG_RXF_REN,
  input  [7:0] REG_RXF_RDATA,
  output reg REG_RXF_RST,
  output reg [P_FIFO_DPTBW:0] REG_RXF_OTHL,
  input  [P_FIFO_DPTBW:0] REG_RXF_CAP,
  input  REG_INT_RXF_OTH,
  input  REG_INT_RXF_UDF,

  // Interrupt Interface
  output I2CM_INT
);

wire w_reg_write;
wire w_reg_read;
assign w_reg_write = REG_ACC &  REG_W1R0;
assign w_reg_read  = REG_ACC & !REG_W1R0;

// Address Decoder
wire w_hit_i2cm_enr;
wire w_hit_i2cm_txfifor;
wire w_hit_i2cm_rxfifor;
wire w_hit_i2cm_bsr;
wire w_hit_i2cm_isr;
wire w_hit_i2cm_ier;
wire w_hit_i2cm_fifosr;
wire w_hit_i2cm_fiforr;
wire w_hit_i2cm_ftlsr;
wire w_hit_i2cm_scltsr;
wire w_hit_i2cm_thdstar;
wire w_hit_i2cm_tsustor;
wire w_hit_i2cm_tsustar;
wire w_hit_i2cm_thighr;
wire w_hit_i2cm_thddatr;
wire w_hit_i2cm_tsudatr;
wire w_hit_i2cm_tbufr;
wire w_hit_i2cm_tbsmplr;
wire w_hit_i2cm_ver;
assign w_hit_i2cm_enr     = ({REG_ADDR[15:2] , 2'b00} == `I2CM_ENR);
assign w_hit_i2cm_txfifor = ({REG_ADDR[15:2] , 2'b00} == `I2CM_TXFIFOR);
assign w_hit_i2cm_rxfifor = ({REG_ADDR[15:2] , 2'b00} == `I2CM_RXFIFOR);
assign w_hit_i2cm_bsr     = ({REG_ADDR[15:2] , 2'b00} == `I2CM_BSR);
assign w_hit_i2cm_isr     = ({REG_ADDR[15:2] , 2'b00} == `I2CM_ISR);
assign w_hit_i2cm_ier     = ({REG_ADDR[15:2] , 2'b00} == `I2CM_IER);
assign w_hit_i2cm_fifosr  = ({REG_ADDR[15:2] , 2'b00} == `I2CM_FIFOSR);
assign w_hit_i2cm_fiforr  = ({REG_ADDR[15:2] , 2'b00} == `I2CM_FIFORR);
assign w_hit_i2cm_ftlsr   = ({REG_ADDR[15:2] , 2'b00} == `I2CM_FTLSR);
assign w_hit_i2cm_scltsr  = ({REG_ADDR[15:2] , 2'b00} == `I2CM_SCLTSR);
assign w_hit_i2cm_thdstar = ({REG_ADDR[15:2] , 2'b00} == `I2CM_THDSTAR);
assign w_hit_i2cm_tsustor = ({REG_ADDR[15:2] , 2'b00} == `I2CM_TSUSTOR);
assign w_hit_i2cm_tsustar = ({REG_ADDR[15:2] , 2'b00} == `I2CM_TSUSTAR);
assign w_hit_i2cm_thighr  = ({REG_ADDR[15:2] , 2'b00} == `I2CM_THIGHR);
assign w_hit_i2cm_thddatr = ({REG_ADDR[15:2] , 2'b00} == `I2CM_THDDATR);
assign w_hit_i2cm_tsudatr = ({REG_ADDR[15:2] , 2'b00} == `I2CM_TSUDATR);
assign w_hit_i2cm_tbufr   = ({REG_ADDR[15:2] , 2'b00} == `I2CM_TBUFR);
assign w_hit_i2cm_tbsmplr = ({REG_ADDR[15:2] , 2'b00} == `I2CM_TBSMPLR);
assign w_hit_i2cm_ver     = ({REG_ADDR[15:2] , 2'b00} == `I2CM_VER);

// I2C Master Enable Register
//----------------------------------------------
always @ (posedge SYSCLK or negedge SYSRST_N) begin
  if (!SYSRST_N)
    REG_I2CM_EN <= 0;
  else if (REG_I2CM_EN_OFF)
    REG_I2CM_EN <= 0;
  else if (w_hit_i2cm_enr & w_reg_write & REG_BYTEEN[0])
    REG_I2CM_EN <= REG_WDATA[`I2CM_EN];
end

wire [31:0] w_rd_i2cm_enr;
assign w_rd_i2cm_enr = (w_hit_i2cm_enr & w_reg_read) ?
                       {{32-1-`I2CM_EN{1'b0}}, REG_I2CM_EN, {`I2CM_EN{1'b0}}} :
                       32'h0;

// I2C Master TX FIFO Register
//----------------------------------------------
always @ (*) begin
  if (w_hit_i2cm_txfifor & w_reg_write & |REG_BYTEEN[1:0]) begin
    REG_TXF_WEN   = 1'b1;
    REG_TXF_WDATA = 0;
    if (REG_BYTEEN[1]) begin
      REG_TXF_WDATA[`I2CM_RESTART] = REG_WDATA[`I2CM_RESTART];
      REG_TXF_WDATA[`I2CM_STOP]    = REG_WDATA[`I2CM_STOP];
    end
    if (REG_BYTEEN[0]) begin
      REG_TXF_WDATA[`I2CM_TXDATA +: 8] = REG_WDATA[`I2CM_TXDATA +: 8];
    end
  end
  else begin
    REG_TXF_WEN   = 0;
    REG_TXF_WDATA = 0;
  end
end

// I2C Master RX FIFO Register
//----------------------------------------------
wire w_rxf_rd_wait;
reg r_rxf_rd_wait_p1;
assign w_rxf_rd_wait = AHB_RD & ({AHB_ADDR[15:2] , 2'b00} == `I2CM_RXFIFOR);
always @ (posedge SYSCLK or negedge SYSRST_N) begin
  if (!SYSRST_N)
    r_rxf_rd_wait_p1 <= 0;
  else
    r_rxf_rd_wait_p1 <= w_rxf_rd_wait;
end
assign AHB_WAIT = w_rxf_rd_wait | r_rxf_rd_wait_p1;

assign REG_RXF_REN = w_hit_i2cm_rxfifor & w_reg_read & r_rxf_rd_wait_p1;

reg [1:0] r_rxf_rd_en_retim;
always @ (posedge SYSCLK or negedge SYSRST_N) begin
  if (!SYSRST_N)
    r_rxf_rd_en_retim <= 0;
  else
    r_rxf_rd_en_retim <= {r_rxf_rd_en_retim[0], REG_RXF_REN};
end

wire [31:0] w_rd_i2cm_rxfifor;
assign w_rd_i2cm_rxfifor = (r_rxf_rd_en_retim[1]) ?
                           {{32-8-`I2CM_RXDATA{1'b0}}, REG_RXF_RDATA, {`I2CM_RXDATA{1'b0}}} :
                           32'h0;

// I2C Master Bus Status Register
//----------------------------------------------
wire [31:0] w_rd_i2cm_bsr;
assign w_rd_i2cm_bsr = (w_hit_i2cm_bsr & w_reg_read) ?
                       {{32-1-`I2CM_OTHERBUSY{1'b0}}, REG_I2CM_OBUSY, {`I2CM_OTHERBUSY{1'b0}}} |
                       {{32-1-`I2CM_SELFBUSY{1'b0}},  REG_I2CM_SBUSY, {`I2CM_SELFBUSY{1'b0}}}  :
                       32'h0;

// I2C Master Interrput Status Register
//----------------------------------------------
reg r_int_sclto;
reg r_int_rxfifoudf;
reg r_int_txfifoovf;
reg r_int_biter;
reg r_int_acker;
reg r_int_rxfifooth;
reg r_int_txfifouth;
reg r_int_arblst;
reg r_int_comp;

always @ (posedge SYSCLK or negedge SYSRST_N) begin
  if (!SYSRST_N) begin
    r_int_sclto     <= 0;
    r_int_rxfifoudf <= 0;
    r_int_txfifoovf <= 0;
    r_int_biter     <= 0;
    r_int_acker     <= 0;
    r_int_rxfifooth <= 0;
    r_int_txfifouth <= 0;
    r_int_arblst    <= 0;
    r_int_comp      <= 0;
  end
  else begin
    if (w_hit_i2cm_isr & w_reg_write) begin
      if (REG_BYTEEN[1]) begin
        if (REG_WDATA[`I2CM_SCLTO])
          r_int_sclto     <= 0;
        if (REG_WDATA[`I2CM_RXFIFOUDF])
          r_int_rxfifoudf <= 0;
        if (REG_WDATA[`I2CM_TXFIFOOVF])
          r_int_txfifoovf <= 0;
        if (REG_WDATA[`I2CM_BITER])
          r_int_biter     <= 0;
        if (REG_WDATA[`I2CM_ACKER])
          r_int_acker     <= 0;
      end
      if (REG_BYTEEN[0]) begin
        if (REG_WDATA[`I2CM_RXFIFOOTH])
          r_int_rxfifooth <= 0;
        if (REG_WDATA[`I2CM_TXFIFOUTH])
          r_int_txfifouth <= 0;
        if (REG_WDATA[`I2CM_ARBLST])
          r_int_arblst    <= 0;
        if (REG_WDATA[`I2CM_COMP])
          r_int_comp      <= 0;
      end
    end
    if (REG_INT_SCL_TO)
      r_int_sclto     <= 1'b1;
    if (REG_INT_RXF_UDF)
      r_int_rxfifoudf <= 1'b1;
    if (REG_INT_TXF_OVF)
      r_int_txfifoovf <= 1'b1;
    if (REG_INT_BIT_ERR)
      r_int_biter     <= 1'b1;
    if (REG_INT_ACK_ERR)
      r_int_acker     <= 1'b1;
    if (REG_INT_RXF_OTH)
      r_int_rxfifooth <= 1'b1;
    if (REG_INT_TXF_UTH)
      r_int_txfifouth <= 1'b1;
    if (REG_INT_ARB_LST)
      r_int_arblst    <= 1'b1;
    if (REG_INT_COMP)
      r_int_comp      <= 1'b1;
  end
end

wire [31:0] w_rd_i2cm_isr;
assign w_rd_i2cm_isr = (w_hit_i2cm_isr & w_reg_read) ?
                       {{32-1-`I2CM_SCLTO{1'b0}},     r_int_sclto,      {`I2CM_SCLTO{1'b0}}}     |
                       {{32-1-`I2CM_RXFIFOUDF{1'b0}}, r_int_rxfifoudf,  {`I2CM_RXFIFOUDF{1'b0}}} |
                       {{32-1-`I2CM_TXFIFOOVF{1'b0}}, r_int_txfifoovf,  {`I2CM_TXFIFOOVF{1'b0}}} |
                       {{32-1-`I2CM_BITER{1'b0}},     r_int_biter,      {`I2CM_BITER{1'b0}}}     |
                       {{32-1-`I2CM_ACKER{1'b0}},     r_int_acker,      {`I2CM_ACKER{1'b0}}}     |
                       {{32-1-`I2CM_RXFIFOOTH{1'b0}}, r_int_rxfifooth,  {`I2CM_RXFIFOOTH{1'b0}}} |
                       {{32-1-`I2CM_TXFIFOUTH{1'b0}}, r_int_txfifouth,  {`I2CM_TXFIFOUTH{1'b0}}} |
                       {{32-1-`I2CM_ARBLST{1'b0}},    r_int_arblst,     {`I2CM_ARBLST{1'b0}}}    |
                       {{32-1-`I2CM_COMP{1'b0}},      r_int_comp,       {`I2CM_COMP{1'b0}}}      :
                       32'h0;

// I2C Master Interrupt Enable Register
//----------------------------------------------
reg r_enb_sclto;
reg r_enb_rxfifoudf;
reg r_enb_txfifoovf;
reg r_enb_biter;
reg r_enb_acker;
reg r_enb_rxfifooth;
reg r_enb_txfifouth;
reg r_enb_arblst;
reg r_enb_comp;
always @ (posedge SYSCLK or negedge SYSRST_N) begin
  if (!SYSRST_N) begin
    r_enb_sclto     <= 0;
    r_enb_rxfifoudf <= 0;
    r_enb_txfifoovf <= 0;
    r_enb_biter     <= 0;
    r_enb_acker     <= 0;
    r_enb_rxfifooth <= 0;
    r_enb_txfifouth <= 0;
    r_enb_arblst    <= 0;
    r_enb_comp      <= 0;
  end
  else if (w_hit_i2cm_ier & w_reg_write) begin
    if (REG_BYTEEN[1]) begin
      r_enb_sclto     <= REG_WDATA[`I2CM_SCLTOENB];
      r_enb_rxfifoudf <= REG_WDATA[`I2CM_RXFIFOUDFENB];
      r_enb_txfifoovf <= REG_WDATA[`I2CM_TXFIFOOVFENB];
      r_enb_biter     <= REG_WDATA[`I2CM_BITERENB];
      r_enb_acker     <= REG_WDATA[`I2CM_ACKERENB];
    end
    if (REG_BYTEEN[0]) begin
      r_enb_rxfifooth <= REG_WDATA[`I2CM_RXFIFOOTHENB];
      r_enb_txfifouth <= REG_WDATA[`I2CM_TXFIFOUTHENB];
      r_enb_arblst    <= REG_WDATA[`I2CM_ARBLSTENB];
      r_enb_comp      <= REG_WDATA[`I2CM_COMPENB];
    end
  end
end

wire [31:0] w_rd_i2cm_ier;
assign w_rd_i2cm_ier = (w_hit_i2cm_ier & w_reg_read) ?
                       {{32-1-`I2CM_SCLTOENB{1'b0}},     r_enb_sclto,      {`I2CM_SCLTOENB{1'b0}}}     |
                       {{32-1-`I2CM_RXFIFOUDFENB{1'b0}}, r_enb_rxfifoudf,  {`I2CM_RXFIFOUDFENB{1'b0}}} |
                       {{32-1-`I2CM_TXFIFOOVFENB{1'b0}}, r_enb_txfifoovf,  {`I2CM_TXFIFOOVFENB{1'b0}}} |
                       {{32-1-`I2CM_BITERENB{1'b0}},     r_enb_biter,      {`I2CM_BITERENB{1'b0}}}     |
                       {{32-1-`I2CM_ACKERENB{1'b0}},     r_enb_acker,      {`I2CM_ACKERENB{1'b0}}}     |
                       {{32-1-`I2CM_RXFIFOOTHENB{1'b0}}, r_enb_rxfifooth,  {`I2CM_RXFIFOOTHENB{1'b0}}} |
                       {{32-1-`I2CM_TXFIFOUTHENB{1'b0}}, r_enb_txfifouth,  {`I2CM_TXFIFOUTHENB{1'b0}}} |
                       {{32-1-`I2CM_ARBLSTENB{1'b0}},    r_enb_arblst,     {`I2CM_ARBLSTENB{1'b0}}}    |
                       {{32-1-`I2CM_COMPENB{1'b0}},      r_enb_comp,       {`I2CM_COMPENB{1'b0}}}      :
                       32'h0;

assign I2CM_INT = (r_int_sclto     & r_enb_sclto    ) |
                  (r_int_rxfifoudf & r_enb_rxfifoudf) |
                  (r_int_txfifoovf & r_enb_txfifoovf) |
                  (r_int_biter     & r_enb_biter    ) |
                  (r_int_acker     & r_enb_acker    ) |
                  (r_int_rxfifooth & r_enb_rxfifooth) |
                  (r_int_txfifouth & r_enb_txfifouth) |
                  (r_int_arblst    & r_enb_arblst   ) |
                  (r_int_comp      & r_enb_comp     ) ;

// I2C Master FIFO Status Register
//----------------------------------------------
wire [31:0] w_rd_i2cm_fifosr;
assign w_rd_i2cm_fifosr = (w_hit_i2cm_fifosr & w_reg_read) ?
                          {{32-P_FIFO_DPTBW-1-`I2CM_RXFIFOCAP{1'b0}}, REG_RXF_CAP, {`I2CM_RXFIFOCAP{1'b0}}} |
                          {{32-P_FIFO_DPTBW-1-`I2CM_TXFIFOCAP{1'b0}}, REG_TXF_CAP, {`I2CM_TXFIFOCAP{1'b0}}} :
                          32'h0;

// I2C Master FIFO Reset Register
//----------------------------------------------
always @ (posedge SYSCLK or negedge SYSRST_N) begin
  if (!SYSRST_N) begin
    REG_RXF_RST <= 0;
    REG_TXF_RST <= 0;
  end
  else begin
    REG_RXF_RST <= 0;
    REG_TXF_RST <= 0;
    if (w_hit_i2cm_fiforr & w_reg_write) begin
      if (REG_BYTEEN[2])
        REG_RXF_RST <= REG_WDATA[`I2CM_RXFIFORST];
      if (REG_BYTEEN[0])
        REG_TXF_RST <= REG_WDATA[`I2CM_TXFIFORST];
    end
  end
end

// I2C Master FIFO Threshold Level Setting Register
//----------------------------------------------
generate
  if (P_FIFO_DPTBW >= 8) begin
    always @ (posedge SYSCLK or negedge SYSRST_N) begin
      if (!SYSRST_N) begin
        REG_RXF_OTHL <= 0;
        REG_TXF_UTHL <= 0;
      end
      else if (w_hit_i2cm_ftlsr & w_reg_write) begin
        if (REG_BYTEEN[3])
          REG_RXF_OTHL[P_FIFO_DPTBW:8] <= REG_WDATA[`I2CM_RXFIFOOTHL+8 +: P_FIFO_DPTBW-8+1];
        if (REG_BYTEEN[2])
          REG_RXF_OTHL[7:0]            <= REG_WDATA[`I2CM_RXFIFOOTHL +: 8];
        if (REG_BYTEEN[1])
          REG_TXF_UTHL[P_FIFO_DPTBW:8] <= REG_WDATA[`I2CM_TXFIFOUTHL+8 +: P_FIFO_DPTBW-8+1];
        if (REG_BYTEEN[0])
          REG_TXF_UTHL[7:0]            <= REG_WDATA[`I2CM_TXFIFOUTHL +: 8];
      end
    end
  end
  else begin
    always @ (posedge SYSCLK or negedge SYSRST_N) begin
      if (!SYSRST_N) begin
        REG_RXF_OTHL <= 0;
        REG_TXF_UTHL <= 0;
      end
      else if (w_hit_i2cm_ftlsr & w_reg_write) begin
        if (REG_BYTEEN[2])
          REG_RXF_OTHL[P_FIFO_DPTBW:0] <= REG_WDATA[`I2CM_RXFIFOOTHL +: P_FIFO_DPTBW+1];
        if (REG_BYTEEN[0])
          REG_TXF_UTHL[P_FIFO_DPTBW:0] <= REG_WDATA[`I2CM_TXFIFOUTHL +: P_FIFO_DPTBW+1];
      end
    end
  end
endgenerate

wire [31:0] w_rd_i2cm_ftlsr;
assign w_rd_i2cm_ftlsr = (w_hit_i2cm_ftlsr & w_reg_read) ?
                         {{32-P_FIFO_DPTBW-1-`I2CM_RXFIFOOTHL{1'b0}}, REG_RXF_OTHL, {`I2CM_RXFIFOOTHL{1'b0}}} |
                         {{32-P_FIFO_DPTBW-1-`I2CM_TXFIFOUTHL{1'b0}}, REG_TXF_UTHL, {`I2CM_TXFIFOUTHL{1'b0}}} :
                         32'h0;

// I2C Master SCL Timeout Setting Register
//----------------------------------------------
always @ (posedge SYSCLK or negedge SYSRST_N) begin
  if (!SYSRST_N)
    REG_SCL_TOPROD <= 0;
  else if (w_hit_i2cm_scltsr & w_reg_write) begin
    if (REG_BYTEEN[1])
      REG_SCL_TOPROD[`I2CM_SCLTOPROD+8 +: 8] <= REG_WDATA[`I2CM_SCLTOPROD+8 +: 8];
    if (REG_BYTEEN[0])
      REG_SCL_TOPROD[`I2CM_SCLTOPROD +: 8]   <= REG_WDATA[`I2CM_SCLTOPROD +: 8];
  end
end

wire [31:0] w_rd_i2cm_scltsr;
assign w_rd_i2cm_scltsr = (w_hit_i2cm_scltsr & w_reg_read) ?
                          {{32-16-`I2CM_SCLTOPROD{1'b0}}, REG_SCL_TOPROD, {`I2CM_SCLTOPROD{1'b0}}} :
                          32'h0;

// I2C Master START Hold Timing Setting Register
//----------------------------------------------
always @ (posedge SYSCLK or negedge SYSRST_N) begin
  if (!SYSRST_N)
    REG_THDSTA <= P_INIT_THDSTA;
  else if (w_hit_i2cm_thdstar & w_reg_write & ~REG_I2CM_EN) begin
    if (REG_BYTEEN[1])
      REG_THDSTA[`I2CM_THDSTA+8 +: 8] <= REG_WDATA[`I2CM_THDSTA+8 +: 8];
    if (REG_BYTEEN[0])
      REG_THDSTA[`I2CM_THDSTA +: 8]   <= REG_WDATA[`I2CM_THDSTA +: 8];
  end
end

wire [31:0] w_rd_i2cm_thdstar;
assign w_rd_i2cm_thdstar = (w_hit_i2cm_thdstar & w_reg_read) ?
                           {{32-16-`I2CM_THDSTA{1'b0}}, REG_THDSTA, {`I2CM_THDSTA{1'b0}}} :
                           32'h0;

// I2C Master STOP Setup Timing Setting Register
//----------------------------------------------
always @ (posedge SYSCLK or negedge SYSRST_N) begin
  if (!SYSRST_N)
    REG_TSUSTO <= P_INIT_TSUSTO;
  else if (w_hit_i2cm_tsustor & w_reg_write & ~REG_I2CM_EN) begin
    if (REG_BYTEEN[1])
      REG_TSUSTO[`I2CM_TSUSTO+8 +: 8] <= REG_WDATA[`I2CM_TSUSTO+8 +: 8];
    if (REG_BYTEEN[0])
      REG_TSUSTO[`I2CM_TSUSTO +: 8]   <= REG_WDATA[`I2CM_TSUSTO +: 8];
  end
end

wire [31:0] w_rd_i2cm_tsustor;
assign w_rd_i2cm_tsustor = (w_hit_i2cm_tsustor & w_reg_read) ?
                           {{32-16-`I2CM_TSUSTO{1'b0}}, REG_TSUSTO, {`I2CM_TSUSTO{1'b0}}} :
                           32'h0;

// I2C Master Repeated START Setup Timing Setting Register
//----------------------------------------------
always @ (posedge SYSCLK or negedge SYSRST_N) begin
  if (!SYSRST_N)
    REG_TSUSTA <= P_INIT_TSUSTA;
  else if (w_hit_i2cm_tsustar & w_reg_write & ~REG_I2CM_EN) begin
    if (REG_BYTEEN[1])
      REG_TSUSTA[`I2CM_TSUSTA+8 +: 8] <= REG_WDATA[`I2CM_TSUSTA+8 +: 8];
    if (REG_BYTEEN[0])
      REG_TSUSTA[`I2CM_TSUSTA +: 8]   <= REG_WDATA[`I2CM_TSUSTA +: 8];
  end
end

wire [31:0] w_rd_i2cm_tsustar;
assign w_rd_i2cm_tsustar = (w_hit_i2cm_tsustar & w_reg_read) ?
                           {{32-16-`I2CM_TSUSTA{1'b0}}, REG_TSUSTA, {`I2CM_TSUSTA{1'b0}}} :
                           32'h0;

// I2C Master Clock High Timing Setting Register
//----------------------------------------------
always @ (posedge SYSCLK or negedge SYSRST_N) begin
  if (!SYSRST_N)
    REG_THIGH <= P_INIT_THIGH;
  else if (w_hit_i2cm_thighr & w_reg_write & ~REG_I2CM_EN) begin
    if (REG_BYTEEN[1])
      REG_THIGH[`I2CM_THIGH+8 +: 8] <= REG_WDATA[`I2CM_THIGH+8 +: 8];
    if (REG_BYTEEN[0])
      REG_THIGH[`I2CM_THIGH +: 8]   <= REG_WDATA[`I2CM_THIGH +: 8];
  end
end

wire [31:0] w_rd_i2cm_thighr;
assign w_rd_i2cm_thighr = (w_hit_i2cm_thighr & w_reg_read) ?
                          {{32-16-`I2CM_THIGH{1'b0}}, REG_THIGH, {`I2CM_THIGH{1'b0}}} :
                          32'h0;

// I2C Master Data Hold Timing Setting Register
//----------------------------------------------
always @ (posedge SYSCLK or negedge SYSRST_N) begin
  if (!SYSRST_N)
    REG_THDDAT <= P_INIT_THDDAT;
  else if (w_hit_i2cm_thddatr & w_reg_write & ~REG_I2CM_EN) begin
    if (REG_BYTEEN[1])
      REG_THDDAT[`I2CM_THDDAT+8 +: 8] <= REG_WDATA[`I2CM_THDDAT+8 +: 8];
    if (REG_BYTEEN[0])
      REG_THDDAT[`I2CM_THDDAT +: 8]   <= REG_WDATA[`I2CM_THDDAT +: 8];
  end
end

wire [31:0] w_rd_i2cm_thddatr;
assign w_rd_i2cm_thddatr = (w_hit_i2cm_thddatr & w_reg_read) ?
                           {{32-16-`I2CM_THDDAT{1'b0}}, REG_THDDAT, {`I2CM_THDDAT{1'b0}}} :
                           32'h0;

// I2C Master Data Setup Timing Setting Register
//----------------------------------------------
always @ (posedge SYSCLK or negedge SYSRST_N) begin
  if (!SYSRST_N)
    REG_TSUDAT <= P_INIT_TSUDAT;
  else if (w_hit_i2cm_tsudatr & w_reg_write & ~REG_I2CM_EN) begin
    if (REG_BYTEEN[1])
      REG_TSUDAT[`I2CM_TSUDAT+8 +: 8] <= REG_WDATA[`I2CM_TSUDAT+8 +: 8];
    if (REG_BYTEEN[0])
      REG_TSUDAT[`I2CM_TSUDAT +: 8]   <= REG_WDATA[`I2CM_TSUDAT +: 8];
  end
end

wire [31:0] w_rd_i2cm_tsudatr;
assign w_rd_i2cm_tsudatr = (w_hit_i2cm_tsudatr & w_reg_read) ?
                           {{32-16-`I2CM_TSUDAT{1'b0}}, REG_TSUDAT, {`I2CM_TSUDAT{1'b0}}} :
                           32'h0;

// I2C Master Bus Free Timing Setting Register
//----------------------------------------------
always @ (posedge SYSCLK or negedge SYSRST_N) begin
  if (!SYSRST_N)
    REG_TBUF <= P_INIT_TBUF;
  else if (w_hit_i2cm_tbufr & w_reg_write & ~REG_I2CM_EN) begin
    if (REG_BYTEEN[1])
      REG_TBUF[`I2CM_TBUF+8 +: 8] <= REG_WDATA[`I2CM_TBUF+8 +: 8];
    if (REG_BYTEEN[0])
      REG_TBUF[`I2CM_TBUF +: 8]   <= REG_WDATA[`I2CM_TBUF +: 8];
  end
end

wire [31:0] w_rd_i2cm_tbufr;
assign w_rd_i2cm_tbufr = (w_hit_i2cm_tbufr & w_reg_read) ?
                         {{32-16-`I2CM_TBUF{1'b0}}, REG_TBUF, {`I2CM_TBUF{1'b0}}} :
                         32'h0;

// I2C Master Bus Sampling Timing Setting Register
//----------------------------------------------
always @ (posedge SYSCLK or negedge SYSRST_N) begin
  if (!SYSRST_N)
    REG_SMPL_DELAY <= 0;
  else if (w_hit_i2cm_tbsmplr & w_reg_write & ~REG_I2CM_EN) begin
    if (REG_BYTEEN[1])
      REG_SMPL_DELAY[`I2CM_SMPLDLY+8 +: 8] <= REG_WDATA[`I2CM_SMPLDLY+8 +: 8];
    if (REG_BYTEEN[0])
      REG_SMPL_DELAY[`I2CM_SMPLDLY +: 8]   <= REG_WDATA[`I2CM_SMPLDLY +: 8];
  end
end

wire [31:0] w_rd_i2cm_tbsmplr;
assign w_rd_i2cm_tbsmplr = (w_hit_i2cm_tbsmplr & w_reg_read) ?
                           {{32-16-`I2CM_SMPLDLY{1'b0}}, REG_SMPL_DELAY, {`I2CM_SMPLDLY{1'b0}}} :
                           32'h0;

// I2C Master Controller IP Version Register
//----------------------------------------------
wire [31:0] w_rd_i2cm_ver;
assign w_rd_i2cm_ver = (w_hit_i2cm_ver & w_reg_read) ?
                      {{32- 8-`I2CM_MAJVER{1'b0}},  `I2CM_MAJVERVAL,  {`I2CM_MAJVER{1'b0}}} |
                      {{32- 8-`I2CM_MINVER{1'b0}},  `I2CM_MINVERVAL,  {`I2CM_MINVER{1'b0}}} |
                      {{32-16-`I2CM_PATVER{1'b0}},  `I2CM_PATVERVAL,  {`I2CM_PATVER{1'b0}}} :
                      32'h0;

// AHB Read Data
//----------------------------------------------
assign REG_RDATA = w_rd_i2cm_enr |
                   w_rd_i2cm_rxfifor |
                   w_rd_i2cm_bsr |
                   w_rd_i2cm_isr |
                   w_rd_i2cm_ier |
                   w_rd_i2cm_fifosr |
                   w_rd_i2cm_ftlsr |
                   w_rd_i2cm_scltsr |
                   w_rd_i2cm_thdstar |
                   w_rd_i2cm_tsustor |
                   w_rd_i2cm_tsustar |
                   w_rd_i2cm_thighr |
                   w_rd_i2cm_thddatr |
                   w_rd_i2cm_tsudatr |
                   w_rd_i2cm_tbufr |
                   w_rd_i2cm_tbsmplr |
                   w_rd_i2cm_ver ;

endmodule
