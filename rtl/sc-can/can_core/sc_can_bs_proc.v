//-----------------------------------------------
// Module: sc_can_bs_proc
//  Space Cubics CAN Controller Bit Stream Processor
//-----------------------------------------------
// Copyright © 2021 Space Cubics, LLC.
//-----------------------------------------------
module sc_can_bs_proc # (
  parameter SC_CAN_FIFO_DEPTH = 6
) (
  // System Interface
  input CAN_RSTB,
  input CAN_CLK,

  // CAN Bus Signal
  output reg CAN_TX,

  // Bit Timing Generator Interface
  output [1:0] BSP_SYNC_STT,
  input RX_VALID,
  input RX_DATA,
  input TX_TRIG,

  // TX Message FIFO Interface
  output reg TXF_REN,
  input [99:0] TXF_RDATA,
  input [SC_CAN_FIFO_DEPTH:0] TXF1_CAP,
  input [SC_CAN_FIFO_DEPTH:0] TXF2_CAP,
  input [SC_CAN_FIFO_DEPTH:0] TXF3_CAP,
  input [SC_CAN_FIFO_DEPTH:0] TXF4_CAP,

  // TX High Priority Message Buffer Interface
  input TXHPB_DVALID,
  output reg TXHPB_REN,
  input [99:0] TXHPB_RDATA,

  // RX Message FIFO Interface
  output reg RXF_WEN,
  output reg [99:0] RXF_WDATA,
  input [SC_CAN_FIFO_DEPTH:0] RXF1_CAP,
  input [SC_CAN_FIFO_DEPTH:0] RXF2_CAP,
  input [SC_CAN_FIFO_DEPTH:0] RXF3_CAP,
  input [SC_CAN_FIFO_DEPTH:0] RXF4_CAP,

  // Register Interface
  input REG_CAN_EN,
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
  output reg REG_BUS_BUSY,
  output reg REG_ERRWRN,
  output reg [1:0] REG_ERR_STS,
  output reg REG_TXF_NEMPTY,
  output reg REG_TXF_FULL,
  output reg REG_RXF_FULL,
  output reg REG_INT_TRNSDN,
  output reg REG_INT_ARBLST,
  output reg REG_INT_RCVDN,
  output reg REG_INT_RXFVAL,
  output reg REG_INT_CRCER,
  output reg REG_INT_FMER,
  output reg REG_INT_STFER,
  output reg REG_INT_BITER,
  output reg REG_INT_ACKER,
  output reg REG_INT_BUSOFF
);

reg r_rx_valid_p1;
reg r_tx_trig_p1;
reg r_txf_ren_p1;
reg r_txf_ren_p2;
reg r_txhpb_ren_p1;
reg r_txhpb_ren_p2;

reg r_txf_val;
reg r_rxf_val;

wire [1:0] w_bsp_state;

reg [3:0] r_commu_mask_cnt;
reg r_commu_ok;

wire w_rx_sof_permit;
wire w_rx_start;

reg r_rx_data_before;
reg [2:0] r_rx_nchg_cnt;
wire w_rx_bitval;

wire w_rx_crc_en;
wire [14:0] w_rx_crc_cal;

reg [62:0] r_rx_data_sft;
reg [5:0] r_rx_bit_cnt;
reg [10:0] r_rx_id1;
reg r_rx_srr;
reg r_rx_ide;
reg [17:0] r_rx_id2;
reg r_rx_rtr;
reg [3:0] r_rx_dlc;
reg [63:0] r_rx_data;
reg [14:0] r_rx_crc;
reg r_rx_efg_trns;
reg r_edlm_bend;
reg [4:0] r_rx_state;
reg [4:0] r_rx_state_p1;

wire w_rx_eof_end;
wire w_rx_edlm_end;
wire w_rx_oldlm_end;
wire w_rx_itm_end;

reg r_tx_ack_flag;
reg r_crc_err_flag;
reg [2:0] r_rx_psv_ecnt;
reg r_rx_dlm_rcsv;
reg r_rx_ovld_dtct;

reg r_rx_id_chken;
wire w_rx_id_match;

reg r_tx_data_before;
reg [2:0] r_tx_nchg_cnt;
wire w_tx_bstfen;
wire w_tx_bitval;
wire w_tx_start_prmt;

reg r_tx_crc_en;
reg r_tx_crc_comp;
wire [14:0] w_tx_crc_cal;

wire w_tx_abt_field;
reg r_tx_abt_field_p1;
reg r_tx_abt_wait;
reg r_tx_abt_wait_p1;
reg r_tx_err_wait;

reg [10:0] r_tx_id1;
reg r_tx_srr;
reg r_tx_ide;
reg [17:0] r_tx_id2;
reg r_tx_rtr;
reg [3:0] r_tx_dlc;
reg [63:0] r_tx_data;

reg r_tx_node_on;
reg [63:0] r_tx_data_sft;
reg [5:0] r_tx_bit_cnt;
reg [4:0] r_tx_state;

wire w_tx_aerr_trns;
wire w_tx_perr_trns;
wire w_tx_ovld_trns;

wire w_error_detect;

reg r_rx_eoflg_fst;
reg [3:0] r_rx_eoflg_dcnt;
reg r_rx_eoflg_dpls;

reg r_rxcnt_err_det_u1;
reg r_rxcnt_effst_dom_u8;
reg r_rxcnt_eoflg_berr_u8;
reg r_rxcnt_eoflg_cndom_u8;

reg r_tx_epsv_ackerr;
reg r_rx_pef_dom_det;
reg r_tx_abt_dstferr;

reg r_txcnt_eflg_trns_u8;
reg r_txcnt_eoflg_berr_u8;
reg r_txcnt_eoflg_cndom_u8;

wire w_bus_off_req;
reg [3:0] r_boff_rcns_cnt;
reg [6:0] r_boff_rocc_cnt;
reg r_bus_recov_pls;
reg [1:0] r_err_sts_lat;

wire w_bus_no_connect;
wire w_err_cnt_rst;

// Main State
parameter STT_BSP_IDLE  = 2'd0,
          STT_BSP_RX    = 2'd1,
          STT_BSP_TX    = 2'd2;

// Receive Format State
parameter STT_RX_IDLE   = 5'd0,
          STT_RX_ID1    = 5'd2,
          STT_RX_SRR    = 5'd3,
          STT_RX_IDE    = 5'd4,
          STT_RX_ID2    = 5'd5,
          STT_RX_RTR    = 5'd6,
          STT_RX_RSV    = 5'd7,
          STT_RX_DLC    = 5'd8,
          STT_RX_DATA   = 5'd9,
          STT_RX_CRC    = 5'd10,
          STT_RX_CDLM   = 5'd11,
          STT_RX_ACK    = 5'd12,
          STT_RX_ADLM   = 5'd13,
          STT_RX_EOF    = 5'd14,
          STT_RX_AEFLG  = 5'd15,
          STT_RX_PEFLG  = 5'd16,
          STT_RX_EDLM   = 5'd17,
          STT_RX_OLFLG  = 5'd18,
          STT_RX_OLDLM  = 5'd19,
          STT_RX_ITM    = 5'd20;

// Transmit Format State
parameter STT_TX_IDLE   = 5'd0,
          STT_TX_SOF    = 5'd1,
          STT_TX_ID1    = 5'd2,
          STT_TX_SRR    = 5'd3,
          STT_TX_IDE    = 5'd4,
          STT_TX_ID2    = 5'd5,
          STT_TX_RTR    = 5'd6,
          STT_TX_RSV    = 5'd7,
          STT_TX_DLC    = 5'd8,
          STT_TX_DATA   = 5'd9,
          STT_TX_CRC    = 5'd10,
          STT_TX_CDLM   = 5'd11,
          STT_TX_ACK    = 5'd12,
          STT_TX_ADLM   = 5'd13,
          STT_TX_EOF    = 5'd14,
          STT_TX_AEFLG  = 5'd15,
          STT_TX_PEFLG  = 5'd16,
          STT_TX_EDLM   = 5'd17,
          STT_TX_OLFLG  = 5'd18,
          STT_TX_OLDLM  = 5'd19,
          STT_TX_ITM    = 5'd20;

