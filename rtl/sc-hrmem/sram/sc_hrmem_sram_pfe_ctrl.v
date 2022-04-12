//-----------------------------------------------
// Module: sram_pfe_ctrl
// Space Cubics StaticRAM Read Data Prefetch Controller
//-----------------------------------------------
// Copyright © 2022 Space Cubics, LLC.
//-----------------------------------------------
module sc_hrmem_sram_pfe_ctrl # (
  parameter P_AD_W            = 22,
  parameter P_DT_W            = 32,
  parameter P_BANK_W          = 2,
  parameter P_RD_LTCY         = 3,
  parameter P_PFB_STG_NUM     = 8,
  parameter P_PFB_LINE_NUM    = 8,
  parameter P_SP_PFB_LINE_NUM = 2
) (
  // System Interface
  input                                     SYSCLK,
  input                                     RESETB,

  // AXI SRAM Controller Interface
  input                                     PF_SRCH_VAL,
  input                                     RAM_REN,
  input      [P_AD_W-1:0]                   RAM_RADR,
  input      [P_DT_W/8-1:0]                 RAM_RBTEN,
  output                                    PF_RWAIT,
  input                                     PF_RD_DT_MSK,

  output                                    PF_RD_VAL,
  output                                    RAM_RDT_VAL,
  output     [P_DT_W-1:0]                   RAM_RDATA,

  input                                     CODE_RAM_WEN,
  input      [P_AD_W-1:0]                   CODE_RAM_WADR,
  input                                     SYS_RAM_WEN,
  input      [P_AD_W-1:0]                   SYS_RAM_WADR,

  output                                    PF_ACC_VAL,
  output     [P_AD_W-1:0]                   PF_ACC_ADR,

  // RAM Interface
  output                                    PF_REN,
  output     [P_AD_W-1:0]                   PF_RADR,
  output     [P_DT_W/8-1:0]                 PF_RBTEN,
  input                                     PF_RDT_VAL,
  input      [P_DT_W-1:0]                   PF_RDATA,

  // Register Interface
  input      [P_SP_PFB_LINE_NUM-1:0]        REG_SP_PF_EN,
  input      [P_AD_W*P_SP_PFB_LINE_NUM-1:0] REG_SP_PF_ADR,
  input                                     REG_PF_FLUSH
);

parameter p_pfb_stg_w = (P_PFB_STG_NUM == (2 << 1)) ? 2 :
                        (P_PFB_STG_NUM == (2 << 2)) ? 3 :
                        (P_PFB_STG_NUM == (2 << 3)) ? 4 :
                        (P_PFB_STG_NUM == (2 << 4)) ? 5 :
                        (P_PFB_STG_NUM == (2 << 5)) ? 6 :
                                                      1 ;

parameter p_pfb_line_w = (P_PFB_LINE_NUM <= (2 << 0)) ? 1 :
                         (P_PFB_LINE_NUM <= (2 << 1)) ? 2 :
                         (P_PFB_LINE_NUM <= (2 << 2)) ? 3 :
                         (P_PFB_LINE_NUM <= (2 << 3)) ? 4 :
                         (P_PFB_LINE_NUM <= (2 << 4)) ? 5 :
                                                        6 ;

parameter p_sp_pfb_line_w = (P_SP_PFB_LINE_NUM <= (2 << 0)) ? 1 :
                            (P_SP_PFB_LINE_NUM <= (2 << 1)) ? 2 :
                            (P_SP_PFB_LINE_NUM <= (2 << 2)) ? 3 :
                            (P_SP_PFB_LINE_NUM <= (2 << 3)) ? 4 :
                            (P_SP_PFB_LINE_NUM <= (2 << 4)) ? 5 :
                                                              6 ;

wire w_go_pf_ren;
wire w_nogo_pf_ren;

wire w_pf_rwait_flg;

reg r_pf_lat_en;
reg r_pf_lat_en_1p;
reg r_pf_srch_val_lat;
reg [P_AD_W-1:0] r_ram_radr_lat;
reg [P_DT_W/8-1:0] r_ram_rbten_lat;
reg r_pf_rwait_valid;

wire w_pf_ram_rd_hit;

wire [P_AD_W-1:0] w_ram_radr_sel;
wire [P_DT_W/8-1:0] w_ram_rbten_sel;

