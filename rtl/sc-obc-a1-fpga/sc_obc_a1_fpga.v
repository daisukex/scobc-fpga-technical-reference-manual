//-----------------------------------------------
// Space Cubics OBC A1
//  FPGA Top Module
// Module: sc_obc_a1_fpga
//-----------------------------------------------
// Copyright © 2022 Space Cubics, LLC.
//-----------------------------------------------
module sc_obc_a1_fpga # (
  parameter BUILD_INFO = 32'h00000000,
  parameter SYSCTRL_USER_CLK1_DIVIDE = 100,
  parameter SYSCTRL_USER_CLK1_MODE = 0,
  parameter SYSCTRL_USER_CLK2_DIVIDE = 100,
  parameter SYSCTRL_USER_CLK2_MODE = 0,
  parameter CM3SS_UDL_ISR_NUM = 16,
  parameter CM3SS_ITCM_SIZE_KB = 8,
  parameter CM3SS_ITCM_ADDR_BW = 13,
  parameter CM3SS_ITCM_INIT = "off",
  parameter CM3SS_ITCM_INIT_FILE = "code.hex",
  parameter MAINAXI_UDL_M_AXI_ID_WIDTH = 2,
  parameter MAINAXI_S_AXI_ID_WIDTH = 3
) (
  // System Interface
  input  SYSCLK1,
  output SYSCLK1_EN,
  input  SYSCLK2,
  output SYSCLK2_EN,

  // Debug Interface
  input  CM3_NTRST,
  input  CM3_TDI,
  input  CM3_TCK_SWCLK,
  inout  CM3_TMS_SWDIO,
  output CM3_TDO_SWO,

  // SRAM Interface
  inout  [19:0] SRAM_A,
  inout  SRAM1_CE_B,
  inout  SRAM1_OE_B,
  inout  SRAM1_WE_B,
  inout  SRAM1_BHE_B,
  inout  SRAM1_BLE_B,
  input  SRAM1_ERR,
  inout  [15:0] SRAM1_IO,
  inout  SRAM2_CE_B,
  inout  SRAM2_OE_B,
  inout  SRAM2_WE_B,
  inout  SRAM2_BHE_B,
  inout  SRAM2_BLE_B,
  input  SRAM2_ERR,
  inout  [15:0] SRAM2_IO,

  // CFG QSPI Flash Interface
  output CFG_MEM_SEL,
  input  CFG_MEM_MON,
  inout  CFG_MEM_CS_B,
  inout  [3:0] CFG_MEM_IO,

  // Data QSPI Flash Interface
  inout  DATA_MEM1_CS_B,
  output DATA_MEM1_SCK,
  inout  [3:0] DATA_MEM1_IO,
  inout  DATA_MEM2_CS_B,
  output DATA_MEM2_SCK,
  inout  [3:0] DATA_MEM2_IO,

  // FRAM Interface
  inout  FRAM1_CS_B,
  output FRAM1_SCK,
  inout  [3:0] FRAM1_IO,
  inout  FRAM2_CS_B,
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
  inout  FPGA_WATCHDOG,
  inout  FPGA_RESERVE,
  inout  FPGA_PWR_CYCLE_REQ,

  // ULPI Interface
  inout ULPI_CS,
  input ULPI_CLOCK,
  inout ULPI_RESET_B,
  input ULPI_DIR,
  input ULPI_NXT,
  output ULPI_STP,
  inout [7:0] ULPI_DATA,
  output ULPI_REFCLK,

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
wire [1:0] osc_clken;
assign SYSCLK1_EN = 1'b1;
assign SYSCLK2_EN = 1'b1;

wire boot_rstb;
wire por_rstb;
wire por_rstb_sync_refclk;
wire sys_rstb;
wire g_sys_rstb;
wire sys_rstb_sync_refclk;
wire sys_rstb_sync_userclk1;
wire sys_rstb_sync_userclk2;
wire bus_rstb;

wire cfg_mem_sck;

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

wire [19:0] w_sram_a;
wire w_sram1_ce_b;
wire w_sram1_oe_b;
wire w_sram1_we_b;
wire w_sram1_bhe_b;
wire w_sram1_ble_b;
wire w_sram2_ce_b;
wire w_sram2_oe_b;
wire w_sram2_we_b;
wire w_sram2_bhe_b;
wire w_sram2_ble_b;

wire w_cfg_mem_cs_b;
wire [3:0] w_cfg_mem_oe;
wire [3:0] w_cfg_mem_dout;
wire [3:0] w_cfg_mem_din;
wire w_data_mem1_cs_b;
wire [3:0] w_data_mem1_oe;
wire [3:0] w_data_mem1_dout;
wire [3:0] w_data_mem1_din;
wire w_data_mem2_cs_b;
wire [3:0] w_data_mem2_oe;
wire [3:0] w_data_mem2_dout;
wire [3:0] w_data_mem2_din;
wire w_fram1_cs_b;
wire [3:0] w_fram1_oe;
wire [3:0] w_fram1_dout;
wire [3:0] w_fram1_din;
wire w_fram2_cs_b;
wire [3:0] w_fram2_oe;
wire [3:0] w_fram2_dout;
wire [3:0] w_fram2_din;

wire w_fpga_watchdog;
wire w_fpga_pwr_cycle_req;

wire [2*20-1:0] sram_a_gpio_mode_sel;
wire [1:0] sram1_ce_b_gpio_mode_sel;
wire [1:0] sram1_oe_b_gpio_mode_sel;
wire [1:0] sram1_we_b_gpio_mode_sel;
wire [1:0] sram1_bhe_b_gpio_mode_sel;
wire [1:0] sram1_ble_b_gpio_mode_sel;
wire [1:0] sram2_ce_b_gpio_mode_sel;
wire [1:0] sram2_oe_b_gpio_mode_sel;
wire [1:0] sram2_we_b_gpio_mode_sel;
wire [1:0] sram2_bhe_b_gpio_mode_sel;
wire [1:0] sram2_ble_b_gpio_mode_sel;
wire [19:0] sram_a_gpio_in;
wire sram1_ce_b_gpio_in;
wire sram1_oe_b_gpio_in;
wire sram1_we_b_gpio_in;
wire sram1_bhe_b_gpio_in;
wire sram1_ble_b_gpio_in;
wire sram2_ce_b_gpio_in;
wire sram2_oe_b_gpio_in;
wire sram2_we_b_gpio_in;
wire sram2_bhe_b_gpio_in;
wire sram2_ble_b_gpio_in;

wire [1:0] cfg_mem_cs_b_gpio_mode_sel;
wire [2*4-1:0] cfg_mem_io_gpio_mode_sel;
wire cfg_mem_cs_b_gpio_in;
wire [3:0] cfg_mem_io_gpio_in;

wire [1:0] data_mem1_cs_b_gpio_mode_sel;
wire [2*4-1:0] data_mem1_io_gpio_mode_sel;
wire [1:0] data_mem2_cs_b_gpio_mode_sel;
wire [2*4-1:0] data_mem2_io_gpio_mode_sel;
wire data_mem1_cs_b_gpio_in;
wire [3:0] data_mem1_io_gpio_in;
wire data_mem2_cs_b_gpio_in;
wire [3:0] data_mem2_io_gpio_in;

wire [1:0] fram1_cs_b_gpio_mode_sel;
wire [2*4-1:0] fram1_io_gpio_mode_sel;
wire [1:0] fram2_cs_b_gpio_mode_sel;
wire [2*4-1:0] fram2_io_gpio_mode_sel;
wire fram1_cs_b_gpio_in;
wire [3:0] fram1_io_gpio_in;
wire fram2_cs_b_gpio_in;
wire [3:0] fram2_io_gpio_in;

wire sysclk2_state;
wire sysclk1_state;

wire [1:0] ext_i2c_scl_gpio_mode_sel;
wire [1:0] ext_i2c_sda_gpio_mode_sel;
wire ext_i2c_scl_gpio_in;
wire ext_i2c_sda_gpio_in;

wire [31:0] fpga_boot_shiftreg_in;
wire [1:0] fpga_watchdog_gpio_mode_sel;
wire [1:0] fpga_pwr_cycle_req_gpio_mode_sel;
wire [1:0] fpga_reserve_gpio_mode_sel;
wire fpga_watchdog_gpio_in;
wire fpga_pwr_cycle_req_gpio_in;
wire fpga_reserve_gpio_in;

wire ulpi_clock_state;
wire [1:0] ulpi_reset_b_gpio_mode_sel;
wire [1:0] ulpi_cs_gpio_mode_sel;
wire ulpi_reset_b_gpio_in;
wire ulpi_cs_gpio_in;

wire [2*16-1:0] uio1_gpio_mode_sel;
wire [15:0] uio1_gpio_in;

wire [2*16-1:0] uio2_gpio_mode_sel;
wire [15:0] uio2_gpio_in;

wire [2*6-1:0] uio4_gpio_mode_sel;
wire [5:0] uio4_gpio_in;

wire [2*16-1:0] rsv_gpio_mode_sel;
wire [15:0] rsv_gpio_in;

// System Controller
scobca1_sysctrl # (
  .SYSCTRL_USER_CLK1_DIVIDE(SYSCTRL_USER_CLK1_DIVIDE),
  .SYSCTRL_USER_CLK1_MODE(SYSCTRL_USER_CLK1_MODE),
  .SYSCTRL_USER_CLK2_DIVIDE(SYSCTRL_USER_CLK2_DIVIDE),
  .SYSCTRL_USER_CLK2_MODE(SYSCTRL_USER_CLK2_MODE)
) sysctrl (
  .SYSCLK1(SYSCLK1),
  .SYSCLK1_EN(osc_clken[0]),
  .SYSCLK2(SYSCLK2),
  .SYSCLK2_EN(osc_clken[1]),
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
  .ULPI_REFCLK(ULPI_REFCLK),
  .USER_CLK1(user_clk1),
  .USER_CLK2(user_clk2),
  .BOOT_RSTB(boot_rstb),
  .POR_RSTB(por_rstb),
  .POR_RSTB_SYNC_REFCLK(por_rstb_sync_refclk),
  .SYS_RSTB(sys_rstb),
  .SYS_RSTB_SYNC_REFCLK(sys_rstb_sync_refclk),
  .SYS_RSTB_SYNC_USERCLK1(sys_rstb_sync_userclk1),
  .SYS_RSTB_SYNC_USERCLK2(sys_rstb_sync_userclk2),
  .BUS_RSTB(bus_rstb)
);
BUFG bufg_sys_rstb (.I(sys_rstb), .O(g_sys_rstb));