// Error Status
parameter STT_STS_EN_OFF  = 2'd0,
          STT_STS_ERR_ACT = 2'd1,
          STT_STS_ERR_PSV = 2'd2,
          STT_STS_BUS_OFF = 2'd3;

// Signal Re-Timing
always @ (posedge CAN_CLK or negedge CAN_RSTB) begin
  if (!CAN_RSTB) begin
    r_rx_valid_p1  <= 0;
    r_tx_trig_p1   <= 0;
    r_txf_ren_p1   <= 0;
    r_txf_ren_p2   <= 0;
    r_txhpb_ren_p1 <= 0;
    r_txhpb_ren_p2 <= 0;
  end else begin
    r_rx_valid_p1  <= RX_VALID;
    r_tx_trig_p1   <= TX_TRIG;
    r_txf_ren_p1   <= TXF_REN;
    r_txf_ren_p2   <= r_txf_ren_p1;
    r_txhpb_ren_p1 <= TXHPB_REN;
    r_txhpb_ren_p2 <= r_txhpb_ren_p1;
  end
end

// FIFO Data Capacity
always @ (posedge CAN_CLK or negedge CAN_RSTB) begin
  if (!CAN_RSTB) begin
    r_txf_val    <= 0;
    r_rxf_val    <= 0;
  end else begin
    r_txf_val    <= |TXF1_CAP & |TXF2_CAP & |TXF3_CAP & |TXF4_CAP;
    r_rxf_val    <= |RXF1_CAP & |RXF2_CAP & |RXF3_CAP & |RXF4_CAP;
  end
end

// Bit Stream Processor Main State
assign w_bsp_state = (r_tx_state != STT_TX_IDLE) ? STT_BSP_TX :
                     (r_rx_state != STT_RX_IDLE) ? STT_BSP_RX :
                                                   STT_BSP_IDLE ;
assign BSP_SYNC_STT = ((w_bsp_state == STT_BSP_IDLE) |
                      (((r_tx_state <= STT_TX_SOF) | (r_tx_state == STT_TX_ITM)) & w_rx_sof_permit)) ? STT_BSP_IDLE :
                      ((w_bsp_state == STT_BSP_RX) & (r_rx_state != STT_RX_ACK))                     ? STT_BSP_RX :
                                                                                                       STT_BSP_TX ;

// CAN Node Status
always @ (posedge CAN_CLK or negedge CAN_RSTB) begin
  if (!CAN_RSTB) begin
    REG_BUS_BUSY   <= 0;
    REG_ERRWRN     <= 0;
    REG_TXF_NEMPTY <= 0;
    REG_TXF_FULL   <= 0;
    REG_RXF_FULL   <= 0;
  end else begin
    REG_BUS_BUSY   <= (w_bsp_state != STT_BSP_IDLE);
    REG_ERRWRN     <= (REG_TX_ECNT >= 8'd96) | (REG_RX_ECNT >= 8'd96);
    if (~REG_TXF_NEMPTY | ~REG_CAN_EN | REG_INT_TRNSDN)
      REG_TXF_NEMPTY <= r_txf_val;
    REG_TXF_FULL   <= TXF1_CAP[SC_CAN_FIFO_DEPTH] & TXF2_CAP[SC_CAN_FIFO_DEPTH] &
                      TXF3_CAP[SC_CAN_FIFO_DEPTH] & TXF4_CAP[SC_CAN_FIFO_DEPTH];
    REG_RXF_FULL   <= RXF1_CAP[SC_CAN_FIFO_DEPTH] & RXF2_CAP[SC_CAN_FIFO_DEPTH] &
                      RXF3_CAP[SC_CAN_FIFO_DEPTH] & RXF4_CAP[SC_CAN_FIFO_DEPTH];
  end
end

