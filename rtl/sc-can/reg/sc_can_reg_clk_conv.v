//-----------------------------------------------
// Module: sc_can_reg_clk_conv
//  Space Cubics CAN Controller Register Signal Clock Converter
//-----------------------------------------------
// Copyright © 2021 Space Cubics, LLC.
//-----------------------------------------------
module sc_can_reg_clk_conv (
  input REG_RSTB,
  input REG_CLK,
  input CAN_RSTB,
  input CAN_CLK,

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
  output [7:0] REG_TX_ECNT_SYNC,
  output [7:0] REG_RX_ECNT_SYNC,
  output REG_BUS_BUSY_SYNC,
  output REG_ERRWRN_SYNC,
  output [1:0] REG_ERR_STS_SYNC,
  output REG_TXF_NEMPTY_SYNC,
  output REG_TXF_FULL_SYNC,
  output REG_RXF_FULL_SYNC,
  output REG_INT_TRNSDN_SYNC,
  output REG_INT_ARBLST_SYNC,
  output REG_INT_RCVDN_SYNC,
  output REG_INT_RXFVAL_SYNC,
  output REG_INT_CRCER_SYNC,
  output REG_INT_FMER_SYNC,
  output REG_INT_STFER_SYNC,
  output REG_INT_BITER_SYNC,
  output REG_INT_ACKER_SYNC,
  output REG_INT_BUSOFF_SYNC,
  input REG_TXHPB1_WEN,
  input [31:0] REG_TXHPB1_WDATA,
  input REG_TXHPB2_WEN,
  input [3:0] REG_TXHPB2_WDATA,
  input REG_TXHPB3_WEN,
  input [31:0] REG_TXHPB3_WDATA,
  input REG_TXHPB4_WEN,
  input [31:0] REG_TXHPB4_WDATA,
  input REG_TXHPB_RST,
  output REG_TXHPB_FULL_SYNC,
  output REG_INT_TXHBOVF_SYNC,
  input REG_RXF_RST,
  output REG_INT_RXFOVF_SYNC,

  // CAN Core Interface
  output REG_CAN_EN_SYNC,
  output [15:0] REG_TQPDIV_SYNC,
  output [3:0] REG_TS1_SYNC,
  output [2:0] REG_TS2_SYNC,
  output [1:0] REG_SJW_SYNC,
  output [3:0] REG_ACF_EN_SYNC,
  output [31:0] REG_ACF1_ID_MASK_SYNC,
  output [31:0] REG_ACF1_ID_VAL_SYNC,
  output [31:0] REG_ACF2_ID_MASK_SYNC,
  output [31:0] REG_ACF2_ID_VAL_SYNC,
  output [31:0] REG_ACF3_ID_MASK_SYNC,
  output [31:0] REG_ACF3_ID_VAL_SYNC,
  output [31:0] REG_ACF4_ID_MASK_SYNC,
  output [31:0] REG_ACF4_ID_VAL_SYNC,
  output REG_SELF_TMODE_SYNC,
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
  output REG_TXHPB1_WEN_SYNC,
  output [31:0] REG_TXHPB1_WDATA_SYNC,
  output REG_TXHPB2_WEN_SYNC,
  output [3:0] REG_TXHPB2_WDATA_SYNC,
  output REG_TXHPB3_WEN_SYNC,
  output [31:0] REG_TXHPB3_WDATA_SYNC,
  output REG_TXHPB4_WEN_SYNC,
  output [31:0] REG_TXHPB4_WDATA_SYNC,
  output REG_TXHPB_RST_SYNC,
  input REG_TXHPB_FULL,
  input REG_INT_TXHBOVF,
  output REG_RXF_RST_SYNC,
  input REG_INT_RXFOVF
);

/*----------------------
// REG_CLK -> CAN_CLK
----------------------*/

// REG_CAN_EN
sc_clk_conv_lvl # (
  .P_INIT_VAL(0)
) cconv_can_en (
  .IN_RSTB(REG_RSTB),        // input
  .IN_CLK(REG_CLK),          // input
  .IN_SIG(REG_CAN_EN),       // input
  .SYNC_RSTB(CAN_RSTB),      // input
  .SYNC_CLK(CAN_CLK),        // input
  .SYNC_SIG(REG_CAN_EN_SYNC) // output
);

