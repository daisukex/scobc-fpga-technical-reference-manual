//-----------------------------------------------
// Module: sc_hrmem_unit_sram_ctrl
//  Space Cubics Unit StaticRAM Controller
//-----------------------------------------------
// Copyright © 2022 Space Cubics, LLC.
//-----------------------------------------------
module sc_hrmem_unit_sram_ctrl # (
  parameter P_AD_W = 20,
  parameter P_DT_W = 32,
  parameter P_RD_LTCY = 3
) (
  // System Interface
  input                 RAM_CLK,
  input                 RESET_N,

  // SRAM Initialize Controller Interface
  input                 INIT_EN,
  input  [P_AD_W-1:0]   INIT_ADR,

  // AXI SRAM Controller Interface
  input                 AXI_RAM_WEN,
  input  [P_AD_W-1:0]   AXI_RAM_WADR,
  input  [P_DT_W-1:0]   AXI_RAM_WDATA,
  input  [P_DT_W/8-1:0] AXI_RAM_WBTEN,

  input                 AXI_RAM_REN,
  input  [P_AD_W-1:0]   AXI_RAM_RADR,
  output [P_DT_W-1:0]   AXI_RAM_RDATA,
  input  [P_DT_W/8-1:0] AXI_RAM_RBTEN,

  // RAM Scrub Sequencer Interface
  input                 MEM_SCRB_ACT,

  // SRAM Interface
  output [19:0]         SR_A,

  output                SR1_CEB,
  output                SR1_OEB,
  output                SR1_WEB,
  output                SR1_BHEB,
  output                SR1_BLEB,
  inout  [15:0]         SR1_IO,
  input                 SR1_ERR,

  output                SR2_CEB,
  output                SR2_OEB,
  output                SR2_WEB,
  output                SR2_BHEB,
  output                SR2_BLEB,
  inout  [15:0]         SR2_IO,
  input                 SR2_ERR,

  // Register Interface
  input                 ECC_COL_EN,
  input                 COL_FSTK_RDSTOP,
  output                RAM_ECC1ERR,
  output                RAM_ECC2ERR,
  output                RAM_ECC1ERR_AXI,
  output                RAM_ECC2ERR_AXI,
  output                RAM_ECC1ERR_ATRD,
  output                RAM_ECC2ERR_ATRD,
  output [P_AD_W-1:0]   RAM_ECCERR_ADR,
  output                ECC_COL_DISC
);

wire                w_mem_atrd_val;
wire [P_AD_W-1:0]   w_mem_atrd_adr;
wire                w_mem_cor_val;
wire [P_AD_W-1:0]   w_mem_cor_adr;
wire [P_DT_W/8-1:0] w_mem_cor_bten;
wire [P_DT_W-1:0]   w_mem_cor_data;
wire                w_mem_cor_val_bef;
wire                w_mem_cor_val_cxl;
wire [P_AD_W-1:0]   w_mem_cor_adr_cxl;
wire [P_DT_W/8-1:0] w_mem_cor_bten_cxl;
wire [P_DT_W-1:0]   w_mem_cor_data_cxl;

wire                w_ram_rd_axi;
wire                w_ram_rd_atrd;
wire                w_ram_rd_atrd_cxl;

wire                w_ram_wen;
wire [P_AD_W-1:0]   w_ram_wadr;
wire [P_DT_W/8-1:0] w_ram_wbten;
wire [P_DT_W-1:0]   w_ram_wdata;
wire                w_ram_ren;
wire [P_AD_W-1:0]   w_ram_radr;
wire [P_DT_W/8-1:0] w_ram_rbten;
wire [P_DT_W-1:0]   w_ram_rdata;
wire                w_int_ecc1err;
wire [P_AD_W-1:0]   w_eccerr_adr;
wire [P_DT_W/8-1:0] w_eccerr_bten;

