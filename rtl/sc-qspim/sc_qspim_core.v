//-----------------------------------------------
// Module: sc_qspim_core
//  Space Cubics Quad-SPI Master Core
//-----------------------------------------------
// Copyright © 2020 Space Cubics, LLC.
//-----------------------------------------------
module sc_qspim_core # (
  parameter SC_QSPIM_DT_B_WIDTH = 1, // Renge: 1-4
  parameter SC_QSPIM_FIFO_DEPTH = 4, // Renge: 1-15
  parameter SC_QSPIM_S_DEV_NUM = 1 // Renge: 1-16
) (
  // System Interface
  input SYSCLK,
  input SYSRST_N,

  // Register Interface
  input [1:0] REG_SPIIOMODE,
  input [SC_QSPIM_S_DEV_NUM-1:0] REG_SPISSCTL,
  input REG_SCKPOL,
  input REG_SCKPHA,
  input [11:0] REG_SCKDIV,
  input REG_DTCAPT,
  output REG_SPIBUSY,
  output REG_INT_SCTL_DN,

  // FIFO Interface
  output TX_FIFO_REN,
  input [SC_QSPIM_DT_B_WIDTH*8+1-1:0] TX_FIFO_RDATA,
  input [SC_QSPIM_FIFO_DEPTH:0] TX_FIFO_DCOUNT,
  output reg RX_FIFO_WEN,
  output reg [SC_QSPIM_DT_B_WIDTH*8-1:0] RX_FIFO_WDATA,

  // FLASH QSPI Interface
  output reg [SC_QSPIM_S_DEV_NUM-1:0] QSPI_SS,
  output reg QSPI_SCK,
  output reg [3:0] QSPI_OE,
  output reg [3:0] QSPI_DOUT,
  input [3:0] QSPI_DIN
);

reg [SC_QSPIM_S_DEV_NUM-1:0] r_reg_spissctl_p1;
reg [11:0] r_qspi_sschg_cnt;

wire w_qspi_trx_en;
wire w_qspi_clk_half_trg;
wire w_qspi_clk_full_trg;
wire w_qspi_clk_full_m1_trg;
wire w_qspi_tr_st_last;
wire w_qspi_tr_st_last_m1;
wire w_qspi_trx_wrd_last;
wire w_qspi_trx_wrd_last_m1;
wire w_qspi_trx_stt_last;
reg [12:0] r_qspi_clk_cnt;

wire w_txf_rd_ready;
reg r_reg_spibusy_p1;
reg [4:0] r_qspi_bit_cnt;
reg r_stt_last_flg;
reg [SC_QSPIM_FIFO_DEPTH:0] r_tx_fifo_dcount_p1;
reg [2:0] r_qspi_main_stm;

reg r_tx_fifo_ren_p1;
reg r_tx_fifo_ren_p2;
reg r_tx_fifo_ren_p3;
reg r_txf_rdat_wflg;
reg r_txf_rdat_rflg;
reg r_txf_rdat_stt;
reg [SC_QSPIM_DT_B_WIDTH*8-1:0] r_txf_rdat_sft [0:1];

reg [3:0] r_qspi_din_p1;
reg [3:0] r_qspi_din_sync;
reg r_qspi_rx_clk_half_p1;
reg r_qspi_tx_clk_half_p1;
reg r_qspi_rx_wrd_last_p1;
reg r_qspi_tx_wrd_last_p1;
reg r_qspi_rx_clk_half_p2;
reg r_qspi_tx_clk_half_p2;
reg r_qspi_rx_wrd_last_p2;
reg r_qspi_tx_wrd_last_p2;
reg r_qspi_rx_clk_half_p3;
reg r_qspi_tx_clk_half_p3;
reg r_qspi_rx_wrd_last_p3;
reg r_qspi_tx_wrd_last_p3;

