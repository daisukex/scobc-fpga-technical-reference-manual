//-----------------------------------------------
// Module: sc_can_msg_strg
//  Space Cubics CAN Controller Message Storage Module
//-----------------------------------------------
// Copyright © 2021 Space Cubics, LLC.
//-----------------------------------------------
module sc_can_msg_strg # (
  parameter SC_CAN_FIFO_DEPTH = 6,
  parameter SC_CAN_CLK_ASYNC  = 1, // 1: Two Phase Asynchronous 0: Single Phase Synchronous
  parameter SC_CAN_PRIO_MGMT  = 1
) (
  // System Interface
  input REG_RSTB,
  input REG_CLK,
  input CAN_RSTB,
  input CAN_CLK,

  // Register Interface
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
  output REG_INT_RXFUDF,

  // Bit Stream Processor Interface
  output BSP_TXPM_RVAL,
  input BSP_TXF_REN,
  output [99:0] BSP_TXF_RDATA,
  input BSP_TXF_RD_END,
  output [SC_CAN_FIFO_DEPTH:0] BSP_TXF1_CAP,
  output [SC_CAN_FIFO_DEPTH:0] BSP_TXF2_CAP,
  output [SC_CAN_FIFO_DEPTH:0] BSP_TXF3_CAP,
  output [SC_CAN_FIFO_DEPTH:0] BSP_TXF4_CAP,

  output BSP_TXHPB_DVALID,
  input BSP_TXHPB_REN,
  output [99:0] BSP_TXHPB_RDATA,
  input BSP_TXHPB_RD_END,

  input BSP_RXF_WEN,
  input [99:0] BSP_RXF_WDATA,
  output [SC_CAN_FIFO_DEPTH:0] BSP_RXF1_CAP,
  output [SC_CAN_FIFO_DEPTH:0] BSP_RXF2_CAP,
  output [SC_CAN_FIFO_DEPTH:0] BSP_RXF3_CAP,
  output [SC_CAN_FIFO_DEPTH:0] BSP_RXF4_CAP
);

wire [3:0] w_txf_wen;
wire [31:0] w_txf_wdata [0:3];
wire [3:0] w_txf_ovf;
wire [31:0] w_txf_rdata [0:3];
wire [SC_CAN_FIFO_DEPTH:0] w_txf_cap [0:3];
wire [SC_CAN_FIFO_DEPTH:0] w_txf_cap_rsync [0:3];

wire [31:0] w_rxf_wdata [0:3];
wire [3:0] w_rxf_ovf;
wire [3:0] w_rxf_ren;
wire [31:0] w_rxf_rdata [0:3];
wire [3:0] w_rxf_udf;
wire [SC_CAN_FIFO_DEPTH:0] w_rxf_cap [0:3];
wire [SC_CAN_FIFO_DEPTH:0] w_rxf_cap_wsync [0:3];

wire [SC_CAN_FIFO_DEPTH-1:0] w_txpm_wadr;
wire [SC_CAN_FIFO_DEPTH-1:0] w_txpm_radr;

