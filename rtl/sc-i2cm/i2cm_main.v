//-----------------------------------------------
// Module: i2cm_main
//  I2C Master Main Controller
//-----------------------------------------------
// Copyright © 2021 Space Cubics, LLC.
//-----------------------------------------------
module i2cm_main (
  // System Interface
  input  SYSCLK,
  input  SYSRST_N,

  // Register Interface
  input  REG_I2CM_EN,
  output REG_I2CM_SBUSY,
  output REG_I2CM_OBUSY,
  input  [15:0] REG_SCL_TOPROD,
  input  [15:0] REG_THDSTA,
  input  [15:0] REG_TSUSTO,
  input  [15:0] REG_TSUSTA,
  input  [15:0] REG_THIGH,
  input  [15:0] REG_THDDAT,
  input  [15:0] REG_TSUDAT,
  input  [15:0] REG_TBUF,
  input  [15:0] REG_SMPL_DELAY,
  output reg REG_INT_COMP,
  output reg REG_INT_ARB_LST,
  output reg REG_INT_ACK_ERR,
  output reg REG_INT_BIT_ERR,
  output reg REG_INT_SCL_TO,
  output REG_I2CM_EN_OFF,

  // TX DATA Interface
  output reg TX_DATA_REQ,
  input  [9:0] TX_DATA_IN,
  input  TX_DATA_READY,

  // RX DATA Interface
  output RX_DATA_VAL,
  output [7:0] RX_DATA_OUT,
  input  RX_DATA_READY,

  // I2C Interface
  input  SDA_IN,
  output reg SDA_OUT,
  input  SCL_IN,
  output reg SCL_OUT
);

reg r_sda_in_sync;
reg r_sda_in_asn;
reg r_sda_in_asn_p1;
reg r_scl_in_sync;
reg r_scl_in_asn;
reg r_scl_in_asn_p1;

wire w_sda_redge;
wire w_sda_fedge;
wire w_scl_redge;
wire w_scl_fedge;

reg r_smpl_cnt_en;
reg [15:0] r_smpl_cnt;
wire w_smpl_en;
reg [7:0] r_rx_data_sft;

reg r_tx_data_req_p1;
reg r_tx_data_req_p2;
reg r_tx_data_req_p3;
reg [9:0] r_tx_data_lat;
reg [1:0] r_next_condition;

wire w_tim_end;
wire [18:0] w_rxack_total_tim;
wire [18:0] w_restart_total_tim;
wire w_next_txd_rdtim;
reg [15:0] r_tim_cnt;
reg [3:0] r_tim_state;

reg r_rw_mode;
reg [1:0] r_tx_error_lat;
reg [2:0] r_bit_cnt;
reg [18:0] r_txd_req_cnt;
reg [7:0] r_rx_byte_set;
reg [7:0] r_rx_byte_cnt;
reg [3:0] r_main_state;

reg [7:0] r_1us_cnt;
reg [15:0] r_scl_to_cnt;
reg r_scl_cnt_msk;

// I2C Timing State
localparam P_T_IDLE     = 4'h0,
           P_T_HDSTA    = 4'h1,
           P_T_HDDAT    = 4'h2,
           P_T_SUDAT    = 4'h3,
           P_T_HIGH     = 4'h4,
           P_T_SUSTO    = 4'h5,
           P_T_BUF      = 4'h6,
           P_T_SUSTA    = 4'h7,
           P_T_TDTWAIT  = 4'h8;

// I2C Main State
localparam P_M_IDLE     = 4'h0,
           P_M_START    = 4'h1,
           P_M_TXDAT    = 4'h2,
           P_M_RXACK    = 4'h3,
           P_M_RXDAT    = 4'h4,
           P_M_TXACK    = 4'h5,
           P_M_TXNACK   = 4'h6,
           P_M_STOP     = 4'h7,
           P_M_RESTART  = 4'h8,
           P_M_TDTWAIT  = 4'h9,
           P_M_RDTWAIT  = 4'hA,
           P_M_RRDYWAIT = 4'hB,
           P_M_RSTAWAIT = 4'hC,
           P_M_OBUSY    = 4'hD;

// 1us Counter Value
localparam P_1US_CNT_VALUE = 8'h5F; // 96MHz

