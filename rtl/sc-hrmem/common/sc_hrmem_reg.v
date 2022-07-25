//-----------------------------------------------
// Module: sc_hrmem_reg
//  Space Cubics High Reliability Memory Register
//-----------------------------------------------
// Copyright © 2022 Space Cubics, LLC.
//-----------------------------------------------
`include "sc_hrmem_version.vh"
`include "sc_hrmem_reg_map.vh"

module sc_hrmem_reg # (
  parameter P_AD_W            = 16,
  parameter P_BANK_W          = 2,
  parameter [15:0] P_MSC_INI  = 0,
  parameter P_PFB_STG_NUM     = 8,
  parameter P_SP_PFB_LINE_NUM = 2
) (
  // System Interface
  input SYSCLK,
  input RESETB,

  // AHB Interface
  input REG_ACC,
  input REG_W1R0,
  input [31:0] REG_ADDR,
  input [3:0] REG_BYTEEN,
  input [31:0] REG_WDATA,
  output [31:0] REG_RDATA,

  // Memory Controller Interface
  output reg REG_INJ_ECC1ERR,
  output reg REG_INJ_ECC2ERR,
  output reg REG_ECC_COL_EN,
  output reg REG_MEM_SCRB_EN,
  output reg [15:0] REG_MEM_SCRB_CYCLE,
  output REG_COL_FSTK_RDSTOP,
  output reg REG_ECCERRCNT_CLR,
  input REG_RAM_ECC1ERR,
  input REG_RAM_ECC2ERR,
  input REG_RAM_ECC1ERR_AXI,
  input REG_RAM_ECC2ERR_AXI,
  input REG_RAM_ECC1ERR_ATRD,
  input REG_RAM_ECC2ERR_ATRD,
  input REG_ECC_COL_DISC,
  input [15:0] REG_RAM_ECC1ERR_AXI_CNT,
  input [15:0] REG_RAM_ECC2ERR_AXI_CNT,
  input [15:0] REG_RAM_ECC1ERR_ATRD_CNT,
  input [15:0] REG_RAM_ECC2ERR_ATRD_CNT,
  input [15:0] REG_ECC_COL_DISC_CNT,

  // Prefetch Controller Interface
  output reg [1:0] REG_PF_MODE_SEL,
  output reg [P_SP_PFB_LINE_NUM-1:0] REG_SP_PF_EN,
  output reg [P_AD_W*P_SP_PFB_LINE_NUM-1:0] REG_SP_PF_ADR,
  output reg REG_PF_FLUSH,

  // Interrupt Interface
  output HRMEM_INT
);

parameter p_pfb_stg_w = (P_PFB_STG_NUM == (2 << 1)) ? 2 :
                        (P_PFB_STG_NUM == (2 << 2)) ? 3 :
                        (P_PFB_STG_NUM == (2 << 3)) ? 4 :
                        (P_PFB_STG_NUM == (2 << 4)) ? 5 :
                        (P_PFB_STG_NUM == (2 << 5)) ? 6 :
                                                      1 ;

integer i;
genvar gn, gnb;

wire w_reg_write;
wire w_reg_read;
assign w_reg_write = REG_ACC &  REG_W1R0;
assign w_reg_read  = REG_ACC & !REG_W1R0;

