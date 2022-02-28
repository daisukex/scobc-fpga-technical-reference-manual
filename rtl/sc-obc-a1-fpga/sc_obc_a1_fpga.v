//-----------------------------------------------
// Space Cubics OBC A1
//  FPGA Top Module
// Module: sc_obc_a1_fpga
//-----------------------------------------------
// Copyright © 2022 Space Cubics, LLC.
//-----------------------------------------------
module sc_obc_a1_fpga # (
  parameter SYSCTRL_USER_CLK1_DIVIDE = 100,
  parameter SYSCTRL_USER_CLK1_MODE = 0,
  parameter SYSCTRL_USER_CLK2_DIVIDE = 100,
  parameter SYSCTRL_USER_CLK2_MODE = 0,
  parameter CM3SS_UDL_ISR_NUM = 16,
  parameter CM3SS_ITCM_SIZE_KB = 128,
  parameter CM3SS_ITCM_ADDR_BW = 14,
  parameter MAINAXI_UDL_M_AXI_ID_WIDTH = 2,
  parameter MAINAXI_S_AXI_ID_WIDTH = 3
) (
  // System Interface
  input  SYSCLK1,
  output SYSCLK1_EN,
  input  SYSCLK2,
  output SYSCLK2_EN,
  input  CDRST_B,
  output CFG_DONE,

  // Debug Interface
  input  CM3_NTRST,
  input  CM3_TDI,
  input  CM3_TCK_SWCLK,
  inout  CM3_TMS_SWDIO,
  output CM3_TDO_SWO,

  // CFG QSPI Flash Interface
  output CFG_MEM_SEL,
  input  CFG_MEM_MON,
  output CFG_MEM_SCK,
  output CFG_MEM_CS_B,
  inout  [3:0] CFG_MEM_IO,

  // Data QSPI Flash Interface
  output DATA_MEM1_CS_B,
  output DATA_MEM1_SCK,
  inout  [3:0] DATA_MEM1_IO,
  output DATA_MEM2_CS_B,
  output DATA_MEM2_SCK,
  inout  [3:0] DATA_MEM2_IO,

  // FRAM Interface
  output FRAM1_CS_B,
  output FRAM1_SCK,
  inout  [3:0] FRAM1_IO,
  output FRAM2_CS_B,
  output FRAM2_SCK,
  inout  [3:0] FRAM2_IO,

  // CAN Interface
  output FPGA_CAN_TX,
  input  FPGA_CAN_RX,
  output FPGA_CAN_SLEEP_EN,

  // I2C Interface
  inout  FPGA_INT_SCL,
  inout  FPGA_INT_SDA,
  input  CVM_CRITICAL_B,
  input  CVM_WARNING_B,
  input  TEMP_ALERT_B,
  inout  FPGA_EXT_SCL,
  inout  FPGA_EXT_SDA,

  // TRCH Interface
  input  FPGA_BOOT0,
  input  FPGA_BOOT1,
  output FPGA_WATCHDOG,
  inout  FPGA_RESERVE,

  // User IO Interface
//  inout  [15:0] UIO1,
//  inout  [15:0] UIO2,
  inout  UIO4
);

wire w_init_req;
wire w_init_done;
wire [1:0] w_clkmode;
wire w_cmc_req;
wire w_cmc_ack;
wire w_plllock;
wire w_sleeping;
wire w_sleepholdreqn;
wire w_sleepholdackn;
wire w_sys_rst_req;
wire w_reg_rst_req;
wire w_cpu_lockup;
wire w_cpu_lockup_rsten;

wire w_ref_clk;
wire w_sys_clk;
wire w_maxi_clk;
wire w_user_clk1;
wire w_user_clk2;

wire w_por_rstb;
wire w_por_rstb_sync_refclk;
wire w_sys_rstb;
wire w_sys_rstb_sync_refclk;
wire w_sys_rstb_sync_userclk1;
wire w_sys_rstb_sync_userclk2;
wire w_bus_rstb;