// REG_TQPDIV
sc_clk_conv_bus # (
  .P_USE_VLD(0),
  .P_DT_WIDTH(16)
) cconv_tqpdiv (
  .IN_RSTB(REG_RSTB),         // input
  .IN_CLK(REG_CLK),           // input
  .IN_VALID(1'b0),            // input
  .IN_DATA(REG_TQPDIV),       // input [P_DT_WIDTH-1:0]
  .SYNC_RSTB(CAN_RSTB),       // input
  .SYNC_CLK(CAN_CLK),         // input
  .SYNC_VALID(/*open*/),      // output
  .SYNC_DATA(REG_TQPDIV_SYNC) // output [P_DT_WIDTH-1:0]
);

// REG_TS1, REG_TS2, REG_SJW
wire [8:0] w_bittim;
wire [8:0] w_bittim_sync;
assign w_bittim = {REG_SJW, REG_TS2, REG_TS1};
sc_clk_conv_bus # (
  .P_USE_VLD(0),
  .P_DT_WIDTH(9)
) cconv_bittim (
  .IN_RSTB(REG_RSTB),       // input
  .IN_CLK(REG_CLK),         // input
  .IN_VALID(1'b0),          // input
  .IN_DATA(w_bittim),       // input [P_DT_WIDTH-1:0]
  .SYNC_RSTB(CAN_RSTB),     // input
  .SYNC_CLK(CAN_CLK),       // input
  .SYNC_VALID(/*open*/),    // output
  .SYNC_DATA(w_bittim_sync) // output [P_DT_WIDTH-1:0]
);
assign REG_TS1_SYNC = w_bittim_sync[3:0];
assign REG_TS2_SYNC = w_bittim_sync[6:4];
assign REG_SJW_SYNC = w_bittim_sync[8:7];

// REG_ACF_EN
sc_clk_conv_bus # (
  .P_USE_VLD(0),
  .P_DT_WIDTH(4)
) cconv_acf_en (
  .IN_RSTB(REG_RSTB),         // input
  .IN_CLK(REG_CLK),           // input
  .IN_VALID(1'b0),            // input
  .IN_DATA(REG_ACF_EN),       // input [P_DT_WIDTH-1:0]
  .SYNC_RSTB(CAN_RSTB),       // input
  .SYNC_CLK(CAN_CLK),         // input
  .SYNC_VALID(/*open*/),      // output
  .SYNC_DATA(REG_ACF_EN_SYNC) // output [P_DT_WIDTH-1:0]
);

// REG_ACF1_ID_MASK
sc_clk_conv_bus # (
  .P_USE_VLD(0),
  .P_DT_WIDTH(32)
) cconv_acf1_id_mask (
  .IN_RSTB(REG_RSTB),               // input
  .IN_CLK(REG_CLK),                 // input
  .IN_VALID(1'b0),                  // input
  .IN_DATA(REG_ACF1_ID_MASK),       // input [P_DT_WIDTH-1:0]
  .SYNC_RSTB(CAN_RSTB),             // input
  .SYNC_CLK(CAN_CLK),               // input
  .SYNC_VALID(/*open*/),            // output
  .SYNC_DATA(REG_ACF1_ID_MASK_SYNC) // output [P_DT_WIDTH-1:0]
);

// REG_ACF1_ID_VAL
sc_clk_conv_bus # (
  .P_USE_VLD(0),
  .P_DT_WIDTH(32)
) cconv_acf1_id_val (
  .IN_RSTB(REG_RSTB),              // input
  .IN_CLK(REG_CLK),                // input
  .IN_VALID(1'b0),                 // input
  .IN_DATA(REG_ACF1_ID_VAL),       // input [P_DT_WIDTH-1:0]
  .SYNC_RSTB(CAN_RSTB),            // input
  .SYNC_CLK(CAN_CLK),              // input
  .SYNC_VALID(/*open*/),           // output
  .SYNC_DATA(REG_ACF1_ID_VAL_SYNC) // output [P_DT_WIDTH-1:0]
);

// REG_ACF2_ID_MASK
sc_clk_conv_bus # (
  .P_USE_VLD(0),
  .P_DT_WIDTH(32)
) cconv_acf2_id_mask (
  .IN_RSTB(REG_RSTB),               // input
  .IN_CLK(REG_CLK),                 // input
  .IN_VALID(1'b0),                  // input
  .IN_DATA(REG_ACF2_ID_MASK),       // input [P_DT_WIDTH-1:0]
  .SYNC_RSTB(CAN_RSTB),             // input
  .SYNC_CLK(CAN_CLK),               // input
  .SYNC_VALID(/*open*/),            // output
  .SYNC_DATA(REG_ACF2_ID_MASK_SYNC) // output [P_DT_WIDTH-1:0]
);

// REG_ACF2_ID_VAL
sc_clk_conv_bus # (
  .P_USE_VLD(0),
  .P_DT_WIDTH(32)
) cconv_acf2_id_val (
  .IN_RSTB(REG_RSTB),              // input
  .IN_CLK(REG_CLK),                // input
  .IN_VALID(1'b0),                 // input
  .IN_DATA(REG_ACF2_ID_VAL),       // input [P_DT_WIDTH-1:0]
  .SYNC_RSTB(CAN_RSTB),            // input
  .SYNC_CLK(CAN_CLK),              // input
  .SYNC_VALID(/*open*/),           // output
  .SYNC_DATA(REG_ACF2_ID_VAL_SYNC) // output [P_DT_WIDTH-1:0]
);

// REG_ACF3_ID_MASK
sc_clk_conv_bus # (
  .P_USE_VLD(0),
  .P_DT_WIDTH(32)
) cconv_acf3_id_mask (
  .IN_RSTB(REG_RSTB),               // input
  .IN_CLK(REG_CLK),                 // input
  .IN_VALID(1'b0),                  // input
  .IN_DATA(REG_ACF3_ID_MASK),       // input [P_DT_WIDTH-1:0]
  .SYNC_RSTB(CAN_RSTB),             // input
  .SYNC_CLK(CAN_CLK),               // input
  .SYNC_VALID(/*open*/),            // output
  .SYNC_DATA(REG_ACF3_ID_MASK_SYNC) // output [P_DT_WIDTH-1:0]
);

// REG_ACF3_ID_VAL
sc_clk_conv_bus # (
  .P_USE_VLD(0),
  .P_DT_WIDTH(32)
) cconv_acf3_id_val (
  .IN_RSTB(REG_RSTB),              // input
  .IN_CLK(REG_CLK),                // input
  .IN_VALID(1'b0),                 // input
  .IN_DATA(REG_ACF3_ID_VAL),       // input [P_DT_WIDTH-1:0]
  .SYNC_RSTB(CAN_RSTB),            // input
  .SYNC_CLK(CAN_CLK),              // input
  .SYNC_VALID(/*open*/),           // output
  .SYNC_DATA(REG_ACF3_ID_VAL_SYNC) // output [P_DT_WIDTH-1:0]
);

// REG_ACF4_ID_MASK
sc_clk_conv_bus # (
  .P_USE_VLD(0),
  .P_DT_WIDTH(32)
) cconv_acf4_id_mask (
  .IN_RSTB(REG_RSTB),               // input
  .IN_CLK(REG_CLK),                 // input
  .IN_VALID(1'b0),                  // input
  .IN_DATA(REG_ACF4_ID_MASK),       // input [P_DT_WIDTH-1:0]
  .SYNC_RSTB(CAN_RSTB),             // input
  .SYNC_CLK(CAN_CLK),               // input
  .SYNC_VALID(/*open*/),            // output
  .SYNC_DATA(REG_ACF4_ID_MASK_SYNC) // output [P_DT_WIDTH-1:0]
);

// REG_ACF4_ID_VAL
sc_clk_conv_bus # (
  .P_USE_VLD(0),
  .P_DT_WIDTH(32)
) cconv_acf4_id_val (
  .IN_RSTB(REG_RSTB),              // input
  .IN_CLK(REG_CLK),                // input
  .IN_VALID(1'b0),                 // input
  .IN_DATA(REG_ACF4_ID_VAL),       // input [P_DT_WIDTH-1:0]
  .SYNC_RSTB(CAN_RSTB),            // input
  .SYNC_CLK(CAN_CLK),              // input
  .SYNC_VALID(/*open*/),           // output
  .SYNC_DATA(REG_ACF4_ID_VAL_SYNC) // output [P_DT_WIDTH-1:0]
);

// REG_SELF_TMODE
sc_clk_conv_lvl # (
  .P_INIT_VAL(0)
) cconv_self_tmode (
  .IN_RSTB(REG_RSTB),            // input
  .IN_CLK(REG_CLK),              // input
  .IN_SIG(REG_SELF_TMODE),       // input
  .SYNC_RSTB(CAN_RSTB),          // input
  .SYNC_CLK(CAN_CLK),            // input
  .SYNC_SIG(REG_SELF_TMODE_SYNC) // output
);

