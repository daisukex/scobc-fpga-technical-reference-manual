//-----------------------------------------------
// Module: sc_can_core
//  Space Cubics CAN Controller CAN Function Core Module
//-----------------------------------------------
// Copyright © 2021 Space Cubics, LLC.
//-----------------------------------------------
module sc_can_core # (
  parameter SC_CAN_FIFO_DEPTH = 6,
  parameter SC_CAN_CLK_ASYNC  = 1, // 1: Two Phase Asynchronous 0: Single Phase Synchronous
  parameter SC_CAN_PRIO_MGMT  = 1
) (
  // System Interface
  input REG_RSTB,
  input REG_CLK,
  input CAN_RSTB,
  input CAN_CLK,

  // CAN Bus Signal
  output CAN_TX,
  input CAN_RX,

  // Register Interface
  input REG_CAN_EN,

  input [15:0] REG_TQPDIV,
  input [3:0] REG_TS1,
  input [2:0] REG_TS2,
  input [1:0] REG_SJW,

  input [3:0] REG_ACF_EN,
  input [31:0] REG_ACF1_ID_MASK,
  input [31:0] REG_ACF1_ID_VAL,
  input [31:0] REG_ACF2_ID_MASK,
  input [31:0] REG_ACF2_ID_VAL,
  input [31:0] REG_ACF3_ID_MASK,
  input [31:0] REG_ACF3_ID_VAL,
  input [31:0] REG_ACF4_ID_MASK,
  input [31:0] REG_ACF4_ID_VAL,
  input REG_SELF_TMODE,
  output [7:0] REG_TX_ECNT,
  output [7:0] REG_RX_ECNT,
  output REG_BUS_BUSY,
  output REG_ERRWRN,
  output [1:0] REG_ERR_STS,
  output REG_TXF_NEMPTY,
  output REG_TXF_FULL,
  output REG_RXF_FULL,
  output REG_INT_TRNSDN,
  output REG_INT_ARBLST,
  output REG_INT_RCVDN,
  output REG_INT_RXFVAL,
  output REG_INT_CRCER,
  output REG_INT_FMER,
  output REG_INT_STFER,
  output REG_INT_BITER,
  output REG_INT_ACKER,
  output REG_INT_BUSOFF,

  input REG_TXF1_WEN,
  input [31:0] REG_TXF1_WDATA,
  input REG_TXF2_WEN,
  input [3:0] REG_TXF2_WDATA,
  input REG_TXF3_WEN,
  input [31:0] REG_TXF3_WDATA,
  input REG_TXF4_WEN,
  input [31:0] REG_TXF4_WDATA,
  input REG_TXF_RST,
  output REG_INT_TXFOVF,

  input REG_TXHPB1_WEN,
  input [31:0] REG_TXHPB1_WDATA,
  input REG_TXHPB2_WEN,
  input [3:0] REG_TXHPB2_WDATA,
  input REG_TXHPB3_WEN,
  input [31:0] REG_TXHPB3_WDATA,
  input REG_TXHPB4_WEN,
  input [31:0] REG_TXHPB4_WDATA,
  input REG_TXHPB_RST,
  output REG_TXHPB_FULL,
  output REG_INT_TXHBOVF,

  input REG_RXF1_REN,
  output [31:0] REG_RXF1_RDATA,
  input REG_RXF2_REN,
  output [3:0] REG_RXF2_RDATA,
  input REG_RXF3_REN,
  output [31:0] REG_RXF3_RDATA,
  input REG_RXF4_REN,
  output [31:0] REG_RXF4_RDATA,
  input REG_RXF_RST,
  output REG_INT_RXFOVF,
  output REG_INT_RXFUDF
);

wire [1:0] w_bsp_sync_stt;
wire w_rx_valid;
wire w_rx_data;
wire w_tx_trig;
wire w_txpm_rval;
wire w_txf_ren;
wire w_txf_rd_end;
wire [99:0] w_txf_rdata;
wire [SC_CAN_FIFO_DEPTH:0] w_txf_cap [0:3];
wire w_txhpb_dvalid;
wire w_txhpb_ren;
wire w_txhpb_rd_end;
wire [99:0] w_txhpb_rdata;
wire w_rxf_wen;
wire [99:0] w_rxf_wdata;

// Bit Timing Generator
sc_can_bt_gen can_bt_gen (
  // System Interface
  .CAN_RSTB(CAN_RSTB),            // input
  .CAN_CLK(CAN_CLK),              // input

  // CAN Bus Signal
  .CAN_RX(CAN_RX),                // input

  // Bit Stream Processor Interface
  .BSP_SYNC_STT(w_bsp_sync_stt),  // input [1:0]
  .RX_VALID(w_rx_valid),          // output
  .RX_DATA(w_rx_data),            // output
  .TX_TRIG(w_tx_trig),            // output

  // Register Interface
  .REG_CAN_EN(REG_CAN_EN),        // input
  .REG_TQPDIV(REG_TQPDIV),        // input [15:0]
  .REG_TS1(REG_TS1),              // input [3:0]
  .REG_TS2(REG_TS2),              // input [2:0]
  .REG_SJW(REG_SJW)               // input [1:0]
);