wire [MAINAXI_UDL_M_AXI_ID_WIDTH-1:0] w_udl_m_axi_awid;
wire [31:0] w_udl_m_axi_awaddr;
wire [7:0] w_udl_m_axi_awlen;
wire [2:0] w_udl_m_axi_awsize;
wire [1:0] w_udl_m_axi_awburst;
wire w_udl_m_axi_awlock;
wire [3:0] w_udl_m_axi_awcache;
wire [2:0] w_udl_m_axi_awprot;
wire [3:0] w_udl_m_axi_awqos;
wire w_udl_m_axi_awvalid;
wire w_udl_m_axi_awready;
wire [31:0] w_udl_m_axi_wdata;
wire [3:0] w_udl_m_axi_wstrb;
wire w_udl_m_axi_wlast;
wire w_udl_m_axi_wvalid;
wire w_udl_m_axi_wready;
wire [MAINAXI_UDL_M_AXI_ID_WIDTH-1:0] w_udl_m_axi_bid;
wire [1:0] w_udl_m_axi_bresp;
wire w_udl_m_axi_bvalid;
wire w_udl_m_axi_bready;
wire [MAINAXI_UDL_M_AXI_ID_WIDTH-1:0] w_udl_m_axi_arid;
wire [31:0] w_udl_m_axi_araddr;
wire [7:0] w_udl_m_axi_arlen;
wire [2:0] w_udl_m_axi_arsize;
wire [1:0] w_udl_m_axi_arburst;
wire w_udl_m_axi_arlock;
wire [3:0] w_udl_m_axi_arcache;
wire [2:0] w_udl_m_axi_arprot;
wire [3:0] w_udl_m_axi_arqos;
wire w_udl_m_axi_arvalid;
wire w_udl_m_axi_arready;
wire [MAINAXI_UDL_M_AXI_ID_WIDTH-1:0] w_udl_m_axi_rid;
wire [31:0] w_udl_m_axi_rdata;
wire [1:0] w_udl_m_axi_rresp;
wire w_udl_m_axi_rlast;
wire w_udl_m_axi_rvalid;
wire w_udl_m_axi_rready;

wire [MAINAXI_S_AXI_ID_WIDTH-1:0] w_udl_s_axi_awid;
wire [31:0] w_udl_s_axi_awaddr;
wire [7:0] w_udl_s_axi_awlen;
wire [2:0] w_udl_s_axi_awsize;
wire [1:0] w_udl_s_axi_awburst;
wire w_udl_s_axi_awlock;
wire [3:0] w_udl_s_axi_awcache;
wire [2:0] w_udl_s_axi_awprot;
wire [3:0] w_udl_s_axi_awregion;
wire [3:0] w_udl_s_axi_awqos;
wire w_udl_s_axi_awvalid;
wire w_udl_s_axi_awready;
wire [31:0] w_udl_s_axi_wdata;
wire [3:0] w_udl_s_axi_wstrb;
wire w_udl_s_axi_wlast;
wire w_udl_s_axi_wvalid;
wire w_udl_s_axi_wready;
wire [MAINAXI_S_AXI_ID_WIDTH-1:0] w_udl_s_axi_bid;
wire [1:0] w_udl_s_axi_bresp;
wire w_udl_s_axi_bvalid;
wire w_udl_s_axi_bready;
wire [MAINAXI_S_AXI_ID_WIDTH-1:0] w_udl_s_axi_arid;
wire [31:0] w_udl_s_axi_araddr;
wire [7:0] w_udl_s_axi_arlen;
wire [2:0] w_udl_s_axi_arsize;
wire [1:0] w_udl_s_axi_arburst;
wire w_udl_s_axi_arlock;
wire [3:0] w_udl_s_axi_arcache;
wire [2:0] w_udl_s_axi_arprot;
wire [3:0] w_udl_s_axi_arregion;
wire [3:0] w_udl_s_axi_arqos;
wire w_udl_s_axi_arvalid;
wire w_udl_s_axi_arready;
wire [MAINAXI_S_AXI_ID_WIDTH-1:0] w_udl_s_axi_rid;
wire [31:0] w_udl_s_axi_rdata;
wire [1:0] w_udl_s_axi_rresp;
wire w_udl_s_axi_rlast;
wire w_udl_s_axi_rvalid;
wire w_udl_s_axi_rready;

wire [CM3SS_UDL_ISR_NUM-1:0] w_udl_intisr;

wire w_jtagnsw;
wire w_swclktck;
wire w_swditms;
wire w_swdo;
wire w_swdoen;
wire w_swv;
wire w_ntrst;
wire w_tdi;
wire w_tdo;
wire w_ntdoen;