// REG_TXHPB1_WEN, REG_TXHPB1_WDATA
sc_clk_conv_bus # (
  .P_USE_VLD(1),
  .P_DT_WIDTH(32)
) cconv_txhpb1_wdata (
  .IN_RSTB(REG_RSTB),               // input
  .IN_CLK(REG_CLK),                 // input
  .IN_VALID(REG_TXHPB1_WEN),        // input
  .IN_DATA(REG_TXHPB1_WDATA),       // input [P_DT_WIDTH-1:0]
  .SYNC_RSTB(CAN_RSTB),             // input
  .SYNC_CLK(CAN_CLK),               // input
  .SYNC_VALID(REG_TXHPB1_WEN_SYNC), // output
  .SYNC_DATA(REG_TXHPB1_WDATA_SYNC) // output [P_DT_WIDTH-1:0]
);

// REG_TXHPB2_WEN, REG_TXHPB2_WDATA
sc_clk_conv_bus # (
  .P_USE_VLD(1),
  .P_DT_WIDTH(4)
) cconv_txhpb2_wdata (
  .IN_RSTB(REG_RSTB),               // input
  .IN_CLK(REG_CLK),                 // input
  .IN_VALID(REG_TXHPB2_WEN),        // input
  .IN_DATA(REG_TXHPB2_WDATA),       // input [P_DT_WIDTH-1:0]
  .SYNC_RSTB(CAN_RSTB),             // input
  .SYNC_CLK(CAN_CLK),               // input
  .SYNC_VALID(REG_TXHPB2_WEN_SYNC), // output
  .SYNC_DATA(REG_TXHPB2_WDATA_SYNC) // output [P_DT_WIDTH-1:0]
);

