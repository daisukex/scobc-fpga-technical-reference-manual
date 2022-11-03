//-----------------------------------------------
// Module: sc_hrmem_sram_ecc_ctrl
//  Space Cubics StaticRAM ECC Controller
//-----------------------------------------------
// Copyright © 2022 Space Cubics, LLC.
//-----------------------------------------------
module sc_hrmem_sram_ecc_ctrl # (
  parameter P_AD_W = 20,
  parameter P_DT_W = 32,
  parameter P_RD_LTCY = 3
) (
  // System Interface
  input                   CLK,
  input                   RESET_N,

  input                   RD_LTCY_MODE,

  // AXI SRAM Controller Interface
  input                   AXI_WEN,
  input      [P_AD_W-1:0] AXI_WADR,
  input                   AXI_REN,

  // RAM Access Selector Interface
  input                   RAM_REN,

  // RAM Interface
  output                  MEM_ATRD_VAL,
  output reg [P_AD_W-1:0] MEM_ATRD_ADR,

  input                   INT_ECC1ERR,
  input                   INT_ECC2ERR,
  input      [P_AD_W-1:0] ECCERR_ADR,
  input      [P_DT_W/8-1:0] ECCERR_BTEN,
  input      [P_DT_W-1:0] ECCCOL_DAT,
  output                  MEM_COR_VAL,
  output reg [P_AD_W-1:0] MEM_COR_ADR,
  output reg [P_DT_W/8-1:0] MEM_COR_BTEN,
  output reg [P_DT_W-1:0] MEM_COR_DATA,
  output                  MEM_COR_VAL_BEF,
  input                   MEM_COR_VAL_CXL,
  input      [P_AD_W-1:0] MEM_COR_ADR_CXL,
  input      [P_DT_W/8-1:0] MEM_COR_BTEN_CXL,
  input      [P_DT_W-1:0] MEM_COR_DATA_CXL,

  // RAM Scrub Sequencer Interface
  input                   MEM_SCRB_ACT,

  // Debug Interface
  input                   RAM_RD_AXI,
  input                   RAM_RD_ATRD,
  input                   RAM_RD_ATRD_CXL,

  // Register Interface
  input                   ECC_COL_EN,
  input                   COL_FSTK_RDSTOP,
  output reg              RAM_ECC1ERR,
  output reg              RAM_ECC2ERR,
  output reg              RAM_ECC1ERR_AXI,
  output reg              RAM_ECC2ERR_AXI,
  output reg              RAM_ECC1ERR_ATRD,
  output reg              RAM_ECC2ERR_ATRD,
  output reg [P_AD_W-1:0] RAM_ECCERR_ADR,
  output reg              ECC_COL_DISC
);

parameter P_SFIFO_AD_W = 4; // Stock FIFO Address WIDTH
parameter [P_SFIFO_AD_W-1:0] P_SFIFO_AMF_CAP = 5; // Remaining Stock FIFO capacity when Allmost Full

wire [2:0] RD_LTCY_SEL = P_RD_LTCY - (RD_LTCY_MODE==0);

reg [1:0] axi_wen_retim;
reg [P_AD_W-1:0] axi_wadr_retim;
reg [P_RD_LTCY-3:0] axi_ren_retim;
reg cor_val_retim;
reg [P_RD_LTCY-2:0] ram_ren_p;
reg [P_RD_LTCY-2:0] ram_rd_axi_p;
reg [P_RD_LTCY-2:0] ram_rd_atrd_p;
reg r_mem_atrd_trg;
reg r_mem_atrd_val_1p;

wire w_hprio_acc;
wire w_col_mask;
wire w_write_conf;
wire w_sfifo_wr_val;
wire w_sfifo_rd_val;
wire w_sfifo_rev_val;
wire w_cor_cxl_val;

reg [P_SFIFO_AD_W-1:0] r_sfifo_wp;
reg [P_SFIFO_AD_W-1:0] r_sfifo_rp;
reg r_sfifo_full;
reg r_sfifo_amfull;
reg [2**P_SFIFO_AD_W-1:0] r_sfifo_val;
reg [P_AD_W-1:0] r_sfifo_adr [0:2**P_SFIFO_AD_W-1];
reg [P_DT_W/8-1:0] r_sfifo_bten [0:2**P_SFIFO_AD_W-1];
reg [P_DT_W-1:0] r_sfifo_data [0:2**P_SFIFO_AD_W-1];

reg r_cor_val_lat;
reg [P_AD_W-1:0] r_cor_adr_lat;
reg [P_DT_W/8-1:0] r_cor_bten_lat;
reg [P_DT_W-1:0] r_cor_data_lat;

