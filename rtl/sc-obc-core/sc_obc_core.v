//-----------------------------------------------
// Space Cubics OBC Core
//  Space Cubics CORE TOP
//  Module: sc_obc_core
//-----------------------------------------------
// Copyright © 2022 Space Cubics, LLC.
//-----------------------------------------------

module sc_obc_core # (
  parameter BUILD_INFO = 32'h00000000,
  parameter CM3SS_UDL_ISR_NUM = 16,
  parameter CM3SS_ITCM_SIZE_KB = 128,
  parameter CM3SS_ITCM_ADDR_BW = 17,
  parameter CM3SS_ITCM_INIT = "off",
  parameter CM3SS_ITCM_INIT_FILE = "code.hex",
  parameter MAINAXI_UDL_M_AXI_ID_WIDTH = 2,
  parameter MAINAXI_S_AXI_ID_WIDTH = 3
) (
  // Clock/Reset Signals
  // ------------------------------
  // Clock
  input REF_CLK,
  input SYS_CLK,
  input MAXI_CLK,
  input ULPI_REFCLK,
  input USER_CLK1,
  input USER_CLK2,
  input PLLLOCK,
  input [1:0] OSC_CLKEN,
  // Reset
  output SYS_RST_REQ,
  output REG_RST_REQ,
  input BOOT_RSTB,
  input POR_RSTB,
  input POR_RSTB_SYNC_REFCLK,
  input SYS_RSTB,
  input SYS_RSTB_SYNC_REFCLK,
  input BUS_RSTB,
  // Clock Mode Control
  output [1:0] CLKMODE,
  output CMC_REQ,
  input CMC_ACK,

  // Logic Initilize Control Signals
  // ------------------------------
  input INIT_REQ,
  output INIT_DONE,

  // Cortex-M3 Signals
  // ------------------------------
  // Power Management Signals
  output SLEEPING,
  input SLEEPHOLDREQN,
  output SLEEPHOLDACKN,
  // Lockup monitor and control
  output CPU_LOCKUP,
  output CPU_LOCKUP_RSTEN,

  // TRCH/Board System Interface
  // ------------------------------
  input [1:0] FPGA_BOOT,
  output FPGA_WATCHDOG,
  inout FPGA_RESERVE,
  output FPGA_PWR_CYCLE_REQ,

  // UDL Master Interface
  // ------------------------------
  // Write Address Channel
  input [MAINAXI_UDL_M_AXI_ID_WIDTH-1:0] UDL_AXIM_AWID,
  input [31:0] UDL_AXIM_AWADDR,
  input [7:0] UDL_AXIM_AWLEN,
  input [2:0] UDL_AXIM_AWSIZE,
  input [1:0] UDL_AXIM_AWBURST,
  input UDL_AXIM_AWLOCK,
  input [3:0] UDL_AXIM_AWCACHE,
  input [2:0] UDL_AXIM_AWPROT,
  input [3:0] UDL_AXIM_AWQOS,
  input  UDL_AXIM_AWVALID,
  output UDL_AXIM_AWREADY,
  // Write Data Channel
  input  [31:0] UDL_AXIM_WDATA,
  input  [3:0] UDL_AXIM_WSTRB,
  input  UDL_AXIM_WLAST,
  input  UDL_AXIM_WVALID,
  output UDL_AXIM_WREADY,
  output [MAINAXI_UDL_M_AXI_ID_WIDTH-1:0] UDL_AXIM_BID,
  // Write Responce Channel
  output [1:0] UDL_AXIM_BRESP,
  output UDL_AXIM_BVALID,
  input  UDL_AXIM_BREADY,
  // Read Address Channel
  input  [MAINAXI_UDL_M_AXI_ID_WIDTH-1:0] UDL_AXIM_ARID,
  input  [31:0] UDL_AXIM_ARADDR,
  input  [7:0] UDL_AXIM_ARLEN,
  input  [2:0] UDL_AXIM_ARSIZE,
  input  [1:0] UDL_AXIM_ARBURST,
  input  UDL_AXIM_ARLOCK,
  input  [3:0] UDL_AXIM_ARCACHE,
  input  [2:0] UDL_AXIM_ARPROT,
  input  [3:0] UDL_AXIM_ARQOS,
  input  UDL_AXIM_ARVALID,
  output UDL_AXIM_ARREADY,
  // Read Data Channel
  output [MAINAXI_UDL_M_AXI_ID_WIDTH-1:0] UDL_AXIM_RID,
  output [31:0] UDL_AXIM_RDATA,
  output [1:0] UDL_AXIM_RRESP,
  output UDL_AXIM_RLAST,
  output UDL_AXIM_RVALID,
  input  UDL_AXIM_RREADY,

  // UDL Slave Interface
  // ------------------------------
  // Write Address Channel
  output [MAINAXI_S_AXI_ID_WIDTH-1:0] UDL_AXIS_AWID,
  output [31:0] UDL_AXIS_AWADDR,
  output [7:0] UDL_AXIS_AWLEN,
  output [2:0] UDL_AXIS_AWSIZE,
  output [1:0] UDL_AXIS_AWBURST,
  output UDL_AXIS_AWLOCK,
  output [3:0] UDL_AXIS_AWCACHE,
  output [2:0] UDL_AXIS_AWPROT,
  output [3:0] UDL_AXIS_AWREGION,
  output [3:0] UDL_AXIS_AWQOS,
  output UDL_AXIS_AWVALID,
  input UDL_AXIS_AWREADY,
  // Write Data Channel
  output [31:0] UDL_AXIS_WDATA,
  output [3:0] UDL_AXIS_WSTRB,
  output UDL_AXIS_WLAST,
  output UDL_AXIS_WVALID,
  input UDL_AXIS_WREADY,
  // Write Responce Channel
  input [MAINAXI_S_AXI_ID_WIDTH-1:0] UDL_AXIS_BID,
  input [1:0] UDL_AXIS_BRESP,
  input UDL_AXIS_BVALID,
  output UDL_AXIS_BREADY,
  // Read Address Channel
  output [MAINAXI_S_AXI_ID_WIDTH-1:0] UDL_AXIS_ARID,
  output [31:0] UDL_AXIS_ARADDR,
  output [7:0] UDL_AXIS_ARLEN,
  output [2:0] UDL_AXIS_ARSIZE,
  output [1:0] UDL_AXIS_ARBURST,
  output UDL_AXIS_ARLOCK,
  output [3:0] UDL_AXIS_ARCACHE,
  output [2:0] UDL_AXIS_ARPROT,
  output [3:0] UDL_AXIS_ARREGION,
  output [3:0] UDL_AXIS_ARQOS,
  output UDL_AXIS_ARVALID,
  input UDL_AXIS_ARREADY,
  // Read Data Channel
  input [MAINAXI_S_AXI_ID_WIDTH-1:0] UDL_AXIS_RID,
  input [31:0] UDL_AXIS_RDATA,
  input [1:0] UDL_AXIS_RRESP,
  input UDL_AXIS_RLAST,
  input UDL_AXIS_RVALID,
  output UDL_AXIS_RREADY,
  input [CM3SS_UDL_ISR_NUM-1:0] UDL_INTISR,

  // SRAM Interface
  // ------------------------------
  output [19:0] SRAM_A,
  output SRAM1_CE_B,
  output SRAM1_OE_B,
  output SRAM1_WE_B,
  output SRAM1_BHE_B,
  output SRAM1_BLE_B,
  input SRAM1_ERR,
  inout [15:0] SRAM1_IO,
  output SRAM2_CE_B,
  output SRAM2_OE_B,
  output SRAM2_WE_B,
  output SRAM2_BHE_B,
  output SRAM2_BLE_B,
  input SRAM2_ERR,
  inout [15:0] SRAM2_IO,

  // NOR Flash Configuration Memory Interface
  // ------------------------------
  output CFG_MEM_SEL,
  input CFG_MEM_MON,
  output CFG_MEM_SCK,
  output CFG_MEM_CS_B,
  output [3:0] CFG_MEM_OE,
  output [3:0] CFG_MEM_DOUT,
  input  [3:0] CFG_MEM_DIN,

  // NOR Flash Data Memory Interface
  // ------------------------------
  output DATA_MEM1_SCK,
  output DATA_MEM1_CS_B,
  output [3:0] DATA_MEM1_OE,
  output [3:0] DATA_MEM1_DOUT,
  input  [3:0] DATA_MEM1_DIN,
  output DATA_MEM2_SCK,
  output DATA_MEM2_CS_B,
  output [3:0] DATA_MEM2_OE,
  output [3:0] DATA_MEM2_DOUT,
  input  [3:0] DATA_MEM2_DIN,

  // FeRAM Data Memory Interface
  // ------------------------------
  output FRAM1_SCK,
  output FRAM1_CS_B,
  output [3:0] FRAM1_OE,
  output [3:0] FRAM1_DOUT,
  input  [3:0] FRAM1_DIN,
  output FRAM2_SCK,
  output FRAM2_CS_B,
  output [3:0] FRAM2_OE,
  output [3:0] FRAM2_DOUT,
  input  [3:0] FRAM2_DIN,

  // CAN Interface
  // ------------------------------
  output CAN_TX,
  input  CAN_RX,
  output CAN_SLEEP_EN,

  // Uart Lite Interface
  // ------------------------------
  output UART_TX,
  input UART_RX,

  // Internal I2C Interface
  // ------------------------------
  inout INTERNAL_I2CM_SDA,
  inout INTERNAL_I2CM_SCL,
  input CVM_CRITICAL_B,
  input CVM_WARNING_B,
  input TEMP_ALERT_B,

  // External I2C Interface
  // ------------------------------
  inout EXTERNAL_I2CM_SDA,
  inout EXTERNAL_I2CM_SCL,

  // ULPI Interface
  // ------------------------------
  output ULPI_CS,
  input ULPI_CLOCK,
  output ULPI_RESET_B,
  input ULPI_DIR,
  input ULPI_NXT,
  output ULPI_STP,
  inout [7:0] ULPI_DATA,

  // Coetex-M3 SWJ-DP Interface
  // ------------------------------
  output JTAGNSW,
  input SWCLKTCK,
  input SWDITMS,
  output SWDO,
  output SWDOEN,
  output SWV,
  input NTRST,
  input TDI,
  output TDO,
  output NTDOEN,

  // Debug Register Interface
  // ------------------------------
  output [2*20-1:0] SRAM_A_GPIO_MODE_SEL,
  output [1:0] SRAM1_CE_B_GPIO_MODE_SEL,
  output [1:0] SRAM1_OE_B_GPIO_MODE_SEL,
  output [1:0] SRAM1_WE_B_GPIO_MODE_SEL,
  output [1:0] SRAM1_BHE_B_GPIO_MODE_SEL,
  output [1:0] SRAM1_BLE_B_GPIO_MODE_SEL,
  output [1:0] SRAM2_CE_B_GPIO_MODE_SEL,
  output [1:0] SRAM2_OE_B_GPIO_MODE_SEL,
  output [1:0] SRAM2_WE_B_GPIO_MODE_SEL,
  output [1:0] SRAM2_BHE_B_GPIO_MODE_SEL,
  output [1:0] SRAM2_BLE_B_GPIO_MODE_SEL,
  input  [19:0] SRAM_A_GPIO_IN,
  input  SRAM1_CE_B_GPIO_IN,
  input  SRAM1_OE_B_GPIO_IN,
  input  SRAM1_WE_B_GPIO_IN,
  input  SRAM1_BHE_B_GPIO_IN,
  input  SRAM1_BLE_B_GPIO_IN,
  input  SRAM2_CE_B_GPIO_IN,
  input  SRAM2_OE_B_GPIO_IN,
  input  SRAM2_WE_B_GPIO_IN,
  input  SRAM2_BHE_B_GPIO_IN,
  input  SRAM2_BLE_B_GPIO_IN,

  output [1:0] CFG_MEM_CS_B_GPIO_MODE_SEL,
  output [2*4-1:0] CFG_MEM_IO_GPIO_MODE_SEL,
  input  CFG_MEM_CS_B_GPIO_IN,
  input  [3:0] CFG_MEM_IO_GPIO_IN,

  output [1:0] DATA_MEM1_CS_B_GPIO_MODE_SEL,
  output [2*4-1:0] DATA_MEM1_IO_GPIO_MODE_SEL,
  output [1:0] DATA_MEM2_CS_B_GPIO_MODE_SEL,
  output [2*4-1:0] DATA_MEM2_IO_GPIO_MODE_SEL,
  input  DATA_MEM1_CS_B_GPIO_IN,
  input  [3:0] DATA_MEM1_IO_GPIO_IN,
  input  DATA_MEM2_CS_B_GPIO_IN,
  input  [3:0] DATA_MEM2_IO_GPIO_IN,

  output [1:0] FRAM1_CS_B_GPIO_MODE_SEL,
  output [2*4-1:0] FRAM1_IO_GPIO_MODE_SEL,
  output [1:0] FRAM2_CS_B_GPIO_MODE_SEL,
  output [2*4-1:0] FRAM2_IO_GPIO_MODE_SEL,
  input  FRAM1_CS_B_GPIO_IN,
  input  [3:0] FRAM1_IO_GPIO_IN,
  input  FRAM2_CS_B_GPIO_IN,
  input  [3:0] FRAM2_IO_GPIO_IN,

  input  SYSCLK2_STATE,
  input  SYSCLK1_STATE,

  output [1:0] EXT_I2C_SCL_GPIO_MODE_SEL,
  output [1:0] EXT_I2C_SDA_GPIO_MODE_SEL,
  input  EXT_I2C_SCL_GPIO_IN,
  input  EXT_I2C_SDA_GPIO_IN,

  input  [31:0] FPGA_BOOT_SHIFTREG_IN,
  output [1:0] FPGA_WATCHDOG_GPIO_MODE_SEL,
  output [1:0] FPGA_PWR_CYCLE_REQ_GPIO_MODE_SEL,
  output [1:0] FPGA_RESERVE_GPIO_MODE_SEL,
  input  FPGA_WATCHDOG_GPIO_IN,
  input  FPGA_PWR_CYCLE_REQ_GPIO_IN,
  input  FPGA_RESERVE_GPIO_IN,
  input FPGA_BOOT0_GPIO_IN,
  input FPGA_BOOT1_GPIO_IN,

  output [1:0] FPGA_BOOT0_GPIO_MODE_SEL,
  output [1:0] FPGA_BOOT1_GPIO_MODE_SEL,
  input  ULPI_CLOCK_STATE,
  output [1:0] ULPI_RESET_B_GPIO_MODE_SEL,
  output [1:0] ULPI_CS_GPIO_MODE_SEL,
  input  ULPI_RESET_B_GPIO_IN,
  input  ULPI_CS_GPIO_IN,

  input  PUDC_B,

  output [2*16-1:0] UIO1_GPIO_MODE_SEL,
  input  [15:0] UIO1_GPIO_IN,

  output [2*16-1:0] UIO2_GPIO_MODE_SEL,
  input  [15:0] UIO2_GPIO_IN,

  output [2*6-1:0] UIO4_GPIO_MODE_SEL,
  input  [5:0] UIO4_GPIO_IN,

  output [2*16-1:0] RSV_GPIO_MODE_SEL,
  input  [15:0] RSV_GPIO_IN
);