wire [P_PFB_LINE_NUM-1:0] w_pfb_empty;
wire [P_PFB_LINE_NUM-1:0] w_pfb_adr_hit;
wire [P_PFB_LINE_NUM-1:0] w_pf_hit;

wire [P_AD_W-1:0] w_sp_pfb_adr [0:P_SP_PFB_LINE_NUM-1];

wire [P_SP_PFB_LINE_NUM-1:0] w_sp_pfb_adr_hit;
wire [P_SP_PFB_LINE_NUM-1:0] w_sp_pf_hit;

wire w_pf_acc_start;

reg               r_pf_acc_rd;
reg               r_pf_acc_ren;
reg [P_AD_W-1:0]  r_pf_acc_radr;
reg [P_RD_LTCY:0] r_pf_acc_rd_retim;
reg [P_RD_LTCY-1:0] r_pf_acc_ren_retim;
reg [P_AD_W-1:0]  r_pf_acc_radr_retim [0:P_RD_LTCY-1];

reg                         r_sp_pf_en;
reg                         r_pf_acc_busy;
reg [p_pfb_stg_w-1:0]       r_pfb_stg_wptr;
reg [p_pfb_line_w-1:0]      r_pfb_line_wptr;
reg [P_PFB_LINE_NUM-1:0]    r_pfb_empty_lat;
reg [P_PFB_LINE_NUM-1:0]    r_pfb_adr_hit_lat;
reg [P_SP_PFB_LINE_NUM-1:0] r_sp_pfb_adr_hit_lat;
reg [P_RD_LTCY-1:0]         r_nogo_pf_ren_retim;
reg [P_RD_LTCY-1:0]         r_nogo_pf_rlat_retim;

reg [p_pfb_line_w-1:0]    r_pfb_line_wsel;
reg [p_sp_pfb_line_w-1:0] r_sp_pfb_line_wsel;
reg [p_pfb_line_w-1:0]    r_pf_hit_sel;
reg [p_sp_pfb_line_w-1:0] r_sp_pf_hit_sel;

wire w_pf_acc_end;
wire w_pf_flush_wait;
reg r_pf_acc_end_1p;
reg r_pf_flush_wait_1p;

wire [P_PFB_LINE_NUM-1:0] w_pf_code_wadr_hit;
wire [P_PFB_LINE_NUM-1:0] w_pf_sys_wadr_hit;

reg [P_PFB_STG_NUM-1:0]        r_pfb_entry [0:P_PFB_LINE_NUM-1];
reg [P_PFB_STG_NUM-1:0]        r_pfb_entry_flush_lat [0:P_PFB_LINE_NUM-1];
reg [P_AD_W-1:0]               r_pfb_adr [0:P_PFB_LINE_NUM-1];
reg [P_DT_W*P_PFB_STG_NUM-1:0] r_pf_buffer [0:P_PFB_LINE_NUM-1];
wire [P_PFB_STG_NUM-1:0]       w_pfb_entry_flush [0:P_PFB_LINE_NUM-1];

wire [P_SP_PFB_LINE_NUM-1:0] w_sp_pf_code_wadr_hit;
wire [P_SP_PFB_LINE_NUM-1:0] w_sp_pf_sys_wadr_hit;

reg [P_PFB_STG_NUM-1:0]        r_sp_pfb_entry [0:P_SP_PFB_LINE_NUM-1];
reg [P_PFB_STG_NUM-1:0]        r_sp_pfb_entry_flush_lat [0:P_SP_PFB_LINE_NUM-1];
reg [P_DT_W*P_PFB_STG_NUM-1:0] r_sp_pf_buffer [0:P_SP_PFB_LINE_NUM-1];
wire [P_PFB_STG_NUM-1:0]       w_sp_pfb_entry_flush [0:P_SP_PFB_LINE_NUM-1];

reg r_pfb_rd_val;
reg [P_DT_W-1:0] r_pf_rd_data;

integer i;
genvar gn;

assign w_go_pf_ren   =  PF_SRCH_VAL & RAM_REN;
assign w_nogo_pf_ren = ~PF_SRCH_VAL & RAM_REN;

assign w_pf_rwait_flg = (r_pf_acc_busy | r_pf_acc_end_1p | r_pf_lat_en_1p) &
                        ((w_nogo_pf_ren & ~r_pf_acc_ren) | (w_go_pf_ren & ~(|w_pf_hit | |w_sp_pf_hit)));

