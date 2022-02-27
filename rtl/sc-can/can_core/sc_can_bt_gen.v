//-----------------------------------------------
// Module: sc_can_bt_gen
//  Space Cubics CAN Controller Bit Timing Generator
//-----------------------------------------------
// Copyright © 2021 Space Cubics, LLC.
//-----------------------------------------------
module sc_can_bt_gen (
  // System Interface
  input CAN_RSTB,
  input CAN_CLK,

  // CAN Bus Signal
  input CAN_RX,

  // Bit Stream Processor Interface
  input [1:0] BSP_SYNC_STT,
  output reg RX_VALID,
  output reg RX_DATA,
  output TX_TRIG,

  // Register Interface
  input REG_CAN_EN,
  input [15:0] REG_TQPDIV,
  input [3:0] REG_TS1,
  input [2:0] REG_TS2,
  input [1:0] REG_SJW
);

reg [15:0] r_clk_cnt;
wire w_tq_en;

reg r_can_rx_p1;
reg r_can_rx_sync;
reg r_can_rx_sync_p1;

wire w_rx_nedge;
reg r_rx_nedge_lat;

wire w_hard_sync;
wire w_re_sync;
wire [2:0] w_sjw_value;

reg r_re_sync_mask;
reg [2:0] r_ts1_stop_time;
reg [2:0] r_ts1_stop_cnt;
reg [3:0] r_ts1_cnt;
reg [2:0] r_ts2_cnt;
reg [1:0] r_bts_state;

// Bit Stream Processor State
parameter STT_BSP_IDLE  = 2'd0,
          STT_BSP_RX    = 2'd1,
          STT_BSP_TX    = 2'd2;

// Bit Timing Segment State
parameter STT_BTS_SYNC  = 2'd0,
          STT_BTS_TS1   = 2'd1,
          STT_BTS_TS2   = 2'd2;

// Time Quantum Prescaler
always @ (posedge CAN_CLK or negedge CAN_RSTB) begin
  if (!CAN_RSTB) begin
    r_clk_cnt <= 0;
  end else if (~REG_CAN_EN) begin
    r_clk_cnt <= 0;
  end else begin
    if (r_clk_cnt >= REG_TQPDIV)
      r_clk_cnt <= 0;
    else
      r_clk_cnt <= r_clk_cnt + 1;
  end
end

assign w_tq_en = REG_CAN_EN & (r_clk_cnt == REG_TQPDIV);

// Synchronize CAN_RX to CAN_CLK
always @ (posedge CAN_CLK or negedge CAN_RSTB) begin
  if (!CAN_RSTB) begin
    r_can_rx_p1      <= 1'b1;
    r_can_rx_sync    <= 1'b1;
    r_can_rx_sync_p1 <= 1'b1;
  end else begin
    r_can_rx_p1      <= CAN_RX;
    r_can_rx_sync    <= r_can_rx_p1;
    r_can_rx_sync_p1 <= r_can_rx_sync;
  end
end

// CAN_RX Negative Edge Detection
assign w_rx_nedge = ~r_can_rx_sync & r_can_rx_sync_p1;

always @ (posedge CAN_CLK or negedge CAN_RSTB) begin
  if (!CAN_RSTB) begin
    r_rx_nedge_lat <= 0;
  end else if (~REG_CAN_EN) begin
    r_rx_nedge_lat <= 0;
  end else if (~w_tq_en) begin
    if (w_rx_nedge)
      r_rx_nedge_lat <= 1'b1;
  end else begin
    r_rx_nedge_lat <= 0;
  end
end

