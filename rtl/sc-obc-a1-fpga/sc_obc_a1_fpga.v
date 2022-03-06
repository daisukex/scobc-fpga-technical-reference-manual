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
  parameter CM3SS_ITCM_ADDR_BW = 17,
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

wire init_req;
wire init_done;
wire [1:0] clkmode;
wire cmc_req;
wire cmc_ack;
wire plllock;
wire sleeping;
wire sleepholdreqn;
wire sleepholdackn;
wire sys_rst_req;
wire reg_rst_req;
wire cpu_lockup;
wire cpu_lockup_rsten;

wire ref_clk;
wire sys_clk;
wire maxi_clk;
wire user_clk1;
wire user_clk2;

wire por_rstb;
wire por_rstb_sync_refclk;
wire sys_rstb;
wire sys_rstb_sync_refclk;
wire sys_rstb_sync_userclk1;
wire sys_rstb_sync_userclk2;
wire bus_rstb;

wire [MAINAXI_UDL_M_AXI_ID_WIDTH-1:0] udl_axim_awid;
wire [31:0] udl_axim_awaddr;
wire [7:0] udl_axim_awlen;
wire [2:0] udl_axim_awsize;
wire [1:0] udl_axim_awburst;
wire udl_axim_awlock;
wire [3:0] udl_axim_awcache;
wire [2:0] udl_axim_awprot;
wire [3:0] udl_axim_awqos;
wire udl_axim_awvalid;
wire udl_axim_awready;
wire [31:0] udl_axim_wdata;
wire [3:0] udl_axim_wstrb;
wire udl_axim_wlast;
wire udl_axim_wvalid;
wire udl_axim_wready;
wire [MAINAXI_UDL_M_AXI_ID_WIDTH-1:0] udl_axim_bid;
wire [1:0] udl_axim_bresp;
wire udl_axim_bvalid;
wire udl_axim_bready;
wire [MAINAXI_UDL_M_AXI_ID_WIDTH-1:0] udl_axim_arid;
wire [31:0] udl_axim_araddr;
wire [7:0] udl_axim_arlen;
wire [2:0] udl_axim_arsize;
wire [1:0] udl_axim_arburst;
wire udl_axim_arlock;
wire [3:0] udl_axim_arcache;
wire [2:0] udl_axim_arprot;
wire [3:0] udl_axim_arqos;
wire udl_axim_arvalid;
wire udl_axim_arready;
wire [MAINAXI_UDL_M_AXI_ID_WIDTH-1:0] udl_axim_rid;
wire [31:0] udl_axim_rdata;
wire [1:0] udl_axim_rresp;
wire udl_axim_rlast;
wire udl_axim_rvalid;
wire udl_axim_rready;

wire [MAINAXI_S_AXI_ID_WIDTH-1:0] udl_axis_awid;
wire [31:0] udl_axis_awaddr;
wire [7:0] udl_axis_awlen;
wire [2:0] udl_axis_awsize;
wire [1:0] udl_axis_awburst;
wire udl_axis_awlock;
wire [3:0] udl_axis_awcache;
wire [2:0] udl_axis_awprot;
wire [3:0] udl_axis_awregion;
wire [3:0] udl_axis_awqos;
wire udl_axis_awvalid;
wire udl_axis_awready;
wire [31:0] udl_axis_wdata;
wire [3:0] udl_axis_wstrb;
wire udl_axis_wlast;
wire udl_axis_wvalid;
wire udl_axis_wready;
wire [MAINAXI_S_AXI_ID_WIDTH-1:0] udl_axis_bid;
wire [1:0] udl_axis_bresp;
wire udl_axis_bvalid;
wire udl_axis_bready;
wire [MAINAXI_S_AXI_ID_WIDTH-1:0] udl_axis_arid;
wire [31:0] udl_axis_araddr;
wire [7:0] udl_axis_arlen;
wire [2:0] udl_axis_arsize;
wire [1:0] udl_axis_arburst;
wire udl_axis_arlock;
wire [3:0] udl_axis_arcache;
wire [2:0] udl_axis_arprot;
wire [3:0] udl_axis_arregion;
wire [3:0] udl_axis_arqos;
wire udl_axis_arvalid;
wire udl_axis_arready;
wire [MAINAXI_S_AXI_ID_WIDTH-1:0] udl_axis_rid;
wire [31:0] udl_axis_rdata;
wire [1:0] udl_axis_rresp;
wire udl_axis_rlast;
wire udl_axis_rvalid;
wire udl_axis_rready;

