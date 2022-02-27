//-----------------------------------------------
// Module: main_axi_ss
//  Main AXI Bus Sub System
//-----------------------------------------------
// Copyright © 2022 Space Cubics, LLC.
//-----------------------------------------------
module main_axi_ss # (
  parameter MAINAXI_UDL_M_AXI_ID_WIDTH = 2,
  parameter MAINAXI_S_AXI_ID_WIDTH = 3
) (
  // System Interface
  input  SYS_CLK,
  input  REF_CLK,
  input  SYS_RSTB,
  input  SYS_RSTB_SYNC_REFCLK,
  input  BUS_RSTB,

  output CFG_MEM_INT,
  output DATA_MEM_INT,
  output FRAM_INT,
  output CAN_INT,

  // CPU SYS AXI3 Slave Interface
  input  [31:0] CPU_SYS_S_AXI_AWADDR,
  input  [3:0] CPU_SYS_S_AXI_AWLEN,
  input  [2:0] CPU_SYS_S_AXI_AWSIZE,
  input  [1:0] CPU_SYS_S_AXI_AWBURST,
  input  [1:0] CPU_SYS_S_AXI_AWLOCK,
  input  [3:0] CPU_SYS_S_AXI_AWCACHE,
  input  [2:0] CPU_SYS_S_AXI_AWPROT,
  input  CPU_SYS_S_AXI_AWVALID,
  output CPU_SYS_S_AXI_AWREADY,
  input  [31:0] CPU_SYS_S_AXI_WDATA,
  input  [3:0] CPU_SYS_S_AXI_WSTRB,
  input  CPU_SYS_S_AXI_WLAST,
  input  CPU_SYS_S_AXI_WVALID,
  output CPU_SYS_S_AXI_WREADY,
  output [1:0] CPU_SYS_S_AXI_BRESP,
  output CPU_SYS_S_AXI_BVALID,
  input  CPU_SYS_S_AXI_BREADY,
  input  [31:0] CPU_SYS_S_AXI_ARADDR,
  input  [3:0] CPU_SYS_S_AXI_ARLEN,
  input  [2:0] CPU_SYS_S_AXI_ARSIZE,
  input  [1:0] CPU_SYS_S_AXI_ARBURST,
  input  [1:0] CPU_SYS_S_AXI_ARLOCK,
  input  [3:0] CPU_SYS_S_AXI_ARCACHE,
  input  [2:0] CPU_SYS_S_AXI_ARPROT,
  input  CPU_SYS_S_AXI_ARVALID,
  output CPU_SYS_S_AXI_ARREADY,
  output [31:0] CPU_SYS_S_AXI_RDATA,
  output [1:0] CPU_SYS_S_AXI_RRESP,
  output CPU_SYS_S_AXI_RLAST,
  output CPU_SYS_S_AXI_RVALID,
  input  CPU_SYS_S_AXI_RREADY,

  // UDL AXI4 Slave Interface
  input  [MAINAXI_UDL_M_AXI_ID_WIDTH-1:0] UDL_S_AXI_AWID,
  input  [31:0] UDL_S_AXI_AWADDR,
  input  [7:0] UDL_S_AXI_AWLEN,
  input  [2:0] UDL_S_AXI_AWSIZE,
  input  [1:0] UDL_S_AXI_AWBURST,
  input  UDL_S_AXI_AWLOCK,
  input  [3:0] UDL_S_AXI_AWCACHE,
  input  [2:0] UDL_S_AXI_AWPROT,
  input  [3:0] UDL_S_AXI_AWQOS,
  input  UDL_S_AXI_AWVALID,
  output UDL_S_AXI_AWREADY,
  input  [31:0] UDL_S_AXI_WDATA,
  input  [3:0] UDL_S_AXI_WSTRB,
  input  UDL_S_AXI_WLAST,
  input  UDL_S_AXI_WVALID,
  output UDL_S_AXI_WREADY,
  output [MAINAXI_UDL_M_AXI_ID_WIDTH-1:0] UDL_S_AXI_BID,
  output [1:0] UDL_S_AXI_BRESP,
  output UDL_S_AXI_BVALID,
  input  UDL_S_AXI_BREADY,
  input  [MAINAXI_UDL_M_AXI_ID_WIDTH-1:0] UDL_S_AXI_ARID,
  input  [31:0] UDL_S_AXI_ARADDR,
  input  [7:0] UDL_S_AXI_ARLEN,
  input  [2:0] UDL_S_AXI_ARSIZE,
  input  [1:0] UDL_S_AXI_ARBURST,
  input  UDL_S_AXI_ARLOCK,
  input  [3:0] UDL_S_AXI_ARCACHE,
  input  [2:0] UDL_S_AXI_ARPROT,
  input  [3:0] UDL_S_AXI_ARQOS,
  input  UDL_S_AXI_ARVALID,
  output UDL_S_AXI_ARREADY,
  output [MAINAXI_UDL_M_AXI_ID_WIDTH-1:0] UDL_S_AXI_RID,
  output [31:0] UDL_S_AXI_RDATA,
  output [1:0] UDL_S_AXI_RRESP,
  output UDL_S_AXI_RLAST,
  output UDL_S_AXI_RVALID,
  input  UDL_S_AXI_RREADY,

  // Low Performance AHB AXI4 Master Interface
  output [MAINAXI_S_AXI_ID_WIDTH-1:0] LPAHB_M_AXI_AWID,
  output [31:0] LPAHB_M_AXI_AWADDR,
  output [7:0] LPAHB_M_AXI_AWLEN,
  output [2:0] LPAHB_M_AXI_AWSIZE,
  output [1:0] LPAHB_M_AXI_AWBURST,
  output LPAHB_M_AXI_AWVALID,
  input  LPAHB_M_AXI_AWREADY,
  output [31:0] LPAHB_M_AXI_WDATA,
  output [3:0] LPAHB_M_AXI_WSTRB,
  output LPAHB_M_AXI_WLAST,
  output LPAHB_M_AXI_WVALID,
  input  LPAHB_M_AXI_WREADY,
  input  [MAINAXI_S_AXI_ID_WIDTH-1:0] LPAHB_M_AXI_BID,
  input  [1:0] LPAHB_M_AXI_BRESP,
  input  LPAHB_M_AXI_BVALID,
  output LPAHB_M_AXI_BREADY,
  output [MAINAXI_S_AXI_ID_WIDTH-1:0] LPAHB_M_AXI_ARID,
  output [31:0] LPAHB_M_AXI_ARADDR,
  output [7:0] LPAHB_M_AXI_ARLEN,
  output [2:0] LPAHB_M_AXI_ARSIZE,
  output [1:0] LPAHB_M_AXI_ARBURST,
  output LPAHB_M_AXI_ARVALID,
  input  LPAHB_M_AXI_ARREADY,
  input  [MAINAXI_S_AXI_ID_WIDTH-1:0] LPAHB_M_AXI_RID,
  input  [31:0] LPAHB_M_AXI_RDATA,
  input  [1:0] LPAHB_M_AXI_RRESP,
  input  LPAHB_M_AXI_RLAST,
  input  LPAHB_M_AXI_RVALID,
  output LPAHB_M_AXI_RREADY,

  // UDL AXI4 Master Interface
  output [MAINAXI_S_AXI_ID_WIDTH-1:0] UDL_M_AXI_AWID,
  output [31:0] UDL_M_AXI_AWADDR,
  output [7:0] UDL_M_AXI_AWLEN,
  output [2:0] UDL_M_AXI_AWSIZE,
  output [1:0] UDL_M_AXI_AWBURST,
  output UDL_M_AXI_AWLOCK,
  output [3:0] UDL_M_AXI_AWCACHE,
  output [2:0] UDL_M_AXI_AWPROT,
  output [3:0] UDL_M_AXI_AWREGION,
  output [3:0] UDL_M_AXI_AWQOS,
  output UDL_M_AXI_AWVALID,
  input  UDL_M_AXI_AWREADY,
  output [31:0] UDL_M_AXI_WDATA,
  output [3:0] UDL_M_AXI_WSTRB,
  output UDL_M_AXI_WLAST,
  output UDL_M_AXI_WVALID,
  input  UDL_M_AXI_WREADY,
  input  [MAINAXI_S_AXI_ID_WIDTH-1:0] UDL_M_AXI_BID,
  input  [1:0] UDL_M_AXI_BRESP,
  input  UDL_M_AXI_BVALID,
  output UDL_M_AXI_BREADY,
  output [MAINAXI_S_AXI_ID_WIDTH-1:0] UDL_M_AXI_ARID,
  output [31:0] UDL_M_AXI_ARADDR,
  output [7:0] UDL_M_AXI_ARLEN,
  output [2:0] UDL_M_AXI_ARSIZE,
  output [1:0] UDL_M_AXI_ARBURST,
  output UDL_M_AXI_ARLOCK,
  output [3:0] UDL_M_AXI_ARCACHE,
  output [2:0] UDL_M_AXI_ARPROT,
  output [3:0] UDL_M_AXI_ARREGION,
  output [3:0] UDL_M_AXI_ARQOS,
  output UDL_M_AXI_ARVALID,
  input  UDL_M_AXI_ARREADY,
  input  [MAINAXI_S_AXI_ID_WIDTH-1:0] UDL_M_AXI_RID,
  input  [31:0] UDL_M_AXI_RDATA,
  input  [1:0] UDL_M_AXI_RRESP,
  input  UDL_M_AXI_RLAST,
  input  UDL_M_AXI_RVALID,
  output UDL_M_AXI_RREADY,

  // NOR Flash Configuration Memory Interface
  output CFG_MEM_SCK,
  output CFG_MEM_CS_B,
  inout  [3:0] CFG_MEM_IO,

  // NOR Flash Data Memory Interface
  output DATA_MEM1_SCK,
  output DATA_MEM1_CS_B,
  inout  [3:0] DATA_MEM1_IO,
  output DATA_MEM2_SCK,
  output DATA_MEM2_CS_B,
  inout  [3:0] DATA_MEM2_IO,

  // FeRAM Data Memory Interface
  output FRAM1_SCK,
  output FRAM1_CS_B,
  inout  [3:0] FRAM1_IO,
  output FRAM2_SCK,
  output FRAM2_CS_B,
  inout  [3:0] FRAM2_IO,

  // CAN Interface
  output CAN_TX,
  input  CAN_RX,
  output CAN_SLEEP_EN
);

localparam MAINAXI_CRSBAR_S_PORTS = 2;
localparam MAINAXI_CRSBAR_S_PORT_NUM_CPU_SYS = 0;
localparam MAINAXI_CRSBAR_S_PORT_NUM_UDL = 1;

localparam MAINAXI_CRSBAR_M_PORTS = 10;
localparam MAINAXI_CRSBAR_M_PORT_NUM_HRMEM_SRAM = 0;
localparam MAINAXI_CRSBAR_M_PORT_NUM_QSPI_CFG = 1;
localparam MAINAXI_CRSBAR_M_PORT_NUM_QSPI_DATA = 2;
localparam MAINAXI_CRSBAR_M_PORT_NUM_QSPI_FRAM = 3;
localparam MAINAXI_CRSBAR_M_PORT_NUM_HRMEM_BRAM = 4;
localparam MAINAXI_CRSBAR_M_PORT_NUM_CAN = 5;
localparam MAINAXI_CRSBAR_M_PORT_NUM_HRMEM_SRAM_REG = 6;
localparam MAINAXI_CRSBAR_M_PORT_NUM_HRMEM_BRAM_REG = 7;
localparam MAINAXI_CRSBAR_M_PORT_NUM_LPAHB = 8;
localparam MAINAXI_CRSBAR_M_PORT_NUM_UDL = 9;

wire [MAINAXI_S_AXI_ID_WIDTH*MAINAXI_CRSBAR_S_PORTS-1:0] w_crsbar_s_axi_awid;
wire [32*MAINAXI_CRSBAR_S_PORTS-1:0] w_crsbar_s_axi_awaddr;
wire [8*MAINAXI_CRSBAR_S_PORTS-1:0] w_crsbar_s_axi_awlen;
wire [3*MAINAXI_CRSBAR_S_PORTS-1:0] w_crsbar_s_axi_awsize;
wire [2*MAINAXI_CRSBAR_S_PORTS-1:0] w_crsbar_s_axi_awburst;
wire [1*MAINAXI_CRSBAR_S_PORTS-1:0] w_crsbar_s_axi_awlock;
wire [4*MAINAXI_CRSBAR_S_PORTS-1:0] w_crsbar_s_axi_awcache;
wire [3*MAINAXI_CRSBAR_S_PORTS-1:0] w_crsbar_s_axi_awprot;
wire [4*MAINAXI_CRSBAR_S_PORTS-1:0] w_crsbar_s_axi_awqos;
wire [1*MAINAXI_CRSBAR_S_PORTS-1:0] w_crsbar_s_axi_awvalid;
wire [1*MAINAXI_CRSBAR_S_PORTS-1:0] w_crsbar_s_axi_awready;
wire [32*MAINAXI_CRSBAR_S_PORTS-1:0] w_crsbar_s_axi_wdata;
wire [4*MAINAXI_CRSBAR_S_PORTS-1:0] w_crsbar_s_axi_wstrb;
wire [1*MAINAXI_CRSBAR_S_PORTS-1:0] w_crsbar_s_axi_wlast;
wire [1*MAINAXI_CRSBAR_S_PORTS-1:0] w_crsbar_s_axi_wvalid;
wire [1*MAINAXI_CRSBAR_S_PORTS-1:0] w_crsbar_s_axi_wready;
wire [MAINAXI_S_AXI_ID_WIDTH*MAINAXI_CRSBAR_S_PORTS-1:0] w_crsbar_s_axi_bid;
wire [2*MAINAXI_CRSBAR_S_PORTS-1:0] w_crsbar_s_axi_bresp;
wire [1*MAINAXI_CRSBAR_S_PORTS-1:0] w_crsbar_s_axi_bvalid;
wire [1*MAINAXI_CRSBAR_S_PORTS-1:0] w_crsbar_s_axi_bready;
wire [MAINAXI_S_AXI_ID_WIDTH*MAINAXI_CRSBAR_S_PORTS-1:0] w_crsbar_s_axi_arid;
wire [32*MAINAXI_CRSBAR_S_PORTS-1:0] w_crsbar_s_axi_araddr;
wire [8*MAINAXI_CRSBAR_S_PORTS-1:0] w_crsbar_s_axi_arlen;
wire [3*MAINAXI_CRSBAR_S_PORTS-1:0] w_crsbar_s_axi_arsize;
wire [2*MAINAXI_CRSBAR_S_PORTS-1:0] w_crsbar_s_axi_arburst;
wire [1*MAINAXI_CRSBAR_S_PORTS-1:0] w_crsbar_s_axi_arlock;
wire [4*MAINAXI_CRSBAR_S_PORTS-1:0] w_crsbar_s_axi_arcache;
wire [3*MAINAXI_CRSBAR_S_PORTS-1:0] w_crsbar_s_axi_arprot;
wire [4*MAINAXI_CRSBAR_S_PORTS-1:0] w_crsbar_s_axi_arqos;
wire [1*MAINAXI_CRSBAR_S_PORTS-1:0] w_crsbar_s_axi_arvalid;
wire [1*MAINAXI_CRSBAR_S_PORTS-1:0] w_crsbar_s_axi_arready;
wire [MAINAXI_S_AXI_ID_WIDTH*MAINAXI_CRSBAR_S_PORTS-1:0] w_crsbar_s_axi_rid;
wire [32*MAINAXI_CRSBAR_S_PORTS-1:0] w_crsbar_s_axi_rdata;
wire [2*MAINAXI_CRSBAR_S_PORTS-1:0] w_crsbar_s_axi_rresp;
wire [1*MAINAXI_CRSBAR_S_PORTS-1:0] w_crsbar_s_axi_rlast;
wire [1*MAINAXI_CRSBAR_S_PORTS-1:0] w_crsbar_s_axi_rvalid;
wire [1*MAINAXI_CRSBAR_S_PORTS-1:0] w_crsbar_s_axi_rready;