reg pre_cor_val;

integer i;

// RAM Read Enable Signal Retiming
always @ (posedge CLK or negedge RESET_N) begin
  if (!RESET_N) begin
    axi_wen_retim  <= 0;
    axi_wadr_retim <= 0;
    axi_ren_retim  <= 0;
    cor_val_retim  <= 0;
    ram_ren_p      <= 0;
    ram_rd_axi_p   <= 0;
    ram_rd_atrd_p  <= 0;
  end else begin
    axi_wen_retim  <= {axi_wen_retim[0], AXI_WEN};
    axi_wadr_retim <= AXI_WADR;
    axi_ren_retim[0] <= AXI_REN;
    if (P_RD_LTCY > 3) begin
      for (i=1; i<P_RD_LTCY-2; i=i+1)
        axi_ren_retim[i] <= axi_ren_retim[i-1];
    end
    cor_val_retim  <= MEM_COR_VAL;
    ram_ren_p      <= {ram_ren_p[P_RD_LTCY-3:0], RAM_REN};
    ram_rd_axi_p   <= {ram_rd_axi_p[P_RD_LTCY-3:0], RAM_RD_AXI};
    ram_rd_atrd_p  <= {ram_rd_atrd_p[P_RD_LTCY-3:0], RAM_RD_ATRD};
  end
end

// Memory Auto Read Triger
always @ (posedge CLK or negedge RESET_N) begin
  if (!RESET_N) begin
    r_mem_atrd_trg <= 0;
  end else begin
    r_mem_atrd_trg <= ECC_COL_EN & MEM_SCRB_ACT & (~COL_FSTK_RDSTOP | ~r_sfifo_amfull);
  end
end

// Memory Auto Read Valid
assign MEM_ATRD_VAL = r_mem_atrd_trg & ~(AXI_REN |
                                         (RD_LTCY_MODE & |axi_ren_retim[P_RD_LTCY-3:0]) |
                                         (~RD_LTCY_MODE & |axi_ren_retim[P_RD_LTCY-4:0]) |
                                         AXI_WEN | |axi_wen_retim |
                                         MEM_COR_VAL_BEF | MEM_COR_VAL | cor_val_retim |
                                         r_mem_atrd_val_1p);

always @ (posedge CLK or negedge RESET_N) begin
  if (!RESET_N) begin
    r_mem_atrd_val_1p <= 0;
  end else begin
    r_mem_atrd_val_1p <= MEM_ATRD_VAL;
  end
end

// Memory Auto Read Address
always @ (posedge CLK or negedge RESET_N) begin
  if (!RESET_N) begin
    MEM_ATRD_ADR <= 0;
  end else if (~ECC_COL_EN) begin
    MEM_ATRD_ADR <= 0;
  end else if (MEM_ATRD_VAL) begin
    MEM_ATRD_ADR <= MEM_ATRD_ADR + 1;
  end else if (RAM_RD_ATRD_CXL) begin
    MEM_ATRD_ADR <= MEM_ATRD_ADR - 1;
  end
end

assign w_hprio_acc    = AXI_WEN | axi_wen_retim[0] | AXI_REN |
                        (RD_LTCY_MODE & |axi_ren_retim[P_RD_LTCY-3:0]) |
                        (~RD_LTCY_MODE & |axi_ren_retim[P_RD_LTCY-4:0]) |
                        MEM_COR_VAL;
assign w_col_mask     = axi_wen_retim[0] & (ECCERR_ADR == axi_wadr_retim);
assign w_write_conf   = ram_ren_p[RD_LTCY_SEL-2] & INT_ECC1ERR & w_hprio_acc & ~w_col_mask;
assign w_sfifo_wr_val = w_write_conf & (~r_sfifo_full | w_sfifo_rd_val);
assign w_sfifo_rd_val = ~((ram_ren_p[RD_LTCY_SEL-2] & INT_ECC1ERR) | w_hprio_acc) &
                        (r_sfifo_wp != r_sfifo_rp | r_sfifo_full);
assign w_sfifo_rev_val = ((pre_cor_val & (AXI_WEN | AXI_REN)) | r_cor_val_lat) &
                         (~r_sfifo_full | w_sfifo_rd_val);
assign w_cor_cxl_val = MEM_COR_VAL_CXL & (~r_sfifo_full | w_sfifo_rd_val);

