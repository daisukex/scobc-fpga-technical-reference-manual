//-----------------------------------------------
// Module: sc_qspim_reg
//  Space Cubics Quad-SPI Master Register
//-----------------------------------------------
// Copyright © 2020 Space Cubics, LLC.
//-----------------------------------------------
`include "sc_qspim_version.vh"
`include "sc_qspim_reg_map.vh"

module sc_qspim_reg # (
  parameter SC_QSPIM_DT_B_WIDTH = 1, // Renge: 1-4
  parameter SC_QSPIM_FIFO_DEPTH = 4, // Renge: 1-15
  parameter SC_QSPIM_S_DEV_NUM = 1 // Renge: 1-16
) (
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

  // QSPI Main Controller Interface
  output reg [1:0] REG_SPIIOMODE,
  output reg [SC_QSPIM_S_DEV_NUM-1:0] REG_SPISSCTL,
  output REG_TXF_WEN,
  output reg [SC_QSPIM_DT_B_WIDTH*8-1:0] REG_TXF_WDATA,
  output REG_RXF_WEN,
  output REG_RXF_REN,
  input [SC_QSPIM_DT_B_WIDTH*8-1:0] REG_RXF_RDATA,
  input REG_SPIBUSY,
  input [SC_QSPIM_FIFO_DEPTH:0] REG_TXF_CAP,
  input [SC_QSPIM_FIFO_DEPTH:0] REG_RXF_CAP,
  output reg REG_TXF_RST,
  output reg REG_RXF_RST,
  input REG_INT_TXF_UTH,
  input REG_INT_TXF_OVF,
  input REG_INT_TXF_UDF,
  input REG_INT_RXF_OTH,
  input REG_INT_RXF_OVF,
  input REG_INT_RXF_UDF,
  input REG_INT_SCTL_DN,
  output reg REG_SCKPOL,
  output reg REG_SCKPHA,
  output reg [11:0] REG_SCKDIV,
  output reg REG_DTCAPT,
  output reg [SC_QSPIM_FIFO_DEPTH:0] REG_TXF_UTHL,
  output reg [SC_QSPIM_FIFO_DEPTH:0] REG_RXF_OTHL,

  // Interrupt Interface
  output QSPI_INT
);

integer i;

// Address Decoder
wire w_wr_hit_spiacr;
wire w_wr_hit_spitdr;
wire w_wr_hit_spirdr;
wire w_wr_hit_spififorr;
wire w_wr_hit_spiisr;
wire w_wr_hit_spiier;
wire w_wr_hit_spiccr;
wire w_wr_hit_spidcmsr;
wire w_wr_hit_spiftlsr;

wire w_rd_hit_spiacr;
wire w_rd_hit_spirdr;
wire w_rd_hit_spiasr;
wire w_rd_hit_spififosr;
wire w_rd_hit_spiisr;
wire w_rd_hit_spiier;
wire w_rd_hit_spiccr;
wire w_rd_hit_spidcmsr;
wire w_rd_hit_spiftlsr;
wire w_rd_hit_qspiver;