assign CPU_LOCKUP_RSTEN = 0;

localparam LPAHB_CONSOLE_UART_DIV = 16'h015A;
localparam CM3SS_PRIMARY_ISR_NUM = 12;

// SC-OBC-SS Interrupt Signal
wire [CM3SS_PRIMARY_ISR_NUM-1:0] internal_isr;
wire hrmem_sram_isr;
wire cfgmem_qspi_isr;
wire datamem_qspi_isr;
wire fram_qspi_isr;
wire canc_isr;
wire uartlite_isr;
wire external_i2c_isr;
wire sysmon_hw_isr;
wire sysmon_bhm_isr;
wire gptmr_gtmr_isr;
wire gptmr_sitmr_isr;
assign internal_isr[11] = gptmr_sitmr_isr;
assign internal_isr[10] = gptmr_gtmr_isr;
assign internal_isr[9] = sysmon_bhm_isr;
assign internal_isr[8] = sysmon_hw_isr;
assign internal_isr[7] = external_i2c_isr;
assign internal_isr[6] = 1'b0;
assign internal_isr[5] = canc_isr;
assign internal_isr[4] = fram_qspi_isr;
assign internal_isr[3] = datamem_qspi_isr;
assign internal_isr[2] = cfgmem_qspi_isr;
assign internal_isr[1] = hrmem_sram_isr;
assign internal_isr[0] = uartlite_isr;

wire cfgitcmen;

// CM3_COD_AHB Interface
wire cm3_cod_hsel;
wire [1:0] cm3_cod_htrans;
wire [31:0] cm3_cod_haddr;
wire [2:0] cm3_cod_hburst;
wire cm3_cod_hwrite;
wire [2:0] cm3_cod_hsize;
wire [3:0] cm3_cod_hprot;
wire [31:0] cm3_cod_hwdata;
wire cm3_cod_hready;
wire [31:0] cm3_cod_hrdata;
wire [1:0] cm3_cod_hresp;

// CM3_SYS_AXI Interface
//  Write Address Channel
wire [31:0] cm3_sys_awaddr;
wire [3:0] cm3_sys_awlen;
wire [2:0] cm3_sys_awsize;
wire [1:0] cm3_sys_awburst;
wire [1:0] cm3_sys_awlock;
wire [3:0] cm3_sys_awcache;
wire [2:0] cm3_sys_awprot;
wire cm3_sys_awvalid;
wire cm3_sys_awready;
//  Write Data Channel
wire [31:0] cm3_sys_wdata;
wire [3:0] cm3_sys_wstrb;
wire cm3_sys_wlast;
wire cm3_sys_wvalid;
wire cm3_sys_wready;
// Write Responce Channel
wire [1:0] cm3_sys_bresp;
wire cm3_sys_bvalid;
wire cm3_sys_bready;
// Read Address Channel
wire [31:0] cm3_sys_araddr;
wire [3:0] cm3_sys_arlen;
wire [2:0] cm3_sys_arsize;
wire [1:0] cm3_sys_arburst;
wire [1:0] cm3_sys_arlock;
wire [3:0] cm3_sys_arcache;
wire [2:0] cm3_sys_arprot;
wire cm3_sys_arvalid;
wire cm3_sys_arready;
// Read Data Channel
wire [31:0] cm3_sys_rdata;
wire [1:0] cm3_sys_rresp;
wire cm3_sys_rlast;
wire cm3_sys_rvalid;
wire cm3_sys_rready;

