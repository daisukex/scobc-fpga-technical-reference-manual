//-----------------------------------------------
// Module: sc_hrmem_sram
//  Space Cubics High Reliability Memory for StaticRAM (AHB/AXI)
//-----------------------------------------------
// Copyright © 2022 Space Cubics, LLC.
//-----------------------------------------------
module sc_hrmem_sram # (
  parameter SC_HRMEM_SRAM_SYS_AXI_ID_W    = 1,
  parameter SC_HRMEM_SRAM_PFB_STG_NUM     = 8,
  parameter SC_HRMEM_SRAM_PFB_LINE_NUM    = 8,
  parameter SC_HRMEM_SRAM_SP_PFB_LINE_NUM = 2
) (
  // System Interface
  input                                   SYSCLK,
  input                                   SYSRST_N,
  input                                   MODULE_RSTN,
  input                                   POR_RST_N,
  input                                   RAM_INIT_REQ,
  output                                  RAM_INIT_DONE,

  // CM3 CODE Bus AHB Slave Interface
  input                                   CODE_SHSEL,
  input  [21:0]                           CODE_SHADDR,
  input  [1:0]                            CODE_SHTRANS,
  input  [2:0]                            CODE_SHSIZE,
  input  [2:0]                            CODE_SHBURST,
  input                                   CODE_SHWRITE,
  input  [3:0]                            CODE_SHPROT,
  input  [31:0]                           CODE_SHWDATA,
  output [31:0]                           CODE_SHRDATA,
  output [1:0]                            CODE_SHRESP,
  input                                   CODE_SHREADYIN,
  output                                  CODE_SHREADYOUT,

  // CM3 SYS Bus AXI Slave Interface
  input  [SC_HRMEM_SRAM_SYS_AXI_ID_W-1:0] SYS_S_AXI_AWID,
  input  [21:0]                           SYS_S_AXI_AWADDR,
  input  [7:0]                            SYS_S_AXI_AWLEN,
  input  [2:0]                            SYS_S_AXI_AWSIZE,
  input  [1:0]                            SYS_S_AXI_AWBURST,
  input                                   SYS_S_AXI_AWLOCK,
  input  [3:0]                            SYS_S_AXI_AWCACHE,
  input  [2:0]                            SYS_S_AXI_AWPROT,
  input                                   SYS_S_AXI_AWVALID,
  output                                  SYS_S_AXI_AWREADY,
  input  [31:0]                           SYS_S_AXI_WDATA,
  input  [3:0]                            SYS_S_AXI_WSTRB,
  input                                   SYS_S_AXI_WLAST,
  input                                   SYS_S_AXI_WVALID,
  output                                  SYS_S_AXI_WREADY,
  output [SC_HRMEM_SRAM_SYS_AXI_ID_W-1:0] SYS_S_AXI_BID,
  output [1:0]                            SYS_S_AXI_BRESP,
  output                                  SYS_S_AXI_BVALID,
  input                                   SYS_S_AXI_BREADY,
  input  [SC_HRMEM_SRAM_SYS_AXI_ID_W-1:0] SYS_S_AXI_ARID,
  input  [21:0]                           SYS_S_AXI_ARADDR,
  input  [7:0]                            SYS_S_AXI_ARLEN,
  input  [2:0]                            SYS_S_AXI_ARSIZE,
  input  [1:0]                            SYS_S_AXI_ARBURST,
  input                                   SYS_S_AXI_ARLOCK,
  input  [3:0]                            SYS_S_AXI_ARCACHE,
  input  [2:0]                            SYS_S_AXI_ARPROT,
  input                                   SYS_S_AXI_ARVALID,
  output                                  SYS_S_AXI_ARREADY,
  output [SC_HRMEM_SRAM_SYS_AXI_ID_W-1:0] SYS_S_AXI_RID,
  output [31:0]                           SYS_S_AXI_RDATA,
  output [1:0]                            SYS_S_AXI_RRESP,
  output                                  SYS_S_AXI_RLAST,
  output                                  SYS_S_AXI_RVALID,
  input                                   SYS_S_AXI_RREADY,

  // Register AHB Interface
  input                                   SHSEL,
  input  [31:0]                           SHADDR,
  input  [1:0]                            SHTRANS,
  input  [2:0]                            SHSIZE,
  input  [2:0]                            SHBURST,
  input                                   SHWRITE,
  input                                   SHREADYIN,
  output                                  SHREADYOUT,
  input  [31:0]                           SHWDATA,
  output [31:0]                           SHRDATA,
  output [1:0]                            SHRESP,

  // SRAM Interface
  output [19:0]                           SR_A,
  output                                  SR1_CEB,
  output                                  SR1_OEB,
  output                                  SR1_WEB,
  output                                  SR1_BHEB,
  output                                  SR1_BLEB,
  inout  [15:0]                           SR1_IO,
  input                                   SR1_ERR,
  output                                  SR2_CEB,
  output                                  SR2_OEB,
  output                                  SR2_WEB,
  output                                  SR2_BHEB,
  output                                  SR2_BLEB,
  inout  [15:0]                           SR2_IO,
  input                                   SR2_ERR,

  // Interrupt Interface
  output                                  HRMEM_INT
);