assign w_wr_hit_spiacr = {REG_WADDR[15:2], 2'b00} == `SPIACR;
assign w_wr_hit_spitdr = {REG_WADDR[15:2], 2'b00} == `SPITDR;
assign w_wr_hit_spirdr = {REG_WADDR[15:2], 2'b00} == `SPIRDR;
assign w_wr_hit_spififorr = {REG_WADDR[15:2], 2'b00} == `SPIFIFORR;
assign w_wr_hit_spiisr = {REG_WADDR[15:2], 2'b00} == `SPIISR;
assign w_wr_hit_spiier = {REG_WADDR[15:2], 2'b00} == `SPIIER;
assign w_wr_hit_spiccr = {REG_WADDR[15:2], 2'b00} == `SPICCR;
assign w_wr_hit_spidcmsr = {REG_WADDR[15:2], 2'b00} == `SPIDCMSR;
assign w_wr_hit_spiftlsr = {REG_WADDR[15:2], 2'b00} == `SPIFTLSR;

assign w_rd_hit_spiacr = {REG_RADDR[15:2], 2'b00} == `SPIACR;
assign w_rd_hit_spirdr = {REG_RADDR[15:2], 2'b00} == `SPIRDR;
assign w_rd_hit_spiasr = {REG_RADDR[15:2], 2'b00} == `SPIASR;
assign w_rd_hit_spififosr = {REG_RADDR[15:2], 2'b00} == `SPIFIFOSR;
assign w_rd_hit_spiisr = {REG_RADDR[15:2], 2'b00} == `SPIISR;
assign w_rd_hit_spiier = {REG_RADDR[15:2], 2'b00} == `SPIIER;
assign w_rd_hit_spiccr = {REG_RADDR[15:2], 2'b00} == `SPICCR;
assign w_rd_hit_spidcmsr = {REG_RADDR[15:2], 2'b00} == `SPIDCMSR;
assign w_rd_hit_spiftlsr = {REG_RADDR[15:2], 2'b00} == `SPIFTLSR;
assign w_rd_hit_qspiver = {REG_RADDR[15:2], 2'b00} == `QSPIVER;

// RX FIFO Read Wait
reg [1:0] r_rxf_rd_en_retim;
wire w_rxf_rd_wait;
reg r_rxf_rd_wait_p1;

always @ (posedge SYSCLK or negedge SYSRST_N) begin
  if (!SYSRST_N) begin
    r_rxf_rd_en_retim <= 0;
  end else begin
    r_rxf_rd_en_retim <= {r_rxf_rd_en_retim[0], REG_RXF_REN};
  end
end

assign w_rxf_rd_wait = REG_RXF_REN & ~r_rxf_rd_en_retim[0];

always @ (posedge SYSCLK or negedge SYSRST_N) begin
  if (!SYSRST_N) begin
    r_rxf_rd_wait_p1 <= 1'b0;
  end else begin
    r_rxf_rd_wait_p1 <= w_rxf_rd_wait;
  end
end

assign REG_RWAIT = w_rxf_rd_wait | r_rxf_rd_wait_p1;

// SPI Access Control Register
//----------------------------------------------
always @ (posedge SYSCLK or negedge SYSRST_N) begin
  if (!SYSRST_N) begin
    REG_SPIIOMODE <= 0;
  end else begin
    if (w_wr_hit_spiacr & REG_WEN) begin
      if (REG_WBTEN[2])
        REG_SPIIOMODE <= REG_WDATA[`SPIIOMODE +: 2];
    end
  end
end

generate
  if (SC_QSPIM_S_DEV_NUM > 8) begin
    always @ (posedge SYSCLK or negedge SYSRST_N) begin
      if (!SYSRST_N) begin
        REG_SPISSCTL <= 0;
      end else begin
        if (w_wr_hit_spiacr & REG_WEN) begin
          if (REG_WBTEN[1])
            REG_SPISSCTL[SC_QSPIM_S_DEV_NUM-1:8] <= REG_WDATA[`SPISSCTL+8 +: SC_QSPIM_S_DEV_NUM-8];
          if (REG_WBTEN[0])
            REG_SPISSCTL[7:0]                    <= REG_WDATA[`SPISSCTL +: 8];
        end
      end
    end
  end else begin
    always @ (posedge SYSCLK or negedge SYSRST_N) begin
      if (!SYSRST_N) begin
        REG_SPISSCTL <= 0;
      end else begin
        if (w_wr_hit_spiacr & REG_WEN) begin
          if (REG_WBTEN[0])
            REG_SPISSCTL[SC_QSPIM_S_DEV_NUM-1:0] <= REG_WDATA[`SPISSCTL +: SC_QSPIM_S_DEV_NUM];
        end
      end
    end
  end
endgenerate

wire [31:0] w_rd_spiacr;
assign w_rd_spiacr = (w_rd_hit_spiacr & REG_REN) ?
                     {{32-2-`SPIIOMODE{1'b0}},                 REG_SPIIOMODE, {`SPIIOMODE{1'b0}}} |
                     {{32-SC_QSPIM_S_DEV_NUM-`SPISSCTL{1'b0}}, REG_SPISSCTL,  {`SPISSCTL{1'b0}}}  :
                     32'h0;

// SPI TX Data Register
//----------------------------------------------
assign REG_TXF_WEN = w_wr_hit_spitdr & REG_WEN & |REG_WBTEN;
always @ (*) begin
  for (i=0; i<SC_QSPIM_DT_B_WIDTH; i=i+1) begin
    if (w_wr_hit_spitdr & REG_WEN & REG_WBTEN[i])
      REG_TXF_WDATA[i*8 +: 8] = REG_WDATA[`SPITXDATA+i*8 +: 8];
    else
      REG_TXF_WDATA[i*8 +: 8] = 0;
  end
end

// SPI RX Data Register
//----------------------------------------------
assign REG_RXF_WEN = w_wr_hit_spirdr & REG_WEN & |REG_WBTEN;
assign REG_RXF_REN = w_rd_hit_spirdr & REG_REN;

wire [31:0] w_rd_spirdr;
assign w_rd_spirdr = (r_rxf_rd_en_retim[1]) ?
                     {{32-SC_QSPIM_DT_B_WIDTH*8-`SPIRXDATA{1'b0}}, REG_RXF_RDATA, {`SPIRXDATA{1'b0}}} :
                     32'h0;

// SPI Access Status Register
//----------------------------------------------
wire [31:0] w_rd_spiasr;
assign w_rd_spiasr = (w_rd_hit_spiasr & REG_REN) ?
                     {{32-1-`SPIBUSY{1'b0}}, REG_SPIBUSY, {`SPIBUSY{1'b0}}} :
                     32'h0;

// SPI FIFO Status Register
//----------------------------------------------
wire [31:0] w_rd_spififosr;
assign w_rd_spififosr = (w_rd_hit_spififosr & REG_REN) ?
                     {{32-SC_QSPIM_FIFO_DEPTH-1-`TXFIFOCAP{1'b0}}, REG_TXF_CAP, {`TXFIFOCAP{1'b0}}} |
                     {{32-SC_QSPIM_FIFO_DEPTH-1-`RXFIFOCAP{1'b0}}, REG_RXF_CAP, {`RXFIFOCAP{1'b0}}} :
                     32'h0;

// SPI FIFO Reset Register
//----------------------------------------------
always @ (posedge SYSCLK or negedge SYSRST_N) begin
  if (!SYSRST_N) begin
    REG_TXF_RST <= 0;
    REG_RXF_RST <= 0;
  end else begin
    REG_TXF_RST <= 0;
    REG_RXF_RST <= 0;
    if (w_wr_hit_spififorr & REG_WEN) begin
      if (REG_WBTEN[0]) begin
        REG_TXF_RST <= REG_WDATA[`TXFIFORST];
        REG_RXF_RST <= REG_WDATA[`RXFIFORST];
      end
    end
  end
end

// SPI Interrput Status Register
//----------------------------------------------
reg r_int_txf_uth;
reg r_int_txf_ovf;
reg r_int_txf_udf;
reg r_int_rxf_oth;
reg r_int_rxf_ovf;
reg r_int_rxf_udf;
reg r_int_sctl_dn;
always @ (posedge SYSCLK or negedge SYSRST_N) begin
  if (!SYSRST_N) begin
    r_int_txf_uth <= 0;
    r_int_txf_ovf <= 0;
    r_int_txf_udf <= 0;
    r_int_rxf_oth <= 0;
    r_int_rxf_ovf <= 0;
    r_int_rxf_udf <= 0;
    r_int_sctl_dn <= 0;
  end else begin
    if (w_wr_hit_spiisr & REG_WEN) begin
      if (REG_WBTEN[3]) begin
        if (REG_WDATA[`TXFIFOUTH])
          r_int_txf_uth <= 1'b0;
        if (REG_WDATA[`TXFIFOOVF])
          r_int_txf_ovf <= 1'b0;
        if (REG_WDATA[`TXFIFOUDF])
          r_int_txf_udf <= 1'b0;
      end
      if (REG_WBTEN[2]) begin
        if (REG_WDATA[`RXFIFOOTH])
          r_int_rxf_oth <= 1'b0;
        if (REG_WDATA[`RXFIFOOVF])
          r_int_rxf_ovf <= 1'b0;
        if (REG_WDATA[`RXFIFOUDF])
          r_int_rxf_udf <= 1'b0;
      end
      if (REG_WBTEN[0]) begin
        if (REG_WDATA[`SPICTRLDN])
          r_int_sctl_dn <= 1'b0;
      end
    end
    if (REG_INT_TXF_UTH)
      r_int_txf_uth <= 1'b1;
    if (REG_INT_TXF_OVF)
      r_int_txf_ovf <= 1'b1;
    if (REG_INT_TXF_UDF)
      r_int_txf_udf <= 1'b1;
    if (REG_INT_RXF_OTH)
      r_int_rxf_oth <= 1'b1;
    if (REG_INT_RXF_OVF)
      r_int_rxf_ovf <= 1'b1;
    if (REG_INT_RXF_UDF)
      r_int_rxf_udf <= 1'b1;
    if (REG_INT_SCTL_DN)
      r_int_sctl_dn <= 1'b1;
  end
end

wire [31:0] w_rd_spiisr;
assign w_rd_spiisr = (w_rd_hit_spiisr & REG_REN) ?
                     {{32-1-`TXFIFOUTH{1'b0}}, r_int_txf_uth, {`TXFIFOUTH{1'b0}}} |
                     {{32-1-`TXFIFOOVF{1'b0}}, r_int_txf_ovf, {`TXFIFOOVF{1'b0}}} |
                     {{32-1-`TXFIFOUDF{1'b0}}, r_int_txf_udf, {`TXFIFOUDF{1'b0}}} |
                     {{32-1-`RXFIFOOTH{1'b0}}, r_int_rxf_oth, {`RXFIFOOTH{1'b0}}} |
                     {{32-1-`RXFIFOOVF{1'b0}}, r_int_rxf_ovf, {`RXFIFOOVF{1'b0}}} |
                     {{32-1-`RXFIFOUDF{1'b0}}, r_int_rxf_udf, {`RXFIFOUDF{1'b0}}} |
                     {{32-1-`SPICTRLDN{1'b0}}, r_int_sctl_dn, {`SPICTRLDN{1'b0}}} :
                     32'h0;

// SPI Interrupt Enable Register
//----------------------------------------------
reg r_enb_txf_uth;
reg r_enb_txf_ovf;
reg r_enb_txf_udf;
reg r_enb_rxf_oth;
reg r_enb_rxf_ovf;
reg r_enb_rxf_udf;
reg r_enb_sctl_dn;
always @ (posedge SYSCLK or negedge SYSRST_N) begin
  if (!SYSRST_N) begin
    r_enb_txf_uth <= 0;
    r_enb_txf_ovf <= 0;
    r_enb_txf_udf <= 0;
    r_enb_rxf_oth <= 0;
    r_enb_rxf_ovf <= 0;
    r_enb_rxf_udf <= 0;
    r_enb_sctl_dn <= 0;
  end else begin
    if (w_wr_hit_spiier & REG_WEN) begin
      if (REG_WBTEN[3]) begin
        r_enb_txf_uth <= REG_WDATA[`TXFIFOUTHEMB];
        r_enb_txf_ovf <= REG_WDATA[`TXFIFOOVFEMB];
        r_enb_txf_udf <= REG_WDATA[`TXFIFOUDFEMB];
      end
      if (REG_WBTEN[2]) begin
        r_enb_rxf_oth <= REG_WDATA[`RXFIFOOTHEMB];
        r_enb_rxf_ovf <= REG_WDATA[`RXFIFOOVFEMB];
        r_enb_rxf_udf <= REG_WDATA[`RXFIFOUDFEMB];
      end
      if (REG_WBTEN[0]) begin
        r_enb_sctl_dn <= REG_WDATA[`SPICTRLDNEMB];
      end
    end
  end
end

wire [31:0] w_rd_spiier;
assign w_rd_spiier = (w_rd_hit_spiier & REG_REN) ?
                     {{32-1-`TXFIFOUTHEMB{1'b0}}, r_enb_txf_uth, {`TXFIFOUTHEMB{1'b0}}} |
                     {{32-1-`TXFIFOOVFEMB{1'b0}}, r_enb_txf_ovf, {`TXFIFOOVFEMB{1'b0}}} |
                     {{32-1-`TXFIFOUDFEMB{1'b0}}, r_enb_txf_udf, {`TXFIFOUDFEMB{1'b0}}} |
                     {{32-1-`RXFIFOOTHEMB{1'b0}}, r_enb_rxf_oth, {`RXFIFOOTHEMB{1'b0}}} |
                     {{32-1-`RXFIFOOVFEMB{1'b0}}, r_enb_rxf_ovf, {`RXFIFOOVFEMB{1'b0}}} |
                     {{32-1-`RXFIFOUDFEMB{1'b0}}, r_enb_rxf_udf, {`RXFIFOUDFEMB{1'b0}}} |
                     {{32-1-`SPICTRLDNEMB{1'b0}}, r_enb_sctl_dn, {`SPICTRLDNEMB{1'b0}}} :
                     32'h0;

assign QSPI_INT = (r_int_txf_uth & r_enb_txf_uth) |
                  (r_int_txf_ovf & r_enb_txf_ovf) |
                  (r_int_txf_udf & r_enb_txf_udf) |
                  (r_int_rxf_oth & r_enb_rxf_oth) |
                  (r_int_rxf_ovf & r_enb_rxf_ovf) |
                  (r_int_rxf_udf & r_enb_rxf_udf) |
                  (r_int_sctl_dn & r_enb_sctl_dn) ;

// SPI Clock Control Register
//----------------------------------------------
always @ (posedge SYSCLK or negedge SYSRST_N) begin
  if (!SYSRST_N) begin
    REG_SCKPOL <= 0;
    REG_SCKPHA <= 0;
    REG_SCKDIV <= 0;
  end else begin
    if (w_wr_hit_spiccr & REG_WEN) begin
      if (REG_WBTEN[2]) begin
        REG_SCKPOL <= REG_WDATA[`SCKPOL];
        REG_SCKPHA <= REG_WDATA[`SCKPHA];
      end
      if (REG_WBTEN[1]) begin
        REG_SCKDIV[11:8] <= REG_WDATA[`SCKDIV+8 +: 4];
      end
      if (REG_WBTEN[0]) begin
        REG_SCKDIV[7:0]  <= REG_WDATA[`SCKDIV   +: 8];
      end
    end
  end
end

wire [31:0] w_rd_spiccr;
assign w_rd_spiccr = (w_rd_hit_spiccr & REG_REN) ?
                     {{32-1-`SCKPOL{1'b0}},  REG_SCKPOL, {`SCKPOL{1'b0}}} |
                     {{32-1-`SCKPHA{1'b0}},  REG_SCKPHA, {`SCKPHA{1'b0}}} |
                     {{32-12-`SCKDIV{1'b0}}, REG_SCKDIV, {`SCKDIV{1'b0}}} :
                     32'h0;

// SPI Data Capture Mode Setting Register
//----------------------------------------------
always @ (posedge SYSCLK or negedge SYSRST_N) begin
  if (!SYSRST_N) begin
    REG_DTCAPT <= 0;
  end else begin
    if (w_wr_hit_spidcmsr & REG_WEN) begin
      if (REG_WBTEN[0])
        REG_DTCAPT <= REG_WDATA[`DTCAPT];
    end
  end
end

wire [31:0] w_rd_spidcmsr;
assign w_rd_spidcmsr = (w_rd_hit_spidcmsr & REG_REN) ?
                       {{32-1-`DTCAPT{1'b0}}, REG_DTCAPT, {`DTCAPT{1'b0}}} :
                       32'h0;

// SPI FIFO Threshold Level Setting Register
//----------------------------------------------
generate
  if (SC_QSPIM_FIFO_DEPTH >= 8) begin
    always @ (posedge SYSCLK or negedge SYSRST_N) begin
      if (!SYSRST_N) begin
        REG_TXF_UTHL <= 0;
        REG_RXF_OTHL <= 0;
      end else begin
        if (w_wr_hit_spiftlsr & REG_WEN) begin
          if (REG_WBTEN[3])
            REG_TXF_UTHL[SC_QSPIM_FIFO_DEPTH:8] <= REG_WDATA[`TXFIFOUTHL+8 +: SC_QSPIM_FIFO_DEPTH-8+1];
          if (REG_WBTEN[2])
            REG_TXF_UTHL[7:0]                   <= REG_WDATA[`TXFIFOUTHL +: 8];
          if (REG_WBTEN[1])
            REG_RXF_OTHL[SC_QSPIM_FIFO_DEPTH:8] <= REG_WDATA[`RXFIFOOTHL+8 +: SC_QSPIM_FIFO_DEPTH-8+1];
          if (REG_WBTEN[0])
            REG_RXF_OTHL[7:0]                   <= REG_WDATA[`RXFIFOOTHL +: 8];
        end
      end
    end
  end else begin
    always @ (posedge SYSCLK or negedge SYSRST_N) begin
      if (!SYSRST_N) begin
        REG_TXF_UTHL <= 0;
        REG_RXF_OTHL <= 0;
      end else begin
        if (w_wr_hit_spiftlsr & REG_WEN) begin
          if (REG_WBTEN[2])
            REG_TXF_UTHL[SC_QSPIM_FIFO_DEPTH:0] <= REG_WDATA[`TXFIFOUTHL +: SC_QSPIM_FIFO_DEPTH+1];
          if (REG_WBTEN[0])
            REG_RXF_OTHL[SC_QSPIM_FIFO_DEPTH:0] <= REG_WDATA[`RXFIFOOTHL +: SC_QSPIM_FIFO_DEPTH+1];
        end
      end
    end
  end
endgenerate

wire [31:0] w_rd_spiftlsr;
assign w_rd_spiftlsr = (w_rd_hit_spiftlsr & REG_REN) ?
                       {{32-SC_QSPIM_FIFO_DEPTH-1-`TXFIFOUTHL{1'b0}}, REG_TXF_UTHL, {`TXFIFOUTHL{1'b0}}} |
                       {{32-SC_QSPIM_FIFO_DEPTH-1-`RXFIFOOTHL{1'b0}}, REG_RXF_OTHL, {`RXFIFOOTHL{1'b0}}} :
                       32'h0;

// IP Version Register
//----------------------------------------------
wire [31:0] w_rd_qspiver;
assign w_rd_qspiver = (w_rd_hit_qspiver & REG_REN) ?
                      {{32- 8-`QSPIMAJVER{1'b0}},  `QSPI_MAJVERVAL,  {`QSPIMAJVER{1'b0}}} |
                      {{32- 8-`QSPIMINVER{1'b0}},  `QSPI_MINVERVAL,  {`QSPIMINVER{1'b0}}} |
                      {{32-16-`QSPIPATVER{1'b0}},  `QSPI_PATVERVAL,  {`QSPIPATVER{1'b0}}} :
                      32'h0;

// AXI Read Data
//----------------------------------------------
assign REG_RDATA = w_rd_spiacr |
                   w_rd_spirdr |
                   w_rd_spiasr |
                   w_rd_spififosr |
                   w_rd_spiisr |
                   w_rd_spiier |
                   w_rd_spiccr |
                   w_rd_spidcmsr |
                   w_rd_spiftlsr |
                   w_rd_qspiver ;

endmodule