wire [CM3SS_UDL_ISR_NUM-1:0] udl_intisr;

wire jtagnsw;
wire swclktck;
wire swditms;
wire swdo;
wire swdoen;
wire swv;
wire ntrst;
wire tdi;
wire tdo;
wire ntdoen;

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
  .INIT_REQ(init_req),
  .INIT_DONE(init_done),
  .CLKMODE(clkmode),
  .CMC_REQ(cmc_req),
  .CMC_ACK(cmc_ack),
  .PLLLOCK(plllock),
  .SLEEPING(sleeping),
  .SLEEPHOLDREQN(sleepholdreqn),
  .SLEEPHOLDACKN(sleepholdackn),
  .SYS_RST_REQ(sys_rst_req),
  .REG_RST_REQ(reg_rst_req),
  .CPU_LOCKUP(cpu_lockup),
  .CPU_LOCKUP_RSTEN(cpu_lockup_rsten),
  .REF_CLK(ref_clk),
  .SYS_CLK(sys_clk),
  .MAXI_CLK(maxi_clk),
  .ULPI_REFCLK(/*open*/),
  .USER_CLK1(user_clk1),
  .USER_CLK2(user_clk2),
  .POR_RSTB(por_rstb),
  .POR_RSTB_SYNC_REFCLK(por_rstb_sync_refclk),
  .SYS_RSTB(sys_rstb),
  .SYS_RSTB_SYNC_REFCLK(sys_rstb_sync_refclk),
  .SYS_RSTB_SYNC_USERCLK1(sys_rstb_sync_userclk1),
  .SYS_RSTB_SYNC_USERCLK2(sys_rstb_sync_userclk2),
  .BUS_RSTB(bus_rstb)
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
  .REF_CLK(ref_clk),
  .SYS_CLK(sys_clk),
  .PLLLOCK(plllock),
  // Reset
  .SYS_RST_REQ(sys_rst_req),
  .REG_RST_REQ(reg_rst_req),
  .POR_RSTB(por_rstb),
  .POR_RSTB_SYNC_REFCLK(por_rstb_sync_refclk),
  .SYS_RSTB(sys_rstb),
  .SYS_RSTB_SYNC_REFCLK(sys_rstb_sync_refclk),
  .BUS_RSTB(bus_rstb),
  // Clock Mode Control
  .CLKMODE(clkmode),
  .CMC_REQ(cmc_req),
  .CMC_ACK(cmc_ack),
  // Logic Initilize Control Signals
  // ------------------------------
  .INIT_REQ(init_req),
  .INIT_DONE(init_done),
  // Cortex-M3 Signals
  // ------------------------------
  // Power Management Signals
  .SLEEPING(sleeping),
  .SLEEPHOLDREQN(sleepholdreqn),
  .SLEEPHOLDACKN(sleepholdackn),
  // Lockup monitor and control
  .CPU_LOCKUP(cpu_lockup),
  .CPU_LOCKUP_RSTEN(cpu_lockup_rsten),

  // UDL Master Interface
  // ------------------------------
  // Write Address Channel
  .UDL_AXIM_AWID(udl_axim_awid),
  .UDL_AXIM_AWADDR(udl_axim_awaddr),
  .UDL_AXIM_AWLEN(udl_axim_awlen),
  .UDL_AXIM_AWSIZE(udl_axim_awsize),
  .UDL_AXIM_AWBURST(udl_axim_awburst),
  .UDL_AXIM_AWLOCK(udl_axim_awlock),
  .UDL_AXIM_AWCACHE(udl_axim_awcache),
  .UDL_AXIM_AWPROT(udl_axim_awprot),
  .UDL_AXIM_AWQOS(udl_axim_awqos),
  .UDL_AXIM_AWVALID(udl_axim_awvalid),
  .UDL_AXIM_AWREADY(udl_axim_awready),
  // Write Data Channel
  .UDL_AXIM_WDATA(udl_axim_wdata),
  .UDL_AXIM_WSTRB(udl_axim_wstrb),
  .UDL_AXIM_WLAST(udl_axim_wlast),
  .UDL_AXIM_WVALID(udl_axim_wvalid),
  .UDL_AXIM_WREADY(udl_axim_wready),
  .UDL_AXIM_BID(udl_axim_bid),
  // Write Responce Channel
  .UDL_AXIM_BRESP(udl_axim_bresp),
  .UDL_AXIM_BVALID(udl_axim_bvalid),
  .UDL_AXIM_BREADY(udl_axim_bready),
  // Read Address Channel
  .UDL_AXIM_ARID(udl_axim_arid),
  .UDL_AXIM_ARADDR(udl_axim_araddr),
  .UDL_AXIM_ARLEN(udl_axim_arlen),
  .UDL_AXIM_ARSIZE(udl_axim_arsize),
  .UDL_AXIM_ARBURST(udl_axim_arburst),
  .UDL_AXIM_ARLOCK(udl_axim_arlock),
  .UDL_AXIM_ARCACHE(udl_axim_arcache),
  .UDL_AXIM_ARPROT(udl_axim_arprot),
  .UDL_AXIM_ARQOS(udl_axim_arqos),
  .UDL_AXIM_ARVALID(udl_axim_arvalid),
  .UDL_AXIM_ARREADY(udl_axim_arready),
  // Read Data Channel
  .UDL_AXIM_RID(udl_axim_rid),
  .UDL_AXIM_RDATA(udl_axim_rdata),
  .UDL_AXIM_RRESP(udl_axim_rresp),
  .UDL_AXIM_RLAST(udl_axim_rlast),
  .UDL_AXIM_RVALID(udl_axim_rvalid),
  .UDL_AXIM_RREADY(udl_axim_rready),

  // UDL Slave Interface
  // ------------------------------
  // Write Address Channel
  .UDL_AXIS_AWID(udl_axis_awid),
  .UDL_AXIS_AWADDR(udl_axis_awaddr),
  .UDL_AXIS_AWLEN(udl_axis_awlen),
  .UDL_AXIS_AWSIZE(udl_axis_awsize),
  .UDL_AXIS_AWBURST(udl_axis_awburst),
  .UDL_AXIS_AWLOCK(udl_axis_awlock),
  .UDL_AXIS_AWCACHE(udl_axis_awcache),
  .UDL_AXIS_AWPROT(udl_axis_awprot),
  .UDL_AXIS_AWREGION(udl_axis_awregion),
  .UDL_AXIS_AWQOS(udl_axis_awqos),
  .UDL_AXIS_AWVALID(udl_axis_awvalid),
  .UDL_AXIS_AWREADY(udl_axis_awready),
  // Write Data Channel
  .UDL_AXIS_WDATA(udl_axis_wdata),
  .UDL_AXIS_WSTRB(udl_axis_wstrb),
  .UDL_AXIS_WLAST(udl_axis_wlast),
  .UDL_AXIS_WVALID(udl_axis_wvalid),
  .UDL_AXIS_WREADY(udl_axis_wready),
  // Write Responce Channel
  .UDL_AXIS_BID(udl_axis_bid),
  .UDL_AXIS_BRESP(udl_axis_bresp),
  .UDL_AXIS_BVALID(udl_axis_bvalid),
  .UDL_AXIS_BREADY(udl_axis_bready),
  // Read Address Channel
  .UDL_AXIS_ARID(udl_axis_arid),
  .UDL_AXIS_ARADDR(udl_axis_araddr),
  .UDL_AXIS_ARLEN(udl_axis_arlen),
  .UDL_AXIS_ARSIZE(udl_axis_arsize),
  .UDL_AXIS_ARBURST(udl_axis_arburst),
  .UDL_AXIS_ARLOCK(udl_axis_arlock),
  .UDL_AXIS_ARCACHE(udl_axis_arcache),
  .UDL_AXIS_ARPROT(udl_axis_arprot),
  .UDL_AXIS_ARREGION(udl_axis_arregion),
  .UDL_AXIS_ARQOS(udl_axis_arqos),
  .UDL_AXIS_ARVALID(udl_axis_arvalid),
  .UDL_AXIS_ARREADY(udl_axis_arready),
  // Read Data Channel
  .UDL_AXIS_RID(udl_axis_rid),
  .UDL_AXIS_RDATA(udl_axis_rdata),
  .UDL_AXIS_RRESP(udl_axis_rresp),
  .UDL_AXIS_RLAST(udl_axis_rlast),
  .UDL_AXIS_RVALID(udl_axis_rvalid),
  .UDL_AXIS_RREADY(udl_axis_rready),
  .UDL_INTISR(udl_intisr),

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
  .JTAGNSW(jtagnsw),
  .SWCLKTCK(swclktck),
  .SWDITMS(swditms),
  .SWDO(swdo),
  .SWDOEN(swdoen),
  .SWV(swv),
  .NTRST(ntrst),
  .TDI(tdi),
  .TDO(tdo),
  .NTDOEN(ntdoen)
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
  .NTRST_OUT(ntrst),
  .TDI_OUT(tdi),
  .SWCLKTCK_OUT(swclktck),
  .SWDITMS_OUT(swditms),
  .SWDO_IN(swdo),
  .SWDOEN_IN(swdoen),
  .JTAGNSW_IN(jtagnsw),
  .TDO_IN(tdo),
  .SWV_IN(swv),
  .NTDOEN_IN(ntdoen)
);