// REG_TXHPB3_WEN, REG_TXHPB3_WDATA
sc_clk_conv_bus # (
  .P_USE_VLD(1),
  .P_DT_WIDTH(32)
) cconv_txhpb3_wdata (
  .IN_RSTB(REG_RSTB),               // input
  .IN_CLK(REG_CLK),                 // input
  .IN_VALID(REG_TXHPB3_WEN),        // input
  .IN_DATA(REG_TXHPB3_WDATA),       // input [P_DT_WIDTH-1:0]
  .SYNC_RSTB(CAN_RSTB),             // input
  .SYNC_CLK(CAN_CLK),               // input
  .SYNC_VALID(REG_TXHPB3_WEN_SYNC), // output
  .SYNC_DATA(REG_TXHPB3_WDATA_SYNC) // output [P_DT_WIDTH-1:0]
);

// REG_TXHPB4_WEN, REG_TXHPB4_WDATA
sc_clk_conv_bus # (
  .P_USE_VLD(1),
  .P_DT_WIDTH(32)
) cconv_txhpb4_wdata (
  .IN_RSTB(REG_RSTB),               // input
  .IN_CLK(REG_CLK),                 // input
  .IN_VALID(REG_TXHPB4_WEN),        // input
  .IN_DATA(REG_TXHPB4_WDATA),       // input [P_DT_WIDTH-1:0]
  .SYNC_RSTB(CAN_RSTB),             // input
  .SYNC_CLK(CAN_CLK),               // input
  .SYNC_VALID(REG_TXHPB4_WEN_SYNC), // output
  .SYNC_DATA(REG_TXHPB4_WDATA_SYNC) // output [P_DT_WIDTH-1:0]
);

