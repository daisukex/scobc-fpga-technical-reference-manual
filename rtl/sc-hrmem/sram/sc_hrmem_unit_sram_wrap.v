//-----------------------------------------------
// Module: sc_hrmem_unit_sram_wrap
//  Space Cubics Unit StaticRAM Wrapper
//-----------------------------------------------
// Copyright © 2022 Space Cubics, LLC.
//-----------------------------------------------
module sc_hrmem_unit_sram_wrap # (
  parameter P_AXI_AD_W = 22,
  parameter P_MEM_AD_W = 20,
  parameter P_DT_W     = 32,
  parameter P_BANK_W   = 2,
  parameter P_RD_LTCY  = 3
) (
  // System Interface
  input                       RAM_CLK,
  input                       RESET_N,

  // SRAM Initialize Controller Interface
  input                       INIT_EN,
  input      [P_MEM_AD_W-1:0] INIT_ADR,

  // AXI SRAM Controller Interface
  input                       CODE_RAM_WEN,
  input      [P_AXI_AD_W-1:0] CODE_RAM_WADR,
  input      [P_DT_W-1:0]     CODE_RAM_WDATA,
  input      [P_DT_W/8-1:0]   CODE_RAM_WBTEN,
  input                       CODE_RAM_REN,
  input      [P_AXI_AD_W-1:0] CODE_RAM_RADR,
  input      [P_DT_W/8-1:0]   CODE_RAM_RBTEN,
  output                      CODE_RAM_RDT_VAL,
  output     [P_DT_W-1:0]     CODE_RAM_RDATA,
  input                       SYS_RAM_WEN,
  input      [P_AXI_AD_W-1:0] SYS_RAM_WADR,
  input      [P_DT_W-1:0]     SYS_RAM_WDATA,
  input      [P_DT_W/8-1:0]   SYS_RAM_WBTEN,
  input                       SYS_RAM_REN,
  input      [P_AXI_AD_W-1:0] SYS_RAM_RADR,
  input      [P_DT_W/8-1:0]   SYS_RAM_RBTEN,
  output                      SYS_RAM_RDT_VAL,
  output     [P_DT_W-1:0]     SYS_RAM_RDATA,

  // RAM Scrub Sequencer Interface
  input                       MEM_SCRB_ACT,

  // SRAM Interface
  output   [19:0]             SR_A,
  output                      SR1_CEB,
  output                      SR1_OEB,
  output                      SR1_WEB,
  output                      SR1_BHEB,
  output                      SR1_BLEB,
  inout    [15:0]             SR1_IO,
  input                       SR1_ERR,
  output                      SR2_CEB,
  output                      SR2_OEB,
  output                      SR2_WEB,
  output                      SR2_BHEB,
  output                      SR2_BLEB,
  inout    [15:0]             SR2_IO,
  input                       SR2_ERR,

  // Register Interface
  input                       ECC_COL_EN,
  input                       COL_FSTK_RDSTOP,
  input                       ECCERRCNT_CLR,
  output                      RAM_ECC1ERR,
  output                      RAM_ECC2ERR,
  output                      RAM_ECC1ERR_AXI,
  output                      RAM_ECC2ERR_AXI,
  output                      RAM_ECC1ERR_ATRD,
  output                      RAM_ECC2ERR_ATRD,
  output     [P_AXI_AD_W-1:0] RAM_ECCERR_ADR,
  output                      ECC_COL_DISC,
  output reg [15:0]           RAM_ECC1ERR_AXI_CNT,
  output reg [15:0]           RAM_ECC2ERR_AXI_CNT,
  output reg [15:0]           RAM_ECC1ERR_ATRD_CNT,
  output reg [15:0]           RAM_ECC2ERR_ATRD_CNT,
  output reg [15:0]           ECC_COL_DISC_CNT
);

reg                   r_ram_wen;
reg  [P_AXI_AD_W-1:0] r_ram_wadr;
reg  [P_DT_W-1:0]     r_ram_wdata;
reg  [P_DT_W/8-1:0]   r_ram_wbten;

reg                   r_ram_ren;
reg  [P_AXI_AD_W-1:0] r_ram_radr;
reg  [P_DT_W/8-1:0]   r_ram_rbten;

