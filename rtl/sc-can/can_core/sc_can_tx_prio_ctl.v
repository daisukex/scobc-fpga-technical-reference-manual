//-----------------------------------------------
// sc_can_tx_prio_ctl
//  Space Cubics CAN Controller TX Priority Controller Module
//-----------------------------------------------
// Copyright © 2022 Space Cubics, LLC.
//-----------------------------------------------
module sc_can_tx_prio_ctl # (
  parameter SC_CAN_MEM_AD_WIDTH = 4,
  parameter SC_CAN_CLK_ASYNC  = 1
)
(
  input WR_RSTB,
  input WR_CLK,
  input RD_RSTB,
  input RD_CLK,

  // Write Port (WR_CLK Sync)
  input [3:0] TXPM_WEN,
  output reg [SC_CAN_MEM_AD_WIDTH-1:0] TXPM_WADR,

  input TXPM_RST,

  output reg TXPM_FULL,
  output TXPM_OVERFLOW,
  input [SC_CAN_MEM_AD_WIDTH:0] TXPM_OVER_TH_LVL,
  output reg TXPM_OVER_TH,

  output [SC_CAN_MEM_AD_WIDTH:0] TXPM1_DATA_COUNT,
  output [SC_CAN_MEM_AD_WIDTH:0] TXPM2_DATA_COUNT,
  output [SC_CAN_MEM_AD_WIDTH:0] TXPM3_DATA_COUNT,
  output [SC_CAN_MEM_AD_WIDTH:0] TXPM4_DATA_COUNT,

  // Read Port (RD_CLK Sync)
  output TXPM_RVAL,
  input TXPM_REN,
  output [SC_CAN_MEM_AD_WIDTH-1:0] TXPM_RADR,
  input [31:0] PRIO_SEARCH_RDATA,
  input TXPM_RD_END,

  output reg TXPM_EMPTY,
  output TXPM_UNDERFLOW,
  input [SC_CAN_MEM_AD_WIDTH:0] TXPM_UNDER_TH_LVL,
  output reg TXPM_UNDER_TH
);

reg [2**SC_CAN_MEM_AD_WIDTH-1:0] r_mem_wval [0:3];

reg [2**SC_CAN_MEM_AD_WIDTH-1:0] r_mem_rval_prio;
reg [SC_CAN_MEM_AD_WIDTH-1:0] r_prio_sach_cnt;
reg [1:0] r_prio_sach_state;

wire [2**SC_CAN_MEM_AD_WIDTH-1:0] w_mem_wval_rsync_all;
reg r_txpm_rd_end_wait;
reg r_txpm_rst_wait;

reg r_prio_sach_val;
reg [SC_CAN_MEM_AD_WIDTH-1:0] r_prio_tgt_adr;

wire w_prio_sach_ren;
wire [SC_CAN_MEM_AD_WIDTH-1:0] w_prio_sach_radr;

reg r_prio_sach_ren_p1;
reg r_prio_sach_ren_p2;
reg [1:0] r_prio_sach_state_p1;
reg [1:0] r_prio_sach_state_p2;
reg [SC_CAN_MEM_AD_WIDTH-1:0] r_prio_sach_cnt_p1;
reg [SC_CAN_MEM_AD_WIDTH-1:0] r_prio_sach_cnt_p2;

reg [31:0] r_tgt_rdata;

reg [SC_CAN_MEM_AD_WIDTH-1:0] r_prio_inval_near_h;
reg [SC_CAN_MEM_AD_WIDTH-1:0] r_prio_inval_near_l;
reg [SC_CAN_MEM_AD_WIDTH-1:0] r_prio_val_min_num;
reg [SC_CAN_MEM_AD_WIDTH-1:0] r_prio_val_max_num;

reg r_txpm_rd_end_lat;
reg [SC_CAN_MEM_AD_WIDTH-1:0] r_txpm_radr_lat;
reg [SC_CAN_MEM_AD_WIDTH-1:0] r_prio_rd_num;

reg [2**SC_CAN_MEM_AD_WIDTH-1:0] r_prio_val;
reg [SC_CAN_MEM_AD_WIDTH-1:0] r_prio_adr [0:2**SC_CAN_MEM_AD_WIDTH-1];