// HRMEM for SRAM AXI Interface
//  Write Address Channel
wire [MAINAXI_S_AXI_ID_WIDTH-1:0] hrmem_sram_axis_awid;
wire [31:0] hrmem_sram_axis_awaddr;
wire [7:0] hrmem_sram_axis_awlen;
wire [2:0] hrmem_sram_axis_awsize;
wire [1:0] hrmem_sram_axis_awburst;
wire hrmem_sram_axis_awlock;
wire [3:0] hrmem_sram_axis_awcache;
wire [2:0] hrmem_sram_axis_awprot;
wire hrmem_sram_axis_awvalid;
wire hrmem_sram_axis_awready;
//  Write Data Channel
wire [31:0] hrmem_sram_axis_wdata;
wire [3:0] hrmem_sram_axis_wstrb;
wire hrmem_sram_axis_wlast;
wire hrmem_sram_axis_wvalid;
wire hrmem_sram_axis_wready;
//  Write Responce Channel
wire [MAINAXI_S_AXI_ID_WIDTH-1:0] hrmem_sram_axis_bid;
wire [1:0] hrmem_sram_axis_bresp;
wire hrmem_sram_axis_bvalid;
wire hrmem_sram_axis_bready;
//  Read Address Channel
wire [MAINAXI_S_AXI_ID_WIDTH-1:0] hrmem_sram_axis_arid;
wire [31:0] hrmem_sram_axis_araddr;
wire [7:0] hrmem_sram_axis_arlen;
wire [2:0] hrmem_sram_axis_arsize;
wire [1:0] hrmem_sram_axis_arburst;
wire hrmem_sram_axis_arlock;
wire [3:0] hrmem_sram_axis_arcache;
wire [2:0] hrmem_sram_axis_arprot;
wire hrmem_sram_axis_arvalid;
wire hrmem_sram_axis_arready;
//  Read Data Channel
wire [MAINAXI_S_AXI_ID_WIDTH-1:0] hrmem_sram_axis_rid;
wire [31:0] hrmem_sram_axis_rdata;
wire [1:0] hrmem_sram_axis_rresp;
wire hrmem_sram_axis_rlast;
wire hrmem_sram_axis_rvalid;
wire hrmem_sram_axis_rready;

// HRMEM Register for SRAM AXI Interface
//  Write Address Channel
wire [MAINAXI_S_AXI_ID_WIDTH-1:0] hrmem_sram_reg_axis_awid;
wire [31:0] hrmem_sram_reg_axis_awaddr;
wire [7:0] hrmem_sram_reg_axis_awlen;
wire [2:0] hrmem_sram_reg_axis_awsize;
wire [1:0] hrmem_sram_reg_axis_awburst;
wire hrmem_sram_reg_axis_awvalid;
wire hrmem_sram_reg_axis_awready;
//  Write Data Channel
wire [31:0] hrmem_sram_reg_axis_wdata;
wire [3:0] hrmem_sram_reg_axis_wstrb;
wire hrmem_sram_reg_axis_wlast;
wire hrmem_sram_reg_axis_wvalid;
wire hrmem_sram_reg_axis_wready;
//  Write Responce Channel
wire [MAINAXI_S_AXI_ID_WIDTH-1:0] hrmem_sram_reg_axis_bid;
wire [1:0] hrmem_sram_reg_axis_bresp;
wire hrmem_sram_reg_axis_bvalid;
wire hrmem_sram_reg_axis_bready;
//  Read Address Channel
wire [MAINAXI_S_AXI_ID_WIDTH-1:0] hrmem_sram_reg_axis_arid;
wire [31:0] hrmem_sram_reg_axis_araddr;
wire [7:0] hrmem_sram_reg_axis_arlen;
wire [2:0] hrmem_sram_reg_axis_arsize;
wire [1:0] hrmem_sram_reg_axis_arburst;
wire hrmem_sram_reg_axis_arvalid;
wire hrmem_sram_reg_axis_arready;
//  Read Data Channel
wire [MAINAXI_S_AXI_ID_WIDTH-1:0] hrmem_sram_reg_axis_rid;
wire [31:0] hrmem_sram_reg_axis_rdata;
wire [1:0] hrmem_sram_reg_axis_rresp;
wire hrmem_sram_reg_axis_rlast;
wire hrmem_sram_reg_axis_rvalid;
wire hrmem_sram_reg_axis_rready;

// HRMEM Register for SRAM AHB Interface
wire [31:0] hrmem_sram_reg_haddr;
wire [1:0] hrmem_sram_reg_htrans;
wire hrmem_sram_reg_hwrite;
wire [2:0] hrmem_sram_reg_hsize;
wire [2:0] hrmem_sram_reg_hburst;
wire [31:0] hrmem_sram_reg_hwdata;
wire [31:0] hrmem_sram_reg_hrdata;
wire hrmem_sram_reg_hready;
wire [1:0] hrmem_sram_reg_hresp;

// Low Performance AXI Interface
//  Write Address Channel
wire [MAINAXI_S_AXI_ID_WIDTH-1:0] lpahb_axim_awid;
wire [31:0] lpahb_axim_awaddr;
wire [7:0] lpahb_axim_awlen;
wire [2:0] lpahb_axim_awsize;
wire [1:0] lpahb_axim_awburst;
wire lpahb_axim_awvalid;
wire lpahb_axim_awready;
//  Write Data Channel
wire [31:0] lpahb_axim_wdata;
wire [3:0] lpahb_axim_wstrb;
wire lpahb_axim_wlast;
wire lpahb_axim_wvalid;
wire lpahb_axim_wready;
// Write Responce Channel
wire [MAINAXI_S_AXI_ID_WIDTH-1:0] lpahb_axim_bid;
wire [1:0] lpahb_axim_bresp;
wire lpahb_axim_bvalid;
wire lpahb_axim_bready;
// Read Address Channel
wire [MAINAXI_S_AXI_ID_WIDTH-1:0] lpahb_axim_arid;
wire [31:0] lpahb_axim_araddr;
wire [7:0] lpahb_axim_arlen;
wire [2:0] lpahb_axim_arsize;
wire [1:0] lpahb_axim_arburst;
wire lpahb_axim_arvalid;
wire lpahb_axim_arready;
// Read Data Channel
wire [MAINAXI_S_AXI_ID_WIDTH-1:0] lpahb_axim_rid;
wire [31:0] lpahb_axim_rdata;
wire [1:0] lpahb_axim_rresp;
wire lpahb_axim_rlast;
wire lpahb_axim_rvalid;
wire lpahb_axim_rready;

// Configuration Memory Interface
wire cfg_mem_owner;
wire cfg_mem_regsel;
wire cfg_mem_busy = 1'b0;