// REG_TXHPB_RST
sc_clk_conv_pls # (
  .P_POLARITY(1) // 1: Positive 0: Negative
) cconv_txhpb_rst (
  .IN_RSTB(REG_RSTB),           // input
  .IN_CLK(REG_CLK),             // input
  .IN_PLS(REG_TXHPB_RST),       // input
  .SYNC_RSTB(CAN_RSTB),         // input
  .SYNC_CLK(CAN_CLK),           // input
  .SYNC_PLS(REG_TXHPB_RST_SYNC) // output
);

// REG_RXF_RST
sc_clk_conv_pls # (
  .P_POLARITY(1) // 1: Positive 0: Negative
) cconv_rxf_rst (
  .IN_RSTB(REG_RSTB),         // input
  .IN_CLK(REG_CLK),           // input
  .IN_PLS(REG_RXF_RST),       // input
  .SYNC_RSTB(CAN_RSTB),       // input
  .SYNC_CLK(CAN_CLK),         // input
  .SYNC_PLS(REG_RXF_RST_SYNC) // output
);

/*----------------------
// CAN_CLK -> REG_CLK
----------------------*/

// REG_TX_ECNT
sc_clk_conv_bus # (
  .P_USE_VLD(0),
  .P_DT_WIDTH(8)
) cconv_tx_ecnt (
  .IN_RSTB(CAN_RSTB),          // input
  .IN_CLK(CAN_CLK),            // input
  .IN_VALID(1'b0),             // input
  .IN_DATA(REG_TX_ECNT),       // input [P_DT_WIDTH-1:0]
  .SYNC_RSTB(REG_RSTB),        // input
  .SYNC_CLK(REG_CLK),          // input
  .SYNC_VALID(/*open*/),       // output
  .SYNC_DATA(REG_TX_ECNT_SYNC) // output [P_DT_WIDTH-1:0]
);

// REG_RX_ECNT
sc_clk_conv_bus # (
  .P_USE_VLD(0),
  .P_DT_WIDTH(8)
) cconv_rx_ecnt (
  .IN_RSTB(CAN_RSTB),          // input
  .IN_CLK(CAN_CLK),            // input
  .IN_VALID(1'b0),             // input
  .IN_DATA(REG_RX_ECNT),       // input [P_DT_WIDTH-1:0]
  .SYNC_RSTB(REG_RSTB),        // input
  .SYNC_CLK(REG_CLK),          // input
  .SYNC_VALID(/*open*/),       // output
  .SYNC_DATA(REG_RX_ECNT_SYNC) // output [P_DT_WIDTH-1:0]
);

// REG_BUS_BUSY
sc_clk_conv_lvl # (
  .P_INIT_VAL(0)
) cconv_bus_busy (
  .IN_RSTB(CAN_RSTB),          // input
  .IN_CLK(CAN_CLK),            // input
  .IN_SIG(REG_BUS_BUSY),       // input
  .SYNC_RSTB(REG_RSTB),        // input
  .SYNC_CLK(REG_CLK),          // input
  .SYNC_SIG(REG_BUS_BUSY_SYNC) // output
);

// REG_ERRWRN
sc_clk_conv_lvl # (
  .P_INIT_VAL(0)
) cconv_errwrn (
  .IN_RSTB(CAN_RSTB),        // input
  .IN_CLK(CAN_CLK),          // input
  .IN_SIG(REG_ERRWRN),       // input
  .SYNC_RSTB(REG_RSTB),      // input
  .SYNC_CLK(REG_CLK),        // input
  .SYNC_SIG(REG_ERRWRN_SYNC) // output
);

// REG_ERR_STS
sc_clk_conv_bus # (
  .P_USE_VLD(0),
  .P_DT_WIDTH(2)
) cconv_err_sts (
  .IN_RSTB(CAN_RSTB),          // input
  .IN_CLK(CAN_CLK),            // input
  .IN_VALID(1'b0),             // input
  .IN_DATA(REG_ERR_STS),       // input [P_DT_WIDTH-1:0]
  .SYNC_RSTB(REG_RSTB),        // input
  .SYNC_CLK(REG_CLK),          // input
  .SYNC_VALID(/*open*/),       // output
  .SYNC_DATA(REG_ERR_STS_SYNC) // output [P_DT_WIDTH-1:0]
);

// REG_TXF_NEMPTY
sc_clk_conv_lvl # (
  .P_INIT_VAL(0)
) cconv_txf_nempty (
  .IN_RSTB(CAN_RSTB),            // input
  .IN_CLK(CAN_CLK),              // input
  .IN_SIG(REG_TXF_NEMPTY),       // input
  .SYNC_RSTB(REG_RSTB),          // input
  .SYNC_CLK(REG_CLK),            // input
  .SYNC_SIG(REG_TXF_NEMPTY_SYNC) // output
);