// Message Storage
sc_can_msg_strg # (
  .SC_CAN_FIFO_DEPTH(SC_CAN_FIFO_DEPTH),
  .SC_CAN_CLK_ASYNC(SC_CAN_CLK_ASYNC),  // 1: Two Phase Asynchronous 0: Single Phase Synchronous
  .SC_CAN_PRIO_MGMT(SC_CAN_PRIO_MGMT)
) can_msg_strg (
  // System Interface
  .REG_RSTB(REG_RSTB),                  // input
  .REG_CLK(REG_CLK),                    // input
  .CAN_RSTB(CAN_RSTB),                  // input
  .CAN_CLK(CAN_CLK),                    // input

  // Register Interface
  .REG_TXF1_WEN(REG_TXF1_WEN),          // input
  .REG_TXF1_WDATA(REG_TXF1_WDATA),      // input [31:0]
  .REG_TXF2_WEN(REG_TXF2_WEN),          // input
  .REG_TXF2_WDATA(REG_TXF2_WDATA),      // input [3:0]
  .REG_TXF3_WEN(REG_TXF3_WEN),          // input
  .REG_TXF3_WDATA(REG_TXF3_WDATA),      // input [31:0]
  .REG_TXF4_WEN(REG_TXF4_WEN),          // input
  .REG_TXF4_WDATA(REG_TXF4_WDATA),      // input [31:0]
  .REG_TXF_RST(REG_TXF_RST),            // input
  .REG_INT_TXFOVF(REG_INT_TXFOVF),      // output

  .REG_TXHPB1_WEN(REG_TXHPB1_WEN),      // input
  .REG_TXHPB1_WDATA(REG_TXHPB1_WDATA),  // input [31:0]
  .REG_TXHPB2_WEN(REG_TXHPB2_WEN),      // input
  .REG_TXHPB2_WDATA(REG_TXHPB2_WDATA),  // input [3:0]
  .REG_TXHPB3_WEN(REG_TXHPB3_WEN),      // input
  .REG_TXHPB3_WDATA(REG_TXHPB3_WDATA),  // input [31:0]
  .REG_TXHPB4_WEN(REG_TXHPB4_WEN),      // input
  .REG_TXHPB4_WDATA(REG_TXHPB4_WDATA),  // input [31:0]
  .REG_TXHPB_RST(REG_TXHPB_RST),        // input
  .REG_INT_TXHBOVF(REG_INT_TXHBOVF),    // output

  .REG_RXF1_REN(REG_RXF1_REN),          // input
  .REG_RXF1_RDATA(REG_RXF1_RDATA),      // output [31:0]
  .REG_RXF2_REN(REG_RXF2_REN),          // input
  .REG_RXF2_RDATA(REG_RXF2_RDATA),      // output [3:0]
  .REG_RXF3_REN(REG_RXF3_REN),          // input
  .REG_RXF3_RDATA(REG_RXF3_RDATA),      // output [31:0]
  .REG_RXF4_REN(REG_RXF4_REN),          // input
  .REG_RXF4_RDATA(REG_RXF4_RDATA),      // output [31:0]
  .REG_RXF_RST(REG_RXF_RST),            // input
  .REG_TXF_FULL(REG_TXF_FULL),          // output
  .REG_RXF_FULL(REG_RXF_FULL),          // output
  .REG_INT_RXFVAL(REG_INT_RXFVAL),      // output
  .REG_INT_RXFOVF(REG_INT_RXFOVF),      // output
  .REG_INT_RXFUDF(REG_INT_RXFUDF),      // output

  // Bit Stream Processor Interface
  .BSP_TXPM_RVAL(w_txpm_rval),          // output
  .BSP_TXF_REN(w_txf_ren),              // input
  .BSP_TXF_RDATA(w_txf_rdata),          // output [99:0]
  .BSP_TXF_RD_END(w_txf_rd_end),        // input
  .BSP_TXF1_CAP(w_txf_cap[0]),          // output [SC_CAN_FIFO_DEPTH:0]
  .BSP_TXF2_CAP(w_txf_cap[1]),          // output [SC_CAN_FIFO_DEPTH:0]
  .BSP_TXF3_CAP(w_txf_cap[2]),          // output [SC_CAN_FIFO_DEPTH:0]
  .BSP_TXF4_CAP(w_txf_cap[3]),          // output [SC_CAN_FIFO_DEPTH:0]

  .BSP_TXHPB_DVALID(w_txhpb_dvalid),    // output
  .BSP_TXHPB_REN(w_txhpb_ren),          // input
  .BSP_TXHPB_RDATA(w_txhpb_rdata),      // output [99:0]
  .BSP_TXHPB_RD_END(w_txhpb_rd_end),    // input

  .BSP_RXF_WEN(w_rxf_wen),              // input
  .BSP_RXF_WDATA(w_rxf_wdata)           // input [99:0]
);