// ARM Cortex-M3 SubSystem
sc_cm3_ss # (
  .CM3SS_PRIMARY_ISR_NUM(CM3SS_PRIMARY_ISR_NUM),
  .CM3SS_SECONDARY_ISR_NUM(CM3SS_UDL_ISR_NUM),
  .CM3SS_ITCM_SIZE_KB(CM3SS_ITCM_SIZE_KB),
  .CM3SS_ITCM_ADDR_BW(CM3SS_ITCM_ADDR_BW),
  .CM3SS_ITCM_INIT(CM3SS_ITCM_INIT),
  .CM3SS_ITCM_INIT_FILE(CM3SS_ITCM_INIT_FILE)
) cm3_ss (
  // System Interface
  .SYS_CLK(SYS_CLK),
  .REF_CLK(REF_CLK),
  .SYS_RST_N(SYS_RSTB),
  .DBG_RST_N(POR_RSTB),
  .SYS_RST_REQ(SYS_RST_REQ),
  .CFGITCMEN(cfgitcmen),
  .CPU_LOCKUP(CPU_LOCKUP),
  .CPU_HALTED(/*open*/),
  .CPU_SLEEPING(SLEEPING),
  .CPU_SLEEPHOLDREQN(SLEEPHOLDREQN),
  .CPU_SLEEPHOLDACKN(SLEEPHOLDACKN),
  .CPU_WICENREQ(1'b0),
  .CPU_WICENACK(/*open*/),
  .CPU_WAKEUP(/*open*/),

  // Interrupt Signal
  .INTISR1(internal_isr),
  .INTISR2(UDL_INTISR),
  .NMI(1'b0),

  // CM3_COD_AHB Interface
  .CM3_COD_HSEL(cm3_cod_hsel),
  .CM3_COD_HTRANS(cm3_cod_htrans),
  .CM3_COD_HADDR(cm3_cod_haddr),
  .CM3_COD_HBURST(cm3_cod_hburst),
  .CM3_COD_HWRITE(cm3_cod_hwrite),
  .CM3_COD_HSIZE(cm3_cod_hsize),
  .CM3_COD_HPROT(cm3_cod_hprot),
  .CM3_COD_HWDATA(cm3_cod_hwdata),
  .CM3_COD_HREADY(cm3_cod_hready),
  .CM3_COD_HRDATA(cm3_cod_hrdata),
  .CM3_COD_HRESP(cm3_cod_hresp),

  // CM3_SYS_AXI3 Write Address Channel
  .CM3_SYS_AWADDR(cm3_sys_awaddr),
  .CM3_SYS_AWLEN(cm3_sys_awlen),
  .CM3_SYS_AWSIZE(cm3_sys_awsize),
  .CM3_SYS_AWBURST(cm3_sys_awburst),
  .CM3_SYS_AWLOCK(cm3_sys_awlock),
  .CM3_SYS_AWCACHE(cm3_sys_awcache),
  .CM3_SYS_AWPROT(cm3_sys_awprot),
  .CM3_SYS_AWUSER(/*open*/),
  .CM3_SYS_AWVALID(cm3_sys_awvalid),
  .CM3_SYS_AWREADY(cm3_sys_awready),

  // CM3_SYS_AXI3 Write Data Channel
  .CM3_SYS_WDATA(cm3_sys_wdata),
  .CM3_SYS_WSTRB(cm3_sys_wstrb),
  .CM3_SYS_WLAST(cm3_sys_wlast),
  .CM3_SYS_WVALID(cm3_sys_wvalid),
  .CM3_SYS_WREADY(cm3_sys_wready),

  // CM3_SYS_AXI3 Write Responce Channel
  .CM3_SYS_BRESP(cm3_sys_bresp),
  .CM3_SYS_BVALID(cm3_sys_bvalid),
  .CM3_SYS_BREADY(cm3_sys_bready),

  // CM3_SYS_AXI3 Read Address Channel
  .CM3_SYS_ARADDR(cm3_sys_araddr),
  .CM3_SYS_ARLEN(cm3_sys_arlen),
  .CM3_SYS_ARSIZE(cm3_sys_arsize),
  .CM3_SYS_ARBURST(cm3_sys_arburst),
  .CM3_SYS_ARLOCK(cm3_sys_arlock),
  .CM3_SYS_ARCACHE(cm3_sys_arcache),
  .CM3_SYS_ARPROT(cm3_sys_arprot),
  .CM3_SYS_ARUSER(/*open*/),
  .CM3_SYS_ARVALID(cm3_sys_arvalid),
  .CM3_SYS_ARREADY(cm3_sys_arready),

  // CM3_SYS_AXI3 Read Data Channel
  .CM3_SYS_RDATA(cm3_sys_rdata),
  .CM3_SYS_RRESP(cm3_sys_rresp),
  .CM3_SYS_RLAST(cm3_sys_rlast),
  .CM3_SYS_RVALID(cm3_sys_rvalid),
  .CM3_SYS_RREADY(cm3_sys_rready),

  // SWJ-DP Interface
  .JTAGNSW(JTAGNSW),
  .SWCLKTCK(SWCLKTCK),
  .SWDITMS(SWDITMS),
  .SWDO(SWDO),
  .SWDOEN(SWDOEN),
  .SWV(SWV),
  .NTRST(NTRST),
  .TDI(TDI),
  .TDO(TDO),
  .NTDOEN(NTDOEN)
);

wire read_latency_mode;
hrmem_latency_sel latency_sel (
  .SYS_CLK(SYS_CLK),
  .SYS_RSTB(SYS_RSTB),
  .CLKMODE(CLKMODE),
  .CMC_REQ(CMC_REQ),
  .CMC_ACK(CMC_ACK),
  .LATENCY_SEL(read_latency_mode)
);

sc_hrmem_sram # (
  .SC_HRMEM_SRAM_SYS_AXI_ID_W(MAINAXI_S_AXI_ID_WIDTH),
  .SC_HRMEM_SRAM_PFB_STG_NUM(8),
  .SC_HRMEM_SRAM_PFB_LINE_NUM(8),
  .SC_HRMEM_SRAM_SP_PFB_LINE_NUM(2)
) hrmem_sram (
  // System Interface
  .SYSCLK(SYS_CLK),
  .SYSRST_N(SYS_RSTB),
  .MODULE_RSTN(1'b1),
  .POR_RST_N(BOOT_RSTB),
  .RAM_INIT_REQ(INIT_REQ),
  .RAM_INIT_DONE(INIT_DONE),
  .RD_LTCY_MODE(read_latency_mode),

  // CM3 CODE Bus AHB Slave Interface
  .CODE_SHSEL(cm3_cod_hsel),
  .CODE_SHADDR(cm3_cod_haddr[21:0]),
  .CODE_SHTRANS(cm3_cod_htrans),
  .CODE_SHSIZE(cm3_cod_hsize),
  .CODE_SHBURST(cm3_cod_hburst),
  .CODE_SHWRITE(cm3_cod_hwrite),
  .CODE_SHPROT(cm3_cod_hprot),
  .CODE_SHWDATA(cm3_cod_hwdata),
  .CODE_SHRDATA(cm3_cod_hrdata),
  .CODE_SHRESP(cm3_cod_hresp),
  .CODE_SHREADYIN(1'b1),
  .CODE_SHREADYOUT(cm3_cod_hready),

  // SYS Bus AXI Slave Interface
  .SYS_S_AXI_AWID(hrmem_sram_axis_awid),
  .SYS_S_AXI_AWADDR(hrmem_sram_axis_awaddr[21:0]),
  .SYS_S_AXI_AWLEN(hrmem_sram_axis_awlen),
  .SYS_S_AXI_AWSIZE(hrmem_sram_axis_awsize),
  .SYS_S_AXI_AWBURST(hrmem_sram_axis_awburst),
  .SYS_S_AXI_AWLOCK(hrmem_sram_axis_awlock),
  .SYS_S_AXI_AWCACHE(hrmem_sram_axis_awcache),
  .SYS_S_AXI_AWPROT(hrmem_sram_axis_awprot),
  .SYS_S_AXI_AWVALID(hrmem_sram_axis_awvalid),
  .SYS_S_AXI_AWREADY(hrmem_sram_axis_awready),
  .SYS_S_AXI_WDATA(hrmem_sram_axis_wdata),
  .SYS_S_AXI_WSTRB(hrmem_sram_axis_wstrb),
  .SYS_S_AXI_WLAST(hrmem_sram_axis_wlast),
  .SYS_S_AXI_WVALID(hrmem_sram_axis_wvalid),
  .SYS_S_AXI_WREADY(hrmem_sram_axis_wready),
  .SYS_S_AXI_BID(hrmem_sram_axis_bid),
  .SYS_S_AXI_BRESP(hrmem_sram_axis_bresp),
  .SYS_S_AXI_BVALID(hrmem_sram_axis_bvalid),
  .SYS_S_AXI_BREADY(hrmem_sram_axis_bready),
  .SYS_S_AXI_ARID(hrmem_sram_axis_arid),
  .SYS_S_AXI_ARADDR(hrmem_sram_axis_araddr[21:0]),
  .SYS_S_AXI_ARLEN(hrmem_sram_axis_arlen),
  .SYS_S_AXI_ARSIZE(hrmem_sram_axis_arsize),
  .SYS_S_AXI_ARBURST(hrmem_sram_axis_arburst),
  .SYS_S_AXI_ARLOCK(hrmem_sram_axis_arlock),
  .SYS_S_AXI_ARCACHE(hrmem_sram_axis_arcache),
  .SYS_S_AXI_ARPROT(hrmem_sram_axis_arprot),
  .SYS_S_AXI_ARVALID(hrmem_sram_axis_arvalid),
  .SYS_S_AXI_ARREADY(hrmem_sram_axis_arready),
  .SYS_S_AXI_RID(hrmem_sram_axis_rid),
  .SYS_S_AXI_RDATA(hrmem_sram_axis_rdata),
  .SYS_S_AXI_RRESP(hrmem_sram_axis_rresp),
  .SYS_S_AXI_RLAST(hrmem_sram_axis_rlast),
  .SYS_S_AXI_RVALID(hrmem_sram_axis_rvalid),
  .SYS_S_AXI_RREADY(hrmem_sram_axis_rready),

  // AHB Interface
  .SHSEL(hrmem_sram_reg_htrans[1]),
  .SHADDR(hrmem_sram_reg_haddr),
  .SHTRANS(hrmem_sram_reg_htrans),
  .SHSIZE(hrmem_sram_reg_hsize),
  .SHBURST(hrmem_sram_reg_hburst),
  .SHWRITE(hrmem_sram_reg_hwrite),
  .SHREADYIN(1'b1),
  .SHREADYOUT(hrmem_sram_reg_hready),
  .SHWDATA(hrmem_sram_reg_hwdata),
  .SHRDATA(hrmem_sram_reg_hrdata),
  .SHRESP(hrmem_sram_reg_hresp),

  // SRAM Interface
  .SR_A(SRAM_A),
  .SR1_CEB(SRAM1_CE_B),
  .SR1_OEB(SRAM1_OE_B),
  .SR1_WEB(SRAM1_WE_B),
  .SR1_BHEB(SRAM1_BHE_B),
  .SR1_BLEB(SRAM1_BLE_B),
  .SR1_IO(SRAM1_IO),
  .SR1_ERR(SRAM1_ERR),
  .SR2_CEB(SRAM2_CE_B),
  .SR2_OEB(SRAM2_OE_B),
  .SR2_WEB(SRAM2_WE_B),
  .SR2_BHEB(SRAM2_BHE_B),
  .SR2_BLEB(SRAM2_BLE_B),
  .SR2_IO(SRAM2_IO),
  .SR2_ERR(SRAM2_ERR),

  // Interrupt Interface
  .HRMEM_INT(hrmem_sram_isr)
);

sc_axim2ahbs_nb # (
  .AXIM2AHBSNB_ID_WIDTH(MAINAXI_S_AXI_ID_WIDTH),
  .AXIM2AHBSNB_HCLK_IDLE_BIT(5)
) axim2ahbs_hrmem_sram_reg (
  // Global Signal
  .ACLK(SYS_CLK),
  .ARESETN(SYS_RSTB),

  // Write Address Channel Signal
  .AWID(hrmem_sram_reg_axis_awid),
  .AWADDR(hrmem_sram_reg_axis_awaddr),
  .AWLEN(hrmem_sram_reg_axis_awlen),
  .AWSIZE(hrmem_sram_reg_axis_awsize),
  .AWBURST(hrmem_sram_reg_axis_awburst),
  .AWVALID(hrmem_sram_reg_axis_awvalid),
  .AWREADY(hrmem_sram_reg_axis_awready),

  // Write Data Channel Signal
  .WDATA(hrmem_sram_reg_axis_wdata),
  .WSTRB(hrmem_sram_reg_axis_wstrb),
  .WLAST(hrmem_sram_reg_axis_wlast),
  .WVALID(hrmem_sram_reg_axis_wvalid),
  .WREADY(hrmem_sram_reg_axis_wready),

  // Write Responce Channel Signal
  .BRESP(hrmem_sram_reg_axis_bresp),
  .BVALID(hrmem_sram_reg_axis_bvalid),
  .BREADY(hrmem_sram_reg_axis_bready),
  .BID(hrmem_sram_reg_axis_bid),

  // Read Address Channel Signal
  .ARID(hrmem_sram_reg_axis_arid),
  .ARADDR(hrmem_sram_reg_axis_araddr),
  .ARLEN(hrmem_sram_reg_axis_arlen),
  .ARSIZE(hrmem_sram_reg_axis_arsize),
  .ARBURST(hrmem_sram_reg_axis_arburst),
  .ARVALID(hrmem_sram_reg_axis_arvalid),
  .ARREADY(hrmem_sram_reg_axis_arready),

  // Read Data Channel Signal
  .RID(hrmem_sram_reg_axis_rid),
  .RDATA(hrmem_sram_reg_axis_rdata),
  .RRESP(hrmem_sram_reg_axis_rresp),
  .RLAST(hrmem_sram_reg_axis_rlast),
  .RVALID(hrmem_sram_reg_axis_rvalid),
  .RREADY(hrmem_sram_reg_axis_rready),

  // AHB Slave Interface
  .HADDR(hrmem_sram_reg_haddr),
  .HTRANS(hrmem_sram_reg_htrans),
  .HWRITE(hrmem_sram_reg_hwrite),
  .HSIZE(hrmem_sram_reg_hsize),
  .HBURST(hrmem_sram_reg_hburst),
  .HWDATA(hrmem_sram_reg_hwdata),
  .HRDATA(hrmem_sram_reg_hrdata),
  .HREADY(hrmem_sram_reg_hready),
  .HRESP(hrmem_sram_reg_hresp),
  .HCLKEN(/*open*/)
);

main_axi_ss # (
  .MAINAXI_UDL_M_AXI_ID_WIDTH(MAINAXI_UDL_M_AXI_ID_WIDTH),
  .MAINAXI_S_AXI_ID_WIDTH(MAINAXI_S_AXI_ID_WIDTH)
) main_axi (
  // System Interface
  .SYS_CLK(SYS_CLK),
  .REF_CLK(REF_CLK),
  .SYS_RSTB(SYS_RSTB),
  .SYS_RSTB_SYNC_REFCLK(SYS_RSTB_SYNC_REFCLK),
  .BUS_RSTB(BUS_RSTB),
  // Interrupt Signal
  .CFG_MEM_INT(cfgmem_qspi_isr),
  .DATA_MEM_INT(datamem_qspi_isr),
  .FRAM_INT(fram_qspi_isr),
  .CAN_INT(canc_isr),

  // CPU SYS AXI3 Slave Interface
  //  Write Address Channel
  .CPU_SYS_S_AXI_AWADDR(cm3_sys_awaddr),
  .CPU_SYS_S_AXI_AWLEN(cm3_sys_awlen),
  .CPU_SYS_S_AXI_AWSIZE(cm3_sys_awsize),
  .CPU_SYS_S_AXI_AWBURST(cm3_sys_awburst),
  .CPU_SYS_S_AXI_AWLOCK(cm3_sys_awlock),
  .CPU_SYS_S_AXI_AWCACHE(cm3_sys_awcache),
  .CPU_SYS_S_AXI_AWPROT(cm3_sys_awprot),
  .CPU_SYS_S_AXI_AWVALID(cm3_sys_awvalid),
  .CPU_SYS_S_AXI_AWREADY(cm3_sys_awready),
  //  Write Data Channel
  .CPU_SYS_S_AXI_WDATA(cm3_sys_wdata),
  .CPU_SYS_S_AXI_WSTRB(cm3_sys_wstrb),
  .CPU_SYS_S_AXI_WLAST(cm3_sys_wlast),
  .CPU_SYS_S_AXI_WVALID(cm3_sys_wvalid),
  .CPU_SYS_S_AXI_WREADY(cm3_sys_wready),
  //  Write Responce Channel
  .CPU_SYS_S_AXI_BRESP(cm3_sys_bresp),
  .CPU_SYS_S_AXI_BVALID(cm3_sys_bvalid),
  .CPU_SYS_S_AXI_BREADY(cm3_sys_bready),
  //  Read Address Channel
  .CPU_SYS_S_AXI_ARADDR(cm3_sys_araddr),
  .CPU_SYS_S_AXI_ARLEN(cm3_sys_arlen),
  .CPU_SYS_S_AXI_ARSIZE(cm3_sys_arsize),
  .CPU_SYS_S_AXI_ARBURST(cm3_sys_arburst),
  .CPU_SYS_S_AXI_ARLOCK(cm3_sys_arlock),
  .CPU_SYS_S_AXI_ARCACHE(cm3_sys_arcache),
  .CPU_SYS_S_AXI_ARPROT(cm3_sys_arprot),
  .CPU_SYS_S_AXI_ARVALID(cm3_sys_arvalid),
  .CPU_SYS_S_AXI_ARREADY(cm3_sys_arready),
  //  Read Data Channel
  .CPU_SYS_S_AXI_RDATA(cm3_sys_rdata),
  .CPU_SYS_S_AXI_RRESP(cm3_sys_rresp),
  .CPU_SYS_S_AXI_RLAST(cm3_sys_rlast),
  .CPU_SYS_S_AXI_RVALID(cm3_sys_rvalid),
  .CPU_SYS_S_AXI_RREADY(cm3_sys_rready),

  // UDL AXI4 Slave Interface
  //  Write Address Channel
  .UDL_S_AXI_AWID(UDL_AXIM_AWID),
  .UDL_S_AXI_AWADDR(UDL_AXIM_AWADDR),
  .UDL_S_AXI_AWLEN(UDL_AXIM_AWLEN),
  .UDL_S_AXI_AWSIZE(UDL_AXIM_AWSIZE),
  .UDL_S_AXI_AWBURST(UDL_AXIM_AWBURST),
  .UDL_S_AXI_AWLOCK(UDL_AXIM_AWLOCK),
  .UDL_S_AXI_AWCACHE(UDL_AXIM_AWCACHE),
  .UDL_S_AXI_AWPROT(UDL_AXIM_AWPROT),
  .UDL_S_AXI_AWQOS(UDL_AXIM_AWQOS),
  .UDL_S_AXI_AWVALID(UDL_AXIM_AWVALID),
  .UDL_S_AXI_AWREADY(UDL_AXIM_AWREADY),
  //  Write Data Channel
  .UDL_S_AXI_WDATA(UDL_AXIM_WDATA),
  .UDL_S_AXI_WSTRB(UDL_AXIM_WSTRB),
  .UDL_S_AXI_WLAST(UDL_AXIM_WLAST),
  .UDL_S_AXI_WVALID(UDL_AXIM_WVALID),
  .UDL_S_AXI_WREADY(UDL_AXIM_WREADY),
  //  Write Responce Channel
  .UDL_S_AXI_BID(UDL_AXIM_BID),
  .UDL_S_AXI_BRESP(UDL_AXIM_BRESP),
  .UDL_S_AXI_BVALID(UDL_AXIM_BVALID),
  .UDL_S_AXI_BREADY(UDL_AXIM_BREADY),
  //  Read Address Channel
  .UDL_S_AXI_ARID(UDL_AXIM_ARID),
  .UDL_S_AXI_ARADDR(UDL_AXIM_ARADDR),
  .UDL_S_AXI_ARLEN(UDL_AXIM_ARLEN),
  .UDL_S_AXI_ARSIZE(UDL_AXIM_ARSIZE),
  .UDL_S_AXI_ARBURST(UDL_AXIM_ARBURST),
  .UDL_S_AXI_ARLOCK(UDL_AXIM_ARLOCK),
  .UDL_S_AXI_ARCACHE(UDL_AXIM_ARCACHE),
  .UDL_S_AXI_ARPROT(UDL_AXIM_ARPROT),
  .UDL_S_AXI_ARQOS(UDL_AXIM_ARQOS),
  .UDL_S_AXI_ARVALID(UDL_AXIM_ARVALID),
  .UDL_S_AXI_ARREADY(UDL_AXIM_ARREADY),
  //  Read Data Channel
  .UDL_S_AXI_RID(UDL_AXIM_RID),
  .UDL_S_AXI_RDATA(UDL_AXIM_RDATA),
  .UDL_S_AXI_RRESP(UDL_AXIM_RRESP),
  .UDL_S_AXI_RLAST(UDL_AXIM_RLAST),
  .UDL_S_AXI_RVALID(UDL_AXIM_RVALID),
  .UDL_S_AXI_RREADY(UDL_AXIM_RREADY),

  // HRMEM for SRAM AXI4 Master Interface
  //  Write Address Channel
  .HRMEM_SRAM_M_AXI_AWID(hrmem_sram_axis_awid),
  .HRMEM_SRAM_M_AXI_AWADDR(hrmem_sram_axis_awaddr),
  .HRMEM_SRAM_M_AXI_AWLEN(hrmem_sram_axis_awlen),
  .HRMEM_SRAM_M_AXI_AWSIZE(hrmem_sram_axis_awsize),
  .HRMEM_SRAM_M_AXI_AWBURST(hrmem_sram_axis_awburst),
  .HRMEM_SRAM_M_AXI_AWLOCK(hrmem_sram_axis_awlock),
  .HRMEM_SRAM_M_AXI_AWCACHE(hrmem_sram_axis_awcache),
  .HRMEM_SRAM_M_AXI_AWPROT(hrmem_sram_axis_awprot),
  .HRMEM_SRAM_M_AXI_AWVALID(hrmem_sram_axis_awvalid),
  .HRMEM_SRAM_M_AXI_AWREADY(hrmem_sram_axis_awready),
  //  Write Data Channel
  .HRMEM_SRAM_M_AXI_WDATA(hrmem_sram_axis_wdata),
  .HRMEM_SRAM_M_AXI_WSTRB(hrmem_sram_axis_wstrb),
  .HRMEM_SRAM_M_AXI_WLAST(hrmem_sram_axis_wlast),
  .HRMEM_SRAM_M_AXI_WVALID(hrmem_sram_axis_wvalid),
  .HRMEM_SRAM_M_AXI_WREADY(hrmem_sram_axis_wready),
  //  Write Responce Channel
  .HRMEM_SRAM_M_AXI_BID(hrmem_sram_axis_bid),
  .HRMEM_SRAM_M_AXI_BRESP(hrmem_sram_axis_bresp),
  .HRMEM_SRAM_M_AXI_BVALID(hrmem_sram_axis_bvalid),
  .HRMEM_SRAM_M_AXI_BREADY(hrmem_sram_axis_bready),
  //  Read Address Channel
  .HRMEM_SRAM_M_AXI_ARID(hrmem_sram_axis_arid),
  .HRMEM_SRAM_M_AXI_ARADDR(hrmem_sram_axis_araddr),
  .HRMEM_SRAM_M_AXI_ARLEN(hrmem_sram_axis_arlen),
  .HRMEM_SRAM_M_AXI_ARSIZE(hrmem_sram_axis_arsize),
  .HRMEM_SRAM_M_AXI_ARBURST(hrmem_sram_axis_arburst),
  .HRMEM_SRAM_M_AXI_ARLOCK(hrmem_sram_axis_arlock),
  .HRMEM_SRAM_M_AXI_ARCACHE(hrmem_sram_axis_arcache),
  .HRMEM_SRAM_M_AXI_ARPROT(hrmem_sram_axis_arprot),
  .HRMEM_SRAM_M_AXI_ARVALID(hrmem_sram_axis_arvalid),
  .HRMEM_SRAM_M_AXI_ARREADY(hrmem_sram_axis_arready),
  //  Read Data Channel
  .HRMEM_SRAM_M_AXI_RID(hrmem_sram_axis_rid),
  .HRMEM_SRAM_M_AXI_RDATA(hrmem_sram_axis_rdata),
  .HRMEM_SRAM_M_AXI_RRESP(hrmem_sram_axis_rresp),
  .HRMEM_SRAM_M_AXI_RLAST(hrmem_sram_axis_rlast),
  .HRMEM_SRAM_M_AXI_RVALID(hrmem_sram_axis_rvalid),
  .HRMEM_SRAM_M_AXI_RREADY(hrmem_sram_axis_rready),

  // HRMEM Register for SRAM AXI4 Master Interface
  //  Write Address Channel
  .HRMEM_SRAM_REG_M_AXI_AWID(hrmem_sram_reg_axis_awid),
  .HRMEM_SRAM_REG_M_AXI_AWADDR(hrmem_sram_reg_axis_awaddr),
  .HRMEM_SRAM_REG_M_AXI_AWLEN(hrmem_sram_reg_axis_awlen),
  .HRMEM_SRAM_REG_M_AXI_AWSIZE(hrmem_sram_reg_axis_awsize),
  .HRMEM_SRAM_REG_M_AXI_AWBURST(hrmem_sram_reg_axis_awburst),
  .HRMEM_SRAM_REG_M_AXI_AWVALID(hrmem_sram_reg_axis_awvalid),
  .HRMEM_SRAM_REG_M_AXI_AWREADY(hrmem_sram_reg_axis_awready),
  //  Write Data Channel
  .HRMEM_SRAM_REG_M_AXI_WDATA(hrmem_sram_reg_axis_wdata),
  .HRMEM_SRAM_REG_M_AXI_WSTRB(hrmem_sram_reg_axis_wstrb),
  .HRMEM_SRAM_REG_M_AXI_WLAST(hrmem_sram_reg_axis_wlast),
  .HRMEM_SRAM_REG_M_AXI_WVALID(hrmem_sram_reg_axis_wvalid),
  .HRMEM_SRAM_REG_M_AXI_WREADY(hrmem_sram_reg_axis_wready),
  //  Write Responce Channel
  .HRMEM_SRAM_REG_M_AXI_BID(hrmem_sram_reg_axis_bid),
  .HRMEM_SRAM_REG_M_AXI_BRESP(hrmem_sram_reg_axis_bresp),
  .HRMEM_SRAM_REG_M_AXI_BVALID(hrmem_sram_reg_axis_bvalid),
  .HRMEM_SRAM_REG_M_AXI_BREADY(hrmem_sram_reg_axis_bready),
  //  Read Address Channel
  .HRMEM_SRAM_REG_M_AXI_ARID(hrmem_sram_reg_axis_arid),
  .HRMEM_SRAM_REG_M_AXI_ARADDR(hrmem_sram_reg_axis_araddr),
  .HRMEM_SRAM_REG_M_AXI_ARLEN(hrmem_sram_reg_axis_arlen),
  .HRMEM_SRAM_REG_M_AXI_ARSIZE(hrmem_sram_reg_axis_arsize),
  .HRMEM_SRAM_REG_M_AXI_ARBURST(hrmem_sram_reg_axis_arburst),
  .HRMEM_SRAM_REG_M_AXI_ARVALID(hrmem_sram_reg_axis_arvalid),
  .HRMEM_SRAM_REG_M_AXI_ARREADY(hrmem_sram_reg_axis_arready),
  //  Read Data Channel
  .HRMEM_SRAM_REG_M_AXI_RID(hrmem_sram_reg_axis_rid),
  .HRMEM_SRAM_REG_M_AXI_RDATA(hrmem_sram_reg_axis_rdata),
  .HRMEM_SRAM_REG_M_AXI_RRESP(hrmem_sram_reg_axis_rresp),
  .HRMEM_SRAM_REG_M_AXI_RLAST(hrmem_sram_reg_axis_rlast),
  .HRMEM_SRAM_REG_M_AXI_RVALID(hrmem_sram_reg_axis_rvalid),
  .HRMEM_SRAM_REG_M_AXI_RREADY(hrmem_sram_reg_axis_rready),

  // Low Performance AHB AXI4 Master Interface
  //  Write Address Channel
  .LPAHB_M_AXI_AWID(lpahb_axim_awid),
  .LPAHB_M_AXI_AWADDR(lpahb_axim_awaddr),
  .LPAHB_M_AXI_AWLEN(lpahb_axim_awlen),
  .LPAHB_M_AXI_AWSIZE(lpahb_axim_awsize),
  .LPAHB_M_AXI_AWBURST(lpahb_axim_awburst),
  .LPAHB_M_AXI_AWVALID(lpahb_axim_awvalid),
  .LPAHB_M_AXI_AWREADY(lpahb_axim_awready),
  //  Write Data Channel
  .LPAHB_M_AXI_WDATA(lpahb_axim_wdata),
  .LPAHB_M_AXI_WSTRB(lpahb_axim_wstrb),
  .LPAHB_M_AXI_WLAST(lpahb_axim_wlast),
  .LPAHB_M_AXI_WVALID(lpahb_axim_wvalid),
  .LPAHB_M_AXI_WREADY(lpahb_axim_wready),
  //  Write Responce Channel
  .LPAHB_M_AXI_BID(lpahb_axim_bid),
  .LPAHB_M_AXI_BRESP(lpahb_axim_bresp),
  .LPAHB_M_AXI_BVALID(lpahb_axim_bvalid),
  .LPAHB_M_AXI_BREADY(lpahb_axim_bready),
  //  Read Address Channel
  .LPAHB_M_AXI_ARID(lpahb_axim_arid),
  .LPAHB_M_AXI_ARADDR(lpahb_axim_araddr),
  .LPAHB_M_AXI_ARLEN(lpahb_axim_arlen),
  .LPAHB_M_AXI_ARSIZE(lpahb_axim_arsize),
  .LPAHB_M_AXI_ARBURST(lpahb_axim_arburst),
  .LPAHB_M_AXI_ARVALID(lpahb_axim_arvalid),
  .LPAHB_M_AXI_ARREADY(lpahb_axim_arready),

  //  Read Data Channel
  .LPAHB_M_AXI_RID(lpahb_axim_rid),
  .LPAHB_M_AXI_RDATA(lpahb_axim_rdata),
  .LPAHB_M_AXI_RRESP(lpahb_axim_rresp),
  .LPAHB_M_AXI_RLAST(lpahb_axim_rlast),
  .LPAHB_M_AXI_RVALID(lpahb_axim_rvalid),
  .LPAHB_M_AXI_RREADY(lpahb_axim_rready),

  // UDL AXI4 Master Interface
  //  Write Address Channel
  .UDL_M_AXI_AWID(UDL_AXIS_AWID),
  .UDL_M_AXI_AWADDR(UDL_AXIS_AWADDR),
  .UDL_M_AXI_AWLEN(UDL_AXIS_AWLEN),
  .UDL_M_AXI_AWSIZE(UDL_AXIS_AWSIZE),
  .UDL_M_AXI_AWBURST(UDL_AXIS_AWBURST),
  .UDL_M_AXI_AWLOCK(UDL_AXIS_AWLOCK),
  .UDL_M_AXI_AWCACHE(UDL_AXIS_AWCACHE),
  .UDL_M_AXI_AWPROT(UDL_AXIS_AWPROT),
  .UDL_M_AXI_AWREGION(UDL_AXIS_AWREGION),
  .UDL_M_AXI_AWQOS(UDL_AXIS_AWQOS),
  .UDL_M_AXI_AWVALID(UDL_AXIS_AWVALID),
  .UDL_M_AXI_AWREADY(UDL_AXIS_AWREADY),
  //  Write Data Channel
  .UDL_M_AXI_WDATA(UDL_AXIS_WDATA),
  .UDL_M_AXI_WSTRB(UDL_AXIS_WSTRB),
  .UDL_M_AXI_WLAST(UDL_AXIS_WLAST),
  .UDL_M_AXI_WVALID(UDL_AXIS_WVALID),
  .UDL_M_AXI_WREADY(UDL_AXIS_WREADY),
  //  Write Responce Channel
  .UDL_M_AXI_BID(UDL_AXIS_BID),
  .UDL_M_AXI_BRESP(UDL_AXIS_BRESP),
  .UDL_M_AXI_BVALID(UDL_AXIS_BVALID),
  .UDL_M_AXI_BREADY(UDL_AXIS_BREADY),
  //  Read Address Channel
  .UDL_M_AXI_ARID(UDL_AXIS_ARID),
  .UDL_M_AXI_ARADDR(UDL_AXIS_ARADDR),
  .UDL_M_AXI_ARLEN(UDL_AXIS_ARLEN),
  .UDL_M_AXI_ARSIZE(UDL_AXIS_ARSIZE),
  .UDL_M_AXI_ARBURST(UDL_AXIS_ARBURST),
  .UDL_M_AXI_ARLOCK(UDL_AXIS_ARLOCK),
  .UDL_M_AXI_ARCACHE(UDL_AXIS_ARCACHE),
  .UDL_M_AXI_ARPROT(UDL_AXIS_ARPROT),
  .UDL_M_AXI_ARREGION(UDL_AXIS_ARREGION),
  .UDL_M_AXI_ARQOS(UDL_AXIS_ARQOS),
  .UDL_M_AXI_ARVALID(UDL_AXIS_ARVALID),
  .UDL_M_AXI_ARREADY(UDL_AXIS_ARREADY),
  //  Read Data Channel
  .UDL_M_AXI_RID(UDL_AXIS_RID),
  .UDL_M_AXI_RDATA(UDL_AXIS_RDATA),
  .UDL_M_AXI_RRESP(UDL_AXIS_RRESP),
  .UDL_M_AXI_RLAST(UDL_AXIS_RLAST),
  .UDL_M_AXI_RVALID(UDL_AXIS_RVALID),
  .UDL_M_AXI_RREADY(UDL_AXIS_RREADY),

  // NOR Flash Configuration Memory Interface
  .CFG_MEM_SCK(CFG_MEM_SCK),
  .CFG_MEM_CS_B(CFG_MEM_CS_B),
  .CFG_MEM_OE(CFG_MEM_OE),
  .CFG_MEM_DOUT(CFG_MEM_DOUT),
  .CFG_MEM_DIN(CFG_MEM_DIN),

  // NOR Flash Data Memory Interface
  .DATA_MEM1_SCK(DATA_MEM1_SCK),
  .DATA_MEM1_CS_B(DATA_MEM1_CS_B),
  .DATA_MEM1_OE(DATA_MEM1_OE),
  .DATA_MEM1_DOUT(DATA_MEM1_DOUT),
  .DATA_MEM1_DIN(DATA_MEM1_DIN),
  .DATA_MEM2_SCK(DATA_MEM2_SCK),
  .DATA_MEM2_CS_B(DATA_MEM2_CS_B),
  .DATA_MEM2_OE(DATA_MEM2_OE),
  .DATA_MEM2_DOUT(DATA_MEM2_DOUT),
  .DATA_MEM2_DIN(DATA_MEM2_DIN),

  // FeRAM Data Memory Interface
  .FRAM1_SCK(FRAM1_SCK),
  .FRAM1_CS_B(FRAM1_CS_B),
  .FRAM1_OE(FRAM1_OE),
  .FRAM1_DOUT(FRAM1_DOUT),
  .FRAM1_DIN(FRAM1_DIN),
  .FRAM2_SCK(FRAM2_SCK),
  .FRAM2_CS_B(FRAM2_CS_B),
  .FRAM2_OE(FRAM2_OE),
  .FRAM2_DOUT(FRAM2_DOUT),
  .FRAM2_DIN(FRAM2_DIN),

  // CAN Interface
  .CAN_TX(CAN_TX),
  .CAN_RX(CAN_RX),
  .CAN_SLEEP_EN(CAN_SLEEP_EN)
);

lpahb_ss # (
  .BUILD_INFO(BUILD_INFO),
  .LPAHB_AXI_ID_WIDTH(MAINAXI_S_AXI_ID_WIDTH),
  .LPAHB_UART_DIV_INIT(LPAHB_CONSOLE_UART_DIV)
) lpahb (
  // System Interface,
  .ACLK(SYS_CLK),
  .ARESETN(SYS_RSTB),
  .REF_CLK(REF_CLK),
  .SYS_RSTB_SYNC_REFCLK(SYS_RSTB_SYNC_REFCLK),
  .UARTLITE_ISR(uartlite_isr),
  .EXTERNAL_I2CM_ISR(external_i2c_isr),
  .SYSMON_HW_ISR(sysmon_hw_isr),
  .SYSMON_BHM_ISR(sysmon_bhm_isr),
  .GPTMR_GTMR_ISR(gptmr_gtmr_isr),
  .GPTMR_SITMR_ISR(gptmr_sitmr_isr),
  .TRCH_BOOT(FPGA_BOOT),
  .CLKMODE(CLKMODE),
  .CMC_REQ(CMC_REQ),
  .CMC_ACK(CMC_ACK),
  .PWR_CYCLE_REQ(FPGA_PWR_CYCLE_REQ),

  // Clock Monitor Interface
  .OSC_CLKEN(OSC_CLKEN),
  .SYS_CLK(SYS_CLK),
  .MAXI_CLK(MAXI_CLK),
  .ULPI_REFCLK(ULPI_REFCLK),
  .USER_CLK1(USER_CLK1),
  .USER_CLK2(USER_CLK2),
  .PLLLOCK(PLLLOCK),

  // AXI Write Address Channel
  .AWID(lpahb_axim_awid),
  .AWADDR(lpahb_axim_awaddr),
  .AWLEN(lpahb_axim_awlen),
  .AWSIZE(lpahb_axim_awsize),
  .AWBURST(lpahb_axim_awburst),
  .AWVALID(lpahb_axim_awvalid),
  .AWREADY(lpahb_axim_awready),

  // AXI Write Data Channel
  .WDATA(lpahb_axim_wdata),
  .WSTRB(lpahb_axim_wstrb),
  .WLAST(lpahb_axim_wlast),
  .WVALID(lpahb_axim_wvalid),
  .WREADY(lpahb_axim_wready),

  // AXI Write Responce Channel
  .BID(lpahb_axim_bid),
  .BRESP(lpahb_axim_bresp),
  .BVALID(lpahb_axim_bvalid),
  .BREADY(lpahb_axim_bready),

  // AXI Read Address Channel
  .ARID(lpahb_axim_arid),
  .ARADDR(lpahb_axim_araddr),
  .ARLEN(lpahb_axim_arlen),
  .ARSIZE(lpahb_axim_arsize),
  .ARBURST(lpahb_axim_arburst),
  .ARVALID(lpahb_axim_arvalid),
  .ARREADY(lpahb_axim_arready),

  // AXI Read Data Channel
  .RID(lpahb_axim_rid),
  .RDATA(lpahb_axim_rdata),
  .RRESP(lpahb_axim_rresp),
  .RLAST(lpahb_axim_rlast),
  .RVALID(lpahb_axim_rvalid),
  .RREADY(lpahb_axim_rready),

  // System Register Control Signal
  .POR_RSTB(POR_RSTB),
  .CFGITCMEN(cfgitcmen),
  .SYSREG_RST_REQ(REG_RST_REQ),

  // Configuration Memory Interface
  .CFG_MEM_MON(CFG_MEM_MON),
  .CFG_MEM_OWNER(cfg_mem_owner),
  .CFG_MEM_REGSEL(cfg_mem_regsel),
  .CFG_MEM_BUSY(cfg_mem_busy),

  // Uart Lite
  .UART_TX(UART_TX),
  .UART_RX(UART_RX),

  // Internal I2C
  .INTERNAL_I2CM_SDA(INTERNAL_I2CM_SDA),
  .INTERNAL_I2CM_SCL(INTERNAL_I2CM_SCL),
  .CVM_CRITICAL_B(CVM_CRITICAL_B),
  .CVM_WARNING_B(CVM_WARNING_B),
  .TEMP_ALERT_B(TEMP_ALERT_B),

  // External I2C
  .EXTERNAL_I2CM_SDA(EXTERNAL_I2CM_SDA),
  .EXTERNAL_I2CM_SCL(EXTERNAL_I2CM_SCL),

  // Watchdog Signal
  .FPGA_WATCHDOG(FPGA_WATCHDOG),

  // Debug Register Interface
  .SRAM_A_GPIO_MODE_SEL(SRAM_A_GPIO_MODE_SEL),
  .SRAM1_CE_B_GPIO_MODE_SEL(SRAM1_CE_B_GPIO_MODE_SEL),
  .SRAM1_OE_B_GPIO_MODE_SEL(SRAM1_OE_B_GPIO_MODE_SEL),
  .SRAM1_WE_B_GPIO_MODE_SEL(SRAM1_WE_B_GPIO_MODE_SEL),
  .SRAM1_BHE_B_GPIO_MODE_SEL(SRAM1_BHE_B_GPIO_MODE_SEL),
  .SRAM1_BLE_B_GPIO_MODE_SEL(SRAM1_BLE_B_GPIO_MODE_SEL),
  .SRAM2_CE_B_GPIO_MODE_SEL(SRAM2_CE_B_GPIO_MODE_SEL),
  .SRAM2_OE_B_GPIO_MODE_SEL(SRAM2_OE_B_GPIO_MODE_SEL),
  .SRAM2_WE_B_GPIO_MODE_SEL(SRAM2_WE_B_GPIO_MODE_SEL),
  .SRAM2_BHE_B_GPIO_MODE_SEL(SRAM2_BHE_B_GPIO_MODE_SEL),
  .SRAM2_BLE_B_GPIO_MODE_SEL(SRAM2_BLE_B_GPIO_MODE_SEL),
  .SRAM_A_GPIO_IN(SRAM_A_GPIO_IN),
  .SRAM1_CE_B_GPIO_IN(SRAM1_CE_B_GPIO_IN),
  .SRAM1_OE_B_GPIO_IN(SRAM1_OE_B_GPIO_IN),
  .SRAM1_WE_B_GPIO_IN(SRAM1_WE_B_GPIO_IN),
  .SRAM1_BHE_B_GPIO_IN(SRAM1_BHE_B_GPIO_IN),
  .SRAM1_BLE_B_GPIO_IN(SRAM1_BLE_B_GPIO_IN),
  .SRAM2_CE_B_GPIO_IN(SRAM2_CE_B_GPIO_IN),
  .SRAM2_OE_B_GPIO_IN(SRAM2_OE_B_GPIO_IN),
  .SRAM2_WE_B_GPIO_IN(SRAM2_WE_B_GPIO_IN),
  .SRAM2_BHE_B_GPIO_IN(SRAM2_BHE_B_GPIO_IN),
  .SRAM2_BLE_B_GPIO_IN(SRAM2_BLE_B_GPIO_IN),

  .CFG_MEM_CS_B_GPIO_MODE_SEL(CFG_MEM_CS_B_GPIO_MODE_SEL),
  .CFG_MEM_IO_GPIO_MODE_SEL(CFG_MEM_IO_GPIO_MODE_SEL),
  .CFG_MEM_CS_B_GPIO_IN(CFG_MEM_CS_B_GPIO_IN),
  .CFG_MEM_IO_GPIO_IN(CFG_MEM_IO_GPIO_IN),

  .DATA_MEM1_CS_B_GPIO_MODE_SEL(DATA_MEM1_CS_B_GPIO_MODE_SEL),
  .DATA_MEM1_IO_GPIO_MODE_SEL(DATA_MEM1_IO_GPIO_MODE_SEL),
  .DATA_MEM2_CS_B_GPIO_MODE_SEL(DATA_MEM2_CS_B_GPIO_MODE_SEL),
  .DATA_MEM2_IO_GPIO_MODE_SEL(DATA_MEM2_IO_GPIO_MODE_SEL),
  .DATA_MEM1_CS_B_GPIO_IN(DATA_MEM1_CS_B_GPIO_IN),
  .DATA_MEM1_IO_GPIO_IN(DATA_MEM1_IO_GPIO_IN),
  .DATA_MEM2_CS_B_GPIO_IN(DATA_MEM2_CS_B_GPIO_IN),
  .DATA_MEM2_IO_GPIO_IN(DATA_MEM2_IO_GPIO_IN),

  .FRAM1_CS_B_GPIO_MODE_SEL(FRAM1_CS_B_GPIO_MODE_SEL),
  .FRAM1_IO_GPIO_MODE_SEL(FRAM1_IO_GPIO_MODE_SEL),
  .FRAM2_CS_B_GPIO_MODE_SEL(FRAM2_CS_B_GPIO_MODE_SEL),
  .FRAM2_IO_GPIO_MODE_SEL(FRAM2_IO_GPIO_MODE_SEL),
  .FRAM1_CS_B_GPIO_IN(FRAM1_CS_B_GPIO_IN),
  .FRAM1_IO_GPIO_IN(FRAM1_IO_GPIO_IN),
  .FRAM2_CS_B_GPIO_IN(FRAM2_CS_B_GPIO_IN),
  .FRAM2_IO_GPIO_IN(FRAM2_IO_GPIO_IN),

  .SYSCLK2_STATE(SYSCLK2_STATE),
  .SYSCLK1_STATE(SYSCLK1_STATE),

  .EXT_I2C_SCL_GPIO_MODE_SEL(EXT_I2C_SCL_GPIO_MODE_SEL),
  .EXT_I2C_SDA_GPIO_MODE_SEL(EXT_I2C_SDA_GPIO_MODE_SEL),
  .EXT_I2C_SCL_GPIO_IN(EXT_I2C_SCL_GPIO_IN),
  .EXT_I2C_SDA_GPIO_IN(EXT_I2C_SDA_GPIO_IN),

  .FPGA_BOOT_SHIFTREG_IN(FPGA_BOOT_SHIFTREG_IN),
  .FPGA_WATCHDOG_GPIO_MODE_SEL(FPGA_WATCHDOG_GPIO_MODE_SEL),
  .FPGA_PWR_CYCLE_REQ_GPIO_MODE_SEL(FPGA_PWR_CYCLE_REQ_GPIO_MODE_SEL),
  .FPGA_RESERVE_GPIO_MODE_SEL(FPGA_RESERVE_GPIO_MODE_SEL),
  .FPGA_BOOT0_GPIO_MODE_SEL(FPGA_BOOT0_GPIO_MODE_SEL),
  .FPGA_BOOT1_GPIO_MODE_SEL(FPGA_BOOT1_GPIO_MODE_SEL),
  .FPGA_WATCHDOG_GPIO_IN(FPGA_WATCHDOG_GPIO_IN),
  .FPGA_PWR_CYCLE_REQ_GPIO_IN(FPGA_PWR_CYCLE_REQ_GPIO_IN),
  .FPGA_RESERVE_GPIO_IN(FPGA_RESERVE_GPIO_IN),
  .FPGA_BOOT0_GPIO_IN(FPGA_BOOT0_GPIO_IN),
  .FPGA_BOOT1_GPIO_IN(FPGA_BOOT1_GPIO_IN),

  .ULPI_CLOCK_STATE(ULPI_CLOCK_STATE),
  .ULPI_RESET_B_GPIO_MODE_SEL(ULPI_RESET_B_GPIO_MODE_SEL),
  .ULPI_CS_GPIO_MODE_SEL(ULPI_CS_GPIO_MODE_SEL),
  .ULPI_RESET_B_GPIO_IN(ULPI_RESET_B_GPIO_IN),
  .ULPI_CS_GPIO_IN(ULPI_CS_GPIO_IN),

  .PUDC_B(PUDC_B),

  .UIO1_GPIO_MODE_SEL(UIO1_GPIO_MODE_SEL),
  .UIO1_GPIO_IN(UIO1_GPIO_IN),

  .UIO2_GPIO_MODE_SEL(UIO2_GPIO_MODE_SEL),
  .UIO2_GPIO_IN(UIO2_GPIO_IN),

  .UIO4_GPIO_MODE_SEL(UIO4_GPIO_MODE_SEL),
  .UIO4_GPIO_IN(UIO4_GPIO_IN),

  .RSV_GPIO_MODE_SEL(RSV_GPIO_MODE_SEL),
  .RSV_GPIO_IN(RSV_GPIO_IN)
);

assign CFG_MEM_SEL = (!cfg_mem_owner) ? cfg_mem_regsel: 1'b0;

assign ULPI_CS = 1'b0;
assign ULPI_RESET_B = 1'b1;
assign ULPI_STP = 1'b0;
assign ULPI_DATA = 8'h0;

endmodule