always @ (posedge SYSCLK or negedge RESETB) begin
  if (!RESETB) begin
    r_pf_lat_en       <= 0;
    r_pf_lat_en_1p    <= 0;
    r_pf_srch_val_lat <= 0;
    r_ram_radr_lat    <= 0;
    r_ram_rbten_lat   <= 0;
    r_pf_rwait_valid  <= 0;
  end else begin
    r_pf_lat_en_1p <= r_pf_lat_en;
    if (~r_pf_acc_busy | (r_pf_lat_en & r_pf_srch_val_lat & (|w_pf_hit | |w_sp_pf_hit | w_pf_ram_rd_hit)))
      r_pf_rwait_valid <= 0;
    if (w_pf_rwait_flg) begin
      r_pf_lat_en       <= 1'b1;
      r_pf_srch_val_lat <= PF_SRCH_VAL;
      r_ram_radr_lat    <= RAM_RADR;
      r_ram_rbten_lat   <= RAM_RBTEN;
      if (~w_nogo_pf_ren)
        r_pf_rwait_valid  <= 1'b1;
    end else if (~r_pf_rwait_valid | (r_pf_srch_val_lat & (|w_pf_hit | |w_sp_pf_hit | w_pf_ram_rd_hit))) begin
      r_pf_lat_en <= 0;
    end
  end
end

assign w_pf_ram_rd_hit = r_pf_lat_en & r_pf_srch_val_lat & r_pf_acc_ren_retim[2] & ~PF_RD_DT_MSK &
                         (r_ram_radr_lat == r_pf_acc_radr_retim[2]);

assign PF_RWAIT = r_pf_acc_rd | r_pf_lat_en;

assign w_ram_radr_sel = (r_pf_lat_en & ~w_go_pf_ren) ? r_ram_radr_lat:
                                                       RAM_RADR;
assign w_ram_rbten_sel = (r_pf_lat_en & ~w_go_pf_ren) ? r_ram_rbten_lat:
                                                        RAM_RBTEN;

generate
  for(gn=0; gn<P_PFB_LINE_NUM; gn=gn+1) begin : pf_hit_gen
    assign w_pfb_empty[gn] = ~|r_pfb_entry[gn];
    assign w_pfb_adr_hit[gn] = ~|w_sp_pfb_adr_hit & ~w_pfb_empty[gn] &
                               (w_ram_radr_sel[P_AD_W-1:p_pfb_stg_w+P_BANK_W] ==
                                r_pfb_adr[gn][P_AD_W-1:p_pfb_stg_w+P_BANK_W]);

    assign w_pf_hit[gn]      = w_pfb_adr_hit[gn] &
                               r_pfb_entry[gn][w_ram_radr_sel[p_pfb_stg_w+P_BANK_W-1:P_BANK_W]];
  end
  for(gn=0; gn<P_SP_PFB_LINE_NUM; gn=gn+1) begin : sp_pf_hit_gen
    assign w_sp_pfb_adr[gn] = REG_SP_PF_ADR[P_AD_W*gn +: P_AD_W];
    assign w_sp_pfb_adr_hit[gn] = REG_SP_PF_EN[gn] &
                                  (w_ram_radr_sel[P_AD_W-1:p_pfb_stg_w+P_BANK_W] ==
                                   w_sp_pfb_adr[gn][P_AD_W-1:p_pfb_stg_w+P_BANK_W]);
    assign w_sp_pf_hit[gn]      = w_sp_pfb_adr_hit[gn] &
                                  r_sp_pfb_entry[gn][w_ram_radr_sel[p_pfb_stg_w+P_BANK_W-1:P_BANK_W]];
  end
endgenerate

assign w_pf_acc_start = (w_go_pf_ren | (r_pf_lat_en & r_pf_srch_val_lat)) &
                        ~(w_pf_rwait_flg | r_pf_rwait_valid) &
                        ~(|w_pf_hit | |w_sp_pf_hit);