// Address Decoder
wire w_hit_ecccolenr;
wire w_hit_memscrctrlr;
wire w_hit_hrmintstr;
wire w_hit_hrmintenr;
wire w_hit_ecc1errcntr;
wire w_hit_ecc2errcntr;
wire w_hit_ecdiscntr;
wire w_hit_errcntclrr;
wire w_hit_eccerrinsr;
wire w_hit_pfemdctlr;
wire w_hit_spepfenr;
wire w_hit_pfbufflushr;
wire [P_SP_PFB_LINE_NUM-1:0] w_hit_spepfadrsetr;
wire w_hit_hrmemver;
assign w_hit_ecccolenr      = ({REG_ADDR[15:2] , 2'b00} == `ECCCOLENR);
assign w_hit_memscrctrlr    = ({REG_ADDR[15:2] , 2'b00} == `MEMSCRCTRLR);
assign w_hit_hrmintstr      = ({REG_ADDR[15:2] , 2'b00} == `HRMINTSTR);
assign w_hit_hrmintenr      = ({REG_ADDR[15:2] , 2'b00} == `HRMINTENR);
assign w_hit_ecc1errcntr    = ({REG_ADDR[15:2] , 2'b00} == `ECC1ERRCNTR);
assign w_hit_ecc2errcntr    = ({REG_ADDR[15:2] , 2'b00} == `ECC2ERRCNTR);
assign w_hit_ecdiscntr      = ({REG_ADDR[15:2] , 2'b00} == `ECDISCNTR);
assign w_hit_errcntclrr     = ({REG_ADDR[15:2] , 2'b00} == `ERRCNTCLRR);
assign w_hit_eccerrinsr     = ({REG_ADDR[15:2] , 2'b00} == `ECCERRINSR);
assign w_hit_pfemdctlr      = ({REG_ADDR[15:2] , 2'b00} == `PFEMDCTLR);
assign w_hit_spepfenr       = ({REG_ADDR[15:2] , 2'b00} == `SPEPFENR);
assign w_hit_pfbufflushr    = ({REG_ADDR[15:2] , 2'b00} == `PFBUFFLUSHR);
generate
  for(gn=0; gn<P_SP_PFB_LINE_NUM; gn=gn+1) begin : hit_spepfadrsetr_gen
    assign w_hit_spepfadrsetr[gn] = ({REG_ADDR[15:2] , 2'b00} == `SPEPFADRSETR + (gn*4));
  end
endgenerate
assign w_hit_hrmemver       = ({REG_ADDR[15:2] , 2'b00} == `HRMEMVER);

// ECC Error Collect Enable Register
//----------------------------------------------
always @ (posedge SYSCLK or negedge RESETB) begin
  if (!RESETB) begin
    REG_ECC_COL_EN <= 1'b1;
  end else if (w_hit_ecccolenr & w_reg_write) begin
    if (REG_BYTEEN[0])
      REG_ECC_COL_EN <= REG_WDATA[`ECCCOLEN];
  end
end

wire [31:0] w_rd_ecccolenr;
assign w_rd_ecccolenr = (w_hit_ecccolenr & w_reg_read) ?
                        {{32-1-`ECCCOLEN{1'b0}}, REG_ECC_COL_EN, {`ECCCOLEN{1'b0}}} :
                        32'h0;

// Memory Scrubing Control Register
//----------------------------------------------
reg w_col_fstk_rdstop_n;
always @ (posedge SYSCLK or negedge RESETB) begin
  if (!RESETB) begin
    w_col_fstk_rdstop_n <= 0;
    REG_MEM_SCRB_CYCLE  <= P_MSC_INI;
    REG_MEM_SCRB_EN     <= 0;
  end else if (w_hit_memscrctrlr & w_reg_write) begin
    if (REG_BYTEEN[3])
      REG_MEM_SCRB_CYCLE[15:8] <= REG_WDATA[`MEMSCRCYC+8 +: 8];
    if (REG_BYTEEN[2])
      REG_MEM_SCRB_CYCLE[7:0]  <= REG_WDATA[`MEMSCRCYC +: 8];
    if (REG_BYTEEN[1])
      w_col_fstk_rdstop_n      <= REG_WDATA[`COLFSRDSTPB];
    if (REG_BYTEEN[0])
      REG_MEM_SCRB_EN          <= REG_WDATA[`MEMSCRBEN];
  end
end

wire [31:0] w_rd_memscrctrlr;
assign w_rd_memscrctrlr = (w_hit_memscrctrlr & w_reg_read) ?
                          {{32-16-`MEMSCRCYC{1'b0}},   REG_MEM_SCRB_CYCLE,  {`MEMSCRCYC{1'b0}}} |
                          {{32- 1-`COLFSRDSTPB{1'b0}}, w_col_fstk_rdstop_n, {`COLFSRDSTPB{1'b0}}} |
                          {{32- 1-`MEMSCRBEN{1'b0}},   REG_MEM_SCRB_EN,     {`MEMSCRBEN{1'b0}}} :
                          32'h0;

assign REG_COL_FSTK_RDSTOP = ~w_col_fstk_rdstop_n;

// HRMEM Interrupt Status Register
//----------------------------------------------
reg r_atrde2err_sts;
reg r_axie2err_sts;
reg r_atrde1err_sts;
reg r_axie1err_sts;
reg r_ecdisint_sts;
reg r_e2errint_sts;
reg r_e1errint_sts;
always @ (posedge SYSCLK or negedge RESETB) begin
  if (!RESETB) begin
    r_atrde2err_sts <= 0;
    r_axie2err_sts  <= 0;
    r_atrde1err_sts <= 0;
    r_axie1err_sts  <= 0;
    r_ecdisint_sts  <= 0;
    r_e2errint_sts  <= 0;
    r_e1errint_sts  <= 0;
  end else begin
    if (w_hit_hrmintstr & w_reg_write) begin
      if (REG_BYTEEN[1]) begin
        if (REG_WDATA[`ECDISINT])
          r_ecdisint_sts <= 0;
      end
      if (REG_BYTEEN[0]) begin
        if (REG_WDATA[`E2ERRINT]) begin
          r_atrde2err_sts <= 0;
          r_axie2err_sts  <= 0;
          r_e2errint_sts  <= 0;
        end
        if (REG_WDATA[`E1ERRINT]) begin
          r_atrde1err_sts <= 0;
          r_axie1err_sts  <= 0;
          r_e1errint_sts  <= 0;
        end
      end
    end
    if (REG_RAM_ECC2ERR_ATRD)
      r_atrde2err_sts <= 1'b1;
    if (REG_RAM_ECC2ERR_AXI)
      r_axie2err_sts <= 1'b1;
    if (REG_RAM_ECC1ERR_ATRD)
      r_atrde1err_sts <= 1'b1;
    if (REG_RAM_ECC1ERR_AXI)
      r_axie1err_sts <= 1'b1;
    if (REG_ECC_COL_DISC)
      r_ecdisint_sts <= 1'b1;
    if (REG_RAM_ECC2ERR)
      r_e2errint_sts <= 1'b1;
    if (REG_RAM_ECC1ERR)
      r_e1errint_sts <= 1'b1;
  end
end

wire [31:0] w_rd_hrmintstr;
assign w_rd_hrmintstr = (w_hit_hrmintstr & w_reg_read) ?
                        {{32-1-`ATRDE2ERR{1'b0}}, r_atrde2err_sts, {`ATRDE2ERR{1'b0}}} |
                        {{32-1-`AXIE2ERR{1'b0}},  r_axie2err_sts,  {`AXIE2ERR{1'b0}}} |
                        {{32-1-`ATRDE1ERR{1'b0}}, r_atrde1err_sts, {`ATRDE1ERR{1'b0}}} |
                        {{32-1-`AXIE1ERR{1'b0}},  r_axie1err_sts,  {`AXIE1ERR{1'b0}}} |
                        {{32-1-`ECDISINT{1'b0}},  r_ecdisint_sts,  {`ECDISINT{1'b0}}} |
                        {{32-1-`E2ERRINT{1'b0}},  r_e2errint_sts,  {`E2ERRINT{1'b0}}} |
                        {{32-1-`E1ERRINT{1'b0}},  r_e1errint_sts,  {`E1ERRINT{1'b0}}} :
                        32'h0;

// HRMEM Interrupt Enable Register
//----------------------------------------------
reg r_ecdisint_enb;
reg r_e2errint_enb;
reg r_e1errint_enb;
always @ (posedge SYSCLK or negedge RESETB) begin
  if (!RESETB) begin
    r_ecdisint_enb <= 0;
    r_e2errint_enb <= 0;
    r_e1errint_enb <= 0;
  end else if (w_hit_hrmintenr & w_reg_write) begin
    if (REG_BYTEEN[1])
      r_ecdisint_enb <= REG_WDATA[`ECDISINTENB];
    if (REG_BYTEEN[0]) begin
      r_e2errint_enb <= REG_WDATA[`E2ERRINTENB];
      r_e1errint_enb <= REG_WDATA[`E1ERRINTENB];
    end
  end
end

wire [31:0] w_rd_hrmintenr;
assign w_rd_hrmintenr = (w_hit_hrmintenr & w_reg_read) ?
                        {{32-1-`ECDISINTENB{1'b0}}, r_ecdisint_enb, {`ECDISINTENB{1'b0}}} |
                        {{32-1-`E2ERRINTENB{1'b0}}, r_e2errint_enb, {`E2ERRINTENB{1'b0}}} |
                        {{32-1-`E1ERRINTENB{1'b0}}, r_e1errint_enb, {`E1ERRINTENB{1'b0}}} :
                        32'h0;

// 1Bit ECC Error Count Register
//----------------------------------------------
wire [31:0] w_rd_ecc1errcntr;
assign w_rd_ecc1errcntr = (w_hit_ecc1errcntr & w_reg_read) ?
                          {{32-16-`ATRDE1ERRCNT{1'b0}}, REG_RAM_ECC1ERR_ATRD_CNT, {`ATRDE1ERRCNT{1'b0}}} |
                          {{32-16-`AXIE1ERRCNT{1'b0}},  REG_RAM_ECC1ERR_AXI_CNT,  {`AXIE1ERRCNT{1'b0}}} :
                          32'h0;

// 2Bit ECC Error Count Register
//----------------------------------------------
wire [31:0] w_rd_ecc2errcntr;
assign w_rd_ecc2errcntr = (w_hit_ecc2errcntr & w_reg_read) ?
                          {{32-16-`ATRDE2ERRCNT{1'b0}}, REG_RAM_ECC2ERR_ATRD_CNT, {`ATRDE2ERRCNT{1'b0}}} |
                          {{32-16-`AXIE2ERRCNT{1'b0}},  REG_RAM_ECC2ERR_AXI_CNT,  {`AXIE2ERRCNT{1'b0}}} :
                          32'h0;

// ECC Correct Data Discard Count Register
//----------------------------------------------
wire [31:0] w_rd_ecdiscntr;
assign w_rd_ecdiscntr = (w_hit_ecdiscntr & w_reg_read) ?
                        {{32-16-`ECDISCNT{1'b0}}, REG_ECC_COL_DISC_CNT, {`ECDISCNT{1'b0}}} :
                        32'h0;

// Error Count Clear Register
//----------------------------------------------
always @ (posedge SYSCLK or negedge RESETB) begin
  if (!RESETB) begin
    REG_ECCERRCNT_CLR <= 0;
  end else begin
    REG_ECCERRCNT_CLR <= 0;
    if (w_hit_errcntclrr & w_reg_write) begin
      if (REG_BYTEEN[0])
        REG_ECCERRCNT_CLR <= REG_WDATA[`ECNTCLR];
    end
  end
end

// ECC Error Occurrence factor Insert Register
//----------------------------------------------
always @ (posedge SYSCLK or negedge RESETB) begin
  if (!RESETB) begin
    REG_INJ_ECC2ERR <= 0;
    REG_INJ_ECC1ERR <= 0;
  end else if (w_hit_eccerrinsr & w_reg_write) begin
    if (REG_BYTEEN[0]) begin
      REG_INJ_ECC2ERR <= REG_WDATA[`E2ERRINS];
      REG_INJ_ECC1ERR <= REG_WDATA[`E1ERRINS];
    end
  end
end

wire [31:0] w_rd_eccerrinsr;
assign w_rd_eccerrinsr = (w_hit_eccerrinsr & w_reg_read) ?
                         {{32-1-`E2ERRINS{1'b0}}, REG_INJ_ECC2ERR, {`E2ERRINS{1'b0}}} |
                         {{32-1-`E1ERRINS{1'b0}}, REG_INJ_ECC1ERR, {`E1ERRINS{1'b0}}} :
                         32'h0;

// Prefetch Mode Control Register
//----------------------------------------------
always @ (posedge SYSCLK or negedge RESETB) begin
  if (!RESETB) begin
    REG_PF_MODE_SEL <= 2'b01;
  end else if (w_hit_pfemdctlr & w_reg_write & REG_BYTEEN[0]) begin
    REG_PF_MODE_SEL <= REG_WDATA[`PFMDCTL +: 2];
  end
end

wire [31:0] w_rd_pfemdctlr;
assign w_rd_pfemdctlr = (w_hit_pfemdctlr & w_reg_read) ?
                        {{32-2-`PFMDCTL{1'b0}}, REG_PF_MODE_SEL, {`PFMDCTL{1'b0}}} :
                        32'h0;

// Special Prefetch Enable Register
//----------------------------------------------
generate
  for(gn=0; gn<P_SP_PFB_LINE_NUM; gn=gn+1) begin : sp_pf_en_gen
    always @ (posedge SYSCLK or negedge RESETB) begin
      if (!RESETB) begin
        REG_SP_PF_EN[gn] <= 0;
      end else if (w_hit_spepfenr & w_reg_write) begin
        if ((gn >= 24 & gn <= 31 & REG_BYTEEN[3]) |
            (gn >= 16 & gn <= 23 & REG_BYTEEN[2]) |
            (gn >=  8 & gn <= 15 & REG_BYTEEN[1]) |
            (gn >=  0 & gn <=  7 & REG_BYTEEN[0]) )
          REG_SP_PF_EN[gn] <= REG_WDATA[`SPPFENB+gn];
      end
    end
  end
endgenerate

wire [31:0] w_rd_spepfenr;
assign w_rd_spepfenr = (w_hit_spepfenr & w_reg_read) ?
                        {{32-P_SP_PFB_LINE_NUM-`SPPFENB{1'b0}}, REG_SP_PF_EN, {`SPPFENB{1'b0}}} :
                        32'h0;

// Prefetch Buffer Flush Register
//----------------------------------------------
always @ (posedge SYSCLK or negedge RESETB) begin
  if (!RESETB) begin
    REG_PF_FLUSH <= 0;
  end else begin
    REG_PF_FLUSH <= 0;
    if (w_hit_pfbufflushr & w_reg_write & REG_BYTEEN[0])
      REG_PF_FLUSH <= REG_WDATA[`PFBFLUSH];
  end
end

// Special Prefetch Address Setting Register
//----------------------------------------------
wire [31:0] w_rd_spepfadrsetr [0:P_SP_PFB_LINE_NUM-1];
wire [32*P_SP_PFB_LINE_NUM-1:0] w_rd_spepfadrsetr_cnv1;
wire [P_SP_PFB_LINE_NUM-1:0] w_rd_spepfadrsetr_cnv2 [0:31];
wire [31:0] w_rd_spepfadrsetr_merge;

generate
  for(gn=0; gn<P_SP_PFB_LINE_NUM; gn=gn+1) begin : spepfadrsetr_gen
    always @ (posedge SYSCLK or negedge RESETB) begin
      if (!RESETB) begin
        REG_SP_PF_ADR[P_AD_W*gn +: P_AD_W] <= 0;
      end else if (w_hit_spepfadrsetr[gn] & w_reg_write) begin
        for(i=0; i<P_AD_W; i=i+1) begin
          if ((i >= 24 & i <= 31 & REG_BYTEEN[3]) |
              (i >= 16 & i <= 23 & REG_BYTEEN[2]) |
              (i >=  8 & i <= 15 & REG_BYTEEN[1]) |
              (i >=  0 & i <=  7 & REG_BYTEEN[0]) ) begin
            if (i >= p_pfb_stg_w+P_BANK_W)
              REG_SP_PF_ADR[P_AD_W*gn+i] <= REG_WDATA[`SPPFADR+i];
          end
        end
      end
    end

    assign w_rd_spepfadrsetr[gn] = (w_hit_spepfadrsetr[gn] & w_reg_read) ?
                                   {{32-P_AD_W-`SPPFADR{1'b0}}, REG_SP_PF_ADR[P_AD_W*gn +: P_AD_W], {`SPPFADR{1'b0}}} :
                                   32'h0;

    assign w_rd_spepfadrsetr_cnv1[32*gn +: 32] = w_rd_spepfadrsetr[gn];

    for(gnb=0; gnb<32; gnb=gnb+1) begin : spepfadrsetr_cnv2_gen
      assign w_rd_spepfadrsetr_cnv2[gnb][gn] = w_rd_spepfadrsetr_cnv1[32*gn+gnb];
    end
  end
  for(gnb=0; gnb<32; gnb=gnb+1) begin : spepfadrsetr_marge_gen
    assign w_rd_spepfadrsetr_merge[gnb] = |w_rd_spepfadrsetr_cnv2[gnb];
  end
endgenerate

// IP Version Register
//----------------------------------------------
wire [31:0] w_rd_hrmemver;
assign w_rd_hrmemver = (w_hit_hrmemver & w_reg_read) ?
                       {{32- 8-`HRMEMMAJVER{1'b0}},  `HRMEM_MAJVERVAL,  {`HRMEMMAJVER{1'b0}}} |
                       {{32- 8-`HRMEMMINVER{1'b0}},  `HRMEM_MINVERVAL,  {`HRMEMMINVER{1'b0}}} |
                       {{32-16-`HRMEMPATVER{1'b0}},  `HRMEM_PATVERVAL,  {`HRMEMPATVER{1'b0}}} :
                       32'h0;

// Interrupt
//----------------------------------------------
assign HRMEM_INT = (r_ecdisint_enb & r_ecdisint_sts) |
                   (r_e2errint_enb & r_e2errint_sts) |
                   (r_e1errint_enb & r_e1errint_sts) ;

// AHB Read Data
//----------------------------------------------
assign REG_RDATA = w_rd_ecccolenr |
                   w_rd_memscrctrlr |
                   w_rd_hrmintstr |
                   w_rd_hrmintenr |
                   w_rd_ecc1errcntr |
                   w_rd_ecc2errcntr |
                   w_rd_ecdiscntr |
                   w_rd_eccerrinsr |
                   w_rd_pfemdctlr |
                   w_rd_spepfenr |
                   w_rd_spepfadrsetr_merge |
                   w_rd_hrmemver ;

endmodule