// Stock FIFO Write/Read Pointer
always @ (posedge CLK or negedge RESET_N) begin
  if (!RESET_N) begin
    r_sfifo_wp <= 0;
    r_sfifo_rp <= 0;
  end else if (~ECC_COL_EN) begin
    r_sfifo_wp <= 0;
    r_sfifo_rp <= 0;
  end else begin
    if (w_sfifo_wr_val | w_sfifo_rev_val | w_cor_cxl_val)
      r_sfifo_wp <= r_sfifo_wp + 1;
    if (w_sfifo_rd_val)
      r_sfifo_rp <= r_sfifo_rp + 1;
  end
end

// Stock FIFO full
always @ (posedge CLK or negedge RESET_N) begin
  if (!RESET_N) begin
    r_sfifo_full   <= 0;
    r_sfifo_amfull <= 0;
  end else if (~ECC_COL_EN) begin
    r_sfifo_full   <= 0;
    r_sfifo_amfull <= 0;
  end else if (w_sfifo_wr_val | w_sfifo_rev_val | w_cor_cxl_val) begin
    if (w_sfifo_rd_val) begin
      r_sfifo_full   <= r_sfifo_full;
      r_sfifo_amfull <= r_sfifo_amfull;
    end else begin
      if (r_sfifo_wp == (r_sfifo_rp - 1'b1))
        r_sfifo_full   <= 1;
      if (r_sfifo_wp == (r_sfifo_rp - P_SFIFO_AMF_CAP))
        r_sfifo_amfull <= 1;
    end
  end else if (w_sfifo_rd_val) begin
    r_sfifo_full <= 0;
    if (r_sfifo_wp == (r_sfifo_rp - (P_SFIFO_AMF_CAP - 1'b1)))
      r_sfifo_amfull <= 0;
  end
end

// Stock FIFO Write Data Discard
always @ (posedge CLK or negedge RESET_N) begin
  if (!RESET_N) begin
    ECC_COL_DISC <= 0;
  end else if (ECC_COL_EN & r_sfifo_full & ~w_sfifo_rd_val &
               (w_write_conf |
                ((pre_cor_val & (AXI_WEN | AXI_REN)) | r_cor_val_lat) |
                MEM_COR_VAL_CXL)) begin
    ECC_COL_DISC <= 1;
  end else begin
    ECC_COL_DISC <= 0;
  end
end

genvar gn;
generate
  for(gn=0; gn<2**P_SFIFO_AD_W; gn=gn+1) begin : sfifo_gen

    // Stock FIFO Data Valid
    always @ (posedge CLK or negedge RESET_N) begin
      if (!RESET_N) begin
        r_sfifo_val[gn] <= 0;
      end else if (~ECC_COL_EN) begin
        r_sfifo_val[gn] <= 0;
      end else if ((w_sfifo_wr_val | (pre_cor_val & (AXI_WEN | AXI_REN)) |
                    r_cor_val_lat | MEM_COR_VAL_CXL) & r_sfifo_wp == gn) begin
        r_sfifo_val[gn] <= 1;
      end else if (axi_wen_retim[0] & r_sfifo_adr[gn] == axi_wadr_retim) begin
        r_sfifo_val[gn] <= 0;
      end
    end

    // Stock FIFO Write from ECC 1bit Error Correction DATA
    always @ (posedge CLK or negedge RESET_N) begin
      if (!RESET_N) begin
        r_sfifo_adr[gn]  <= 0;
        r_sfifo_bten[gn] <= 0;
        r_sfifo_data[gn] <= 0;
      end else if (~ECC_COL_EN) begin
        r_sfifo_adr[gn]  <= 0;
        r_sfifo_bten[gn] <= 0;
        r_sfifo_data[gn] <= 0;
      end else if (w_sfifo_wr_val & r_sfifo_wp == gn) begin
        r_sfifo_adr[gn]  <= ECCERR_ADR;
        r_sfifo_bten[gn] <= ECCERR_BTEN;
        r_sfifo_data[gn] <= ECCCOL_DAT;
      end else if (pre_cor_val & (AXI_WEN | AXI_REN) & r_sfifo_wp == gn) begin
        r_sfifo_adr[gn]  <= MEM_COR_ADR;
        r_sfifo_bten[gn] <= MEM_COR_BTEN;
        r_sfifo_data[gn] <= MEM_COR_DATA;
      end else if (r_cor_val_lat & r_sfifo_wp == gn) begin
        r_sfifo_adr[gn]  <= r_cor_adr_lat;
        r_sfifo_bten[gn] <= r_cor_bten_lat;
        r_sfifo_data[gn] <= r_cor_data_lat;
      end else if (MEM_COR_VAL_CXL & r_sfifo_wp == gn) begin
        r_sfifo_adr[gn]  <= MEM_COR_ADR_CXL;
        r_sfifo_bten[gn] <= MEM_COR_BTEN_CXL;
        r_sfifo_data[gn] <= MEM_COR_DATA_CXL;
      end
    end

  end
endgenerate

always @ (posedge CLK or negedge RESET_N) begin
  if (!RESET_N) begin
    r_cor_val_lat  <= 0;
    r_cor_adr_lat  <= 0;
    r_cor_bten_lat <= 0;
    r_cor_data_lat <= 0;
  end else if (w_sfifo_wr_val & pre_cor_val & (AXI_WEN | AXI_REN)) begin
    r_cor_val_lat  <= 1'b1;
    r_cor_adr_lat  <= MEM_COR_ADR;
    r_cor_bten_lat <= MEM_COR_BTEN;
    r_cor_data_lat <= MEM_COR_DATA;
  end else begin
    r_cor_val_lat  <= 0;
    r_cor_adr_lat  <= 0;
    r_cor_bten_lat <= 0;
    r_cor_data_lat <= 0;
  end
end

// ECC 1bit Error Correction
always @ (posedge CLK or negedge RESET_N) begin
  if (!RESET_N) begin
    pre_cor_val  <= 0;
    MEM_COR_ADR  <= 0;
    MEM_COR_BTEN <= 0;
    MEM_COR_DATA <= 0;
  end else if (ECC_COL_EN & ~w_hprio_acc) begin
    if (ram_ren_p[RD_LTCY_SEL-2] & INT_ECC1ERR) begin
      pre_cor_val  <= 1;
      MEM_COR_ADR  <= ECCERR_ADR;
      MEM_COR_BTEN <= ECCERR_BTEN;
      MEM_COR_DATA <= ECCCOL_DAT;
    end else if (w_sfifo_rd_val) begin
      pre_cor_val  <= r_sfifo_val[r_sfifo_rp];
      MEM_COR_ADR  <= r_sfifo_adr[r_sfifo_rp];
      MEM_COR_BTEN <= r_sfifo_bten[r_sfifo_rp];
      MEM_COR_DATA <= r_sfifo_data[r_sfifo_rp];
    end else begin
      pre_cor_val  <= 0;
      MEM_COR_ADR  <= 0;
      MEM_COR_BTEN <= 0;
      MEM_COR_DATA <= 0;
    end
  end else begin
    pre_cor_val  <= 0;
    MEM_COR_ADR  <= 0;
    MEM_COR_BTEN <= 0;
    MEM_COR_DATA <= 0;
  end
end
assign MEM_COR_VAL = pre_cor_val & ~(AXI_WEN | AXI_REN);
assign MEM_COR_VAL_BEF = ECC_COL_EN & ~w_hprio_acc &
                         ((ram_ren_p[RD_LTCY_SEL-2] & INT_ECC1ERR) | w_sfifo_rd_val);

// ECC Error Detect Output
always @ (posedge CLK or negedge RESET_N) begin
  if (!RESET_N) begin
    RAM_ECC1ERR      <= 0;
    RAM_ECC2ERR      <= 0;
    RAM_ECC1ERR_AXI  <= 0;
    RAM_ECC2ERR_AXI  <= 0;
    RAM_ECC1ERR_ATRD <= 0;
    RAM_ECC2ERR_ATRD <= 0;
    RAM_ECCERR_ADR   <= 0;
  end else begin
    RAM_ECC1ERR      <= ram_ren_p[RD_LTCY_SEL-2] & INT_ECC1ERR;
    RAM_ECC2ERR      <= ram_ren_p[RD_LTCY_SEL-2] & INT_ECC2ERR;
    RAM_ECC1ERR_AXI  <= ram_rd_axi_p[RD_LTCY_SEL-2] & INT_ECC1ERR;
    RAM_ECC2ERR_AXI  <= ram_rd_axi_p[RD_LTCY_SEL-2] & INT_ECC2ERR;
    RAM_ECC1ERR_ATRD <= ram_rd_atrd_p[RD_LTCY_SEL-2] & INT_ECC1ERR;
    RAM_ECC2ERR_ATRD <= ram_rd_atrd_p[RD_LTCY_SEL-2] & INT_ECC2ERR;
    if (ram_ren_p[RD_LTCY_SEL-2] & (INT_ECC1ERR | INT_ECC2ERR))
      RAM_ECCERR_ADR   <= ECCERR_ADR;
  end
end

endmodule
