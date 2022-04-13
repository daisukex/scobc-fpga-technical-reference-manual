//-----------------------------------------------
// Module: sc_can_reg_wrap
//  Space Cubics CAN Controller Register Wrapper
//-----------------------------------------------
// Copyright © 2021 Space Cubics, LLC.
//-----------------------------------------------
module sc_can_reg_wrap # (
  parameter SC_CAN_AXI_ID_WIDTH = 1,
  parameter SC_CAN_CLK_ASYNC    = 1 // 1: Two Phase Asynchronous 0: Single Phase Synchronous
) (
  // System Interface
  input S_AXI_ARESETN,
  input S_AXI_ACLK,
  input CAN_RSTB,
  input CAN_CLK,

  // AXI Slave Interface
  input [SC_CAN_AXI_ID_WIDTH-1:0] S_AXI_AWID,
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
  output [SC_CAN_AXI_ID_WIDTH-1:0] S_AXI_BID,
  output [1:0] S_AXI_BRESP,
  output S_AXI_BVALID,
  input S_AXI_BREADY,
  input [SC_CAN_AXI_ID_WIDTH-1:0] S_AXI_ARID,
  input [31:0] S_AXI_ARADDR,
  input [7:0] S_AXI_ARLEN,
  input [2:0] S_AXI_ARSIZE,
  input [1:0] S_AXI_ARBURST,
  input S_AXI_ARLOCK,
  input [3:0] S_AXI_ARCACHE,
  input [2:0] S_AXI_ARPROT,
  input S_AXI_ARVALID,
  output S_AXI_ARREADY,
  output [SC_CAN_AXI_ID_WIDTH-1:0] S_AXI_RID,
  output [31:0] S_AXI_RDATA,
  output [1:0] S_AXI_RRESP,
  output S_AXI_RLAST,
  output S_AXI_RVALID,
  input S_AXI_RREADY,

  // CAN Core Enable Signal
  output REG_CAN_EN,

  // Bit Timing Generator Interface
  output [15:0] REG_TQPDIV,
  output [3:0] REG_TS1,
  output [2:0] REG_TS2,
  output [1:0] REG_SJW,

  // Bit Stream Processor Interface
  output [3:0] REG_ACF_EN,
  output [31:0] REG_ACF1_ID_MASK,
  output [31:0] REG_ACF1_ID_VAL,
  output [31:0] REG_ACF2_ID_MASK,
  output [31:0] REG_ACF2_ID_VAL,
  output [31:0] REG_ACF3_ID_MASK,
  output [31:0] REG_ACF3_ID_VAL,
  output [31:0] REG_ACF4_ID_MASK,
  output [31:0] REG_ACF4_ID_VAL,
  output REG_SELF_TMODE,
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
  output [31:0] REG_TXF1_WDATA,
  output REG_TXF2_WEN,
  output [3:0] REG_TXF2_WDATA,
  output REG_TXF3_WEN,
  output [31:0] REG_TXF3_WDATA,
  output REG_TXF4_WEN,
  output [31:0] REG_TXF4_WDATA,
  output REG_TXF_RST,
  input REG_INT_TXFOVF,

  // TX High Priority Message Buffer Interface
  output REG_TXHPB1_WEN,
  output [31:0] REG_TXHPB1_WDATA,
  output REG_TXHPB2_WEN,
  output [3:0] REG_TXHPB2_WDATA,
  output REG_TXHPB3_WEN,
  output [31:0] REG_TXHPB3_WDATA,
  output REG_TXHPB4_WEN,
  output [31:0] REG_TXHPB4_WDATA,
  output REG_TXHPB_RST,
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
  output REG_RXF_RST,
  input REG_INT_RXFOVF,
  input REG_INT_RXFUDF,

  // CAN Transceiver Interface
  output REG_PHY_SLEEP_EN,

  // Interrupt Signal
  output CAN_INT
);

wire w_reg_wen;
wire [31:0] w_reg_waddr;
wire [3:0] w_reg_wbten;
wire [31:0] w_reg_wdata;
wire w_reg_ren;
wire [31:0] w_reg_raddr;
wire [31:0] w_reg_rdata;
wire w_reg_rwait;