always @ (posedge SYSCLK or negedge RESETB) begin
  if (!RESETB) begin
    r_pf_acc_rd        <= 0;
    r_pf_acc_ren       <= 0;
    r_pf_acc_radr      <= 0;
    r_pf_acc_rd_retim  <= 0;
    r_pf_acc_ren_retim <= 0;
    for (i=0; i<P_RD_LTCY; i=i+1) begin
      r_pf_acc_radr_retim[i] <= 0;
    end
  end else begin
    r_pf_acc_rd_retim  <= {r_pf_acc_rd_retim[P_RD_LTCY-1:0], r_pf_acc_rd};
    r_pf_acc_ren_retim <= {r_pf_acc_ren_retim[P_RD_LTCY-2:0], r_pf_acc_ren};
    r_pf_acc_radr_retim[0] <= r_pf_acc_radr;
    for (i=1; i<P_RD_LTCY; i=i+1) begin
      r_pf_acc_radr_retim[i] <= r_pf_acc_radr_retim[i-1];
    end
    if (w_pf_acc_start) begin
      r_pf_acc_rd   <= 1'b1;
      r_pf_acc_ren  <= 1'b1;
      r_pf_acc_radr <= w_ram_radr_sel;
    end else if (r_pf_acc_ren) begin
      r_pf_acc_ren  <= 0;
      if (~w_nogo_pf_ren) begin
        if (&r_pf_acc_radr[p_pfb_stg_w+P_BANK_W-1:P_BANK_W] |
            (~r_sp_pf_en &
             r_pfb_entry[r_pfb_line_wsel][r_pf_acc_radr[p_pfb_stg_w+P_BANK_W-1:P_BANK_W]+1]) |
            (r_sp_pf_en &
             r_sp_pfb_entry[r_sp_pfb_line_wsel][r_pf_acc_radr[p_pfb_stg_w+P_BANK_W-1:P_BANK_W]+1])) begin
          r_pf_acc_rd   <= 0;
          r_pf_acc_radr <= 0;
        end else begin
          r_pf_acc_radr <= r_pf_acc_radr + (1 << P_BANK_W);
        end
      end
    end else if (r_pf_acc_rd & ~(w_nogo_pf_ren | (r_pf_lat_en & ~r_pf_srch_val_lat))) begin
      r_pf_acc_ren  <= 1'b1;
    end
  end
end

assign PF_REN  = r_pf_acc_ren |
                 (r_pf_lat_en & ~r_pf_srch_val_lat) |
                 (w_nogo_pf_ren & ~w_pf_rwait_flg);
assign PF_RADR = (r_pf_acc_ren & ~w_nogo_pf_ren) ? r_pf_acc_radr :
                                                   w_ram_radr_sel;