wire w_prio_cmp_end;
reg r_prio_cmp_end_p1;
reg r_prio_cmp_end_p2;

reg [3:0] r_txpm_full;
reg [3:0] r_txpm_ovf;
reg [3:0] r_txpm_ovth;
reg [SC_CAN_MEM_AD_WIDTH:0] r_txpm_dcount [0:3];

reg [3:0] r_txpm_full_lat;
reg [3:0] r_txpm_ovth_lat;

reg [3:0] r_txpm_empty;
reg [3:0] r_txpm_udf;
reg [3:0] r_txpm_udth;

reg [3:0] r_txpm_empty_lat;
reg [3:0] r_txpm_udth_lat;

wire w_txpm_rst_rsync;
wire [3:0] w_txpm_wen_rsync;
wire [2**SC_CAN_MEM_AD_WIDTH-1:0] w_mem_wval_rsync [0:3];
wire [SC_CAN_MEM_AD_WIDTH:0] w_txpm_dcount_rsync [0:3];

wire w_txpm_rd_end_wsync;
reg r_txpm_rd_end_wsync_p1;
reg r_txpm_rd_end_wsync_p2;
wire w_txpm_rst_wsync;
reg r_txpm_rst_wsync_p1;
reg r_txpm_rst_wsync_p2;
wire [SC_CAN_MEM_AD_WIDTH-1:0] w_txpm_radr_lat_wsync;
wire w_txpm_rd_end_wsync_rsync;
wire w_txpm_rst_wsync_rsync;

parameter STT_IDLE = 2'd0,
          STT_TGT  = 2'd1,
          STT_CMP  = 2'd2,
          STT_END  = 2'd3;

integer i;
genvar gn;

// Priority Management Table
generate
  for(gn=0; gn<4; gn=gn+1) begin : mem_wval_gen
    always @ (posedge WR_CLK or negedge WR_RSTB) begin
      if (!WR_RSTB)
        r_mem_wval[gn] <= 0;
      else if (TXPM_RST)
        r_mem_wval[gn] <= 0;
      else begin
        if (w_txpm_rd_end_wsync)
          r_mem_wval[gn][w_txpm_radr_lat_wsync] <= 0;
        if (TXPM_WEN[gn] & ~TXPM_FULL)
          r_mem_wval[gn][TXPM_WADR] <= 1'b1;
      end
    end
  end
endgenerate

always @ (posedge WR_CLK or negedge WR_RSTB) begin
  if (!WR_RSTB)
    TXPM_WADR <= 0;
  else begin
    for (i=2**SC_CAN_MEM_AD_WIDTH-1; i>=0; i=i-1) begin
      if (~(r_mem_wval[0][i] & r_mem_wval[1][i] & r_mem_wval[2][i] & r_mem_wval[3][i]))
        TXPM_WADR <= i;
    end
  end
end

always @ (posedge RD_CLK or negedge RD_RSTB) begin
  if (!RD_RSTB) begin
    r_mem_rval_prio    <= 0;
    r_prio_sach_cnt    <= 0;
    r_prio_sach_state  <= STT_IDLE;
  end
  else if (w_txpm_rst_rsync) begin
    r_mem_rval_prio    <= 0;
    r_prio_sach_cnt    <= 0;
    r_prio_sach_state  <= STT_IDLE;
  end
  else begin
    if (TXPM_RD_END)
      r_mem_rval_prio[r_txpm_radr_lat] <= 0;
    case (r_prio_sach_state)
      STT_IDLE : begin
        if (r_prio_sach_val)
          r_prio_sach_state <= STT_TGT;
      end
      STT_TGT : begin
        if (~|r_prio_val) begin
          r_mem_rval_prio[0] <= 1'b1;
          r_prio_sach_state  <= STT_END;
        end
        else if (w_prio_sach_ren)
          r_prio_sach_state  <= STT_CMP;
      end
      STT_CMP : begin
        if (w_prio_sach_ren)
          r_prio_sach_cnt <= r_prio_sach_cnt + 1;
        if (w_prio_cmp_end) begin
          r_mem_rval_prio[r_prio_tgt_adr] <= 1'b1;
          r_prio_sach_cnt                 <= 0;
          r_prio_sach_state               <= STT_END;
        end
      end
      default : begin
        if (r_prio_cmp_end_p2 | (r_prio_sach_state_p1 ==  STT_TGT))
          r_prio_sach_state <= STT_IDLE;
      end
    endcase
  end
