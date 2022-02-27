//-----------------------------------------------
// Module: sc_qspim
//  Space Cubics Quad-SPI Master
//-----------------------------------------------
// Copyright © 2020 Space Cubics, LLC.
//-----------------------------------------------
module sc_qspim # (
  parameter SC_QSPIM_AXI_ID_WIDTH = 1,
  parameter SC_QSPIM_DT_B_WIDTH = 1, // Renge: 1-4
  parameter SC_QSPIM_FIFO_DEPTH = 4, // Renge: 1-15
  parameter SC_QSPIM_FIFO_TYPE = 0, // 0: BlockRAM 1: Shift Register
  parameter SC_QSPIM_S_DEV_NUM = 1 // Renge: 1-16
) (
  // System Interface
  input SYSCLK,
  input SYSRST_N,
  input MODULE_RSTN,

  // AXI Slave Interface
  input [SC_QSPIM_AXI_ID_WIDTH-1:0] S_AXI_AWID,
  input [31:0] S_AXI_AWADDR,
  input [7:0] S_AXI_AWLEN,
  input [2:0] S_AXI_AWSIZE,
  input [1:0] S_AXI_AWBURST,
  input S_AXI_AWLOCK,
  input [3:0] S_AXI_AWCACHE,
  input [2:0] S_AXI_AWPROT,
  input S_AXI_AWVALID,
  output S_AXI_AWREADY,
  input [31:0] S_AXI_WDATA,
  input [3:0] S_AXI_WSTRB,
  input S_AXI_WLAST,
  input S_AXI_WVALID,
  output S_AXI_WREADY,
  output [SC_QSPIM_AXI_ID_WIDTH-1:0] S_AXI_BID,
  output [1:0] S_AXI_BRESP,
  output S_AXI_BVALID,
  input S_AXI_BREADY,
  input [SC_QSPIM_AXI_ID_WIDTH-1:0] S_AXI_ARID,
  input [31:0] S_AXI_ARADDR,
  input [7:0] S_AXI_ARLEN,
  input [2:0] S_AXI_ARSIZE,
  input [1:0] S_AXI_ARBURST,
  input S_AXI_ARLOCK,
  input [3:0] S_AXI_ARCACHE,
  input [2:0] S_AXI_ARPROT,
  input S_AXI_ARVALID,
  output S_AXI_ARREADY,
  output [SC_QSPIM_AXI_ID_WIDTH-1:0] S_AXI_RID,
  output [31:0] S_AXI_RDATA,
  output [1:0] S_AXI_RRESP,
  output S_AXI_RLAST,
  output S_AXI_RVALID,
  input S_AXI_RREADY,

  // QSPI Interface
  output QSPI_SCK,
  output [SC_QSPIM_S_DEV_NUM-1:0] QSPI_SS,
  output [3:0] QSPI_OE,
  output [3:0] QSPI_DOUT,
  input [3:0] QSPI_DIN,

  // Interrupt Interface
  output QSPI_INT
);

wire qspi_resetn;

wire w_reg_wen;
wire [31:0] w_reg_waddr;
wire [ 3:0] w_reg_wbten;
wire [31:0] w_reg_wdata;
wire w_reg_ren;
wire [31:0] w_reg_raddr;
wire [31:0] w_reg_rdata;
wire w_reg_rwait;

wire [1:0] w_reg_spiiomode;
wire [SC_QSPIM_S_DEV_NUM-1:0] w_reg_spissctl;
wire w_reg_txf_wen;
wire [SC_QSPIM_DT_B_WIDTH*8-1:0] w_reg_txf_wdata;
wire w_reg_rxf_wen;
wire w_reg_rxf_ren;
wire [SC_QSPIM_DT_B_WIDTH*8-1:0] w_reg_rxf_rdata;
wire w_reg_spibusy;
wire [SC_QSPIM_FIFO_DEPTH:0] w_reg_txf_cap;
wire [SC_QSPIM_FIFO_DEPTH:0] w_reg_rxf_cap;
wire w_reg_txf_rst;
wire w_reg_rxf_rst;
wire w_reg_int_txf_uth;
wire w_reg_int_txf_ovf;
wire w_reg_int_txf_udf;
wire w_reg_int_rxf_oth;
wire w_reg_int_rxf_ovf;
wire w_reg_int_rxf_udf;
wire w_reg_int_sctl_dn;
wire w_reg_sckpol;
wire w_reg_sckpha;
wire [11:0] w_reg_sckdiv;
wire w_reg_dtcapt;
wire [SC_QSPIM_FIFO_DEPTH:0] w_reg_txf_uthl;
wire [SC_QSPIM_FIFO_DEPTH:0] w_reg_rxf_othl;