wire [MAINAXI_S_AXI_ID_WIDTH*MAINAXI_CRSBAR_M_PORTS-1:0] w_crsbar_m_axi_awid;
wire [32*MAINAXI_CRSBAR_M_PORTS-1:0] w_crsbar_m_axi_awaddr;
wire [8*MAINAXI_CRSBAR_M_PORTS-1:0] w_crsbar_m_axi_awlen;
wire [3*MAINAXI_CRSBAR_M_PORTS-1:0] w_crsbar_m_axi_awsize;
wire [2*MAINAXI_CRSBAR_M_PORTS-1:0] w_crsbar_m_axi_awburst;
wire [1*MAINAXI_CRSBAR_M_PORTS-1:0] w_crsbar_m_axi_awlock;
wire [4*MAINAXI_CRSBAR_M_PORTS-1:0] w_crsbar_m_axi_awcache;
wire [3*MAINAXI_CRSBAR_M_PORTS-1:0] w_crsbar_m_axi_awprot;
wire [4*MAINAXI_CRSBAR_M_PORTS-1:0] w_crsbar_m_axi_awregion;
wire [4*MAINAXI_CRSBAR_M_PORTS-1:0] w_crsbar_m_axi_awqos;
wire [1*MAINAXI_CRSBAR_M_PORTS-1:0] w_crsbar_m_axi_awvalid;
wire [1*MAINAXI_CRSBAR_M_PORTS-1:0] w_crsbar_m_axi_awready;
wire [32*MAINAXI_CRSBAR_M_PORTS-1:0] w_crsbar_m_axi_wdata;
wire [4*MAINAXI_CRSBAR_M_PORTS-1:0] w_crsbar_m_axi_wstrb;
wire [1*MAINAXI_CRSBAR_M_PORTS-1:0] w_crsbar_m_axi_wlast;
wire [1*MAINAXI_CRSBAR_M_PORTS-1:0] w_crsbar_m_axi_wvalid;
wire [1*MAINAXI_CRSBAR_M_PORTS-1:0] w_crsbar_m_axi_wready;
wire [MAINAXI_S_AXI_ID_WIDTH*MAINAXI_CRSBAR_M_PORTS-1:0] w_crsbar_m_axi_bid;
wire [2*MAINAXI_CRSBAR_M_PORTS-1:0] w_crsbar_m_axi_bresp;
wire [1*MAINAXI_CRSBAR_M_PORTS-1:0] w_crsbar_m_axi_bvalid;
wire [1*MAINAXI_CRSBAR_M_PORTS-1:0] w_crsbar_m_axi_bready;
wire [MAINAXI_S_AXI_ID_WIDTH*MAINAXI_CRSBAR_M_PORTS-1:0] w_crsbar_m_axi_arid;
wire [32*MAINAXI_CRSBAR_M_PORTS-1:0] w_crsbar_m_axi_araddr;
wire [8*MAINAXI_CRSBAR_M_PORTS-1:0] w_crsbar_m_axi_arlen;
wire [3*MAINAXI_CRSBAR_M_PORTS-1:0] w_crsbar_m_axi_arsize;
wire [2*MAINAXI_CRSBAR_M_PORTS-1:0] w_crsbar_m_axi_arburst;
wire [1*MAINAXI_CRSBAR_M_PORTS-1:0] w_crsbar_m_axi_arlock;
wire [4*MAINAXI_CRSBAR_M_PORTS-1:0] w_crsbar_m_axi_arcache;
wire [3*MAINAXI_CRSBAR_M_PORTS-1:0] w_crsbar_m_axi_arprot;
wire [4*MAINAXI_CRSBAR_M_PORTS-1:0] w_crsbar_m_axi_arregion;
wire [4*MAINAXI_CRSBAR_M_PORTS-1:0] w_crsbar_m_axi_arqos;
wire [1*MAINAXI_CRSBAR_M_PORTS-1:0] w_crsbar_m_axi_arvalid;
wire [1*MAINAXI_CRSBAR_M_PORTS-1:0] w_crsbar_m_axi_arready;
wire [MAINAXI_S_AXI_ID_WIDTH*MAINAXI_CRSBAR_M_PORTS-1:0] w_crsbar_m_axi_rid;
wire [32*MAINAXI_CRSBAR_M_PORTS-1:0] w_crsbar_m_axi_rdata;
wire [2*MAINAXI_CRSBAR_M_PORTS-1:0] w_crsbar_m_axi_rresp;
wire [1*MAINAXI_CRSBAR_M_PORTS-1:0] w_crsbar_m_axi_rlast;
wire [1*MAINAXI_CRSBAR_M_PORTS-1:0] w_crsbar_m_axi_rvalid;
wire [1*MAINAXI_CRSBAR_M_PORTS-1:0] w_crsbar_m_axi_rready;

wire [3:0] w_cfg_mem_oe;
wire [3:0] w_cfg_mem_dout;
wire [3:0] w_cfg_mem_din;

wire w_data_mem_sck;
wire w_data_mem_cs_b;
wire [3:0] w_data_mem_oe;
wire [3:0] w_data_mem_dout;
wire [3:0] w_data_mem_din;
wire [3:0] w_data_mem1_oe;
wire [3:0] w_data_mem2_oe;
wire [3:0] w_data_mem1_din;
wire [3:0] w_data_mem2_din;

wire w_fram_sck;
wire w_fram_cs_b;
wire [3:0] w_fram_oe;
wire [3:0] w_fram_dout;
wire [3:0] w_fram_din;
wire [3:0] w_fram1_oe;
wire [3:0] w_fram2_oe;
wire [3:0] w_fram1_din;
wire [3:0] w_fram2_din;