end

generate
  for(gn=0; gn<2**SC_CAN_MEM_AD_WIDTH; gn=gn+1) begin : mem_wval_all_rsync_gen
    assign w_mem_wval_rsync_all[gn] = w_mem_wval_rsync[0][gn] &
                                      w_mem_wval_rsync[1][gn] &
                                      w_mem_wval_rsync[2][gn] &
                                      w_mem_wval_rsync[3][gn] ;
  end
endgenerate

assign TXPM_RVAL = |(r_mem_rval_prio & w_mem_wval_rsync_all);

always @ (posedge RD_CLK or negedge RD_RSTB) begin
  if (!RD_RSTB) begin
    r_txpm_rd_end_wait <= 0;
    r_txpm_rst_wait    <= 0;
  end
  else if (SC_CAN_CLK_ASYNC) begin
    if (TXPM_RD_END)
      r_txpm_rd_end_wait <= 1'b1;
    else if (w_txpm_rd_end_wsync_rsync)
      r_txpm_rd_end_wait <= 0;
    if (w_txpm_rst_rsync)
      r_txpm_rst_wait <= 1'b1;
    else if (w_txpm_rst_wsync_rsync)
      r_txpm_rst_wait <= 0;
  end
end

always @ (posedge RD_CLK or negedge RD_RSTB) begin
  if (!RD_RSTB) begin
    r_prio_sach_val <= 0;
    r_prio_tgt_adr  <= 0;
  end
  else begin
    r_prio_sach_val <= (w_mem_wval_rsync[0] != r_mem_rval_prio) &
                       ~(TXPM_RD_END | r_txpm_rd_end_wait | w_txpm_rst_rsync | r_txpm_rst_wait);
    for (i=2**SC_CAN_MEM_AD_WIDTH-1; i>=0; i=i-1) begin
      if ((r_prio_sach_state == STT_IDLE) & w_mem_wval_rsync[0][i] & ~r_mem_rval_prio[i])
        r_prio_tgt_adr <= i;
    end
  end
end

assign w_prio_sach_ren = (((r_prio_sach_state == STT_TGT) & |r_prio_val) |
                          (r_prio_sach_state == STT_CMP)) &
                         ~(TXPM_REN | TXPM_RD_END);
assign w_prio_sach_radr = (r_prio_sach_state == STT_TGT) ? r_prio_tgt_adr:
                                                           r_prio_adr[r_prio_sach_cnt];

always @ (posedge RD_CLK or negedge RD_RSTB) begin
  if (!RD_RSTB) begin
    r_prio_sach_ren_p1   <= 0;
    r_prio_sach_ren_p2   <= 0;
    r_prio_sach_state_p1 <= 0;
    r_prio_sach_state_p2 <= 0;
    r_prio_sach_cnt_p1   <= 0;
    r_prio_sach_cnt_p2   <= 0;
  end
  else begin
    r_prio_sach_ren_p1   <= w_prio_sach_ren;
    r_prio_sach_ren_p2   <= r_prio_sach_ren_p1;
    r_prio_sach_state_p1 <= r_prio_sach_state;
    r_prio_sach_state_p2 <= r_prio_sach_state_p1;
    r_prio_sach_cnt_p1   <= r_prio_sach_cnt;
    r_prio_sach_cnt_p2   <= r_prio_sach_cnt_p1;
  end
end

always @ (posedge RD_CLK or negedge RD_RSTB) begin
  if (!RD_RSTB)
    r_tgt_rdata <= 0;
  else if ((r_prio_sach_state_p2 == STT_TGT) & r_prio_sach_ren_p2)
    r_tgt_rdata <= PRIO_SEARCH_RDATA;