parameter STT_M_IDLE  = 3'h0,
          STT_M_SSCHG = 3'h1,
          STT_M_TR_ST = 3'h2,
          STT_M_TX    = 3'h3,
          STT_M_RX    = 3'h4;

// Debug monitor
wire [SC_QSPIM_DT_B_WIDTH*8-1:0] m_txf_rdat_sft_mon0 = r_txf_rdat_sft[0];
wire [SC_QSPIM_DT_B_WIDTH*8-1:0] m_txf_rdat_sft_mon1 = r_txf_rdat_sft[1];

// SPI Slave Select Control
always @ (posedge SYSCLK or negedge SYSRST_N) begin
  if (!SYSRST_N) begin
    r_reg_spissctl_p1 <= 0;
    r_qspi_sschg_cnt  <= 0;
    QSPI_SS           <= {SC_QSPIM_S_DEV_NUM{1'b1}};
  end else begin
    r_reg_spissctl_p1 <= REG_SPISSCTL;
    QSPI_SS           <= ~REG_SPISSCTL;
    if (r_qspi_main_stm == STT_M_SSCHG) begin
      r_qspi_sschg_cnt <= r_qspi_sschg_cnt + 1;
      if (r_qspi_sschg_cnt >= REG_SCKDIV)
        r_qspi_sschg_cnt <= 0;
    end else begin
      r_qspi_sschg_cnt <= 0;
    end
  end
end

// SPI Clock Control
assign w_qspi_trx_en = r_qspi_main_stm == STT_M_TX | r_qspi_main_stm == STT_M_RX;
assign w_qspi_clk_half_trg = w_qspi_trx_en & (r_qspi_clk_cnt == {1'b0, REG_SCKDIV});
assign w_qspi_clk_full_trg = w_qspi_trx_en & (r_qspi_clk_cnt >= (({1'b0, REG_SCKDIV} << 1)+1));
assign w_qspi_clk_full_m1_trg = w_qspi_trx_en & (r_qspi_clk_cnt == ({1'b0, REG_SCKDIV} << 1));
assign w_qspi_tr_st_last = r_qspi_main_stm == STT_M_TR_ST & r_tx_fifo_ren_p3;
assign w_qspi_tr_st_last_m1 = r_qspi_main_stm == STT_M_TR_ST & r_tx_fifo_ren_p2;
assign w_qspi_trx_wrd_last = ~|r_qspi_bit_cnt & w_qspi_clk_full_trg;
assign w_qspi_trx_wrd_last_m1 = ~|r_qspi_bit_cnt & w_qspi_clk_full_m1_trg;
assign w_qspi_trx_stt_last = w_qspi_trx_wrd_last & r_stt_last_flg;

always @ (posedge SYSCLK or negedge SYSRST_N) begin
  if (!SYSRST_N) begin
    r_qspi_clk_cnt <= 0;
    QSPI_SCK       <= 0;
  end else if (w_qspi_trx_en) begin
    r_qspi_clk_cnt <= r_qspi_clk_cnt + 1;
    if (w_qspi_clk_full_trg) begin
      r_qspi_clk_cnt <= 0;
      if (REG_SCKPHA & ~w_qspi_trx_stt_last)
        QSPI_SCK <= ~REG_SCKPOL;
      else
        QSPI_SCK <= REG_SCKPOL;
    end else if (w_qspi_clk_half_trg) begin
      if (REG_SCKPHA)
        QSPI_SCK <= REG_SCKPOL;
      else
        QSPI_SCK <= ~REG_SCKPOL;
    end
  end else if (w_qspi_tr_st_last & REG_SCKPHA) begin
    QSPI_SCK <= ~REG_SCKPOL;
  end else begin
    r_qspi_clk_cnt <= 0;
    QSPI_SCK       <= REG_SCKPOL;
  end
end

// QSPI State Control
assign REG_SPIBUSY = r_qspi_main_stm != STT_M_IDLE;
assign w_txf_rd_ready = r_qspi_main_stm == STT_M_IDLE | (r_qspi_bit_cnt == 5'h1 & w_qspi_clk_half_trg);

always @ (posedge SYSCLK or negedge SYSRST_N) begin
  if (!SYSRST_N) begin
    r_reg_spibusy_p1  <= 0;
    r_qspi_bit_cnt    <= 0;
  end else begin
    r_reg_spibusy_p1  <= REG_SPIBUSY;
    if (w_qspi_tr_st_last | w_qspi_trx_wrd_last) begin
      if (REG_SPIIOMODE == 2'b10)
        r_qspi_bit_cnt <= SC_QSPIM_DT_B_WIDTH*2 - 1;
      else if (REG_SPIIOMODE == 2'b01)
        r_qspi_bit_cnt <= SC_QSPIM_DT_B_WIDTH*4 - 1;
      else
        r_qspi_bit_cnt <= SC_QSPIM_DT_B_WIDTH*8 - 1;
    end else if (w_qspi_trx_en) begin
      if (w_qspi_clk_full_trg)
        r_qspi_bit_cnt <= r_qspi_bit_cnt - 1;
    end else begin
      r_qspi_bit_cnt <= 0;
    end
  end
end

assign REG_INT_SCTL_DN = ~REG_SPIBUSY & r_reg_spibusy_p1;

always @ (posedge SYSCLK or negedge SYSRST_N) begin
  if (!SYSRST_N) begin
    r_stt_last_flg <= 0;
  end else if (w_qspi_trx_en) begin
    if (w_txf_rd_ready & ~TX_FIFO_REN)
      r_stt_last_flg <= 1;
    else if (w_qspi_trx_wrd_last)
      r_stt_last_flg <= 0;
  end else begin
    r_stt_last_flg <= 0;
  end
end

always @ (posedge SYSCLK or negedge SYSRST_N) begin
  if (!SYSRST_N) begin
    r_tx_fifo_dcount_p1 <= 0;
    r_qspi_main_stm     <= STT_M_IDLE;
  end else begin
    r_tx_fifo_dcount_p1 <= TX_FIFO_DCOUNT;
    case (r_qspi_main_stm)
      STT_M_IDLE : begin
        if (REG_SPISSCTL != r_reg_spissctl_p1)
          r_qspi_main_stm <= STT_M_SSCHG;
        else if (|r_tx_fifo_dcount_p1)
          r_qspi_main_stm <= STT_M_TR_ST;
      end
      STT_M_SSCHG : begin
        if (r_qspi_sschg_cnt >= REG_SCKDIV)
          r_qspi_main_stm <= STT_M_IDLE;
      end
      STT_M_TR_ST : begin
        if (w_qspi_tr_st_last) begin
          if (r_txf_rdat_stt)
            r_qspi_main_stm <= STT_M_RX;
          else
            r_qspi_main_stm <= STT_M_TX;
        end
      end
      STT_M_TX : begin
        if (w_qspi_trx_wrd_last) begin
          if (r_stt_last_flg)
            r_qspi_main_stm <= STT_M_IDLE;
          else if (r_txf_rdat_stt)
            r_qspi_main_stm <= STT_M_RX;
        end
      end
      STT_M_RX : begin
        if (w_qspi_trx_wrd_last) begin
          if (r_stt_last_flg)
            r_qspi_main_stm <= STT_M_IDLE;
          else if (~r_txf_rdat_stt)
            r_qspi_main_stm <= STT_M_TX;
        end
      end
      default : begin
        r_qspi_main_stm <= STT_M_IDLE;
      end
    endcase
  end
end

// QSPI I/O Data Output Enable Control
always @ (*) begin
  if (r_qspi_main_stm != STT_M_TX) begin
    QSPI_OE = 4'b0000;
  end else begin
    if (REG_SPIIOMODE == 2'b10)
      QSPI_OE = 4'b1111;
    else if (REG_SPIIOMODE == 2'b01)
      QSPI_OE = 4'b0011;
    else
      QSPI_OE = 4'b0001;
  end
end

// TX FIFO Read & SPI Output Data Control
assign TX_FIFO_REN = w_txf_rd_ready & |r_tx_fifo_dcount_p1;

always @ (posedge SYSCLK or negedge SYSRST_N) begin
  if (!SYSRST_N) begin
    r_tx_fifo_ren_p1 <= 0;
    r_tx_fifo_ren_p2 <= 0;
    r_tx_fifo_ren_p3 <= 0;
  end else begin
    r_tx_fifo_ren_p1 <= TX_FIFO_REN;
    r_tx_fifo_ren_p2 <= r_tx_fifo_ren_p1;
    r_tx_fifo_ren_p3 <= r_tx_fifo_ren_p2;
  end
end

always @ (posedge SYSCLK or negedge SYSRST_N) begin
  if (!SYSRST_N) begin
    r_txf_rdat_wflg   <= 0;
    r_txf_rdat_rflg   <= 0;
    r_txf_rdat_stt    <= 0;
    r_txf_rdat_sft[0] <= 0;
    r_txf_rdat_sft[1] <= 0;
    QSPI_DOUT         <= 0;
  end else if (w_qspi_tr_st_last_m1 | w_qspi_tr_st_last | w_qspi_trx_en) begin
    if (w_qspi_trx_stt_last) begin
      r_txf_rdat_wflg   <= 0;
      r_txf_rdat_rflg   <= 0;
      r_txf_rdat_stt    <= 0;
      r_txf_rdat_sft[0] <= 0;
      r_txf_rdat_sft[1] <= 0;
      QSPI_DOUT         <= 0;
    end else begin
      if (r_tx_fifo_ren_p2) begin
        r_txf_rdat_wflg                 <= ~r_txf_rdat_wflg;
        r_txf_rdat_stt                  <= TX_FIFO_RDATA[SC_QSPIM_DT_B_WIDTH*8];
        r_txf_rdat_sft[r_txf_rdat_wflg] <= TX_FIFO_RDATA[SC_QSPIM_DT_B_WIDTH*8-1:0];
      end
      if (w_qspi_trx_wrd_last_m1)
        r_txf_rdat_rflg <= ~r_txf_rdat_rflg;
      if (w_qspi_tr_st_last | w_qspi_clk_full_trg) begin
        if (REG_SPIIOMODE == 2'b10) begin
          r_txf_rdat_sft[r_txf_rdat_rflg] <= {r_txf_rdat_sft[r_txf_rdat_rflg][SC_QSPIM_DT_B_WIDTH*8-5:0], 4'h0} ;
          QSPI_DOUT                       <= r_txf_rdat_sft[r_txf_rdat_rflg][SC_QSPIM_DT_B_WIDTH*8-1 -: 4];
        end else if (REG_SPIIOMODE == 2'b01) begin
          r_txf_rdat_sft[r_txf_rdat_rflg] <= {r_txf_rdat_sft[r_txf_rdat_rflg][SC_QSPIM_DT_B_WIDTH*8-3:0], 2'h0} ;
          QSPI_DOUT                       <= {2'b00, r_txf_rdat_sft[r_txf_rdat_rflg][SC_QSPIM_DT_B_WIDTH*8-1 -: 2]};
        end else begin
          r_txf_rdat_sft[r_txf_rdat_rflg] <= {r_txf_rdat_sft[r_txf_rdat_rflg][SC_QSPIM_DT_B_WIDTH*8-2:0], 1'b0} ;
          QSPI_DOUT                       <= {3'b000, r_txf_rdat_sft[r_txf_rdat_rflg][SC_QSPIM_DT_B_WIDTH*8-1]};
        end
      end
    end
  end else begin
    r_txf_rdat_wflg   <= 0;
    r_txf_rdat_rflg   <= 0;
    r_txf_rdat_stt    <= 0;
    r_txf_rdat_sft[0] <= 0;
    r_txf_rdat_sft[1] <= 0;
    QSPI_DOUT         <= 0;
  end
end

// SPI Input Data & RX FIFO Write Control
always @ (posedge SYSCLK or negedge SYSRST_N) begin
  if (!SYSRST_N) begin
    r_qspi_din_p1   <= 0;
    r_qspi_din_sync <= 0;
  end else begin
    r_qspi_din_p1   <= QSPI_DIN;
    r_qspi_din_sync <= r_qspi_din_p1;
  end
end

always @ (posedge SYSCLK or negedge SYSRST_N) begin
  if (!SYSRST_N) begin
    r_qspi_rx_clk_half_p1 <= 0;
    r_qspi_tx_clk_half_p1 <= 0;
    r_qspi_rx_wrd_last_p1 <= 0;
    r_qspi_tx_wrd_last_p1 <= 0;
    r_qspi_rx_clk_half_p2 <= 0;
    r_qspi_tx_clk_half_p2 <= 0;
    r_qspi_rx_wrd_last_p2 <= 0;
    r_qspi_tx_wrd_last_p2 <= 0;
    r_qspi_rx_clk_half_p3 <= 0;
    r_qspi_tx_clk_half_p3 <= 0;
    r_qspi_rx_wrd_last_p3 <= 0;
    r_qspi_tx_wrd_last_p3 <= 0;
    RX_FIFO_WEN           <= 0;
    RX_FIFO_WDATA         <= 0;
  end else begin
    r_qspi_rx_clk_half_p1 <= r_qspi_main_stm == STT_M_RX & w_qspi_clk_half_trg;
    r_qspi_tx_clk_half_p1 <= r_qspi_main_stm == STT_M_TX & w_qspi_clk_half_trg;
    r_qspi_rx_wrd_last_p1 <= r_qspi_main_stm == STT_M_RX & w_qspi_trx_wrd_last;
    r_qspi_tx_wrd_last_p1 <= r_qspi_main_stm == STT_M_TX & w_qspi_trx_wrd_last;
    r_qspi_rx_clk_half_p2 <= r_qspi_rx_clk_half_p1;
    r_qspi_tx_clk_half_p2 <= r_qspi_tx_clk_half_p1;
    r_qspi_rx_wrd_last_p2 <= r_qspi_rx_wrd_last_p1;
    r_qspi_tx_wrd_last_p2 <= r_qspi_tx_wrd_last_p1;
    r_qspi_rx_clk_half_p3 <= r_qspi_rx_clk_half_p2;
    r_qspi_tx_clk_half_p3 <= r_qspi_tx_clk_half_p2;
    r_qspi_rx_wrd_last_p3 <= r_qspi_rx_wrd_last_p2;
    r_qspi_tx_wrd_last_p3 <= r_qspi_tx_wrd_last_p2;
    RX_FIFO_WEN           <= r_qspi_rx_wrd_last_p3 | (REG_DTCAPT & r_qspi_tx_wrd_last_p3);
    if (r_qspi_rx_clk_half_p3 | (REG_DTCAPT & r_qspi_tx_clk_half_p3)) begin
      if (REG_SPIIOMODE == 2'b10)
        RX_FIFO_WDATA <= {RX_FIFO_WDATA[SC_QSPIM_DT_B_WIDTH*8-5:0], r_qspi_din_sync};
      else if (REG_SPIIOMODE == 2'b01)
        RX_FIFO_WDATA <= {RX_FIFO_WDATA[SC_QSPIM_DT_B_WIDTH*8-3:0], r_qspi_din_sync[1:0]};
      else
        RX_FIFO_WDATA <= {RX_FIFO_WDATA[SC_QSPIM_DT_B_WIDTH*8-2:0], r_qspi_din_sync[1]};
    end
  end
end

endmodule
