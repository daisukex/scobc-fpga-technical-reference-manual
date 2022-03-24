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

localparam CROSSBAR_S_PORTS = 2;
localparam S_PORT_NUM_CPU_SYS = 0;
localparam S_PORT_NUM_UDL = 1;

localparam CROSSBAR_M_PORTS = 10;
localparam M_PORT_NUM_HRMEM_SRAM = 0;
localparam M_PORT_NUM_QSPI_CFG = 1;
localparam M_PORT_NUM_QSPI_DATA = 2;
localparam M_PORT_NUM_QSPI_FRAM = 3;
localparam M_PORT_NUM_HRMEM_BRAM = 4;
localparam M_PORT_NUM_CAN = 5;
localparam M_PORT_NUM_HRMEM_SRAM_REG = 6;
localparam M_PORT_NUM_HRMEM_BRAM_REG = 7;
localparam M_PORT_NUM_LPAHB = 8;
localparam M_PORT_NUM_UDL = 9;

wire [MAINAXI_S_AXI_ID_WIDTH*CROSSBAR_S_PORTS-1:0] axis_awid;
wire [32*CROSSBAR_S_PORTS-1:0] axis_awaddr;
wire [8*CROSSBAR_S_PORTS-1:0] axis_awlen;
wire [3*CROSSBAR_S_PORTS-1:0] axis_awsize;
wire [2*CROSSBAR_S_PORTS-1:0] axis_awburst;
wire [1*CROSSBAR_S_PORTS-1:0] axis_awlock;
wire [4*CROSSBAR_S_PORTS-1:0] axis_awcache;
wire [3*CROSSBAR_S_PORTS-1:0] axis_awprot;
wire [4*CROSSBAR_S_PORTS-1:0] axis_awqos;
wire [1*CROSSBAR_S_PORTS-1:0] axis_awvalid;
wire [1*CROSSBAR_S_PORTS-1:0] axis_awready;
wire [32*CROSSBAR_S_PORTS-1:0] axis_wdata;
wire [4*CROSSBAR_S_PORTS-1:0] axis_wstrb;
wire [1*CROSSBAR_S_PORTS-1:0] axis_wlast;
wire [1*CROSSBAR_S_PORTS-1:0] axis_wvalid;
wire [1*CROSSBAR_S_PORTS-1:0] axis_wready;
wire [MAINAXI_S_AXI_ID_WIDTH*CROSSBAR_S_PORTS-1:0] axis_bid;
wire [2*CROSSBAR_S_PORTS-1:0] axis_bresp;
wire [1*CROSSBAR_S_PORTS-1:0] axis_bvalid;
wire [1*CROSSBAR_S_PORTS-1:0] axis_bready;
wire [MAINAXI_S_AXI_ID_WIDTH*CROSSBAR_S_PORTS-1:0] axis_arid;
wire [32*CROSSBAR_S_PORTS-1:0] axis_araddr;
wire [8*CROSSBAR_S_PORTS-1:0] axis_arlen;
wire [3*CROSSBAR_S_PORTS-1:0] axis_arsize;
wire [2*CROSSBAR_S_PORTS-1:0] axis_arburst;
wire [1*CROSSBAR_S_PORTS-1:0] axis_arlock;
wire [4*CROSSBAR_S_PORTS-1:0] axis_arcache;
wire [3*CROSSBAR_S_PORTS-1:0] axis_arprot;
wire [4*CROSSBAR_S_PORTS-1:0] axis_arqos;
wire [1*CROSSBAR_S_PORTS-1:0] axis_arvalid;
wire [1*CROSSBAR_S_PORTS-1:0] axis_arready;
wire [MAINAXI_S_AXI_ID_WIDTH*CROSSBAR_S_PORTS-1:0] axis_rid;
wire [32*CROSSBAR_S_PORTS-1:0] axis_rdata;
wire [2*CROSSBAR_S_PORTS-1:0] axis_rresp;
wire [1*CROSSBAR_S_PORTS-1:0] axis_rlast;
wire [1*CROSSBAR_S_PORTS-1:0] axis_rvalid;
wire [1*CROSSBAR_S_PORTS-1:0] axis_rready;