end

always @ (*) begin
  r_prio_inval_near_h = 0;
  r_prio_inval_near_l = 0;
  r_prio_val_min_num  = 0;
  r_prio_val_max_num  = 0;
  for (i=2**SC_CAN_MEM_AD_WIDTH-1; i>=0; i=i-1) begin
    if ((r_prio_sach_cnt_p2 < i) & ~r_prio_val[i])
      r_prio_inval_near_h = i;
  end
  for (i=0; i<2**SC_CAN_MEM_AD_WIDTH; i=i+1) begin
    if ((r_prio_sach_cnt_p2 > i) & ~r_prio_val[i])
      r_prio_inval_near_l = i;
  end
  for (i=2**SC_CAN_MEM_AD_WIDTH-1; i>=0; i=i-1) begin
    if (r_prio_val[i])
      r_prio_val_min_num = i;
  end
  for (i=0; i<2**SC_CAN_MEM_AD_WIDTH; i=i+1) begin
    if (r_prio_val[i])
      r_prio_val_max_num = i;
  end
end

always @ (posedge RD_CLK or negedge RD_RSTB) begin
  if (!RD_RSTB) begin
    r_txpm_rd_end_lat <= 0;
    r_txpm_radr_lat   <= 0;
    r_prio_rd_num     <= 0;
  end
  else begin
    if (w_prio_cmp_end | r_prio_cmp_end_p1) begin
      if (TXPM_RD_END)
        r_txpm_rd_end_lat <= 1'b1;
    end
    else
      r_txpm_rd_end_lat <= 0;
    if (TXPM_REN)
      r_txpm_radr_lat <= TXPM_RADR;
    for (i=0; i<2**SC_CAN_MEM_AD_WIDTH; i=i+1) begin
      if (r_prio_val[i] & (r_prio_adr[i] == r_txpm_radr_lat))
        r_prio_rd_num <= i;
    end
  end
end

always @ (posedge RD_CLK or negedge RD_RSTB) begin
  if (!RD_RSTB)
    r_prio_val <= 0;
  else if (w_txpm_rst_rsync)
    r_prio_val <= 0;
  else begin
    if ((r_prio_sach_state == STT_TGT) & ~|r_prio_val)
      r_prio_val[0] <= 1'b1;
    else if (r_prio_sach_ren_p2 & r_prio_val[r_prio_sach_cnt_p2] &
             (r_prio_sach_state_p2 == STT_CMP) & (r_prio_sach_state != STT_END)) begin
      if (r_tgt_rdata < PRIO_SEARCH_RDATA) begin
        if (~r_prio_val[r_prio_sach_cnt_p2-1] & |r_prio_sach_cnt_p2)
          r_prio_val[r_prio_sach_cnt_p2-1] <= 1'b1;
        else if (r_prio_sach_cnt_p2 < r_prio_inval_near_h)
          r_prio_val[r_prio_inval_near_h]  <= 1'b1;
        else
          r_prio_val[r_prio_inval_near_l]  <= 1'b1;
      end
      else begin
        if (&r_prio_sach_cnt_p2)
          r_prio_val[r_prio_inval_near_l]  <= 1'b1;
        else if ((r_prio_sach_cnt_p2+1) > r_prio_val_max_num)
          r_prio_val[r_prio_sach_cnt_p2+1] <= 1'b1;
      end
    end
    if ((TXPM_RD_END | r_txpm_rd_end_lat) & ~(w_prio_cmp_end | r_prio_cmp_end_p1))
      r_prio_val[r_prio_rd_num] <= 0;
  end
end