sc_hrmem_sram_ecc_ctrl # (
  .P_AD_W(P_AD_W),
  .P_DT_W(P_DT_W),
  .P_RD_LTCY(P_RD_LTCY)
) ram_ecc_ctrl (
  // System Interface
  .CLK(RAM_CLK),                           //  input
  .RESET_N(RESET_N),                       //  input
  // AXI SRAM Controller Interface
  .AXI_WEN(AXI_RAM_WEN),                   //  input
  .AXI_WADR(AXI_RAM_WADR),                 //  input [P_AD_W-1:0]
  .AXI_REN(AXI_RAM_REN),                   //  input
  // RAM Access Selector Interface
  .RAM_REN(w_ram_ren),                     //  input
  // RAM Interface
  .MEM_ATRD_VAL(w_mem_atrd_val),           // output
  .MEM_ATRD_ADR(w_mem_atrd_adr),           // output [P_AD_W-1:0]
  .INT_ECC1ERR(w_int_ecc1err),             //  input
  .INT_ECC2ERR(1'b0),                      //  input
  .ECCERR_ADR(w_eccerr_adr),               //  input [P_AD_W-1:0]
  .ECCERR_BTEN(w_eccerr_bten),             //  input [P_DT_W/8-1:0]
  .ECCCOL_DAT(w_ram_rdata),                //  input [P_DT_W-1:0]
  .MEM_COR_VAL(w_mem_cor_val),             // output
  .MEM_COR_ADR(w_mem_cor_adr),             // output [P_AD_W-1:0]
  .MEM_COR_BTEN(w_mem_cor_bten),           // output [P_DT_W/8-1:0]
  .MEM_COR_DATA(w_mem_cor_data),           // output [P_DT_W-1:0]
  .MEM_COR_VAL_BEF(w_mem_cor_val_bef),     // output
  .MEM_COR_VAL_CXL(w_mem_cor_val_cxl),     //  input
  .MEM_COR_ADR_CXL(w_mem_cor_adr_cxl),     //  input [P_AD_W-1:0]
  .MEM_COR_BTEN_CXL(w_mem_cor_bten_cxl),   //  input [P_DT_W/8-1:0]
  .MEM_COR_DATA_CXL(w_mem_cor_data_cxl),   //  input [P_DT_W-1:0]
  // Scrub Sequencer Interface
  .MEM_SCRB_ACT(MEM_SCRB_ACT),             //  input
  // Debug Interface
  .RAM_RD_AXI(w_ram_rd_axi),               //  input
  .RAM_RD_ATRD(w_ram_rd_atrd),             //  input
  .RAM_RD_ATRD_CXL(w_ram_rd_atrd_cxl),     //  input
  // Register Interface
  .ECC_COL_EN(ECC_COL_EN),                 //  input
  .COL_FSTK_RDSTOP(COL_FSTK_RDSTOP),       //  input
  .RAM_ECC1ERR(RAM_ECC1ERR),               // output
  .RAM_ECC2ERR(RAM_ECC2ERR),               // output
  .RAM_ECC1ERR_AXI(RAM_ECC1ERR_AXI),       // output
  .RAM_ECC2ERR_AXI(RAM_ECC2ERR_AXI),       // output
  .RAM_ECC1ERR_ATRD(RAM_ECC1ERR_ATRD),     // output
  .RAM_ECC2ERR_ATRD(RAM_ECC2ERR_ATRD),     // output
  .RAM_ECCERR_ADR(RAM_ECCERR_ADR),         // output [P_AD_W-1:0]
  .ECC_COL_DISC(ECC_COL_DISC)              // output
);

sc_hrmem_sram_acc_sel # (
  .P_AD_W(P_AD_W),
  .P_DT_W(P_DT_W)
) ram_acc_sel (
  // System Interface
  .CLK(RAM_CLK),                           //  input
  .RESET_N(RESET_N),                       //  input
  // AXI SRAM Controller Interface
  .AXI_WEN(AXI_RAM_WEN),                   //  input
  .AXI_WADR(AXI_RAM_WADR),                 //  input [P_AD_W-1:0]
  .AXI_WBTEN(AXI_RAM_WBTEN),               // input [P_DT_W/8-1:0]
  .AXI_WDATA(AXI_RAM_WDATA),               //  input [P_DT_W-1:0]
  .AXI_REN(AXI_RAM_REN),                   //  input
  .AXI_RADR(AXI_RAM_RADR),                 //  input [P_AD_W-1:0]
  .AXI_RBTEN(AXI_RAM_RBTEN),               // input [P_DT_W/8-1:0]
  // MEM Scrub Controller Interface
  .MEM_COR_VAL(w_mem_cor_val),             //  input
  .MEM_COR_ADR(w_mem_cor_adr),             //  input [P_AD_W-1:0]
  .MEM_COR_BTEN(w_mem_cor_bten),           //  input [P_DT_W/8-1:0]
  .MEM_COR_DATA(w_mem_cor_data),           //  input [P_DT_W-1:0]
  .MEM_COR_VAL_BEF(w_mem_cor_val_bef),     //  input
  .MEM_COR_VAL_CXL(w_mem_cor_val_cxl),     //  output
  .MEM_COR_ADR_CXL(w_mem_cor_adr_cxl),     //  output [P_AD_W-1:0]
  .MEM_COR_BTEN_CXL(w_mem_cor_bten_cxl),   //  output [P_DT_W/8-1:0]
  .MEM_COR_DATA_CXL(w_mem_cor_data_cxl),   //  output [P_DT_W-1:0]
  .MEM_ATRD_VAL(w_mem_atrd_val),           //  input
  .MEM_ATRD_ADR(w_mem_atrd_adr),           //  input [P_AD_W-1:0]
  // Debug Interface
  .RAM_RD_AXI(w_ram_rd_axi),               // output
  .RAM_RD_ATRD(w_ram_rd_atrd),             // output
  .RAM_RD_ATRD_CXL(w_ram_rd_atrd_cxl),     // output
  // SRAM Control Interface
  .RAM_WEN(w_ram_wen),                     // output
  .RAM_WADR(w_ram_wadr),                   // output [P_AD_W-1:0]
  .RAM_WBTEN(w_ram_wbten),                 // output [P_DT_W/8-1:0]
  .RAM_WDATA(w_ram_wdata),                 // output [P_DT_W-1:0]
  .RAM_REN(w_ram_ren),                     // output
  .RAM_RBTEN(w_ram_rbten),                 // output [P_DT_W/8-1:0]
  .RAM_RADR(w_ram_radr)                    // output [P_AD_W-1:0]
);