// System Controller
scobca1_sysctrl # (
  .SYSCTRL_USER_CLK1_DIVIDE(SYSCTRL_USER_CLK1_DIVIDE),
  .SYSCTRL_USER_CLK1_MODE(SYSCTRL_USER_CLK1_MODE),
  .SYSCTRL_USER_CLK2_DIVIDE(SYSCTRL_USER_CLK2_DIVIDE),
  .SYSCTRL_USER_CLK2_MODE(SYSCTRL_USER_CLK2_MODE)
) sysctrl (
  .SYSCLK1(SYSCLK1),
  .SYSCLK1_EN(SYSCLK1_EN),
  .SYSCLK2(SYSCLK2),
  .SYSCLK2_EN(SYSCLK2_EN),
  .INIT_REQ(w_init_req),
  .INIT_DONE(w_init_done),
  .CLKMODE(w_clkmode),
  .CMC_REQ(w_cmc_req),
  .CMC_ACK(w_cmc_ack),
  .PLLLOCK(w_plllock),
  .SLEEPING(w_sleeping),
  .SLEEPHOLDREQN(w_sleepholdreqn),
  .SLEEPHOLDACKN(w_sleepholdackn),
  .SYS_RST_REQ(w_sys_rst_req),
  .REG_RST_REQ(w_reg_rst_req),
  .CPU_LOCKUP(w_cpu_lockup),
  .CPU_LOCKUP_RSTEN(w_cpu_lockup_rsten),
  .REF_CLK(w_ref_clk),
  .SYS_CLK(w_sys_clk),
  .MAXI_CLK(w_maxi_clk),
  .ULPI_REFCLK(/*open*/),
  .USER_CLK1(w_user_clk1),
  .USER_CLK2(w_user_clk2),
  .POR_RSTB(w_por_rstb),
  .POR_RSTB_SYNC_REFCLK(w_por_rstb_sync_refclk),
  .SYS_RSTB(w_sys_rstb),
  .SYS_RSTB_SYNC_REFCLK(w_sys_rstb_sync_refclk),
  .SYS_RSTB_SYNC_USERCLK1(w_sys_rstb_sync_userclk1),
  .SYS_RSTB_SYNC_USERCLK2(w_sys_rstb_sync_userclk2),
  .BUS_RSTB(w_bus_rstb)
);