generate
  for(gn=0; gn<2**SC_CAN_MEM_AD_WIDTH; gn=gn+1) begin : prio_table_gen
    always @ (posedge RD_CLK or negedge RD_RSTB) begin
      if (!RD_RSTB)
        r_prio_adr[gn] <= 0;
      else if (w_txpm_rst_rsync)
        r_prio_adr[gn] <= 0;
      else begin
        if ((r_prio_sach_state == STT_TGT) & ~|r_prio_val) begin
          if (gn == 0)
            r_prio_adr[gn] <= r_prio_tgt_adr;
        end
        else if (r_prio_sach_ren_p2 & r_prio_val[r_prio_sach_cnt_p2] &
                 (r_prio_sach_state_p2 == STT_CMP) & (r_prio_sach_state != STT_END)) begin
          if (r_tgt_rdata < PRIO_SEARCH_RDATA) begin
            if (~r_prio_val[r_prio_sach_cnt_p2-1] & |r_prio_sach_cnt_p2) begin
              if (gn == (r_prio_sach_cnt_p2-1))
                r_prio_adr[gn] <= r_prio_tgt_adr;
            end
            else begin
              if (r_prio_sach_cnt_p2 < r_prio_inval_near_h) begin
                if (gn == r_prio_sach_cnt_p2)
                  r_prio_adr[gn] <= r_prio_tgt_adr;
                else if ((gn > r_prio_sach_cnt_p2) & (gn <= r_prio_inval_near_h)) begin
                  if (gn != 0)
                    r_prio_adr[gn] <= r_prio_adr[gn-1];
                end
              end
              else begin
                if (gn == (r_prio_sach_cnt_p2-1))
                  r_prio_adr[gn] <= r_prio_tgt_adr;
                else if ((gn < (r_prio_sach_cnt_p2-1)) & (gn >= r_prio_inval_near_l)) begin
                  if (gn != (2**SC_CAN_MEM_AD_WIDTH-1))
                    r_prio_adr[gn] <= r_prio_adr[gn+1];
                end
              end
            end
          end
          else begin
            if (&r_prio_sach_cnt_p2) begin
              if (gn == (2**SC_CAN_MEM_AD_WIDTH-1))
                r_prio_adr[gn] <= r_prio_tgt_adr;
              else if (gn >= r_prio_inval_near_l)
                r_prio_adr[gn] <= r_prio_adr[gn+1];
            end
            else if ((r_prio_sach_cnt_p2+1) > r_prio_val_max_num) begin
              if (gn == (r_prio_sach_cnt_p2+1))
                r_prio_adr[gn] <= r_prio_tgt_adr;
            end
          end
        end
      end
    end
  end
endgenerate

assign w_prio_cmp_end = (r_prio_sach_ren_p2 & r_prio_val[r_prio_sach_cnt_p2] &
                         (r_prio_sach_state_p2 == STT_CMP) & (r_prio_sach_state != STT_END)) &
                        ((r_tgt_rdata < PRIO_SEARCH_RDATA) |
                         ((r_tgt_rdata >= PRIO_SEARCH_RDATA) &
                          (&r_prio_sach_cnt_p2 | ((r_prio_sach_cnt_p2+1) > r_prio_val_max_num))));

always @ (posedge RD_CLK or negedge RD_RSTB) begin
  if (!RD_RSTB) begin
    r_prio_cmp_end_p1 <= 0;
    r_prio_cmp_end_p2 <= 0;
  end
  else begin
    r_prio_cmp_end_p1 <= w_prio_cmp_end;
    r_prio_cmp_end_p2 <= r_prio_cmp_end_p1;
  end
end

assign TXPM_RADR = (w_prio_sach_ren) ? w_prio_sach_radr:
                                       r_prio_adr[r_prio_val_min_num];

