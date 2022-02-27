//-----------------------------------------------
// Module: sc_can
//  Space Cubics CAN Controller
//-----------------------------------------------
// Copyright © 2021 Space Cubics, LLC.
//-----------------------------------------------
module sc_can # (
  parameter SC_CAN_AXI_ID_WIDTH = 1,
  parameter SC_CAN_FIFO_DEPTH = 6,
  parameter SC_CAN_CLK_ASYNC  = 1 // 1: Two Phase Asynchronous 0: Single Phase Synchronous
) (
  // System Interface
  input S_AXI_ARESETN,
  input S_AXI_ACLK,
  input CAN_RSTB,
  input CAN_CLK,
  input MODULE_RSTN,

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

  // CAN Bus Signal
  output CAN_TX,
  input CAN_RX,

  // CAN Transceiver Interface
  output CAN_SLEEP_EN,

  // Interrupt Signal
  output CAN_INT
);

wire w_can_axi_resetn;
wire w_sync_can_mrstb;
wire w_can_core_resetn;

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
wire [7:0] w_reg_tx_ecnt;
wire [7:0] w_reg_rx_ecnt;
wire w_reg_bus_busy;
wire w_reg_errwrn;
wire [1:0] w_reg_err_sts;
wire w_reg_txf_nempty;
wire w_reg_txf_full;
wire w_reg_rxf_full;
wire w_reg_int_trnsdn;
wire w_reg_int_arblst;
wire w_reg_int_rcvdn;
wire w_reg_int_rxfval;
wire w_reg_int_crcer;
wire w_reg_int_fmer;
wire w_reg_int_stfer;
wire w_reg_int_biter;
wire w_reg_int_acker;
wire w_reg_int_busoff;

wire w_reg_txf1_wen;
wire [31:0] w_reg_txf1_wdata;
wire w_reg_txf2_wen;
wire [3:0] w_reg_txf2_wdata;
wire w_reg_txf3_wen;
wire [31:0] w_reg_txf3_wdata;
wire w_reg_txf4_wen;
wire [31:0] w_reg_txf4_wdata;
wire w_reg_txf_rst;
wire w_reg_int_txfovf;

wire w_reg_txhpb1_wen;
wire [31:0] w_reg_txhpb1_wdata;
wire w_reg_txhpb2_wen;
wire [3:0] w_reg_txhpb2_wdata;
wire w_reg_txhpb3_wen;
wire [31:0] w_reg_txhpb3_wdata;
wire w_reg_txhpb4_wen;
wire [31:0] w_reg_txhpb4_wdata;
wire w_reg_txhpb_rst;
wire w_reg_txhpb_full;
wire w_reg_int_txhbovf;

wire w_reg_rxf1_ren;
wire [31:0] w_reg_rxf1_rdata;
wire w_reg_rxf2_ren;
wire [3:0] w_reg_rxf2_rdata;
wire w_reg_rxf3_ren;
wire [31:0] w_reg_rxf3_rdata;
wire w_reg_rxf4_ren;
wire [31:0] w_reg_rxf4_rdata;
wire w_reg_rxf_rst;
wire w_reg_int_rxfovf;
wire w_reg_int_rxfudf;

assign w_can_axi_resetn = S_AXI_ARESETN & MODULE_RSTN;

generate
  if (SC_CAN_CLK_ASYNC) begin
    sclib_rstb_sync sync_can_mrstb (
      .CLK(CAN_CLK),
      .RSTB_IN(MODULE_RSTN),
      .RSTB_OUT(w_sync_can_mrstb)
    );
  end else begin
    assign w_sync_can_mrstb = MODULE_RSTN;
  end
endgenerate
assign w_can_core_resetn = CAN_RSTB & w_sync_can_mrstb;