// CAN Bus Communication Mask Immediately After CAN Enabled
always @ (posedge CAN_CLK or negedge CAN_RSTB) begin
  if (!CAN_RSTB) begin
    r_commu_mask_cnt <= 0;
    r_commu_ok       <= 0;
  end else if (~REG_CAN_EN) begin
    r_commu_mask_cnt <= 0;
    r_commu_ok       <= 0;
  end else if (~r_commu_ok) begin
    if (RX_VALID) begin
      if (~RX_DATA) begin
        r_commu_mask_cnt <= 0;
      end else begin
        r_commu_mask_cnt <= r_commu_mask_cnt + 1;
        if (r_commu_mask_cnt >= 4'd10) begin
          r_commu_mask_cnt <= 0;
          r_commu_ok       <= 1'b1;
        end
      end
    end
  end
end

/*----------------------
// Receive Control
----------------------*/

// RX Start Flag
assign w_rx_sof_permit = (r_rx_state == STT_RX_IDLE) | w_rx_itm_end |
                         (r_tx_node_on & (r_rx_state == STT_RX_ITM) &
                         (r_err_sts_lat == STT_STS_ERR_PSV) & (r_rx_bit_cnt <= 6'd8));
assign w_rx_start = w_rx_sof_permit & RX_VALID & ~RX_DATA;

// RX Bit Stuffing Decode
always @ (posedge CAN_CLK or negedge CAN_RSTB) begin
  if (!CAN_RSTB) begin
    r_rx_data_before <= 1'b1;
    r_rx_nchg_cnt    <= 0;
  end else if (w_bus_no_connect) begin
    r_rx_data_before <= 1'b1;
    r_rx_nchg_cnt    <= 0;
  end else begin
    if (RX_VALID) begin
      r_rx_data_before <= RX_DATA;
      if (r_rx_state == STT_RX_IDLE) begin
        r_rx_nchg_cnt <= 0;
      end else begin
        if (RX_DATA != r_rx_data_before)
          r_rx_nchg_cnt <= 0;
        else
          r_rx_nchg_cnt <= r_rx_nchg_cnt + 1;
      end
    end
  end
end

assign w_rx_bitval = RX_VALID &
                     (((r_rx_state <= STT_RX_CDLM) & (r_rx_nchg_cnt < 3'h4)) |
                      (r_rx_state >= STT_RX_ACK));

// RX CRC Calculator
assign w_rx_crc_en = RX_VALID &
                     (r_rx_state >= STT_RX_ID1) & (r_rx_state <= STT_RX_DATA) &
                     (r_rx_nchg_cnt < 3'h4);

sc_can_crc_cal rx_crc_cal (
  .CAN_CLK(CAN_CLK),      // input
  .CAN_RSTB(CAN_RSTB),    // input
  .CRCINIT(w_rx_start),   // input
  .CRCEN(w_rx_crc_en),    // input
  .DIN(RX_DATA),          // input
  .CRC_CAL(w_rx_crc_cal)  // output [14:0]
);

// Frame Receive Control
always @ (posedge CAN_CLK or negedge CAN_RSTB) begin
  if (!CAN_RSTB) begin
    r_rx_data_sft <= 0;
    r_rx_bit_cnt  <= 0;
    r_rx_id1      <= 0;
    r_rx_srr      <= 0;
    r_rx_ide      <= 0;
    r_rx_id2      <= 0;
    r_rx_rtr      <= 0;
    r_rx_dlc      <= 0;
    r_rx_data     <= 0;
    r_rx_crc      <= 0;
    r_rx_efg_trns <= 0;
    r_edlm_bend   <= 0;
    r_rx_state    <= STT_RX_IDLE;
  end else if (w_bus_no_connect) begin
    r_rx_data_sft <= 0;
    r_rx_bit_cnt  <= 0;
    r_rx_id1      <= 0;
    r_rx_srr      <= 0;
    r_rx_ide      <= 0;
    r_rx_id2      <= 0;
    r_rx_rtr      <= 0;
    r_rx_dlc      <= 0;
    r_rx_data     <= 0;
    r_rx_crc      <= 0;
    r_rx_efg_trns <= 0;
    r_edlm_bend   <= 0;
    r_rx_state    <= STT_RX_IDLE;
  end else begin
    r_rx_efg_trns <= 0;
    if (w_tx_aerr_trns | w_tx_perr_trns | w_tx_ovld_trns) begin
      r_rx_bit_cnt <= 6'd5;
      if (w_tx_aerr_trns)
        r_rx_state <= STT_RX_AEFLG;
      if (w_tx_perr_trns)
        r_rx_state <= STT_RX_PEFLG;
      if (w_tx_ovld_trns)
        r_rx_state <= STT_RX_OLFLG;
    end else if (w_rx_bitval) begin
      r_rx_data_sft <= {r_rx_data_sft[61:0], RX_DATA};
      case (r_rx_state)
        STT_RX_IDLE : begin
          r_rx_bit_cnt <= 0;
          r_rx_id1     <= 0;
          r_rx_srr     <= 0;
          r_rx_ide     <= 0;
          r_rx_id2     <= 0;
          r_rx_rtr     <= 0;
          r_rx_dlc     <= 0;
          r_rx_data    <= 0;
          r_rx_crc     <= 0;
          r_edlm_bend  <= 0;
          if (w_rx_start) begin
            r_rx_bit_cnt <= 6'd10;
            r_rx_state   <= STT_RX_ID1;
          end
        end
        STT_RX_ID1 : begin
          r_rx_bit_cnt <= r_rx_bit_cnt - 1;
          if (~|r_rx_bit_cnt) begin
            r_rx_bit_cnt <= 0;
            r_rx_id1     <= {r_rx_data_sft[9:0], RX_DATA};
            r_rx_state   <= STT_RX_SRR;
          end
        end
        STT_RX_SRR : begin
          r_rx_bit_cnt <= 0;
          r_rx_srr     <= RX_DATA;
          r_rx_state   <= STT_RX_IDE;
        end
        STT_RX_IDE : begin
          r_rx_ide <= RX_DATA;
          if (~RX_DATA) begin
            r_rx_bit_cnt <= 0;
            r_rx_state   <= STT_RX_RSV;
          end else begin
            r_rx_bit_cnt <= 6'd17;
            r_rx_state   <= STT_RX_ID2;
          end
        end
        STT_RX_ID2 : begin
          r_rx_bit_cnt <= r_rx_bit_cnt - 1;
          if (~|r_rx_bit_cnt) begin
            r_rx_bit_cnt <= 0;
            r_rx_id2     <= {r_rx_data_sft[16:0], RX_DATA};
            r_rx_state   <= STT_RX_RTR;
          end
        end
        STT_RX_RTR : begin
          r_rx_bit_cnt <= 6'd1;
          r_rx_rtr     <= RX_DATA;
          r_rx_state   <= STT_RX_RSV;
        end
        STT_RX_RSV : begin
          r_rx_bit_cnt <= r_rx_bit_cnt - 1;
          if (~|r_rx_bit_cnt) begin
            r_rx_bit_cnt <= 6'd3;
            r_rx_state   <= STT_RX_DLC;
          end
        end
        STT_RX_DLC : begin
          r_rx_bit_cnt <= r_rx_bit_cnt - 1;
          if (~|r_rx_bit_cnt) begin
            r_rx_dlc <= {r_rx_data_sft[2:0], RX_DATA};
            if (~|{r_rx_data_sft[2:0], RX_DATA} | (~r_rx_ide & r_rx_srr) | (r_rx_ide & r_rx_rtr)) begin
              r_rx_bit_cnt <= 6'd14;
              r_rx_data    <= 0;
              r_rx_state   <= STT_RX_CRC;
            end else begin
              r_rx_state <= STT_RX_DATA;
              case ({r_rx_data_sft[2:0], RX_DATA})
                4'h1 :    r_rx_bit_cnt <= 6'd7;
                4'h2 :    r_rx_bit_cnt <= 6'd15;
                4'h3 :    r_rx_bit_cnt <= 6'd23;
                4'h4 :    r_rx_bit_cnt <= 6'd31;
                4'h5 :    r_rx_bit_cnt <= 6'd39;
                4'h6 :    r_rx_bit_cnt <= 6'd47;
                4'h7 :    r_rx_bit_cnt <= 6'd55;
                default : r_rx_bit_cnt <= 6'd63;
              endcase
            end
          end
        end
        STT_RX_DATA : begin
          r_rx_bit_cnt <= r_rx_bit_cnt - 1;
          if (~|r_rx_bit_cnt) begin
            r_rx_bit_cnt <= 6'd14;
            r_rx_state   <= STT_RX_CRC;
            case (r_rx_dlc)
              4'h1 :    r_rx_data <= {r_rx_data_sft[6:0],  RX_DATA, 56'h0};
              4'h2 :    r_rx_data <= {r_rx_data_sft[14:0], RX_DATA, 48'h0};
              4'h3 :    r_rx_data <= {r_rx_data_sft[22:0], RX_DATA, 40'h0};
              4'h4 :    r_rx_data <= {r_rx_data_sft[30:0], RX_DATA, 32'h0};
              4'h5 :    r_rx_data <= {r_rx_data_sft[38:0], RX_DATA, 24'h0};
              4'h6 :    r_rx_data <= {r_rx_data_sft[46:0], RX_DATA, 16'h0};
              4'h7 :    r_rx_data <= {r_rx_data_sft[54:0], RX_DATA,  8'h0};
              default : r_rx_data <= {r_rx_data_sft,       RX_DATA};
            endcase
          end
        end
        STT_RX_CRC : begin
          r_rx_bit_cnt <= r_rx_bit_cnt - 1;
          if (~|r_rx_bit_cnt) begin
            r_rx_bit_cnt <= 0;
            r_rx_crc     <= {r_rx_data_sft[13:0], RX_DATA};
            r_rx_state   <= STT_RX_CDLM;
          end
        end
        STT_RX_CDLM : begin
          r_rx_bit_cnt <= 0;
          r_rx_state   <= STT_RX_ACK;
        end
        STT_RX_ACK : begin
          r_rx_bit_cnt <= 0;
          r_rx_state   <= STT_RX_ADLM;
        end
        STT_RX_ADLM : begin
          r_rx_bit_cnt <= 6'd6;
          r_rx_state   <= STT_RX_EOF;
        end
        STT_RX_EOF : begin
          r_rx_bit_cnt <= r_rx_bit_cnt - 1;
          if (~|r_rx_bit_cnt) begin
            r_rx_state <= STT_RX_ITM;
            if (r_tx_node_on & (r_err_sts_lat == STT_STS_ERR_PSV))
              r_rx_bit_cnt <= 6'd10;
            else
              r_rx_bit_cnt <= 6'd2;
          end
        end
        STT_RX_AEFLG : begin
          r_rx_bit_cnt <= r_rx_bit_cnt - 1;
          if (~|r_rx_bit_cnt) begin
            r_rx_bit_cnt  <= 6'd7;
            r_rx_efg_trns <= 1'b1;
            r_rx_state    <= STT_RX_EDLM;
          end
        end
        STT_RX_PEFLG : begin
          if (~|r_rx_bit_cnt & (r_rx_psv_ecnt >= 4) & (RX_DATA == r_rx_data_before)) begin
            r_rx_bit_cnt  <= 6'd7;
            r_rx_efg_trns <= 1'b1;
            r_rx_state    <= STT_RX_EDLM;
          end else if (|r_rx_bit_cnt) begin
            r_rx_bit_cnt <= r_rx_bit_cnt - 1;
          end
        end
        STT_RX_EDLM : begin
          r_edlm_bend <= 1'b1;
          if ((r_rx_bit_cnt != 6'd7) | RX_DATA)
            r_rx_bit_cnt <= r_rx_bit_cnt - 1;
          if (~|r_rx_bit_cnt) begin
            r_edlm_bend <= 0;
            r_rx_state  <= STT_RX_ITM;
            if (r_tx_node_on & (r_err_sts_lat == STT_STS_ERR_PSV))
              r_rx_bit_cnt <= 6'd10;
            else
              r_rx_bit_cnt <= 6'd2;
          end
        end
        STT_RX_OLFLG : begin
          r_rx_bit_cnt <= r_rx_bit_cnt - 1;
          if (~|r_rx_bit_cnt) begin
            r_rx_bit_cnt <= 6'd7;
            r_rx_state   <= STT_RX_OLDLM;
          end
        end
        STT_RX_OLDLM : begin
          if ((r_rx_bit_cnt != 6'd7) | RX_DATA)
            r_rx_bit_cnt <= r_rx_bit_cnt - 1;
          if (~|r_rx_bit_cnt) begin
            r_rx_state <= STT_RX_ITM;
            if (r_tx_node_on & (r_err_sts_lat == STT_STS_ERR_PSV))
              r_rx_bit_cnt <= 6'd10;
            else
              r_rx_bit_cnt <= 6'd2;
          end
        end
        STT_RX_ITM : begin
          r_rx_bit_cnt <= r_rx_bit_cnt - 1;
          if (w_rx_start) begin
            r_rx_bit_cnt <= 6'd10;
            r_rx_state   <= STT_RX_ID1;
          end else if (~|r_rx_bit_cnt) begin
            r_rx_bit_cnt <= 0;
            r_rx_state   <= STT_RX_IDLE;
          end
        end
        default : begin
          r_rx_bit_cnt  <= 0;
          r_rx_id1      <= 0;
          r_rx_srr      <= 0;
          r_rx_ide      <= 0;
          r_rx_id2      <= 0;
          r_rx_rtr      <= 0;
          r_rx_dlc      <= 0;
          r_rx_data     <= 0;
          r_rx_crc      <= 0;
          r_rx_efg_trns <= 0;
          r_edlm_bend   <= 0;
          r_rx_state    <= STT_RX_IDLE;
        end
      endcase
    end
  end
end

always @ (posedge CAN_CLK or negedge CAN_RSTB) begin
  if (!CAN_RSTB) begin
    r_rx_state_p1 <= STT_RX_IDLE;
  end else begin
    r_rx_state_p1 <= r_rx_state;
  end
end

// RX Field END
assign w_rx_eof_end   = (r_rx_state == STT_RX_EOF)   & ~|r_rx_bit_cnt;
assign w_rx_edlm_end  = (r_rx_state == STT_RX_EDLM)  & ~|r_rx_bit_cnt;
assign w_rx_oldlm_end = (r_rx_state == STT_RX_OLDLM) & ~|r_rx_bit_cnt;
assign w_rx_itm_end   = (r_rx_state == STT_RX_ITM)   & ~|r_rx_bit_cnt;

// Trans ACK Flag
always @ (posedge CAN_CLK or negedge CAN_RSTB) begin
  if (!CAN_RSTB) begin
    r_tx_ack_flag  <= 0;
    r_crc_err_flag <= 0;
  end else if (w_bus_no_connect | w_error_detect) begin
    r_tx_ack_flag  <= 0;
    r_crc_err_flag <= 0;
  end else begin
    if (TX_TRIG) begin
      if ((~r_tx_node_on | REG_SELF_TMODE) & r_rx_state == STT_RX_CDLM & (r_rx_nchg_cnt < 3'h4))
        r_tx_ack_flag <= 1'b1;
      else
        r_tx_ack_flag <= 0;
    end
    if (REG_INT_CRCER)
      r_crc_err_flag <= 1'b1;
    else if ((r_rx_state_p1 == STT_RX_ADLM) & r_rx_valid_p1)
      r_crc_err_flag <= 0;
  end
end

// RX Passive Error Flag Counter
always @ (posedge CAN_CLK or negedge CAN_RSTB) begin
  if (!CAN_RSTB) begin
    r_rx_psv_ecnt <= 0;
  end else if (w_bus_no_connect) begin
    r_rx_psv_ecnt <= 0;
  end else begin
    if (r_rx_state == STT_RX_PEFLG) begin
      if (RX_VALID) begin
        if ((r_rx_bit_cnt == 6'd5) | (RX_DATA != r_rx_data_before))
          r_rx_psv_ecnt <= 0;
        else
          r_rx_psv_ecnt <= r_rx_psv_ecnt + 1;
      end
    end else begin
      r_rx_psv_ecnt <= 0;
    end
  end
end

// RX Delimiter First Recessive Bit Receive
always @ (posedge CAN_CLK or negedge CAN_RSTB) begin
  if (!CAN_RSTB) begin
    r_rx_dlm_rcsv <= 0;
  end else if (w_bus_no_connect) begin
    r_rx_dlm_rcsv <= 0;
  end else begin
    if ((r_rx_state == STT_RX_EDLM) | (r_rx_state == STT_RX_OLDLM)) begin
      if ((r_rx_bit_cnt == 6'd7) & RX_VALID & RX_DATA)
        r_rx_dlm_rcsv <= 1'b1;
    end else begin
      r_rx_dlm_rcsv <= 0;
    end
  end
end

// RX Overload Detect
always @ (posedge CAN_CLK or negedge CAN_RSTB) begin
  if (!CAN_RSTB) begin
    r_rx_ovld_dtct <= 0;
  end else if (w_bus_no_connect) begin
    r_rx_ovld_dtct <= 0;
  end else begin
    r_rx_ovld_dtct <= 0;
    if (RX_VALID & ~RX_DATA) begin
      if (r_rx_state == STT_RX_ITM & ~w_rx_itm_end) begin
        if (r_tx_node_on & (r_err_sts_lat == STT_STS_ERR_PSV)) begin
          if (r_rx_bit_cnt >= 6'd9)
            r_rx_ovld_dtct <= 1'b1;
        end else begin
          r_rx_ovld_dtct <= 1'b1;
        end
      end else if (~r_tx_node_on & (w_rx_eof_end | w_rx_edlm_end | w_rx_oldlm_end)) begin
        r_rx_ovld_dtct <= 1'b1;
      end
    end
  end
end

// RX Acceptance Filter
always @ (posedge CAN_CLK or negedge CAN_RSTB) begin
  if (!CAN_RSTB) begin
    r_rx_id_chken <= 0;
  end else begin
    r_rx_id_chken <= (~r_tx_node_on | REG_SELF_TMODE) & r_rx_valid_p1 & w_rx_eof_end & ~w_error_detect;
  end
end

sc_can_acp_fil can_acp_fil (
  .CAN_CLK(CAN_CLK),                    // input
  .CAN_RSTB(CAN_RSTB),                  // input

  .ID_CHKEN(r_rx_id_chken),             // input

  .RX_ID1(r_rx_id1),                    // input [10:0]
  .RX_SRR(r_rx_srr),                    // input
  .RX_IDE(r_rx_ide),                    // input
  .RX_ID2(r_rx_id2),                    // input [17:0]
  .RX_RTR(r_rx_rtr),                    // input

  .REG_ACF_EN(REG_ACF_EN),              // input [3:0]
  .REG_ACF1_ID_MASK(REG_ACF1_ID_MASK),  // input [31:0]
  .REG_ACF1_ID_VAL(REG_ACF1_ID_VAL),    // input [31:0]
  .REG_ACF2_ID_MASK(REG_ACF2_ID_MASK),  // input [31:0]
  .REG_ACF2_ID_VAL(REG_ACF2_ID_VAL),    // input [31:0]
  .REG_ACF3_ID_MASK(REG_ACF3_ID_MASK),  // input [31:0]
  .REG_ACF3_ID_VAL(REG_ACF3_ID_VAL),    // input [31:0]
  .REG_ACF4_ID_MASK(REG_ACF4_ID_MASK),  // input [31:0]
  .REG_ACF4_ID_VAL(REG_ACF4_ID_VAL),    // input [31:0]

  .ID_MATCH(w_rx_id_match)              // output
);

// Receive Data to RX Message FIFO
always @ (posedge CAN_CLK or negedge CAN_RSTB) begin
  if (!CAN_RSTB) begin
    RXF_WEN   <= 0;
    RXF_WDATA <= 0;
  end else if (w_bus_no_connect) begin
    RXF_WEN   <= 0;
    RXF_WDATA <= 0;
  end else begin
    RXF_WEN <= 0;
    if (w_rx_id_match)
      RXF_WEN   <= 1'b1;
      RXF_WDATA <= {r_rx_id1,
                    r_rx_srr,
                    r_rx_ide,
                    r_rx_id2,
                    r_rx_rtr,
                    r_rx_dlc,
                    r_rx_data};
  end
end

/*----------------------
// Transmit Control
----------------------*/

// TX Bit Stuffing Encode
always @ (posedge CAN_CLK or negedge CAN_RSTB) begin
  if (!CAN_RSTB) begin
    r_tx_data_before <= 1'b1;
    r_tx_nchg_cnt    <= 0;
  end else if (w_bus_no_connect) begin
    r_tx_data_before <= 1'b1;
    r_tx_nchg_cnt    <= 0;
  end else begin
    if (TX_TRIG)
      r_tx_data_before <= CAN_TX;
    if (r_tx_state == STT_TX_IDLE) begin
      r_tx_nchg_cnt <= 0;
    end else if (r_tx_trig_p1) begin
      if (CAN_TX != r_tx_data_before)
        r_tx_nchg_cnt <= 0;
      else
        r_tx_nchg_cnt <= r_tx_nchg_cnt + 1;
    end
  end
end

assign w_tx_bstfen = (r_tx_nchg_cnt >= 3'h4) & (r_tx_state <= STT_TX_CDLM);
assign w_tx_bitval = TX_TRIG & ~w_tx_bstfen;
assign w_tx_start_prmt = r_tx_trig_p1 & ((w_bsp_state == STT_BSP_IDLE) | ((w_bsp_state == STT_BSP_RX) & w_rx_itm_end));

// TX CRC Calculator
always @ (posedge CAN_CLK or negedge CAN_RSTB) begin
  if (!CAN_RSTB) begin
    r_tx_crc_en   <= 0;
    r_tx_crc_comp <= 0;
  end else begin
    r_tx_crc_en   <= 0;
    r_tx_crc_comp <= r_tx_crc_en & (r_tx_state == STT_TX_CRC);
    if (w_tx_bitval & (w_bsp_state == STT_BSP_TX) & (r_tx_state <= STT_TX_DATA))
      r_tx_crc_en <= 1'b1;
  end
end

sc_can_crc_cal tx_crc_cal (
  .CAN_CLK(CAN_CLK),          // input
  .CAN_RSTB(CAN_RSTB),        // input
  .CRCINIT(w_tx_start_prmt),  // input
  .CRCEN(r_tx_crc_en),        // input
  .DIN(CAN_TX),               // input
  .CRC_CAL(w_tx_crc_cal)      // output [14:0]
);

// Arbitration/Error Resend Control
assign w_tx_abt_field = (w_bsp_state == STT_BSP_TX) & (r_rx_state >= STT_RX_ID1) &
                         ((~r_tx_ide & ((r_rx_state <= STT_RX_SRR) |
                                       ((r_rx_state == STT_RX_IDE) & (r_rx_nchg_cnt >= 3'h4)))) |
                           (r_tx_ide & ((r_rx_state <= STT_RX_RTR) |
                                       ((r_rx_state == STT_RX_RSV) & (r_rx_bit_cnt == 6'd1) & (r_rx_nchg_cnt >= 3'h4)))));

always @ (posedge CAN_CLK or negedge CAN_RSTB) begin
  if (!CAN_RSTB) begin
    r_tx_abt_field_p1 <= 0;
    r_tx_abt_wait     <= 0;
    r_tx_abt_wait_p1  <= 0;
    r_tx_err_wait     <= 0;
  end else begin
    r_tx_abt_field_p1 <= w_tx_abt_field;
    r_tx_abt_wait_p1  <= r_tx_abt_wait;
    if (~r_commu_ok | (w_tx_start_prmt & (REG_ERR_STS != STT_STS_BUS_OFF))) begin
      r_tx_abt_wait <= 0;
      r_tx_err_wait <= 0;
    end else begin
      if (w_tx_abt_field & RX_VALID & CAN_TX & ~RX_DATA & ~((r_rx_nchg_cnt >= 3'h4) & ~r_rx_data_before))
        r_tx_abt_wait <= 1'b1;
      if (r_tx_node_on & w_error_detect & (r_rx_state_p1 != STT_RX_OLFLG) & (r_rx_state_p1 != STT_RX_OLDLM))
        r_tx_err_wait <= 1'b1;
    end
  end
end

// Frame Transmit Control
always @ (posedge CAN_CLK or negedge CAN_RSTB) begin
  if (!CAN_RSTB) begin
    r_tx_id1  <= 0;
    r_tx_srr  <= 0;
    r_tx_ide  <= 0;
    r_tx_id2  <= 0;
    r_tx_rtr  <= 0;
    r_tx_dlc  <= 0;
    r_tx_data <= 0;
  end else if (~r_commu_ok) begin
    r_tx_id1  <= 0;
    r_tx_srr  <= 0;
    r_tx_ide  <= 0;
    r_tx_id2  <= 0;
    r_tx_rtr  <= 0;
    r_tx_dlc  <= 0;
    r_tx_data <= 0;
  end else begin
    if (r_txhpb_ren_p2) begin
      r_tx_id1  <= TXHPB_RDATA[99:89];
      r_tx_srr  <= TXHPB_RDATA[88];
      r_tx_ide  <= TXHPB_RDATA[87];
      r_tx_id2  <= TXHPB_RDATA[86:69];
      r_tx_rtr  <= TXHPB_RDATA[68];
      r_tx_dlc  <= TXHPB_RDATA[67:64];
      r_tx_data <= TXHPB_RDATA[63:0];
    end else if (r_txf_ren_p2) begin
      r_tx_id1  <= TXF_RDATA[99:89];
      r_tx_srr  <= TXF_RDATA[88];
      r_tx_ide  <= TXF_RDATA[87];
      r_tx_id2  <= TXF_RDATA[86:69];
      r_tx_rtr  <= TXF_RDATA[68];
      r_tx_dlc  <= TXF_RDATA[67:64];
      r_tx_data <= TXF_RDATA[63:0];
    end
  end
end

always @ (posedge CAN_CLK or negedge CAN_RSTB) begin
  if (!CAN_RSTB) begin
    r_tx_node_on  <= 0;
    r_tx_data_sft <= {64{1'b1}};
    r_tx_bit_cnt  <= 0;
    TXF_REN       <= 0;
    TXHPB_REN     <= 0;
    r_tx_state    <= STT_TX_IDLE;
  end else if (w_bus_no_connect) begin
    r_tx_node_on  <= 0;
    r_tx_data_sft <= {64{1'b1}};
    r_tx_bit_cnt  <= 0;
    TXF_REN       <= 0;
    TXHPB_REN     <= 0;
    r_tx_state    <= STT_TX_IDLE;
  end else begin
    if (w_tx_abt_field & RX_VALID & CAN_TX & ~RX_DATA & ~((r_rx_nchg_cnt >= 3'h4) & ~r_rx_data_before)) begin
      r_tx_node_on  <= 0;
      r_tx_data_sft <= {64{1'b1}};
      r_tx_bit_cnt  <= 0;
      r_tx_state    <= STT_TX_IDLE;
    end
    if (w_tx_bitval)
      r_tx_data_sft <= {r_tx_data_sft[62:0], 1'b1};
    TXF_REN   <= 0;
    TXHPB_REN <= 0;
    if (w_error_detect) begin
      r_tx_bit_cnt <= 6'd5;
      if (r_err_sts_lat == STT_STS_ERR_ACT) begin
        r_tx_data_sft <= {6'h0, {58{1'b1}}};
        r_tx_state    <= STT_TX_AEFLG;
      end else begin
        r_tx_data_sft <= {64{1'b1}};
        r_tx_state    <= STT_TX_PEFLG;
      end
    end else if (r_rx_ovld_dtct) begin
      r_tx_bit_cnt  <= 6'd5;
      r_tx_data_sft <= {6'h0, {58{1'b1}}};
      r_tx_state    <= STT_TX_OLFLG;
    end else begin
      case (r_tx_state)
        STT_TX_IDLE : begin
          r_tx_node_on  <= 0;
          r_tx_data_sft <= {64{1'b1}};
          r_tx_bit_cnt  <= 0;
          if (w_tx_start_prmt &
              (r_tx_abt_wait | r_tx_err_wait | TXHPB_DVALID | r_txf_val)) begin
            r_tx_node_on  <= 1'b1;
            r_tx_data_sft <= {1'b0, {63{1'b1}}};
            r_tx_bit_cnt  <= 0;
            r_tx_state    <= STT_TX_SOF;
            if (~(r_tx_abt_wait | r_tx_err_wait)) begin
              if (TXHPB_DVALID)
                TXHPB_REN <= 1'b1;
              else if (r_txf_val)
                TXF_REN <= 1'b1;
            end
          end
        end
        STT_TX_SOF : begin
          if (w_tx_bitval | w_rx_start) begin
            r_tx_data_sft <= {r_tx_id1, {53{1'b1}}};
            r_tx_bit_cnt  <= 6'd10;
            r_tx_state    <= STT_TX_ID1;
          end
        end
        STT_TX_ID1 : begin
          if (w_tx_bitval) begin
            r_tx_bit_cnt <= r_tx_bit_cnt - 1;
            if (~|r_tx_bit_cnt) begin
              r_tx_data_sft <= {r_tx_srr, {63{1'b1}}};
              r_tx_bit_cnt  <= 0;
              r_tx_state    <= STT_TX_SRR;
            end
          end
        end
        STT_TX_SRR : begin
          if (w_tx_bitval) begin
            r_tx_data_sft <= {r_tx_ide, {63{1'b1}}};
            r_tx_bit_cnt  <= 0;
            r_tx_state    <= STT_TX_IDE;
          end
        end
        STT_TX_IDE : begin
          if (w_tx_bitval) begin
            if (~r_tx_ide) begin
              r_tx_data_sft <= {1'b0, {63{1'b1}}};
              r_tx_bit_cnt  <= 0;
              r_tx_state    <= STT_TX_RSV;
            end else begin
              r_tx_data_sft <= {r_tx_id2, {46{1'b1}}};
              r_tx_bit_cnt  <= 6'd17;
              r_tx_state    <= STT_TX_ID2;
            end
          end
        end
        STT_TX_ID2 : begin
          if (w_tx_bitval) begin
            r_tx_bit_cnt <= r_tx_bit_cnt - 1;
            if (~|r_tx_bit_cnt) begin
              r_tx_data_sft <= {r_tx_rtr, {63{1'b1}}};
              r_tx_bit_cnt  <= 0;
              r_tx_state    <= STT_TX_RTR;
            end
          end
        end
        STT_TX_RTR : begin
          if (w_tx_bitval) begin
            r_tx_data_sft <= {2'b00, {62{1'b1}}};
            r_tx_bit_cnt  <= 6'd1;
            r_tx_state    <= STT_TX_RSV;
          end
        end
        STT_TX_RSV : begin
          if (w_tx_bitval) begin
            r_tx_bit_cnt <= r_tx_bit_cnt - 1;
            if (~|r_tx_bit_cnt) begin
              r_tx_data_sft <= {r_tx_dlc, {60{1'b1}}};
              r_tx_bit_cnt  <= 6'd3;
              r_tx_state    <= STT_TX_DLC;
            end
          end
        end
        STT_TX_DLC : begin
          if (w_tx_bitval) begin
            r_tx_bit_cnt <= r_tx_bit_cnt - 1;
            if (~|r_tx_bit_cnt) begin
              if (~|r_tx_dlc | (~r_tx_ide & r_tx_srr) | (r_tx_ide & r_tx_rtr)) begin
                r_tx_bit_cnt <= 6'd14;
                r_tx_state   <= STT_TX_CRC;
              end else begin
                r_tx_data_sft <= r_tx_data;
                r_tx_state    <= STT_TX_DATA;
                case (r_tx_dlc)
                  4'h1 :    r_tx_bit_cnt <= 6'd7;
                  4'h2 :    r_tx_bit_cnt <= 6'd15;
                  4'h3 :    r_tx_bit_cnt <= 6'd23;
                  4'h4 :    r_tx_bit_cnt <= 6'd31;
                  4'h5 :    r_tx_bit_cnt <= 6'd39;
                  4'h6 :    r_tx_bit_cnt <= 6'd47;
                  4'h7 :    r_tx_bit_cnt <= 6'd55;
                  default : r_tx_bit_cnt <= 6'd63;
                endcase
              end
            end
          end
        end
        STT_TX_DATA : begin
          if (w_tx_bitval) begin
            r_tx_bit_cnt <= r_tx_bit_cnt - 1;
            if (~|r_tx_bit_cnt) begin
              r_tx_bit_cnt <= 6'd14;
              r_tx_state   <= STT_TX_CRC;
            end
          end
        end
        STT_TX_CRC : begin
          if (r_tx_crc_comp)
            r_tx_data_sft <= {w_tx_crc_cal, {49{1'b1}}};
          if (w_tx_bitval) begin
            r_tx_bit_cnt <= r_tx_bit_cnt - 1;
            if (~|r_tx_bit_cnt) begin
              r_tx_data_sft <= {64{1'b1}};
              r_tx_bit_cnt  <= 0;
              r_tx_state    <= STT_TX_CDLM;
            end
          end
        end
        STT_TX_CDLM : begin
          if (w_tx_bitval) begin
            r_tx_data_sft <= {64{1'b1}};
            r_tx_bit_cnt  <= 0;
            r_tx_state    <= STT_TX_ACK;
          end
        end
        STT_TX_ACK : begin
          if (w_tx_bitval) begin
            r_tx_data_sft <= {64{1'b1}};
            r_tx_bit_cnt  <= 0;
            r_tx_state    <= STT_TX_ADLM;
          end
        end
        STT_TX_ADLM : begin
          if (w_tx_bitval) begin
            r_tx_data_sft <= {64{1'b1}};
            r_tx_bit_cnt  <= 6'd6;
            r_tx_state    <= STT_TX_EOF;
          end
        end
        STT_TX_EOF : begin
          if (w_tx_bitval) begin
            r_tx_bit_cnt <= r_tx_bit_cnt - 1;
            if (~|r_tx_bit_cnt) begin
              r_tx_data_sft <= {64{1'b1}};
              r_tx_state    <= STT_TX_ITM;
              if (r_tx_node_on & (r_err_sts_lat == STT_STS_ERR_PSV))
                r_tx_bit_cnt <= 6'd10;
              else
                r_tx_bit_cnt <= 6'd2;
            end
          end
        end
        STT_TX_AEFLG : begin
          if (w_tx_bitval) begin
            r_tx_bit_cnt <= r_tx_bit_cnt - 1;
            if (~|r_tx_bit_cnt) begin
              r_tx_data_sft <= {64{1'b1}};
              r_tx_bit_cnt  <= 6'd7;
              r_tx_state    <= STT_TX_EDLM;
            end
          end
        end
        STT_TX_PEFLG : begin
          if (RX_VALID & ~|r_tx_bit_cnt &
              (r_rx_psv_ecnt >= 4) & (RX_DATA == r_rx_data_before)) begin
            r_tx_data_sft <= {64{1'b1}};
            r_tx_bit_cnt  <= 6'd7;
            r_tx_state    <= STT_TX_EDLM;
          end else if (w_tx_bitval & |r_tx_bit_cnt) begin
            r_tx_bit_cnt <= r_tx_bit_cnt - 1;
          end
        end
        STT_TX_EDLM : begin
          if (w_tx_bitval & ((r_tx_bit_cnt != 6'd6) | r_rx_dlm_rcsv)) begin
            r_tx_bit_cnt <= r_tx_bit_cnt - 1;
            if (~|r_tx_bit_cnt) begin
              r_tx_data_sft <= {64{1'b1}};
              r_tx_state    <= STT_TX_ITM;
              if (r_tx_node_on & (r_err_sts_lat == STT_STS_ERR_PSV))
                r_tx_bit_cnt <= 6'd10;
              else
                r_tx_bit_cnt <= 6'd2;
            end
          end
        end
        STT_TX_OLFLG : begin
          if (w_tx_bitval) begin
            r_tx_bit_cnt <= r_tx_bit_cnt - 1;
            if (~|r_tx_bit_cnt) begin
              r_tx_data_sft <= {64{1'b1}};
              r_tx_bit_cnt  <= 6'd7;
              r_tx_state    <= STT_TX_OLDLM;
            end
          end
        end
        STT_TX_OLDLM : begin
          if (w_tx_bitval & ((r_tx_bit_cnt != 6'd6) | r_rx_dlm_rcsv)) begin
            r_tx_bit_cnt <= r_tx_bit_cnt - 1;
            if (~|r_tx_bit_cnt) begin
              r_tx_data_sft <= {64{1'b1}};
              r_tx_state    <= STT_TX_ITM;
              if (r_tx_node_on & (r_err_sts_lat == STT_STS_ERR_PSV))
                r_tx_bit_cnt <= 6'd10;
              else
                r_tx_bit_cnt <= 6'd2;
            end
          end
        end
        STT_TX_ITM : begin
          if (w_rx_start) begin
            r_tx_node_on  <= 0;
            r_tx_data_sft <= {64{1'b1}};
            r_tx_bit_cnt  <= 0;
            r_tx_state    <= STT_TX_IDLE;
          end else if (w_tx_bitval) begin
            r_tx_bit_cnt <= r_tx_bit_cnt - 1;
            if (~|r_tx_bit_cnt) begin
              r_tx_node_on  <= 0;
              r_tx_data_sft <= {64{1'b1}};
              r_tx_bit_cnt  <= 0;
              r_tx_state    <= STT_TX_IDLE;
            end
          end
        end
        default : begin
          r_tx_node_on  <= 0;
          r_tx_data_sft <= {64{1'b1}};
          r_tx_bit_cnt  <= 0;
          TXF_REN       <= 0;
          TXHPB_REN     <= 0;
          r_tx_state    <= STT_TX_IDLE;
        end
      endcase
    end
  end
end

always @ (posedge CAN_CLK or negedge CAN_RSTB) begin
  if (!CAN_RSTB) begin
    CAN_TX <= 1'b1;
  end else if (w_bus_no_connect) begin
    CAN_TX <= 1'b1;
  end else if (TX_TRIG) begin
    CAN_TX <= 1'b1;
    if (r_tx_ack_flag) begin
      CAN_TX <= r_crc_err_flag;
    end else if (w_bsp_state == STT_BSP_TX) begin
      if (w_tx_bstfen)
        CAN_TX <= ~CAN_TX;
      else
        CAN_TX <= r_tx_data_sft[63];
    end
  end
end

// TX Error/Overload Trans start
assign w_tx_aerr_trns = TX_TRIG & (r_tx_state == STT_TX_AEFLG) & (r_tx_bit_cnt == 6'd5);
assign w_tx_perr_trns = TX_TRIG & (r_tx_state == STT_TX_PEFLG) & (r_tx_bit_cnt == 6'd5);
assign w_tx_ovld_trns = TX_TRIG & (r_tx_state == STT_TX_OLFLG) & (r_tx_bit_cnt == 6'd5);

/*----------------------
// Fault Confinement
----------------------*/
// Interrupt
always @ (posedge CAN_CLK or negedge CAN_RSTB) begin
  if (!CAN_RSTB) begin
    REG_INT_TRNSDN <= 0;
    REG_INT_ARBLST <= 0;
    REG_INT_RCVDN  <= 0;
    REG_INT_RXFVAL <= 0;
    REG_INT_CRCER  <= 0;
    REG_INT_FMER   <= 0;
    REG_INT_STFER  <= 0;
    REG_INT_BITER  <= 0;
    REG_INT_ACKER  <= 0;
    REG_INT_BUSOFF <= 0;
  end else begin
    REG_INT_TRNSDN <= r_tx_node_on & w_rx_eof_end & RX_VALID & RX_DATA;
    REG_INT_ARBLST <= r_tx_abt_wait & ~r_tx_abt_wait_p1;
    REG_INT_RCVDN  <= RXF_WEN;
    REG_INT_RXFVAL <= r_rxf_val;
    REG_INT_CRCER  <= (~r_tx_node_on | REG_SELF_TMODE) & (r_rx_state == STT_RX_CDLM) & r_rx_valid_p1 & (r_rx_nchg_cnt < 3'h4) &
                      (r_rx_crc != w_rx_crc_cal);
    REG_INT_FMER   <= w_rx_bitval & ~RX_DATA & ( (r_rx_state == STT_RX_CDLM) |
                                                 (r_rx_state == STT_RX_ADLM) |
                                                ((r_rx_state == STT_RX_EOF)   & (r_tx_node_on | ~w_rx_eof_end)) |
                                                ((r_rx_state == STT_RX_EDLM)  & (r_tx_node_on | ~w_rx_edlm_end)  & r_rx_dlm_rcsv) |
                                                ((r_rx_state == STT_RX_OLDLM) & (r_tx_node_on | ~w_rx_oldlm_end) & r_rx_dlm_rcsv));
    REG_INT_STFER  <= (r_rx_state != STT_RX_IDLE) & (r_rx_state <= STT_RX_CDLM) & RX_VALID &
                      (r_rx_nchg_cnt >= 3'h4) & (RX_DATA == r_rx_data_before);
    REG_INT_BITER  <= ((((w_bsp_state == STT_BSP_TX) & (r_tx_state != STT_TX_SOF)) |
                        ((w_bsp_state == STT_BSP_RX) & (r_rx_state == STT_RX_ACK))) &
                       (r_rx_state != STT_RX_ITM) & RX_VALID & (CAN_TX != RX_DATA)) &
                      ~((w_tx_abt_field | (r_rx_state == STT_RX_ACK) | (r_rx_state == STT_RX_PEFLG) |
                        (((r_rx_state == STT_RX_EDLM) | (r_rx_state == STT_RX_OLDLM)) &
                          (~r_rx_dlm_rcsv | (~r_tx_node_on & (w_rx_edlm_end | w_rx_oldlm_end))))) & ~RX_DATA);
    REG_INT_ACKER  <= (r_tx_state == STT_TX_ADLM) & RX_VALID & RX_DATA;
    REG_INT_BUSOFF <= w_bus_off_req;
  end
end

// Error Detect
assign w_error_detect = REG_INT_ACKER | REG_INT_BITER | REG_INT_FMER | REG_INT_STFER |
                        ((r_rx_state_p1 == STT_RX_ADLM) & r_rx_valid_p1 & r_crc_err_flag); // CRCER

// RX Error/Overload Flag Dominant bit Count
always @ (posedge CAN_CLK or negedge CAN_RSTB) begin
  if (!CAN_RSTB) begin
    r_rx_eoflg_fst  <= 0;
    r_rx_eoflg_dcnt <= 0;
    r_rx_eoflg_dpls <= 0;
  end else if (w_bus_no_connect) begin
    r_rx_eoflg_fst  <= 0;
    r_rx_eoflg_dcnt <= 0;
    r_rx_eoflg_dpls <= 0;
  end else begin
    r_rx_eoflg_dpls <= 0;
    if ((r_rx_state >= STT_RX_AEFLG) & (r_rx_state <= STT_RX_OLDLM)) begin
      if (r_rx_state == STT_RX_PEFLG)
        r_rx_eoflg_fst <= 1'b1;
      if (RX_VALID) begin
        if (RX_DATA) begin
          r_rx_eoflg_dcnt <= 0;
        end else if (r_rx_state != STT_RX_PEFLG) begin
          r_rx_eoflg_dcnt <= r_rx_eoflg_dcnt + 1;
          if ((~r_rx_eoflg_fst & r_rx_eoflg_dcnt >= 4'd13) |
              ( r_rx_eoflg_fst & r_rx_eoflg_dcnt >= 4'd7 ) ) begin
            r_rx_eoflg_fst  <= 1'b1;
            r_rx_eoflg_dcnt <= 0;
            r_rx_eoflg_dpls <= 1'b1;
          end
        end
      end
    end else begin
      r_rx_eoflg_fst  <= 0;
      r_rx_eoflg_dcnt <= 0;
    end
  end
end

// RX Error Count Pulse
always @ (posedge CAN_CLK or negedge CAN_RSTB) begin
  if (!CAN_RSTB) begin
    r_rxcnt_err_det_u1     <= 0;
    r_rxcnt_effst_dom_u8   <= 0;
    r_rxcnt_eoflg_berr_u8  <= 0;
    r_rxcnt_eoflg_cndom_u8 <= 0;
  end else begin
    r_rxcnt_err_det_u1     <= 0;
    r_rxcnt_effst_dom_u8   <= 0;
    r_rxcnt_eoflg_berr_u8  <= 0;
    r_rxcnt_eoflg_cndom_u8 <= 0;
    if (~r_tx_node_on) begin
      if (w_error_detect & ~(REG_INT_BITER & ((r_rx_state_p1 == STT_RX_AEFLG) | (r_rx_state_p1 == STT_RX_OLFLG))))
        r_rxcnt_err_det_u1 <= 1'b1;
      if ((r_rx_state == STT_RX_EDLM) & ~r_edlm_bend & RX_VALID & ~RX_DATA)
        r_rxcnt_effst_dom_u8 <= 1'b1;
      if (REG_INT_BITER & ((r_rx_state_p1 == STT_RX_AEFLG) | (r_rx_state_p1 == STT_RX_OLFLG)))
        r_rxcnt_eoflg_berr_u8 <= 1'b1;
      if (r_rx_eoflg_dpls)
        r_rxcnt_eoflg_cndom_u8 <= 1'b1;
    end
  end
end

// TX ACK Error Detect in Error Passive
// Dominant Detect in Passive Error Flag
// Stuff Error due to Dominant bit detection during arbitration Flag
always @ (posedge CAN_CLK or negedge CAN_RSTB) begin
  if (!CAN_RSTB) begin
    r_tx_epsv_ackerr <= 0;
    r_rx_pef_dom_det <= 0;
    r_tx_abt_dstferr <= 0;
  end else if (w_bus_no_connect) begin
    r_tx_epsv_ackerr <= 0;
    r_rx_pef_dom_det <= 0;
    r_tx_abt_dstferr <= 0;
  end else begin
    if (r_rx_valid_p1 & (r_rx_state == STT_RX_EDLM)) begin
      r_tx_epsv_ackerr <= 0;
      r_rx_pef_dom_det <= 0;
      r_tx_abt_dstferr <= 0;
    end else begin
      if ((r_err_sts_lat == STT_STS_ERR_PSV) & REG_INT_ACKER)
        r_tx_epsv_ackerr <= 1'b1;
      if ((r_rx_state == STT_RX_PEFLG) & RX_VALID & ~RX_DATA)
        r_rx_pef_dom_det <= 1'b1;
      if (r_tx_abt_field_p1 & REG_INT_STFER & ~r_rx_data_before)
        r_tx_abt_dstferr <= 1'b1;
    end
  end
end

// TX Error Count Pulse
always @ (posedge CAN_CLK or negedge CAN_RSTB) begin
  if (!CAN_RSTB) begin
    r_txcnt_eflg_trns_u8   <= 0;
    r_txcnt_eoflg_berr_u8  <= 0;
    r_txcnt_eoflg_cndom_u8 <= 0;
  end else begin
    r_txcnt_eflg_trns_u8   <= 0;
    r_txcnt_eoflg_berr_u8  <= 0;
    r_txcnt_eoflg_cndom_u8 <= 0;
    if (r_tx_node_on) begin
      if (r_rx_efg_trns & ~w_error_detect &
          ~((r_tx_epsv_ackerr & ~r_rx_pef_dom_det) | r_tx_abt_dstferr))
        r_txcnt_eflg_trns_u8 <= 1'b1;
      if (REG_INT_BITER & ((r_rx_state_p1 == STT_RX_AEFLG) | (r_rx_state_p1 == STT_RX_OLFLG)))
        r_txcnt_eoflg_berr_u8 <= 1'b1;
      if (r_rx_eoflg_dpls)
        r_txcnt_eoflg_cndom_u8 <= 1'b1;
    end
  end
end

// Error Counter
sc_can_err_cntr can_err_cntr (
  .CAN_CLK(CAN_CLK),                     // input
  .CAN_RSTB(CAN_RSTB),                   // input

  .CNTR_RST(w_err_cnt_rst),              // input

  .RX_CPLS1_U1(r_rxcnt_err_det_u1),      // input
  .RX_CPLS2_U8(r_rxcnt_effst_dom_u8),    // input
  .RX_CPLS3_U8(r_rxcnt_eoflg_berr_u8),   // input
  .RX_CPLS4_U8(r_rxcnt_eoflg_cndom_u8),  // input
  .RX_COMP_PLS(r_rx_id_chken),           // input
  .TX_CPLS1_U8(r_txcnt_eflg_trns_u8),    // input
  .TX_CPLS2_U8(r_txcnt_eoflg_berr_u8),   // input
  .TX_CPLS3_U8(r_txcnt_eoflg_cndom_u8),  // input
  .TX_COMP_PLS(REG_INT_TRNSDN),          // input

  .REG_TX_ECNT(REG_TX_ECNT),             // output [7:0]
  .REG_RX_ECNT(REG_RX_ECNT),             // output [7:0]
  .BUS_OFF_REQ(w_bus_off_req)            // output
);

// Error Status
always @ (posedge CAN_CLK or negedge CAN_RSTB) begin
  if (!CAN_RSTB) begin
    r_boff_rcns_cnt <= 0;
    r_boff_rocc_cnt <= 0;
    r_bus_recov_pls <= 0;
    REG_ERR_STS     <= STT_STS_EN_OFF;
  end else if (~r_commu_ok) begin
    r_boff_rcns_cnt <= 0;
    r_boff_rocc_cnt <= 0;
    r_bus_recov_pls <= 0;
    REG_ERR_STS     <= STT_STS_EN_OFF;
  end else begin
    r_bus_recov_pls <= 0;
    case (REG_ERR_STS)
      STT_STS_EN_OFF : begin
        r_boff_rcns_cnt <= 0;
        r_boff_rocc_cnt <= 0;
        REG_ERR_STS     <= STT_STS_ERR_ACT;
      end
      STT_STS_ERR_ACT : begin
        if ((REG_TX_ECNT >= 8'd128) | (REG_RX_ECNT >= 8'd128))
          REG_ERR_STS <= STT_STS_ERR_PSV;
      end
      STT_STS_ERR_PSV : begin
        if (w_bus_off_req)
          REG_ERR_STS <= STT_STS_BUS_OFF;
        else if ((REG_TX_ECNT < 8'd128) & (REG_RX_ECNT < 8'd128))
          REG_ERR_STS <= STT_STS_ERR_ACT;
      end
      STT_STS_BUS_OFF : begin
        if (r_bus_recov_pls) begin
          r_boff_rcns_cnt <= 0;
          r_boff_rocc_cnt <= 0;
          REG_ERR_STS     <= STT_STS_ERR_ACT;
        end else if (RX_VALID) begin
          if (~RX_DATA) begin
            r_boff_rcns_cnt <= 0;
          end else begin
            if (r_boff_rcns_cnt >= 4'd10) begin
              r_boff_rcns_cnt <= 0;
              if (&r_boff_rocc_cnt) begin
                r_boff_rocc_cnt <= 0;
                r_bus_recov_pls <= 1'b1;
              end else begin
                r_boff_rocc_cnt <= r_boff_rocc_cnt + 1;
              end
            end else begin
              r_boff_rcns_cnt <= r_boff_rcns_cnt + 1;
            end
          end
        end
      end
      default : begin
        r_boff_rcns_cnt <= 0;
        r_boff_rocc_cnt <= 0;
        REG_ERR_STS     <= STT_STS_EN_OFF;
      end
    endcase
  end
end

always @ (posedge CAN_CLK or negedge CAN_RSTB) begin
  if (!CAN_RSTB) begin
    r_err_sts_lat <= STT_STS_EN_OFF;
  end else if (~r_commu_ok) begin
    r_err_sts_lat <= STT_STS_EN_OFF;
  end else if (w_rx_start | w_tx_start_prmt) begin
    r_err_sts_lat <= REG_ERR_STS;
  end
end

assign w_bus_no_connect = ~r_commu_ok | (REG_ERR_STS == STT_STS_BUS_OFF);
assign w_err_cnt_rst = ~r_commu_ok | r_bus_recov_pls;

endmodule