wire w_reg_can_en;
wire [15:0] w_reg_tqpdiv;
wire [3:0] w_reg_ts1;
wire [2:0] w_reg_ts2;
wire [1:0] w_reg_sjw;
wire [3:0] w_reg_acf_en;
wire [31:0] w_reg_acf1_id_mask;
wire [31:0] w_reg_acf1_id_val;
wire [31:0] w_reg_acf2_id_mask;
wire [31:0] w_reg_acf2_id_val;
wire [31:0] w_reg_acf3_id_mask;
wire [31:0] w_reg_acf3_id_val;
wire [31:0] w_reg_acf4_id_mask;
wire [31:0] w_reg_acf4_id_val;
wire w_reg_self_tmode;
wire [7:0] w_reg_tx_ecnt_sync;
wire [7:0] w_reg_rx_ecnt_sync;
wire w_reg_bus_busy_sync;
wire w_reg_errwrn_sync;
wire [1:0] w_reg_err_sts_sync;
wire w_reg_txf_nempty_sync;
wire w_reg_int_trnsdn_sync;
wire w_reg_int_arblst_sync;
wire w_reg_int_rcvdn_sync;
wire w_reg_int_crcer_sync;
wire w_reg_int_fmer_sync;
wire w_reg_int_stfer_sync;
wire w_reg_int_biter_sync;
wire w_reg_int_acker_sync;
wire w_reg_int_busoff_sync;
wire w_reg_txhpb1_wen;
wire [31:0] w_reg_txhpb1_wdata;
wire w_reg_txhpb2_wen;
wire [3:0] w_reg_txhpb2_wdata;
wire w_reg_txhpb3_wen;
wire [31:0] w_reg_txhpb3_wdata;
wire w_reg_txhpb4_wen;
wire [31:0] w_reg_txhpb4_wdata;
wire w_reg_txhpb_rst;
wire w_reg_txhpb_full_sync;
wire w_reg_int_txhbovf_sync;
wire w_reg_rxf_rst;
wire w_reg_int_rxfovf_sync;