wire [MAINAXI_S_AXI_ID_WIDTH*CROSSBAR_M_PORTS-1:0] axim_awid;
wire [32*CROSSBAR_M_PORTS-1:0] axim_awaddr;
wire [8*CROSSBAR_M_PORTS-1:0] axim_awlen;
wire [3*CROSSBAR_M_PORTS-1:0] axim_awsize;
wire [2*CROSSBAR_M_PORTS-1:0] axim_awburst;
wire [1*CROSSBAR_M_PORTS-1:0] axim_awlock;
wire [4*CROSSBAR_M_PORTS-1:0] axim_awcache;
wire [3*CROSSBAR_M_PORTS-1:0] axim_awprot;
wire [4*CROSSBAR_M_PORTS-1:0] axim_awregion;
wire [4*CROSSBAR_M_PORTS-1:0] axim_awqos;
wire [1*CROSSBAR_M_PORTS-1:0] axim_awvalid;
wire [1*CROSSBAR_M_PORTS-1:0] axim_awready;
wire [32*CROSSBAR_M_PORTS-1:0] axim_wdata;
wire [4*CROSSBAR_M_PORTS-1:0] axim_wstrb;
wire [1*CROSSBAR_M_PORTS-1:0] axim_wlast;
wire [1*CROSSBAR_M_PORTS-1:0] axim_wvalid;
wire [1*CROSSBAR_M_PORTS-1:0] axim_wready;
wire [MAINAXI_S_AXI_ID_WIDTH*CROSSBAR_M_PORTS-1:0] axim_bid;
wire [2*CROSSBAR_M_PORTS-1:0] axim_bresp;
wire [1*CROSSBAR_M_PORTS-1:0] axim_bvalid;
wire [1*CROSSBAR_M_PORTS-1:0] axim_bready;
wire [MAINAXI_S_AXI_ID_WIDTH*CROSSBAR_M_PORTS-1:0] axim_arid;
wire [32*CROSSBAR_M_PORTS-1:0] axim_araddr;
wire [8*CROSSBAR_M_PORTS-1:0] axim_arlen;
wire [3*CROSSBAR_M_PORTS-1:0] axim_arsize;
wire [2*CROSSBAR_M_PORTS-1:0] axim_arburst;
wire [1*CROSSBAR_M_PORTS-1:0] axim_arlock;
wire [4*CROSSBAR_M_PORTS-1:0] axim_arcache;
wire [3*CROSSBAR_M_PORTS-1:0] axim_arprot;
wire [4*CROSSBAR_M_PORTS-1:0] axim_arregion;
wire [4*CROSSBAR_M_PORTS-1:0] axim_arqos;
wire [1*CROSSBAR_M_PORTS-1:0] axim_arvalid;
wire [1*CROSSBAR_M_PORTS-1:0] axim_arready;
wire [MAINAXI_S_AXI_ID_WIDTH*CROSSBAR_M_PORTS-1:0] axim_rid;
wire [32*CROSSBAR_M_PORTS-1:0] axim_rdata;
wire [2*CROSSBAR_M_PORTS-1:0] axim_rresp;
wire [1*CROSSBAR_M_PORTS-1:0] axim_rlast;
wire [1*CROSSBAR_M_PORTS-1:0] axim_rvalid;
wire [1*CROSSBAR_M_PORTS-1:0] axim_rready;

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
assign axis_awid[S_PORT_NUM_CPU_SYS*MAINAXI_S_AXI_ID_WIDTH +: MAINAXI_S_AXI_ID_WIDTH] = 0;
assign axis_awaddr[S_PORT_NUM_CPU_SYS*32 +: 32] = CPU_SYS_S_AXI_AWADDR;
assign axis_awlen[S_PORT_NUM_CPU_SYS*8 +: 8] = {4'h0, CPU_SYS_S_AXI_AWLEN};
assign axis_awsize[S_PORT_NUM_CPU_SYS*3 +: 3] = CPU_SYS_S_AXI_AWSIZE;
assign axis_awburst[S_PORT_NUM_CPU_SYS*2 +: 2] = CPU_SYS_S_AXI_AWBURST;
assign axis_awlock[S_PORT_NUM_CPU_SYS*1 +: 1] = CPU_SYS_S_AXI_AWLOCK[0];
assign axis_awcache[S_PORT_NUM_CPU_SYS*4 +: 4] = CPU_SYS_S_AXI_AWCACHE;
assign axis_awprot[S_PORT_NUM_CPU_SYS*3 +: 3] = CPU_SYS_S_AXI_AWPROT;
assign axis_awqos[S_PORT_NUM_CPU_SYS*4 +: 4] = 0;
assign axis_awvalid[S_PORT_NUM_CPU_SYS*1 +: 1] = CPU_SYS_S_AXI_AWVALID;
assign axis_wdata[S_PORT_NUM_CPU_SYS*32 +:32] = CPU_SYS_S_AXI_WDATA;
assign axis_wstrb[S_PORT_NUM_CPU_SYS*4 +: 4] = CPU_SYS_S_AXI_WSTRB;
assign axis_wlast[S_PORT_NUM_CPU_SYS*1 +: 1] = CPU_SYS_S_AXI_WLAST;
assign axis_wvalid[S_PORT_NUM_CPU_SYS*1 +: 1] = CPU_SYS_S_AXI_WVALID;
assign axis_bready[S_PORT_NUM_CPU_SYS*1 +: 1] = CPU_SYS_S_AXI_BREADY;
assign axis_arid[S_PORT_NUM_CPU_SYS*MAINAXI_S_AXI_ID_WIDTH +: MAINAXI_S_AXI_ID_WIDTH] = 0;
assign axis_araddr[S_PORT_NUM_CPU_SYS*32 +:32] = CPU_SYS_S_AXI_ARADDR;
assign axis_arlen[S_PORT_NUM_CPU_SYS*8 +: 8] = {4'h0, CPU_SYS_S_AXI_ARLEN};
assign axis_arsize[S_PORT_NUM_CPU_SYS*3 +: 3] = CPU_SYS_S_AXI_ARSIZE;
assign axis_arburst[S_PORT_NUM_CPU_SYS*2 +: 2] = CPU_SYS_S_AXI_ARBURST;
assign axis_arlock[S_PORT_NUM_CPU_SYS*1 +: 1] = CPU_SYS_S_AXI_ARLOCK[0];
assign axis_arcache[S_PORT_NUM_CPU_SYS*4 +: 4] = CPU_SYS_S_AXI_ARCACHE;
assign axis_arprot[S_PORT_NUM_CPU_SYS*3 +: 3] = CPU_SYS_S_AXI_ARPROT;
assign axis_arqos[S_PORT_NUM_CPU_SYS*4 +: 4] = 0;
assign axis_arvalid[S_PORT_NUM_CPU_SYS*1 +: 1] = CPU_SYS_S_AXI_ARVALID;
assign axis_rready[S_PORT_NUM_CPU_SYS*1 +: 1] = CPU_SYS_S_AXI_RREADY;
assign CPU_SYS_S_AXI_AWREADY = axis_awready[S_PORT_NUM_CPU_SYS*1 +: 1];
assign CPU_SYS_S_AXI_WREADY = axis_wready[S_PORT_NUM_CPU_SYS*1 +: 1];
assign CPU_SYS_S_AXI_BRESP = axis_bresp[S_PORT_NUM_CPU_SYS*2 +: 2];
assign CPU_SYS_S_AXI_BVALID = axis_bvalid[S_PORT_NUM_CPU_SYS*1 +: 1];
assign CPU_SYS_S_AXI_ARREADY = axis_arready[S_PORT_NUM_CPU_SYS*1 +: 1];
assign CPU_SYS_S_AXI_RDATA = axis_rdata[S_PORT_NUM_CPU_SYS*32 +: 32];
assign CPU_SYS_S_AXI_RRESP = axis_rresp[S_PORT_NUM_CPU_SYS*2 +: 2];
assign CPU_SYS_S_AXI_RLAST = axis_rlast[S_PORT_NUM_CPU_SYS*1 +: 1];
assign CPU_SYS_S_AXI_RVALID = axis_rvalid[S_PORT_NUM_CPU_SYS*1 +: 1];

// UDL AXI4 Slave Interface to main_axi_crossbar
assign axis_awid[S_PORT_NUM_UDL*MAINAXI_S_AXI_ID_WIDTH +: MAINAXI_S_AXI_ID_WIDTH] =
       {{MAINAXI_S_AXI_ID_WIDTH-MAINAXI_UDL_M_AXI_ID_WIDTH{1'b0}}, UDL_S_AXI_AWID};
assign axis_awaddr[S_PORT_NUM_UDL*32 +: 32] = UDL_S_AXI_AWADDR;
assign axis_awlen[S_PORT_NUM_UDL*8 +: 8] = UDL_S_AXI_AWLEN;
assign axis_awsize[S_PORT_NUM_UDL*3 +: 3] = UDL_S_AXI_AWSIZE;
assign axis_awburst[S_PORT_NUM_UDL*2 +: 2] = UDL_S_AXI_AWBURST;
assign axis_awlock[S_PORT_NUM_UDL*1 +: 1] = UDL_S_AXI_AWLOCK;
assign axis_awcache[S_PORT_NUM_UDL*4 +: 4] = UDL_S_AXI_AWCACHE;
assign axis_awprot[S_PORT_NUM_UDL*3 +: 3] = UDL_S_AXI_AWPROT;
assign axis_awqos[S_PORT_NUM_UDL*4 +: 4] = UDL_S_AXI_AWQOS;
assign axis_awvalid[S_PORT_NUM_UDL*1 +: 1] = UDL_S_AXI_AWVALID;
assign axis_wdata[S_PORT_NUM_UDL*32 +:32] = UDL_S_AXI_WDATA;
assign axis_wstrb[S_PORT_NUM_UDL*4 +: 4] = UDL_S_AXI_WSTRB;
assign axis_wlast[S_PORT_NUM_UDL*1 +: 1] = UDL_S_AXI_WLAST;
assign axis_wvalid[S_PORT_NUM_UDL*1 +: 1] = UDL_S_AXI_WVALID;
assign axis_bready[S_PORT_NUM_UDL*1 +: 1] = UDL_S_AXI_BREADY;
assign axis_arid[S_PORT_NUM_UDL*MAINAXI_S_AXI_ID_WIDTH +: MAINAXI_S_AXI_ID_WIDTH] =
       {{MAINAXI_S_AXI_ID_WIDTH-MAINAXI_UDL_M_AXI_ID_WIDTH{1'b0}}, UDL_S_AXI_ARID};
assign axis_araddr[S_PORT_NUM_UDL*32 +:32] = UDL_S_AXI_ARADDR;
assign axis_arlen[S_PORT_NUM_UDL*8 +: 8] = UDL_S_AXI_ARLEN;
assign axis_arsize[S_PORT_NUM_UDL*3 +: 3] = UDL_S_AXI_ARSIZE;
assign axis_arburst[S_PORT_NUM_UDL*2 +: 2] = UDL_S_AXI_ARBURST;
assign axis_arlock[S_PORT_NUM_UDL*1 +: 1] = UDL_S_AXI_ARLOCK;
assign axis_arcache[S_PORT_NUM_UDL*4 +: 4] = UDL_S_AXI_ARCACHE;
assign axis_arprot[S_PORT_NUM_UDL*3 +: 3] = UDL_S_AXI_ARPROT;
assign axis_arqos[S_PORT_NUM_UDL*4 +: 4] = UDL_S_AXI_ARQOS;
assign axis_arvalid[S_PORT_NUM_UDL*1 +: 1] = UDL_S_AXI_ARVALID;
assign axis_rready[S_PORT_NUM_UDL*1 +: 1] = UDL_S_AXI_RREADY;
assign UDL_S_AXI_AWREADY = axis_awready[S_PORT_NUM_UDL*1 +: 1];
assign UDL_S_AXI_WREADY = axis_wready[S_PORT_NUM_UDL*1 +: 1];
assign UDL_S_AXI_BID = axis_bid[S_PORT_NUM_UDL*MAINAXI_S_AXI_ID_WIDTH +: MAINAXI_UDL_M_AXI_ID_WIDTH];
assign UDL_S_AXI_BRESP = axis_bresp[S_PORT_NUM_UDL*2 +: 2];
assign UDL_S_AXI_BVALID = axis_bvalid[S_PORT_NUM_UDL*1 +: 1];
assign UDL_S_AXI_ARREADY = axis_arready[S_PORT_NUM_UDL*1 +: 1];
assign UDL_S_AXI_RID = axis_rid[S_PORT_NUM_UDL*MAINAXI_S_AXI_ID_WIDTH +: MAINAXI_UDL_M_AXI_ID_WIDTH];
assign UDL_S_AXI_RDATA = axis_rdata[S_PORT_NUM_UDL*32 +: 32];
assign UDL_S_AXI_RRESP = axis_rresp[S_PORT_NUM_UDL*2 +: 2];
assign UDL_S_AXI_RLAST = axis_rlast[S_PORT_NUM_UDL*1 +: 1];
assign UDL_S_AXI_RVALID = axis_rvalid[S_PORT_NUM_UDL*1 +: 1];

// Main AXI Bus Crossvar
main_axi_crossbar main_axi_crossbar (
  .aclk(SYS_CLK),
  .aresetn(BUS_RSTB),
  .s_axi_awid(axis_awid),
  .s_axi_awaddr(axis_awaddr),
  .s_axi_awlen(axis_awlen),
  .s_axi_awsize(axis_awsize),
  .s_axi_awburst(axis_awburst),
  .s_axi_awlock(axis_awlock),
  .s_axi_awcache(axis_awcache),
  .s_axi_awprot(axis_awprot),
  .s_axi_awqos(axis_awqos),
  .s_axi_awvalid(axis_awvalid),
  .s_axi_awready(axis_awready),
  .s_axi_wdata(axis_wdata),
  .s_axi_wstrb(axis_wstrb),
  .s_axi_wlast(axis_wlast),
  .s_axi_wvalid(axis_wvalid),
  .s_axi_wready(axis_wready),
  .s_axi_bid(axis_bid),
  .s_axi_bresp(axis_bresp),
  .s_axi_bvalid(axis_bvalid),
  .s_axi_bready(axis_bready),
  .s_axi_arid(axis_arid),
  .s_axi_araddr(axis_araddr),
  .s_axi_arlen(axis_arlen),
  .s_axi_arsize(axis_arsize),
  .s_axi_arburst(axis_arburst),
  .s_axi_arlock(axis_arlock),
  .s_axi_arcache(axis_arcache),
  .s_axi_arprot(axis_arprot),
  .s_axi_arqos(axis_arqos),
  .s_axi_arvalid(axis_arvalid),
  .s_axi_arready(axis_arready),
  .s_axi_rid(axis_rid),
  .s_axi_rdata(axis_rdata),
  .s_axi_rresp(axis_rresp),
  .s_axi_rlast(axis_rlast),
  .s_axi_rvalid(axis_rvalid),
  .s_axi_rready(axis_rready),
  .m_axi_awid(axim_awid),
  .m_axi_awaddr(axim_awaddr),
  .m_axi_awlen(axim_awlen),
  .m_axi_awsize(axim_awsize),
  .m_axi_awburst(axim_awburst),
  .m_axi_awlock(axim_awlock),
  .m_axi_awcache(axim_awcache),
  .m_axi_awprot(axim_awprot),
  .m_axi_awregion(axim_awregion),
  .m_axi_awqos(axim_awqos),
  .m_axi_awvalid(axim_awvalid),
  .m_axi_awready(axim_awready),
  .m_axi_wdata(axim_wdata),
  .m_axi_wstrb(axim_wstrb),
  .m_axi_wlast(axim_wlast),
  .m_axi_wvalid(axim_wvalid),
  .m_axi_wready(axim_wready),
  .m_axi_bid(axim_bid),
  .m_axi_bresp(axim_bresp),
  .m_axi_bvalid(axim_bvalid),
  .m_axi_bready(axim_bready),
  .m_axi_arid(axim_arid),
  .m_axi_araddr(axim_araddr),
  .m_axi_arlen(axim_arlen),
  .m_axi_arsize(axim_arsize),
  .m_axi_arburst(axim_arburst),
  .m_axi_arlock(axim_arlock),
  .m_axi_arcache(axim_arcache),
  .m_axi_arprot(axim_arprot),
  .m_axi_arregion(axim_arregion),
  .m_axi_arqos(axim_arqos),
  .m_axi_arvalid(axim_arvalid),
  .m_axi_arready(axim_arready),
  .m_axi_rid(axim_rid),
  .m_axi_rdata(axim_rdata),
  .m_axi_rresp(axim_rresp),
  .m_axi_rlast(axim_rlast),
  .m_axi_rvalid(axim_rvalid),
  .m_axi_rready(axim_rready)
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
  .S_AXI_AWID(axim_awid[M_PORT_NUM_HRMEM_SRAM*MAINAXI_S_AXI_ID_WIDTH +: MAINAXI_S_AXI_ID_WIDTH]),
  .S_AXI_AWADDR(axim_awaddr[M_PORT_NUM_HRMEM_SRAM*32 +: 32]),
  .S_AXI_AWLEN(axim_awlen[M_PORT_NUM_HRMEM_SRAM*8 +: 8]),
  .S_AXI_AWSIZE(axim_awsize[M_PORT_NUM_HRMEM_SRAM*3 +: 3]),
  .S_AXI_AWBURST(axim_awburst[M_PORT_NUM_HRMEM_SRAM*2 +: 2]),
  .S_AXI_AWLOCK(axim_awlock[M_PORT_NUM_HRMEM_SRAM*1 +: 1]),
  .S_AXI_AWCACHE(axim_awcache[M_PORT_NUM_HRMEM_SRAM*4 +: 4]),
  .S_AXI_AWPROT(axim_awprot[M_PORT_NUM_HRMEM_SRAM*3 +: 3]),
  .S_AXI_AWVALID(axim_awvalid[M_PORT_NUM_HRMEM_SRAM*1 +: 1]),
  .S_AXI_AWREADY(axim_awready[M_PORT_NUM_HRMEM_SRAM*1 +: 1]),
  .S_AXI_WDATA(axim_wdata[M_PORT_NUM_HRMEM_SRAM*32 +: 32]),
  .S_AXI_WSTRB(axim_wstrb[M_PORT_NUM_HRMEM_SRAM*4 +: 4]),
  .S_AXI_WLAST(axim_wlast[M_PORT_NUM_HRMEM_SRAM*1 +: 1]),
  .S_AXI_WVALID(axim_wvalid[M_PORT_NUM_HRMEM_SRAM*1 +: 1]),
  .S_AXI_WREADY(axim_wready[M_PORT_NUM_HRMEM_SRAM*1 +: 1]),
  .S_AXI_BID(axim_bid[M_PORT_NUM_HRMEM_SRAM*MAINAXI_S_AXI_ID_WIDTH +: MAINAXI_S_AXI_ID_WIDTH]),
  .S_AXI_BRESP(axim_bresp[M_PORT_NUM_HRMEM_SRAM*2 +: 2]),
  .S_AXI_BVALID(axim_bvalid[M_PORT_NUM_HRMEM_SRAM*1 +: 1]),
  .S_AXI_BREADY(axim_bready[M_PORT_NUM_HRMEM_SRAM*1 +: 1]),
  .S_AXI_ARID(axim_arid[M_PORT_NUM_HRMEM_SRAM*MAINAXI_S_AXI_ID_WIDTH +: MAINAXI_S_AXI_ID_WIDTH]),
  .S_AXI_ARADDR(axim_araddr[M_PORT_NUM_HRMEM_SRAM*32 +: 32]),
  .S_AXI_ARLEN(axim_arlen[M_PORT_NUM_HRMEM_SRAM*8 +: 8]),
  .S_AXI_ARSIZE(axim_arsize[M_PORT_NUM_HRMEM_SRAM*3 +: 3]),
  .S_AXI_ARBURST(axim_arburst[M_PORT_NUM_HRMEM_SRAM*2 +: 2]),
  .S_AXI_ARLOCK(axim_arlock[M_PORT_NUM_HRMEM_SRAM*1 +: 1]),
  .S_AXI_ARCACHE(axim_arcache[M_PORT_NUM_HRMEM_SRAM*4 +: 4]),
  .S_AXI_ARPROT(axim_arprot[M_PORT_NUM_HRMEM_SRAM*3 +: 3]),
  .S_AXI_ARVALID(axim_arvalid[M_PORT_NUM_HRMEM_SRAM*1 +: 1]),
  .S_AXI_ARREADY(axim_arready[M_PORT_NUM_HRMEM_SRAM*1 +: 1]),
  .S_AXI_RID(axim_rid[M_PORT_NUM_HRMEM_SRAM*MAINAXI_S_AXI_ID_WIDTH +: MAINAXI_S_AXI_ID_WIDTH]),
  .S_AXI_RDATA(axim_rdata[M_PORT_NUM_HRMEM_SRAM*32 +: 32]),
  .S_AXI_RRESP(axim_rresp[M_PORT_NUM_HRMEM_SRAM*2 +: 2]),
  .S_AXI_RLAST(axim_rlast[M_PORT_NUM_HRMEM_SRAM*1 +: 1]),
  .S_AXI_RVALID(axim_rvalid[M_PORT_NUM_HRMEM_SRAM*1 +: 1]),
  .S_AXI_RREADY(axim_rready[M_PORT_NUM_HRMEM_SRAM*1 +: 1]),
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
  .S_AXI_AWID(axim_awid[M_PORT_NUM_QSPI_CFG*MAINAXI_S_AXI_ID_WIDTH +: MAINAXI_S_AXI_ID_WIDTH]),
  .S_AXI_AWADDR(axim_awaddr[M_PORT_NUM_QSPI_CFG*32 +: 32]),
  .S_AXI_AWLEN(axim_awlen[M_PORT_NUM_QSPI_CFG*8 +: 8]),
  .S_AXI_AWSIZE(axim_awsize[M_PORT_NUM_QSPI_CFG*3 +: 3]),
  .S_AXI_AWBURST(axim_awburst[M_PORT_NUM_QSPI_CFG*2 +: 2]),
  .S_AXI_AWLOCK(axim_awlock[M_PORT_NUM_QSPI_CFG*1 +: 1]),
  .S_AXI_AWCACHE(axim_awcache[M_PORT_NUM_QSPI_CFG*4 +: 4]),
  .S_AXI_AWPROT(axim_awprot[M_PORT_NUM_QSPI_CFG*3 +: 3]),
  .S_AXI_AWVALID(axim_awvalid[M_PORT_NUM_QSPI_CFG*1 +: 1]),
  .S_AXI_AWREADY(axim_awready[M_PORT_NUM_QSPI_CFG*1 +: 1]),
  .S_AXI_WDATA(axim_wdata[M_PORT_NUM_QSPI_CFG*32 +: 32]),
  .S_AXI_WSTRB(axim_wstrb[M_PORT_NUM_QSPI_CFG*4 +: 4]),
  .S_AXI_WLAST(axim_wlast[M_PORT_NUM_QSPI_CFG*1 +: 1]),
  .S_AXI_WVALID(axim_wvalid[M_PORT_NUM_QSPI_CFG*1 +: 1]),
  .S_AXI_WREADY(axim_wready[M_PORT_NUM_QSPI_CFG*1 +: 1]),
  .S_AXI_BID(axim_bid[M_PORT_NUM_QSPI_CFG*MAINAXI_S_AXI_ID_WIDTH +: MAINAXI_S_AXI_ID_WIDTH]),
  .S_AXI_BRESP(axim_bresp[M_PORT_NUM_QSPI_CFG*2 +: 2]),
  .S_AXI_BVALID(axim_bvalid[M_PORT_NUM_QSPI_CFG*1 +: 1]),
  .S_AXI_BREADY(axim_bready[M_PORT_NUM_QSPI_CFG*1 +: 1]),
  .S_AXI_ARID(axim_arid[M_PORT_NUM_QSPI_CFG*MAINAXI_S_AXI_ID_WIDTH +: MAINAXI_S_AXI_ID_WIDTH]),
  .S_AXI_ARADDR(axim_araddr[M_PORT_NUM_QSPI_CFG*32 +: 32]),
  .S_AXI_ARLEN(axim_arlen[M_PORT_NUM_QSPI_CFG*8 +: 8]),
  .S_AXI_ARSIZE(axim_arsize[M_PORT_NUM_QSPI_CFG*3 +: 3]),
  .S_AXI_ARBURST(axim_arburst[M_PORT_NUM_QSPI_CFG*2 +: 2]),
  .S_AXI_ARLOCK(axim_arlock[M_PORT_NUM_QSPI_CFG*1 +: 1]),
  .S_AXI_ARCACHE(axim_arcache[M_PORT_NUM_QSPI_CFG*4 +: 4]),
  .S_AXI_ARPROT(axim_arprot[M_PORT_NUM_QSPI_CFG*3 +: 3]),
  .S_AXI_ARVALID(axim_arvalid[M_PORT_NUM_QSPI_CFG*1 +: 1]),
  .S_AXI_ARREADY(axim_arready[M_PORT_NUM_QSPI_CFG*1 +: 1]),
  .S_AXI_RID(axim_rid[M_PORT_NUM_QSPI_CFG*MAINAXI_S_AXI_ID_WIDTH +: MAINAXI_S_AXI_ID_WIDTH]),
  .S_AXI_RDATA(axim_rdata[M_PORT_NUM_QSPI_CFG*32 +: 32]),
  .S_AXI_RRESP(axim_rresp[M_PORT_NUM_QSPI_CFG*2 +: 2]),
  .S_AXI_RLAST(axim_rlast[M_PORT_NUM_QSPI_CFG*1 +: 1]),
  .S_AXI_RVALID(axim_rvalid[M_PORT_NUM_QSPI_CFG*1 +: 1]),
  .S_AXI_RREADY(axim_rready[M_PORT_NUM_QSPI_CFG*1 +: 1]),

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
  .S_AXI_AWID(axim_awid[M_PORT_NUM_QSPI_DATA*MAINAXI_S_AXI_ID_WIDTH +: MAINAXI_S_AXI_ID_WIDTH]),
  .S_AXI_AWADDR(axim_awaddr[M_PORT_NUM_QSPI_DATA*32 +: 32]),
  .S_AXI_AWLEN(axim_awlen[M_PORT_NUM_QSPI_DATA*8 +: 8]),
  .S_AXI_AWSIZE(axim_awsize[M_PORT_NUM_QSPI_DATA*3 +: 3]),
  .S_AXI_AWBURST(axim_awburst[M_PORT_NUM_QSPI_DATA*2 +: 2]),
  .S_AXI_AWLOCK(axim_awlock[M_PORT_NUM_QSPI_DATA*1 +: 1]),
  .S_AXI_AWCACHE(axim_awcache[M_PORT_NUM_QSPI_DATA*4 +: 4]),
  .S_AXI_AWPROT(axim_awprot[M_PORT_NUM_QSPI_DATA*3 +: 3]),
  .S_AXI_AWVALID(axim_awvalid[M_PORT_NUM_QSPI_DATA*1 +: 1]),
  .S_AXI_AWREADY(axim_awready[M_PORT_NUM_QSPI_DATA*1 +: 1]),
  .S_AXI_WDATA(axim_wdata[M_PORT_NUM_QSPI_DATA*32 +: 32]),
  .S_AXI_WSTRB(axim_wstrb[M_PORT_NUM_QSPI_DATA*4 +: 4]),
  .S_AXI_WLAST(axim_wlast[M_PORT_NUM_QSPI_DATA*1 +: 1]),
  .S_AXI_WVALID(axim_wvalid[M_PORT_NUM_QSPI_DATA*1 +: 1]),
  .S_AXI_WREADY(axim_wready[M_PORT_NUM_QSPI_DATA*1 +: 1]),
  .S_AXI_BID(axim_bid[M_PORT_NUM_QSPI_DATA*MAINAXI_S_AXI_ID_WIDTH +: MAINAXI_S_AXI_ID_WIDTH]),
  .S_AXI_BRESP(axim_bresp[M_PORT_NUM_QSPI_DATA*2 +: 2]),
  .S_AXI_BVALID(axim_bvalid[M_PORT_NUM_QSPI_DATA*1 +: 1]),
  .S_AXI_BREADY(axim_bready[M_PORT_NUM_QSPI_DATA*1 +: 1]),
  .S_AXI_ARID(axim_arid[M_PORT_NUM_QSPI_DATA*MAINAXI_S_AXI_ID_WIDTH +: MAINAXI_S_AXI_ID_WIDTH]),
  .S_AXI_ARADDR(axim_araddr[M_PORT_NUM_QSPI_DATA*32 +: 32]),
  .S_AXI_ARLEN(axim_arlen[M_PORT_NUM_QSPI_DATA*8 +: 8]),
  .S_AXI_ARSIZE(axim_arsize[M_PORT_NUM_QSPI_DATA*3 +: 3]),
  .S_AXI_ARBURST(axim_arburst[M_PORT_NUM_QSPI_DATA*2 +: 2]),
  .S_AXI_ARLOCK(axim_arlock[M_PORT_NUM_QSPI_DATA*1 +: 1]),
  .S_AXI_ARCACHE(axim_arcache[M_PORT_NUM_QSPI_DATA*4 +: 4]),
  .S_AXI_ARPROT(axim_arprot[M_PORT_NUM_QSPI_DATA*3 +: 3]),
  .S_AXI_ARVALID(axim_arvalid[M_PORT_NUM_QSPI_DATA*1 +: 1]),
  .S_AXI_ARREADY(axim_arready[M_PORT_NUM_QSPI_DATA*1 +: 1]),
  .S_AXI_RID(axim_rid[M_PORT_NUM_QSPI_DATA*MAINAXI_S_AXI_ID_WIDTH +: MAINAXI_S_AXI_ID_WIDTH]),
  .S_AXI_RDATA(axim_rdata[M_PORT_NUM_QSPI_DATA*32 +: 32]),
  .S_AXI_RRESP(axim_rresp[M_PORT_NUM_QSPI_DATA*2 +: 2]),
  .S_AXI_RLAST(axim_rlast[M_PORT_NUM_QSPI_DATA*1 +: 1]),
  .S_AXI_RVALID(axim_rvalid[M_PORT_NUM_QSPI_DATA*1 +: 1]),
  .S_AXI_RREADY(axim_rready[M_PORT_NUM_QSPI_DATA*1 +: 1]),

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
  .S_AXI_AWID(axim_awid[M_PORT_NUM_QSPI_FRAM*MAINAXI_S_AXI_ID_WIDTH +: MAINAXI_S_AXI_ID_WIDTH]),
  .S_AXI_AWADDR(axim_awaddr[M_PORT_NUM_QSPI_FRAM*32 +: 32]),
  .S_AXI_AWLEN(axim_awlen[M_PORT_NUM_QSPI_FRAM*8 +: 8]),
  .S_AXI_AWSIZE(axim_awsize[M_PORT_NUM_QSPI_FRAM*3 +: 3]),
  .S_AXI_AWBURST(axim_awburst[M_PORT_NUM_QSPI_FRAM*2 +: 2]),
  .S_AXI_AWLOCK(axim_awlock[M_PORT_NUM_QSPI_FRAM*1 +: 1]),
  .S_AXI_AWCACHE(axim_awcache[M_PORT_NUM_QSPI_FRAM*4 +: 4]),
  .S_AXI_AWPROT(axim_awprot[M_PORT_NUM_QSPI_FRAM*3 +: 3]),
  .S_AXI_AWVALID(axim_awvalid[M_PORT_NUM_QSPI_FRAM*1 +: 1]),
  .S_AXI_AWREADY(axim_awready[M_PORT_NUM_QSPI_FRAM*1 +: 1]),
  .S_AXI_WDATA(axim_wdata[M_PORT_NUM_QSPI_FRAM*32 +: 32]),
  .S_AXI_WSTRB(axim_wstrb[M_PORT_NUM_QSPI_FRAM*4 +: 4]),
  .S_AXI_WLAST(axim_wlast[M_PORT_NUM_QSPI_FRAM*1 +: 1]),
  .S_AXI_WVALID(axim_wvalid[M_PORT_NUM_QSPI_FRAM*1 +: 1]),
  .S_AXI_WREADY(axim_wready[M_PORT_NUM_QSPI_FRAM*1 +: 1]),
  .S_AXI_BID(axim_bid[M_PORT_NUM_QSPI_FRAM*MAINAXI_S_AXI_ID_WIDTH +: MAINAXI_S_AXI_ID_WIDTH]),
  .S_AXI_BRESP(axim_bresp[M_PORT_NUM_QSPI_FRAM*2 +: 2]),
  .S_AXI_BVALID(axim_bvalid[M_PORT_NUM_QSPI_FRAM*1 +: 1]),
  .S_AXI_BREADY(axim_bready[M_PORT_NUM_QSPI_FRAM*1 +: 1]),
  .S_AXI_ARID(axim_arid[M_PORT_NUM_QSPI_FRAM*MAINAXI_S_AXI_ID_WIDTH +: MAINAXI_S_AXI_ID_WIDTH]),
  .S_AXI_ARADDR(axim_araddr[M_PORT_NUM_QSPI_FRAM*32 +: 32]),
  .S_AXI_ARLEN(axim_arlen[M_PORT_NUM_QSPI_FRAM*8 +: 8]),
  .S_AXI_ARSIZE(axim_arsize[M_PORT_NUM_QSPI_FRAM*3 +: 3]),
  .S_AXI_ARBURST(axim_arburst[M_PORT_NUM_QSPI_FRAM*2 +: 2]),
  .S_AXI_ARLOCK(axim_arlock[M_PORT_NUM_QSPI_FRAM*1 +: 1]),
  .S_AXI_ARCACHE(axim_arcache[M_PORT_NUM_QSPI_FRAM*4 +: 4]),
  .S_AXI_ARPROT(axim_arprot[M_PORT_NUM_QSPI_FRAM*3 +: 3]),
  .S_AXI_ARVALID(axim_arvalid[M_PORT_NUM_QSPI_FRAM*1 +: 1]),
  .S_AXI_ARREADY(axim_arready[M_PORT_NUM_QSPI_FRAM*1 +: 1]),
  .S_AXI_RID(axim_rid[M_PORT_NUM_QSPI_FRAM*MAINAXI_S_AXI_ID_WIDTH +: MAINAXI_S_AXI_ID_WIDTH]),
  .S_AXI_RDATA(axim_rdata[M_PORT_NUM_QSPI_FRAM*32 +: 32]),
  .S_AXI_RRESP(axim_rresp[M_PORT_NUM_QSPI_FRAM*2 +: 2]),
  .S_AXI_RLAST(axim_rlast[M_PORT_NUM_QSPI_FRAM*1 +: 1]),
  .S_AXI_RVALID(axim_rvalid[M_PORT_NUM_QSPI_FRAM*1 +: 1]),
  .S_AXI_RREADY(axim_rready[M_PORT_NUM_QSPI_FRAM*1 +: 1]),

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
  .S_AXI_AWID(axim_awid[M_PORT_NUM_HRMEM_BRAM*MAINAXI_S_AXI_ID_WIDTH +: MAINAXI_S_AXI_ID_WIDTH]),
  .S_AXI_AWADDR(axim_awaddr[M_PORT_NUM_HRMEM_BRAM*32 +: 32]),
  .S_AXI_AWLEN(axim_awlen[M_PORT_NUM_HRMEM_BRAM*8 +: 8]),
  .S_AXI_AWSIZE(axim_awsize[M_PORT_NUM_HRMEM_BRAM*3 +: 3]),
  .S_AXI_AWBURST(axim_awburst[M_PORT_NUM_HRMEM_BRAM*2 +: 2]),
  .S_AXI_AWLOCK(axim_awlock[M_PORT_NUM_HRMEM_BRAM*1 +: 1]),
  .S_AXI_AWCACHE(axim_awcache[M_PORT_NUM_HRMEM_BRAM*4 +: 4]),
  .S_AXI_AWPROT(axim_awprot[M_PORT_NUM_HRMEM_BRAM*3 +: 3]),
  .S_AXI_AWVALID(axim_awvalid[M_PORT_NUM_HRMEM_BRAM*1 +: 1]),
  .S_AXI_AWREADY(axim_awready[M_PORT_NUM_HRMEM_BRAM*1 +: 1]),
  .S_AXI_WDATA(axim_wdata[M_PORT_NUM_HRMEM_BRAM*32 +: 32]),
  .S_AXI_WSTRB(axim_wstrb[M_PORT_NUM_HRMEM_BRAM*4 +: 4]),
  .S_AXI_WLAST(axim_wlast[M_PORT_NUM_HRMEM_BRAM*1 +: 1]),
  .S_AXI_WVALID(axim_wvalid[M_PORT_NUM_HRMEM_BRAM*1 +: 1]),
  .S_AXI_WREADY(axim_wready[M_PORT_NUM_HRMEM_BRAM*1 +: 1]),
  .S_AXI_BID(axim_bid[M_PORT_NUM_HRMEM_BRAM*MAINAXI_S_AXI_ID_WIDTH +: MAINAXI_S_AXI_ID_WIDTH]),
  .S_AXI_BRESP(axim_bresp[M_PORT_NUM_HRMEM_BRAM*2 +: 2]),
  .S_AXI_BVALID(axim_bvalid[M_PORT_NUM_HRMEM_BRAM*1 +: 1]),
  .S_AXI_BREADY(axim_bready[M_PORT_NUM_HRMEM_BRAM*1 +: 1]),
  .S_AXI_ARID(axim_arid[M_PORT_NUM_HRMEM_BRAM*MAINAXI_S_AXI_ID_WIDTH +: MAINAXI_S_AXI_ID_WIDTH]),
  .S_AXI_ARADDR(axim_araddr[M_PORT_NUM_HRMEM_BRAM*32 +: 32]),
  .S_AXI_ARLEN(axim_arlen[M_PORT_NUM_HRMEM_BRAM*8 +: 8]),
  .S_AXI_ARSIZE(axim_arsize[M_PORT_NUM_HRMEM_BRAM*3 +: 3]),
  .S_AXI_ARBURST(axim_arburst[M_PORT_NUM_HRMEM_BRAM*2 +: 2]),
  .S_AXI_ARLOCK(axim_arlock[M_PORT_NUM_HRMEM_BRAM*1 +: 1]),
  .S_AXI_ARCACHE(axim_arcache[M_PORT_NUM_HRMEM_BRAM*4 +: 4]),
  .S_AXI_ARPROT(axim_arprot[M_PORT_NUM_HRMEM_BRAM*3 +: 3]),
  .S_AXI_ARVALID(axim_arvalid[M_PORT_NUM_HRMEM_BRAM*1 +: 1]),
  .S_AXI_ARREADY(axim_arready[M_PORT_NUM_HRMEM_BRAM*1 +: 1]),
  .S_AXI_RID(axim_rid[M_PORT_NUM_HRMEM_BRAM*MAINAXI_S_AXI_ID_WIDTH +: MAINAXI_S_AXI_ID_WIDTH]),
  .S_AXI_RDATA(axim_rdata[M_PORT_NUM_HRMEM_BRAM*32 +: 32]),
  .S_AXI_RRESP(axim_rresp[M_PORT_NUM_HRMEM_BRAM*2 +: 2]),
  .S_AXI_RLAST(axim_rlast[M_PORT_NUM_HRMEM_BRAM*1 +: 1]),
  .S_AXI_RVALID(axim_rvalid[M_PORT_NUM_HRMEM_BRAM*1 +: 1]),
  .S_AXI_RREADY(axim_rready[M_PORT_NUM_HRMEM_BRAM*1 +: 1]),
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
  .S_AXI_AWID(axim_awid[M_PORT_NUM_CAN*MAINAXI_S_AXI_ID_WIDTH +: MAINAXI_S_AXI_ID_WIDTH]),
  .S_AXI_AWADDR(axim_awaddr[M_PORT_NUM_CAN*32 +: 32]),
  .S_AXI_AWLEN(axim_awlen[M_PORT_NUM_CAN*8 +: 8]),
  .S_AXI_AWSIZE(axim_awsize[M_PORT_NUM_CAN*3 +: 3]),
  .S_AXI_AWBURST(axim_awburst[M_PORT_NUM_CAN*2 +: 2]),
  .S_AXI_AWLOCK(axim_awlock[M_PORT_NUM_CAN*1 +: 1]),
  .S_AXI_AWCACHE(axim_awcache[M_PORT_NUM_CAN*4 +: 4]),
  .S_AXI_AWPROT(axim_awprot[M_PORT_NUM_CAN*3 +: 3]),
  .S_AXI_AWVALID(axim_awvalid[M_PORT_NUM_CAN*1 +: 1]),
  .S_AXI_AWREADY(axim_awready[M_PORT_NUM_CAN*1 +: 1]),
  .S_AXI_WDATA(axim_wdata[M_PORT_NUM_CAN*32 +: 32]),
  .S_AXI_WSTRB(axim_wstrb[M_PORT_NUM_CAN*4 +: 4]),
  .S_AXI_WLAST(axim_wlast[M_PORT_NUM_CAN*1 +: 1]),
  .S_AXI_WVALID(axim_wvalid[M_PORT_NUM_CAN*1 +: 1]),
  .S_AXI_WREADY(axim_wready[M_PORT_NUM_CAN*1 +: 1]),
  .S_AXI_BID(axim_bid[M_PORT_NUM_CAN*MAINAXI_S_AXI_ID_WIDTH +: MAINAXI_S_AXI_ID_WIDTH]),
  .S_AXI_BRESP(axim_bresp[M_PORT_NUM_CAN*2 +: 2]),
  .S_AXI_BVALID(axim_bvalid[M_PORT_NUM_CAN*1 +: 1]),
  .S_AXI_BREADY(axim_bready[M_PORT_NUM_CAN*1 +: 1]),
  .S_AXI_ARID(axim_arid[M_PORT_NUM_CAN*MAINAXI_S_AXI_ID_WIDTH +: MAINAXI_S_AXI_ID_WIDTH]),
  .S_AXI_ARADDR(axim_araddr[M_PORT_NUM_CAN*32 +: 32]),
  .S_AXI_ARLEN(axim_arlen[M_PORT_NUM_CAN*8 +: 8]),
  .S_AXI_ARSIZE(axim_arsize[M_PORT_NUM_CAN*3 +: 3]),
  .S_AXI_ARBURST(axim_arburst[M_PORT_NUM_CAN*2 +: 2]),
  .S_AXI_ARLOCK(axim_arlock[M_PORT_NUM_CAN*1 +: 1]),
  .S_AXI_ARCACHE(axim_arcache[M_PORT_NUM_CAN*4 +: 4]),
  .S_AXI_ARPROT(axim_arprot[M_PORT_NUM_CAN*3 +: 3]),
  .S_AXI_ARVALID(axim_arvalid[M_PORT_NUM_CAN*1 +: 1]),
  .S_AXI_ARREADY(axim_arready[M_PORT_NUM_CAN*1 +: 1]),
  .S_AXI_RID(axim_rid[M_PORT_NUM_CAN*MAINAXI_S_AXI_ID_WIDTH +: MAINAXI_S_AXI_ID_WIDTH]),
  .S_AXI_RDATA(axim_rdata[M_PORT_NUM_CAN*32 +: 32]),
  .S_AXI_RRESP(axim_rresp[M_PORT_NUM_CAN*2 +: 2]),
  .S_AXI_RLAST(axim_rlast[M_PORT_NUM_CAN*1 +: 1]),
  .S_AXI_RVALID(axim_rvalid[M_PORT_NUM_CAN*1 +: 1]),
  .S_AXI_RREADY(axim_rready[M_PORT_NUM_CAN*1 +: 1]),

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
  .S_AXI_AWID(axim_awid[M_PORT_NUM_HRMEM_SRAM_REG*MAINAXI_S_AXI_ID_WIDTH +: MAINAXI_S_AXI_ID_WIDTH]),
  .S_AXI_AWADDR(axim_awaddr[M_PORT_NUM_HRMEM_SRAM_REG*32 +: 32]),
  .S_AXI_AWLEN(axim_awlen[M_PORT_NUM_HRMEM_SRAM_REG*8 +: 8]),
  .S_AXI_AWSIZE(axim_awsize[M_PORT_NUM_HRMEM_SRAM_REG*3 +: 3]),
  .S_AXI_AWBURST(axim_awburst[M_PORT_NUM_HRMEM_SRAM_REG*2 +: 2]),
  .S_AXI_AWLOCK(axim_awlock[M_PORT_NUM_HRMEM_SRAM_REG*1 +: 1]),
  .S_AXI_AWCACHE(axim_awcache[M_PORT_NUM_HRMEM_SRAM_REG*4 +: 4]),
  .S_AXI_AWPROT(axim_awprot[M_PORT_NUM_HRMEM_SRAM_REG*3 +: 3]),
  .S_AXI_AWVALID(axim_awvalid[M_PORT_NUM_HRMEM_SRAM_REG*1 +: 1]),
  .S_AXI_AWREADY(axim_awready[M_PORT_NUM_HRMEM_SRAM_REG*1 +: 1]),
  .S_AXI_WDATA(axim_wdata[M_PORT_NUM_HRMEM_SRAM_REG*32 +: 32]),
  .S_AXI_WSTRB(axim_wstrb[M_PORT_NUM_HRMEM_SRAM_REG*4 +: 4]),
  .S_AXI_WLAST(axim_wlast[M_PORT_NUM_HRMEM_SRAM_REG*1 +: 1]),
  .S_AXI_WVALID(axim_wvalid[M_PORT_NUM_HRMEM_SRAM_REG*1 +: 1]),
  .S_AXI_WREADY(axim_wready[M_PORT_NUM_HRMEM_SRAM_REG*1 +: 1]),
  .S_AXI_BID(axim_bid[M_PORT_NUM_HRMEM_SRAM_REG*MAINAXI_S_AXI_ID_WIDTH +: MAINAXI_S_AXI_ID_WIDTH]),
  .S_AXI_BRESP(axim_bresp[M_PORT_NUM_HRMEM_SRAM_REG*2 +: 2]),
  .S_AXI_BVALID(axim_bvalid[M_PORT_NUM_HRMEM_SRAM_REG*1 +: 1]),
  .S_AXI_BREADY(axim_bready[M_PORT_NUM_HRMEM_SRAM_REG*1 +: 1]),
  .S_AXI_ARID(axim_arid[M_PORT_NUM_HRMEM_SRAM_REG*MAINAXI_S_AXI_ID_WIDTH +: MAINAXI_S_AXI_ID_WIDTH]),
  .S_AXI_ARADDR(axim_araddr[M_PORT_NUM_HRMEM_SRAM_REG*32 +: 32]),
  .S_AXI_ARLEN(axim_arlen[M_PORT_NUM_HRMEM_SRAM_REG*8 +: 8]),
  .S_AXI_ARSIZE(axim_arsize[M_PORT_NUM_HRMEM_SRAM_REG*3 +: 3]),
  .S_AXI_ARBURST(axim_arburst[M_PORT_NUM_HRMEM_SRAM_REG*2 +: 2]),
  .S_AXI_ARLOCK(axim_arlock[M_PORT_NUM_HRMEM_SRAM_REG*1 +: 1]),
  .S_AXI_ARCACHE(axim_arcache[M_PORT_NUM_HRMEM_SRAM_REG*4 +: 4]),
  .S_AXI_ARPROT(axim_arprot[M_PORT_NUM_HRMEM_SRAM_REG*3 +: 3]),
  .S_AXI_ARVALID(axim_arvalid[M_PORT_NUM_HRMEM_SRAM_REG*1 +: 1]),
  .S_AXI_ARREADY(axim_arready[M_PORT_NUM_HRMEM_SRAM_REG*1 +: 1]),
  .S_AXI_RID(axim_rid[M_PORT_NUM_HRMEM_SRAM_REG*MAINAXI_S_AXI_ID_WIDTH +: MAINAXI_S_AXI_ID_WIDTH]),
  .S_AXI_RDATA(axim_rdata[M_PORT_NUM_HRMEM_SRAM_REG*32 +: 32]),
  .S_AXI_RRESP(axim_rresp[M_PORT_NUM_HRMEM_SRAM_REG*2 +: 2]),
  .S_AXI_RLAST(axim_rlast[M_PORT_NUM_HRMEM_SRAM_REG*1 +: 1]),
  .S_AXI_RVALID(axim_rvalid[M_PORT_NUM_HRMEM_SRAM_REG*1 +: 1]),
  .S_AXI_RREADY(axim_rready[M_PORT_NUM_HRMEM_SRAM_REG*1 +: 1]),
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
  .S_AXI_AWID(axim_awid[M_PORT_NUM_HRMEM_BRAM_REG*MAINAXI_S_AXI_ID_WIDTH +: MAINAXI_S_AXI_ID_WIDTH]),
  .S_AXI_AWADDR(axim_awaddr[M_PORT_NUM_HRMEM_BRAM_REG*32 +: 32]),
  .S_AXI_AWLEN(axim_awlen[M_PORT_NUM_HRMEM_BRAM_REG*8 +: 8]),
  .S_AXI_AWSIZE(axim_awsize[M_PORT_NUM_HRMEM_BRAM_REG*3 +: 3]),
  .S_AXI_AWBURST(axim_awburst[M_PORT_NUM_HRMEM_BRAM_REG*2 +: 2]),
  .S_AXI_AWLOCK(axim_awlock[M_PORT_NUM_HRMEM_BRAM_REG*1 +: 1]),
  .S_AXI_AWCACHE(axim_awcache[M_PORT_NUM_HRMEM_BRAM_REG*4 +: 4]),
  .S_AXI_AWPROT(axim_awprot[M_PORT_NUM_HRMEM_BRAM_REG*3 +: 3]),
  .S_AXI_AWVALID(axim_awvalid[M_PORT_NUM_HRMEM_BRAM_REG*1 +: 1]),
  .S_AXI_AWREADY(axim_awready[M_PORT_NUM_HRMEM_BRAM_REG*1 +: 1]),
  .S_AXI_WDATA(axim_wdata[M_PORT_NUM_HRMEM_BRAM_REG*32 +: 32]),
  .S_AXI_WSTRB(axim_wstrb[M_PORT_NUM_HRMEM_BRAM_REG*4 +: 4]),
  .S_AXI_WLAST(axim_wlast[M_PORT_NUM_HRMEM_BRAM_REG*1 +: 1]),
  .S_AXI_WVALID(axim_wvalid[M_PORT_NUM_HRMEM_BRAM_REG*1 +: 1]),
  .S_AXI_WREADY(axim_wready[M_PORT_NUM_HRMEM_BRAM_REG*1 +: 1]),
  .S_AXI_BID(axim_bid[M_PORT_NUM_HRMEM_BRAM_REG*MAINAXI_S_AXI_ID_WIDTH +: MAINAXI_S_AXI_ID_WIDTH]),
  .S_AXI_BRESP(axim_bresp[M_PORT_NUM_HRMEM_BRAM_REG*2 +: 2]),
  .S_AXI_BVALID(axim_bvalid[M_PORT_NUM_HRMEM_BRAM_REG*1 +: 1]),
  .S_AXI_BREADY(axim_bready[M_PORT_NUM_HRMEM_BRAM_REG*1 +: 1]),
  .S_AXI_ARID(axim_arid[M_PORT_NUM_HRMEM_BRAM_REG*MAINAXI_S_AXI_ID_WIDTH +: MAINAXI_S_AXI_ID_WIDTH]),
  .S_AXI_ARADDR(axim_araddr[M_PORT_NUM_HRMEM_BRAM_REG*32 +: 32]),
  .S_AXI_ARLEN(axim_arlen[M_PORT_NUM_HRMEM_BRAM_REG*8 +: 8]),
  .S_AXI_ARSIZE(axim_arsize[M_PORT_NUM_HRMEM_BRAM_REG*3 +: 3]),
  .S_AXI_ARBURST(axim_arburst[M_PORT_NUM_HRMEM_BRAM_REG*2 +: 2]),
  .S_AXI_ARLOCK(axim_arlock[M_PORT_NUM_HRMEM_BRAM_REG*1 +: 1]),
  .S_AXI_ARCACHE(axim_arcache[M_PORT_NUM_HRMEM_BRAM_REG*4 +: 4]),
  .S_AXI_ARPROT(axim_arprot[M_PORT_NUM_HRMEM_BRAM_REG*3 +: 3]),
  .S_AXI_ARVALID(axim_arvalid[M_PORT_NUM_HRMEM_BRAM_REG*1 +: 1]),
  .S_AXI_ARREADY(axim_arready[M_PORT_NUM_HRMEM_BRAM_REG*1 +: 1]),
  .S_AXI_RID(axim_rid[M_PORT_NUM_HRMEM_BRAM_REG*MAINAXI_S_AXI_ID_WIDTH +: MAINAXI_S_AXI_ID_WIDTH]),
  .S_AXI_RDATA(axim_rdata[M_PORT_NUM_HRMEM_BRAM_REG*32 +: 32]),
  .S_AXI_RRESP(axim_rresp[M_PORT_NUM_HRMEM_BRAM_REG*2 +: 2]),
  .S_AXI_RLAST(axim_rlast[M_PORT_NUM_HRMEM_BRAM_REG*1 +: 1]),
  .S_AXI_RVALID(axim_rvalid[M_PORT_NUM_HRMEM_BRAM_REG*1 +: 1]),
  .S_AXI_RREADY(axim_rready[M_PORT_NUM_HRMEM_BRAM_REG*1 +: 1]),
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
assign LPAHB_M_AXI_AWID = axim_awid[M_PORT_NUM_LPAHB*MAINAXI_S_AXI_ID_WIDTH +: MAINAXI_S_AXI_ID_WIDTH];
assign LPAHB_M_AXI_AWADDR = axim_awaddr[M_PORT_NUM_LPAHB*32 +: 32];
assign LPAHB_M_AXI_AWLEN = axim_awlen[M_PORT_NUM_LPAHB*8 +: 8];
assign LPAHB_M_AXI_AWSIZE = axim_awsize[M_PORT_NUM_LPAHB*3 +: 3];
assign LPAHB_M_AXI_AWBURST = axim_awburst[M_PORT_NUM_LPAHB*2 +: 2];
assign LPAHB_M_AXI_AWVALID = axim_awvalid[M_PORT_NUM_LPAHB*1 +: 1];
assign axim_awready[M_PORT_NUM_LPAHB*1 +: 1] = LPAHB_M_AXI_AWREADY;
assign LPAHB_M_AXI_WDATA = axim_wdata[M_PORT_NUM_LPAHB*32 +: 32];
assign LPAHB_M_AXI_WSTRB = axim_wstrb[M_PORT_NUM_LPAHB*4 +: 4];
assign LPAHB_M_AXI_WLAST = axim_wlast[M_PORT_NUM_LPAHB*1 +: 1];
assign LPAHB_M_AXI_WVALID = axim_wvalid[M_PORT_NUM_LPAHB*1 +: 1];
assign axim_wready[M_PORT_NUM_LPAHB*1 +: 1] = LPAHB_M_AXI_WREADY;
assign axim_bid[M_PORT_NUM_LPAHB*MAINAXI_S_AXI_ID_WIDTH +: MAINAXI_S_AXI_ID_WIDTH] = LPAHB_M_AXI_BID;
assign axim_bresp[M_PORT_NUM_LPAHB*2 +: 2] = LPAHB_M_AXI_BRESP;
assign axim_bvalid[M_PORT_NUM_LPAHB*1 +: 1] = LPAHB_M_AXI_BVALID;
assign LPAHB_M_AXI_BREADY = axim_bready[M_PORT_NUM_LPAHB*1 +: 1];
assign LPAHB_M_AXI_ARID = axim_arid[M_PORT_NUM_LPAHB*MAINAXI_S_AXI_ID_WIDTH +: MAINAXI_S_AXI_ID_WIDTH];
assign LPAHB_M_AXI_ARADDR = axim_araddr[M_PORT_NUM_LPAHB*32 +: 32];
assign LPAHB_M_AXI_ARLEN = axim_arlen[M_PORT_NUM_LPAHB*8 +: 8];
assign LPAHB_M_AXI_ARSIZE = axim_arsize[M_PORT_NUM_LPAHB*3 +: 3];
assign LPAHB_M_AXI_ARBURST = axim_arburst[M_PORT_NUM_LPAHB*2 +: 2];
assign LPAHB_M_AXI_ARVALID = axim_arvalid[M_PORT_NUM_LPAHB*1 +: 1];
assign axim_arready[M_PORT_NUM_LPAHB*1 +: 1] = LPAHB_M_AXI_ARREADY;
assign axim_rid[M_PORT_NUM_LPAHB*MAINAXI_S_AXI_ID_WIDTH +: MAINAXI_S_AXI_ID_WIDTH] = LPAHB_M_AXI_RID;
assign axim_rdata[M_PORT_NUM_LPAHB*32 +: 32] = LPAHB_M_AXI_RDATA;
assign axim_rresp[M_PORT_NUM_LPAHB*2 +: 2] = LPAHB_M_AXI_RRESP;
assign axim_rlast[M_PORT_NUM_LPAHB*1 +: 1] = LPAHB_M_AXI_RLAST;
assign axim_rvalid[M_PORT_NUM_LPAHB*1 +: 1] = LPAHB_M_AXI_RVALID;
assign LPAHB_M_AXI_RREADY = axim_rready[M_PORT_NUM_LPAHB*1 +: 1];

// main_axi_crossbar to UDL AXI4 Master Interface
assign UDL_M_AXI_AWID = axim_awid[M_PORT_NUM_UDL*MAINAXI_S_AXI_ID_WIDTH +: MAINAXI_S_AXI_ID_WIDTH];
assign UDL_M_AXI_AWADDR = axim_awaddr[M_PORT_NUM_UDL*32 +: 32];
assign UDL_M_AXI_AWLEN = axim_awlen[M_PORT_NUM_UDL*8 +: 8];
assign UDL_M_AXI_AWSIZE = axim_awsize[M_PORT_NUM_UDL*3 +: 3];
assign UDL_M_AXI_AWBURST = axim_awburst[M_PORT_NUM_UDL*2 +: 2];
assign UDL_M_AXI_AWLOCK = axim_awlock[M_PORT_NUM_UDL*1 +: 1];
assign UDL_M_AXI_AWCACHE = axim_awcache[M_PORT_NUM_UDL*4 +: 4];
assign UDL_M_AXI_AWPROT = axim_awprot[M_PORT_NUM_UDL*3 +: 3];
assign UDL_M_AXI_AWREGION = axim_awregion[M_PORT_NUM_UDL*4 +: 4];
assign UDL_M_AXI_AWQOS = axim_awqos[M_PORT_NUM_UDL*4 +: 4];
assign UDL_M_AXI_AWVALID = axim_awvalid[M_PORT_NUM_UDL*1 +: 1];
assign axim_awready[M_PORT_NUM_UDL*1 +: 1] = UDL_M_AXI_AWREADY;
assign UDL_M_AXI_WDATA = axim_wdata[M_PORT_NUM_UDL*32 +: 32];
assign UDL_M_AXI_WSTRB = axim_wstrb[M_PORT_NUM_UDL*4 +: 4];
assign UDL_M_AXI_WLAST = axim_wlast[M_PORT_NUM_UDL*1 +: 1];
assign UDL_M_AXI_WVALID = axim_wvalid[M_PORT_NUM_UDL*1 +: 1];
assign axim_wready[M_PORT_NUM_UDL*1 +: 1] = UDL_M_AXI_WREADY;
assign axim_bid[M_PORT_NUM_UDL*MAINAXI_S_AXI_ID_WIDTH +: MAINAXI_S_AXI_ID_WIDTH] = UDL_M_AXI_BID;
assign axim_bresp[M_PORT_NUM_UDL*2 +: 2] = UDL_M_AXI_BRESP;
assign axim_bvalid[M_PORT_NUM_UDL*1 +: 1] = UDL_M_AXI_BVALID;
assign UDL_M_AXI_BREADY = axim_bready[M_PORT_NUM_UDL*1 +: 1];
assign UDL_M_AXI_ARID = axim_arid[M_PORT_NUM_UDL*MAINAXI_S_AXI_ID_WIDTH +: MAINAXI_S_AXI_ID_WIDTH];
assign UDL_M_AXI_ARADDR = axim_araddr[M_PORT_NUM_UDL*32 +: 32];
assign UDL_M_AXI_ARLEN = axim_arlen[M_PORT_NUM_UDL*8 +: 8];
assign UDL_M_AXI_ARSIZE = axim_arsize[M_PORT_NUM_UDL*3 +: 3];
assign UDL_M_AXI_ARBURST = axim_arburst[M_PORT_NUM_UDL*2 +: 2];
assign UDL_M_AXI_ARLOCK = axim_arlock[M_PORT_NUM_UDL*1 +: 1];
assign UDL_M_AXI_ARCACHE = axim_arcache[M_PORT_NUM_UDL*4 +: 4];
assign UDL_M_AXI_ARPROT = axim_arprot[M_PORT_NUM_UDL*3 +: 3];
assign UDL_M_AXI_ARREGION = axim_arregion[M_PORT_NUM_UDL*4 +: 4];
assign UDL_M_AXI_ARQOS = axim_arqos[M_PORT_NUM_UDL*4 +: 4];
assign UDL_M_AXI_ARVALID = axim_arvalid[M_PORT_NUM_UDL*1 +: 1];
assign axim_arready[M_PORT_NUM_UDL*1 +: 1] = UDL_M_AXI_ARREADY;
assign axim_rid[M_PORT_NUM_UDL*MAINAXI_S_AXI_ID_WIDTH +: MAINAXI_S_AXI_ID_WIDTH] = UDL_M_AXI_RID;
assign axim_rdata[M_PORT_NUM_UDL*32 +: 32] = UDL_M_AXI_RDATA;
assign axim_rresp[M_PORT_NUM_UDL*2 +: 2] = UDL_M_AXI_RRESP;
assign axim_rlast[M_PORT_NUM_UDL*1 +: 1] = UDL_M_AXI_RLAST;
assign axim_rvalid[M_PORT_NUM_UDL*1 +: 1] = UDL_M_AXI_RVALID;
assign UDL_M_AXI_RREADY = axim_rready[M_PORT_NUM_UDL*1 +: 1];

endmodule