// I2C Signal Sync
always @ (posedge SYSCLK or negedge SYSRST_N) begin
  if (!SYSRST_N) begin
    r_sda_in_sync   <= 1'b1;
    r_sda_in_asn    <= 1'b1;
    r_sda_in_asn_p1 <= 1'b1;
    r_scl_in_sync   <= 1'b1;
    r_scl_in_asn    <= 1'b1;
    r_scl_in_asn_p1 <= 1'b1;
  end
  else begin
    r_sda_in_sync   <= SDA_IN;
    r_sda_in_asn    <= r_sda_in_sync;
    r_sda_in_asn_p1 <= r_sda_in_asn;
    r_scl_in_sync   <= SCL_IN;
    r_scl_in_asn    <= r_scl_in_sync;
    r_scl_in_asn_p1 <= r_scl_in_asn;
  end
end

// SDA/SCL Rise/Fall Edge
assign w_sda_redge = r_sda_in_asn & ~r_sda_in_asn_p1;
assign w_sda_fedge = ~r_sda_in_asn & r_sda_in_asn_p1;
assign w_scl_redge = r_scl_in_asn & ~r_scl_in_asn_p1;
assign w_scl_fedge = ~r_scl_in_asn & r_scl_in_asn_p1;

// SDA Sampling
always @ (posedge SYSCLK or negedge SYSRST_N) begin
  if (!SYSRST_N) begin
    r_smpl_cnt_en <= 0;
    r_smpl_cnt    <= 0;
  end
  else if (~REG_I2CM_EN | w_smpl_en) begin
    r_smpl_cnt_en <= 0;
    r_smpl_cnt    <= 0;
  end
  else if (w_scl_redge) begin
    r_smpl_cnt_en <= 1'b1;
    r_smpl_cnt    <= 16'h1;
  end
  else if (r_smpl_cnt_en) begin
    if (r_smpl_cnt >= REG_SMPL_DELAY)
      r_smpl_cnt <= 0;
    else
      r_smpl_cnt <= r_smpl_cnt + 1;
  end
end

assign w_smpl_en = (~|REG_SMPL_DELAY & w_scl_redge) |
                   (r_smpl_cnt_en & (r_smpl_cnt >= REG_SMPL_DELAY));

always @ (posedge SYSCLK or negedge SYSRST_N) begin
  if (!SYSRST_N)
    r_rx_data_sft <= 0;
  else if (w_smpl_en & (r_main_state == P_M_RXDAT))
    r_rx_data_sft <= {r_rx_data_sft[6:0], r_sda_in_asn};
end

// I2C TX Data Latch
always @ (posedge SYSCLK or negedge SYSRST_N) begin
  if (!SYSRST_N) begin
    r_tx_data_req_p1 <= 0;
    r_tx_data_req_p2 <= 0;
    r_tx_data_req_p3 <= 0;
    r_tx_data_lat    <= 0;
    r_next_condition <= 0;
  end
  else begin
    r_tx_data_req_p1 <= TX_DATA_REQ;
    r_tx_data_req_p2 <= r_tx_data_req_p1;
    r_tx_data_req_p3 <= r_tx_data_req_p2;
    if (r_tx_data_req_p2)
      r_tx_data_lat <= TX_DATA_IN;
    if (r_tx_data_req_p3)
      r_next_condition <= r_tx_data_lat[9:8];
  end
end

// I2C Timing Control
assign w_tim_end = ((r_tim_state == P_T_HDSTA) & (r_tim_cnt >= REG_THDSTA)) |
                   ((r_tim_state == P_T_HDDAT) & (r_tim_cnt >= REG_THDDAT)) |
                   ((r_tim_state == P_T_SUDAT) & (r_tim_cnt >= REG_TSUDAT)) |
                   ((r_tim_state == P_T_HIGH)  & (r_tim_cnt >= REG_THIGH) ) |
                   ((r_tim_state == P_T_SUSTO) & (r_tim_cnt >= REG_TSUSTO)) |
                   ((r_tim_state == P_T_BUF)   & (r_tim_cnt >= REG_TBUF)  ) |
                   ((r_tim_state == P_T_SUSTA) & (r_tim_cnt >= REG_TSUSTA)) ;