// AXI Slave
sc_axi_slave # (
  .P_AD_W(32),
  .P_DT_W(32),
  .P_ID_W(SC_CAN_AXI_ID_WIDTH)
) axi_slave (
  // AXI Interface
  .S_AXI_ACLK(S_AXI_ACLK),         // input
  .S_AXI_ARESETN(S_AXI_ARESETN),   // input
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

// CAN Register
sc_can_reg can_reg (
  // System Interface
  .SYSCLK(S_AXI_ACLK),                       // input
  .SYSRST_N(S_AXI_ARESETN),                  // input

  // AXI Slave Interface
  .REG_WEN(w_reg_wen),                       // input
  .REG_WADDR(w_reg_waddr),                   // input [31:0]
  .REG_WBTEN(w_reg_wbten),                   // input [3:0]
  .REG_WDATA(w_reg_wdata),                   // input [31:0]
  .REG_REN(w_reg_ren),                       // input
  .REG_RADDR(w_reg_raddr),                   // input [31:0]
  .REG_RDATA(w_reg_rdata),                   // output [31:0]
  .REG_RWAIT(w_reg_rwait),                   // output

  // CAN Core Enable Signal
  .REG_CAN_EN(w_reg_can_en),                 // output

  // Bit Timing Generator Interface
  .REG_TQPDIV(w_reg_tqpdiv),                 // output [15:0]
  .REG_TS1(w_reg_ts1),                       // output [3:0]
  .REG_TS2(w_reg_ts2),                       // output [2:0]
  .REG_SJW(w_reg_sjw),                       // output [1:0]

  // Bit Stream Processor Interface
  .REG_ACF_EN(w_reg_acf_en),                 // output [3:0]
  .REG_ACF1_ID_MASK(w_reg_acf1_id_mask),     // output [31:0]
  .REG_ACF1_ID_VAL(w_reg_acf1_id_val),       // output [31:0]
  .REG_ACF2_ID_MASK(w_reg_acf2_id_mask),     // output [31:0]
  .REG_ACF2_ID_VAL(w_reg_acf2_id_val),       // output [31:0]
  .REG_ACF3_ID_MASK(w_reg_acf3_id_mask),     // output [31:0]
  .REG_ACF3_ID_VAL(w_reg_acf3_id_val),       // output [31:0]
  .REG_ACF4_ID_MASK(w_reg_acf4_id_mask),     // output [31:0]
  .REG_ACF4_ID_VAL(w_reg_acf4_id_val),       // output [31:0]
  .REG_SELF_TMODE(w_reg_self_tmode),         // output
  .REG_TX_ECNT(w_reg_tx_ecnt_sync),          // input [7:0]
  .REG_RX_ECNT(w_reg_rx_ecnt_sync),          // input [7:0]
  .REG_BUS_BUSY(w_reg_bus_busy_sync),        // input
  .REG_ERRWRN(w_reg_errwrn_sync),            // input
  .REG_ERR_STS(w_reg_err_sts_sync),          // input [1:0]
  .REG_TXF_NEMPTY(w_reg_txf_nempty_sync),    // input
  .REG_TXF_FULL(REG_TXF_FULL),               // input
  .REG_RXF_FULL(REG_RXF_FULL),               // input
  .REG_INT_TRNSDN(w_reg_int_trnsdn_sync),    // input
  .REG_INT_ARBLST(w_reg_int_arblst_sync),    // input
  .REG_INT_RCVDN(w_reg_int_rcvdn_sync),      // input
  .REG_INT_RXFVAL(REG_INT_RXFVAL),           // input
  .REG_INT_CRCER(w_reg_int_crcer_sync),      // input
  .REG_INT_FMER(w_reg_int_fmer_sync),        // input
  .REG_INT_STFER(w_reg_int_stfer_sync),      // input
  .REG_INT_BITER(w_reg_int_biter_sync),      // input
  .REG_INT_ACKER(w_reg_int_acker_sync),      // input
  .REG_INT_BUSOFF(w_reg_int_busoff_sync),    // input

  // TX Message FIFO Interface
  .REG_TXF1_WEN(REG_TXF1_WEN),               // output
  .REG_TXF1_WDATA(REG_TXF1_WDATA),           // output [31:0]
  .REG_TXF2_WEN(REG_TXF2_WEN),               // output
  .REG_TXF2_WDATA(REG_TXF2_WDATA),           // output [3:0]
  .REG_TXF3_WEN(REG_TXF3_WEN),               // output
  .REG_TXF3_WDATA(REG_TXF3_WDATA),           // output [31:0]
  .REG_TXF4_WEN(REG_TXF4_WEN),               // output
  .REG_TXF4_WDATA(REG_TXF4_WDATA),           // output [31:0]
  .REG_TXF_RST(REG_TXF_RST),                 // output
  .REG_INT_TXFOVF(REG_INT_TXFOVF),           // input

  // TX High Priority Message Buffer Interface
  .REG_TXHPB1_WEN(w_reg_txhpb1_wen),         // output
  .REG_TXHPB1_WDATA(w_reg_txhpb1_wdata),     // output [31:0]
  .REG_TXHPB2_WEN(w_reg_txhpb2_wen),         // output
  .REG_TXHPB2_WDATA(w_reg_txhpb2_wdata),     // output [3:0]
  .REG_TXHPB3_WEN(w_reg_txhpb3_wen),         // output
  .REG_TXHPB3_WDATA(w_reg_txhpb3_wdata),     // output [31:0]
  .REG_TXHPB4_WEN(w_reg_txhpb4_wen),         // output
  .REG_TXHPB4_WDATA(w_reg_txhpb4_wdata),     // output [31:0]
  .REG_TXHPB_RST(w_reg_txhpb_rst),           // output
  .REG_TXHPB_FULL(w_reg_txhpb_full_sync),    // input
  .REG_INT_TXHBOVF(w_reg_int_txhbovf_sync),  // input

  // RX Message FIFO Interface
  .REG_RXF1_REN(REG_RXF1_REN),               // output
  .REG_RXF1_RDATA(REG_RXF1_RDATA),           // input [31:0]
  .REG_RXF2_REN(REG_RXF2_REN),               // output
  .REG_RXF2_RDATA(REG_RXF2_RDATA),           // input [3:0]
  .REG_RXF3_REN(REG_RXF3_REN),               // output
  .REG_RXF3_RDATA(REG_RXF3_RDATA),           // input [31:0]
  .REG_RXF4_REN(REG_RXF4_REN),               // output
  .REG_RXF4_RDATA(REG_RXF4_RDATA),           // input [31:0]
  .REG_RXF_RST(w_reg_rxf_rst),               // output
  .REG_INT_RXFOVF(w_reg_int_rxfovf_sync),    // input
  .REG_INT_RXFUDF(REG_INT_RXFUDF),           // input

  // CAN Transceiver Interface
  .REG_PHY_SLEEP_EN(REG_PHY_SLEEP_EN),       // output

  // Interrupt Signal
  .CAN_INT(CAN_INT)                          // output
);

generate
  if (SC_CAN_CLK_ASYNC) begin

    // CAN Register Signal Clock Converter
    sc_can_reg_clk_conv can_reg_clk_conv (
      .REG_RSTB(S_AXI_ARESETN),                       // input
      .REG_CLK(S_AXI_ACLK),                           // input
      .CAN_RSTB(CAN_RSTB),                            // input
      .CAN_CLK(CAN_CLK),                              // input

      // Register Interface
      .REG_CAN_EN(w_reg_can_en),                      // input
      .REG_TQPDIV(w_reg_tqpdiv),                      // input [15:0]
      .REG_TS1(w_reg_ts1),                            // input [3:0]
      .REG_TS2(w_reg_ts2),                            // input [2:0]
      .REG_SJW(w_reg_sjw),                            // input [1:0]
      .REG_ACF_EN(w_reg_acf_en),                      // input [3:0]
      .REG_ACF1_ID_MASK(w_reg_acf1_id_mask),          // input [31:0]
      .REG_ACF1_ID_VAL(w_reg_acf1_id_val),            // input [31:0]
      .REG_ACF2_ID_MASK(w_reg_acf2_id_mask),          // input [31:0]
      .REG_ACF2_ID_VAL(w_reg_acf2_id_val),            // input [31:0]
      .REG_ACF3_ID_MASK(w_reg_acf3_id_mask),          // input [31:0]
      .REG_ACF3_ID_VAL(w_reg_acf3_id_val),            // input [31:0]
      .REG_ACF4_ID_MASK(w_reg_acf4_id_mask),          // input [31:0]
      .REG_ACF4_ID_VAL(w_reg_acf4_id_val),            // input [31:0]
      .REG_SELF_TMODE(w_reg_self_tmode),              // input
      .REG_TX_ECNT_SYNC(w_reg_tx_ecnt_sync),          // output [7:0]
      .REG_RX_ECNT_SYNC(w_reg_rx_ecnt_sync),          // output [7:0]
      .REG_BUS_BUSY_SYNC(w_reg_bus_busy_sync),        // output
      .REG_ERRWRN_SYNC(w_reg_errwrn_sync),            // output
      .REG_ERR_STS_SYNC(w_reg_err_sts_sync),          // output [1:0]
      .REG_TXF_NEMPTY_SYNC(w_reg_txf_nempty_sync),    // output
      .REG_INT_TRNSDN_SYNC(w_reg_int_trnsdn_sync),    // output
      .REG_INT_ARBLST_SYNC(w_reg_int_arblst_sync),    // output
      .REG_INT_RCVDN_SYNC(w_reg_int_rcvdn_sync),      // output
      .REG_INT_CRCER_SYNC(w_reg_int_crcer_sync),      // output
      .REG_INT_FMER_SYNC(w_reg_int_fmer_sync),        // output
      .REG_INT_STFER_SYNC(w_reg_int_stfer_sync),      // output
      .REG_INT_BITER_SYNC(w_reg_int_biter_sync),      // output
      .REG_INT_ACKER_SYNC(w_reg_int_acker_sync),      // output
      .REG_INT_BUSOFF_SYNC(w_reg_int_busoff_sync),    // output
      .REG_TXHPB1_WEN(w_reg_txhpb1_wen),              // input
      .REG_TXHPB1_WDATA(w_reg_txhpb1_wdata),          // input [31:0]
      .REG_TXHPB2_WEN(w_reg_txhpb2_wen),              // input
      .REG_TXHPB2_WDATA(w_reg_txhpb2_wdata),          // input [3:0]
      .REG_TXHPB3_WEN(w_reg_txhpb3_wen),              // input
      .REG_TXHPB3_WDATA(w_reg_txhpb3_wdata),          // input [31:0]
      .REG_TXHPB4_WEN(w_reg_txhpb4_wen),              // input
      .REG_TXHPB4_WDATA(w_reg_txhpb4_wdata),          // input [31:0]
      .REG_TXHPB_RST(w_reg_txhpb_rst),                // input
      .REG_TXHPB_FULL_SYNC(w_reg_txhpb_full_sync),    // output
      .REG_INT_TXHBOVF_SYNC(w_reg_int_txhbovf_sync),  // output
      .REG_RXF_RST(w_reg_rxf_rst),                    // input
      .REG_INT_RXFOVF_SYNC(w_reg_int_rxfovf_sync),    // output

      // CAN Core Interface
      .REG_CAN_EN_SYNC(REG_CAN_EN),                   // output
      .REG_TQPDIV_SYNC(REG_TQPDIV),                   // output [15:0]
      .REG_TS1_SYNC(REG_TS1),                         // output [3:0]
      .REG_TS2_SYNC(REG_TS2),                         // output [2:0]
      .REG_SJW_SYNC(REG_SJW),                         // output [1:0]
      .REG_ACF_EN_SYNC(REG_ACF_EN),                   // output [3:0]
      .REG_ACF1_ID_MASK_SYNC(REG_ACF1_ID_MASK),       // output [31:0]
      .REG_ACF1_ID_VAL_SYNC(REG_ACF1_ID_VAL),         // output [31:0]
      .REG_ACF2_ID_MASK_SYNC(REG_ACF2_ID_MASK),       // output [31:0]
      .REG_ACF2_ID_VAL_SYNC(REG_ACF2_ID_VAL),         // output [31:0]
      .REG_ACF3_ID_MASK_SYNC(REG_ACF3_ID_MASK),       // output [31:0]
      .REG_ACF3_ID_VAL_SYNC(REG_ACF3_ID_VAL),         // output [31:0]
      .REG_ACF4_ID_MASK_SYNC(REG_ACF4_ID_MASK),       // output [31:0]
      .REG_ACF4_ID_VAL_SYNC(REG_ACF4_ID_VAL),         // output [31:0]
      .REG_SELF_TMODE_SYNC(REG_SELF_TMODE),           // output
      .REG_TX_ECNT(REG_TX_ECNT),                      // input [7:0]
      .REG_RX_ECNT(REG_RX_ECNT),                      // input [7:0]
      .REG_BUS_BUSY(REG_BUS_BUSY),                    // input
      .REG_ERRWRN(REG_ERRWRN),                        // input
      .REG_ERR_STS(REG_ERR_STS),                      // input [1:0]
      .REG_TXF_NEMPTY(REG_TXF_NEMPTY),                // input
      .REG_INT_TRNSDN(REG_INT_TRNSDN),                // input
      .REG_INT_ARBLST(REG_INT_ARBLST),                // input
      .REG_INT_RCVDN(REG_INT_RCVDN),                  // input
      .REG_INT_CRCER(REG_INT_CRCER),                  // input
      .REG_INT_FMER(REG_INT_FMER),                    // input
      .REG_INT_STFER(REG_INT_STFER),                  // input
      .REG_INT_BITER(REG_INT_BITER),                  // input
      .REG_INT_ACKER(REG_INT_ACKER),                  // input
      .REG_INT_BUSOFF(REG_INT_BUSOFF),                // input
      .REG_TXHPB1_WEN_SYNC(REG_TXHPB1_WEN),           // output
      .REG_TXHPB1_WDATA_SYNC(REG_TXHPB1_WDATA),       // output [31:0]
      .REG_TXHPB2_WEN_SYNC(REG_TXHPB2_WEN),           // output
      .REG_TXHPB2_WDATA_SYNC(REG_TXHPB2_WDATA),       // output [3:0]
      .REG_TXHPB3_WEN_SYNC(REG_TXHPB3_WEN),           // output
      .REG_TXHPB3_WDATA_SYNC(REG_TXHPB3_WDATA),       // output [31:0]
      .REG_TXHPB4_WEN_SYNC(REG_TXHPB4_WEN),           // output
      .REG_TXHPB4_WDATA_SYNC(REG_TXHPB4_WDATA),       // output [31:0]
      .REG_TXHPB_RST_SYNC(REG_TXHPB_RST),             // output
      .REG_TXHPB_FULL(REG_TXHPB_FULL),                // input
      .REG_INT_TXHBOVF(REG_INT_TXHBOVF),              // input
      .REG_RXF_RST_SYNC(REG_RXF_RST),                 // output
      .REG_INT_RXFOVF(REG_INT_RXFOVF)                 // input
    );

  end else begin

    assign REG_CAN_EN = w_reg_can_en;
    assign REG_TQPDIV = w_reg_tqpdiv;
    assign REG_TS1 = w_reg_ts1;
    assign REG_TS2 = w_reg_ts2;
    assign REG_SJW = w_reg_sjw;
    assign REG_ACF_EN = w_reg_acf_en;
    assign REG_ACF1_ID_MASK = w_reg_acf1_id_mask;
    assign REG_ACF1_ID_VAL = w_reg_acf1_id_val;
    assign REG_ACF2_ID_MASK = w_reg_acf2_id_mask;
    assign REG_ACF2_ID_VAL = w_reg_acf2_id_val;
    assign REG_ACF3_ID_MASK = w_reg_acf3_id_mask;
    assign REG_ACF3_ID_VAL = w_reg_acf3_id_val;
    assign REG_ACF4_ID_MASK = w_reg_acf4_id_mask;
    assign REG_ACF4_ID_VAL = w_reg_acf4_id_val;
    assign REG_SELF_TMODE = w_reg_self_tmode;
    assign w_reg_tx_ecnt_sync = REG_TX_ECNT;
    assign w_reg_rx_ecnt_sync = REG_RX_ECNT;
    assign w_reg_bus_busy_sync = REG_BUS_BUSY;
    assign w_reg_errwrn_sync = REG_ERRWRN;
    assign w_reg_err_sts_sync = REG_ERR_STS;
    assign w_reg_txf_nempty_sync = REG_TXF_NEMPTY;
    assign w_reg_int_trnsdn_sync = REG_INT_TRNSDN;
    assign w_reg_int_arblst_sync = REG_INT_ARBLST;
    assign w_reg_int_rcvdn_sync = REG_INT_RCVDN;
    assign w_reg_int_crcer_sync = REG_INT_CRCER;
    assign w_reg_int_fmer_sync = REG_INT_FMER;
    assign w_reg_int_stfer_sync = REG_INT_STFER;
    assign w_reg_int_biter_sync = REG_INT_BITER;
    assign w_reg_int_acker_sync = REG_INT_ACKER;
    assign w_reg_int_busoff_sync = REG_INT_BUSOFF;
    assign REG_TXHPB1_WEN = w_reg_txhpb1_wen;
    assign REG_TXHPB1_WDATA = w_reg_txhpb1_wdata;
    assign REG_TXHPB2_WEN = w_reg_txhpb2_wen;
    assign REG_TXHPB2_WDATA = w_reg_txhpb2_wdata;
    assign REG_TXHPB3_WEN = w_reg_txhpb3_wen;
    assign REG_TXHPB3_WDATA = w_reg_txhpb3_wdata;
    assign REG_TXHPB4_WEN = w_reg_txhpb4_wen;
    assign REG_TXHPB4_WDATA = w_reg_txhpb4_wdata;
    assign REG_TXHPB_RST = w_reg_txhpb_rst;
    assign w_reg_txhpb_full_sync = REG_TXHPB_FULL;
    assign w_reg_int_txhbovf_sync = REG_INT_TXHBOVF;
    assign REG_RXF_RST = w_reg_rxf_rst;
    assign w_reg_int_rxfovf_sync = REG_INT_RXFOVF;

  end
endgenerate

endmodule