// OBC Core TOP
sc_obc_core # (
  .CM3SS_UDL_ISR_NUM(CM3SS_UDL_ISR_NUM),
  .CM3SS_ITCM_SIZE_KB(CM3SS_ITCM_SIZE_KB),
  .CM3SS_ITCM_ADDR_BW(CM3SS_ITCM_ADDR_BW),
  .MAINAXI_UDL_M_AXI_ID_WIDTH(MAINAXI_UDL_M_AXI_ID_WIDTH),
  .MAINAXI_S_AXI_ID_WIDTH(MAINAXI_S_AXI_ID_WIDTH)
) obc_core (
  // Clock/Reset Signals
  // ------------------------------
  // Clock
  .REF_CLK(w_ref_clk),
  .SYS_CLK(w_sys_clk),
  .PLLLOCK(w_plllock),
  // Reset
  .SYS_RST_REQ(w_sys_rst_req),
  .REG_RST_REQ(w_reg_rst_req),
  .POR_RSTB(w_por_rstb),
  .POR_RSTB_SYNC_REFCLK(w_por_rstb_sync_refclk),
  .SYS_RSTB(w_sys_rstb),
  .SYS_RSTB_SYNC_REFCLK(w_sys_rstb_sync_refclk),
  .BUS_RSTB(w_bus_rstb),
  // Clock Mode Control
  .CLKMODE(w_clkmode),
  .CMC_REQ(w_cmc_req),
  .CMC_ACK(w_cmc_ack),
  // Logic Initilize Control Signals
  // ------------------------------
  .INIT_REQ(w_init_req),
  .INIT_DONE(w_init_done),
  // Cortex-M3 Signals
  // ------------------------------
  // Power Management Signals
  .SLEEPING(w_sleeping),
  .SLEEPHOLDREQN(w_sleepholdreqn),
  .SLEEPHOLDACKN(w_sleepholdackn),
  // Lockup monitor and control
  .CPU_LOCKUP(w_cpu_lockup),
  .CPU_LOCKUP_RSTEN(w_cpu_lockup_rsten),

  // UDL Master Interface
  // ------------------------------
  // Write Address Channel
  .UDL_AXIM_AWID(w_udl_m_axi_awid),
  .UDL_AXIM_AWADDR(w_udl_m_axi_awaddr),
  .UDL_AXIM_AWLEN(w_udl_m_axi_awlen),
  .UDL_AXIM_AWSIZE(w_udl_m_axi_awsize),
  .UDL_AXIM_AWBURST(w_udl_m_axi_awburst),
  .UDL_AXIM_AWLOCK(w_udl_m_axi_awlock),
  .UDL_AXIM_AWCACHE(w_udl_m_axi_awcache),
  .UDL_AXIM_AWPROT(w_udl_m_axi_awprot),
  .UDL_AXIM_AWQOS(w_udl_m_axi_awqos),
  .UDL_AXIM_AWVALID(w_udl_m_axi_awvalid),
  .UDL_AXIM_AWREADY(w_udl_m_axi_awready),
  // Write Data Channel
  .UDL_AXIM_WDATA(w_udl_m_axi_wdata),
  .UDL_AXIM_WSTRB(w_udl_m_axi_wstrb),
  .UDL_AXIM_WLAST(w_udl_m_axi_wlast),
  .UDL_AXIM_WVALID(w_udl_m_axi_wvalid),
  .UDL_AXIM_WREADY(w_udl_m_axi_wready),
  .UDL_AXIM_BID(w_udl_m_axi_bid),
  // Write Responce Channel
  .UDL_AXIM_BRESP(w_udl_m_axi_bresp),
  .UDL_AXIM_BVALID(w_udl_m_axi_bvalid),
  .UDL_AXIM_BREADY(w_udl_m_axi_bready),
  // Read Address Channel
  .UDL_AXIM_ARID(w_udl_m_axi_arid),
  .UDL_AXIM_ARADDR(w_udl_m_axi_araddr),
  .UDL_AXIM_ARLEN(w_udl_m_axi_arlen),
  .UDL_AXIM_ARSIZE(w_udl_m_axi_arsize),
  .UDL_AXIM_ARBURST(w_udl_m_axi_arburst),
  .UDL_AXIM_ARLOCK(w_udl_m_axi_arlock),
  .UDL_AXIM_ARCACHE(w_udl_m_axi_arcache),
  .UDL_AXIM_ARPROT(w_udl_m_axi_arprot),
  .UDL_AXIM_ARQOS(w_udl_m_axi_arqos),
  .UDL_AXIM_ARVALID(w_udl_m_axi_arvalid),
  .UDL_AXIM_ARREADY(w_udl_m_axi_arready),
  // Read Data Channel
  .UDL_AXIM_RID(w_udl_m_axi_rid),
  .UDL_AXIM_RDATA(w_udl_m_axi_rdata),
  .UDL_AXIM_RRESP(w_udl_m_axi_rresp),
  .UDL_AXIM_RLAST(w_udl_m_axi_rlast),
  .UDL_AXIM_RVALID(w_udl_m_axi_rvalid),
  .UDL_AXIM_RREADY(w_udl_m_axi_rready),

  // UDL Slave Interface
  // ------------------------------
  // Write Address Channel
  .UDL_AXIS_AWID(w_udl_s_axi_awid),
  .UDL_AXIS_AWADDR(w_udl_s_axi_awaddr),
  .UDL_AXIS_AWLEN(w_udl_s_axi_awlen),
  .UDL_AXIS_AWSIZE(w_udl_s_axi_awsize),
  .UDL_AXIS_AWBURST(w_udl_s_axi_awburst),
  .UDL_AXIS_AWLOCK(w_udl_s_axi_awlock),
  .UDL_AXIS_AWCACHE(w_udl_s_axi_awcache),
  .UDL_AXIS_AWPROT(w_udl_s_axi_awprot),
  .UDL_AXIS_AWREGION(w_udl_s_axi_awregion),
  .UDL_AXIS_AWQOS(w_udl_s_axi_awqos),
  .UDL_AXIS_AWVALID(w_udl_s_axi_awvalid),
  .UDL_AXIS_AWREADY(w_udl_s_axi_awready),
  // Write Data Channel
  .UDL_AXIS_WDATA(w_udl_s_axi_wdata),
  .UDL_AXIS_WSTRB(w_udl_s_axi_wstrb),
  .UDL_AXIS_WLAST(w_udl_s_axi_wlast),
  .UDL_AXIS_WVALID(w_udl_s_axi_wvalid),
  .UDL_AXIS_WREADY(w_udl_s_axi_wready),
  // Write Responce Channel
  .UDL_AXIS_BID(w_udl_s_axi_bid),
  .UDL_AXIS_BRESP(w_udl_s_axi_bresp),
  .UDL_AXIS_BVALID(w_udl_s_axi_bvalid),
  .UDL_AXIS_BREADY(w_udl_s_axi_bready),
  // Read Address Channel
  .UDL_AXIS_ARID(w_udl_s_axi_arid),
  .UDL_AXIS_ARADDR(w_udl_s_axi_araddr),
  .UDL_AXIS_ARLEN(w_udl_s_axi_arlen),
  .UDL_AXIS_ARSIZE(w_udl_s_axi_arsize),
  .UDL_AXIS_ARBURST(w_udl_s_axi_arburst),
  .UDL_AXIS_ARLOCK(w_udl_s_axi_arlock),
  .UDL_AXIS_ARCACHE(w_udl_s_axi_arcache),
  .UDL_AXIS_ARPROT(w_udl_s_axi_arprot),
  .UDL_AXIS_ARREGION(w_udl_s_axi_arregion),
  .UDL_AXIS_ARQOS(w_udl_s_axi_arqos),
  .UDL_AXIS_ARVALID(w_udl_s_axi_arvalid),
  .UDL_AXIS_ARREADY(w_udl_s_axi_arready),
  // Read Data Channel
  .UDL_AXIS_RID(w_udl_s_axi_rid),
  .UDL_AXIS_RDATA(w_udl_s_axi_rdata),
  .UDL_AXIS_RRESP(w_udl_s_axi_rresp),
  .UDL_AXIS_RLAST(w_udl_s_axi_rlast),
  .UDL_AXIS_RVALID(w_udl_s_axi_rvalid),
  .UDL_AXIS_RREADY(w_udl_s_axi_rready),
  .UDL_INTISR(w_udl_intisr),

  // NOR Flash Configuration Memory Interface
  // ------------------------------
  .CFG_MEM_SCK(CFG_MEM_SCK),
  .CFG_MEM_CS_B(CFG_MEM_CS_B),
  .CFG_MEM_IO(CFG_MEM_IO),

  // NOR Flash Data Memory Interface
  // ------------------------------
  .DATA_MEM1_SCK(DATA_MEM1_SCK),
  .DATA_MEM1_CS_B(DATA_MEM1_CS_B),
  .DATA_MEM1_IO(DATA_MEM1_IO),
  .DATA_MEM2_SCK(DATA_MEM2_SCK),
  .DATA_MEM2_CS_B(DATA_MEM2_CS_B),
  .DATA_MEM2_IO(DATA_MEM2_IO),

  // FeRAM Data Memory Interface
  // ------------------------------
  .FRAM1_SCK(FRAM1_SCK),
  .FRAM1_CS_B(FRAM1_CS_B),
  .FRAM1_IO(FRAM1_IO),
  .FRAM2_SCK(FRAM2_SCK),
  .FRAM2_CS_B(FRAM2_CS_B),
  .FRAM2_IO(FRAM2_IO),

  // CAN Interface
  // ------------------------------
  .CAN_TX(FPGA_CAN_TX),
  .CAN_RX(FPGA_CAN_RX),
  .CAN_SLEEP_EN(FPGA_CAN_SLEEP_EN),

  // Uart Lite Interface
  // ------------------------------
  .UART_TX(UIO4),
  .UART_RX(CM3_NTRST),

  // Internal I2C Interface
  // ------------------------------
  .INTERNAL_I2CM_SDA(FPGA_INT_SDA),
  .INTERNAL_I2CM_SCL(FPGA_INT_SCL),

  // External I2C Interface
  // ------------------------------
  .EXTERNAL_I2CM_SDA(FPGA_EXT_SDA),
  .EXTERNAL_I2CM_SCL(FPGA_EXT_SCL),

  // Coetex-M3 SWJ-DP Interface
  // ------------------------------
  .JTAGNSW(w_jtagnsw),
  .SWCLKTCK(w_swclktck),
  .SWDITMS(w_swditms),
  .SWDO(w_swdo),
  .SWDOEN(w_swdoen),
  .SWV(w_swv),
  .NTRST(w_ntrst),
  .TDI(w_tdi),
  .TDO(w_tdo),
  .NTDOEN(w_ntdoen)
);