// Interrupt,Data Counter
generate
  for(gn=0; gn<4; gn=gn+1) begin : txpm_sts_wr_gen
    always @ (posedge WR_CLK or negedge WR_RSTB) begin
      if (!WR_RSTB) begin
        r_txpm_full[gn]   <= 0;
        r_txpm_ovf[gn]    <= 0;
        r_txpm_ovth[gn]   <= 0;
        r_txpm_dcount[gn] <= 0;
      end
      else if (TXPM_RST) begin
        r_txpm_full[gn]   <= 0;
        r_txpm_ovf[gn]    <= 0;
        r_txpm_ovth[gn]   <= 0;
        r_txpm_dcount[gn] <= 0;
      end
      else begin
        r_txpm_full[gn]   <= 0;
        r_txpm_ovf[gn]    <= 0;
        r_txpm_ovth[gn]   <= 0;
        if (TXPM_WEN[gn] & ~w_txpm_rd_end_wsync) begin
          if (r_txpm_dcount[gn][SC_CAN_MEM_AD_WIDTH])
            r_txpm_ovf[gn] <= 1'b1;
          else begin
            r_txpm_dcount[gn] <= r_txpm_dcount[gn] + 1;
            if (&r_txpm_dcount[gn][SC_CAN_MEM_AD_WIDTH-1:0])
              r_txpm_full[gn] <= 1'b1;
            if (|TXPM_OVER_TH_LVL &
                (r_txpm_dcount[gn] == TXPM_OVER_TH_LVL))
              r_txpm_ovth[gn] <= 1'b1;
          end
        end
        else if (w_txpm_rd_end_wsync & ~TXPM_WEN[gn]) begin
          if (|r_txpm_dcount[gn])
            r_txpm_dcount[gn] <= r_txpm_dcount[gn] - 1;
        end
      end
    end
  end
endgenerate

assign TXPM1_DATA_COUNT = r_txpm_dcount[0];
assign TXPM2_DATA_COUNT = r_txpm_dcount[1];
assign TXPM3_DATA_COUNT = r_txpm_dcount[2];
assign TXPM4_DATA_COUNT = r_txpm_dcount[3];

always @ (posedge WR_CLK or negedge WR_RSTB) begin
  if (!WR_RSTB) begin
    r_txpm_full_lat <= 0;
    r_txpm_ovth_lat <= 0;
    TXPM_FULL       <= 0;
    TXPM_OVER_TH    <= 0;
  end
  else if (TXPM_RST) begin
    r_txpm_full_lat <= 0;
    r_txpm_ovth_lat <= 0;
    TXPM_FULL       <= 0;
    TXPM_OVER_TH    <= 0;
  end
  else begin
    TXPM_FULL    <= 0;
    TXPM_OVER_TH <= 0;
    if (&r_txpm_full_lat) begin
      r_txpm_full_lat <= 0;
      TXPM_FULL       <= 1'b1;
    end
    else begin
      for (i=0; i<4; i=i+1) begin
        if (r_txpm_full[i])
          r_txpm_full_lat[i] <= 1'b1;
      end
    end
    if (&r_txpm_ovth_lat) begin
      r_txpm_ovth_lat <= 0;
      TXPM_OVER_TH    <= 1'b1;
    end
    else begin
      for (i=0; i<4; i=i+1) begin
        if (r_txpm_ovth[i])
          r_txpm_ovth_lat[i] <= 1'b1;
      end
    end
  end
end

assign TXPM_OVERFLOW = |r_txpm_ovf;

generate
  for(gn=0; gn<4; gn=gn+1) begin : txpm_sts_rd_gen
    always @ (posedge RD_CLK or negedge RD_RSTB) begin
      if (!RD_RSTB) begin
        r_txpm_empty[gn] <= 0;
        r_txpm_udf[gn]   <= 0;
        r_txpm_udth[gn]  <= 0;
      end
      else if (w_txpm_rst_rsync) begin
        r_txpm_empty[gn] <= 0;
        r_txpm_udf[gn]   <= 0;
        r_txpm_udth[gn]  <= 0;
      end
      else begin
        r_txpm_empty[gn] <= 0;
        r_txpm_udf[gn]   <= 0;
        r_txpm_udth[gn]  <= 0;
        if (TXPM_RD_END & ~w_txpm_wen_rsync[gn]) begin
          if (~|w_txpm_dcount_rsync[gn])
            r_txpm_udf[gn] <= 1'b1;
          else begin
            if (~|w_txpm_dcount_rsync[gn][SC_CAN_MEM_AD_WIDTH:1])
              r_txpm_empty[gn] <= 1'b1;
            if (~TXPM_UNDER_TH_LVL[SC_CAN_MEM_AD_WIDTH] &
                (w_txpm_dcount_rsync[gn] == TXPM_UNDER_TH_LVL))
              r_txpm_udth[gn] <= 1'b1;
          end
        end
      end
    end
  end
endgenerate