// OBC Core TOP
sc_obc_core # (
  .BUILD_INFO(BUILD_INFO),
  .CM3SS_UDL_ISR_NUM(CM3SS_UDL_ISR_NUM),
  .CM3SS_ITCM_SIZE_KB(CM3SS_ITCM_SIZE_KB),
  .CM3SS_ITCM_ADDR_BW(CM3SS_ITCM_ADDR_BW),
  .CM3SS_ITCM_INIT(CM3SS_ITCM_INIT),
  .CM3SS_ITCM_INIT_FILE(CM3SS_ITCM_INIT_FILE),
  .MAINAXI_UDL_M_AXI_ID_WIDTH(MAINAXI_UDL_M_AXI_ID_WIDTH),
  .MAINAXI_S_AXI_ID_WIDTH(MAINAXI_S_AXI_ID_WIDTH)
) obc_core (
  // Clock/Reset Signals
  // ------------------------------
  // Clock
  .REF_CLK(ref_clk),
  .SYS_CLK(sys_clk),
  .MAXI_CLK(maxi_clk),
  .ULPI_REFCLK(ULPI_REFCLK),
  .USER_CLK1(user_clk1),
  .USER_CLK2(user_clk2),
  .PLLLOCK(plllock),
  .OSC_CLKEN(osc_clken),
  // Reset
  .SYS_RST_REQ(sys_rst_req),
  .REG_RST_REQ(reg_rst_req),
  .BOOT_RSTB(boot_rstb),
  .POR_RSTB(por_rstb),
  .POR_RSTB_SYNC_REFCLK(por_rstb_sync_refclk),
  .SYS_RSTB(g_sys_rstb),
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

  // TRCH/Board System Interface
  // ------------------------------
  .CDRST_B(1'b0),
  .FPGA_BOOT({FPGA_BOOT1,FPGA_BOOT0}),
  .FPGA_WATCHDOG(w_fpga_watchdog),
  .FPGA_RESERVE(/*open*/),
  .FPGA_PWR_CYCLE_REQ(w_fpga_pwr_cycle_req),

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

  // SRAM Interface
  // ------------------------------
  .SRAM_A(w_sram_a),
  .SRAM1_CE_B(w_sram1_ce_b),
  .SRAM1_OE_B(w_sram1_oe_b),
  .SRAM1_WE_B(w_sram1_we_b),
  .SRAM1_BHE_B(w_sram1_bhe_b),
  .SRAM1_BLE_B(w_sram1_ble_b),
  .SRAM1_ERR(SRAM1_ERR),
  .SRAM1_IO(SRAM1_IO),
  .SRAM2_CE_B(w_sram2_ce_b),
  .SRAM2_OE_B(w_sram2_oe_b),
  .SRAM2_WE_B(w_sram2_we_b),
  .SRAM2_BHE_B(w_sram2_bhe_b),
  .SRAM2_BLE_B(w_sram2_ble_b),
  .SRAM2_ERR(SRAM2_ERR),
  .SRAM2_IO(SRAM2_IO),

  // NOR Flash Configuration Memory Interface
  // ------------------------------
  .CFG_MEM_SEL(CFG_MEM_SEL),
  .CFG_MEM_MON(CFG_MEM_MON),
  .CFG_MEM_SCK(cfg_mem_sck),
  .CFG_MEM_CS_B(w_cfg_mem_cs_b),
  .CFG_MEM_OE(w_cfg_mem_oe),
  .CFG_MEM_DOUT(w_cfg_mem_dout),
  .CFG_MEM_DIN(w_cfg_mem_din),

  // NOR Flash Data Memory Interface
  // ------------------------------
  .DATA_MEM1_SCK(DATA_MEM1_SCK),
  .DATA_MEM1_CS_B(w_data_mem1_cs_b),
  .DATA_MEM1_OE(w_data_mem1_oe),
  .DATA_MEM1_DOUT(w_data_mem1_dout),
  .DATA_MEM1_DIN(w_data_mem1_din),
  .DATA_MEM2_SCK(DATA_MEM2_SCK),
  .DATA_MEM2_CS_B(w_data_mem2_cs_b),
  .DATA_MEM2_OE(w_data_mem2_oe),
  .DATA_MEM2_DOUT(w_data_mem2_dout),
  .DATA_MEM2_DIN(w_data_mem2_din),

  // FeRAM Data Memory Interface
  // ------------------------------
  .FRAM1_SCK(FRAM1_SCK),
  .FRAM1_CS_B(w_fram1_cs_b),
  .FRAM1_OE(w_fram1_oe),
  .FRAM1_DOUT(w_fram1_dout),
  .FRAM1_DIN(w_fram1_din),
  .FRAM2_SCK(FRAM2_SCK),
  .FRAM2_CS_B(w_fram2_cs_b),
  .FRAM2_OE(w_fram2_oe),
  .FRAM2_DOUT(w_fram2_dout),
  .FRAM2_DIN(w_fram2_din),

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
  .CVM_CRITICAL_B(CVM_CRITICAL_B),
  .CVM_WARNING_B(CVM_WARNING_B),
  .TEMP_ALERT_B(TEMP_ALERT_B),

  // External I2C Interface
  // ------------------------------
  .EXTERNAL_I2CM_SDA(/*open*/),
  .EXTERNAL_I2CM_SCL(/*open*/),

  // ULPI Interface
  // ------------------------------
  .ULPI_CS(/*open*/),
  .ULPI_CLOCK(1'b0),
  .ULPI_RESET_B(/*open*/),
  .ULPI_DIR(ULPI_DIR),
  .ULPI_NXT(ULPI_NXT),
  .ULPI_STP(ULPI_STP),
  .ULPI_DATA(ULPI_DATA),

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
  .NTDOEN(ntdoen),

  // Debug Register Interface
  // ------------------------------
  .SRAM_A_GPIO_MODE_SEL(sram_a_gpio_mode_sel),
  .SRAM1_CE_B_GPIO_MODE_SEL(sram1_ce_b_gpio_mode_sel),
  .SRAM1_OE_B_GPIO_MODE_SEL(sram1_oe_b_gpio_mode_sel),
  .SRAM1_WE_B_GPIO_MODE_SEL(sram1_we_b_gpio_mode_sel),
  .SRAM1_BHE_B_GPIO_MODE_SEL(sram1_bhe_b_gpio_mode_sel),
  .SRAM1_BLE_B_GPIO_MODE_SEL(sram1_ble_b_gpio_mode_sel),
  .SRAM2_CE_B_GPIO_MODE_SEL(sram2_ce_b_gpio_mode_sel),
  .SRAM2_OE_B_GPIO_MODE_SEL(sram2_oe_b_gpio_mode_sel),
  .SRAM2_WE_B_GPIO_MODE_SEL(sram2_we_b_gpio_mode_sel),
  .SRAM2_BHE_B_GPIO_MODE_SEL(sram2_bhe_b_gpio_mode_sel),
  .SRAM2_BLE_B_GPIO_MODE_SEL(sram2_ble_b_gpio_mode_sel),
  .SRAM_A_GPIO_IN(sram_a_gpio_in),
  .SRAM1_CE_B_GPIO_IN(sram1_ce_b_gpio_in),
  .SRAM1_OE_B_GPIO_IN(sram1_oe_b_gpio_in),
  .SRAM1_WE_B_GPIO_IN(sram1_we_b_gpio_in),
  .SRAM1_BHE_B_GPIO_IN(sram1_bhe_b_gpio_in),
  .SRAM1_BLE_B_GPIO_IN(sram1_ble_b_gpio_in),
  .SRAM2_CE_B_GPIO_IN(sram2_ce_b_gpio_in),
  .SRAM2_OE_B_GPIO_IN(sram2_oe_b_gpio_in),
  .SRAM2_WE_B_GPIO_IN(sram2_we_b_gpio_in),
  .SRAM2_BHE_B_GPIO_IN(sram2_bhe_b_gpio_in),
  .SRAM2_BLE_B_GPIO_IN(sram2_ble_b_gpio_in),

  .CFG_MEM_CS_B_GPIO_MODE_SEL(cfg_mem_cs_b_gpio_mode_sel),
  .CFG_MEM_IO_GPIO_MODE_SEL(cfg_mem_io_gpio_mode_sel),
  .CFG_MEM_CS_B_GPIO_IN(cfg_mem_cs_b_gpio_in),
  .CFG_MEM_IO_GPIO_IN(cfg_mem_io_gpio_in),

  .DATA_MEM1_CS_B_GPIO_MODE_SEL(data_mem1_cs_b_gpio_mode_sel),
  .DATA_MEM1_IO_GPIO_MODE_SEL(data_mem1_io_gpio_mode_sel),
  .DATA_MEM2_CS_B_GPIO_MODE_SEL(data_mem2_cs_b_gpio_mode_sel),
  .DATA_MEM2_IO_GPIO_MODE_SEL(data_mem2_io_gpio_mode_sel),
  .DATA_MEM1_CS_B_GPIO_IN(data_mem1_cs_b_gpio_in),
  .DATA_MEM1_IO_GPIO_IN(data_mem1_io_gpio_in),
  .DATA_MEM2_CS_B_GPIO_IN(data_mem2_cs_b_gpio_in),
  .DATA_MEM2_IO_GPIO_IN(data_mem2_io_gpio_in),

  .FRAM1_CS_B_GPIO_MODE_SEL(fram1_cs_b_gpio_mode_sel),
  .FRAM1_IO_GPIO_MODE_SEL(fram1_io_gpio_mode_sel),
  .FRAM2_CS_B_GPIO_MODE_SEL(fram2_cs_b_gpio_mode_sel),
  .FRAM2_IO_GPIO_MODE_SEL(fram2_io_gpio_mode_sel),
  .FRAM1_CS_B_GPIO_IN(fram1_cs_b_gpio_in),
  .FRAM1_IO_GPIO_IN(fram1_io_gpio_in),
  .FRAM2_CS_B_GPIO_IN(fram2_cs_b_gpio_in),
  .FRAM2_IO_GPIO_IN(fram2_io_gpio_in),

  .SYSCLK2_STATE(sysclk2_state),
  .SYSCLK1_STATE(sysclk1_state),

  .EXT_I2C_SCL_GPIO_MODE_SEL(ext_i2c_scl_gpio_mode_sel),
  .EXT_I2C_SDA_GPIO_MODE_SEL(ext_i2c_sda_gpio_mode_sel),
  .EXT_I2C_SCL_GPIO_IN(ext_i2c_scl_gpio_in),
  .EXT_I2C_SDA_GPIO_IN(ext_i2c_sda_gpio_in),

  .FPGA_BOOT_SHIFTREG_IN(fpga_boot_shiftreg_in),
  .FPGA_WATCHDOG_GPIO_MODE_SEL(fpga_watchdog_gpio_mode_sel),
  .FPGA_PWR_CYCLE_REQ_GPIO_MODE_SEL(fpga_pwr_cycle_req_gpio_mode_sel),
  .FPGA_RESERVE_GPIO_MODE_SEL(fpga_reserve_gpio_mode_sel),
  .FPGA_WATCHDOG_GPIO_IN(fpga_watchdog_gpio_in),
  .FPGA_PWR_CYCLE_REQ_GPIO_IN(fpga_pwr_cycle_req_gpio_in),
  .FPGA_RESERVE_GPIO_IN(fpga_reserve_gpio_in),

  .ULPI_CLOCK_STATE(ulpi_clock_state),
  .ULPI_RESET_B_GPIO_MODE_SEL(ulpi_reset_b_gpio_mode_sel),
  .ULPI_CS_GPIO_MODE_SEL(ulpi_cs_gpio_mode_sel),
  .ULPI_RESET_B_GPIO_IN(ulpi_reset_b_gpio_in),
  .ULPI_CS_GPIO_IN(ulpi_cs_gpio_in),

  .UIO1_GPIO_MODE_SEL(uio1_gpio_mode_sel),
  .UIO1_GPIO_IN(uio1_gpio_in),

  .UIO2_GPIO_MODE_SEL(uio2_gpio_mode_sel),
  .UIO2_GPIO_IN(uio2_gpio_in),

  .UIO4_GPIO_MODE_SEL(uio4_gpio_mode_sel),
  .UIO4_GPIO_IN(uio4_gpio_in),

  .RSV_GPIO_MODE_SEL(rsv_gpio_mode_sel),
  .RSV_GPIO_IN(rsv_gpio_in)
);

STARTUPE2 startupe2 (
  .CLK(1'b0),
  .GSR(1'b0),
  .GTS(1'b0),
  .KEYCLEARB(1'b0),
  .PACK(1'b0),
  .PREQ(/*open*/),
  .USRCCLKO(cfg_mem_sck),
  .USRCCLKTS(1'b0),
  .USRDONEO(1'b1),
  .USRDONETS(1'b0),
  .CFGCLK(/*open*/),
  .CFGMCLK(/*open*/),
  .EOS(/*open*/)
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
  .SYS_RSTB(g_sys_rstb),
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



// Debug Controller Core
scobca1_dbgctrl_core dbgctrl_core (
  // System Interface
  .SYS_CLK(sys_clk),
  .SYS_RSTB(g_sys_rstb),

  // FPGA Interface
  .SRAM_A(SRAM_A),
  .SRAM1_CE_B(SRAM1_CE_B),
  .SRAM1_OE_B(SRAM1_OE_B),
  .SRAM1_WE_B(SRAM1_WE_B),
  .SRAM1_BHE_B(SRAM1_BHE_B),
  .SRAM1_BLE_B(SRAM1_BLE_B),
  .SRAM2_CE_B(SRAM2_CE_B),
  .SRAM2_OE_B(SRAM2_OE_B),
  .SRAM2_WE_B(SRAM2_WE_B),
  .SRAM2_BHE_B(SRAM2_BHE_B),
  .SRAM2_BLE_B(SRAM2_BLE_B),

  .CFG_MEM_CS_B(CFG_MEM_CS_B),
  .CFG_MEM_IO(CFG_MEM_IO),

  .DATA_MEM1_CS_B(DATA_MEM1_CS_B),
  .DATA_MEM1_IO(DATA_MEM1_IO),

  .DATA_MEM2_CS_B(DATA_MEM2_CS_B),
  .DATA_MEM2_IO(DATA_MEM2_IO),

  .FRAM1_CS_B(FRAM1_CS_B),
  .FRAM1_IO(FRAM1_IO),

  .FRAM2_CS_B(FRAM2_CS_B),
  .FRAM2_IO(FRAM2_IO),

  .SYSCLK1(SYSCLK1),
  .SYSCLK2(SYSCLK2),

  .FPGA_EXT_SCL(FPGA_EXT_SCL),
  .FPGA_EXT_SDA(FPGA_EXT_SDA),

  .FPGA_BOOT0(FPGA_BOOT0),
  .FPGA_BOOT1(FPGA_BOOT1),
  .FPGA_WATCHDOG(FPGA_WATCHDOG),
  .FPGA_RESERVE(FPGA_RESERVE),
  .FPGA_PWR_CYCLE_REQ(FPGA_PWR_CYCLE_REQ),

  .ULPI_CLOCK(ULPI_CLOCK),
  .ULPI_RESET_B(ULPI_RESET_B),
  .ULPI_CS(ULPI_CS),

  .UIO1(/*open*/),
  .UIO2(/*open*/),
  .UIO4(/*open*/),

  .RSV(/*open*/),

  // IP Interface
  .SRAM_A_IPOUT(w_sram_a),
  .SRAM1_CE_B_IPOUT(w_sram1_ce_b),
  .SRAM1_OE_B_IPOUT(w_sram1_oe_b),
  .SRAM1_WE_B_IPOUT(w_sram1_we_b),
  .SRAM1_BHE_B_IPOUT(w_sram1_bhe_b),
  .SRAM1_BLE_B_IPOUT(w_sram1_ble_b),
  .SRAM2_CE_B_IPOUT(w_sram2_ce_b),
  .SRAM2_OE_B_IPOUT(w_sram2_oe_b),
  .SRAM2_WE_B_IPOUT(w_sram2_we_b),
  .SRAM2_BHE_B_IPOUT(w_sram2_bhe_b),
  .SRAM2_BLE_B_IPOUT(w_sram2_ble_b),

  .CFG_MEM_CS_B_IPOUT(w_cfg_mem_cs_b),
  .CFG_MEM_OE_IPOUT(w_cfg_mem_oe),
  .CFG_MEM_DOUT_IPOUT(w_cfg_mem_dout),
  .CFG_MEM_DIN_IPIN(w_cfg_mem_din),

  .DATA_MEM1_CS_B_IPOUT(w_data_mem1_cs_b),
  .DATA_MEM1_OE_IPOUT(w_data_mem1_oe),
  .DATA_MEM1_DOUT_IPOUT(w_data_mem1_dout),
  .DATA_MEM1_DIN_IPIN(w_data_mem1_din),

  .DATA_MEM2_CS_B_IPOUT(w_data_mem2_cs_b),
  .DATA_MEM2_OE_IPOUT(w_data_mem2_oe),
  .DATA_MEM2_DOUT_IPOUT(w_data_mem2_dout),
  .DATA_MEM2_DIN_IPIN(w_data_mem2_din),

  .FRAM1_CS_B_IPOUT(w_fram1_cs_b),
  .FRAM1_OE_IPOUT(w_fram1_oe),
  .FRAM1_DOUT_IPOUT(w_fram1_dout),
  .FRAM1_DIN_IPIN(w_fram1_din),

  .FRAM2_CS_B_IPOUT(w_fram2_cs_b),
  .FRAM2_OE_IPOUT(w_fram2_oe),
  .FRAM2_DOUT_IPOUT(w_fram2_dout),
  .FRAM2_DIN_IPIN(w_fram2_din),

  .FPGA_WATCHDOG_IPOUT(w_fpga_watchdog),
  .FPGA_PWR_CYCLE_REQ_IPOUT(w_fpga_pwr_cycle_req),

  .RSV_IPOUT(16'h0),
  .RSV_IPIN(/*open*/),

  // Debug Register Interface
  .SRAM_A_GPIO_MODE_SEL(sram_a_gpio_mode_sel),
  .SRAM1_CE_B_GPIO_MODE_SEL(sram1_ce_b_gpio_mode_sel),
  .SRAM1_OE_B_GPIO_MODE_SEL(sram1_oe_b_gpio_mode_sel),
  .SRAM1_WE_B_GPIO_MODE_SEL(sram1_we_b_gpio_mode_sel),
  .SRAM1_BHE_B_GPIO_MODE_SEL(sram1_bhe_b_gpio_mode_sel),
  .SRAM1_BLE_B_GPIO_MODE_SEL(sram1_ble_b_gpio_mode_sel),
  .SRAM2_CE_B_GPIO_MODE_SEL(sram2_ce_b_gpio_mode_sel),
  .SRAM2_OE_B_GPIO_MODE_SEL(sram2_oe_b_gpio_mode_sel),
  .SRAM2_WE_B_GPIO_MODE_SEL(sram2_we_b_gpio_mode_sel),
  .SRAM2_BHE_B_GPIO_MODE_SEL(sram2_bhe_b_gpio_mode_sel),
  .SRAM2_BLE_B_GPIO_MODE_SEL(sram2_ble_b_gpio_mode_sel),
  .SRAM_A_GPIO_IN(sram_a_gpio_in),
  .SRAM1_CE_B_GPIO_IN(sram1_ce_b_gpio_in),
  .SRAM1_OE_B_GPIO_IN(sram1_oe_b_gpio_in),
  .SRAM1_WE_B_GPIO_IN(sram1_we_b_gpio_in),
  .SRAM1_BHE_B_GPIO_IN(sram1_bhe_b_gpio_in),
  .SRAM1_BLE_B_GPIO_IN(sram1_ble_b_gpio_in),
  .SRAM2_CE_B_GPIO_IN(sram2_ce_b_gpio_in),
  .SRAM2_OE_B_GPIO_IN(sram2_oe_b_gpio_in),
  .SRAM2_WE_B_GPIO_IN(sram2_we_b_gpio_in),
  .SRAM2_BHE_B_GPIO_IN(sram2_bhe_b_gpio_in),
  .SRAM2_BLE_B_GPIO_IN(sram2_ble_b_gpio_in),

  .CFG_MEM_CS_B_GPIO_MODE_SEL(cfg_mem_cs_b_gpio_mode_sel),
  .CFG_MEM_IO_GPIO_MODE_SEL(cfg_mem_io_gpio_mode_sel),
  .CFG_MEM_CS_B_GPIO_IN(cfg_mem_cs_b_gpio_in),
  .CFG_MEM_IO_GPIO_IN(cfg_mem_io_gpio_in),

  .DATA_MEM1_CS_B_GPIO_MODE_SEL(data_mem1_cs_b_gpio_mode_sel),
  .DATA_MEM1_IO_GPIO_MODE_SEL(data_mem1_io_gpio_mode_sel),
  .DATA_MEM2_CS_B_GPIO_MODE_SEL(data_mem2_cs_b_gpio_mode_sel),
  .DATA_MEM2_IO_GPIO_MODE_SEL(data_mem2_io_gpio_mode_sel),
  .DATA_MEM1_CS_B_GPIO_IN(data_mem1_cs_b_gpio_in),
  .DATA_MEM1_IO_GPIO_IN(data_mem1_io_gpio_in),
  .DATA_MEM2_CS_B_GPIO_IN(data_mem2_cs_b_gpio_in),
  .DATA_MEM2_IO_GPIO_IN(data_mem2_io_gpio_in),

  .FRAM1_CS_B_GPIO_MODE_SEL(fram1_cs_b_gpio_mode_sel),
  .FRAM1_IO_GPIO_MODE_SEL(fram1_io_gpio_mode_sel),
  .FRAM2_CS_B_GPIO_MODE_SEL(fram2_cs_b_gpio_mode_sel),
  .FRAM2_IO_GPIO_MODE_SEL(fram2_io_gpio_mode_sel),
  .FRAM1_CS_B_GPIO_IN(fram1_cs_b_gpio_in),
  .FRAM1_IO_GPIO_IN(fram1_io_gpio_in),
  .FRAM2_CS_B_GPIO_IN(fram2_cs_b_gpio_in),
  .FRAM2_IO_GPIO_IN(fram2_io_gpio_in),

  .SYSCLK2_STATE(sysclk2_state),
  .SYSCLK1_STATE(sysclk1_state),

  .EXT_I2C_SCL_GPIO_MODE_SEL(ext_i2c_scl_gpio_mode_sel),
  .EXT_I2C_SDA_GPIO_MODE_SEL(ext_i2c_sda_gpio_mode_sel),
  .EXT_I2C_SCL_GPIO_IN(ext_i2c_scl_gpio_in),
  .EXT_I2C_SDA_GPIO_IN(ext_i2c_sda_gpio_in),

  .FPGA_BOOT_SHIFTREG_IN(fpga_boot_shiftreg_in),
  .FPGA_WATCHDOG_GPIO_MODE_SEL(fpga_watchdog_gpio_mode_sel),
  .FPGA_PWR_CYCLE_REQ_GPIO_MODE_SEL(fpga_pwr_cycle_req_gpio_mode_sel),
  .FPGA_RESERVE_GPIO_MODE_SEL(fpga_reserve_gpio_mode_sel),
  .FPGA_WATCHDOG_GPIO_IN(fpga_watchdog_gpio_in),
  .FPGA_PWR_CYCLE_REQ_GPIO_IN(fpga_pwr_cycle_req_gpio_in),
  .FPGA_RESERVE_GPIO_IN(fpga_reserve_gpio_in),

  .ULPI_CLOCK_STATE(ulpi_clock_state),
  .ULPI_RESET_B_GPIO_MODE_SEL(ulpi_reset_b_gpio_mode_sel),
  .ULPI_CS_GPIO_MODE_SEL(ulpi_cs_gpio_mode_sel),
  .ULPI_RESET_B_GPIO_IN(ulpi_reset_b_gpio_in),
  .ULPI_CS_GPIO_IN(ulpi_cs_gpio_in),

  .UIO1_GPIO_MODE_SEL(uio1_gpio_mode_sel),
  .UIO1_GPIO_IN(uio1_gpio_in),

  .UIO2_GPIO_MODE_SEL(uio2_gpio_mode_sel),
  .UIO2_GPIO_IN(uio2_gpio_in),

  .UIO4_GPIO_MODE_SEL(uio4_gpio_mode_sel),
  .UIO4_GPIO_IN(uio4_gpio_in),

  .RSV_GPIO_MODE_SEL(rsv_gpio_mode_sel),
  .RSV_GPIO_IN(rsv_gpio_in)
);

endmodule