assign w_txf_wen = {REG_TXF4_WEN, REG_TXF3_WEN, REG_TXF2_WEN, REG_TXF1_WEN};
assign w_txf_wdata[0] = REG_TXF1_WDATA;
assign w_txf_wdata[1] = {28'h0, REG_TXF2_WDATA};
assign w_txf_wdata[2] = REG_TXF3_WDATA;
assign w_txf_wdata[3] = REG_TXF4_WDATA;
assign REG_INT_TXFOVF = |w_txf_ovf;
assign w_txf_rdata[1][31:4] = 28'h0;
assign BSP_TXF_RDATA = {w_txf_rdata[0], w_txf_rdata[1][3:0], w_txf_rdata[2], w_txf_rdata[3]};
assign BSP_TXF1_CAP = w_txf_cap_rsync[0];
assign BSP_TXF2_CAP = w_txf_cap_rsync[1];
assign BSP_TXF3_CAP = w_txf_cap_rsync[2];
assign BSP_TXF4_CAP = w_txf_cap_rsync[3];

assign w_rxf_wdata[0] = BSP_RXF_WDATA[99:68];
assign w_rxf_wdata[1] = {28'h0, BSP_RXF_WDATA[67:64]};
assign w_rxf_wdata[2] = BSP_RXF_WDATA[63:32];
assign w_rxf_wdata[3] = BSP_RXF_WDATA[31:0];
assign REG_INT_RXFOVF = |w_rxf_ovf;
assign w_rxf_ren = {REG_RXF4_REN, REG_RXF3_REN, REG_RXF2_REN, REG_RXF1_REN};
assign w_rxf_rdata[1][31:4] = 28'h0;
assign REG_RXF1_RDATA = w_rxf_rdata[0];
assign REG_RXF2_RDATA = w_rxf_rdata[1][3:0];
assign REG_RXF3_RDATA = w_rxf_rdata[2];
assign REG_RXF4_RDATA = w_rxf_rdata[3];
assign REG_INT_RXFUDF = |w_rxf_udf;
assign BSP_RXF1_CAP = w_rxf_cap_wsync[0];
assign BSP_RXF2_CAP = w_rxf_cap_wsync[1];
assign BSP_RXF3_CAP = w_rxf_cap_wsync[2];
assign BSP_RXF4_CAP = w_rxf_cap_wsync[3];

genvar gn;
generate
  if (SC_CAN_PRIO_MGMT) begin

    // TX Priority Controller
    sc_can_tx_prio_ctl # (
      .SC_CAN_MEM_AD_WIDTH(SC_CAN_FIFO_DEPTH),
      .SC_CAN_CLK_ASYNC(SC_CAN_CLK_ASYNC)
    ) tx_prio_ctl (
      .WR_RSTB(REG_RSTB),                               // input
      .WR_CLK(REG_CLK),                                 // input
      .RD_RSTB(CAN_RSTB),                               // input
      .RD_CLK(CAN_CLK),                                 // input

      // Write Port (WR_CLK Sync)
      .TXPM_WEN(w_txf_wen),                             // input [3:0]
      .TXPM_WADR(w_txpm_wadr),                          // output [SC_CAN_MEM_AD_WIDTH-1:0]

      .TXPM_RST(REG_TXF_RST),                           // input

      .TXPM_FULL(/*open*/),                             // output
      .TXPM_OVERFLOW(w_txf_ovf[0]),                     // output
      .TXPM_OVER_TH_LVL({SC_CAN_FIFO_DEPTH+1{1'b0}}),   // input [SC_CAN_MEM_AD_WIDTH:0]
      .TXPM_OVER_TH(/*open*/),                          // output

      .TXPM1_DATA_COUNT(w_txf_cap[0]),                  // output [SC_CAN_MEM_AD_WIDTH:0]
      .TXPM2_DATA_COUNT(w_txf_cap[1]),                  // output [SC_CAN_MEM_AD_WIDTH:0]
      .TXPM3_DATA_COUNT(w_txf_cap[2]),                  // output [SC_CAN_MEM_AD_WIDTH:0]
      .TXPM4_DATA_COUNT(w_txf_cap[3]),                  // output [SC_CAN_MEM_AD_WIDTH:0]

      // Read Port (RD_CLK Sync)
      .TXPM_RVAL(BSP_TXPM_RVAL),                        // output
      .TXPM_REN(BSP_TXF_REN),                           // input
      .TXPM_RADR(w_txpm_radr),                          // output [SC_CAN_MEM_AD_WIDTH-1:0]
      .PRIO_SEARCH_RDATA(w_txf_rdata[0]),               // input [31:0]
      .TXPM_RD_END(BSP_TXF_RD_END),                     // input

      .TXPM_EMPTY(/*open*/),                            // output
      .TXPM_UNDERFLOW(/*open*/),                        // output
      .TXPM_UNDER_TH_LVL({SC_CAN_FIFO_DEPTH+1{1'b0}}),  // input [SC_CAN_MEM_AD_WIDTH:0]
      .TXPM_UNDER_TH(/*open*/)                          // output
    );

    assign w_txf_ovf[3:1] = 0;
  end
  else begin
    assign w_txpm_wadr = 0;
    assign w_txpm_radr = 0;
    assign BSP_TXPM_RVAL = 0;
  end

  for(gn=0; gn<4; gn=gn+1) begin : can_fifo_gen
    if (SC_CAN_PRIO_MGMT) begin

      // TX_Memory
      sc_can_mem # (
        .SC_CAN_MEM_DT_WIDTH(32-(28*(gn==1))),
        .SC_CAN_MEM_AD_WIDTH(SC_CAN_FIFO_DEPTH),
        .SC_CAN_MEM_TYPE(0)                             // 0: BlockRAM 1: Shift Register
      ) tx_mem (
        .WR_RSTB(REG_RSTB),                             // input
        .WR_CLK(REG_CLK),                               // input
        .RD_RSTB(CAN_RSTB),                             // input
        .RD_CLK(CAN_CLK),                               // input

        // Write Port (WR_CLK Sync)
        .WR_EN(w_txf_wen[gn]),                          // input
        .WR_ADR(w_txpm_wadr),                           // input [SC_CAN_MEM_AD_WIDTH-1:0]
        .WR_DAT(w_txf_wdata[gn][0 +: 32-(28*(gn==1))]), // input [SC_CAN_MEM_DT_WIDTH-1:0]

        // Read Port (RD_CLK Sync)
        .RD_ADR(w_txpm_radr),                           // input [SC_CAN_MEM_AD_WIDTH-1:0]
        .RD_DAT(w_txf_rdata[gn][0 +: 32-(28*(gn==1))])  // output [SC_CAN_MEM_DT_WIDTH-1:0]
      );

    end
    else begin
      if (SC_CAN_CLK_ASYNC) begin

        // TX_FIFO
        sc_fifo_async # (
          .P_FIFO_WIDTH(32-(28*(gn==1))),
          .P_FIFO_DEPTH(SC_CAN_FIFO_DEPTH),
          .P_FIFO_TYPE(0),                               // 0: BlockRAM 1: Shift Register
          .P_DCNT_SYNC_TYPE(0)                           // 0: WR_CLK SYNC 1: RD_CLK SYNC
        ) tx_fifo (
          .WR_RSTB(REG_RSTB),                            // input
          .WR_CLK(REG_CLK),                              // input
          .RD_RSTB(CAN_RSTB),                            // input
          .RD_CLK(CAN_CLK),                              // input

          // Write Port (WR_CLK Sync)
          .WR_EN(w_txf_wen[gn]),                         // input
          .DIN(w_txf_wdata[gn][0 +: 32-(28*(gn==1))]),   // input [P_FIFO_WIDTH-1:0]

          .FIFO_RST(REG_TXF_RST),                        // input

          .FULL(/*open*/),                               // output
          .OVERFLOW(w_txf_ovf[gn]),                      // output
          .OVER_TH_LVL({SC_CAN_FIFO_DEPTH+1{1'b0}}),     // input [P_FIFO_DEPTH:0]
          .OVER_TH(/*open*/),                            // output

          // Read Port (RD_CLK Sync)
          .RD_EN(BSP_TXF_RD_END),                        // input
          .DOUT(w_txf_rdata[gn][0 +: 32-(28*(gn==1))]),  // output [P_FIFO_WIDTH-1:0]

          .EMPTY(/*open*/),                              // output
          .UNDERFLOW(/*open*/),                          // output
          .UNDER_TH_LVL({SC_CAN_FIFO_DEPTH+1{1'b0}}),    // input [P_FIFO_DEPTH:0]
          .UNDER_TH(/*open*/),                           // output

          // Data Count (DCNT_SYNC_TYPE Sync)
          .DATA_COUNT(w_txf_cap[gn])                     // output [P_FIFO_DEPTH:0]
        );

      end
      else begin

        // TX_FIFO
        sc_fifo # (
          .P_FIFO_WIDTH(32-(28*(gn==1))),
          .P_FIFO_DEPTH(SC_CAN_FIFO_DEPTH),
          .P_FIFO_TYPE(0)                                // 0: BlockRAM 1: Shift Register
        ) tx_fifo (
          .CLK(CAN_CLK),                                 // input
          .SRST_N(CAN_RSTB),                             // input
          .FIFO_RST(REG_TXF_RST),                        // input

          .WR_EN(w_txf_wen[gn]),                         // input
          .DIN(w_txf_wdata[gn][0 +: 32-(28*(gn==1))]),   // input [P_FIFO_WIDTH-1:0]
          .RD_EN(BSP_TXF_RD_END),                        // input
          .DOUT(w_txf_rdata[gn][0 +: 32-(28*(gn==1))]),  // output [P_FIFO_WIDTH-1:0]

          .OVER_TH_LVL({SC_CAN_FIFO_DEPTH+1{1'b0}}),     // input [P_FIFO_DEPTH:0]
          .UNDER_TH_LVL({SC_CAN_FIFO_DEPTH+1{1'b0}}),    // input [P_FIFO_DEPTH:0]

          .FULL(/*open*/),                               // output
          .EMPTY(/*open*/),                              // output
          .OVERFLOW(w_txf_ovf[gn]),                      // output
          .UNDERFLOW(/*open*/),                          // output
          .OVER_TH(/*open*/),                            // output
          .UNDER_TH(/*open*/),                           // output
          .DATA_COUNT(w_txf_cap[gn])                     // output [P_FIFO_DEPTH:0]
        );

      end
    end

    if (SC_CAN_CLK_ASYNC) begin

      // Clock Converter
      sc_clk_conv_bus # (
        .P_USE_VLD(0),
        .P_DT_WIDTH(SC_CAN_FIFO_DEPTH+1)
      ) cconv_txf_cap_rd (
        .IN_RSTB(REG_RSTB),              // input
        .IN_CLK(REG_CLK),                // input
        .IN_VALID(1'b0),                 // input
        .IN_DATA(w_txf_cap[gn]),         // input [P_DT_WIDTH-1:0]
        .SYNC_RSTB(CAN_RSTB),            // input
        .SYNC_CLK(CAN_CLK),              // input
        .SYNC_VALID(/*open*/),           // output
        .SYNC_DATA(w_txf_cap_rsync[gn])  // output [P_DT_WIDTH-1:0]
      );

      // RX_FIFO
      sc_fifo_async # (
        .P_FIFO_WIDTH(32-(28*(gn==1))),
        .P_FIFO_DEPTH(SC_CAN_FIFO_DEPTH),
        .P_FIFO_TYPE(0),                               // 0: BlockRAM 1: Shift Register
        .P_DCNT_SYNC_TYPE(1)                           // 0: WR_CLK SYNC 1: RD_CLK SYNC
      ) rx_fifo (
        .WR_RSTB(CAN_RSTB),                            // input
        .WR_CLK(CAN_CLK),                              // input
        .RD_RSTB(REG_RSTB),                            // input
        .RD_CLK(REG_CLK),                              // input

        // Write Port (WR_CLK Sync)
        .WR_EN(BSP_RXF_WEN),                           // input
        .DIN(w_rxf_wdata[gn][0 +: 32-(28*(gn==1))]),   // input [P_FIFO_WIDTH-1:0]

        .FIFO_RST(REG_RXF_RST),                        // input

        .FULL(/*open*/),                               // output
        .OVERFLOW(w_rxf_ovf[gn]),                      // output
        .OVER_TH_LVL({SC_CAN_FIFO_DEPTH+1{1'b0}}),     // input [P_FIFO_DEPTH:0]
        .OVER_TH(/*open*/),                            // output

        // Read Port (RD_CLK Sync)
        .RD_EN(w_rxf_ren[gn]),                         // input
        .DOUT(w_rxf_rdata[gn][0 +: 32-(28*(gn==1))]),  // output [P_FIFO_WIDTH-1:0]

        .EMPTY(/*open*/),                              // output
        .UNDERFLOW(w_rxf_udf[gn]),                     // output
        .UNDER_TH_LVL({SC_CAN_FIFO_DEPTH+1{1'b0}}),    // input [P_FIFO_DEPTH:0]
        .UNDER_TH(/*open*/),                           // output

        // Data Count (DCNT_SYNC_TYPE Sync)
        .DATA_COUNT(w_rxf_cap[gn])                     // output [P_FIFO_DEPTH:0]
      );

      // Clock Converter
      sc_clk_conv_bus # (
        .P_USE_VLD(0),
        .P_DT_WIDTH(SC_CAN_FIFO_DEPTH+1)
      ) cconv_rxf_cap_wr (
        .IN_RSTB(REG_RSTB),              // input
        .IN_CLK(REG_CLK),                // input
        .IN_VALID(1'b0),                 // input
        .IN_DATA(w_rxf_cap[gn]),         // input [P_DT_WIDTH-1:0]
        .SYNC_RSTB(CAN_RSTB),            // input
        .SYNC_CLK(CAN_CLK),              // input
        .SYNC_VALID(/*open*/),           // output
        .SYNC_DATA(w_rxf_cap_wsync[gn])  // output [P_DT_WIDTH-1:0]
      );

    end
    else begin

      assign w_txf_cap_rsync[gn] = w_txf_cap[gn];

      // RX_FIFO
      sc_fifo # (
        .P_FIFO_WIDTH(32-(28*(gn==1))),
        .P_FIFO_DEPTH(SC_CAN_FIFO_DEPTH),
        .P_FIFO_TYPE(0)                                // 0: BlockRAM 1: Shift Register
      ) rx_fifo (
        .CLK(CAN_CLK),                                 // input
        .SRST_N(CAN_RSTB),                             // input
        .FIFO_RST(REG_RXF_RST),                        // input

        .WR_EN(BSP_RXF_WEN),                           // input
        .DIN(w_rxf_wdata[gn][0 +: 32-(28*(gn==1))]),   // input [P_FIFO_WIDTH-1:0]
        .RD_EN(w_rxf_ren[gn]),                         // input
        .DOUT(w_rxf_rdata[gn][0 +: 32-(28*(gn==1))]),  // output [P_FIFO_WIDTH-1:0]

        .OVER_TH_LVL({SC_CAN_FIFO_DEPTH+1{1'b0}}),     // input [P_FIFO_DEPTH:0]
        .UNDER_TH_LVL({SC_CAN_FIFO_DEPTH+1{1'b0}}),    // input [P_FIFO_DEPTH:0]

        .FULL(/*open*/),                               // output
        .EMPTY(/*open*/),                              // output
        .OVERFLOW(w_rxf_ovf[gn]),                      // output
        .UNDERFLOW(w_rxf_udf[gn]),                     // output
        .OVER_TH(/*open*/),                            // output
        .UNDER_TH(/*open*/),                           // output
        .DATA_COUNT(w_rxf_cap[gn])                     // output [P_FIFO_DEPTH:0]
      );
      assign w_rxf_cap_wsync[gn] = w_rxf_cap[gn];

    end
  end
endgenerate

// TX High Priority Buffer
sc_can_txhpb can_txhpb (
  .CAN_CLK(CAN_CLK),                 // input
  .CAN_RSTB(CAN_RSTB),               // input

  .TXHPB_RST(REG_TXHPB_RST),         // input

  .TXHPB1_WEN(REG_TXHPB1_WEN),       // input
  .TXHPB1_WDATA(REG_TXHPB1_WDATA),   // input [31:0]
  .TXHPB2_WEN(REG_TXHPB2_WEN),       // input
  .TXHPB2_WDATA(REG_TXHPB2_WDATA),   // input [3:0]
  .TXHPB3_WEN(REG_TXHPB3_WEN),       // input
  .TXHPB3_WDATA(REG_TXHPB3_WDATA),   // input [31:0]
  .TXHPB4_WEN(REG_TXHPB4_WEN),       // input
  .TXHPB4_WDATA(REG_TXHPB4_WDATA),   // input [31:0]

  .TXHPB_DVALID(BSP_TXHPB_DVALID),   // output

  .TXHPB_REN(BSP_TXHPB_REN),         // input
  .TXHPB_RDATA(BSP_TXHPB_RDATA),     // output [99:0]
  .TXHPB_RD_END(BSP_TXHPB_RD_END),   // input

  .TXHPB_OVERFLOW(REG_INT_TXHBOVF),  // output
  .TXHPB_UNDERFLOW(/*open*/)         // output
);

endmodule