// Register
sc_can_reg_wrap # (
  .SC_CAN_AXI_ID_WIDTH(SC_CAN_AXI_ID_WIDTH),
  .SC_CAN_CLK_ASYNC(SC_CAN_CLK_ASYNC)
) can_reg_wrap (
  // System Interface
  .S_AXI_ARESETN(w_can_axi_resetn),       // input
  .S_AXI_ACLK(S_AXI_ACLK),                // input
  .CAN_RSTB(w_can_core_resetn),           // input
  .CAN_CLK(CAN_CLK),                      // input

  // AXI Slave Interface
  .S_AXI_AWID(S_AXI_AWID),                // input [SC_CAN_AXI_ID_W-1:0]
  .S_AXI_AWADDR(S_AXI_AWADDR),            // input [31:0]
  .S_AXI_AWLEN(S_AXI_AWLEN),              // input [7:0]
  .S_AXI_AWSIZE(S_AXI_AWSIZE),            // input [2:0]
  .S_AXI_AWBURST(S_AXI_AWBURST),          // input [1:0]
  .S_AXI_AWLOCK(S_AXI_AWLOCK),            // input
  .S_AXI_AWCACHE(S_AXI_AWCACHE),          // input [3:0]
  .S_AXI_AWPROT(S_AXI_AWPROT),            // input [2:0]
  .S_AXI_AWVALID(S_AXI_AWVALID),          // input
  .S_AXI_AWREADY(S_AXI_AWREADY),          // output
  .S_AXI_WDATA(S_AXI_WDATA),              // input [31:0]
  .S_AXI_WSTRB(S_AXI_WSTRB),              // input [3:0]
  .S_AXI_WLAST(S_AXI_WLAST),              // input
  .S_AXI_WVALID(S_AXI_WVALID),            // input
  .S_AXI_WREADY(S_AXI_WREADY),            // output
  .S_AXI_BID(S_AXI_BID),                  // output [SC_CAN_AXI_ID_W-1:0]
  .S_AXI_BRESP(S_AXI_BRESP),              // output [1:0]
  .S_AXI_BVALID(S_AXI_BVALID),            // output
  .S_AXI_BREADY(S_AXI_BREADY),            // input
  .S_AXI_ARID(S_AXI_ARID),                // input [SC_CAN_AXI_ID_W-1:0]
  .S_AXI_ARADDR(S_AXI_ARADDR),            // input [31:0]
  .S_AXI_ARLEN(S_AXI_ARLEN),              // input [7:0]
  .S_AXI_ARSIZE(S_AXI_ARSIZE),            // input [2:0]
  .S_AXI_ARBURST(S_AXI_ARBURST),          // input [1:0]
  .S_AXI_ARLOCK(S_AXI_ARLOCK),            // input
  .S_AXI_ARCACHE(S_AXI_ARCACHE),          // input [3:0]
  .S_AXI_ARPROT(S_AXI_ARPROT),            // input [2:0]
  .S_AXI_ARVALID(S_AXI_ARVALID),          // input
  .S_AXI_ARREADY(S_AXI_ARREADY),          // output
  .S_AXI_RID(S_AXI_RID),                  // output [SC_CAN_AXI_ID_W-1:0]
  .S_AXI_RDATA(S_AXI_RDATA),              // output [31:0]
  .S_AXI_RRESP(S_AXI_RRESP),              // output [1:0]
  .S_AXI_RLAST(S_AXI_RLAST),              // output
  .S_AXI_RVALID(S_AXI_RVALID),            // output
  .S_AXI_RREADY(S_AXI_RREADY),            // input

  // CAN Core Enable Signal
  .REG_CAN_EN(w_reg_can_en),              // output

  // Bit Timing Generator Interface
  .REG_TQPDIV(w_reg_tqpdiv),              // output [15:0]
  .REG_TS1(w_reg_ts1),                    // output [3:0]
  .REG_TS2(w_reg_ts2),                    // output [2:0]
  .REG_SJW(w_reg_sjw),                    // output [1:0]

  // Bit Stream Processor Interface
  .REG_ACF_EN(w_reg_acf_en),              // output [3:0]
  .REG_ACF1_ID_MASK(w_reg_acf1_id_mask),  // output [31:0]
  .REG_ACF1_ID_VAL(w_reg_acf1_id_val),    // output [31:0]
  .REG_ACF2_ID_MASK(w_reg_acf2_id_mask),  // output [31:0]
  .REG_ACF2_ID_VAL(w_reg_acf2_id_val),    // output [31:0]
  .REG_ACF3_ID_MASK(w_reg_acf3_id_mask),  // output [31:0]
  .REG_ACF3_ID_VAL(w_reg_acf3_id_val),    // output [31:0]
  .REG_ACF4_ID_MASK(w_reg_acf4_id_mask),  // output [31:0]
  .REG_ACF4_ID_VAL(w_reg_acf4_id_val),    // output [31:0]
  .REG_SELF_TMODE(w_reg_self_tmode),      // output
  .REG_TX_ECNT(w_reg_tx_ecnt),            // input [7:0]
  .REG_RX_ECNT(w_reg_rx_ecnt),            // input [7:0]
  .REG_BUS_BUSY(w_reg_bus_busy),          // input
  .REG_ERRWRN(w_reg_errwrn),              // input
  .REG_ERR_STS(w_reg_err_sts),            // input [1:0]
  .REG_TXF_NEMPTY(w_reg_txf_nempty),      // input
  .REG_TXF_FULL(w_reg_txf_full),          // input
  .REG_RXF_FULL(w_reg_rxf_full),          // input
  .REG_INT_TRNSDN(w_reg_int_trnsdn),      // input
  .REG_INT_ARBLST(w_reg_int_arblst),      // input
  .REG_INT_RCVDN(w_reg_int_rcvdn),        // input
  .REG_INT_RXFVAL(w_reg_int_rxfval),      // input
  .REG_INT_CRCER(w_reg_int_crcer),        // input
  .REG_INT_FMER(w_reg_int_fmer),          // input
  .REG_INT_STFER(w_reg_int_stfer),        // input
  .REG_INT_BITER(w_reg_int_biter),        // input
  .REG_INT_ACKER(w_reg_int_acker),        // input
  .REG_INT_BUSOFF(w_reg_int_busoff),      // input

  // TX Message FIFO Interface
  .REG_TXF1_WEN(w_reg_txf1_wen),          // output
  .REG_TXF1_WDATA(w_reg_txf1_wdata),      // output [31:0]
  .REG_TXF2_WEN(w_reg_txf2_wen),          // output
  .REG_TXF2_WDATA(w_reg_txf2_wdata),      // output [3:0]
  .REG_TXF3_WEN(w_reg_txf3_wen),          // output
  .REG_TXF3_WDATA(w_reg_txf3_wdata),      // output [31:0]
  .REG_TXF4_WEN(w_reg_txf4_wen),          // output
  .REG_TXF4_WDATA(w_reg_txf4_wdata),      // output [31:0]
  .REG_TXF_RST(w_reg_txf_rst),            // output
  .REG_INT_TXFOVF(w_reg_int_txfovf),      // input

  // TX High Priority Message Buffer Interface
  .REG_TXHPB1_WEN(w_reg_txhpb1_wen),      // output
  .REG_TXHPB1_WDATA(w_reg_txhpb1_wdata),  // output [31:0]
  .REG_TXHPB2_WEN(w_reg_txhpb2_wen),      // output
  .REG_TXHPB2_WDATA(w_reg_txhpb2_wdata),  // output [3:0]
  .REG_TXHPB3_WEN(w_reg_txhpb3_wen),      // output
  .REG_TXHPB3_WDATA(w_reg_txhpb3_wdata),  // output [31:0]
  .REG_TXHPB4_WEN(w_reg_txhpb4_wen),      // output
  .REG_TXHPB4_WDATA(w_reg_txhpb4_wdata),  // output [31:0]
  .REG_TXHPB_RST(w_reg_txhpb_rst),        // output
  .REG_TXHPB_FULL(w_reg_txhpb_full),      // input
  .REG_INT_TXHBOVF(w_reg_int_txhbovf),    // input

  // RX Message FIFO Interface
  .REG_RXF1_REN(w_reg_rxf1_ren),          // output
  .REG_RXF1_RDATA(w_reg_rxf1_rdata),      // input [31:0]
  .REG_RXF2_REN(w_reg_rxf2_ren),          // output
  .REG_RXF2_RDATA(w_reg_rxf2_rdata),      // input [3:0]
  .REG_RXF3_REN(w_reg_rxf3_ren),          // output
  .REG_RXF3_RDATA(w_reg_rxf3_rdata),      // input [31:0]
  .REG_RXF4_REN(w_reg_rxf4_ren),          // output
  .REG_RXF4_RDATA(w_reg_rxf4_rdata),      // input [31:0]
  .REG_RXF_RST(w_reg_rxf_rst),            // output
  .REG_INT_RXFOVF(w_reg_int_rxfovf),      // input
  .REG_INT_RXFUDF(w_reg_int_rxfudf),      // input

  // CAN Transceiver Interface
  .REG_PHY_SLEEP_EN(CAN_SLEEP_EN),        // output

  // Interrupt Signal
  .CAN_INT(CAN_INT)                       // output
);