reg  [P_RD_LTCY-1:0]  r_code_ram_ren_dttim;
reg  [P_RD_LTCY-1:0]  r_sys_ram_ren_dttim;

wire [P_DT_W-1:0]     w_ram_rdata;

reg r_eccerrcnt_clr_1p;

// SRAM Write Signal Select
always @ (*) begin
  if (SYS_RAM_WEN) begin
    r_ram_wen   = 1'b1;
    r_ram_wadr  = SYS_RAM_WADR;
    r_ram_wdata = SYS_RAM_WDATA;
    r_ram_wbten = SYS_RAM_WBTEN;
  end else if (CODE_RAM_WEN) begin
    r_ram_wen   = 1'b1;
    r_ram_wadr  = CODE_RAM_WADR;
    r_ram_wdata = CODE_RAM_WDATA;
    r_ram_wbten = CODE_RAM_WBTEN;
  end else begin
    r_ram_wen   = 0;
    r_ram_wadr  = 0;
    r_ram_wdata = 0;
    r_ram_wbten = 0;
  end
end

// SRAM Read Signal Select
always @ (*) begin
  if (SYS_RAM_REN) begin
    r_ram_ren   = 1'b1;
    r_ram_radr  = SYS_RAM_RADR;
    r_ram_rbten = SYS_RAM_RBTEN;
  end else if (CODE_RAM_REN) begin
    r_ram_ren   = 1'b1;
    r_ram_radr  = CODE_RAM_RADR;
    r_ram_rbten = CODE_RAM_RBTEN;
  end else begin
    r_ram_ren   = 0;
    r_ram_radr  = 0;
    r_ram_rbten = 0;
  end
end

// SRAM Controller
sc_hrmem_unit_sram_ctrl # (
  .P_AD_W(P_MEM_AD_W),
  .P_DT_W(P_DT_W)
) unit_ram_ctrl (
  // System Interface
  .RAM_CLK(RAM_CLK),                                //  input
  .RESET_N(RESET_N),                                //  input
  // SRAM Initialize Controller Interface
  .INIT_EN(INIT_EN),                                //  input
  .INIT_ADR(INIT_ADR),                              //  input [P_AD_W-1:0]
  // AXI SRAM Controller Interface
  .AXI_RAM_WEN(r_ram_wen),                          //  input
  .AXI_RAM_WADR(r_ram_wadr[P_MEM_AD_W+1:P_BANK_W]), //  input [P_AD_W-1:0]
  .AXI_RAM_WDATA(r_ram_wdata),                      //  input [P_DT_W-1:0]
  .AXI_RAM_WBTEN(r_ram_wbten),                      //  input [P_DT_W/8-1:0]
  .AXI_RAM_REN(r_ram_ren),                          //  input
  .AXI_RAM_RADR(r_ram_radr[P_MEM_AD_W+1:P_BANK_W]), //  input [P_AD_W-1:0]
  .AXI_RAM_RDATA(w_ram_rdata),                      // output [P_DT_W-1:0]
  .AXI_RAM_RBTEN(r_ram_rbten),                      //  input [P_DT_W/8-1:0]
  // RAM Scrub Sequencer Interface
  .MEM_SCRB_ACT(MEM_SCRB_ACT),                      //  input
  // SRAM Interface
  .SR_A(SR_A),                                      // output [19:0]
  .SR1_CEB(SR1_CEB),                                // output
  .SR1_OEB(SR1_OEB),                                // output
  .SR1_WEB(SR1_WEB),                                // output
  .SR1_BHEB(SR1_BHEB),                              // output
  .SR1_BLEB(SR1_BLEB),                              // output
  .SR1_IO(SR1_IO),                                  // inout  [15:0]
  .SR1_ERR(SR1_ERR),                                // input
  .SR2_CEB(SR2_CEB),                                // output
  .SR2_OEB(SR2_OEB),                                // output
  .SR2_WEB(SR2_WEB),                                // output
  .SR2_BHEB(SR2_BHEB),                              // output
  .SR2_BLEB(SR2_BLEB),                              // output
  .SR2_IO(SR2_IO),                                  // inout  [15:0]
  .SR2_ERR(SR2_ERR),                                // input
  // Register Interface
  .ECC_COL_EN(ECC_COL_EN),                          //  input
  .COL_FSTK_RDSTOP(COL_FSTK_RDSTOP),                //  input
  .RAM_ECC1ERR(RAM_ECC1ERR),                        // output
  .RAM_ECC2ERR(RAM_ECC2ERR),                        // output
  .RAM_ECC1ERR_AXI(RAM_ECC1ERR_AXI),                // output
  .RAM_ECC2ERR_AXI(RAM_ECC2ERR_AXI),                // output
  .RAM_ECC1ERR_ATRD(RAM_ECC1ERR_ATRD),              // output
  .RAM_ECC2ERR_ATRD(RAM_ECC2ERR_ATRD),              // output
  .RAM_ECCERR_ADR(RAM_ECCERR_ADR[P_AXI_AD_W-1:2]),  // output [P_AD_W-1:0]
  .ECC_COL_DISC(ECC_COL_DISC)                       // output
);