assign REG_TXHPB_FULL = w_txhpb_dvalid;

// Bit Stream Processor
sc_can_bs_proc # (
  .SC_CAN_FIFO_DEPTH(SC_CAN_FIFO_DEPTH),
  .SC_CAN_PRIO_MGMT(SC_CAN_PRIO_MGMT)
) can_bs_proc (
  // System Interface
  .CAN_RSTB(CAN_RSTB),                  // input
  .CAN_CLK(CAN_CLK),                    // input

  // CAN Bus Signal
  .CAN_TX(CAN_TX),                      // output

  // Bit Timing Generator Interface
  .BSP_SYNC_STT(w_bsp_sync_stt),        // output [1:0]
  .RX_VALID(w_rx_valid),                // input
  .RX_DATA(w_rx_data),                  // input
  .TX_TRIG(w_tx_trig),                  // input

  // TX Message FIFO Interface
  .TXPM_RVAL(w_txpm_rval),              // input
  .TXF_REN(w_txf_ren),                  // output
  .TXF_RDATA(w_txf_rdata),              // input [99:0]
  .TXF_RD_END(w_txf_rd_end),            // output
  .TXF1_CAP(w_txf_cap[0]),              // input [SC_CAN_FIFO_DEPTH:0]
  .TXF2_CAP(w_txf_cap[1]),              // input [SC_CAN_FIFO_DEPTH:0]
  .TXF3_CAP(w_txf_cap[2]),              // input [SC_CAN_FIFO_DEPTH:0]
  .TXF4_CAP(w_txf_cap[3]),              // input [SC_CAN_FIFO_DEPTH:0]

  // TX High Priority Message Buffer Interface
  .TXHPB_DVALID(w_txhpb_dvalid),        // input
  .TXHPB_REN(w_txhpb_ren),              // output
  .TXHPB_RDATA(w_txhpb_rdata),          // input [99:0]
  .TXHPB_RD_END(w_txhpb_rd_end),        // output

  // RX Message FIFO Interface
  .RXF_WEN(w_rxf_wen),                  // output
  .RXF_WDATA(w_rxf_wdata),              // output [99:0]

  // Register Interface
  .REG_CAN_EN(REG_CAN_EN),              // input
  .REG_ACF_EN(REG_ACF_EN),              // input [3:0]
  .REG_ACF1_ID_MASK(REG_ACF1_ID_MASK),  // input [31:0]
  .REG_ACF1_ID_VAL(REG_ACF1_ID_VAL),    // input [31:0]
  .REG_ACF2_ID_MASK(REG_ACF2_ID_MASK),  // input [31:0]
  .REG_ACF2_ID_VAL(REG_ACF2_ID_VAL),    // input [31:0]
  .REG_ACF3_ID_MASK(REG_ACF3_ID_MASK),  // input [31:0]
  .REG_ACF3_ID_VAL(REG_ACF3_ID_VAL),    // input [31:0]
  .REG_ACF4_ID_MASK(REG_ACF4_ID_MASK),  // input [31:0]
  .REG_ACF4_ID_VAL(REG_ACF4_ID_VAL),    // input [31:0]
  .REG_SELF_TMODE(REG_SELF_TMODE),      // input
  .REG_TX_ECNT(REG_TX_ECNT),            // output [7:0]
  .REG_RX_ECNT(REG_RX_ECNT),            // output [7:0]
  .REG_BUS_BUSY(REG_BUS_BUSY),          // output
  .REG_ERRWRN(REG_ERRWRN),              // output
  .REG_ERR_STS(REG_ERR_STS),            // output [1:0]
  .REG_TXF_NEMPTY(REG_TXF_NEMPTY),      // output
  .REG_INT_TRNSDN(REG_INT_TRNSDN),      // output
  .REG_INT_ARBLST(REG_INT_ARBLST),      // output
  .REG_INT_RCVDN(REG_INT_RCVDN),        // output
  .REG_INT_CRCER(REG_INT_CRCER),        // output
  .REG_INT_FMER(REG_INT_FMER),          // output
  .REG_INT_STFER(REG_INT_STFER),        // output
  .REG_INT_BITER(REG_INT_BITER),        // output
  .REG_INT_ACKER(REG_INT_ACKER),        // output
  .REG_INT_BUSOFF(REG_INT_BUSOFF)       // output
);

endmodule