parameter P_MEM_NUM = 1;
parameter P_BUS_AD_W = 22;
parameter P_MEM_AD_W = 20; // SRAM Depth(1Unit): 1M
parameter P_DT_W = 32;
parameter [15:0] P_MSC_INI = 16'h1;

parameter P_BANK_W = (P_DT_W == (2 << 4)) ? 2 :
                     (P_DT_W == (2 << 5)) ? 3 :
                     (P_DT_W == (2 << 6)) ? 4 :
                     (P_DT_W == (2 << 7)) ? 5 :
                     (P_DT_W == (2 << 8)) ? 6 :
                     (P_DT_W == (2 << 9)) ? 7 :
                                            1 ;

parameter P_RD_LTCY = 3; // AHB Read Data Letency: 4Cycle

wire hrmem_resetn;

wire w_reg_dphase;
wire w_reg_w1r0;
wire [31:0] w_reg_addr;
wire [3:0] w_reg_byteen;
wire [31:0] w_reg_wdata;
wire [31:0] w_reg_rdata;

wire w_reg_ecc_col_en;
wire w_reg_mem_scrb_en;
wire [15:0] w_reg_mem_scrb_cycle;
wire w_reg_col_fstk_rdstop;
wire w_reg_eccerrcnt_clr;
wire w_reg_ram_ecc1err;
wire w_reg_ram_ecc2err;
wire w_reg_ram_ecc1err_axi;
wire w_reg_ram_ecc2err_axi;
wire w_reg_ram_ecc1err_atrd;
wire w_reg_ram_ecc2err_atrd;
wire w_reg_ecc_col_disc;
wire [15:0] w_reg_ram_ecc1err_cnt;
wire [15:0] w_reg_ram_ecc2err_cnt;
wire [15:0] w_reg_ram_ecc1err_axi_cnt;
wire [15:0] w_reg_ram_ecc2err_axi_cnt;
wire [15:0] w_reg_ram_ecc1err_atrd_cnt;
wire [15:0] w_reg_ram_ecc2err_atrd_cnt;
wire [15:0] w_reg_ecc_col_disc_cnt;

wire [1:0] w_reg_pf_mode_sel;
wire [SC_HRMEM_SRAM_SP_PFB_LINE_NUM-1:0] w_reg_sp_pf_en;
wire [P_BUS_AD_W*SC_HRMEM_SRAM_SP_PFB_LINE_NUM-1:0] w_reg_sp_pf_adr;
wire w_reg_pf_flush;

wire w_code_wr_acc_start;
wire w_code_wr_acc_busy;
wire w_code_wr_acc_end;
wire w_code_rd_acc_start;
wire w_code_rd_acc_busy;
wire w_code_rd_acc_end;
wire [2:0] w_code_state;
wire w_code_burst_en;
wire w_code_st_burst;

wire w_code_ram_wen;
wire [P_BUS_AD_W-1:0] w_code_ram_wadr;
wire [P_DT_W-1:0] w_code_ram_wdata;
wire [P_DT_W/8-1:0] w_code_ram_wbten;
wire w_code_ram_ren;
wire [P_BUS_AD_W-1:0] w_code_ram_radr;
wire [P_DT_W/8-1:0] w_code_ram_rbten;
wire w_code_ram_rdt_val;
wire [P_DT_W-1:0] w_code_ram_rdata;

wire w_sys_wr_acc_start;
wire w_sys_wr_acc_busy;
wire w_sys_wr_acc_end;
wire [2:0] w_sys_wr_state;
wire w_sys_wr_burst_en;
wire w_sys_rd_acc_start;
wire w_sys_rd_acc_busy;
wire w_sys_rd_acc_end;
wire [1:0] w_sys_rd_state;
wire w_sys_rd_burst_en;
wire w_sys_rd_st_burst;

wire w_sys_ram_wen;
wire [P_BUS_AD_W-1:0] w_sys_ram_wadr;
wire [P_DT_W-1:0] w_sys_ram_wdata;
wire [P_DT_W/8-1:0] w_sys_ram_wbten;
wire w_sys_ram_ren;
wire [P_BUS_AD_W-1:0] w_sys_ram_radr;
wire [P_DT_W/8-1:0] w_sys_ram_rbten;
wire w_sys_ram_rdt_val;
wire [P_DT_W-1:0] w_sys_ram_rdata;

wire w_pf_srch_val;
wire w_pf_rd_val;
wire w_pf_rwait;
wire w_pf_rd_dt_msk;
wire w_pf_acc_val;
wire [P_BUS_AD_W-1:0] w_pf_acc_adr;