// CPU AXI3 SYS Slave Interface to main_axi_crossbar
assign w_crsbar_s_axi_awid[MAINAXI_CRSBAR_S_PORT_NUM_CPU_SYS*MAINAXI_S_AXI_ID_WIDTH +: MAINAXI_S_AXI_ID_WIDTH] = 0;
assign w_crsbar_s_axi_awaddr[MAINAXI_CRSBAR_S_PORT_NUM_CPU_SYS*32 +: 32] = CPU_SYS_S_AXI_AWADDR;
assign w_crsbar_s_axi_awlen[MAINAXI_CRSBAR_S_PORT_NUM_CPU_SYS*8 +: 8] = {4'h0, CPU_SYS_S_AXI_AWLEN};
assign w_crsbar_s_axi_awsize[MAINAXI_CRSBAR_S_PORT_NUM_CPU_SYS*3 +: 3] = CPU_SYS_S_AXI_AWSIZE;
assign w_crsbar_s_axi_awburst[MAINAXI_CRSBAR_S_PORT_NUM_CPU_SYS*2 +: 2] = CPU_SYS_S_AXI_AWBURST;
assign w_crsbar_s_axi_awlock[MAINAXI_CRSBAR_S_PORT_NUM_CPU_SYS*1 +: 1] = CPU_SYS_S_AXI_AWLOCK[0];
assign w_crsbar_s_axi_awcache[MAINAXI_CRSBAR_S_PORT_NUM_CPU_SYS*4 +: 4] = CPU_SYS_S_AXI_AWCACHE;
assign w_crsbar_s_axi_awprot[MAINAXI_CRSBAR_S_PORT_NUM_CPU_SYS*3 +: 3] = CPU_SYS_S_AXI_AWPROT;
assign w_crsbar_s_axi_awqos[MAINAXI_CRSBAR_S_PORT_NUM_CPU_SYS*4 +: 4] = 0;
assign w_crsbar_s_axi_awvalid[MAINAXI_CRSBAR_S_PORT_NUM_CPU_SYS*1 +: 1] = CPU_SYS_S_AXI_AWVALID;
assign w_crsbar_s_axi_wdata[MAINAXI_CRSBAR_S_PORT_NUM_CPU_SYS*32 +:32] = CPU_SYS_S_AXI_WDATA;
assign w_crsbar_s_axi_wstrb[MAINAXI_CRSBAR_S_PORT_NUM_CPU_SYS*4 +: 4] = CPU_SYS_S_AXI_WSTRB;
assign w_crsbar_s_axi_wlast[MAINAXI_CRSBAR_S_PORT_NUM_CPU_SYS*1 +: 1] = CPU_SYS_S_AXI_WLAST;
assign w_crsbar_s_axi_wvalid[MAINAXI_CRSBAR_S_PORT_NUM_CPU_SYS*1 +: 1] = CPU_SYS_S_AXI_WVALID;
assign w_crsbar_s_axi_bready[MAINAXI_CRSBAR_S_PORT_NUM_CPU_SYS*1 +: 1] = CPU_SYS_S_AXI_BREADY;
assign w_crsbar_s_axi_arid[MAINAXI_CRSBAR_S_PORT_NUM_CPU_SYS*MAINAXI_S_AXI_ID_WIDTH +: MAINAXI_S_AXI_ID_WIDTH] = 0;
assign w_crsbar_s_axi_araddr[MAINAXI_CRSBAR_S_PORT_NUM_CPU_SYS*32 +:32] = CPU_SYS_S_AXI_ARADDR;
assign w_crsbar_s_axi_arlen[MAINAXI_CRSBAR_S_PORT_NUM_CPU_SYS*8 +: 8] = {4'h0, CPU_SYS_S_AXI_ARLEN};
assign w_crsbar_s_axi_arsize[MAINAXI_CRSBAR_S_PORT_NUM_CPU_SYS*3 +: 3] = CPU_SYS_S_AXI_ARSIZE;
assign w_crsbar_s_axi_arburst[MAINAXI_CRSBAR_S_PORT_NUM_CPU_SYS*2 +: 2] = CPU_SYS_S_AXI_ARBURST;
assign w_crsbar_s_axi_arlock[MAINAXI_CRSBAR_S_PORT_NUM_CPU_SYS*1 +: 1] = CPU_SYS_S_AXI_ARLOCK[0];
assign w_crsbar_s_axi_arcache[MAINAXI_CRSBAR_S_PORT_NUM_CPU_SYS*4 +: 4] = CPU_SYS_S_AXI_ARCACHE;
assign w_crsbar_s_axi_arprot[MAINAXI_CRSBAR_S_PORT_NUM_CPU_SYS*3 +: 3] = CPU_SYS_S_AXI_ARPROT;
assign w_crsbar_s_axi_arqos[MAINAXI_CRSBAR_S_PORT_NUM_CPU_SYS*4 +: 4] = 0;
assign w_crsbar_s_axi_arvalid[MAINAXI_CRSBAR_S_PORT_NUM_CPU_SYS*1 +: 1] = CPU_SYS_S_AXI_ARVALID;
assign w_crsbar_s_axi_rready[MAINAXI_CRSBAR_S_PORT_NUM_CPU_SYS*1 +: 1] = CPU_SYS_S_AXI_RREADY;
assign CPU_SYS_S_AXI_AWREADY = w_crsbar_s_axi_awready[MAINAXI_CRSBAR_S_PORT_NUM_CPU_SYS*1 +: 1];
assign CPU_SYS_S_AXI_WREADY = w_crsbar_s_axi_wready[MAINAXI_CRSBAR_S_PORT_NUM_CPU_SYS*1 +: 1];
assign CPU_SYS_S_AXI_BRESP = w_crsbar_s_axi_bresp[MAINAXI_CRSBAR_S_PORT_NUM_CPU_SYS*2 +: 2];
assign CPU_SYS_S_AXI_BVALID = w_crsbar_s_axi_bvalid[MAINAXI_CRSBAR_S_PORT_NUM_CPU_SYS*1 +: 1];
assign CPU_SYS_S_AXI_ARREADY = w_crsbar_s_axi_arready[MAINAXI_CRSBAR_S_PORT_NUM_CPU_SYS*1 +: 1];
assign CPU_SYS_S_AXI_RDATA = w_crsbar_s_axi_rdata[MAINAXI_CRSBAR_S_PORT_NUM_CPU_SYS*32 +: 32];
assign CPU_SYS_S_AXI_RRESP = w_crsbar_s_axi_rresp[MAINAXI_CRSBAR_S_PORT_NUM_CPU_SYS*2 +: 2];
assign CPU_SYS_S_AXI_RLAST = w_crsbar_s_axi_rlast[MAINAXI_CRSBAR_S_PORT_NUM_CPU_SYS*1 +: 1];
assign CPU_SYS_S_AXI_RVALID = w_crsbar_s_axi_rvalid[MAINAXI_CRSBAR_S_PORT_NUM_CPU_SYS*1 +: 1];

// UDL AXI4 Slave Interface to main_axi_crossbar
assign w_crsbar_s_axi_awid[MAINAXI_CRSBAR_S_PORT_NUM_UDL*MAINAXI_S_AXI_ID_WIDTH +: MAINAXI_S_AXI_ID_WIDTH] =
       {{MAINAXI_S_AXI_ID_WIDTH-MAINAXI_UDL_M_AXI_ID_WIDTH{1'b0}}, UDL_S_AXI_AWID};
assign w_crsbar_s_axi_awaddr[MAINAXI_CRSBAR_S_PORT_NUM_UDL*32 +: 32] = UDL_S_AXI_AWADDR;
assign w_crsbar_s_axi_awlen[MAINAXI_CRSBAR_S_PORT_NUM_UDL*8 +: 8] = UDL_S_AXI_AWLEN;
assign w_crsbar_s_axi_awsize[MAINAXI_CRSBAR_S_PORT_NUM_UDL*3 +: 3] = UDL_S_AXI_AWSIZE;
assign w_crsbar_s_axi_awburst[MAINAXI_CRSBAR_S_PORT_NUM_UDL*2 +: 2] = UDL_S_AXI_AWBURST;
assign w_crsbar_s_axi_awlock[MAINAXI_CRSBAR_S_PORT_NUM_UDL*1 +: 1] = UDL_S_AXI_AWLOCK;
assign w_crsbar_s_axi_awcache[MAINAXI_CRSBAR_S_PORT_NUM_UDL*4 +: 4] = UDL_S_AXI_AWCACHE;
assign w_crsbar_s_axi_awprot[MAINAXI_CRSBAR_S_PORT_NUM_UDL*3 +: 3] = UDL_S_AXI_AWPROT;
assign w_crsbar_s_axi_awqos[MAINAXI_CRSBAR_S_PORT_NUM_UDL*4 +: 4] = UDL_S_AXI_AWQOS;
assign w_crsbar_s_axi_awvalid[MAINAXI_CRSBAR_S_PORT_NUM_UDL*1 +: 1] = UDL_S_AXI_AWVALID;
assign w_crsbar_s_axi_wdata[MAINAXI_CRSBAR_S_PORT_NUM_UDL*32 +:32] = UDL_S_AXI_WDATA;
assign w_crsbar_s_axi_wstrb[MAINAXI_CRSBAR_S_PORT_NUM_UDL*4 +: 4] = UDL_S_AXI_WSTRB;
assign w_crsbar_s_axi_wlast[MAINAXI_CRSBAR_S_PORT_NUM_UDL*1 +: 1] = UDL_S_AXI_WLAST;
assign w_crsbar_s_axi_wvalid[MAINAXI_CRSBAR_S_PORT_NUM_UDL*1 +: 1] = UDL_S_AXI_WVALID;
assign w_crsbar_s_axi_bready[MAINAXI_CRSBAR_S_PORT_NUM_UDL*1 +: 1] = UDL_S_AXI_BREADY;
assign w_crsbar_s_axi_arid[MAINAXI_CRSBAR_S_PORT_NUM_UDL*MAINAXI_S_AXI_ID_WIDTH +: MAINAXI_S_AXI_ID_WIDTH] =
       {{MAINAXI_S_AXI_ID_WIDTH-MAINAXI_UDL_M_AXI_ID_WIDTH{1'b0}}, UDL_S_AXI_ARID};
assign w_crsbar_s_axi_araddr[MAINAXI_CRSBAR_S_PORT_NUM_UDL*32 +:32] = UDL_S_AXI_ARADDR;
assign w_crsbar_s_axi_arlen[MAINAXI_CRSBAR_S_PORT_NUM_UDL*8 +: 8] = UDL_S_AXI_ARLEN;
assign w_crsbar_s_axi_arsize[MAINAXI_CRSBAR_S_PORT_NUM_UDL*3 +: 3] = UDL_S_AXI_ARSIZE;
assign w_crsbar_s_axi_arburst[MAINAXI_CRSBAR_S_PORT_NUM_UDL*2 +: 2] = UDL_S_AXI_ARBURST;
assign w_crsbar_s_axi_arlock[MAINAXI_CRSBAR_S_PORT_NUM_UDL*1 +: 1] = UDL_S_AXI_ARLOCK;
assign w_crsbar_s_axi_arcache[MAINAXI_CRSBAR_S_PORT_NUM_UDL*4 +: 4] = UDL_S_AXI_ARCACHE;
assign w_crsbar_s_axi_arprot[MAINAXI_CRSBAR_S_PORT_NUM_UDL*3 +: 3] = UDL_S_AXI_ARPROT;
assign w_crsbar_s_axi_arqos[MAINAXI_CRSBAR_S_PORT_NUM_UDL*4 +: 4] = UDL_S_AXI_ARQOS;
assign w_crsbar_s_axi_arvalid[MAINAXI_CRSBAR_S_PORT_NUM_UDL*1 +: 1] = UDL_S_AXI_ARVALID;
assign w_crsbar_s_axi_rready[MAINAXI_CRSBAR_S_PORT_NUM_UDL*1 +: 1] = UDL_S_AXI_RREADY;
assign UDL_S_AXI_AWREADY = w_crsbar_s_axi_awready[MAINAXI_CRSBAR_S_PORT_NUM_UDL*1 +: 1];
assign UDL_S_AXI_WREADY = w_crsbar_s_axi_wready[MAINAXI_CRSBAR_S_PORT_NUM_UDL*1 +: 1];
assign UDL_S_AXI_BID = w_crsbar_s_axi_bid[MAINAXI_CRSBAR_S_PORT_NUM_UDL*MAINAXI_S_AXI_ID_WIDTH +: MAINAXI_UDL_M_AXI_ID_WIDTH];
assign UDL_S_AXI_BRESP = w_crsbar_s_axi_bresp[MAINAXI_CRSBAR_S_PORT_NUM_UDL*2 +: 2];
assign UDL_S_AXI_BVALID = w_crsbar_s_axi_bvalid[MAINAXI_CRSBAR_S_PORT_NUM_UDL*1 +: 1];
assign UDL_S_AXI_ARREADY = w_crsbar_s_axi_arready[MAINAXI_CRSBAR_S_PORT_NUM_UDL*1 +: 1];
assign UDL_S_AXI_RID = w_crsbar_s_axi_rid[MAINAXI_CRSBAR_S_PORT_NUM_UDL*MAINAXI_S_AXI_ID_WIDTH +: MAINAXI_UDL_M_AXI_ID_WIDTH];
assign UDL_S_AXI_RDATA = w_crsbar_s_axi_rdata[MAINAXI_CRSBAR_S_PORT_NUM_UDL*32 +: 32];
assign UDL_S_AXI_RRESP = w_crsbar_s_axi_rresp[MAINAXI_CRSBAR_S_PORT_NUM_UDL*2 +: 2];
assign UDL_S_AXI_RLAST = w_crsbar_s_axi_rlast[MAINAXI_CRSBAR_S_PORT_NUM_UDL*1 +: 1];
assign UDL_S_AXI_RVALID = w_crsbar_s_axi_rvalid[MAINAXI_CRSBAR_S_PORT_NUM_UDL*1 +: 1];

// Main AXI Bus Crossvar
main_axi_crossbar main_axi_crossbar (
  .aclk(SYS_CLK),
  .aresetn(BUS_RSTB),
  .s_axi_awid(w_crsbar_s_axi_awid),
  .s_axi_awaddr(w_crsbar_s_axi_awaddr),
  .s_axi_awlen(w_crsbar_s_axi_awlen),
  .s_axi_awsize(w_crsbar_s_axi_awsize),
  .s_axi_awburst(w_crsbar_s_axi_awburst),
  .s_axi_awlock(w_crsbar_s_axi_awlock),
  .s_axi_awcache(w_crsbar_s_axi_awcache),
  .s_axi_awprot(w_crsbar_s_axi_awprot),
  .s_axi_awqos(w_crsbar_s_axi_awqos),
  .s_axi_awvalid(w_crsbar_s_axi_awvalid),
  .s_axi_awready(w_crsbar_s_axi_awready),
  .s_axi_wdata(w_crsbar_s_axi_wdata),
  .s_axi_wstrb(w_crsbar_s_axi_wstrb),
  .s_axi_wlast(w_crsbar_s_axi_wlast),
  .s_axi_wvalid(w_crsbar_s_axi_wvalid),
  .s_axi_wready(w_crsbar_s_axi_wready),
  .s_axi_bid(w_crsbar_s_axi_bid),
  .s_axi_bresp(w_crsbar_s_axi_bresp),
  .s_axi_bvalid(w_crsbar_s_axi_bvalid),
  .s_axi_bready(w_crsbar_s_axi_bready),
  .s_axi_arid(w_crsbar_s_axi_arid),
  .s_axi_araddr(w_crsbar_s_axi_araddr),
  .s_axi_arlen(w_crsbar_s_axi_arlen),
  .s_axi_arsize(w_crsbar_s_axi_arsize),
  .s_axi_arburst(w_crsbar_s_axi_arburst),
  .s_axi_arlock(w_crsbar_s_axi_arlock),
  .s_axi_arcache(w_crsbar_s_axi_arcache),
  .s_axi_arprot(w_crsbar_s_axi_arprot),
  .s_axi_arqos(w_crsbar_s_axi_arqos),
  .s_axi_arvalid(w_crsbar_s_axi_arvalid),
  .s_axi_arready(w_crsbar_s_axi_arready),
  .s_axi_rid(w_crsbar_s_axi_rid),
  .s_axi_rdata(w_crsbar_s_axi_rdata),
  .s_axi_rresp(w_crsbar_s_axi_rresp),
  .s_axi_rlast(w_crsbar_s_axi_rlast),
  .s_axi_rvalid(w_crsbar_s_axi_rvalid),
  .s_axi_rready(w_crsbar_s_axi_rready),
  .m_axi_awid(w_crsbar_m_axi_awid),
  .m_axi_awaddr(w_crsbar_m_axi_awaddr),
  .m_axi_awlen(w_crsbar_m_axi_awlen),
  .m_axi_awsize(w_crsbar_m_axi_awsize),
  .m_axi_awburst(w_crsbar_m_axi_awburst),
  .m_axi_awlock(w_crsbar_m_axi_awlock),
  .m_axi_awcache(w_crsbar_m_axi_awcache),
  .m_axi_awprot(w_crsbar_m_axi_awprot),
  .m_axi_awregion(w_crsbar_m_axi_awregion),
  .m_axi_awqos(w_crsbar_m_axi_awqos),
  .m_axi_awvalid(w_crsbar_m_axi_awvalid),
  .m_axi_awready(w_crsbar_m_axi_awready),
  .m_axi_wdata(w_crsbar_m_axi_wdata),
  .m_axi_wstrb(w_crsbar_m_axi_wstrb),
  .m_axi_wlast(w_crsbar_m_axi_wlast),
  .m_axi_wvalid(w_crsbar_m_axi_wvalid),
  .m_axi_wready(w_crsbar_m_axi_wready),
  .m_axi_bid(w_crsbar_m_axi_bid),
  .m_axi_bresp(w_crsbar_m_axi_bresp),
  .m_axi_bvalid(w_crsbar_m_axi_bvalid),
  .m_axi_bready(w_crsbar_m_axi_bready),
  .m_axi_arid(w_crsbar_m_axi_arid),
  .m_axi_araddr(w_crsbar_m_axi_araddr),
  .m_axi_arlen(w_crsbar_m_axi_arlen),
  .m_axi_arsize(w_crsbar_m_axi_arsize),
  .m_axi_arburst(w_crsbar_m_axi_arburst),
  .m_axi_arlock(w_crsbar_m_axi_arlock),
  .m_axi_arcache(w_crsbar_m_axi_arcache),
  .m_axi_arprot(w_crsbar_m_axi_arprot),
  .m_axi_arregion(w_crsbar_m_axi_arregion),
  .m_axi_arqos(w_crsbar_m_axi_arqos),
  .m_axi_arvalid(w_crsbar_m_axi_arvalid),
  .m_axi_arready(w_crsbar_m_axi_arready),
  .m_axi_rid(w_crsbar_m_axi_rid),
  .m_axi_rdata(w_crsbar_m_axi_rdata),
  .m_axi_rresp(w_crsbar_m_axi_rresp),
  .m_axi_rlast(w_crsbar_m_axi_rlast),
  .m_axi_rvalid(w_crsbar_m_axi_rvalid),
  .m_axi_rready(w_crsbar_m_axi_rready)
);

// High Reliability Memory Controller for SRAM (Dummy)
sc_axi_slave # (
  .P_AD_W(32),
  .P_DT_W(32),
  .P_ID_W(MAINAXI_S_AXI_ID_WIDTH)
) axi_slave_hrmem_sram_dummy (
  // AXI Interface
  .S_AXI_ACLK(SYS_CLK),
  .S_AXI_ARESETN(SYS_RSTB),
  .S_AXI_AWID(w_crsbar_m_axi_awid[MAINAXI_CRSBAR_M_PORT_NUM_HRMEM_SRAM*MAINAXI_S_AXI_ID_WIDTH +: MAINAXI_S_AXI_ID_WIDTH]),
  .S_AXI_AWADDR(w_crsbar_m_axi_awaddr[MAINAXI_CRSBAR_M_PORT_NUM_HRMEM_SRAM*32 +: 32]),
  .S_AXI_AWLEN(w_crsbar_m_axi_awlen[MAINAXI_CRSBAR_M_PORT_NUM_HRMEM_SRAM*8 +: 8]),
  .S_AXI_AWSIZE(w_crsbar_m_axi_awsize[MAINAXI_CRSBAR_M_PORT_NUM_HRMEM_SRAM*3 +: 3]),
  .S_AXI_AWBURST(w_crsbar_m_axi_awburst[MAINAXI_CRSBAR_M_PORT_NUM_HRMEM_SRAM*2 +: 2]),
  .S_AXI_AWLOCK(w_crsbar_m_axi_awlock[MAINAXI_CRSBAR_M_PORT_NUM_HRMEM_SRAM*1 +: 1]),
  .S_AXI_AWCACHE(w_crsbar_m_axi_awcache[MAINAXI_CRSBAR_M_PORT_NUM_HRMEM_SRAM*4 +: 4]),
  .S_AXI_AWPROT(w_crsbar_m_axi_awprot[MAINAXI_CRSBAR_M_PORT_NUM_HRMEM_SRAM*3 +: 3]),
  .S_AXI_AWVALID(w_crsbar_m_axi_awvalid[MAINAXI_CRSBAR_M_PORT_NUM_HRMEM_SRAM*1 +: 1]),
  .S_AXI_AWREADY(w_crsbar_m_axi_awready[MAINAXI_CRSBAR_M_PORT_NUM_HRMEM_SRAM*1 +: 1]),
  .S_AXI_WDATA(w_crsbar_m_axi_wdata[MAINAXI_CRSBAR_M_PORT_NUM_HRMEM_SRAM*32 +: 32]),
  .S_AXI_WSTRB(w_crsbar_m_axi_wstrb[MAINAXI_CRSBAR_M_PORT_NUM_HRMEM_SRAM*4 +: 4]),
  .S_AXI_WLAST(w_crsbar_m_axi_wlast[MAINAXI_CRSBAR_M_PORT_NUM_HRMEM_SRAM*1 +: 1]),
  .S_AXI_WVALID(w_crsbar_m_axi_wvalid[MAINAXI_CRSBAR_M_PORT_NUM_HRMEM_SRAM*1 +: 1]),
  .S_AXI_WREADY(w_crsbar_m_axi_wready[MAINAXI_CRSBAR_M_PORT_NUM_HRMEM_SRAM*1 +: 1]),
  .S_AXI_BID(w_crsbar_m_axi_bid[MAINAXI_CRSBAR_M_PORT_NUM_HRMEM_SRAM*MAINAXI_S_AXI_ID_WIDTH +: MAINAXI_S_AXI_ID_WIDTH]),
  .S_AXI_BRESP(w_crsbar_m_axi_bresp[MAINAXI_CRSBAR_M_PORT_NUM_HRMEM_SRAM*2 +: 2]),
  .S_AXI_BVALID(w_crsbar_m_axi_bvalid[MAINAXI_CRSBAR_M_PORT_NUM_HRMEM_SRAM*1 +: 1]),
  .S_AXI_BREADY(w_crsbar_m_axi_bready[MAINAXI_CRSBAR_M_PORT_NUM_HRMEM_SRAM*1 +: 1]),
  .S_AXI_ARID(w_crsbar_m_axi_arid[MAINAXI_CRSBAR_M_PORT_NUM_HRMEM_SRAM*MAINAXI_S_AXI_ID_WIDTH +: MAINAXI_S_AXI_ID_WIDTH]),
  .S_AXI_ARADDR(w_crsbar_m_axi_araddr[MAINAXI_CRSBAR_M_PORT_NUM_HRMEM_SRAM*32 +: 32]),
  .S_AXI_ARLEN(w_crsbar_m_axi_arlen[MAINAXI_CRSBAR_M_PORT_NUM_HRMEM_SRAM*8 +: 8]),
  .S_AXI_ARSIZE(w_crsbar_m_axi_arsize[MAINAXI_CRSBAR_M_PORT_NUM_HRMEM_SRAM*3 +: 3]),
  .S_AXI_ARBURST(w_crsbar_m_axi_arburst[MAINAXI_CRSBAR_M_PORT_NUM_HRMEM_SRAM*2 +: 2]),
  .S_AXI_ARLOCK(w_crsbar_m_axi_arlock[MAINAXI_CRSBAR_M_PORT_NUM_HRMEM_SRAM*1 +: 1]),
  .S_AXI_ARCACHE(w_crsbar_m_axi_arcache[MAINAXI_CRSBAR_M_PORT_NUM_HRMEM_SRAM*4 +: 4]),
  .S_AXI_ARPROT(w_crsbar_m_axi_arprot[MAINAXI_CRSBAR_M_PORT_NUM_HRMEM_SRAM*3 +: 3]),
  .S_AXI_ARVALID(w_crsbar_m_axi_arvalid[MAINAXI_CRSBAR_M_PORT_NUM_HRMEM_SRAM*1 +: 1]),
  .S_AXI_ARREADY(w_crsbar_m_axi_arready[MAINAXI_CRSBAR_M_PORT_NUM_HRMEM_SRAM*1 +: 1]),
  .S_AXI_RID(w_crsbar_m_axi_rid[MAINAXI_CRSBAR_M_PORT_NUM_HRMEM_SRAM*MAINAXI_S_AXI_ID_WIDTH +: MAINAXI_S_AXI_ID_WIDTH]),
  .S_AXI_RDATA(w_crsbar_m_axi_rdata[MAINAXI_CRSBAR_M_PORT_NUM_HRMEM_SRAM*32 +: 32]),
  .S_AXI_RRESP(w_crsbar_m_axi_rresp[MAINAXI_CRSBAR_M_PORT_NUM_HRMEM_SRAM*2 +: 2]),
  .S_AXI_RLAST(w_crsbar_m_axi_rlast[MAINAXI_CRSBAR_M_PORT_NUM_HRMEM_SRAM*1 +: 1]),
  .S_AXI_RVALID(w_crsbar_m_axi_rvalid[MAINAXI_CRSBAR_M_PORT_NUM_HRMEM_SRAM*1 +: 1]),
  .S_AXI_RREADY(w_crsbar_m_axi_rready[MAINAXI_CRSBAR_M_PORT_NUM_HRMEM_SRAM*1 +: 1]),
  // Register Interface
  .REG_WEN(/*open*/),
  .REG_WADDR(/*open*/),
  .REG_WBTEN(/*open*/),
  .REG_WDATA(/*open*/),
  .REG_REN(/*open*/),
  .REG_RADDR(/*open*/),
  .REG_RDATA(32'h0),
  .REG_WACCERR(1'b0),
  .REG_RACCERR(1'b0),
  .REG_RWAIT(1'b0)
);

// QSPI Master (NOR Flash Configuration Memory)
sc_qspim # (
  .SC_QSPIM_AXI_ID_WIDTH(MAINAXI_S_AXI_ID_WIDTH),
  .SC_QSPIM_DT_B_WIDTH(1),
  .SC_QSPIM_FIFO_DEPTH(4),
  .SC_QSPIM_FIFO_TYPE(1),
  .SC_QSPIM_S_DEV_NUM(1)
) qspim_flash_cfg (
  // System Interface
  .SYSCLK(SYS_CLK),
  .SYSRST_N(SYS_RSTB),
  .MODULE_RSTN(1'b1),

  // AXI Interface
  .S_AXI_AWID(w_crsbar_m_axi_awid[MAINAXI_CRSBAR_M_PORT_NUM_QSPI_CFG*MAINAXI_S_AXI_ID_WIDTH +: MAINAXI_S_AXI_ID_WIDTH]),
  .S_AXI_AWADDR(w_crsbar_m_axi_awaddr[MAINAXI_CRSBAR_M_PORT_NUM_QSPI_CFG*32 +: 32]),
  .S_AXI_AWLEN(w_crsbar_m_axi_awlen[MAINAXI_CRSBAR_M_PORT_NUM_QSPI_CFG*8 +: 8]),
  .S_AXI_AWSIZE(w_crsbar_m_axi_awsize[MAINAXI_CRSBAR_M_PORT_NUM_QSPI_CFG*3 +: 3]),
  .S_AXI_AWBURST(w_crsbar_m_axi_awburst[MAINAXI_CRSBAR_M_PORT_NUM_QSPI_CFG*2 +: 2]),
  .S_AXI_AWLOCK(w_crsbar_m_axi_awlock[MAINAXI_CRSBAR_M_PORT_NUM_QSPI_CFG*1 +: 1]),
  .S_AXI_AWCACHE(w_crsbar_m_axi_awcache[MAINAXI_CRSBAR_M_PORT_NUM_QSPI_CFG*4 +: 4]),
  .S_AXI_AWPROT(w_crsbar_m_axi_awprot[MAINAXI_CRSBAR_M_PORT_NUM_QSPI_CFG*3 +: 3]),
  .S_AXI_AWVALID(w_crsbar_m_axi_awvalid[MAINAXI_CRSBAR_M_PORT_NUM_QSPI_CFG*1 +: 1]),
  .S_AXI_AWREADY(w_crsbar_m_axi_awready[MAINAXI_CRSBAR_M_PORT_NUM_QSPI_CFG*1 +: 1]),
  .S_AXI_WDATA(w_crsbar_m_axi_wdata[MAINAXI_CRSBAR_M_PORT_NUM_QSPI_CFG*32 +: 32]),
  .S_AXI_WSTRB(w_crsbar_m_axi_wstrb[MAINAXI_CRSBAR_M_PORT_NUM_QSPI_CFG*4 +: 4]),
  .S_AXI_WLAST(w_crsbar_m_axi_wlast[MAINAXI_CRSBAR_M_PORT_NUM_QSPI_CFG*1 +: 1]),
  .S_AXI_WVALID(w_crsbar_m_axi_wvalid[MAINAXI_CRSBAR_M_PORT_NUM_QSPI_CFG*1 +: 1]),
  .S_AXI_WREADY(w_crsbar_m_axi_wready[MAINAXI_CRSBAR_M_PORT_NUM_QSPI_CFG*1 +: 1]),
  .S_AXI_BID(w_crsbar_m_axi_bid[MAINAXI_CRSBAR_M_PORT_NUM_QSPI_CFG*MAINAXI_S_AXI_ID_WIDTH +: MAINAXI_S_AXI_ID_WIDTH]),
  .S_AXI_BRESP(w_crsbar_m_axi_bresp[MAINAXI_CRSBAR_M_PORT_NUM_QSPI_CFG*2 +: 2]),
  .S_AXI_BVALID(w_crsbar_m_axi_bvalid[MAINAXI_CRSBAR_M_PORT_NUM_QSPI_CFG*1 +: 1]),
  .S_AXI_BREADY(w_crsbar_m_axi_bready[MAINAXI_CRSBAR_M_PORT_NUM_QSPI_CFG*1 +: 1]),
  .S_AXI_ARID(w_crsbar_m_axi_arid[MAINAXI_CRSBAR_M_PORT_NUM_QSPI_CFG*MAINAXI_S_AXI_ID_WIDTH +: MAINAXI_S_AXI_ID_WIDTH]),
  .S_AXI_ARADDR(w_crsbar_m_axi_araddr[MAINAXI_CRSBAR_M_PORT_NUM_QSPI_CFG*32 +: 32]),
  .S_AXI_ARLEN(w_crsbar_m_axi_arlen[MAINAXI_CRSBAR_M_PORT_NUM_QSPI_CFG*8 +: 8]),
  .S_AXI_ARSIZE(w_crsbar_m_axi_arsize[MAINAXI_CRSBAR_M_PORT_NUM_QSPI_CFG*3 +: 3]),
  .S_AXI_ARBURST(w_crsbar_m_axi_arburst[MAINAXI_CRSBAR_M_PORT_NUM_QSPI_CFG*2 +: 2]),
  .S_AXI_ARLOCK(w_crsbar_m_axi_arlock[MAINAXI_CRSBAR_M_PORT_NUM_QSPI_CFG*1 +: 1]),
  .S_AXI_ARCACHE(w_crsbar_m_axi_arcache[MAINAXI_CRSBAR_M_PORT_NUM_QSPI_CFG*4 +: 4]),
  .S_AXI_ARPROT(w_crsbar_m_axi_arprot[MAINAXI_CRSBAR_M_PORT_NUM_QSPI_CFG*3 +: 3]),
  .S_AXI_ARVALID(w_crsbar_m_axi_arvalid[MAINAXI_CRSBAR_M_PORT_NUM_QSPI_CFG*1 +: 1]),
  .S_AXI_ARREADY(w_crsbar_m_axi_arready[MAINAXI_CRSBAR_M_PORT_NUM_QSPI_CFG*1 +: 1]),
  .S_AXI_RID(w_crsbar_m_axi_rid[MAINAXI_CRSBAR_M_PORT_NUM_QSPI_CFG*MAINAXI_S_AXI_ID_WIDTH +: MAINAXI_S_AXI_ID_WIDTH]),
  .S_AXI_RDATA(w_crsbar_m_axi_rdata[MAINAXI_CRSBAR_M_PORT_NUM_QSPI_CFG*32 +: 32]),
  .S_AXI_RRESP(w_crsbar_m_axi_rresp[MAINAXI_CRSBAR_M_PORT_NUM_QSPI_CFG*2 +: 2]),
  .S_AXI_RLAST(w_crsbar_m_axi_rlast[MAINAXI_CRSBAR_M_PORT_NUM_QSPI_CFG*1 +: 1]),
  .S_AXI_RVALID(w_crsbar_m_axi_rvalid[MAINAXI_CRSBAR_M_PORT_NUM_QSPI_CFG*1 +: 1]),
  .S_AXI_RREADY(w_crsbar_m_axi_rready[MAINAXI_CRSBAR_M_PORT_NUM_QSPI_CFG*1 +: 1]),

  // QSPI Interface
  .QSPI_SCK(CFG_MEM_SCK),
  .QSPI_SS(CFG_MEM_CS_B),
  .QSPI_OE(w_cfg_mem_oe),
  .QSPI_DOUT(w_cfg_mem_dout),
  .QSPI_DIN(w_cfg_mem_din),

  // Interrupt Interface
  .QSPI_INT(CFG_MEM_INT)
);

// CFG_MEM_QSPI Data I/O
sc_qspim_data_io cfg_mem_qspim_data_io (
  .QSPI_OE(w_cfg_mem_oe),
  .QSPI_DOUT(w_cfg_mem_dout),
  .QSPI_DIN(w_cfg_mem_din),

  .QSPI_IO(CFG_MEM_IO)
);

// QSPI Master (NOR Flash Data Memory)
sc_qspim # (
  .SC_QSPIM_AXI_ID_WIDTH(MAINAXI_S_AXI_ID_WIDTH),
  .SC_QSPIM_DT_B_WIDTH(1),
  .SC_QSPIM_FIFO_DEPTH(4),
  .SC_QSPIM_FIFO_TYPE(1),
  .SC_QSPIM_S_DEV_NUM(1)
) qspim_flash_data (
  // System Interface
  .SYSCLK(SYS_CLK),
  .SYSRST_N(SYS_RSTB),
  .MODULE_RSTN(1'b1),

  // AXI Interface
  .S_AXI_AWID(w_crsbar_m_axi_awid[MAINAXI_CRSBAR_M_PORT_NUM_QSPI_DATA*MAINAXI_S_AXI_ID_WIDTH +: MAINAXI_S_AXI_ID_WIDTH]),
  .S_AXI_AWADDR(w_crsbar_m_axi_awaddr[MAINAXI_CRSBAR_M_PORT_NUM_QSPI_DATA*32 +: 32]),
  .S_AXI_AWLEN(w_crsbar_m_axi_awlen[MAINAXI_CRSBAR_M_PORT_NUM_QSPI_DATA*8 +: 8]),
  .S_AXI_AWSIZE(w_crsbar_m_axi_awsize[MAINAXI_CRSBAR_M_PORT_NUM_QSPI_DATA*3 +: 3]),
  .S_AXI_AWBURST(w_crsbar_m_axi_awburst[MAINAXI_CRSBAR_M_PORT_NUM_QSPI_DATA*2 +: 2]),
  .S_AXI_AWLOCK(w_crsbar_m_axi_awlock[MAINAXI_CRSBAR_M_PORT_NUM_QSPI_DATA*1 +: 1]),
  .S_AXI_AWCACHE(w_crsbar_m_axi_awcache[MAINAXI_CRSBAR_M_PORT_NUM_QSPI_DATA*4 +: 4]),
  .S_AXI_AWPROT(w_crsbar_m_axi_awprot[MAINAXI_CRSBAR_M_PORT_NUM_QSPI_DATA*3 +: 3]),
  .S_AXI_AWVALID(w_crsbar_m_axi_awvalid[MAINAXI_CRSBAR_M_PORT_NUM_QSPI_DATA*1 +: 1]),
  .S_AXI_AWREADY(w_crsbar_m_axi_awready[MAINAXI_CRSBAR_M_PORT_NUM_QSPI_DATA*1 +: 1]),
  .S_AXI_WDATA(w_crsbar_m_axi_wdata[MAINAXI_CRSBAR_M_PORT_NUM_QSPI_DATA*32 +: 32]),
  .S_AXI_WSTRB(w_crsbar_m_axi_wstrb[MAINAXI_CRSBAR_M_PORT_NUM_QSPI_DATA*4 +: 4]),
  .S_AXI_WLAST(w_crsbar_m_axi_wlast[MAINAXI_CRSBAR_M_PORT_NUM_QSPI_DATA*1 +: 1]),
  .S_AXI_WVALID(w_crsbar_m_axi_wvalid[MAINAXI_CRSBAR_M_PORT_NUM_QSPI_DATA*1 +: 1]),
  .S_AXI_WREADY(w_crsbar_m_axi_wready[MAINAXI_CRSBAR_M_PORT_NUM_QSPI_DATA*1 +: 1]),
  .S_AXI_BID(w_crsbar_m_axi_bid[MAINAXI_CRSBAR_M_PORT_NUM_QSPI_DATA*MAINAXI_S_AXI_ID_WIDTH +: MAINAXI_S_AXI_ID_WIDTH]),
  .S_AXI_BRESP(w_crsbar_m_axi_bresp[MAINAXI_CRSBAR_M_PORT_NUM_QSPI_DATA*2 +: 2]),
  .S_AXI_BVALID(w_crsbar_m_axi_bvalid[MAINAXI_CRSBAR_M_PORT_NUM_QSPI_DATA*1 +: 1]),
  .S_AXI_BREADY(w_crsbar_m_axi_bready[MAINAXI_CRSBAR_M_PORT_NUM_QSPI_DATA*1 +: 1]),
  .S_AXI_ARID(w_crsbar_m_axi_arid[MAINAXI_CRSBAR_M_PORT_NUM_QSPI_DATA*MAINAXI_S_AXI_ID_WIDTH +: MAINAXI_S_AXI_ID_WIDTH]),
  .S_AXI_ARADDR(w_crsbar_m_axi_araddr[MAINAXI_CRSBAR_M_PORT_NUM_QSPI_DATA*32 +: 32]),
  .S_AXI_ARLEN(w_crsbar_m_axi_arlen[MAINAXI_CRSBAR_M_PORT_NUM_QSPI_DATA*8 +: 8]),
  .S_AXI_ARSIZE(w_crsbar_m_axi_arsize[MAINAXI_CRSBAR_M_PORT_NUM_QSPI_DATA*3 +: 3]),
  .S_AXI_ARBURST(w_crsbar_m_axi_arburst[MAINAXI_CRSBAR_M_PORT_NUM_QSPI_DATA*2 +: 2]),
  .S_AXI_ARLOCK(w_crsbar_m_axi_arlock[MAINAXI_CRSBAR_M_PORT_NUM_QSPI_DATA*1 +: 1]),
  .S_AXI_ARCACHE(w_crsbar_m_axi_arcache[MAINAXI_CRSBAR_M_PORT_NUM_QSPI_DATA*4 +: 4]),
  .S_AXI_ARPROT(w_crsbar_m_axi_arprot[MAINAXI_CRSBAR_M_PORT_NUM_QSPI_DATA*3 +: 3]),
  .S_AXI_ARVALID(w_crsbar_m_axi_arvalid[MAINAXI_CRSBAR_M_PORT_NUM_QSPI_DATA*1 +: 1]),
  .S_AXI_ARREADY(w_crsbar_m_axi_arready[MAINAXI_CRSBAR_M_PORT_NUM_QSPI_DATA*1 +: 1]),
  .S_AXI_RID(w_crsbar_m_axi_rid[MAINAXI_CRSBAR_M_PORT_NUM_QSPI_DATA*MAINAXI_S_AXI_ID_WIDTH +: MAINAXI_S_AXI_ID_WIDTH]),
  .S_AXI_RDATA(w_crsbar_m_axi_rdata[MAINAXI_CRSBAR_M_PORT_NUM_QSPI_DATA*32 +: 32]),
  .S_AXI_RRESP(w_crsbar_m_axi_rresp[MAINAXI_CRSBAR_M_PORT_NUM_QSPI_DATA*2 +: 2]),
  .S_AXI_RLAST(w_crsbar_m_axi_rlast[MAINAXI_CRSBAR_M_PORT_NUM_QSPI_DATA*1 +: 1]),
  .S_AXI_RVALID(w_crsbar_m_axi_rvalid[MAINAXI_CRSBAR_M_PORT_NUM_QSPI_DATA*1 +: 1]),
  .S_AXI_RREADY(w_crsbar_m_axi_rready[MAINAXI_CRSBAR_M_PORT_NUM_QSPI_DATA*1 +: 1]),

  // QSPI Interface
  .QSPI_SCK(w_data_mem_sck),
  .QSPI_SS(w_data_mem_cs_b),
  .QSPI_OE(w_data_mem_oe),
  .QSPI_DOUT(w_data_mem_dout),
  .QSPI_DIN(w_data_mem_din),

  // Interrupt Interface
  .QSPI_INT(DATA_MEM_INT)
);

// NOR Flash Data Memory Access Select
assign DATA_MEM1_SCK = w_data_mem_sck;
assign DATA_MEM2_SCK = 1'b0;
assign DATA_MEM1_CS_B = w_data_mem_cs_b;
assign DATA_MEM2_CS_B = 1'b1;
assign w_data_mem1_oe = w_data_mem_oe;
assign w_data_mem2_oe = 4'h0;

assign w_data_mem_din = w_data_mem1_din;

// DATA_MEM_QSPI Data I/O
sc_qspim_data_io data_mem1_qspi_data_io (
  .QSPI_OE(w_data_mem1_oe),
  .QSPI_DOUT(w_data_mem_dout),
  .QSPI_DIN(w_data_mem1_din),

  .QSPI_IO(DATA_MEM1_IO)
);
sc_qspim_data_io data_mem2_qspi_data_io (
  .QSPI_OE(w_data_mem2_oe),
  .QSPI_DOUT(w_data_mem_dout),
  .QSPI_DIN(w_data_mem2_din),

  .QSPI_IO(DATA_MEM2_IO)
);

// QSPI Master (FeRAM Data Memory)
sc_qspim # (
  .SC_QSPIM_AXI_ID_WIDTH(MAINAXI_S_AXI_ID_WIDTH),
  .SC_QSPIM_DT_B_WIDTH(1),
  .SC_QSPIM_FIFO_DEPTH(4),
  .SC_QSPIM_FIFO_TYPE(1),
  .SC_QSPIM_S_DEV_NUM(1)
) qspim_fram_data (
  // System Interface
  .SYSCLK(SYS_CLK),
  .SYSRST_N(SYS_RSTB),
  .MODULE_RSTN(1'b1),

  // AXI Interface
  .S_AXI_AWID(w_crsbar_m_axi_awid[MAINAXI_CRSBAR_M_PORT_NUM_QSPI_FRAM*MAINAXI_S_AXI_ID_WIDTH +: MAINAXI_S_AXI_ID_WIDTH]),
  .S_AXI_AWADDR(w_crsbar_m_axi_awaddr[MAINAXI_CRSBAR_M_PORT_NUM_QSPI_FRAM*32 +: 32]),
  .S_AXI_AWLEN(w_crsbar_m_axi_awlen[MAINAXI_CRSBAR_M_PORT_NUM_QSPI_FRAM*8 +: 8]),
  .S_AXI_AWSIZE(w_crsbar_m_axi_awsize[MAINAXI_CRSBAR_M_PORT_NUM_QSPI_FRAM*3 +: 3]),
  .S_AXI_AWBURST(w_crsbar_m_axi_awburst[MAINAXI_CRSBAR_M_PORT_NUM_QSPI_FRAM*2 +: 2]),
  .S_AXI_AWLOCK(w_crsbar_m_axi_awlock[MAINAXI_CRSBAR_M_PORT_NUM_QSPI_FRAM*1 +: 1]),
  .S_AXI_AWCACHE(w_crsbar_m_axi_awcache[MAINAXI_CRSBAR_M_PORT_NUM_QSPI_FRAM*4 +: 4]),
  .S_AXI_AWPROT(w_crsbar_m_axi_awprot[MAINAXI_CRSBAR_M_PORT_NUM_QSPI_FRAM*3 +: 3]),
  .S_AXI_AWVALID(w_crsbar_m_axi_awvalid[MAINAXI_CRSBAR_M_PORT_NUM_QSPI_FRAM*1 +: 1]),
  .S_AXI_AWREADY(w_crsbar_m_axi_awready[MAINAXI_CRSBAR_M_PORT_NUM_QSPI_FRAM*1 +: 1]),
  .S_AXI_WDATA(w_crsbar_m_axi_wdata[MAINAXI_CRSBAR_M_PORT_NUM_QSPI_FRAM*32 +: 32]),
  .S_AXI_WSTRB(w_crsbar_m_axi_wstrb[MAINAXI_CRSBAR_M_PORT_NUM_QSPI_FRAM*4 +: 4]),
  .S_AXI_WLAST(w_crsbar_m_axi_wlast[MAINAXI_CRSBAR_M_PORT_NUM_QSPI_FRAM*1 +: 1]),
  .S_AXI_WVALID(w_crsbar_m_axi_wvalid[MAINAXI_CRSBAR_M_PORT_NUM_QSPI_FRAM*1 +: 1]),
  .S_AXI_WREADY(w_crsbar_m_axi_wready[MAINAXI_CRSBAR_M_PORT_NUM_QSPI_FRAM*1 +: 1]),
  .S_AXI_BID(w_crsbar_m_axi_bid[MAINAXI_CRSBAR_M_PORT_NUM_QSPI_FRAM*MAINAXI_S_AXI_ID_WIDTH +: MAINAXI_S_AXI_ID_WIDTH]),
  .S_AXI_BRESP(w_crsbar_m_axi_bresp[MAINAXI_CRSBAR_M_PORT_NUM_QSPI_FRAM*2 +: 2]),
  .S_AXI_BVALID(w_crsbar_m_axi_bvalid[MAINAXI_CRSBAR_M_PORT_NUM_QSPI_FRAM*1 +: 1]),
  .S_AXI_BREADY(w_crsbar_m_axi_bready[MAINAXI_CRSBAR_M_PORT_NUM_QSPI_FRAM*1 +: 1]),
  .S_AXI_ARID(w_crsbar_m_axi_arid[MAINAXI_CRSBAR_M_PORT_NUM_QSPI_FRAM*MAINAXI_S_AXI_ID_WIDTH +: MAINAXI_S_AXI_ID_WIDTH]),
  .S_AXI_ARADDR(w_crsbar_m_axi_araddr[MAINAXI_CRSBAR_M_PORT_NUM_QSPI_FRAM*32 +: 32]),
  .S_AXI_ARLEN(w_crsbar_m_axi_arlen[MAINAXI_CRSBAR_M_PORT_NUM_QSPI_FRAM*8 +: 8]),
  .S_AXI_ARSIZE(w_crsbar_m_axi_arsize[MAINAXI_CRSBAR_M_PORT_NUM_QSPI_FRAM*3 +: 3]),
  .S_AXI_ARBURST(w_crsbar_m_axi_arburst[MAINAXI_CRSBAR_M_PORT_NUM_QSPI_FRAM*2 +: 2]),
  .S_AXI_ARLOCK(w_crsbar_m_axi_arlock[MAINAXI_CRSBAR_M_PORT_NUM_QSPI_FRAM*1 +: 1]),
  .S_AXI_ARCACHE(w_crsbar_m_axi_arcache[MAINAXI_CRSBAR_M_PORT_NUM_QSPI_FRAM*4 +: 4]),
  .S_AXI_ARPROT(w_crsbar_m_axi_arprot[MAINAXI_CRSBAR_M_PORT_NUM_QSPI_FRAM*3 +: 3]),
  .S_AXI_ARVALID(w_crsbar_m_axi_arvalid[MAINAXI_CRSBAR_M_PORT_NUM_QSPI_FRAM*1 +: 1]),
  .S_AXI_ARREADY(w_crsbar_m_axi_arready[MAINAXI_CRSBAR_M_PORT_NUM_QSPI_FRAM*1 +: 1]),
  .S_AXI_RID(w_crsbar_m_axi_rid[MAINAXI_CRSBAR_M_PORT_NUM_QSPI_FRAM*MAINAXI_S_AXI_ID_WIDTH +: MAINAXI_S_AXI_ID_WIDTH]),
  .S_AXI_RDATA(w_crsbar_m_axi_rdata[MAINAXI_CRSBAR_M_PORT_NUM_QSPI_FRAM*32 +: 32]),
  .S_AXI_RRESP(w_crsbar_m_axi_rresp[MAINAXI_CRSBAR_M_PORT_NUM_QSPI_FRAM*2 +: 2]),
  .S_AXI_RLAST(w_crsbar_m_axi_rlast[MAINAXI_CRSBAR_M_PORT_NUM_QSPI_FRAM*1 +: 1]),
  .S_AXI_RVALID(w_crsbar_m_axi_rvalid[MAINAXI_CRSBAR_M_PORT_NUM_QSPI_FRAM*1 +: 1]),
  .S_AXI_RREADY(w_crsbar_m_axi_rready[MAINAXI_CRSBAR_M_PORT_NUM_QSPI_FRAM*1 +: 1]),

  // QSPI Interface
  .QSPI_SCK(w_fram_sck),
  .QSPI_SS(w_fram_cs_b),
  .QSPI_OE(w_fram_oe),
  .QSPI_DOUT(w_fram_dout),
  .QSPI_DIN(w_fram_din),

  // Interrupt Interface
  .QSPI_INT(FRAM_INT)
);

// FeRAM Data Memory Access Select
assign FRAM1_SCK = w_fram_sck;
assign FRAM2_SCK = 1'b0;
assign FRAM1_CS_B = w_fram_cs_b;
assign FRAM2_CS_B = 1'b1;
assign w_fram1_oe = w_fram_oe;
assign w_fram2_oe = 4'h0;

assign w_fram_din = w_fram1_din;

// FRAM_QSPI Data I/O
sc_qspim_data_io fram1_qspi_data_io (
  .QSPI_OE(w_fram1_oe),
  .QSPI_DOUT(w_fram_dout),
  .QSPI_DIN(w_fram1_din),

  .QSPI_IO(FRAM1_IO)
);
sc_qspim_data_io fram2_qspi_data_io (
  .QSPI_OE(w_fram2_oe),
  .QSPI_DOUT(w_fram_dout),
  .QSPI_DIN(w_fram2_din),

  .QSPI_IO(FRAM2_IO)
);

// High Reliability Memory for BlockRAM (Dummy)
sc_axi_slave # (
  .P_AD_W(32),
  .P_DT_W(32),
  .P_ID_W(MAINAXI_S_AXI_ID_WIDTH)
) axi_slave_hrmem_bram_dummy (
  // AXI Interface
  .S_AXI_ACLK(SYS_CLK),
  .S_AXI_ARESETN(SYS_RSTB),
  .S_AXI_AWID(w_crsbar_m_axi_awid[MAINAXI_CRSBAR_M_PORT_NUM_HRMEM_BRAM*MAINAXI_S_AXI_ID_WIDTH +: MAINAXI_S_AXI_ID_WIDTH]),
  .S_AXI_AWADDR(w_crsbar_m_axi_awaddr[MAINAXI_CRSBAR_M_PORT_NUM_HRMEM_BRAM*32 +: 32]),
  .S_AXI_AWLEN(w_crsbar_m_axi_awlen[MAINAXI_CRSBAR_M_PORT_NUM_HRMEM_BRAM*8 +: 8]),
  .S_AXI_AWSIZE(w_crsbar_m_axi_awsize[MAINAXI_CRSBAR_M_PORT_NUM_HRMEM_BRAM*3 +: 3]),
  .S_AXI_AWBURST(w_crsbar_m_axi_awburst[MAINAXI_CRSBAR_M_PORT_NUM_HRMEM_BRAM*2 +: 2]),
  .S_AXI_AWLOCK(w_crsbar_m_axi_awlock[MAINAXI_CRSBAR_M_PORT_NUM_HRMEM_BRAM*1 +: 1]),
  .S_AXI_AWCACHE(w_crsbar_m_axi_awcache[MAINAXI_CRSBAR_M_PORT_NUM_HRMEM_BRAM*4 +: 4]),
  .S_AXI_AWPROT(w_crsbar_m_axi_awprot[MAINAXI_CRSBAR_M_PORT_NUM_HRMEM_BRAM*3 +: 3]),
  .S_AXI_AWVALID(w_crsbar_m_axi_awvalid[MAINAXI_CRSBAR_M_PORT_NUM_HRMEM_BRAM*1 +: 1]),
  .S_AXI_AWREADY(w_crsbar_m_axi_awready[MAINAXI_CRSBAR_M_PORT_NUM_HRMEM_BRAM*1 +: 1]),
  .S_AXI_WDATA(w_crsbar_m_axi_wdata[MAINAXI_CRSBAR_M_PORT_NUM_HRMEM_BRAM*32 +: 32]),
  .S_AXI_WSTRB(w_crsbar_m_axi_wstrb[MAINAXI_CRSBAR_M_PORT_NUM_HRMEM_BRAM*4 +: 4]),
  .S_AXI_WLAST(w_crsbar_m_axi_wlast[MAINAXI_CRSBAR_M_PORT_NUM_HRMEM_BRAM*1 +: 1]),
  .S_AXI_WVALID(w_crsbar_m_axi_wvalid[MAINAXI_CRSBAR_M_PORT_NUM_HRMEM_BRAM*1 +: 1]),
  .S_AXI_WREADY(w_crsbar_m_axi_wready[MAINAXI_CRSBAR_M_PORT_NUM_HRMEM_BRAM*1 +: 1]),
  .S_AXI_BID(w_crsbar_m_axi_bid[MAINAXI_CRSBAR_M_PORT_NUM_HRMEM_BRAM*MAINAXI_S_AXI_ID_WIDTH +: MAINAXI_S_AXI_ID_WIDTH]),
  .S_AXI_BRESP(w_crsbar_m_axi_bresp[MAINAXI_CRSBAR_M_PORT_NUM_HRMEM_BRAM*2 +: 2]),
  .S_AXI_BVALID(w_crsbar_m_axi_bvalid[MAINAXI_CRSBAR_M_PORT_NUM_HRMEM_BRAM*1 +: 1]),
  .S_AXI_BREADY(w_crsbar_m_axi_bready[MAINAXI_CRSBAR_M_PORT_NUM_HRMEM_BRAM*1 +: 1]),
  .S_AXI_ARID(w_crsbar_m_axi_arid[MAINAXI_CRSBAR_M_PORT_NUM_HRMEM_BRAM*MAINAXI_S_AXI_ID_WIDTH +: MAINAXI_S_AXI_ID_WIDTH]),
  .S_AXI_ARADDR(w_crsbar_m_axi_araddr[MAINAXI_CRSBAR_M_PORT_NUM_HRMEM_BRAM*32 +: 32]),
  .S_AXI_ARLEN(w_crsbar_m_axi_arlen[MAINAXI_CRSBAR_M_PORT_NUM_HRMEM_BRAM*8 +: 8]),
  .S_AXI_ARSIZE(w_crsbar_m_axi_arsize[MAINAXI_CRSBAR_M_PORT_NUM_HRMEM_BRAM*3 +: 3]),
  .S_AXI_ARBURST(w_crsbar_m_axi_arburst[MAINAXI_CRSBAR_M_PORT_NUM_HRMEM_BRAM*2 +: 2]),
  .S_AXI_ARLOCK(w_crsbar_m_axi_arlock[MAINAXI_CRSBAR_M_PORT_NUM_HRMEM_BRAM*1 +: 1]),
  .S_AXI_ARCACHE(w_crsbar_m_axi_arcache[MAINAXI_CRSBAR_M_PORT_NUM_HRMEM_BRAM*4 +: 4]),
  .S_AXI_ARPROT(w_crsbar_m_axi_arprot[MAINAXI_CRSBAR_M_PORT_NUM_HRMEM_BRAM*3 +: 3]),
  .S_AXI_ARVALID(w_crsbar_m_axi_arvalid[MAINAXI_CRSBAR_M_PORT_NUM_HRMEM_BRAM*1 +: 1]),
  .S_AXI_ARREADY(w_crsbar_m_axi_arready[MAINAXI_CRSBAR_M_PORT_NUM_HRMEM_BRAM*1 +: 1]),
  .S_AXI_RID(w_crsbar_m_axi_rid[MAINAXI_CRSBAR_M_PORT_NUM_HRMEM_BRAM*MAINAXI_S_AXI_ID_WIDTH +: MAINAXI_S_AXI_ID_WIDTH]),
  .S_AXI_RDATA(w_crsbar_m_axi_rdata[MAINAXI_CRSBAR_M_PORT_NUM_HRMEM_BRAM*32 +: 32]),
  .S_AXI_RRESP(w_crsbar_m_axi_rresp[MAINAXI_CRSBAR_M_PORT_NUM_HRMEM_BRAM*2 +: 2]),
  .S_AXI_RLAST(w_crsbar_m_axi_rlast[MAINAXI_CRSBAR_M_PORT_NUM_HRMEM_BRAM*1 +: 1]),
  .S_AXI_RVALID(w_crsbar_m_axi_rvalid[MAINAXI_CRSBAR_M_PORT_NUM_HRMEM_BRAM*1 +: 1]),
  .S_AXI_RREADY(w_crsbar_m_axi_rready[MAINAXI_CRSBAR_M_PORT_NUM_HRMEM_BRAM*1 +: 1]),
  // Register Interface
  .REG_WEN(/*open*/),
  .REG_WADDR(/*open*/),
  .REG_WBTEN(/*open*/),
  .REG_WDATA(/*open*/),
  .REG_REN(/*open*/),
  .REG_RADDR(/*open*/),
  .REG_RDATA(32'h0),
  .REG_WACCERR(1'b0),
  .REG_RACCERR(1'b0),
  .REG_RWAIT(1'b0)
);

// CAN I/F
sc_can # (
  .SC_CAN_AXI_ID_WIDTH(MAINAXI_S_AXI_ID_WIDTH),
  .SC_CAN_FIFO_DEPTH(6),
  .SC_CAN_CLK_ASYNC(1)
) can (
  // System Interface
  .S_AXI_ARESETN(SYS_RSTB),
  .S_AXI_ACLK(SYS_CLK),
  .CAN_RSTB(SYS_RSTB_SYNC_REFCLK),
  .CAN_CLK(REF_CLK),
  .MODULE_RSTN(1'b1),

  // AXI Slave Interface
  .S_AXI_AWID(w_crsbar_m_axi_awid[MAINAXI_CRSBAR_M_PORT_NUM_CAN*MAINAXI_S_AXI_ID_WIDTH +: MAINAXI_S_AXI_ID_WIDTH]),
  .S_AXI_AWADDR(w_crsbar_m_axi_awaddr[MAINAXI_CRSBAR_M_PORT_NUM_CAN*32 +: 32]),
  .S_AXI_AWLEN(w_crsbar_m_axi_awlen[MAINAXI_CRSBAR_M_PORT_NUM_CAN*8 +: 8]),
  .S_AXI_AWSIZE(w_crsbar_m_axi_awsize[MAINAXI_CRSBAR_M_PORT_NUM_CAN*3 +: 3]),
  .S_AXI_AWBURST(w_crsbar_m_axi_awburst[MAINAXI_CRSBAR_M_PORT_NUM_CAN*2 +: 2]),
  .S_AXI_AWLOCK(w_crsbar_m_axi_awlock[MAINAXI_CRSBAR_M_PORT_NUM_CAN*1 +: 1]),
  .S_AXI_AWCACHE(w_crsbar_m_axi_awcache[MAINAXI_CRSBAR_M_PORT_NUM_CAN*4 +: 4]),
  .S_AXI_AWPROT(w_crsbar_m_axi_awprot[MAINAXI_CRSBAR_M_PORT_NUM_CAN*3 +: 3]),
  .S_AXI_AWVALID(w_crsbar_m_axi_awvalid[MAINAXI_CRSBAR_M_PORT_NUM_CAN*1 +: 1]),
  .S_AXI_AWREADY(w_crsbar_m_axi_awready[MAINAXI_CRSBAR_M_PORT_NUM_CAN*1 +: 1]),
  .S_AXI_WDATA(w_crsbar_m_axi_wdata[MAINAXI_CRSBAR_M_PORT_NUM_CAN*32 +: 32]),
  .S_AXI_WSTRB(w_crsbar_m_axi_wstrb[MAINAXI_CRSBAR_M_PORT_NUM_CAN*4 +: 4]),
  .S_AXI_WLAST(w_crsbar_m_axi_wlast[MAINAXI_CRSBAR_M_PORT_NUM_CAN*1 +: 1]),
  .S_AXI_WVALID(w_crsbar_m_axi_wvalid[MAINAXI_CRSBAR_M_PORT_NUM_CAN*1 +: 1]),
  .S_AXI_WREADY(w_crsbar_m_axi_wready[MAINAXI_CRSBAR_M_PORT_NUM_CAN*1 +: 1]),
  .S_AXI_BID(w_crsbar_m_axi_bid[MAINAXI_CRSBAR_M_PORT_NUM_CAN*MAINAXI_S_AXI_ID_WIDTH +: MAINAXI_S_AXI_ID_WIDTH]),
  .S_AXI_BRESP(w_crsbar_m_axi_bresp[MAINAXI_CRSBAR_M_PORT_NUM_CAN*2 +: 2]),
  .S_AXI_BVALID(w_crsbar_m_axi_bvalid[MAINAXI_CRSBAR_M_PORT_NUM_CAN*1 +: 1]),
  .S_AXI_BREADY(w_crsbar_m_axi_bready[MAINAXI_CRSBAR_M_PORT_NUM_CAN*1 +: 1]),
  .S_AXI_ARID(w_crsbar_m_axi_arid[MAINAXI_CRSBAR_M_PORT_NUM_CAN*MAINAXI_S_AXI_ID_WIDTH +: MAINAXI_S_AXI_ID_WIDTH]),
  .S_AXI_ARADDR(w_crsbar_m_axi_araddr[MAINAXI_CRSBAR_M_PORT_NUM_CAN*32 +: 32]),
  .S_AXI_ARLEN(w_crsbar_m_axi_arlen[MAINAXI_CRSBAR_M_PORT_NUM_CAN*8 +: 8]),
  .S_AXI_ARSIZE(w_crsbar_m_axi_arsize[MAINAXI_CRSBAR_M_PORT_NUM_CAN*3 +: 3]),
  .S_AXI_ARBURST(w_crsbar_m_axi_arburst[MAINAXI_CRSBAR_M_PORT_NUM_CAN*2 +: 2]),
  .S_AXI_ARLOCK(w_crsbar_m_axi_arlock[MAINAXI_CRSBAR_M_PORT_NUM_CAN*1 +: 1]),
  .S_AXI_ARCACHE(w_crsbar_m_axi_arcache[MAINAXI_CRSBAR_M_PORT_NUM_CAN*4 +: 4]),
  .S_AXI_ARPROT(w_crsbar_m_axi_arprot[MAINAXI_CRSBAR_M_PORT_NUM_CAN*3 +: 3]),
  .S_AXI_ARVALID(w_crsbar_m_axi_arvalid[MAINAXI_CRSBAR_M_PORT_NUM_CAN*1 +: 1]),
  .S_AXI_ARREADY(w_crsbar_m_axi_arready[MAINAXI_CRSBAR_M_PORT_NUM_CAN*1 +: 1]),
  .S_AXI_RID(w_crsbar_m_axi_rid[MAINAXI_CRSBAR_M_PORT_NUM_CAN*MAINAXI_S_AXI_ID_WIDTH +: MAINAXI_S_AXI_ID_WIDTH]),
  .S_AXI_RDATA(w_crsbar_m_axi_rdata[MAINAXI_CRSBAR_M_PORT_NUM_CAN*32 +: 32]),
  .S_AXI_RRESP(w_crsbar_m_axi_rresp[MAINAXI_CRSBAR_M_PORT_NUM_CAN*2 +: 2]),
  .S_AXI_RLAST(w_crsbar_m_axi_rlast[MAINAXI_CRSBAR_M_PORT_NUM_CAN*1 +: 1]),
  .S_AXI_RVALID(w_crsbar_m_axi_rvalid[MAINAXI_CRSBAR_M_PORT_NUM_CAN*1 +: 1]),
  .S_AXI_RREADY(w_crsbar_m_axi_rready[MAINAXI_CRSBAR_M_PORT_NUM_CAN*1 +: 1]),

  // CAN Bus Signal
  .CAN_TX(CAN_TX),
  .CAN_RX(CAN_RX),

  // CAN Transceiver Interface
  .CAN_SLEEP_EN(CAN_SLEEP_EN),

  // Interrupt Signal
  .CAN_INT(CAN_INT)
);

// High Reliability Memory Controller Register for SRAM (Dummy)
sc_axi_slave # (
  .P_AD_W(32),
  .P_DT_W(32),
  .P_ID_W(MAINAXI_S_AXI_ID_WIDTH)
) axi_slave_hrmem_sram_reg_dummy (
  // AXI Interface
  .S_AXI_ACLK(SYS_CLK),
  .S_AXI_ARESETN(SYS_RSTB),
  .S_AXI_AWID(w_crsbar_m_axi_awid[MAINAXI_CRSBAR_M_PORT_NUM_HRMEM_SRAM_REG*MAINAXI_S_AXI_ID_WIDTH +: MAINAXI_S_AXI_ID_WIDTH]),
  .S_AXI_AWADDR(w_crsbar_m_axi_awaddr[MAINAXI_CRSBAR_M_PORT_NUM_HRMEM_SRAM_REG*32 +: 32]),
  .S_AXI_AWLEN(w_crsbar_m_axi_awlen[MAINAXI_CRSBAR_M_PORT_NUM_HRMEM_SRAM_REG*8 +: 8]),
  .S_AXI_AWSIZE(w_crsbar_m_axi_awsize[MAINAXI_CRSBAR_M_PORT_NUM_HRMEM_SRAM_REG*3 +: 3]),
  .S_AXI_AWBURST(w_crsbar_m_axi_awburst[MAINAXI_CRSBAR_M_PORT_NUM_HRMEM_SRAM_REG*2 +: 2]),
  .S_AXI_AWLOCK(w_crsbar_m_axi_awlock[MAINAXI_CRSBAR_M_PORT_NUM_HRMEM_SRAM_REG*1 +: 1]),
  .S_AXI_AWCACHE(w_crsbar_m_axi_awcache[MAINAXI_CRSBAR_M_PORT_NUM_HRMEM_SRAM_REG*4 +: 4]),
  .S_AXI_AWPROT(w_crsbar_m_axi_awprot[MAINAXI_CRSBAR_M_PORT_NUM_HRMEM_SRAM_REG*3 +: 3]),
  .S_AXI_AWVALID(w_crsbar_m_axi_awvalid[MAINAXI_CRSBAR_M_PORT_NUM_HRMEM_SRAM_REG*1 +: 1]),
  .S_AXI_AWREADY(w_crsbar_m_axi_awready[MAINAXI_CRSBAR_M_PORT_NUM_HRMEM_SRAM_REG*1 +: 1]),
  .S_AXI_WDATA(w_crsbar_m_axi_wdata[MAINAXI_CRSBAR_M_PORT_NUM_HRMEM_SRAM_REG*32 +: 32]),
  .S_AXI_WSTRB(w_crsbar_m_axi_wstrb[MAINAXI_CRSBAR_M_PORT_NUM_HRMEM_SRAM_REG*4 +: 4]),
  .S_AXI_WLAST(w_crsbar_m_axi_wlast[MAINAXI_CRSBAR_M_PORT_NUM_HRMEM_SRAM_REG*1 +: 1]),
  .S_AXI_WVALID(w_crsbar_m_axi_wvalid[MAINAXI_CRSBAR_M_PORT_NUM_HRMEM_SRAM_REG*1 +: 1]),
  .S_AXI_WREADY(w_crsbar_m_axi_wready[MAINAXI_CRSBAR_M_PORT_NUM_HRMEM_SRAM_REG*1 +: 1]),
  .S_AXI_BID(w_crsbar_m_axi_bid[MAINAXI_CRSBAR_M_PORT_NUM_HRMEM_SRAM_REG*MAINAXI_S_AXI_ID_WIDTH +: MAINAXI_S_AXI_ID_WIDTH]),
  .S_AXI_BRESP(w_crsbar_m_axi_bresp[MAINAXI_CRSBAR_M_PORT_NUM_HRMEM_SRAM_REG*2 +: 2]),
  .S_AXI_BVALID(w_crsbar_m_axi_bvalid[MAINAXI_CRSBAR_M_PORT_NUM_HRMEM_SRAM_REG*1 +: 1]),
  .S_AXI_BREADY(w_crsbar_m_axi_bready[MAINAXI_CRSBAR_M_PORT_NUM_HRMEM_SRAM_REG*1 +: 1]),
  .S_AXI_ARID(w_crsbar_m_axi_arid[MAINAXI_CRSBAR_M_PORT_NUM_HRMEM_SRAM_REG*MAINAXI_S_AXI_ID_WIDTH +: MAINAXI_S_AXI_ID_WIDTH]),
  .S_AXI_ARADDR(w_crsbar_m_axi_araddr[MAINAXI_CRSBAR_M_PORT_NUM_HRMEM_SRAM_REG*32 +: 32]),
  .S_AXI_ARLEN(w_crsbar_m_axi_arlen[MAINAXI_CRSBAR_M_PORT_NUM_HRMEM_SRAM_REG*8 +: 8]),
  .S_AXI_ARSIZE(w_crsbar_m_axi_arsize[MAINAXI_CRSBAR_M_PORT_NUM_HRMEM_SRAM_REG*3 +: 3]),
  .S_AXI_ARBURST(w_crsbar_m_axi_arburst[MAINAXI_CRSBAR_M_PORT_NUM_HRMEM_SRAM_REG*2 +: 2]),
  .S_AXI_ARLOCK(w_crsbar_m_axi_arlock[MAINAXI_CRSBAR_M_PORT_NUM_HRMEM_SRAM_REG*1 +: 1]),
  .S_AXI_ARCACHE(w_crsbar_m_axi_arcache[MAINAXI_CRSBAR_M_PORT_NUM_HRMEM_SRAM_REG*4 +: 4]),
  .S_AXI_ARPROT(w_crsbar_m_axi_arprot[MAINAXI_CRSBAR_M_PORT_NUM_HRMEM_SRAM_REG*3 +: 3]),
  .S_AXI_ARVALID(w_crsbar_m_axi_arvalid[MAINAXI_CRSBAR_M_PORT_NUM_HRMEM_SRAM_REG*1 +: 1]),
  .S_AXI_ARREADY(w_crsbar_m_axi_arready[MAINAXI_CRSBAR_M_PORT_NUM_HRMEM_SRAM_REG*1 +: 1]),
  .S_AXI_RID(w_crsbar_m_axi_rid[MAINAXI_CRSBAR_M_PORT_NUM_HRMEM_SRAM_REG*MAINAXI_S_AXI_ID_WIDTH +: MAINAXI_S_AXI_ID_WIDTH]),
  .S_AXI_RDATA(w_crsbar_m_axi_rdata[MAINAXI_CRSBAR_M_PORT_NUM_HRMEM_SRAM_REG*32 +: 32]),
  .S_AXI_RRESP(w_crsbar_m_axi_rresp[MAINAXI_CRSBAR_M_PORT_NUM_HRMEM_SRAM_REG*2 +: 2]),
  .S_AXI_RLAST(w_crsbar_m_axi_rlast[MAINAXI_CRSBAR_M_PORT_NUM_HRMEM_SRAM_REG*1 +: 1]),
  .S_AXI_RVALID(w_crsbar_m_axi_rvalid[MAINAXI_CRSBAR_M_PORT_NUM_HRMEM_SRAM_REG*1 +: 1]),
  .S_AXI_RREADY(w_crsbar_m_axi_rready[MAINAXI_CRSBAR_M_PORT_NUM_HRMEM_SRAM_REG*1 +: 1]),
  // Register Interface
  .REG_WEN(/*open*/),
  .REG_WADDR(/*open*/),
  .REG_WBTEN(/*open*/),
  .REG_WDATA(/*open*/),
  .REG_REN(/*open*/),
  .REG_RADDR(/*open*/),
  .REG_RDATA(32'h0),
  .REG_WACCERR(1'b0),
  .REG_RACCERR(1'b0),
  .REG_RWAIT(1'b0)
);

// High Reliability Memory Register for BlockRAM (Dummy)
sc_axi_slave # (
  .P_AD_W(32),
  .P_DT_W(32),
  .P_ID_W(MAINAXI_S_AXI_ID_WIDTH)
) axi_slave_hrmem_bram_reg_dummy (
  // AXI Interface
  .S_AXI_ACLK(SYS_CLK),
  .S_AXI_ARESETN(SYS_RSTB),
  .S_AXI_AWID(w_crsbar_m_axi_awid[MAINAXI_CRSBAR_M_PORT_NUM_HRMEM_BRAM_REG*MAINAXI_S_AXI_ID_WIDTH +: MAINAXI_S_AXI_ID_WIDTH]),
  .S_AXI_AWADDR(w_crsbar_m_axi_awaddr[MAINAXI_CRSBAR_M_PORT_NUM_HRMEM_BRAM_REG*32 +: 32]),
  .S_AXI_AWLEN(w_crsbar_m_axi_awlen[MAINAXI_CRSBAR_M_PORT_NUM_HRMEM_BRAM_REG*8 +: 8]),
  .S_AXI_AWSIZE(w_crsbar_m_axi_awsize[MAINAXI_CRSBAR_M_PORT_NUM_HRMEM_BRAM_REG*3 +: 3]),
  .S_AXI_AWBURST(w_crsbar_m_axi_awburst[MAINAXI_CRSBAR_M_PORT_NUM_HRMEM_BRAM_REG*2 +: 2]),
  .S_AXI_AWLOCK(w_crsbar_m_axi_awlock[MAINAXI_CRSBAR_M_PORT_NUM_HRMEM_BRAM_REG*1 +: 1]),
  .S_AXI_AWCACHE(w_crsbar_m_axi_awcache[MAINAXI_CRSBAR_M_PORT_NUM_HRMEM_BRAM_REG*4 +: 4]),
  .S_AXI_AWPROT(w_crsbar_m_axi_awprot[MAINAXI_CRSBAR_M_PORT_NUM_HRMEM_BRAM_REG*3 +: 3]),
  .S_AXI_AWVALID(w_crsbar_m_axi_awvalid[MAINAXI_CRSBAR_M_PORT_NUM_HRMEM_BRAM_REG*1 +: 1]),
  .S_AXI_AWREADY(w_crsbar_m_axi_awready[MAINAXI_CRSBAR_M_PORT_NUM_HRMEM_BRAM_REG*1 +: 1]),
  .S_AXI_WDATA(w_crsbar_m_axi_wdata[MAINAXI_CRSBAR_M_PORT_NUM_HRMEM_BRAM_REG*32 +: 32]),
  .S_AXI_WSTRB(w_crsbar_m_axi_wstrb[MAINAXI_CRSBAR_M_PORT_NUM_HRMEM_BRAM_REG*4 +: 4]),
  .S_AXI_WLAST(w_crsbar_m_axi_wlast[MAINAXI_CRSBAR_M_PORT_NUM_HRMEM_BRAM_REG*1 +: 1]),
  .S_AXI_WVALID(w_crsbar_m_axi_wvalid[MAINAXI_CRSBAR_M_PORT_NUM_HRMEM_BRAM_REG*1 +: 1]),
  .S_AXI_WREADY(w_crsbar_m_axi_wready[MAINAXI_CRSBAR_M_PORT_NUM_HRMEM_BRAM_REG*1 +: 1]),
  .S_AXI_BID(w_crsbar_m_axi_bid[MAINAXI_CRSBAR_M_PORT_NUM_HRMEM_BRAM_REG*MAINAXI_S_AXI_ID_WIDTH +: MAINAXI_S_AXI_ID_WIDTH]),
  .S_AXI_BRESP(w_crsbar_m_axi_bresp[MAINAXI_CRSBAR_M_PORT_NUM_HRMEM_BRAM_REG*2 +: 2]),
  .S_AXI_BVALID(w_crsbar_m_axi_bvalid[MAINAXI_CRSBAR_M_PORT_NUM_HRMEM_BRAM_REG*1 +: 1]),
  .S_AXI_BREADY(w_crsbar_m_axi_bready[MAINAXI_CRSBAR_M_PORT_NUM_HRMEM_BRAM_REG*1 +: 1]),
  .S_AXI_ARID(w_crsbar_m_axi_arid[MAINAXI_CRSBAR_M_PORT_NUM_HRMEM_BRAM_REG*MAINAXI_S_AXI_ID_WIDTH +: MAINAXI_S_AXI_ID_WIDTH]),
  .S_AXI_ARADDR(w_crsbar_m_axi_araddr[MAINAXI_CRSBAR_M_PORT_NUM_HRMEM_BRAM_REG*32 +: 32]),
  .S_AXI_ARLEN(w_crsbar_m_axi_arlen[MAINAXI_CRSBAR_M_PORT_NUM_HRMEM_BRAM_REG*8 +: 8]),
  .S_AXI_ARSIZE(w_crsbar_m_axi_arsize[MAINAXI_CRSBAR_M_PORT_NUM_HRMEM_BRAM_REG*3 +: 3]),
  .S_AXI_ARBURST(w_crsbar_m_axi_arburst[MAINAXI_CRSBAR_M_PORT_NUM_HRMEM_BRAM_REG*2 +: 2]),
  .S_AXI_ARLOCK(w_crsbar_m_axi_arlock[MAINAXI_CRSBAR_M_PORT_NUM_HRMEM_BRAM_REG*1 +: 1]),
  .S_AXI_ARCACHE(w_crsbar_m_axi_arcache[MAINAXI_CRSBAR_M_PORT_NUM_HRMEM_BRAM_REG*4 +: 4]),
  .S_AXI_ARPROT(w_crsbar_m_axi_arprot[MAINAXI_CRSBAR_M_PORT_NUM_HRMEM_BRAM_REG*3 +: 3]),
  .S_AXI_ARVALID(w_crsbar_m_axi_arvalid[MAINAXI_CRSBAR_M_PORT_NUM_HRMEM_BRAM_REG*1 +: 1]),
  .S_AXI_ARREADY(w_crsbar_m_axi_arready[MAINAXI_CRSBAR_M_PORT_NUM_HRMEM_BRAM_REG*1 +: 1]),
  .S_AXI_RID(w_crsbar_m_axi_rid[MAINAXI_CRSBAR_M_PORT_NUM_HRMEM_BRAM_REG*MAINAXI_S_AXI_ID_WIDTH +: MAINAXI_S_AXI_ID_WIDTH]),
  .S_AXI_RDATA(w_crsbar_m_axi_rdata[MAINAXI_CRSBAR_M_PORT_NUM_HRMEM_BRAM_REG*32 +: 32]),
  .S_AXI_RRESP(w_crsbar_m_axi_rresp[MAINAXI_CRSBAR_M_PORT_NUM_HRMEM_BRAM_REG*2 +: 2]),
  .S_AXI_RLAST(w_crsbar_m_axi_rlast[MAINAXI_CRSBAR_M_PORT_NUM_HRMEM_BRAM_REG*1 +: 1]),
  .S_AXI_RVALID(w_crsbar_m_axi_rvalid[MAINAXI_CRSBAR_M_PORT_NUM_HRMEM_BRAM_REG*1 +: 1]),
  .S_AXI_RREADY(w_crsbar_m_axi_rready[MAINAXI_CRSBAR_M_PORT_NUM_HRMEM_BRAM_REG*1 +: 1]),
  // Register Interface
  .REG_WEN(/*open*/),
  .REG_WADDR(/*open*/),
  .REG_WBTEN(/*open*/),
  .REG_WDATA(/*open*/),
  .REG_REN(/*open*/),
  .REG_RADDR(/*open*/),
  .REG_RDATA(32'h0),
  .REG_WACCERR(1'b0),
  .REG_RACCERR(1'b0),
  .REG_RWAIT(1'b0)
);

// main_axi_crossbar to Low Performance AHB AXI4 Master Interface
assign LPAHB_M_AXI_AWID = w_crsbar_m_axi_awid[MAINAXI_CRSBAR_M_PORT_NUM_LPAHB*MAINAXI_S_AXI_ID_WIDTH +: MAINAXI_S_AXI_ID_WIDTH];
assign LPAHB_M_AXI_AWADDR = w_crsbar_m_axi_awaddr[MAINAXI_CRSBAR_M_PORT_NUM_LPAHB*32 +: 32];
assign LPAHB_M_AXI_AWLEN = w_crsbar_m_axi_awlen[MAINAXI_CRSBAR_M_PORT_NUM_LPAHB*8 +: 8];
assign LPAHB_M_AXI_AWSIZE = w_crsbar_m_axi_awsize[MAINAXI_CRSBAR_M_PORT_NUM_LPAHB*3 +: 3];
assign LPAHB_M_AXI_AWBURST = w_crsbar_m_axi_awburst[MAINAXI_CRSBAR_M_PORT_NUM_LPAHB*2 +: 2];
assign LPAHB_M_AXI_AWVALID = w_crsbar_m_axi_awvalid[MAINAXI_CRSBAR_M_PORT_NUM_LPAHB*1 +: 1];
assign w_crsbar_m_axi_awready[MAINAXI_CRSBAR_M_PORT_NUM_LPAHB*1 +: 1] = LPAHB_M_AXI_AWREADY;
assign LPAHB_M_AXI_WDATA = w_crsbar_m_axi_wdata[MAINAXI_CRSBAR_M_PORT_NUM_LPAHB*32 +: 32];
assign LPAHB_M_AXI_WSTRB = w_crsbar_m_axi_wstrb[MAINAXI_CRSBAR_M_PORT_NUM_LPAHB*4 +: 4];
assign LPAHB_M_AXI_WLAST = w_crsbar_m_axi_wlast[MAINAXI_CRSBAR_M_PORT_NUM_LPAHB*1 +: 1];
assign LPAHB_M_AXI_WVALID = w_crsbar_m_axi_wvalid[MAINAXI_CRSBAR_M_PORT_NUM_LPAHB*1 +: 1];
assign w_crsbar_m_axi_wready[MAINAXI_CRSBAR_M_PORT_NUM_LPAHB*1 +: 1] = LPAHB_M_AXI_WREADY;
assign w_crsbar_m_axi_bid[MAINAXI_CRSBAR_M_PORT_NUM_LPAHB*MAINAXI_S_AXI_ID_WIDTH +: MAINAXI_S_AXI_ID_WIDTH] = LPAHB_M_AXI_BID;
assign w_crsbar_m_axi_bresp[MAINAXI_CRSBAR_M_PORT_NUM_LPAHB*2 +: 2] = LPAHB_M_AXI_BRESP;
assign w_crsbar_m_axi_bvalid[MAINAXI_CRSBAR_M_PORT_NUM_LPAHB*1 +: 1] = LPAHB_M_AXI_BVALID;
assign LPAHB_M_AXI_BREADY = w_crsbar_m_axi_bready[MAINAXI_CRSBAR_M_PORT_NUM_LPAHB*1 +: 1];
assign LPAHB_M_AXI_ARID = w_crsbar_m_axi_arid[MAINAXI_CRSBAR_M_PORT_NUM_LPAHB*MAINAXI_S_AXI_ID_WIDTH +: MAINAXI_S_AXI_ID_WIDTH];
assign LPAHB_M_AXI_ARADDR = w_crsbar_m_axi_araddr[MAINAXI_CRSBAR_M_PORT_NUM_LPAHB*32 +: 32];
assign LPAHB_M_AXI_ARLEN = w_crsbar_m_axi_arlen[MAINAXI_CRSBAR_M_PORT_NUM_LPAHB*8 +: 8];
assign LPAHB_M_AXI_ARSIZE = w_crsbar_m_axi_arsize[MAINAXI_CRSBAR_M_PORT_NUM_LPAHB*3 +: 3];
assign LPAHB_M_AXI_ARBURST = w_crsbar_m_axi_arburst[MAINAXI_CRSBAR_M_PORT_NUM_LPAHB*2 +: 2];
assign LPAHB_M_AXI_ARVALID = w_crsbar_m_axi_arvalid[MAINAXI_CRSBAR_M_PORT_NUM_LPAHB*1 +: 1];
assign w_crsbar_m_axi_arready[MAINAXI_CRSBAR_M_PORT_NUM_LPAHB*1 +: 1] = LPAHB_M_AXI_ARREADY;
assign w_crsbar_m_axi_rid[MAINAXI_CRSBAR_M_PORT_NUM_LPAHB*MAINAXI_S_AXI_ID_WIDTH +: MAINAXI_S_AXI_ID_WIDTH] = LPAHB_M_AXI_RID;
assign w_crsbar_m_axi_rdata[MAINAXI_CRSBAR_M_PORT_NUM_LPAHB*32 +: 32] = LPAHB_M_AXI_RDATA;
assign w_crsbar_m_axi_rresp[MAINAXI_CRSBAR_M_PORT_NUM_LPAHB*2 +: 2] = LPAHB_M_AXI_RRESP;
assign w_crsbar_m_axi_rlast[MAINAXI_CRSBAR_M_PORT_NUM_LPAHB*1 +: 1] = LPAHB_M_AXI_RLAST;
assign w_crsbar_m_axi_rvalid[MAINAXI_CRSBAR_M_PORT_NUM_LPAHB*1 +: 1] = LPAHB_M_AXI_RVALID;
assign LPAHB_M_AXI_RREADY = w_crsbar_m_axi_rready[MAINAXI_CRSBAR_M_PORT_NUM_LPAHB*1 +: 1];

// main_axi_crossbar to UDL AXI4 Master Interface
assign UDL_M_AXI_AWID = w_crsbar_m_axi_awid[MAINAXI_CRSBAR_M_PORT_NUM_UDL*MAINAXI_S_AXI_ID_WIDTH +: MAINAXI_S_AXI_ID_WIDTH];
assign UDL_M_AXI_AWADDR = w_crsbar_m_axi_awaddr[MAINAXI_CRSBAR_M_PORT_NUM_UDL*32 +: 32];
assign UDL_M_AXI_AWLEN = w_crsbar_m_axi_awlen[MAINAXI_CRSBAR_M_PORT_NUM_UDL*8 +: 8];
assign UDL_M_AXI_AWSIZE = w_crsbar_m_axi_awsize[MAINAXI_CRSBAR_M_PORT_NUM_UDL*3 +: 3];
assign UDL_M_AXI_AWBURST = w_crsbar_m_axi_awburst[MAINAXI_CRSBAR_M_PORT_NUM_UDL*2 +: 2];
assign UDL_M_AXI_AWLOCK = w_crsbar_m_axi_awlock[MAINAXI_CRSBAR_M_PORT_NUM_UDL*1 +: 1];
assign UDL_M_AXI_AWCACHE = w_crsbar_m_axi_awcache[MAINAXI_CRSBAR_M_PORT_NUM_UDL*4 +: 4];
assign UDL_M_AXI_AWPROT = w_crsbar_m_axi_awprot[MAINAXI_CRSBAR_M_PORT_NUM_UDL*3 +: 3];
assign UDL_M_AXI_AWREGION = w_crsbar_m_axi_awregion[MAINAXI_CRSBAR_M_PORT_NUM_UDL*4 +: 4];
assign UDL_M_AXI_AWQOS = w_crsbar_m_axi_awqos[MAINAXI_CRSBAR_M_PORT_NUM_UDL*4 +: 4];
assign UDL_M_AXI_AWVALID = w_crsbar_m_axi_awvalid[MAINAXI_CRSBAR_M_PORT_NUM_UDL*1 +: 1];
assign w_crsbar_m_axi_awready[MAINAXI_CRSBAR_M_PORT_NUM_UDL*1 +: 1] = UDL_M_AXI_AWREADY;
assign UDL_M_AXI_WDATA = w_crsbar_m_axi_wdata[MAINAXI_CRSBAR_M_PORT_NUM_UDL*32 +: 32];
assign UDL_M_AXI_WSTRB = w_crsbar_m_axi_wstrb[MAINAXI_CRSBAR_M_PORT_NUM_UDL*4 +: 4];
assign UDL_M_AXI_WLAST = w_crsbar_m_axi_wlast[MAINAXI_CRSBAR_M_PORT_NUM_UDL*1 +: 1];
assign UDL_M_AXI_WVALID = w_crsbar_m_axi_wvalid[MAINAXI_CRSBAR_M_PORT_NUM_UDL*1 +: 1];
assign w_crsbar_m_axi_wready[MAINAXI_CRSBAR_M_PORT_NUM_UDL*1 +: 1] = UDL_M_AXI_WREADY;
assign w_crsbar_m_axi_bid[MAINAXI_CRSBAR_M_PORT_NUM_UDL*MAINAXI_S_AXI_ID_WIDTH +: MAINAXI_S_AXI_ID_WIDTH] = UDL_M_AXI_BID;
assign w_crsbar_m_axi_bresp[MAINAXI_CRSBAR_M_PORT_NUM_UDL*2 +: 2] = UDL_M_AXI_BRESP;
assign w_crsbar_m_axi_bvalid[MAINAXI_CRSBAR_M_PORT_NUM_UDL*1 +: 1] = UDL_M_AXI_BVALID;
assign UDL_M_AXI_BREADY = w_crsbar_m_axi_bready[MAINAXI_CRSBAR_M_PORT_NUM_UDL*1 +: 1];
assign UDL_M_AXI_ARID = w_crsbar_m_axi_arid[MAINAXI_CRSBAR_M_PORT_NUM_UDL*MAINAXI_S_AXI_ID_WIDTH +: MAINAXI_S_AXI_ID_WIDTH];
assign UDL_M_AXI_ARADDR = w_crsbar_m_axi_araddr[MAINAXI_CRSBAR_M_PORT_NUM_UDL*32 +: 32];
assign UDL_M_AXI_ARLEN = w_crsbar_m_axi_arlen[MAINAXI_CRSBAR_M_PORT_NUM_UDL*8 +: 8];
assign UDL_M_AXI_ARSIZE = w_crsbar_m_axi_arsize[MAINAXI_CRSBAR_M_PORT_NUM_UDL*3 +: 3];
assign UDL_M_AXI_ARBURST = w_crsbar_m_axi_arburst[MAINAXI_CRSBAR_M_PORT_NUM_UDL*2 +: 2];
assign UDL_M_AXI_ARLOCK = w_crsbar_m_axi_arlock[MAINAXI_CRSBAR_M_PORT_NUM_UDL*1 +: 1];
assign UDL_M_AXI_ARCACHE = w_crsbar_m_axi_arcache[MAINAXI_CRSBAR_M_PORT_NUM_UDL*4 +: 4];
assign UDL_M_AXI_ARPROT = w_crsbar_m_axi_arprot[MAINAXI_CRSBAR_M_PORT_NUM_UDL*3 +: 3];
assign UDL_M_AXI_ARREGION = w_crsbar_m_axi_arregion[MAINAXI_CRSBAR_M_PORT_NUM_UDL*4 +: 4];
assign UDL_M_AXI_ARQOS = w_crsbar_m_axi_arqos[MAINAXI_CRSBAR_M_PORT_NUM_UDL*4 +: 4];
assign UDL_M_AXI_ARVALID = w_crsbar_m_axi_arvalid[MAINAXI_CRSBAR_M_PORT_NUM_UDL*1 +: 1];
assign w_crsbar_m_axi_arready[MAINAXI_CRSBAR_M_PORT_NUM_UDL*1 +: 1] = UDL_M_AXI_ARREADY;
assign w_crsbar_m_axi_rid[MAINAXI_CRSBAR_M_PORT_NUM_UDL*MAINAXI_S_AXI_ID_WIDTH +: MAINAXI_S_AXI_ID_WIDTH] = UDL_M_AXI_RID;
assign w_crsbar_m_axi_rdata[MAINAXI_CRSBAR_M_PORT_NUM_UDL*32 +: 32] = UDL_M_AXI_RDATA;
assign w_crsbar_m_axi_rresp[MAINAXI_CRSBAR_M_PORT_NUM_UDL*2 +: 2] = UDL_M_AXI_RRESP;
assign w_crsbar_m_axi_rlast[MAINAXI_CRSBAR_M_PORT_NUM_UDL*1 +: 1] = UDL_M_AXI_RLAST;
assign w_crsbar_m_axi_rvalid[MAINAXI_CRSBAR_M_PORT_NUM_UDL*1 +: 1] = UDL_M_AXI_RVALID;
assign UDL_M_AXI_RREADY = w_crsbar_m_axi_rready[MAINAXI_CRSBAR_M_PORT_NUM_UDL*1 +: 1];

endmodule