wire w_main_txf_ren;
wire [SC_QSPIM_DT_B_WIDTH*8+1-1:0] w_main_txf_rdata;
wire w_main_rxf_wen;
wire [SC_QSPIM_DT_B_WIDTH*8-1:0] w_main_rxf_wdata;

assign qspi_resetn = SYSRST_N & MODULE_RSTN;

// AXI Slave
sc_axi_slave # (
  .P_AD_W(32),
  .P_DT_W(32),
  .P_ID_W(SC_QSPIM_AXI_ID_WIDTH)
) axi_slave (
  // AXI Interface
  .S_AXI_ACLK(SYSCLK),             // input
  .S_AXI_ARESETN(qspi_resetn),     // input
  .S_AXI_AWID(S_AXI_AWID),         // input [P_ID_W-1:0]
  .S_AXI_AWADDR(S_AXI_AWADDR),     // input [P_AD_W-1:0]
  .S_AXI_AWLEN(S_AXI_AWLEN),       // input [7:0]
  .S_AXI_AWSIZE(S_AXI_AWSIZE),     // input [2:0]
  .S_AXI_AWBURST(S_AXI_AWBURST),   // input [1:0]
  .S_AXI_AWLOCK(S_AXI_AWLOCK),     // input
  .S_AXI_AWCACHE(S_AXI_AWCACHE),   // input [3:0]
  .S_AXI_AWPROT(S_AXI_AWPROT),     // input [2:0]
  .S_AXI_AWVALID(S_AXI_AWVALID),   // input
  .S_AXI_AWREADY(S_AXI_AWREADY),   // output
  .S_AXI_WDATA(S_AXI_WDATA),       // input [P_DT_W-1:0]
  .S_AXI_WSTRB(S_AXI_WSTRB),       // input [3:0]
  .S_AXI_WLAST(S_AXI_WLAST),       // input
  .S_AXI_WVALID(S_AXI_WVALID),     // input
  .S_AXI_WREADY(S_AXI_WREADY),     // output
  .S_AXI_BID(S_AXI_BID),           // output [P_ID_W-1:0]
  .S_AXI_BRESP(S_AXI_BRESP),       // output [1:0]
  .S_AXI_BVALID(S_AXI_BVALID),     // output
  .S_AXI_BREADY(S_AXI_BREADY),     // input
  .S_AXI_ARID(S_AXI_ARID),         // input [P_ID_W-1:0]
  .S_AXI_ARADDR(S_AXI_ARADDR),     // input [P_AD_W-1:0]
  .S_AXI_ARLEN(S_AXI_ARLEN),       // input [7:0]
  .S_AXI_ARSIZE(S_AXI_ARSIZE),     // input [2:0]
  .S_AXI_ARBURST(S_AXI_ARBURST),   // input [1:0]
  .S_AXI_ARLOCK(S_AXI_ARLOCK),     // input
  .S_AXI_ARCACHE(S_AXI_ARCACHE),   // input [3:0]
  .S_AXI_ARPROT(S_AXI_ARPROT),     // input [2:0]
  .S_AXI_ARVALID(S_AXI_ARVALID),   // input
  .S_AXI_ARREADY(S_AXI_ARREADY),   // output
  .S_AXI_RID(S_AXI_RID),           // output [P_ID_W-1:0]
  .S_AXI_RDATA(S_AXI_RDATA),       // output [P_DT_W-1:0]
  .S_AXI_RRESP(S_AXI_RRESP),       // output [1:0]
  .S_AXI_RLAST(S_AXI_RLAST),       // output
  .S_AXI_RVALID(S_AXI_RVALID),     // output
  .S_AXI_RREADY(S_AXI_RREADY),     // input

  // Register Interface
  .REG_WEN(w_reg_wen),             // output
  .REG_WADDR(w_reg_waddr),         // output [P_AD_W-1:0]
  .REG_WBTEN(w_reg_wbten),         // output [P_DT_W/8-1:0]
  .REG_WDATA(w_reg_wdata),         // output [P_DT_W-1:0]
  .REG_REN(w_reg_ren),             // output
  .REG_RADDR(w_reg_raddr),         // output [P_AD_W-1:0]
  .REG_RDATA(w_reg_rdata),         // input [P_DT_W-1:0]
  .REG_WACCERR(1'b0),              // input
  .REG_RACCERR(1'b0),              // input
  .REG_RWAIT(w_reg_rwait)          // input
);

// QSPI_Register
sc_qspim_reg # (
  .SC_QSPIM_DT_B_WIDTH(SC_QSPIM_DT_B_WIDTH),           // Renge: 1-4
  .SC_QSPIM_FIFO_DEPTH(SC_QSPIM_FIFO_DEPTH),           // Renge: 1-15
  .SC_QSPIM_S_DEV_NUM(SC_QSPIM_S_DEV_NUM)              // Renge: 1-16
) qspim_reg (
  // System Interface
  .SYSCLK(SYSCLK),                                     // input
  .SYSRST_N(qspi_resetn),                              // input

  // AXI Slave Interface
  .REG_WEN(w_reg_wen),                                 // input
  .REG_WADDR(w_reg_waddr),                             // input [31:0]
  .REG_WBTEN(w_reg_wbten),                             // input [3:0]
  .REG_WDATA(w_reg_wdata),                             // input [31:0]
  .REG_REN(w_reg_ren),                                 // input
  .REG_RADDR(w_reg_raddr),                             // input [31:0]
  .REG_RDATA(w_reg_rdata),                             // output [31:0]
  .REG_RWAIT(w_reg_rwait),                             // output

  // QSPI Main Controller Interface
  .REG_SPIIOMODE(w_reg_spiiomode),                     // output [1:0]
  .REG_SPISSCTL(w_reg_spissctl),                       // output [SC_QSPIM_S_DEV_NUM-1:0]
  .REG_TXF_WEN(w_reg_txf_wen),                         // output
  .REG_TXF_WDATA(w_reg_txf_wdata),                     // output [SC_QSPIM_DT_B_WIDTH*8-1:0]
  .REG_RXF_WEN(w_reg_rxf_wen),                         // output
  .REG_RXF_REN(w_reg_rxf_ren),                         // output
  .REG_RXF_RDATA(w_reg_rxf_rdata),                     // input [SC_QSPIM_DT_B_WIDTH*8-1:0]
  .REG_SPIBUSY(w_reg_spibusy),                         // input
  .REG_TXF_CAP(w_reg_txf_cap),                         // input [SC_QSPIM_FIFO_DEPTH:0]
  .REG_RXF_CAP(w_reg_rxf_cap),                         // input [SC_QSPIM_FIFO_DEPTH:0]
  .REG_TXF_RST(w_reg_txf_rst),                         // output
  .REG_RXF_RST(w_reg_rxf_rst),                         // output
  .REG_INT_TXF_UTH(w_reg_int_txf_uth),                 // input
  .REG_INT_TXF_OVF(w_reg_int_txf_ovf),                 // input
  .REG_INT_TXF_UDF(w_reg_int_txf_udf),                 // input
  .REG_INT_RXF_OTH(w_reg_int_rxf_oth),                 // input
  .REG_INT_RXF_OVF(w_reg_int_rxf_ovf),                 // input
  .REG_INT_RXF_UDF(w_reg_int_rxf_udf),                 // input
  .REG_INT_SCTL_DN(w_reg_int_sctl_dn),                 // input
  .REG_SCKPOL(w_reg_sckpol),                           // output
  .REG_SCKPHA(w_reg_sckpha),                           // output
  .REG_SCKDIV(w_reg_sckdiv),                           // output [11:0]
  .REG_DTCAPT(w_reg_dtcapt),                           // output
  .REG_TXF_UTHL(w_reg_txf_uthl),                       // output [SC_QSPIM_FIFO_DEPTH:0]
  .REG_RXF_OTHL(w_reg_rxf_othl),                       // output [SC_QSPIM_FIFO_DEPTH:0]

  // Interrupt Interface
  .QSPI_INT(QSPI_INT)                                  // output
);

// TX_FIFO
sc_fifo # (
  .P_FIFO_WIDTH(SC_QSPIM_DT_B_WIDTH*8+1),
  .P_FIFO_DEPTH(SC_QSPIM_FIFO_DEPTH),
  .P_FIFO_TYPE(SC_QSPIM_FIFO_TYPE)                 // 0: BlockRAM 1: Shift Register
) tx_fifo (
  .CLK(SYSCLK),                                    // input
  .SRST_N(qspi_resetn),                            // input
  .FIFO_RST(w_reg_txf_rst),                        // input

  .WR_EN(w_reg_txf_wen | w_reg_rxf_wen),           // input
  .DIN({w_reg_rxf_wen, w_reg_txf_wdata}),          // input [P_FIFO_WIDTH-1:0]
  .RD_EN(w_main_txf_ren),                          // input
  .DOUT(w_main_txf_rdata),                         // output [P_FIFO_WIDTH-1:0]

  .OVER_TH_LVL({SC_QSPIM_FIFO_DEPTH+1{1'b0}}),     // input [P_FIFO_DEPTH:0]
  .UNDER_TH_LVL(w_reg_txf_uthl),                   // input [P_FIFO_DEPTH:0]

  .FULL(/* open */),                               // output
  .EMPTY(/* open */),                              // output
  .OVERFLOW(w_reg_int_txf_ovf),                    // output
  .UNDERFLOW(w_reg_int_txf_udf),                   // output
  .OVER_TH(/* open */),                            // output
  .UNDER_TH(w_reg_int_txf_uth),                    // output
  .DATA_COUNT(w_reg_txf_cap)                       // output [P_FIFO_DEPTH:0]
);

// RX_FIFO
sc_fifo # (
  .P_FIFO_WIDTH(SC_QSPIM_DT_B_WIDTH*8),
  .P_FIFO_DEPTH(SC_QSPIM_FIFO_DEPTH),
  .P_FIFO_TYPE(SC_QSPIM_FIFO_TYPE)                 // 0: BlockRAM 1: Shift Register
) rx_fifo (
  .CLK(SYSCLK),                                    // input
  .SRST_N(qspi_resetn),                            // input
  .FIFO_RST(w_reg_rxf_rst),                        // input

  .WR_EN(w_main_rxf_wen),                          // input
  .DIN(w_main_rxf_wdata),                          // input [P_FIFO_WIDTH-1:0]
  .RD_EN(w_reg_rxf_ren),                           // input
  .DOUT(w_reg_rxf_rdata),                          // output [P_FIFO_WIDTH-1:0]

  .OVER_TH_LVL(w_reg_rxf_othl),                    // input [P_FIFO_DEPTH:0]
  .UNDER_TH_LVL({SC_QSPIM_FIFO_DEPTH+1{1'b0}}),    // input [P_FIFO_DEPTH:0]

  .FULL(/* open */),                               // output
  .EMPTY(/* open */),                              // output
  .OVERFLOW(w_reg_int_rxf_ovf),                    // output
  .UNDERFLOW(w_reg_int_rxf_udf),                   // output
  .OVER_TH(w_reg_int_rxf_oth),                     // output
  .UNDER_TH(/* open */),                           // output
  .DATA_COUNT(w_reg_rxf_cap)                       // output [P_FIFO_DEPTH:0]
);

// QSPI Core Controller
sc_qspim_core # (
  .SC_QSPIM_DT_B_WIDTH(SC_QSPIM_DT_B_WIDTH),           // Renge: 1-4
  .SC_QSPIM_FIFO_DEPTH(SC_QSPIM_FIFO_DEPTH),           // Renge: 1-15
  .SC_QSPIM_S_DEV_NUM(SC_QSPIM_S_DEV_NUM)              // Renge: 1-16
) qspim_core (
  // System Interface
  .SYSCLK(SYSCLK),                                     // input
  .SYSRST_N(qspi_resetn),                              // input

  // Register Interface
  .REG_SPIIOMODE(w_reg_spiiomode),                     // input [1:0]
  .REG_SPISSCTL(w_reg_spissctl),                       // input [SC_QSPIM_S_DEV_NUM-1:0]
  .REG_SCKPOL(w_reg_sckpol),                           // input
  .REG_SCKPHA(w_reg_sckpha),                           // input
  .REG_SCKDIV(w_reg_sckdiv),                           // input [11:0]
  .REG_DTCAPT(w_reg_dtcapt),                           // input
  .REG_SPIBUSY(w_reg_spibusy),                         // output
  .REG_INT_SCTL_DN(w_reg_int_sctl_dn),                 // output

  // FIFO Interface
  .TX_FIFO_REN(w_main_txf_ren),                        // output
  .TX_FIFO_RDATA(w_main_txf_rdata),                    // input [SC_QSPIM_DT_B_WIDTH*8+1-1:0]
  .TX_FIFO_DCOUNT(w_reg_txf_cap),                      // input [SC_QSPIM_FIFO_DEPTH:0]
  .RX_FIFO_WEN(w_main_rxf_wen),                        // output
  .RX_FIFO_WDATA(w_main_rxf_wdata),                    // output [SC_QSPIM_DT_B_WIDTH*8-1:0]

  // FLASH QSPI Interface
  .QSPI_SS(QSPI_SS),                                   // output [SC_QSPIM_S_DEV_NUM-1:0]
  .QSPI_SCK(QSPI_SCK),                                 // output
  .QSPI_OE(QSPI_OE),                                   // output [3:0]
  .QSPI_DOUT(QSPI_DOUT),                               // output [3:0]
  .QSPI_DIN(QSPI_DIN)                                  // input [3:0]
);

endmodule