wire w_code_pf_ren;
wire [P_BUS_AD_W-1:0] w_code_pf_radr;
wire [P_DT_W/8-1:0] w_code_pf_rbten;
wire w_code_pf_rdt_val;
wire [P_DT_W-1:0] w_code_pf_rdata;

wire w_mem_scrb_act;

wire w_sync_por_rstb;

reg r_ram_init_req_p1;
reg r_ram_init_req_sync;

reg r_ram_init_done_p1;
reg r_ram_init_done_sync;

wire [P_MEM_AD_W-1:0] w_ram_init_addr;
wire w_ram_init_en;

assign hrmem_resetn = SYSRST_N & MODULE_RSTN;

// AHB Slave
sc_ahb_slave ahb_slave (
  // AHB Interface
  .HCLK(SYSCLK),             // input
  .HRESETN(hrmem_resetn),    // input
  .HSEL(SHSEL),              // input
  .HADDR(SHADDR),            // input  [31:0]
  .HTRANS(SHTRANS),          // input  [1:0]
  .HSIZE(SHSIZE),            // input  [2:0]
  .HBURST(SHBURST),          // input  [2:0]
  .HWRITE(SHWRITE),          // input
  .HREADYIN(SHREADYIN),      // input
  .HREADYOUT(SHREADYOUT),    // output
  .HWDATA(SHWDATA),          // input  [31:0]
  .HRDATA(SHRDATA),          // output [31:0]
  .HRESP(SHRESP),            // output [1:0]

  // Register Interface
  .AHB_WR(/*open*/),         // output
  .AHB_RD(/*open*/),         // output
  .AHB_ADDR(/*open*/),       // output [31:0]
  .AHB_WAIT(1'b0),           // input
  .REG_DPHASE(w_reg_dphase), // output
  .REG_W1R0(w_reg_w1r0),     // output
  .REG_ADDR(w_reg_addr),     // output [31:0]
  .REG_BYTEEN(w_reg_byteen), // output [3:0]
  .REG_WDATA(w_reg_wdata),   // output [31:0]
  .REG_RDATA(w_reg_rdata),   // input  [31:0]
  .REG_ACCERR(1'b0)          // input
);

// HRMEM Register
sc_hrmem_reg # (
  .P_MEM_NUM(P_MEM_NUM),
  .P_AD_W(P_BUS_AD_W),
  .P_BANK_W(P_BANK_W),
  .P_MSC_INI(P_MSC_INI),
  .P_PFB_STG_NUM(SC_HRMEM_SRAM_PFB_STG_NUM),
  .P_SP_PFB_LINE_NUM(SC_HRMEM_SRAM_SP_PFB_LINE_NUM)
) hrmem_reg (
  // System Interface
  .SYSCLK(SYSCLK),                                       // input
  .RESETB(hrmem_resetn),                                 // input

  // AHB Interface
  .REG_ACC(w_reg_dphase),                                // input
  .REG_W1R0(w_reg_w1r0),                                 // input
  .REG_ADDR(w_reg_addr),                                 // input [31:0]
  .REG_BYTEEN(w_reg_byteen),                             // input [3:0]
  .REG_WDATA(w_reg_wdata),                               // input [31:0]
  .REG_RDATA(w_reg_rdata),                               // output [31:0]

  // Memory Controller Interface
  .REG_INJ_ECC1ERR(/*open*/),                            // output
  .REG_INJ_ECC2ERR(/*open*/),                            // output
  .REG_ECC_COL_EN(w_reg_ecc_col_en),                     // output
  .REG_MEM_SCRB_EN(w_reg_mem_scrb_en),                   // output
  .REG_MEM_SCRB_CYCLE(w_reg_mem_scrb_cycle),             // output [15:0]
  .REG_COL_FSTK_RDSTOP(w_reg_col_fstk_rdstop),           // output
  .REG_ECCERRCNT_CLR(w_reg_eccerrcnt_clr),               // output
  .REG_RAM_ECC1ERR(w_reg_ram_ecc1err),                   // input
  .REG_RAM_ECC2ERR(w_reg_ram_ecc2err),                   // input
  .REG_RAM_ECC1ERR_AXI(w_reg_ram_ecc1err_axi),           // input [P_MEM_NUM-1:0]
  .REG_RAM_ECC2ERR_AXI(w_reg_ram_ecc2err_axi),           // input [P_MEM_NUM-1:0]
  .REG_RAM_ECC1ERR_ATRD(w_reg_ram_ecc1err_atrd),         // input [P_MEM_NUM-1:0]
  .REG_RAM_ECC2ERR_ATRD(w_reg_ram_ecc2err_atrd),         // input [P_MEM_NUM-1:0]
  .REG_ECC_COL_DISC(w_reg_ecc_col_disc),                 // input
  .REG_RAM_ECC1ERR_CNT(w_reg_ram_ecc1err_cnt),           // input [15:0]
  .REG_RAM_ECC2ERR_CNT(w_reg_ram_ecc2err_cnt),           // input [15:0]
  .REG_RAM_ECC1ERR_AXI_CNT(w_reg_ram_ecc1err_axi_cnt),   // input [15:0]
  .REG_RAM_ECC2ERR_AXI_CNT(w_reg_ram_ecc2err_axi_cnt),   // input [15:0]
  .REG_RAM_ECC1ERR_ATRD_CNT(w_reg_ram_ecc1err_atrd_cnt), // input [15:0]
  .REG_RAM_ECC2ERR_ATRD_CNT(w_reg_ram_ecc2err_atrd_cnt), // input [15:0]
  .REG_ECC_COL_DISC_CNT(w_reg_ecc_col_disc_cnt),         // input [15:0]

  // Prefetch Controller Interface
  .REG_PF_MODE_SEL(w_reg_pf_mode_sel),                   // output [1:0]
  .REG_SP_PF_EN(w_reg_sp_pf_en),                         // output [P_SP_PFB_LINE_NUM-1:0]
  .REG_SP_PF_ADR(w_reg_sp_pf_adr),                       // output [P_AD_W*P_SP_PFB_LINE_NUM-1:0]
  .REG_PF_FLUSH(w_reg_pf_flush),                         // output

  // Interrupt Interface
  .HRMEM_INT(HRMEM_INT)                                  // output
);

// CM3 CODE Bus AHB SRAM Controller
sc_hrmem_ahb_sram_ctrl_vsaxi # (
  .P_AHB_AD_W(P_BUS_AD_W),
  .P_DT_W(P_DT_W),
  .P_BANK_W(P_BANK_W),
  .P_RD_LTCY(P_RD_LTCY),
  .P_H_PRIO(1)
) ahb_ram_ctrl_code (
  // System Interface
  .HCLK(SYSCLK),                            //  input
  .HRESETN(hrmem_resetn),                   //  input
  .RAM_INIT_DONE(r_ram_init_done_sync),     //  input
  // AHB Slave Interface
  .HSEL(CODE_SHSEL),                        //  input
  .HADDR(CODE_SHADDR),                      //  input [P_AHB_AD_W-1:0]
  .HTRANS(CODE_SHTRANS),                    //  input [1:0]
  .HSIZE(CODE_SHSIZE),                      //  input [2:0]
  .HBURST(CODE_SHBURST),                    //  input [2:0]
  .HWRITE(CODE_SHWRITE),                    //  input
  .HPROT(CODE_SHPROT),                      //  input [3:0]
  .HWDATA(CODE_SHWDATA),                    //  input [P_DT_W-1:0]
  .HRDATA(CODE_SHRDATA),                    // output [P_DT_W-1:0]
  .HRESP(CODE_SHRESP),                      // output [1:0]
  .HREADYIN(CODE_SHREADYIN),                //  input
  .HREADYOUT(CODE_SHREADYOUT),              // output
  // Other AHB SRAM Controller Interface
  .SELF_WR_ACC_START(w_code_wr_acc_start),  // output
  .SELF_WR_ACC_BUSY(w_code_wr_acc_busy),    // output
  .SELF_WR_ACC_END(w_code_wr_acc_end),      // output
  .SELF_RD_ACC_START(w_code_rd_acc_start),  // output
  .SELF_RD_ACC_BUSY(w_code_rd_acc_busy),    // output
  .SELF_RD_ACC_END(w_code_rd_acc_end),      // output
  .SELF_STATE(w_code_state),                // output [2:0]
  .SELF_BURST_EN(w_code_burst_en),          // output
  .SELF_ST_BURST(w_code_st_burst),          // output
  .OTHER_WR_ACC_START(w_sys_wr_acc_start),  //  input
  .OTHER_WR_ACC_BUSY(w_sys_wr_acc_busy),    //  input
  .OTHER_WR_ACC_END(w_sys_wr_acc_end),      //  input
  .OTHER_WR_STATE(w_sys_wr_state),          //  input [2:0]
  .OTHER_WR_BURST_EN(w_sys_wr_burst_en),    //  input
  .OTHER_RD_ACC_START(w_sys_rd_acc_start),  //  input
  .OTHER_RD_ACC_BUSY(w_sys_rd_acc_busy),    //  input
  .OTHER_RD_ACC_END(w_sys_rd_acc_end),      //  input
  .OTHER_RD_STATE(w_sys_rd_state),          //  input [1:0]
  .OTHER_RD_BURST_EN(w_sys_rd_burst_en),    //  input
  .OTHER_RD_ST_BURST(w_sys_rd_st_burst),    //  input
  // Prefetch Controller Interface
  .PF_MODE_SEL(w_reg_pf_mode_sel),          //  input [1:0]
  .PF_SRCH_VAL(w_pf_srch_val),              // output
  .PF_RD_VAL(w_pf_rd_val),                  //  input
  .PF_RWAIT(w_pf_rwait),                    //  input
  .PF_RD_DT_MSK(w_pf_rd_dt_msk),            // output
  .PF_ACC_VAL(1'b0),                        //  input
  .PF_ACC_ADR({P_BUS_AD_W{1'b0}}),          //  input [P_AHB_AD_W-1:0]
  // RAM Interface
  .RAM_WEN(w_code_ram_wen),                 // output
  .RAM_WADR(w_code_ram_wadr),               // output [P_AHB_AD_W-1:0]
  .RAM_WDATA(w_code_ram_wdata),             // output [P_DT_W-1:0]
  .RAM_WBTEN(w_code_ram_wbten),             // output [P_DT_W/8-1:0]
  .RAM_REN(w_code_ram_ren),                 // output
  .RAM_RADR(w_code_ram_radr),               // output [P_AHB_AD_W-1:0]
  .RAM_RBTEN(w_code_ram_rbten),             // output [P_DT_W/8-1:0]
  .RAM_RDT_VAL(w_code_ram_rdt_val),         //  input
  .RAM_RDATA(w_code_ram_rdata)              //  input [P_DT_W-1:0]
);

// SYS Bus AXI SRAM Controller
sc_hrmem_axi_sram_ctrl_vsahb # (
  .P_AXI_ID_W(SC_HRMEM_SRAM_SYS_AXI_ID_W),
  .P_AXI_AD_W(P_BUS_AD_W),
  .P_DT_W(P_DT_W),
  .P_BANK_W(P_BANK_W),
  .P_RD_LTCY(P_RD_LTCY),
  .P_H_PRIO(0)
) axi_ram_ctrl_sys (
  // System Interface
  .S_AXI_ACLK(SYSCLK),                      //  input
  .S_AXI_ARESETN(hrmem_resetn),             //  input
  .RAM_INIT_DONE(r_ram_init_done_sync),     //  input
  // AXI Slave Interface
  .S_AXI_AWID(SYS_S_AXI_AWID),              //  input [P_AXI_ID_W-1:0]
  .S_AXI_AWADDR(SYS_S_AXI_AWADDR),          //  input [P_AXI_AD_W-1:0]
  .S_AXI_AWLEN(SYS_S_AXI_AWLEN),            //  input [7:0]
  .S_AXI_AWSIZE(SYS_S_AXI_AWSIZE),          //  input [2:0]
  .S_AXI_AWBURST(SYS_S_AXI_AWBURST),        //  input [1:0]
  .S_AXI_AWLOCK(SYS_S_AXI_AWLOCK),          //  input
  .S_AXI_AWCACHE(SYS_S_AXI_AWCACHE),        //  input [3:0]
  .S_AXI_AWPROT(SYS_S_AXI_AWPROT),          //  input [2:0]
  .S_AXI_AWVALID(SYS_S_AXI_AWVALID),        //  input
  .S_AXI_AWREADY(SYS_S_AXI_AWREADY),        // output
  .S_AXI_WDATA(SYS_S_AXI_WDATA),            //  input [P_DT_W-1:0]
  .S_AXI_WSTRB(SYS_S_AXI_WSTRB),            //  input [3:0]
  .S_AXI_WLAST(SYS_S_AXI_WLAST),            //  input
  .S_AXI_WVALID(SYS_S_AXI_WVALID),          //  input
  .S_AXI_WREADY(SYS_S_AXI_WREADY),          // output
  .S_AXI_BID(SYS_S_AXI_BID),                // output [P_AXI_ID_W-1:0]
  .S_AXI_BRESP(SYS_S_AXI_BRESP),            // output [1:0]
  .S_AXI_BVALID(SYS_S_AXI_BVALID),          // output
  .S_AXI_BREADY(SYS_S_AXI_BREADY),          //  input
  .S_AXI_ARID(SYS_S_AXI_ARID),              //  input [P_AXI_ID_W-1:0]
  .S_AXI_ARADDR(SYS_S_AXI_ARADDR),          //  input [P_AXI_AD_W-1:0]
  .S_AXI_ARLEN(SYS_S_AXI_ARLEN),            //  input [7:0]
  .S_AXI_ARSIZE(SYS_S_AXI_ARSIZE),          //  input [2:0]
  .S_AXI_ARBURST(SYS_S_AXI_ARBURST),        //  input [1:0]
  .S_AXI_ARLOCK(SYS_S_AXI_ARLOCK),          //  input
  .S_AXI_ARCACHE(SYS_S_AXI_ARCACHE),        //  input [3:0]
  .S_AXI_ARPROT(SYS_S_AXI_ARPROT),          //  input [2:0]
  .S_AXI_ARVALID(SYS_S_AXI_ARVALID),        //  input
  .S_AXI_ARREADY(SYS_S_AXI_ARREADY),        // output
  .S_AXI_RID(SYS_S_AXI_RID),                // output [P_AXI_ID_W-1:0]
  .S_AXI_RDATA(SYS_S_AXI_RDATA),            // output [P_DT_W-1:0]
  .S_AXI_RRESP(SYS_S_AXI_RRESP),            // output [1:0]
  .S_AXI_RLAST(SYS_S_AXI_RLAST),            // output
  .S_AXI_RVALID(SYS_S_AXI_RVALID),          // output
  .S_AXI_RREADY(SYS_S_AXI_RREADY),          //  input
  // Other AXI SRAM Controller Interface
  .SELF_WR_ACC_START(w_sys_wr_acc_start),   // output
  .SELF_WR_ACC_BUSY(w_sys_wr_acc_busy),     // output
  .SELF_WR_ACC_END(w_sys_wr_acc_end),       // output
  .SELF_WR_STATE(w_sys_wr_state),           // output [2:0]
  .SELF_WR_BURST_EN(w_sys_wr_burst_en),     // output
  .SELF_RD_ACC_START(w_sys_rd_acc_start),   // output
  .SELF_RD_ACC_BUSY(w_sys_rd_acc_busy),     // output
  .SELF_RD_ACC_END(w_sys_rd_acc_end),       // output
  .SELF_RD_STATE(w_sys_rd_state),           // output [1:0]
  .SELF_RD_BURST_EN(w_sys_rd_burst_en),     // output
  .SELF_RD_ST_BURST(w_sys_rd_st_burst),     // output
  .OTHER_WR_ACC_START(w_code_wr_acc_start), //  input
  .OTHER_WR_ACC_BUSY(w_code_wr_acc_busy),   //  input
  .OTHER_WR_ACC_END(w_code_wr_acc_end),     //  input
  .OTHER_RD_ACC_START(w_code_rd_acc_start), //  input
  .OTHER_RD_ACC_BUSY(w_code_rd_acc_busy),   //  input
  .OTHER_RD_ACC_END(w_code_rd_acc_end),     //  input
  .OTHER_STATE(w_code_state),               //  input [2:0]
  .OTHER_BURST_EN(w_code_burst_en),         //  input
  .OTHER_ST_BURST(w_code_st_burst),         //  input
  // Prefetch Controller Interface
  .PF_MODE_SEL(2'b00),                      //  input [1:0]
  .PF_SRCH_VAL(/*open*/),                   // output
  .PF_RD_VAL(1'b0),                         //  input
  .PF_RWAIT(w_pf_rwait),                    //  input
  .PF_ACC_VAL(w_pf_acc_val),                //  input
  .PF_ACC_ADR(w_pf_acc_adr),                //  input [P_AXI_AD_W-1:0]
  // RAM Interface
  .RAM_WEN(w_sys_ram_wen),                  // output
  .RAM_WADR(w_sys_ram_wadr),                // output [P_AXI_AD_W-1:0]
  .RAM_WDATA(w_sys_ram_wdata),              // output [P_DT_W-1:0]
  .RAM_WBTEN(w_sys_ram_wbten),              // output [P_DT_W/8-1:0]
  .RAM_REN(w_sys_ram_ren),                  // output
  .RAM_RADR(w_sys_ram_radr),                // output [P_AXI_AD_W-1:0]
  .RAM_RBTEN(w_sys_ram_rbten),              // output [P_DT_W/8-1:0]
  .RAM_RDT_VAL(w_sys_ram_rdt_val),          //  input
  .RAM_RDATA(w_sys_ram_rdata)               //  input [P_DT_W-1:0]
);

// RAM Scrub Sequencer
sc_hrmem_ram_scrb_seq # (
  .P_MEM_NUM(P_MEM_NUM)
) ram_scrb_seq (
  // System Interface
  .CLK(SYSCLK),                           //  input
  .RESET_N(hrmem_resetn),                 //  input
  // Register Interface
  .ECC_COL_EN(w_reg_ecc_col_en),          //  input
  .MEM_SCRB_EN(w_reg_mem_scrb_en),        //  input
  .MEM_SCRB_CYCLE(w_reg_mem_scrb_cycle),  //  input [15:0]
  // UNIT RAM Interface
  .MEM_SCRB_ACT(w_mem_scrb_act)           // output [P_MEM_NUM-1:0]
);

// Power On Reset Synchronizer
sclib_rstb_sync sync_por_rst (
  .CLK(SYSCLK),
  .RSTB_IN(POR_RST_N),
  .RSTB_OUT(w_sync_por_rstb)
);

// RAM Initialize Request Synchronizer
always @ (posedge SYSCLK or negedge w_sync_por_rstb) begin
  if (!w_sync_por_rstb) begin
    r_ram_init_req_p1   <= 0;
    r_ram_init_req_sync <= 0;
  end else begin
    r_ram_init_req_p1   <= RAM_INIT_REQ;
    r_ram_init_req_sync <= r_ram_init_req_p1;
  end
end

// SRAM Initialize Controller
sc_hrmem_ram_init_ctrl # (
  .ADDR_WIDTH(P_MEM_AD_W),
  .MEM_DEPTH(2**P_MEM_AD_W),
  .ACC_INTVAL(1)
) ram_init_ctrl (
  .SYSCLK(SYSCLK),                    //  input
  .RESETB(w_sync_por_rstb),           //  input
  .RAM_INIT_REQ(r_ram_init_req_sync), //  input
  .RAM_INIT_ADDR(w_ram_init_addr),    // output [ADDR_WIDTH-1:0]
  .RAM_INIT_EN(w_ram_init_en),        // output
  .RAM_INIT_DONE(RAM_INIT_DONE)       // output
);

// RAM Initialize Done Synchronizer
always @ (posedge SYSCLK or negedge hrmem_resetn) begin
  if (!hrmem_resetn) begin
    r_ram_init_done_p1   <= 0;
    r_ram_init_done_sync <= 0;
  end else begin
    r_ram_init_done_p1   <= RAM_INIT_DONE;
    r_ram_init_done_sync <= r_ram_init_done_p1;
  end
end

// RAM Read Data Prefetch Controller from CODE Bus Access
sc_hrmem_sram_pfe_ctrl # (
  .P_AD_W(P_BUS_AD_W),
  .P_DT_W(P_DT_W),
  .P_BANK_W(P_BANK_W),
  .P_RD_LTCY(P_RD_LTCY),
  .P_PFB_STG_NUM(SC_HRMEM_SRAM_PFB_STG_NUM),
  .P_PFB_LINE_NUM(SC_HRMEM_SRAM_PFB_LINE_NUM),
  .P_SP_PFB_LINE_NUM(SC_HRMEM_SRAM_SP_PFB_LINE_NUM)
) ram_pfe_ctrl_code (
  // System Interface
  .SYSCLK(SYSCLK),                  // input
  .RESETB(hrmem_resetn),            // input
  // AXI SRAM Controller Interface
  .PF_SRCH_VAL(w_pf_srch_val),      // input
  .RAM_REN(w_code_ram_ren),         // input
  .RAM_RADR(w_code_ram_radr),       // input  [P_AD_W-1:0]
  .RAM_RBTEN(w_code_ram_rbten),     // input  [P_DT_W/8-1:0]
  .PF_RWAIT(w_pf_rwait),            // output
  .PF_RD_DT_MSK(w_pf_rd_dt_msk),    // input
  .PF_RD_VAL(w_pf_rd_val),          // output
  .RAM_RDT_VAL(w_code_ram_rdt_val), // output
  .RAM_RDATA(w_code_ram_rdata),     // output [P_DT_W-1:0]
  .CODE_RAM_WEN(w_code_ram_wen),    // input
  .CODE_RAM_WADR(w_code_ram_wadr),  // input  [P_AD_W-1:0]
  .SYS_RAM_WEN(w_sys_ram_wen),      // input
  .SYS_RAM_WADR(w_sys_ram_wadr),    // input  [P_AD_W-1:0]
  .PF_ACC_VAL(w_pf_acc_val),        // output
  .PF_ACC_ADR(w_pf_acc_adr),        // output [P_AD_W-1:0]
  // RAM Interface
  .PF_REN(w_code_pf_ren),           // output
  .PF_RADR(w_code_pf_radr),         // output [P_AD_W-1:0]
  .PF_RBTEN(w_code_pf_rbten),       // output [P_DT_W/8-1:0]
  .PF_RDT_VAL(w_code_pf_rdt_val),   // input
  .PF_RDATA(w_code_pf_rdata),       // input  [P_DT_W-1:0]
  // Register Interface
  .REG_SP_PF_EN(w_reg_sp_pf_en),    // input  [P_SP_PFB_LINE_NUM-1:0]
  .REG_SP_PF_ADR(w_reg_sp_pf_adr),  // input  [P_AD_W*P_SP_PFB_LINE_NUM-1:0]
  .REG_PF_FLUSH(w_reg_pf_flush)     // input
);

// UNIT SRAM Wrapper
sc_hrmem_unit_sram_wrap # (
  .P_AXI_AD_W(P_BUS_AD_W),
  .P_MEM_AD_W(P_MEM_AD_W),
  .P_DT_W(P_DT_W),
  .P_BANK_W(P_BANK_W),
  .P_RD_LTCY(P_RD_LTCY)
) unit_ram_wrap (
  // System Interface
  .RAM_CLK(SYSCLK),                                  //  input
  .RESET_N(hrmem_resetn),                            //  input
  // SRAM Initialize Controller Interface
  .INIT_EN(w_ram_init_en),                           //  input
  .INIT_ADR(w_ram_init_addr),                        //  input [P_MEM_AD_W-1:0]
  // AXI SRAM Controller Interface
  .CODE_RAM_WEN(w_code_ram_wen),                     //  input
  .CODE_RAM_WADR(w_code_ram_wadr),                   //  input [P_AXI_AD_W-1:0]
  .CODE_RAM_WDATA(w_code_ram_wdata),                 //  input [P_DT_W-1:0]
  .CODE_RAM_WBTEN(w_code_ram_wbten),                 //  input [P_DT_W/8-1:0]
  .CODE_RAM_REN(w_code_pf_ren),                      //  input
  .CODE_RAM_RADR(w_code_pf_radr),                    //  input [P_AXI_AD_W-1:0]
  .CODE_RAM_RBTEN(w_code_pf_rbten),                  //  input [P_DT_W/8-1:0]
  .CODE_RAM_RDT_VAL(w_code_pf_rdt_val),              // output
  .CODE_RAM_RDATA(w_code_pf_rdata),                  // output [P_DT_W-1:0]
  .SYS_RAM_WEN(w_sys_ram_wen),                       //  input
  .SYS_RAM_WADR(w_sys_ram_wadr),                     //  input [P_AXI_AD_W-1:0]
  .SYS_RAM_WDATA(w_sys_ram_wdata),                   //  input [P_DT_W-1:0]
  .SYS_RAM_WBTEN(w_sys_ram_wbten),                   //  input [P_DT_W/8-1:0]
  .SYS_RAM_REN(w_sys_ram_ren),                       //  input
  .SYS_RAM_RADR(w_sys_ram_radr),                     //  input [P_AXI_AD_W-1:0]
  .SYS_RAM_RBTEN(w_sys_ram_rbten),                   //  input [P_DT_W/8-1:0]
  .SYS_RAM_RDT_VAL(w_sys_ram_rdt_val),               // output
  .SYS_RAM_RDATA(w_sys_ram_rdata),                   // output [P_DT_W-1:0]
  // RAM Scrub Sequencer Interface
  .MEM_SCRB_ACT(w_mem_scrb_act),                     //  input
  // SRAM Interface
  .SR_A(SR_A),                                       // output [19:0]
  .SR1_CEB(SR1_CEB),                                 // output
  .SR1_OEB(SR1_OEB),                                 // output
  .SR1_WEB(SR1_WEB),                                 // output
  .SR1_BHEB(SR1_BHEB),                               // output
  .SR1_BLEB(SR1_BLEB),                               // output
  .SR1_IO(SR1_IO),                                   // inout  [15:0]
  .SR1_ERR(SR1_ERR),                                 // input
  .SR2_CEB(SR2_CEB),                                 // output
  .SR2_OEB(SR2_OEB),                                 // output
  .SR2_WEB(SR2_WEB),                                 // output
  .SR2_BHEB(SR2_BHEB),                               // output
  .SR2_BLEB(SR2_BLEB),                               // output
  .SR2_IO(SR2_IO),                                   // inout  [15:0]
  .SR2_ERR(SR2_ERR),                                 // input
  // Register Interface
  .ECC_COL_EN(w_reg_ecc_col_en),                     //  input
  .COL_FSTK_RDSTOP(w_reg_col_fstk_rdstop),           //  input
  .ECCERRCNT_CLR(w_reg_eccerrcnt_clr),               //  input
  .RAM_ECC1ERR(w_reg_ram_ecc1err),                   // output
  .RAM_ECC2ERR(w_reg_ram_ecc2err),                   // output
  .RAM_ECC1ERR_AXI(w_reg_ram_ecc1err_axi),           // output
  .RAM_ECC2ERR_AXI(w_reg_ram_ecc2err_axi),           // output
  .RAM_ECC1ERR_ATRD(w_reg_ram_ecc1err_atrd),         // output
  .RAM_ECC2ERR_ATRD(w_reg_ram_ecc2err_atrd),         // output
  .ECC_COL_DISC(w_reg_ecc_col_disc),                 // output
  .RAM_ECC1ERR_CNT(w_reg_ram_ecc1err_cnt),           // output [15:0]
  .RAM_ECC2ERR_CNT(w_reg_ram_ecc2err_cnt),           // output [15:0]
  .RAM_ECC1ERR_AXI_CNT(w_reg_ram_ecc1err_axi_cnt),   // output [15:0]
  .RAM_ECC2ERR_AXI_CNT(w_reg_ram_ecc2err_axi_cnt),   // output [15:0]
  .RAM_ECC1ERR_ATRD_CNT(w_reg_ram_ecc1err_atrd_cnt), // output [15:0]
  .RAM_ECC2ERR_ATRD_CNT(w_reg_ram_ecc2err_atrd_cnt), // output [15:0]
  .ECC_COL_DISC_CNT(w_reg_ecc_col_disc_cnt)          // output [15:0]
);

endmodule