// CAN Network Synchronize Timing
assign w_hard_sync = w_tq_en & (w_rx_nedge | r_rx_nedge_lat) & (BSP_SYNC_STT == STT_BSP_IDLE);
assign w_re_sync   = w_tq_en & (w_rx_nedge | r_rx_nedge_lat) & (BSP_SYNC_STT == STT_BSP_RX) & ~r_re_sync_mask ;
assign w_sjw_value = {1'b0, REG_SJW} + 3'h1;

// Bit Segment Timing
always @ (posedge CAN_CLK or negedge CAN_RSTB) begin
  if (!CAN_RSTB) begin
    r_re_sync_mask  <= 0;
    r_ts1_stop_time <= 0;
    r_ts1_stop_cnt  <= 0;
    r_ts1_cnt       <= 0;
    r_ts2_cnt       <= 0;
    r_bts_state     <= STT_BTS_SYNC;
  end else if (~REG_CAN_EN) begin
    r_re_sync_mask  <= 0;
    r_ts1_stop_time <= 0;
    r_ts1_stop_cnt  <= 0;
    r_ts1_cnt       <= 0;
    r_ts2_cnt       <= 0;
    r_bts_state     <= STT_BTS_SYNC;
  end else if (w_tq_en) begin
    if (w_hard_sync) begin
      r_re_sync_mask  <= 0;
      r_ts1_stop_time <= 0;
      r_ts1_stop_cnt  <= 0;
      r_ts1_cnt       <= 0;
      r_ts2_cnt       <= 0;
      r_bts_state     <= STT_BTS_TS1;
    end else begin
      case (r_bts_state)
        STT_BTS_SYNC : begin
          r_re_sync_mask  <= 0;
          r_ts1_stop_time <= 0;
          r_ts1_stop_cnt  <= 0;
          r_ts1_cnt       <= 0;
          r_ts2_cnt       <= 0;
          r_bts_state     <= STT_BTS_TS1;
        end
        STT_BTS_TS1 : begin
          r_ts1_cnt <= r_ts1_cnt + 1;
          if (w_re_sync | (r_ts1_stop_time != r_ts1_stop_cnt)) begin
            r_ts1_cnt <= r_ts1_cnt;
          end else if (r_ts1_cnt >= REG_TS1) begin
            r_ts1_cnt   <= 0;
            r_bts_state <= STT_BTS_TS2;
          end
          if (w_re_sync) begin
            r_re_sync_mask <= 1'b1;
            r_ts1_stop_cnt <= 3'h1;
            if (r_ts1_cnt > {2'b0, REG_SJW})
              r_ts1_stop_time <= w_sjw_value;
            else
              r_ts1_stop_time <= r_ts1_cnt[2:0] + 3'h1;
          end else if (|r_ts1_stop_cnt) begin
            if (r_ts1_stop_cnt >= r_ts1_stop_time) begin
              r_ts1_stop_time <= 0;
              r_ts1_stop_cnt  <= 0;
            end else begin
              r_ts1_stop_cnt  <= r_ts1_stop_cnt + 1;
            end
          end
        end
        STT_BTS_TS2 : begin
          r_ts2_cnt <= r_ts2_cnt + 1;
          if (w_re_sync) begin
            if ((REG_TS2 - r_ts2_cnt) > w_sjw_value) begin
              r_re_sync_mask <= 1'b1;
              r_ts2_cnt      <= r_ts2_cnt + w_sjw_value + 3'h1;
            end else begin
              r_ts2_cnt <= 0;
              if ((REG_TS2 - r_ts2_cnt) < w_sjw_value)
                r_bts_state <= STT_BTS_TS1;
              else
                r_bts_state <= STT_BTS_SYNC;
            end
          end else if (r_ts2_cnt >= REG_TS2) begin
            r_re_sync_mask <= 0;
            r_ts2_cnt      <= 0;
            r_bts_state    <= STT_BTS_SYNC;
          end
        end
        default : begin
          r_re_sync_mask  <= 0;
          r_ts1_stop_time <= 0;
          r_ts1_stop_cnt  <= 0;
          r_ts1_cnt       <= 0;
          r_ts2_cnt       <= 0;
          r_bts_state     <= STT_BTS_SYNC;
        end
      endcase
    end
  end
end

// RX Data Sampling
always @ (posedge CAN_CLK or negedge CAN_RSTB) begin
  if (!CAN_RSTB) begin
    RX_VALID <= 0;
    RX_DATA  <= 1'b1;
  end else if (~REG_CAN_EN) begin
    RX_VALID <= 0;
    RX_DATA  <= 1'b1;
  end else begin
    RX_VALID <= 0;
    if (w_tq_en & (r_bts_state == STT_BTS_TS1) & (r_ts1_cnt == REG_TS1) &
        ~(w_hard_sync | w_re_sync | (r_ts1_stop_time != r_ts1_stop_cnt))) begin
      RX_VALID <= 1'b1;
      RX_DATA  <= r_can_rx_sync;
    end
  end
end

// Data Transmit Timing
assign TX_TRIG = w_tq_en & (r_bts_state == STT_BTS_TS2) &
                 ((r_ts2_cnt == REG_TS2) | (w_re_sync & ((REG_TS2 - r_ts2_cnt) <= w_sjw_value)));

endmodule