sc_hrmem_sram_acc_ctrl_w32 # (
  .P_RD_LTCY(P_RD_LTCY-1)
) sram_acc_ctrl (
  // System Interface
  .CLK(RAM_CLK),                           //  input
  .RESET_N(RESET_N),                       //  input

  // RAM Access Control Interface
  .INIT_EN(INIT_EN),                       //  input
  .INIT_ADR(INIT_ADR),                     //  input [19:0]

  .WEN(w_ram_wen),                         //  input
  .WADR(w_ram_wadr),                       //  input [19:0]
  .WBTEN(w_ram_wbten),                     //  input [3:0]
  .WDATA(w_ram_wdata),                     //  input [31:0]

  .REN(w_ram_ren),                         //  input
  .RADR(w_ram_radr),                       //  input [19:0]
  .RBTEN(w_ram_rbten),                     //  input [3:0]
  .RDATA(w_ram_rdata),                     // output [31:0]

  .ECC1ERR(w_int_ecc1err),                 // output
  .ECCERR_ADR(w_eccerr_adr),               // output [19:0]
  .ECCERR_BTEN(w_eccerr_bten),             // output [3:0]

  // SRAM Interface
  .SR_A(SR_A),                             // output [19:0]

  .SR1_CEB(SR1_CEB),                       // output
  .SR1_OEB(SR1_OEB),                       // output
  .SR1_WEB(SR1_WEB),                       // output
  .SR1_BHEB(SR1_BHEB),                     // output
  .SR1_BLEB(SR1_BLEB),                     // output
  .SR1_IO(SR1_IO),                         // inout  [15:0]
  .SR1_ERR(SR1_ERR),                       // input

  .SR2_CEB(SR2_CEB),                       // output
  .SR2_OEB(SR2_OEB),                       // output
  .SR2_WEB(SR2_WEB),                       // output
  .SR2_BHEB(SR2_BHEB),                     // output
  .SR2_BLEB(SR2_BLEB),                     // output
  .SR2_IO(SR2_IO),                         // inout  [15:0]
  .SR2_ERR(SR2_ERR)                        // input
);

assign AXI_RAM_RDATA = w_ram_rdata;

endmodule