// SWJ-DP Selector
swjdp_selector swjdp_selector(
  // FPGA External Port
  .NTRST(1'b1),
  .TDI(CM3_TDI),
  .SWCLKTCK(CM3_TCK_SWCLK),
  .SWDIOTMS(CM3_TMS_SWDIO),
  .TDOSWO(CM3_TDO_SWO),
  // CPU Port
  .NTRST_OUT(w_ntrst),
  .TDI_OUT(w_tdi),
  .SWCLKTCK_OUT(w_swclktck),
  .SWDITMS_OUT(w_swditms),
  .SWDO_IN(w_swdo),
  .SWDOEN_IN(w_swdoen),
  .JTAGNSW_IN(w_jtagnsw),
  .TDO_IN(w_tdo),
  .SWV_IN(w_swv),
  .NTDOEN_IN(w_ntdoen)
);

// UDL(User Design Logic) AXI Bus
udl_axi # (
  .CM3SS_UDL_ISR_NUM(CM3SS_UDL_ISR_NUM),
  .MAINAXI_UDL_M_AXI_ID_WIDTH(MAINAXI_UDL_M_AXI_ID_WIDTH),
  .MAINAXI_S_AXI_ID_WIDTH(MAINAXI_S_AXI_ID_WIDTH)
) udl_axi (
  // System Interface
  .MAXI_CLK(w_maxi_clk),
  .REF_CLK(w_ref_clk),
  .USER_CLK1(w_user_clk1),
  .USER_CLK2(w_user_clk2),
  .SYS_RSTB(w_sys_rstb),
  .SYS_RSTB_SYNC_REFCLK(w_sys_rstb_sync_refclk),
  .SYS_RSTB_SYNC_USERCLK1(w_sys_rstb_sync_userclk1),
  .SYS_RSTB_SYNC_USERCLK2(w_sys_rstb_sync_userclk2),
  .POR_RSTB(w_por_rstb),
  .POR_RSTB_SYNC_REFCLK(w_por_rstb_sync_refclk),
  .BUS_RSTB(w_bus_rstb),

  .UDL_INTISR(w_udl_intisr),

  // UDL AXI4 Master Interface
  .UDL_M_AXI_AWID(w_udl_m_axi_awid),
  .UDL_M_AXI_AWADDR(w_udl_m_axi_awaddr),
  .UDL_M_AXI_AWLEN(w_udl_m_axi_awlen),
  .UDL_M_AXI_AWSIZE(w_udl_m_axi_awsize),
  .UDL_M_AXI_AWBURST(w_udl_m_axi_awburst),
  .UDL_M_AXI_AWLOCK(w_udl_m_axi_awlock),
  .UDL_M_AXI_AWCACHE(w_udl_m_axi_awcache),
  .UDL_M_AXI_AWPROT(w_udl_m_axi_awprot),
  .UDL_M_AXI_AWQOS(w_udl_m_axi_awqos),
  .UDL_M_AXI_AWVALID(w_udl_m_axi_awvalid),
  .UDL_M_AXI_AWREADY(w_udl_m_axi_awready),
  .UDL_M_AXI_WDATA(w_udl_m_axi_wdata),
  .UDL_M_AXI_WSTRB(w_udl_m_axi_wstrb),
  .UDL_M_AXI_WLAST(w_udl_m_axi_wlast),
  .UDL_M_AXI_WVALID(w_udl_m_axi_wvalid),
  .UDL_M_AXI_WREADY(w_udl_m_axi_wready),
  .UDL_M_AXI_BID(w_udl_m_axi_bid),
  .UDL_M_AXI_BRESP(w_udl_m_axi_bresp),
  .UDL_M_AXI_BVALID(w_udl_m_axi_bvalid),
  .UDL_M_AXI_BREADY(w_udl_m_axi_bready),
  .UDL_M_AXI_ARID(w_udl_m_axi_arid),
  .UDL_M_AXI_ARADDR(w_udl_m_axi_araddr),
  .UDL_M_AXI_ARLEN(w_udl_m_axi_arlen),
  .UDL_M_AXI_ARSIZE(w_udl_m_axi_arsize),
  .UDL_M_AXI_ARBURST(w_udl_m_axi_arburst),
  .UDL_M_AXI_ARLOCK(w_udl_m_axi_arlock),
  .UDL_M_AXI_ARCACHE(w_udl_m_axi_arcache),
  .UDL_M_AXI_ARPROT(w_udl_m_axi_arprot),
  .UDL_M_AXI_ARQOS(w_udl_m_axi_arqos),
  .UDL_M_AXI_ARVALID(w_udl_m_axi_arvalid),
  .UDL_M_AXI_ARREADY(w_udl_m_axi_arready),
  .UDL_M_AXI_RID(w_udl_m_axi_rid),
  .UDL_M_AXI_RDATA(w_udl_m_axi_rdata),
  .UDL_M_AXI_RRESP(w_udl_m_axi_rresp),
  .UDL_M_AXI_RLAST(w_udl_m_axi_rlast),
  .UDL_M_AXI_RVALID(w_udl_m_axi_rvalid),
  .UDL_M_AXI_RREADY(w_udl_m_axi_rready),

  // UDL AXI4 Slave Interface
  .UDL_S_AXI_AWID(w_udl_s_axi_awid),
  .UDL_S_AXI_AWADDR(w_udl_s_axi_awaddr),
  .UDL_S_AXI_AWLEN(w_udl_s_axi_awlen),
  .UDL_S_AXI_AWSIZE(w_udl_s_axi_awsize),
  .UDL_S_AXI_AWBURST(w_udl_s_axi_awburst),
  .UDL_S_AXI_AWLOCK(w_udl_s_axi_awlock),
  .UDL_S_AXI_AWCACHE(w_udl_s_axi_awcache),
  .UDL_S_AXI_AWPROT(w_udl_s_axi_awprot),
  .UDL_S_AXI_AWREGION(w_udl_s_axi_awregion),
  .UDL_S_AXI_AWQOS(w_udl_s_axi_awqos),
  .UDL_S_AXI_AWVALID(w_udl_s_axi_awvalid),
  .UDL_S_AXI_AWREADY(w_udl_s_axi_awready),
  .UDL_S_AXI_WDATA(w_udl_s_axi_wdata),
  .UDL_S_AXI_WSTRB(w_udl_s_axi_wstrb),
  .UDL_S_AXI_WLAST(w_udl_s_axi_wlast),
  .UDL_S_AXI_WVALID(w_udl_s_axi_wvalid),
  .UDL_S_AXI_WREADY(w_udl_s_axi_wready),
  .UDL_S_AXI_BID(w_udl_s_axi_bid),
  .UDL_S_AXI_BRESP(w_udl_s_axi_bresp),
  .UDL_S_AXI_BVALID(w_udl_s_axi_bvalid),
  .UDL_S_AXI_BREADY(w_udl_s_axi_bready),
  .UDL_S_AXI_ARID(w_udl_s_axi_arid),
  .UDL_S_AXI_ARADDR(w_udl_s_axi_araddr),
  .UDL_S_AXI_ARLEN(w_udl_s_axi_arlen),
  .UDL_S_AXI_ARSIZE(w_udl_s_axi_arsize),
  .UDL_S_AXI_ARBURST(w_udl_s_axi_arburst),
  .UDL_S_AXI_ARLOCK(w_udl_s_axi_arlock),
  .UDL_S_AXI_ARCACHE(w_udl_s_axi_arcache),
  .UDL_S_AXI_ARPROT(w_udl_s_axi_arprot),
  .UDL_S_AXI_ARREGION(w_udl_s_axi_arregion),
  .UDL_S_AXI_ARQOS(w_udl_s_axi_arqos),
  .UDL_S_AXI_ARVALID(w_udl_s_axi_arvalid),
  .UDL_S_AXI_ARREADY(w_udl_s_axi_arready),
  .UDL_S_AXI_RID(w_udl_s_axi_rid),
  .UDL_S_AXI_RDATA(w_udl_s_axi_rdata),
  .UDL_S_AXI_RRESP(w_udl_s_axi_rresp),
  .UDL_S_AXI_RLAST(w_udl_s_axi_rlast),
  .UDL_S_AXI_RVALID(w_udl_s_axi_rvalid),
  .UDL_S_AXI_RREADY(w_udl_s_axi_rready)

  // User IO Interface
//  .UIO1(UIO1),
//  .UIO2(UIO2),
//  .UIO4(UIO4)
);

// Not Used Signal
assign CFG_DONE = 1'b0;
assign CFG_MEM_SEL = 1'b0;
assign FPGA_WATCHDOG = 1'b0;
assign FPGA_RESERVE = 1'b0;

endmodule