always @ (posedge RD_CLK or negedge RD_RSTB) begin
  if (!RD_RSTB) begin
    r_txpm_empty_lat <= 0;
    r_txpm_udth_lat  <= 0;
    TXPM_EMPTY       <= 0;
    TXPM_UNDER_TH    <= 0;
  end
  else if (w_txpm_rst_rsync) begin
    r_txpm_empty_lat <= 0;
    r_txpm_udth_lat  <= 0;
    TXPM_EMPTY       <= 0;
    TXPM_UNDER_TH    <= 0;
  end
  else begin
    TXPM_EMPTY    <= 0;
    TXPM_UNDER_TH <= 0;
    if (&r_txpm_empty_lat) begin
      r_txpm_empty_lat <= 0;
      TXPM_EMPTY       <= 1'b1;
    end
    else begin
      for (i=0; i<4; i=i+1) begin
        if (r_txpm_empty[i])
          r_txpm_empty_lat[i] <= 1'b1;
      end
    end
    if (&r_txpm_udth_lat) begin
      r_txpm_udth_lat <= 0;
      TXPM_UNDER_TH   <= 1'b1;
    end
    else begin
      for (i=0; i<4; i=i+1) begin
        if (r_txpm_udth[i])
          r_txpm_udth_lat[i] <= 1'b1;
      end
    end
  end
end

assign TXPM_UNDERFLOW = |r_txpm_udf;

