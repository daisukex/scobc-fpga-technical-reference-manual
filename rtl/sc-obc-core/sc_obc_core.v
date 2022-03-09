//-----------------------------------------------
// Space Cubics OBC Core
//  Space Cubics CORE TOP
//  Module: sc_obc_core
//-----------------------------------------------
// Copyright © 2022 Space Cubics, LLC.
//-----------------------------------------------

module sc_obc_core # (
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
  input PLLLOCK,
  // Reset
  output SYS_RST_REQ,
  output REG_RST_REQ,
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
  input CDRST_B,
  output CFG_DONE,
  input [1:0] FPGA_BOOT,
  output FPGA_WATCHDOG,
  inout FPGA_RESERVE,

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
  inout  [3:0] CFG_MEM_IO,

  // NOR Flash Data Memory Interface
  // ------------------------------
  output DATA_MEM1_SCK,
  output DATA_MEM1_CS_B,
  inout  [3:0] DATA_MEM1_IO,
  output DATA_MEM2_SCK,
  output DATA_MEM2_CS_B,
  inout  [3:0] DATA_MEM2_IO,

  // FeRAM Data Memory Interface
  // ------------------------------
  output FRAM1_SCK,
  output FRAM1_CS_B,
  inout  [3:0] FRAM1_IO,
  output FRAM2_SCK,
  output FRAM2_CS_B,
  inout  [3:0] FRAM2_IO,

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
  output NTDOEN
);

assign INIT_DONE = INIT_REQ;
assign CPU_LOCKUP_RSTEN = 0;

localparam LPAHB_CONSOLE_UART_DIV = 16'h01A0;
localparam CM3SS_PRIMARY_ISR_NUM = 8;

// SC-OBC-SS Interrupt Signal
wire [CM3SS_PRIMARY_ISR_NUM-1:0] internal_isr;
wire cfgmem_qspi_isr;
wire datamem_qspi_isr;
wire fram_qspi_isr;
wire canc_isr;
wire uartlite_isr;
wire internal_i2c_isr;
wire external_i2c_isr;
assign internal_isr[7] = external_i2c_isr;
assign internal_isr[6] = internal_i2c_isr;
assign internal_isr[5] = canc_isr;
assign internal_isr[4] = fram_qspi_isr;
assign internal_isr[3] = datamem_qspi_isr;
assign internal_isr[2] = cfgmem_qspi_isr;
assign internal_isr[1] = 1'b0;
assign internal_isr[0] = uartlite_isr;

wire cfgitcmen;

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
  .CM3_COD_HSEL(/*open*/),
  .CM3_COD_HTRANS(/*open*/),
  .CM3_COD_HADDR(/*open*/),
  .CM3_COD_HBURST(/*open*/),
  .CM3_COD_HWRITE(/*open*/),
  .CM3_COD_HSIZE(/*open*/),
  .CM3_COD_HPROT(/*open*/),
  .CM3_COD_HWDATA(/*open*/),
  .CM3_COD_HREADY(1'b1),
  .CM3_COD_HRDATA(32'h0000_0000),
  .CM3_COD_HRESP(2'b00),

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
  .CFG_MEM_IO(CFG_MEM_IO),

  // NOR Flash Data Memory Interface
  .DATA_MEM1_SCK(DATA_MEM1_SCK),
  .DATA_MEM1_CS_B(DATA_MEM1_CS_B),
  .DATA_MEM1_IO(DATA_MEM1_IO),
  .DATA_MEM2_SCK(DATA_MEM2_SCK),
  .DATA_MEM2_CS_B(DATA_MEM2_CS_B),
  .DATA_MEM2_IO(DATA_MEM2_IO),

  // FeRAM Data Memory Interface
  .FRAM1_SCK(FRAM1_SCK),
  .FRAM1_CS_B(FRAM1_CS_B),
  .FRAM1_IO(FRAM1_IO),
  .FRAM2_SCK(FRAM2_SCK),
  .FRAM2_CS_B(FRAM2_CS_B),
  .FRAM2_IO(FRAM2_IO),

  // CAN Interface
  .CAN_TX(CAN_TX),
  .CAN_RX(CAN_RX),
  .CAN_SLEEP_EN(CAN_SLEEP_EN)
);

lpahb_ss # (
  .LPAHB_AXI_ID_WIDTH(MAINAXI_S_AXI_ID_WIDTH),
  .LPAHB_UART_DIV_INIT(LPAHB_CONSOLE_UART_DIV)
) lpahb (
  // System Interface,
  .ACLK(SYS_CLK),
  .ARESETN(SYS_RSTB),
  .UARTLITE_ISR(uartlite_isr),
  .INTERNAL_I2CM_ISR(internal_i2c_isr),
  .EXTERNAL_I2CM_ISR(external_i2c_isr),
  .CLKMODE(CLKMODE),
  .CMC_REQ(CMC_REQ),
  .CMC_ACK(CMC_ACK),

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

  // Uart Lite
  .UART_TX(UART_TX),
  .UART_RX(UART_RX),

  // Internal I2C
  .INTERNAL_I2CM_SDA(INTERNAL_I2CM_SDA),
  .INTERNAL_I2CM_SCL(INTERNAL_I2CM_SCL),

  // External I2C
  .EXTERNAL_I2CM_SDA(EXTERNAL_I2CM_SDA),
  .EXTERNAL_I2CM_SCL(EXTERNAL_I2CM_SCL)
);

assign CFG_DONE = 1'b1;
assign FPGA_WATCHDOG = 1'b0;

assign CFG_MEM_SEL = 1'b0;

assign SRAM_A = 20'h0;
assign SRAM1_CE_B = 1'b1;
assign SRAM1_OE_B = 1'b1;
assign SRAM1_WE_B = 1'b1;
assign SRAM1_BHE_B = 1'b1;
assign SRAM1_BLE_B = 1'b1;
assign SRAM1_IO = 16'h0;
assign SRAM2_CE_B = 1'b1;
assign SRAM2_OE_B = 1'b1;
assign SRAM2_WE_B = 1'b1;
assign SRAM2_BHE_B = 1'b1;
assign SRAM2_BLE_B = 1'b1;
assign SRAM2_IO = 16'h0;

assign ULPI_CS = 1'b0;
assign ULPI_RESET_B = 1'b1;
assign ULPI_STP = 1'b0;
assign ULPI_DATA = 8'h0;

endmodule