// CAN Control Core
sc_can_core # (
  .SC_CAN_FIFO_DEPTH(SC_CAN_FIFO_DEPTH),
  .SC_CAN_CLK_ASYNC(SC_CAN_CLK_ASYNC)
) can_core (
  // System Interface
  .REG_RSTB(w_can_axi_resetn),            // input
  .REG_CLK(S_AXI_ACLK),                   // input
  .CAN_RSTB(w_can_core_resetn),           // input
  .CAN_CLK(CAN_CLK),                      // input

  // CAN Bus Signal
  .CAN_TX(CAN_TX),                        // output
  .CAN_RX(CAN_RX),                        // input

  // Register Interface
  .REG_CAN_EN(w_reg_can_en),              // input

  .REG_TQPDIV(w_reg_tqpdiv),              // input [15:0]
  .REG_TS1(w_reg_ts1),                    // input [3:0]
  .REG_TS2(w_reg_ts2),                    // input [2:0]
  .REG_SJW(w_reg_sjw),                    // input [1:0]

  .REG_ACF_EN(w_reg_acf_en),              // input [3:0]
  .REG_ACF1_ID_MASK(w_reg_acf1_id_mask),  // input [31:0]
  .REG_ACF1_ID_VAL(w_reg_acf1_id_val),    // input [31:0]
  .REG_ACF2_ID_MASK(w_reg_acf2_id_mask),  // input [31:0]
  .REG_ACF2_ID_VAL(w_reg_acf2_id_val),    // input [31:0]
  .REG_ACF3_ID_MASK(w_reg_acf3_id_mask),  // input [31:0]
  .REG_ACF3_ID_VAL(w_reg_acf3_id_val),    // input [31:0]
  .REG_ACF4_ID_MASK(w_reg_acf4_id_mask),  // input [31:0]
  .REG_ACF4_ID_VAL(w_reg_acf4_id_val),    // input [31:0]
  .REG_SELF_TMODE(w_reg_self_tmode),      // input
  .REG_TX_ECNT(w_reg_tx_ecnt),            // output [7:0]
  .REG_RX_ECNT(w_reg_rx_ecnt),            // output [7:0]
  .REG_BUS_BUSY(w_reg_bus_busy),          // output
  .REG_ERRWRN(w_reg_errwrn),              // output
  .REG_ERR_STS(w_reg_err_sts),            // output [1:0]
  .REG_TXF_NEMPTY(w_reg_txf_nempty),      // output
  .REG_TXF_FULL(w_reg_txf_full),          // output
  .REG_RXF_FULL(w_reg_rxf_full),          // output
  .REG_INT_TRNSDN(w_reg_int_trnsdn),      // output
  .REG_INT_ARBLST(w_reg_int_arblst),      // output
  .REG_INT_RCVDN(w_reg_int_rcvdn),        // output
  .REG_INT_RXFVAL(w_reg_int_rxfval),      // output
  .REG_INT_CRCER(w_reg_int_crcer),        // output
  .REG_INT_FMER(w_reg_int_fmer),          // output
  .REG_INT_STFER(w_reg_int_stfer),        // output
  .REG_INT_BITER(w_reg_int_biter),        // output
  .REG_INT_ACKER(w_reg_int_acker),        // output
  .REG_INT_BUSOFF(w_reg_int_busoff),      // output

  .REG_TXF1_WEN(w_reg_txf1_wen),          // input
  .REG_TXF1_WDATA(w_reg_txf1_wdata),      // input [31:0]
  .REG_TXF2_WEN(w_reg_txf2_wen),          // input
  .REG_TXF2_WDATA(w_reg_txf2_wdata),      // input [3:0]
  .REG_TXF3_WEN(w_reg_txf3_wen),          // input
  .REG_TXF3_WDATA(w_reg_txf3_wdata),      // input [31:0]
  .REG_TXF4_WEN(w_reg_txf4_wen),          // input
  .REG_TXF4_WDATA(w_reg_txf4_wdata),      // input [31:0]
  .REG_TXF_RST(w_reg_txf_rst),            // input
  .REG_INT_TXFOVF(w_reg_int_txfovf),      // output

  .REG_TXHPB1_WEN(w_reg_txhpb1_wen),      // input
  .REG_TXHPB1_WDATA(w_reg_txhpb1_wdata),  // input [31:0]
  .REG_TXHPB2_WEN(w_reg_txhpb2_wen),      // input
  .REG_TXHPB2_WDATA(w_reg_txhpb2_wdata),  // input [3:0]
  .REG_TXHPB3_WEN(w_reg_txhpb3_wen),      // input
  .REG_TXHPB3_WDATA(w_reg_txhpb3_wdata),  // input [31:0]
  .REG_TXHPB4_WEN(w_reg_txhpb4_wen),      // input
  .REG_TXHPB4_WDATA(w_reg_txhpb4_wdata),  // input [31:0]
  .REG_TXHPB_RST(w_reg_txhpb_rst),        // input
  .REG_TXHPB_FULL(w_reg_txhpb_full),      // output
  .REG_INT_TXHBOVF(w_reg_int_txhbovf),    // output

  .REG_RXF1_REN(w_reg_rxf1_ren),          // input
  .REG_RXF1_RDATA(w_reg_rxf1_rdata),      // output [31:0]
  .REG_RXF2_REN(w_reg_rxf2_ren),          // input
  .REG_RXF2_RDATA(w_reg_rxf2_rdata),      // output [3:0]
  .REG_RXF3_REN(w_reg_rxf3_ren),          // input
  .REG_RXF3_RDATA(w_reg_rxf3_rdata),      // output [31:0]
  .REG_RXF4_REN(w_reg_rxf4_ren),          // input
  .REG_RXF4_RDATA(w_reg_rxf4_rdata),      // output [31:0]
  .REG_RXF_RST(w_reg_rxf_rst),            // input
  .REG_INT_RXFOVF(w_reg_int_rxfovf),      // output
  .REG_INT_RXFUDF(w_reg_int_rxfudf)       // output
);

endmodule