generate
  if (SC_CAN_CLK_ASYNC) begin
    // Clock Converter
    sc_clk_conv_pls # (
      .P_POLARITY(1)
    ) cconv_txpm_rst_rd (
      .IN_RSTB(WR_RSTB),
      .IN_CLK(WR_CLK),
      .IN_PLS(TXPM_RST),
      .SYNC_RSTB(RD_RSTB),
      .SYNC_CLK(RD_CLK),
      .SYNC_PLS(w_txpm_rst_rsync)
    );

    for(gn=0; gn<4; gn=gn+1) begin : cconv_txpm_wen_rd_gen
      sc_clk_conv_pls # (
        .P_POLARITY(1)
      ) cconv_txpm_wen_rd (
        .IN_RSTB(WR_RSTB),
        .IN_CLK(WR_CLK),
        .IN_PLS(TXPM_WEN[gn]),
        .SYNC_RSTB(RD_RSTB),
        .SYNC_CLK(RD_CLK),
        .SYNC_PLS(w_txpm_wen_rsync[gn])
      );
    end

    for(gn=0; gn<4; gn=gn+1) begin : cconv_mem_wval_rd_gen
      sc_clk_conv_bus # (
        .P_USE_VLD(0),
        .P_DT_WIDTH(2**SC_CAN_MEM_AD_WIDTH)
      ) cconv_mem_wval_rd (
        .IN_RSTB(WR_RSTB),
        .IN_CLK(WR_CLK),
        .IN_VALID(1'b0),
        .IN_DATA(r_mem_wval[gn]),
        .SYNC_RSTB(RD_RSTB),
        .SYNC_CLK(RD_CLK),
        .SYNC_VALID(/*open*/),
        .SYNC_DATA(w_mem_wval_rsync[gn])
      );
    end

    for(gn=0; gn<4; gn=gn+1) begin : cconv_txpm_dcount_rd_gen
      sc_clk_conv_bus # (
        .P_USE_VLD(0),
        .P_DT_WIDTH(SC_CAN_MEM_AD_WIDTH+1)
      ) cconv_txpm_dcount_rd (
        .IN_RSTB(WR_RSTB),
        .IN_CLK(WR_CLK),
        .IN_VALID(1'b0),
        .IN_DATA(r_txpm_dcount[gn]),
        .SYNC_RSTB(RD_RSTB),
        .SYNC_CLK(RD_CLK),
        .SYNC_VALID(/*open*/),
        .SYNC_DATA(w_txpm_dcount_rsync[gn])
      );
    end

    sc_clk_conv_pls # (
      .P_POLARITY(1)
    ) cconv_txpm_rd_end_wr (
      .IN_RSTB(RD_RSTB),
      .IN_CLK(RD_CLK),
      .IN_PLS(TXPM_RD_END),
      .SYNC_RSTB(WR_RSTB),
      .SYNC_CLK(WR_CLK),
      .SYNC_PLS(w_txpm_rd_end_wsync)
    );

    sc_clk_conv_pls # (
      .P_POLARITY(1)
    ) cconv_txpm_rst_wr (
      .IN_RSTB(RD_RSTB),
      .IN_CLK(RD_CLK),
      .IN_PLS(w_txpm_rst_rsync),
      .SYNC_RSTB(WR_RSTB),
      .SYNC_CLK(WR_CLK),
      .SYNC_PLS(w_txpm_rst_wsync)
    );

    always @ (posedge WR_CLK or negedge WR_RSTB) begin
      if (!WR_RSTB) begin
        r_txpm_rd_end_wsync_p1 <= 0;
        r_txpm_rd_end_wsync_p2 <= 0;
        r_txpm_rst_wsync_p1    <= 0;
        r_txpm_rst_wsync_p2    <= 0;
      end
      else begin
        r_txpm_rd_end_wsync_p1 <= w_txpm_rd_end_wsync;
        r_txpm_rd_end_wsync_p2 <= r_txpm_rd_end_wsync_p1;
        r_txpm_rst_wsync_p1    <= w_txpm_rst_wsync;
        r_txpm_rst_wsync_p2    <= r_txpm_rst_wsync_p1;
      end
    end

    sc_clk_conv_bus # (
      .P_USE_VLD(0),
      .P_DT_WIDTH(SC_CAN_MEM_AD_WIDTH)
    ) cconv_txpm_radr_lat_wr (
      .IN_RSTB(RD_RSTB),
      .IN_CLK(RD_CLK),
      .IN_VALID(1'b0),
      .IN_DATA(r_txpm_radr_lat),
      .SYNC_RSTB(WR_RSTB),
      .SYNC_CLK(WR_CLK),
      .SYNC_VALID(/*open*/),
      .SYNC_DATA(w_txpm_radr_lat_wsync)
    );

    sc_clk_conv_pls # (
      .P_POLARITY(1)
    ) cconv_txpm_rd_end_wr_rd (
      .IN_RSTB(WR_RSTB),
      .IN_CLK(WR_CLK),
      .IN_PLS(r_txpm_rd_end_wsync_p2),
      .SYNC_RSTB(RD_RSTB),
      .SYNC_CLK(RD_CLK),
      .SYNC_PLS(w_txpm_rd_end_wsync_rsync)
    );

    sc_clk_conv_pls # (
      .P_POLARITY(1)
    ) cconv_txpm_rst_wr_rd (
      .IN_RSTB(WR_RSTB),
      .IN_CLK(WR_CLK),
      .IN_PLS(r_txpm_rst_wsync_p2),
      .SYNC_RSTB(RD_RSTB),
      .SYNC_CLK(RD_CLK),
      .SYNC_PLS(w_txpm_rst_wsync_rsync)
    );
  end
  else begin
    assign w_txpm_rst_rsync = TXPM_RST;
    assign w_txpm_wen_rsync = TXPM_WEN;
    for(gn=0; gn<4; gn=gn+1) begin : not_cconv_sig_gen
      assign w_mem_wval_rsync[gn] = r_mem_wval[gn];
      assign w_txpm_dcount_rsync[gn] = r_txpm_dcount[gn];
    end
    assign w_txpm_rd_end_wsync = TXPM_RD_END;
    assign w_txpm_rst_wsync = w_txpm_rst_rsync;
    always @ (*) begin
      r_txpm_rd_end_wsync_p1 = 1'b0;
      r_txpm_rd_end_wsync_p2 = 1'b0;
      r_txpm_rst_wsync_p1 = 1'b0;
      r_txpm_rst_wsync_p2 = 1'b0;
    end
    assign w_txpm_radr_lat_wsync = r_txpm_radr_lat;
    assign w_txpm_rd_end_wsync_rsync = w_txpm_rd_end_wsync;
    assign w_txpm_rst_wsync_rsync = TXPM_RST;
  end
endgenerate

endmodule