// REG_TXF_FULL
sc_clk_conv_lvl # (
  .P_INIT_VAL(0)
) cconv_txf_full (
  .IN_RSTB(CAN_RSTB),          // input
  .IN_CLK(CAN_CLK),            // input
  .IN_SIG(REG_TXF_FULL),       // input
  .SYNC_RSTB(REG_RSTB),        // input
  .SYNC_CLK(REG_CLK),          // input
  .SYNC_SIG(REG_TXF_FULL_SYNC) // output
);

// REG_RXF_FULL
sc_clk_conv_lvl # (
  .P_INIT_VAL(0)
) cconv_rxf_full (
  .IN_RSTB(CAN_RSTB),          // input
  .IN_CLK(CAN_CLK),            // input
  .IN_SIG(REG_RXF_FULL),       // input
  .SYNC_RSTB(REG_RSTB),        // input
  .SYNC_CLK(REG_CLK),          // input
  .SYNC_SIG(REG_RXF_FULL_SYNC) // output
);

// REG_INT_TRNSDN
sc_clk_conv_pls # (
  .P_POLARITY(1) // 1: Positive 0: Negative
) cconv_int_trnsdn (
  .IN_RSTB(CAN_RSTB),            // input
  .IN_CLK(CAN_CLK),              // input
  .IN_PLS(REG_INT_TRNSDN),       // input
  .SYNC_RSTB(REG_RSTB),          // input
  .SYNC_CLK(REG_CLK),            // input
  .SYNC_PLS(REG_INT_TRNSDN_SYNC) // output
);

// REG_INT_ARBLST
sc_clk_conv_pls # (
  .P_POLARITY(1) // 1: Positive 0: Negative
) cconv_int_arblst (
  .IN_RSTB(CAN_RSTB),            // input
  .IN_CLK(CAN_CLK),              // input
  .IN_PLS(REG_INT_ARBLST),       // input
  .SYNC_RSTB(REG_RSTB),          // input
  .SYNC_CLK(REG_CLK),            // input
  .SYNC_PLS(REG_INT_ARBLST_SYNC) // output
);

// REG_INT_RCVDN
sc_clk_conv_pls # (
  .P_POLARITY(1) // 1: Positive 0: Negative
) cconv_int_rcvdn (
  .IN_RSTB(CAN_RSTB),           // input
  .IN_CLK(CAN_CLK),             // input
  .IN_PLS(REG_INT_RCVDN),       // input
  .SYNC_RSTB(REG_RSTB),         // input
  .SYNC_CLK(REG_CLK),           // input
  .SYNC_PLS(REG_INT_RCVDN_SYNC) // output
);

// REG_INT_RXFVAL
sc_clk_conv_lvl # (
  .P_INIT_VAL(0)
) cconv_int_rxfval (
  .IN_RSTB(CAN_RSTB),            // input
  .IN_CLK(CAN_CLK),              // input
  .IN_SIG(REG_INT_RXFVAL),       // input
  .SYNC_RSTB(REG_RSTB),          // input
  .SYNC_CLK(REG_CLK),            // input
  .SYNC_SIG(REG_INT_RXFVAL_SYNC) // output
);

// REG_INT_CRCER
sc_clk_conv_pls # (
  .P_POLARITY(1) // 1: Positive 0: Negative
) cconv_int_crcer (
  .IN_RSTB(CAN_RSTB),           // input
  .IN_CLK(CAN_CLK),             // input
  .IN_PLS(REG_INT_CRCER),       // input
  .SYNC_RSTB(REG_RSTB),         // input
  .SYNC_CLK(REG_CLK),           // input
  .SYNC_PLS(REG_INT_CRCER_SYNC) // output
);