assign w_rxack_total_tim = {3'h0, REG_TSUDAT} +
                           {3'h0, REG_THIGH} +
                           {3'h0, REG_THDDAT} + 19'h2;
assign w_restart_total_tim = {3'h0, REG_TSUDAT} +
                             {3'h0, REG_TSUSTA} +
                             {3'h0, REG_THDSTA} +
                             {3'h0, REG_THDDAT} + 19'h3;
assign w_next_txd_rdtim = ((r_main_state == P_M_RXACK) &
                           ((r_txd_req_cnt == (w_rxack_total_tim - 19'h4)) |
                           ((r_tim_state == P_T_HIGH) & w_scl_fedge & (REG_THDDAT == 16'h3)))) |
                          ((r_main_state == P_M_RESTART) &
                           ((r_txd_req_cnt == (w_restart_total_tim - 19'h4)) |
                           ((r_tim_state == P_T_HDSTA) & w_scl_fedge & (REG_THDDAT == 16'h3)))) ;

always @ (posedge SYSCLK or negedge SYSRST_N) begin
  if (!SYSRST_N) begin
    r_tim_cnt   <= 0;
    TX_DATA_REQ <= 0;
    SDA_OUT     <= 1'b1;
    SCL_OUT     <= 1'b1;
    r_tim_state <= P_T_IDLE;
  end
  else if (~REG_I2CM_EN | REG_INT_ARB_LST) begin
    r_tim_cnt   <= 0;
    TX_DATA_REQ <= 0;
    SDA_OUT     <= 1'b1;
    SCL_OUT     <= 1'b1;
    if (r_main_state == P_M_OBUSY) begin
      if (r_scl_in_asn & w_sda_redge)
        r_tim_state <= P_T_BUF;
      else if (r_tim_state == P_T_BUF) begin
        if (w_sda_fedge | w_scl_fedge | w_tim_end)
          r_tim_state <= P_T_IDLE;
        else
          r_tim_cnt <= r_tim_cnt + 1;
      end
    end
    else
      r_tim_state <= P_T_IDLE;
  end
  else begin
    TX_DATA_REQ <= 0;
    case (r_tim_state)
      P_T_IDLE : begin
        r_tim_cnt <= 0;
        if (r_main_state == P_M_OBUSY) begin
          if (r_scl_in_asn & w_sda_redge)
            r_tim_state <= P_T_BUF;
        end
        else if (r_main_state == P_M_RRDYWAIT) begin
          if (RX_DATA_READY)
            r_tim_state <= P_T_SUDAT;
        end
        else begin
          if (TX_DATA_READY) begin
            TX_DATA_REQ <= 1'b1;
            if (r_main_state == P_M_IDLE) begin
              SDA_OUT     <= 0;
              r_tim_state <= P_T_HDSTA;
            end
            else
              r_tim_state <= P_T_TDTWAIT;
          end
        end
      end
      P_T_HDSTA : begin
        if (w_tim_end)
          r_tim_cnt <= 0;
        else if (w_scl_fedge)
          r_tim_cnt <= 16'h3;
        else
          r_tim_cnt <= r_tim_cnt + 1;
        if (w_next_txd_rdtim & TX_DATA_READY &
            ((r_main_state == P_M_RESTART) | r_rw_mode | ~|r_next_condition))
          TX_DATA_REQ <= 1'b1;
        if (w_tim_end | w_scl_fedge) begin
          SCL_OUT     <= 0;
          r_tim_state <= P_T_HDDAT;
        end
      end
      P_T_HDDAT : begin
        r_tim_cnt <= r_tim_cnt + 1;
        if (w_next_txd_rdtim & TX_DATA_READY &
            ((r_main_state == P_M_RESTART) | r_rw_mode | ~|r_next_condition))
          TX_DATA_REQ <= 1'b1;
        if (w_tim_end) begin
          r_tim_cnt   <= 0;
          r_tim_state <= P_T_SUDAT;
          if ((r_main_state == P_M_START) |
              (r_main_state == P_M_RESTART)) begin
            SDA_OUT <= r_tx_data_lat[7];
            if (r_main_state == P_M_RESTART & ~r_tx_data_req_p3)
              r_tim_state <= P_T_IDLE;
          end
          else if (r_main_state == P_M_TXDAT) begin
            if (&r_bit_cnt)
              SDA_OUT <= 1'b1;
            else if (r_tx_error_lat[1])
              SDA_OUT <= 0;
            else
              SDA_OUT <= r_tx_data_lat[4'h6 - {1'b0, r_bit_cnt}];
          end
          else if (r_main_state == P_M_RXACK) begin
            if (r_tx_error_lat[0] | (r_tx_error_lat[1] & ~r_rw_mode) | r_next_condition[0])
              SDA_OUT <= 0;
            else if (r_rw_mode | r_next_condition[1])
              SDA_OUT <= 1'b1;
            else
              SDA_OUT <= r_tx_data_lat[7];
            if (~r_tx_error_lat[0] & (~r_tx_error_lat[1] | r_rw_mode) &
                ~r_tx_data_req_p3 & ~|r_next_condition)
              r_tim_state <= P_T_IDLE;
          end
          else if (r_main_state == P_M_RXDAT) begin
            if (&r_bit_cnt) begin
              if (r_tx_error_lat[1])
                SDA_OUT <= 0;
              else if (r_rx_byte_cnt >= r_rx_byte_set)
                SDA_OUT <= 1'b1;
              else
                SDA_OUT <= 0;
            end
          end
          else if (r_main_state == P_M_TXACK) begin
            SDA_OUT <= 1'b1;
            if (~RX_DATA_READY)
              r_tim_state <= P_T_IDLE;
          end
          else if (r_main_state == P_M_TXNACK) begin
            if (r_next_condition[0])
              SDA_OUT <= 0;
            else if (r_next_condition[1])
              SDA_OUT <= 1'b1;
          end
        end
      end
      P_T_SUDAT : begin
        r_tim_cnt <= r_tim_cnt + 1;
        if (w_next_txd_rdtim & TX_DATA_READY &
            ((r_main_state == P_M_RESTART) | r_rw_mode | ~|r_next_condition))
          TX_DATA_REQ <= 1'b1;
        if (w_tim_end) begin
          r_tim_cnt <= 0;
          SCL_OUT   <= 1'b1;
          if (r_main_state == P_M_STOP)
            r_tim_state <= P_T_SUSTO;
          else if (r_main_state == P_M_RESTART)
            r_tim_state <= P_T_SUSTA;
          else
            r_tim_state <= P_T_HIGH;
        end
      end
      P_T_HIGH : begin
        if (w_next_txd_rdtim & TX_DATA_READY &
            ((r_main_state == P_M_RESTART) | r_rw_mode | ~|r_next_condition))
          TX_DATA_REQ <= 1'b1;
        if (w_tim_end)
          r_tim_cnt <= 0;
        else if (w_scl_fedge)
          r_tim_cnt <= 16'h3;
        else if (r_tim_cnt == 16'h2) begin
          if (w_scl_redge)
            r_tim_cnt <= 16'h3;
        end
        else
          r_tim_cnt <= r_tim_cnt + 1;
        if (w_tim_end | w_scl_fedge) begin
          SCL_OUT     <= 0;
          r_tim_state <= P_T_HDDAT;
        end
      end
      P_T_SUSTO : begin
        if (w_scl_fedge) begin
          r_tim_cnt   <= 0;
          SDA_OUT     <= 1'b1;
          r_tim_state <= P_T_IDLE;
        end
        else if (w_tim_end) begin
          r_tim_cnt   <= 0;
          SDA_OUT     <= 1'b1;
          r_tim_state <= P_T_BUF;
        end
        else if (r_tim_cnt == 16'h2) begin
          if (w_scl_redge)
            r_tim_cnt <= 16'h3;
        end
        else
          r_tim_cnt <= r_tim_cnt + 1;
      end
      P_T_BUF : begin
        if (w_sda_fedge | w_scl_fedge) begin
          r_tim_cnt   <= 0;
          SDA_OUT     <= 1'b1;
          r_tim_state <= P_T_IDLE;
        end
        else if (w_tim_end) begin
          r_tim_cnt <= 0;
          if (TX_DATA_READY & ~REG_I2CM_EN_OFF) begin
            TX_DATA_REQ <= 1'b1;
            SDA_OUT     <= 0;
            r_tim_state <= P_T_HDSTA;
          end
          else
            r_tim_state <= P_T_IDLE;
        end
        else
          r_tim_cnt <= r_tim_cnt + 1;
      end
      P_T_SUSTA : begin
        if (w_scl_fedge) begin
          r_tim_cnt   <= 0;
          SDA_OUT     <= 1'b1;
          r_tim_state <= P_T_IDLE;
        end
        else if (w_tim_end) begin
          r_tim_cnt   <= 0;
          SDA_OUT     <= 0;
          r_tim_state <= P_T_HDSTA;
        end
        else if (r_tim_cnt == 16'h2) begin
          if (w_scl_redge)
            r_tim_cnt <= 16'h3;
        end
        else
          r_tim_cnt <= r_tim_cnt + 1;
        if (w_next_txd_rdtim & TX_DATA_READY &
            ((r_main_state == P_M_RESTART) | r_rw_mode | ~|r_next_condition))
          TX_DATA_REQ <= 1'b1;
      end
      P_T_TDTWAIT : begin
        if (r_tx_data_req_p2) begin
          if (r_main_state == P_M_RDTWAIT)
            SDA_OUT <= 1'b1;
          else
            SDA_OUT <= TX_DATA_IN[7];
          r_tim_state <= P_T_SUDAT;
        end
      end
      default : begin
        r_tim_cnt   <= 0;
        TX_DATA_REQ <= 0;
        SDA_OUT     <= 1'b1;
        SCL_OUT     <= 1'b1;
        r_tim_state <= P_T_IDLE;
      end
    endcase
  end
end

// I2C State Control
always @ (posedge SYSCLK or negedge SYSRST_N) begin
  if (!SYSRST_N) begin
    r_rw_mode      <= 0;
    r_tx_error_lat <= 0;
    r_bit_cnt      <= 0;
    r_txd_req_cnt  <= 0;
    r_rx_byte_set  <= 0;
    r_rx_byte_cnt  <= 0;
    r_main_state   <= P_M_IDLE;
  end
  else if (~REG_I2CM_EN) begin
    r_rw_mode      <= 0;
    r_tx_error_lat <= 0;
    r_bit_cnt      <= 0;
    r_txd_req_cnt  <= 0;
    r_rx_byte_set  <= 0;
    r_rx_byte_cnt  <= 0;
    if (r_main_state == P_M_OBUSY) begin
      if ((r_tim_state == P_T_BUF) & w_tim_end)
        r_main_state <= P_M_IDLE;
    end
    else begin
      r_main_state <= P_M_IDLE;
      if ((r_main_state == P_M_IDLE) & w_sda_fedge)
        r_main_state <= P_M_OBUSY;
    end
  end
  else begin
    if (REG_INT_ACK_ERR)
      r_tx_error_lat[0] <= 1'b1;
    if (REG_INT_BIT_ERR)
      r_tx_error_lat[1] <= 1'b1;
    case (r_main_state)
      P_M_IDLE : begin
        r_rw_mode      <= 0;
        r_tx_error_lat <= 0;
        r_bit_cnt      <= 0;
        r_txd_req_cnt  <= 0;
        r_rx_byte_set  <= 0;
        r_rx_byte_cnt  <= 0;
        if (w_sda_fedge)
          r_main_state <= P_M_OBUSY;
        else if (TX_DATA_READY)
          r_main_state <= P_M_START;
      end
      P_M_START : begin
        if ((r_tim_state == P_T_HDDAT) & w_tim_end) begin
          r_rw_mode    <= r_tx_data_lat[0];
          r_main_state <= P_M_TXDAT;
        end
      end
      P_M_TXDAT : begin
        if (REG_INT_ARB_LST) begin
          r_rw_mode      <= 0;
          r_tx_error_lat <= 0;
          r_bit_cnt      <= 0;
          r_rx_byte_set  <= 0;
          r_main_state   <= P_M_OBUSY;
        end
        else if ((r_tim_state == P_T_HDDAT) & w_tim_end) begin
          r_bit_cnt <= r_bit_cnt + 1;
          if (&r_bit_cnt) begin
            r_bit_cnt    <= 0;
            r_main_state <= P_M_RXACK;
          end
          else if (r_tx_error_lat[1]) begin
            r_bit_cnt    <= 0;
            r_main_state <= P_M_STOP;
          end
        end
      end
      P_M_RXACK : begin
        if ((r_tim_state == P_T_HDDAT) & w_tim_end) begin
          r_txd_req_cnt <= 0;
          if (r_tx_error_lat[0])
            r_main_state <= P_M_STOP;
          else begin
            if (r_rw_mode) begin
              if (r_tx_data_req_p3) begin
                r_rx_byte_set <= r_tx_data_lat[7:0];
                if (RX_DATA_READY)
                  r_main_state <= P_M_RXDAT;
                else
                  r_main_state <= P_M_RRDYWAIT;
              end
              else
                r_main_state <= P_M_RDTWAIT;
            end
            else begin
              if (r_tx_error_lat[1])
                r_main_state <= P_M_STOP;
              else if (r_next_condition[1])
                r_main_state <= P_M_RESTART;
              else if (r_next_condition[0])
                r_main_state <= P_M_STOP;
              else if (r_tx_data_req_p3)
                r_main_state <= P_M_TXDAT;
              else
                r_main_state <= P_M_TDTWAIT;
            end
          end
        end
        else if (w_next_txd_rdtim)
          r_txd_req_cnt <= 0;
        else if ((r_tim_state == P_T_HIGH) & w_scl_fedge) begin
          if (REG_THDDAT < 16'h4)
            r_txd_req_cnt <= 0;
          else
            r_txd_req_cnt <= {3'h0, REG_TSUDAT} + {3'h0, REG_THIGH} + 19'h2;
        end
        else if (((r_tim_state != P_T_HIGH) | (r_tim_cnt != 16'h2)) |
                 ((r_tim_state == P_T_HIGH) & w_scl_redge))
          r_txd_req_cnt <= r_txd_req_cnt + 1;
      end
      P_M_RXDAT : begin
        if ((r_tim_state == P_T_HDDAT) & w_tim_end) begin
          r_bit_cnt <= r_bit_cnt + 1;
          if (&r_bit_cnt) begin
            r_bit_cnt <= 0;
            if (r_tx_error_lat[1]) begin
              r_rx_byte_cnt <= 0;
              r_main_state  <= P_M_STOP;
            end
            else if (r_rx_byte_cnt >= r_rx_byte_set) begin
              r_rx_byte_cnt <= 0;
              r_main_state  <= P_M_TXNACK;
            end
            else begin
              r_rx_byte_cnt <= r_rx_byte_cnt + 1;
              r_main_state  <= P_M_TXACK;
            end
          end
        end
      end
      P_M_TXACK : begin
        if ((r_tim_state == P_T_HDDAT) & w_tim_end) begin
          if (RX_DATA_READY)
            r_main_state <= P_M_RXDAT;
          else
            r_main_state <= P_M_RRDYWAIT;
        end
      end
      P_M_TXNACK : begin
        if ((r_tim_state == P_T_HDDAT) & w_tim_end) begin
          if (r_next_condition[1])
            r_main_state <= P_M_RESTART;
          else
            r_main_state <= P_M_STOP;
        end
      end
      P_M_STOP : begin
        if (r_tim_state == P_T_BUF) begin
          if (w_sda_fedge) begin
            r_rw_mode      <= 0;
            r_tx_error_lat <= 0;
            r_rx_byte_set  <= 0;
            r_main_state   <= P_M_OBUSY;
          end
          else if (w_tim_end) begin
            r_rw_mode      <= 0;
            r_tx_error_lat <= 0;
            r_rx_byte_set  <= 0;
            if (TX_DATA_READY & ~|r_tx_error_lat)
              r_main_state <= P_M_START;
            else
              r_main_state <= P_M_IDLE;
          end
        end
      end
      P_M_RESTART : begin
        if ((r_tim_state == P_T_HDDAT) & w_tim_end) begin
          r_tx_error_lat <= 0;
          r_txd_req_cnt  <= 0;
          r_rx_byte_set  <= 0;
          if (r_tx_data_req_p3) begin
            r_rw_mode    <= r_tx_data_lat[0];
            r_main_state <= P_M_TXDAT;
          end
          else
            r_main_state <= P_M_RSTAWAIT;
        end
        else if (w_next_txd_rdtim)
          r_txd_req_cnt <= 0;
        else if ((r_tim_state == P_T_HDSTA) & w_scl_fedge) begin
          if (REG_THDDAT < 16'h4)
            r_txd_req_cnt <= 0;
          else
            r_txd_req_cnt <= {3'h0, REG_TSUDAT} + {3'h0, REG_TSUSTA} +
                             {3'h0, REG_THDSTA} + 19'h3;
        end
        else if (((r_tim_state != P_T_HIGH) | (r_tim_cnt != 16'h2)) |
                 ((r_tim_state == P_T_HIGH) & w_scl_redge))
          r_txd_req_cnt <= r_txd_req_cnt + 1;
      end
      P_M_TDTWAIT : begin
        if (r_tx_data_req_p3)
          r_main_state <= P_M_TXDAT;
      end
      P_M_RDTWAIT : begin
        if (r_tx_data_req_p3) begin
          r_rx_byte_set <= r_tx_data_lat[7:0];
          if (RX_DATA_READY)
            r_main_state <= P_M_RXDAT;
          else
            r_main_state <= P_M_RRDYWAIT;
        end
      end
      P_M_RRDYWAIT : begin
        if (RX_DATA_READY)
          r_main_state <= P_M_RXDAT;
      end
      P_M_RSTAWAIT : begin
        if (r_tx_data_req_p3) begin
          r_rw_mode    <= r_tx_data_lat[0];
          r_main_state <= P_M_TXDAT;
        end
      end
      P_M_OBUSY : begin
        if ((r_tim_state == P_T_BUF) & w_tim_end) begin
          if (TX_DATA_READY)
            r_main_state <= P_M_START;
          else
            r_main_state <= P_M_IDLE;
        end
      end
      default : begin
        r_rw_mode      <= 0;
        r_tx_error_lat <= 0;
        r_bit_cnt      <= 0;
        r_rx_byte_set  <= 0;
        r_rx_byte_cnt  <= 0;
        r_main_state   <= P_M_IDLE;
      end
    endcase
  end
end

// I2C Master Bus Status
assign REG_I2CM_SBUSY = (r_main_state != P_M_IDLE) & (r_main_state != P_M_OBUSY);
assign REG_I2CM_OBUSY = (r_main_state == P_M_OBUSY);

// I2C Communication/Error Interrupt
always @ (posedge SYSCLK or negedge SYSRST_N) begin
  if (!SYSRST_N) begin
    REG_INT_COMP    <= 0;
    REG_INT_ARB_LST <= 0;
    REG_INT_ACK_ERR <= 0;
    REG_INT_BIT_ERR <= 0;
  end
  else begin
    REG_INT_COMP    <= (r_tim_state == P_T_SUSTO) & w_tim_end & ~|r_tx_error_lat;
    REG_INT_ARB_LST <= (r_main_state == P_M_TXDAT) & w_smpl_en & SDA_OUT & ~r_sda_in_asn;
    REG_INT_ACK_ERR <= (r_main_state == P_M_RXACK) & w_smpl_en & r_sda_in_asn;
    REG_INT_BIT_ERR <= w_smpl_en & r_sda_in_asn &
                       (((r_main_state == P_M_TXDAT) & ~SDA_OUT) |
                         (r_main_state == P_M_TXACK));
  end
end

// SCL Timeout Interrupt
always @ (posedge SYSCLK or negedge SYSRST_N) begin
  if (!SYSRST_N) begin
    r_1us_cnt      <= 0;
    r_scl_to_cnt   <= 0;
    r_scl_cnt_msk  <= 0;
    REG_INT_SCL_TO <= 0;
  end
  else if (~REG_I2CM_EN | ~|REG_SCL_TOPROD | r_scl_in_asn |
           (r_main_state == P_M_OBUSY) | (r_main_state >= P_M_TDTWAIT)) begin
    r_1us_cnt      <= 0;
    r_scl_to_cnt   <= 0;
    r_scl_cnt_msk  <= 0;
    REG_INT_SCL_TO <= 0;
  end
  else begin
    REG_INT_SCL_TO <= 0;
    if (~r_scl_cnt_msk) begin
      if (r_1us_cnt >= P_1US_CNT_VALUE) begin
        r_1us_cnt <= 0;
        if (r_scl_to_cnt >= (REG_SCL_TOPROD - 16'h1)) begin
          r_scl_to_cnt   <= 0;
          r_scl_cnt_msk  <= 1'b1;
          REG_INT_SCL_TO <= 1'b1;
        end 
        else
          r_scl_to_cnt <= r_scl_to_cnt + 1;
      end
      else
        r_1us_cnt <= r_1us_cnt + 1;
    end
  end
end

// I2C Enable OFF Request
assign REG_I2CM_EN_OFF = ((r_main_state == P_M_STOP) & (r_tim_state == P_T_BUF) &
                          (w_sda_fedge | w_tim_end) & |r_tx_error_lat) |
                         REG_INT_ARB_LST;

// Stores Received Data to RX FIFO
assign RX_DATA_VAL = ((r_main_state == P_M_TXACK) | (r_main_state == P_M_TXNACK)) &
                      (r_tim_state == P_T_HIGH) & w_tim_end & ~|r_tx_error_lat;
assign RX_DATA_OUT = r_rx_data_sft;

endmodule