// UDL(User Design Logic) AXI Bus
udl_axi # (
  .CM3SS_UDL_ISR_NUM(CM3SS_UDL_ISR_NUM),
  .MAINAXI_UDL_M_AXI_ID_WIDTH(MAINAXI_UDL_M_AXI_ID_WIDTH),
  .MAINAXI_S_AXI_ID_WIDTH(MAINAXI_S_AXI_ID_WIDTH)
) udl_axi (
  // System Interface
  .MAXI_CLK(maxi_clk),
  .REF_CLK(ref_clk),
  .USER_CLK1(user_clk1),
  .USER_CLK2(user_clk2),
  .SYS_RSTB(sys_rstb),
  .SYS_RSTB_SYNC_REFCLK(sys_rstb_sync_refclk),
  .SYS_RSTB_SYNC_USERCLK1(sys_rstb_sync_userclk1),
  .SYS_RSTB_SYNC_USERCLK2(sys_rstb_sync_userclk2),
  .POR_RSTB(por_rstb),
  .POR_RSTB_SYNC_REFCLK(por_rstb_sync_refclk),
  .BUS_RSTB(bus_rstb),

  .UDL_INTISR(udl_intisr),

  // UDL AXI4 Master Interface
  .UDL_AXIM_AWID(udl_axim_awid),
  .UDL_AXIM_AWADDR(udl_axim_awaddr),
  .UDL_AXIM_AWLEN(udl_axim_awlen),
  .UDL_AXIM_AWSIZE(udl_axim_awsize),
  .UDL_AXIM_AWBURST(udl_axim_awburst),
  .UDL_AXIM_AWLOCK(udl_axim_awlock),
  .UDL_AXIM_AWCACHE(udl_axim_awcache),
  .UDL_AXIM_AWPROT(udl_axim_awprot),
  .UDL_AXIM_AWQOS(udl_axim_awqos),
  .UDL_AXIM_AWVALID(udl_axim_awvalid),
  .UDL_AXIM_AWREADY(udl_axim_awready),
  .UDL_AXIM_WDATA(udl_axim_wdata),
  .UDL_AXIM_WSTRB(udl_axim_wstrb),
  .UDL_AXIM_WLAST(udl_axim_wlast),
  .UDL_AXIM_WVALID(udl_axim_wvalid),
  .UDL_AXIM_WREADY(udl_axim_wready),
  .UDL_AXIM_BID(udl_axim_bid),
  .UDL_AXIM_BRESP(udl_axim_bresp),
  .UDL_AXIM_BVALID(udl_axim_bvalid),
  .UDL_AXIM_BREADY(udl_axim_bready),
  .UDL_AXIM_ARID(udl_axim_arid),
  .UDL_AXIM_ARADDR(udl_axim_araddr),
  .UDL_AXIM_ARLEN(udl_axim_arlen),
  .UDL_AXIM_ARSIZE(udl_axim_arsize),
  .UDL_AXIM_ARBURST(udl_axim_arburst),
  .UDL_AXIM_ARLOCK(udl_axim_arlock),
  .UDL_AXIM_ARCACHE(udl_axim_arcache),
  .UDL_AXIM_ARPROT(udl_axim_arprot),
  .UDL_AXIM_ARQOS(udl_axim_arqos),
  .UDL_AXIM_ARVALID(udl_axim_arvalid),
  .UDL_AXIM_ARREADY(udl_axim_arready),
  .UDL_AXIM_RID(udl_axim_rid),
  .UDL_AXIM_RDATA(udl_axim_rdata),
  .UDL_AXIM_RRESP(udl_axim_rresp),
  .UDL_AXIM_RLAST(udl_axim_rlast),
  .UDL_AXIM_RVALID(udl_axim_rvalid),
  .UDL_AXIM_RREADY(udl_axim_rready),

  // UDL AXI4 Slave Interface
  .UDL_AXIS_AWID(udl_axis_awid),
  .UDL_AXIS_AWADDR(udl_axis_awaddr),
  .UDL_AXIS_AWLEN(udl_axis_awlen),
  .UDL_AXIS_AWSIZE(udl_axis_awsize),
  .UDL_AXIS_AWBURST(udl_axis_awburst),
  .UDL_AXIS_AWLOCK(udl_axis_awlock),
  .UDL_AXIS_AWCACHE(udl_axis_awcache),
  .UDL_AXIS_AWPROT(udl_axis_awprot),
  .UDL_AXIS_AWREGION(udl_axis_awregion),
  .UDL_AXIS_AWQOS(udl_axis_awqos),
  .UDL_AXIS_AWVALID(udl_axis_awvalid),
  .UDL_AXIS_AWREADY(udl_axis_awready),
  .UDL_AXIS_WDATA(udl_axis_wdata),
  .UDL_AXIS_WSTRB(udl_axis_wstrb),
  .UDL_AXIS_WLAST(udl_axis_wlast),
  .UDL_AXIS_WVALID(udl_axis_wvalid),
  .UDL_AXIS_WREADY(udl_axis_wready),
  .UDL_AXIS_BID(udl_axis_bid),
  .UDL_AXIS_BRESP(udl_axis_bresp),
  .UDL_AXIS_BVALID(udl_axis_bvalid),
  .UDL_AXIS_BREADY(udl_axis_bready),
  .UDL_AXIS_ARID(udl_axis_arid),
  .UDL_AXIS_ARADDR(udl_axis_araddr),
  .UDL_AXIS_ARLEN(udl_axis_arlen),
  .UDL_AXIS_ARSIZE(udl_axis_arsize),
  .UDL_AXIS_ARBURST(udl_axis_arburst),
  .UDL_AXIS_ARLOCK(udl_axis_arlock),
  .UDL_AXIS_ARCACHE(udl_axis_arcache),
  .UDL_AXIS_ARPROT(udl_axis_arprot),
  .UDL_AXIS_ARREGION(udl_axis_arregion),
  .UDL_AXIS_ARQOS(udl_axis_arqos),
  .UDL_AXIS_ARVALID(udl_axis_arvalid),
  .UDL_AXIS_ARREADY(udl_axis_arready),
  .UDL_AXIS_RID(udl_axis_rid),
  .UDL_AXIS_RDATA(udl_axis_rdata),
  .UDL_AXIS_RRESP(udl_axis_rresp),
  .UDL_AXIS_RLAST(udl_axis_rlast),
  .UDL_AXIS_RVALID(udl_axis_rvalid),
  .UDL_AXIS_RREADY(udl_axis_rready)

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