// REG_INT_FMER
sc_clk_conv_pls # (
  .P_POLARITY(1) // 1: Positive 0: Negative
) cconv_int_fmer (
  .IN_RSTB(CAN_RSTB),          // input
  .IN_CLK(CAN_CLK),            // input
  .IN_PLS(REG_INT_FMER),       // input
  .SYNC_RSTB(REG_RSTB),        // input
  .SYNC_CLK(REG_CLK),          // input
  .SYNC_PLS(REG_INT_FMER_SYNC) // output
);

// REG_INT_STFER
sc_clk_conv_pls # (
  .P_POLARITY(1) // 1: Positive 0: Negative
) cconv_int_stfer (
  .IN_RSTB(CAN_RSTB),           // input
  .IN_CLK(CAN_CLK),             // input
  .IN_PLS(REG_INT_STFER),       // input
  .SYNC_RSTB(REG_RSTB),         // input
  .SYNC_CLK(REG_CLK),           // input
  .SYNC_PLS(REG_INT_STFER_SYNC) // output
);

// REG_INT_BITER
sc_clk_conv_pls # (
  .P_POLARITY(1) // 1: Positive 0: Negative
) cconv_int_biter (
  .IN_RSTB(CAN_RSTB),           // input
  .IN_CLK(CAN_CLK),             // input
  .IN_PLS(REG_INT_BITER),       // input
  .SYNC_RSTB(REG_RSTB),         // input
  .SYNC_CLK(REG_CLK),           // input
  .SYNC_PLS(REG_INT_BITER_SYNC) // output
);

// REG_INT_ACKER
sc_clk_conv_pls # (
  .P_POLARITY(1) // 1: Positive 0: Negative
) cconv_int_acker (
  .IN_RSTB(CAN_RSTB),           // input
  .IN_CLK(CAN_CLK),             // input
  .IN_PLS(REG_INT_ACKER),       // input
  .SYNC_RSTB(REG_RSTB),         // input
  .SYNC_CLK(REG_CLK),           // input
  .SYNC_PLS(REG_INT_ACKER_SYNC) // output
);

// REG_INT_BUSOFF
sc_clk_conv_pls # (
  .P_POLARITY(1) // 1: Positive 0: Negative
) cconv_int_busoff (
  .IN_RSTB(CAN_RSTB),            // input
  .IN_CLK(CAN_CLK),              // input
  .IN_PLS(REG_INT_BUSOFF),       // input
  .SYNC_RSTB(REG_RSTB),          // input
  .SYNC_CLK(REG_CLK),            // input
  .SYNC_PLS(REG_INT_BUSOFF_SYNC) // output
);

// REG_TXHPB_FULL
sc_clk_conv_lvl # (
  .P_INIT_VAL(0)
) cconv_txhpb_full (
  .IN_RSTB(CAN_RSTB),            // input
  .IN_CLK(CAN_CLK),              // input
  .IN_SIG(REG_TXHPB_FULL),       // input
  .SYNC_RSTB(REG_RSTB),          // input
  .SYNC_CLK(REG_CLK),            // input
  .SYNC_SIG(REG_TXHPB_FULL_SYNC) // output
);

// REG_INT_TXHBOVF
sc_clk_conv_pls # (
  .P_POLARITY(1) // 1: Positive 0: Negative
) cconv_int_txhbovf (
  .IN_RSTB(CAN_RSTB),             // input
  .IN_CLK(CAN_CLK),               // input
  .IN_PLS(REG_INT_TXHBOVF),       // input
  .SYNC_RSTB(REG_RSTB),           // input
  .SYNC_CLK(REG_CLK),             // input
  .SYNC_PLS(REG_INT_TXHBOVF_SYNC) // output
);

// REG_INT_RXFOVF
sc_clk_conv_pls # (
  .P_POLARITY(1) // 1: Positive 0: Negative
) cconv_int_rxfovf (
  .IN_RSTB(CAN_RSTB),             // input
  .IN_CLK(CAN_CLK),               // input
  .IN_PLS(REG_INT_RXFOVF),        // input
  .SYNC_RSTB(REG_RSTB),           // input
  .SYNC_CLK(REG_CLK),             // input
  .SYNC_PLS(REG_INT_RXFOVF_SYNC)  // output
);

endmodule