assign PF_RBTEN = (r_pf_acc_ren & ~w_nogo_pf_ren) ? {P_DT_W/8{1'b1}} :
                                                    w_ram_rbten_sel;

always @ (posedge SYSCLK or negedge RESETB) begin
  if (!RESETB) begin
    r_sp_pf_en           <= 0;
    r_pf_acc_busy        <= 0;
    r_pfb_stg_wptr       <= 0;
    r_pfb_line_wptr      <= 0;
    r_pfb_empty_lat      <= 0;
    r_pfb_adr_hit_lat    <= 0;
    r_sp_pfb_adr_hit_lat <= 0;
    r_nogo_pf_ren_retim  <= 0;
    r_nogo_pf_rlat_retim <= 0;
  end else begin
    r_nogo_pf_ren_retim  <= {r_nogo_pf_ren_retim[P_RD_LTCY-2:0], w_nogo_pf_ren};
    r_nogo_pf_rlat_retim <= {r_nogo_pf_rlat_retim[P_RD_LTCY-2:0], (r_pf_lat_en & ~r_pf_srch_val_lat)};
    if (w_pf_acc_start) begin
      if (|w_sp_pfb_adr_hit & ~|w_sp_pf_hit)
        r_sp_pf_en <= 1'b1;
      r_pf_acc_busy        <= 1'b1;
      r_pfb_stg_wptr       <= w_ram_radr_sel[p_pfb_stg_w+P_BANK_W-1:P_BANK_W];
      r_pfb_empty_lat      <= w_pfb_empty;
      r_pfb_adr_hit_lat    <= w_pfb_adr_hit;
      r_sp_pfb_adr_hit_lat <= w_sp_pfb_adr_hit;
    end else if (w_pf_acc_end) begin
      r_sp_pf_en     <= 0;
      r_pf_acc_busy  <= 0;
      r_pfb_stg_wptr <= 0;
      if (~(r_sp_pf_en | |r_pfb_adr_hit_lat | |r_pfb_empty_lat)) begin
        if (r_pfb_line_wptr >= (P_PFB_LINE_NUM -1))
          r_pfb_line_wptr <= 0;
        else
          r_pfb_line_wptr <= r_pfb_line_wptr + 1;
      end
    end else if (r_pf_acc_ren_retim[P_RD_LTCY-1] & ~r_nogo_pf_ren_retim[P_RD_LTCY-1]) begin
      r_pfb_stg_wptr <= r_pfb_stg_wptr + 1;
    end
    if (REG_PF_FLUSH)
      r_pfb_line_wptr <= 0;
  end
end

always @ (*) begin
  if ((w_pf_acc_start & |w_pfb_adr_hit) | (~w_pf_acc_start & |r_pfb_adr_hit_lat)) begin
    for (i=0; i<P_PFB_LINE_NUM; i=i+1) begin
      if ((w_pf_acc_start & w_pfb_adr_hit[i]) | (~w_pf_acc_start & r_pfb_adr_hit_lat[i]))
        r_pfb_line_wsel = i[p_pfb_line_w-1:0];
    end
  end else if ((w_pf_acc_start & |w_pfb_empty) | (~w_pf_acc_start & |r_pfb_empty_lat)) begin
    for (i=P_PFB_LINE_NUM-1; i>=0; i=i-1) begin
      if ((w_pf_acc_start & w_pfb_empty[i]) | (~w_pf_acc_start & r_pfb_empty_lat[i]))
        r_pfb_line_wsel = i[p_pfb_line_w-1:0];
    end
  end else begin
    r_pfb_line_wsel = r_pfb_line_wptr;
  end

  for (i=0; i<P_SP_PFB_LINE_NUM; i=i+1) begin
    if ((w_pf_acc_start & w_sp_pfb_adr_hit[i]) | (~w_pf_acc_start & r_sp_pfb_adr_hit_lat[i]))
      r_sp_pfb_line_wsel = i[p_sp_pfb_line_w-1:0];
  end

  for (i=0; i<P_PFB_LINE_NUM; i=i+1) begin
    if (w_pf_hit[i])
      r_pf_hit_sel = i[p_pfb_line_w-1:0];
  end

  for (i=0; i<P_SP_PFB_LINE_NUM; i=i+1) begin
    if (w_sp_pf_hit[i])
      r_sp_pf_hit_sel = i[p_sp_pfb_line_w-1:0];
  end
end

assign w_pf_acc_end = ~r_pf_acc_rd_retim[P_RD_LTCY-2] & r_pf_acc_rd_retim[P_RD_LTCY-1];

assign w_pf_flush_wait = w_pf_acc_start | r_pf_acc_busy;

always @ (posedge SYSCLK or negedge RESETB) begin
  if (!RESETB) begin
    r_pf_acc_end_1p    <= 0;
    r_pf_flush_wait_1p <= 0;
  end else begin
    r_pf_acc_end_1p    <= w_pf_acc_end;
    r_pf_flush_wait_1p <= w_pf_flush_wait;
  end
end

generate
  for(gn=0; gn<P_PFB_LINE_NUM; gn=gn+1) begin : pf_buffer_gen

    assign w_pf_code_wadr_hit[gn] = CODE_RAM_WEN & (CODE_RAM_WADR[P_AD_W-1:p_pfb_stg_w+P_BANK_W] ==
                                                    r_pfb_adr[gn][P_AD_W-1:p_pfb_stg_w+P_BANK_W]);
    assign w_pf_sys_wadr_hit[gn]  = SYS_RAM_WEN  &  (SYS_RAM_WADR[P_AD_W-1:p_pfb_stg_w+P_BANK_W] ==
                                                    r_pfb_adr[gn][P_AD_W-1:p_pfb_stg_w+P_BANK_W]);

    always @ (posedge SYSCLK or negedge RESETB) begin
      if (!RESETB) begin
        r_pfb_entry[gn]           <= 0;
        r_pfb_entry_flush_lat[gn] <= 0;
        r_pfb_adr[gn]             <= 0;
        r_pf_buffer[gn]           <= 0;
      end else begin
        if (REG_PF_FLUSH) begin
          r_pfb_entry[gn] <= 0;
        end else if (~w_pf_flush_wait) begin
          r_pfb_entry_flush_lat[gn] <= 0;
          if (r_pf_flush_wait_1p) begin
             r_pfb_entry[gn] <= r_pfb_entry[gn] & ~w_pfb_entry_flush[gn];
          end else begin
            if (w_pf_code_wadr_hit[gn])
              r_pfb_entry[gn][CODE_RAM_WADR[p_pfb_stg_w+P_BANK_W-1:P_BANK_W]] <= 0;
            if (w_pf_sys_wadr_hit[gn])
              r_pfb_entry[gn][SYS_RAM_WADR[p_pfb_stg_w+P_BANK_W-1:P_BANK_W]]  <= 0;
          end
        end else begin
          if (w_pf_acc_start & ~|w_pfb_adr_hit & ~|w_sp_pfb_adr_hit & r_pfb_line_wsel == gn)
            r_pfb_entry[gn] <= 0;
          if (~r_sp_pf_en & (r_pfb_line_wsel == gn) & r_pf_acc_ren_retim[P_RD_LTCY-1] &
                                                      ~r_nogo_pf_ren_retim[P_RD_LTCY-1])
            r_pfb_entry[gn][r_pfb_stg_wptr] <= 1'b1;
          if (w_pf_code_wadr_hit[gn])
            r_pfb_entry_flush_lat[gn][CODE_RAM_WADR[p_pfb_stg_w+P_BANK_W-1:P_BANK_W]] <= 1'b1;
          if (w_pf_sys_wadr_hit[gn])
            r_pfb_entry_flush_lat[gn][SYS_RAM_WADR[p_pfb_stg_w+P_BANK_W-1:P_BANK_W]]  <= 1'b1;
        end

        if (~|w_sp_pfb_adr_hit & r_pfb_line_wsel == gn) begin
          if (w_pf_acc_start & ~|w_pfb_adr_hit)
            r_pfb_adr[gn] <= {w_ram_radr_sel[P_AD_W-1:p_pfb_stg_w+P_BANK_W], {p_pfb_stg_w+P_BANK_W{1'b0}}};
        end

        if (~r_sp_pf_en & r_pfb_line_wsel == gn) begin
          if (r_pf_acc_ren_retim[P_RD_LTCY-1] & ~r_nogo_pf_ren_retim[P_RD_LTCY-1])
            r_pf_buffer[gn][r_pfb_stg_wptr*P_DT_W +: P_DT_W] <= PF_RDATA;
        end
      end
    end

    assign w_pfb_entry_flush[gn] = r_pfb_entry_flush_lat[gn] |
                                   ({P_PFB_STG_NUM{w_pf_code_wadr_hit[gn]}} &
                                    (1 << CODE_RAM_WADR[p_pfb_stg_w+P_BANK_W-1:P_BANK_W])) |
                                   ({P_PFB_STG_NUM{w_pf_sys_wadr_hit[gn]}}  &
                                    (1 <<  SYS_RAM_WADR[p_pfb_stg_w+P_BANK_W-1:P_BANK_W])) ;

  end
  for(gn=0; gn<P_SP_PFB_LINE_NUM; gn=gn+1) begin : sp_pf_buffer_gen

    assign w_sp_pf_code_wadr_hit[gn] = CODE_RAM_WEN & (CODE_RAM_WADR[P_AD_W-1:p_pfb_stg_w+P_BANK_W] ==
                                                    w_sp_pfb_adr[gn][P_AD_W-1:p_pfb_stg_w+P_BANK_W]);
    assign w_sp_pf_sys_wadr_hit[gn]  = SYS_RAM_WEN  &  (SYS_RAM_WADR[P_AD_W-1:p_pfb_stg_w+P_BANK_W] ==
                                                    w_sp_pfb_adr[gn][P_AD_W-1:p_pfb_stg_w+P_BANK_W]);

    always @ (posedge SYSCLK or negedge RESETB) begin
      if (!RESETB) begin
        r_sp_pfb_entry[gn]           <= 0;
        r_sp_pfb_entry_flush_lat[gn] <= 0;
        r_sp_pf_buffer[gn]           <= 0;
      end else begin
        if (REG_PF_FLUSH | ~REG_SP_PF_EN[gn]) begin
          r_sp_pfb_entry[gn] <= 0;
        end else if (~w_pf_flush_wait) begin
          r_sp_pfb_entry_flush_lat[gn] <= 0;
          if (r_pf_flush_wait_1p) begin
             r_sp_pfb_entry[gn] <= r_sp_pfb_entry[gn] & ~w_sp_pfb_entry_flush[gn];
          end else begin
            if (w_sp_pf_code_wadr_hit[gn])
              r_sp_pfb_entry[gn][CODE_RAM_WADR[p_pfb_stg_w+P_BANK_W-1:P_BANK_W]] <= 0;
            if (w_sp_pf_sys_wadr_hit[gn])
              r_sp_pfb_entry[gn][SYS_RAM_WADR[p_pfb_stg_w+P_BANK_W-1:P_BANK_W]]  <= 0;
          end
        end else begin
          if (r_sp_pf_en & (r_sp_pfb_line_wsel == gn) & r_pf_acc_ren_retim[P_RD_LTCY-1] &
                                                        ~r_nogo_pf_ren_retim[P_RD_LTCY-1])
            r_sp_pfb_entry[gn][r_pfb_stg_wptr] <= 1'b1;
          if (w_sp_pf_code_wadr_hit[gn])
            r_sp_pfb_entry_flush_lat[gn][CODE_RAM_WADR[p_pfb_stg_w+P_BANK_W-1:P_BANK_W]] <= 1'b1;
          if (w_sp_pf_sys_wadr_hit[gn])
            r_sp_pfb_entry_flush_lat[gn][SYS_RAM_WADR[p_pfb_stg_w+P_BANK_W-1:P_BANK_W]]  <= 1'b1;
        end

        if (r_sp_pf_en & r_sp_pfb_line_wsel == gn) begin
          if (r_pf_acc_ren_retim[P_RD_LTCY-1] & ~r_nogo_pf_ren_retim[P_RD_LTCY-1])
            r_sp_pf_buffer[gn][r_pfb_stg_wptr*P_DT_W +: P_DT_W] <= PF_RDATA;
        end
      end
    end

    assign w_sp_pfb_entry_flush[gn] = r_sp_pfb_entry_flush_lat[gn] |
                                      ({P_PFB_STG_NUM{w_sp_pf_code_wadr_hit[gn]}} &
                                       (1 << CODE_RAM_WADR[p_pfb_stg_w+P_BANK_W-1:P_BANK_W])) |
                                      ({P_PFB_STG_NUM{w_sp_pf_sys_wadr_hit[gn]}}  &
                                       (1 <<  SYS_RAM_WADR[p_pfb_stg_w+P_BANK_W-1:P_BANK_W])) ;

  end
endgenerate

always @ (posedge SYSCLK or negedge RESETB) begin
  if (!RESETB) begin
    r_pfb_rd_val         <= 0;
    r_pf_rd_data         <= 0;
  end else begin
    r_pfb_rd_val <= (w_go_pf_ren | (r_pf_lat_en & r_pf_srch_val_lat)) & (|w_pf_hit | |w_sp_pf_hit);

    if ((w_go_pf_ren | (r_pf_lat_en & r_pf_srch_val_lat)) & |w_pf_hit) begin
      r_pf_rd_data <= r_pf_buffer[r_pf_hit_sel][P_DT_W*(w_ram_radr_sel[p_pfb_stg_w+P_BANK_W-1:P_BANK_W]) +: P_DT_W];
    end else if ((w_go_pf_ren | (r_pf_lat_en & r_pf_srch_val_lat)) & |w_sp_pf_hit) begin
      r_pf_rd_data <= r_sp_pf_buffer[r_sp_pf_hit_sel][P_DT_W*(w_ram_radr_sel[p_pfb_stg_w+P_BANK_W-1:P_BANK_W]) +: P_DT_W];
    end else begin
      r_pf_rd_data <= 0;
    end
  end
end

assign PF_RD_VAL   = r_pfb_rd_val | (r_pf_acc_rd_retim[P_RD_LTCY-1] & ~r_pf_acc_rd_retim[P_RD_LTCY]) |
                     w_pf_ram_rd_hit;
assign RAM_RDT_VAL = PF_RD_VAL | ((~r_pf_acc_busy | r_nogo_pf_ren_retim[P_RD_LTCY-1] |
                     r_nogo_pf_rlat_retim[P_RD_LTCY-1]) & PF_RDT_VAL);
assign RAM_RDATA   = (r_pfb_rd_val) ? r_pf_rd_data:
                                      PF_RDATA;

assign PF_ACC_VAL  = r_pf_acc_rd | r_pf_acc_rd_retim[0];
assign PF_ACC_ADR  = (r_pf_acc_rd_retim[0]) ? r_pf_acc_radr_retim[0]:
                                              r_pf_acc_radr;

endmodule