assign RAM_ECCERR_ADR[1:0] = 2'b00;

// Unit RAM Read Enable Retiming
always @ (posedge RAM_CLK or negedge RESET_N) begin
  if (!RESET_N) begin
    r_code_ram_ren_dttim <= 0;
    r_sys_ram_ren_dttim  <= 0;
  end else begin
    r_code_ram_ren_dttim <= {r_code_ram_ren_dttim[P_RD_LTCY-2:0], CODE_RAM_REN};
    r_sys_ram_ren_dttim  <= {r_sys_ram_ren_dttim[P_RD_LTCY-2:0], SYS_RAM_REN};
  end
end

// Unit RAM Read Data Valid
assign CODE_RAM_RDT_VAL = r_code_ram_ren_dttim[P_RD_LTCY-1];
assign SYS_RAM_RDT_VAL  = r_sys_ram_ren_dttim[P_RD_LTCY-1];

// Unit RAM Read Data Select
assign CODE_RAM_RDATA = w_ram_rdata;
assign SYS_RAM_RDATA  = w_ram_rdata;

// ECC Error Counter
always @ (posedge RAM_CLK or negedge RESET_N) begin
  if (!RESET_N) begin
    r_eccerrcnt_clr_1p   <= 0;
    RAM_ECC1ERR_AXI_CNT  <= 0;
    RAM_ECC2ERR_AXI_CNT  <= 0;
    RAM_ECC1ERR_ATRD_CNT <= 0;
    RAM_ECC2ERR_ATRD_CNT <= 0;
    ECC_COL_DISC_CNT     <= 0;
  end else begin
    r_eccerrcnt_clr_1p <= ECCERRCNT_CLR;
    if (ECCERRCNT_CLR & ~r_eccerrcnt_clr_1p) begin
      RAM_ECC1ERR_AXI_CNT  <= 0;
      RAM_ECC2ERR_AXI_CNT  <= 0;
      RAM_ECC1ERR_ATRD_CNT <= 0;
      RAM_ECC2ERR_ATRD_CNT <= 0;
      ECC_COL_DISC_CNT     <= 0;
    end else begin
      if ((~&RAM_ECC1ERR_AXI_CNT) & RAM_ECC1ERR_AXI)
        RAM_ECC1ERR_AXI_CNT  <= RAM_ECC1ERR_AXI_CNT + 1;
      if ((~&RAM_ECC2ERR_AXI_CNT) & RAM_ECC2ERR_AXI)
        RAM_ECC2ERR_AXI_CNT  <= RAM_ECC2ERR_AXI_CNT + 1;
      if ((~&RAM_ECC1ERR_ATRD_CNT) & RAM_ECC1ERR_ATRD)
        RAM_ECC1ERR_ATRD_CNT <= RAM_ECC1ERR_ATRD_CNT + 1;
      if ((~&RAM_ECC2ERR_ATRD_CNT) & RAM_ECC2ERR_ATRD)
        RAM_ECC2ERR_ATRD_CNT <= RAM_ECC2ERR_ATRD_CNT + 1;
      if ((~&ECC_COL_DISC_CNT) & ECC_COL_DISC)
        ECC_COL_DISC_CNT     <= ECC_COL_DISC_CNT + 1;
    end
  end
end

endmodule
