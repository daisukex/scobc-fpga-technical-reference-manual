//-----------------------------------------------
// Module: udl_axi
//  UDL(User Design Logic) AXI Bus
//-----------------------------------------------
// Copyright © 2022 Space Cubics, LLC.
//-----------------------------------------------
module udl_axi # (
  parameter CM3SS_UDL_ISR_NUM = 16,
  parameter MAINAXI_UDL_M_AXI_ID_WIDTH = 2,
  parameter MAINAXI_S_AXI_ID_WIDTH = 3
) (
  // System Interface
  input  MAXI_CLK,
  input  REF_CLK,
  input  USER_CLK1,
  input  USER_CLK2,
  input  SYS_RSTB,
  input  SYS_RSTB_SYNC_REFCLK,
  input  SYS_RSTB_SYNC_USERCLK1,
  input  SYS_RSTB_SYNC_USERCLK2,
  input  POR_RSTB,
  input  POR_RSTB_SYNC_REFCLK,
  input  BUS_RSTB,

  output [CM3SS_UDL_ISR_NUM-1:0] UDL_INTISR,

  // UDL AXI4 Master Interface
  output [MAINAXI_UDL_M_AXI_ID_WIDTH-1:0] UDL_AXIM_AWID,
  output [31:0] UDL_AXIM_AWADDR,
  output [7:0] UDL_AXIM_AWLEN,
  output [2:0] UDL_AXIM_AWSIZE,
  output [1:0] UDL_AXIM_AWBURST,
  output UDL_AXIM_AWLOCK,
  output [3:0] UDL_AXIM_AWCACHE,
  output [2:0] UDL_AXIM_AWPROT,
  output [3:0] UDL_AXIM_AWQOS,
  output UDL_AXIM_AWVALID,
  input  UDL_AXIM_AWREADY,
  output [31:0] UDL_AXIM_WDATA,
  output [3:0] UDL_AXIM_WSTRB,
  output UDL_AXIM_WLAST,
  output UDL_AXIM_WVALID,
  input  UDL_AXIM_WREADY,
  input  [MAINAXI_UDL_M_AXI_ID_WIDTH-1:0] UDL_AXIM_BID,
  input  [1:0] UDL_AXIM_BRESP,
  input  UDL_AXIM_BVALID,
  output UDL_AXIM_BREADY,
  output [MAINAXI_UDL_M_AXI_ID_WIDTH-1:0] UDL_AXIM_ARID,
  output [31:0] UDL_AXIM_ARADDR,
  output [7:0] UDL_AXIM_ARLEN,
  output [2:0] UDL_AXIM_ARSIZE,
  output [1:0] UDL_AXIM_ARBURST,
  output UDL_AXIM_ARLOCK,
  output [3:0] UDL_AXIM_ARCACHE,
  output [2:0] UDL_AXIM_ARPROT,
  output [3:0] UDL_AXIM_ARQOS,
  output UDL_AXIM_ARVALID,
  input  UDL_AXIM_ARREADY,
  input  [MAINAXI_UDL_M_AXI_ID_WIDTH-1:0] UDL_AXIM_RID,
  input  [31:0] UDL_AXIM_RDATA,
  input  [1:0] UDL_AXIM_RRESP,
  input  UDL_AXIM_RLAST,
  input  UDL_AXIM_RVALID,
  output UDL_AXIM_RREADY,

  // UDL AXI4 Slave Interface
  input  [MAINAXI_S_AXI_ID_WIDTH-1:0] UDL_AXIS_AWID,
  input  [31:0] UDL_AXIS_AWADDR,
  input  [7:0] UDL_AXIS_AWLEN,
  input  [2:0] UDL_AXIS_AWSIZE,
  input  [1:0] UDL_AXIS_AWBURST,
  input  UDL_AXIS_AWLOCK,
  input  [3:0] UDL_AXIS_AWCACHE,
  input  [2:0] UDL_AXIS_AWPROT,
  input  [3:0] UDL_AXIS_AWREGION,
  input  [3:0] UDL_AXIS_AWQOS,
  input  UDL_AXIS_AWVALID,
  output UDL_AXIS_AWREADY,
  input  [31:0] UDL_AXIS_WDATA,
  input  [3:0] UDL_AXIS_WSTRB,
  input  UDL_AXIS_WLAST,
  input  UDL_AXIS_WVALID,
  output UDL_AXIS_WREADY,
  output [MAINAXI_S_AXI_ID_WIDTH-1:0] UDL_AXIS_BID,
  output [1:0] UDL_AXIS_BRESP,
  output UDL_AXIS_BVALID,
  input  UDL_AXIS_BREADY,
  input  [MAINAXI_S_AXI_ID_WIDTH-1:0] UDL_AXIS_ARID,
  input  [31:0] UDL_AXIS_ARADDR,
  input  [7:0] UDL_AXIS_ARLEN,
  input  [2:0] UDL_AXIS_ARSIZE,
  input  [1:0] UDL_AXIS_ARBURST,
  input  UDL_AXIS_ARLOCK,
  input  [3:0] UDL_AXIS_ARCACHE,
  input  [2:0] UDL_AXIS_ARPROT,
  input  [3:0] UDL_AXIS_ARREGION,
  input  [3:0] UDL_AXIS_ARQOS,
  input  UDL_AXIS_ARVALID,
  output UDL_AXIS_ARREADY,
  output [MAINAXI_S_AXI_ID_WIDTH-1:0] UDL_AXIS_RID,
  output [31:0] UDL_AXIS_RDATA,
  output [1:0] UDL_AXIS_RRESP,
  output UDL_AXIS_RLAST,
  output UDL_AXIS_RVALID,
  input  UDL_AXIS_RREADY

  // User IO Interface
//  inout [15:0] UIO1,
//  inout [15:0] UIO2,
//  inout UIO4
);

localparam CRSBAR_S_PORTS = 1;
localparam CRSBAR_S_PORT_NUM_MAINAXI = 0;

localparam CRSBAR_M_PORTS = 4;
localparam CRSBAR_M_PORT_NUM_UDLIP1 = 0;
localparam CRSBAR_M_PORT_NUM_UDLIP2 = 1;
localparam CRSBAR_M_PORT_NUM_UDLIP3 = 2;
localparam CRSBAR_M_PORT_NUM_UDLIP4 = 3;

wire [MAINAXI_S_AXI_ID_WIDTH*CRSBAR_S_PORTS-1:0] axis_awid;
wire [32*CRSBAR_S_PORTS-1:0] axis_awaddr;
wire [8*CRSBAR_S_PORTS-1:0] axis_awlen;
wire [3*CRSBAR_S_PORTS-1:0] axis_awsize;
wire [2*CRSBAR_S_PORTS-1:0] axis_awburst;
wire [1*CRSBAR_S_PORTS-1:0] axis_awlock;
wire [4*CRSBAR_S_PORTS-1:0] axis_awcache;
wire [3*CRSBAR_S_PORTS-1:0] axis_awprot;
wire [4*CRSBAR_S_PORTS-1:0] axis_awqos;
wire [1*CRSBAR_S_PORTS-1:0] axis_awvalid;
wire [1*CRSBAR_S_PORTS-1:0] axis_awready;
wire [32*CRSBAR_S_PORTS-1:0] axis_wdata;
wire [4*CRSBAR_S_PORTS-1:0] axis_wstrb;
wire [1*CRSBAR_S_PORTS-1:0] axis_wlast;
wire [1*CRSBAR_S_PORTS-1:0] axis_wvalid;
wire [1*CRSBAR_S_PORTS-1:0] axis_wready;
wire [MAINAXI_S_AXI_ID_WIDTH*CRSBAR_S_PORTS-1:0] axis_bid;
wire [2*CRSBAR_S_PORTS-1:0] axis_bresp;
wire [1*CRSBAR_S_PORTS-1:0] axis_bvalid;
wire [1*CRSBAR_S_PORTS-1:0] axis_bready;
wire [MAINAXI_S_AXI_ID_WIDTH*CRSBAR_S_PORTS-1:0] axis_arid;
wire [32*CRSBAR_S_PORTS-1:0] axis_araddr;
wire [8*CRSBAR_S_PORTS-1:0] axis_arlen;
wire [3*CRSBAR_S_PORTS-1:0] axis_arsize;
wire [2*CRSBAR_S_PORTS-1:0] axis_arburst;
wire [1*CRSBAR_S_PORTS-1:0] axis_arlock;
wire [4*CRSBAR_S_PORTS-1:0] axis_arcache;
wire [3*CRSBAR_S_PORTS-1:0] axis_arprot;
wire [4*CRSBAR_S_PORTS-1:0] axis_arqos;
wire [1*CRSBAR_S_PORTS-1:0] axis_arvalid;
wire [1*CRSBAR_S_PORTS-1:0] axis_arready;
wire [MAINAXI_S_AXI_ID_WIDTH*CRSBAR_S_PORTS-1:0] axis_rid;
wire [32*CRSBAR_S_PORTS-1:0] axis_rdata;
wire [2*CRSBAR_S_PORTS-1:0] axis_rresp;
wire [1*CRSBAR_S_PORTS-1:0] axis_rlast;
wire [1*CRSBAR_S_PORTS-1:0] axis_rvalid;
wire [1*CRSBAR_S_PORTS-1:0] axis_rready;

wire [MAINAXI_S_AXI_ID_WIDTH*CRSBAR_M_PORTS-1:0] axim_awid;
wire [32*CRSBAR_M_PORTS-1:0] axim_awaddr;
wire [8*CRSBAR_M_PORTS-1:0] axim_awlen;
wire [3*CRSBAR_M_PORTS-1:0] axim_awsize;
wire [2*CRSBAR_M_PORTS-1:0] axim_awburst;
wire [1*CRSBAR_M_PORTS-1:0] axim_awlock;
wire [4*CRSBAR_M_PORTS-1:0] axim_awcache;
wire [3*CRSBAR_M_PORTS-1:0] axim_awprot;
wire [4*CRSBAR_M_PORTS-1:0] axim_awregion;
wire [4*CRSBAR_M_PORTS-1:0] axim_awqos;
wire [1*CRSBAR_M_PORTS-1:0] axim_awvalid;
wire [1*CRSBAR_M_PORTS-1:0] axim_awready;
wire [32*CRSBAR_M_PORTS-1:0] axim_wdata;
wire [4*CRSBAR_M_PORTS-1:0] axim_wstrb;
wire [1*CRSBAR_M_PORTS-1:0] axim_wlast;
wire [1*CRSBAR_M_PORTS-1:0] axim_wvalid;
wire [1*CRSBAR_M_PORTS-1:0] axim_wready;
wire [MAINAXI_S_AXI_ID_WIDTH*CRSBAR_M_PORTS-1:0] axim_bid;
wire [2*CRSBAR_M_PORTS-1:0] axim_bresp;
wire [1*CRSBAR_M_PORTS-1:0] axim_bvalid;
wire [1*CRSBAR_M_PORTS-1:0] axim_bready;
wire [MAINAXI_S_AXI_ID_WIDTH*CRSBAR_M_PORTS-1:0] axim_arid;
wire [32*CRSBAR_M_PORTS-1:0] axim_araddr;
wire [8*CRSBAR_M_PORTS-1:0] axim_arlen;
wire [3*CRSBAR_M_PORTS-1:0] axim_arsize;
wire [2*CRSBAR_M_PORTS-1:0] axim_arburst;
wire [1*CRSBAR_M_PORTS-1:0] axim_arlock;
wire [4*CRSBAR_M_PORTS-1:0] axim_arcache;
wire [3*CRSBAR_M_PORTS-1:0] axim_arprot;
wire [4*CRSBAR_M_PORTS-1:0] axim_arregion;
wire [4*CRSBAR_M_PORTS-1:0] axim_arqos;
wire [1*CRSBAR_M_PORTS-1:0] axim_arvalid;
wire [1*CRSBAR_M_PORTS-1:0] axim_arready;
wire [MAINAXI_S_AXI_ID_WIDTH*CRSBAR_M_PORTS-1:0] axim_rid;
wire [32*CRSBAR_M_PORTS-1:0] axim_rdata;
wire [2*CRSBAR_M_PORTS-1:0] axim_rresp;
wire [1*CRSBAR_M_PORTS-1:0] axim_rlast;
wire [1*CRSBAR_M_PORTS-1:0] axim_rvalid;
wire [1*CRSBAR_M_PORTS-1:0] axim_rready;

// Interrupt to CPU
assign UDL_INTISR = {CM3SS_UDL_ISR_NUM{1'b0}};

// UDL AXI4 Master Interface (Dummy Clamp)
assign UDL_AXIM_AWID = {MAINAXI_UDL_M_AXI_ID_WIDTH{1'b0}};
assign UDL_AXIM_AWADDR = 32'h0;
assign UDL_AXIM_AWLEN = 8'h0;
assign UDL_AXIM_AWSIZE = 3'h0;
assign UDL_AXIM_AWBURST = 2'h0;
assign UDL_AXIM_AWLOCK = 1'b0;
assign UDL_AXIM_AWCACHE = 4'h0;
assign UDL_AXIM_AWPROT = 3'h0;
assign UDL_AXIM_AWQOS = 4'h0;
assign UDL_AXIM_AWVALID = 1'b0;
assign UDL_AXIM_WDATA = 32'h0;
assign UDL_AXIM_WSTRB = 4'h0;
assign UDL_AXIM_WLAST = 1'b0;
assign UDL_AXIM_WVALID = 1'b0;
assign UDL_AXIM_BREADY = 1'b1;
assign UDL_AXIM_ARID = {MAINAXI_UDL_M_AXI_ID_WIDTH{1'b0}};
assign UDL_AXIM_ARADDR = 32'h0;
assign UDL_AXIM_ARLEN = 8'h0;
assign UDL_AXIM_ARSIZE = 3'h0;
assign UDL_AXIM_ARBURST = 2'h0;
assign UDL_AXIM_ARLOCK = 1'b0;
assign UDL_AXIM_ARCACHE = 4'h0;
assign UDL_AXIM_ARPROT = 3'h0;
assign UDL_AXIM_ARQOS = 4'h0;
assign UDL_AXIM_ARVALID = 1'b0;
assign UDL_AXIM_RREADY = 1'b1;

// MAINAXI AXI4 Slave Interface to main_axi_crossbar
assign axis_awid[CRSBAR_S_PORT_NUM_MAINAXI*MAINAXI_S_AXI_ID_WIDTH +: MAINAXI_S_AXI_ID_WIDTH] = UDL_AXIS_AWID;
assign axis_awaddr[CRSBAR_S_PORT_NUM_MAINAXI*32 +: 32] = UDL_AXIS_AWADDR;
assign axis_awlen[CRSBAR_S_PORT_NUM_MAINAXI*8 +: 8] = UDL_AXIS_AWLEN;
assign axis_awsize[CRSBAR_S_PORT_NUM_MAINAXI*3 +: 3] = UDL_AXIS_AWSIZE;
assign axis_awburst[CRSBAR_S_PORT_NUM_MAINAXI*2 +: 2] = UDL_AXIS_AWBURST;
assign axis_awlock[CRSBAR_S_PORT_NUM_MAINAXI*1 +: 1] = UDL_AXIS_AWLOCK;
assign axis_awcache[CRSBAR_S_PORT_NUM_MAINAXI*4 +: 4] = UDL_AXIS_AWCACHE;
assign axis_awprot[CRSBAR_S_PORT_NUM_MAINAXI*3 +: 3] = UDL_AXIS_AWPROT;
assign axis_awqos[CRSBAR_S_PORT_NUM_MAINAXI*4 +: 4] = UDL_AXIS_AWQOS;
assign axis_awvalid[CRSBAR_S_PORT_NUM_MAINAXI*1 +: 1] = UDL_AXIS_AWVALID;
assign axis_wdata[CRSBAR_S_PORT_NUM_MAINAXI*32 +:32] = UDL_AXIS_WDATA;
assign axis_wstrb[CRSBAR_S_PORT_NUM_MAINAXI*4 +: 4] = UDL_AXIS_WSTRB;
assign axis_wlast[CRSBAR_S_PORT_NUM_MAINAXI*1 +: 1] = UDL_AXIS_WLAST;
assign axis_wvalid[CRSBAR_S_PORT_NUM_MAINAXI*1 +: 1] = UDL_AXIS_WVALID;
assign axis_bready[CRSBAR_S_PORT_NUM_MAINAXI*1 +: 1] = UDL_AXIS_BREADY;
assign axis_arid[CRSBAR_S_PORT_NUM_MAINAXI*MAINAXI_S_AXI_ID_WIDTH +: MAINAXI_S_AXI_ID_WIDTH] = UDL_AXIS_ARID;
assign axis_araddr[CRSBAR_S_PORT_NUM_MAINAXI*32 +:32] = UDL_AXIS_ARADDR;
assign axis_arlen[CRSBAR_S_PORT_NUM_MAINAXI*8 +: 8] = UDL_AXIS_ARLEN;
assign axis_arsize[CRSBAR_S_PORT_NUM_MAINAXI*3 +: 3] = UDL_AXIS_ARSIZE;
assign axis_arburst[CRSBAR_S_PORT_NUM_MAINAXI*2 +: 2] = UDL_AXIS_ARBURST;
assign axis_arlock[CRSBAR_S_PORT_NUM_MAINAXI*1 +: 1] = UDL_AXIS_ARLOCK;
assign axis_arcache[CRSBAR_S_PORT_NUM_MAINAXI*4 +: 4] = UDL_AXIS_ARCACHE;
assign axis_arprot[CRSBAR_S_PORT_NUM_MAINAXI*3 +: 3] = UDL_AXIS_ARPROT;
assign axis_arqos[CRSBAR_S_PORT_NUM_MAINAXI*4 +: 4] = UDL_AXIS_ARQOS;
assign axis_arvalid[CRSBAR_S_PORT_NUM_MAINAXI*1 +: 1] = UDL_AXIS_ARVALID;
assign axis_rready[CRSBAR_S_PORT_NUM_MAINAXI*1 +: 1] = UDL_AXIS_RREADY;
assign UDL_AXIS_AWREADY = axis_awready[CRSBAR_S_PORT_NUM_MAINAXI*1 +: 1];
assign UDL_AXIS_WREADY = axis_wready[CRSBAR_S_PORT_NUM_MAINAXI*1 +: 1];
assign UDL_AXIS_BID = axis_bid[CRSBAR_S_PORT_NUM_MAINAXI*MAINAXI_S_AXI_ID_WIDTH +: MAINAXI_S_AXI_ID_WIDTH];
assign UDL_AXIS_BRESP = axis_bresp[CRSBAR_S_PORT_NUM_MAINAXI*2 +: 2];
assign UDL_AXIS_BVALID = axis_bvalid[CRSBAR_S_PORT_NUM_MAINAXI*1 +: 1];
assign UDL_AXIS_ARREADY = axis_arready[CRSBAR_S_PORT_NUM_MAINAXI*1 +: 1];
assign UDL_AXIS_RID = axis_rid[CRSBAR_S_PORT_NUM_MAINAXI*MAINAXI_S_AXI_ID_WIDTH +: MAINAXI_S_AXI_ID_WIDTH];
assign UDL_AXIS_RDATA = axis_rdata[CRSBAR_S_PORT_NUM_MAINAXI*32 +: 32];
assign UDL_AXIS_RRESP = axis_rresp[CRSBAR_S_PORT_NUM_MAINAXI*2 +: 2];
assign UDL_AXIS_RLAST = axis_rlast[CRSBAR_S_PORT_NUM_MAINAXI*1 +: 1];
assign UDL_AXIS_RVALID = axis_rvalid[CRSBAR_S_PORT_NUM_MAINAXI*1 +: 1];

// UDL AXI Bus Crossvar
udl_axi_crossbar udl_axi_crossbar (
  .aclk(MAXI_CLK),
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

// UDL IP AXI Bus-1 (Dummy)
sc_axi_slave # (
  .P_AD_W(32),
  .P_DT_W(32),
  .P_ID_W(MAINAXI_S_AXI_ID_WIDTH)
) axi_slave_udlip1_dummy (
  // AXI Interface
  .S_AXI_ACLK(MAXI_CLK),
  .S_AXI_ARESETN(SYS_RSTB),
  .S_AXI_AWID(axim_awid[CRSBAR_M_PORT_NUM_UDLIP1*MAINAXI_S_AXI_ID_WIDTH +: MAINAXI_S_AXI_ID_WIDTH]),
  .S_AXI_AWADDR(axim_awaddr[CRSBAR_M_PORT_NUM_UDLIP1*32 +: 32]),
  .S_AXI_AWLEN(axim_awlen[CRSBAR_M_PORT_NUM_UDLIP1*8 +: 8]),
  .S_AXI_AWSIZE(axim_awsize[CRSBAR_M_PORT_NUM_UDLIP1*3 +: 3]),
  .S_AXI_AWBURST(axim_awburst[CRSBAR_M_PORT_NUM_UDLIP1*2 +: 2]),
  .S_AXI_AWLOCK(axim_awlock[CRSBAR_M_PORT_NUM_UDLIP1*1 +: 1]),
  .S_AXI_AWCACHE(axim_awcache[CRSBAR_M_PORT_NUM_UDLIP1*4 +: 4]),
  .S_AXI_AWPROT(axim_awprot[CRSBAR_M_PORT_NUM_UDLIP1*3 +: 3]),
  .S_AXI_AWVALID(axim_awvalid[CRSBAR_M_PORT_NUM_UDLIP1*1 +: 1]),
  .S_AXI_AWREADY(axim_awready[CRSBAR_M_PORT_NUM_UDLIP1*1 +: 1]),
  .S_AXI_WDATA(axim_wdata[CRSBAR_M_PORT_NUM_UDLIP1*32 +: 32]),
  .S_AXI_WSTRB(axim_wstrb[CRSBAR_M_PORT_NUM_UDLIP1*4 +: 4]),
  .S_AXI_WLAST(axim_wlast[CRSBAR_M_PORT_NUM_UDLIP1*1 +: 1]),
  .S_AXI_WVALID(axim_wvalid[CRSBAR_M_PORT_NUM_UDLIP1*1 +: 1]),
  .S_AXI_WREADY(axim_wready[CRSBAR_M_PORT_NUM_UDLIP1*1 +: 1]),
  .S_AXI_BID(axim_bid[CRSBAR_M_PORT_NUM_UDLIP1*MAINAXI_S_AXI_ID_WIDTH +: MAINAXI_S_AXI_ID_WIDTH]),
  .S_AXI_BRESP(axim_bresp[CRSBAR_M_PORT_NUM_UDLIP1*2 +: 2]),
  .S_AXI_BVALID(axim_bvalid[CRSBAR_M_PORT_NUM_UDLIP1*1 +: 1]),
  .S_AXI_BREADY(axim_bready[CRSBAR_M_PORT_NUM_UDLIP1*1 +: 1]),
  .S_AXI_ARID(axim_arid[CRSBAR_M_PORT_NUM_UDLIP1*MAINAXI_S_AXI_ID_WIDTH +: MAINAXI_S_AXI_ID_WIDTH]),
  .S_AXI_ARADDR(axim_araddr[CRSBAR_M_PORT_NUM_UDLIP1*32 +: 32]),
  .S_AXI_ARLEN(axim_arlen[CRSBAR_M_PORT_NUM_UDLIP1*8 +: 8]),
  .S_AXI_ARSIZE(axim_arsize[CRSBAR_M_PORT_NUM_UDLIP1*3 +: 3]),
  .S_AXI_ARBURST(axim_arburst[CRSBAR_M_PORT_NUM_UDLIP1*2 +: 2]),
  .S_AXI_ARLOCK(axim_arlock[CRSBAR_M_PORT_NUM_UDLIP1*1 +: 1]),
  .S_AXI_ARCACHE(axim_arcache[CRSBAR_M_PORT_NUM_UDLIP1*4 +: 4]),
  .S_AXI_ARPROT(axim_arprot[CRSBAR_M_PORT_NUM_UDLIP1*3 +: 3]),
  .S_AXI_ARVALID(axim_arvalid[CRSBAR_M_PORT_NUM_UDLIP1*1 +: 1]),
  .S_AXI_ARREADY(axim_arready[CRSBAR_M_PORT_NUM_UDLIP1*1 +: 1]),
  .S_AXI_RID(axim_rid[CRSBAR_M_PORT_NUM_UDLIP1*MAINAXI_S_AXI_ID_WIDTH +: MAINAXI_S_AXI_ID_WIDTH]),
  .S_AXI_RDATA(axim_rdata[CRSBAR_M_PORT_NUM_UDLIP1*32 +: 32]),
  .S_AXI_RRESP(axim_rresp[CRSBAR_M_PORT_NUM_UDLIP1*2 +: 2]),
  .S_AXI_RLAST(axim_rlast[CRSBAR_M_PORT_NUM_UDLIP1*1 +: 1]),
  .S_AXI_RVALID(axim_rvalid[CRSBAR_M_PORT_NUM_UDLIP1*1 +: 1]),
  .S_AXI_RREADY(axim_rready[CRSBAR_M_PORT_NUM_UDLIP1*1 +: 1]),
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

// UDL IP AXI Bus-2 (Dummy)
sc_axi_slave # (
  .P_AD_W(32),
  .P_DT_W(32),
  .P_ID_W(MAINAXI_S_AXI_ID_WIDTH)
) axi_slave_udlip2_dummy (
  // AXI Interface
  .S_AXI_ACLK(MAXI_CLK),
  .S_AXI_ARESETN(SYS_RSTB),
  .S_AXI_AWID(axim_awid[CRSBAR_M_PORT_NUM_UDLIP2*MAINAXI_S_AXI_ID_WIDTH +: MAINAXI_S_AXI_ID_WIDTH]),
  .S_AXI_AWADDR(axim_awaddr[CRSBAR_M_PORT_NUM_UDLIP2*32 +: 32]),
  .S_AXI_AWLEN(axim_awlen[CRSBAR_M_PORT_NUM_UDLIP2*8 +: 8]),
  .S_AXI_AWSIZE(axim_awsize[CRSBAR_M_PORT_NUM_UDLIP2*3 +: 3]),
  .S_AXI_AWBURST(axim_awburst[CRSBAR_M_PORT_NUM_UDLIP2*2 +: 2]),
  .S_AXI_AWLOCK(axim_awlock[CRSBAR_M_PORT_NUM_UDLIP2*1 +: 1]),
  .S_AXI_AWCACHE(axim_awcache[CRSBAR_M_PORT_NUM_UDLIP2*4 +: 4]),
  .S_AXI_AWPROT(axim_awprot[CRSBAR_M_PORT_NUM_UDLIP2*3 +: 3]),
  .S_AXI_AWVALID(axim_awvalid[CRSBAR_M_PORT_NUM_UDLIP2*1 +: 1]),
  .S_AXI_AWREADY(axim_awready[CRSBAR_M_PORT_NUM_UDLIP2*1 +: 1]),
  .S_AXI_WDATA(axim_wdata[CRSBAR_M_PORT_NUM_UDLIP2*32 +: 32]),
  .S_AXI_WSTRB(axim_wstrb[CRSBAR_M_PORT_NUM_UDLIP2*4 +: 4]),
  .S_AXI_WLAST(axim_wlast[CRSBAR_M_PORT_NUM_UDLIP2*1 +: 1]),
  .S_AXI_WVALID(axim_wvalid[CRSBAR_M_PORT_NUM_UDLIP2*1 +: 1]),
  .S_AXI_WREADY(axim_wready[CRSBAR_M_PORT_NUM_UDLIP2*1 +: 1]),
  .S_AXI_BID(axim_bid[CRSBAR_M_PORT_NUM_UDLIP2*MAINAXI_S_AXI_ID_WIDTH +: MAINAXI_S_AXI_ID_WIDTH]),
  .S_AXI_BRESP(axim_bresp[CRSBAR_M_PORT_NUM_UDLIP2*2 +: 2]),
  .S_AXI_BVALID(axim_bvalid[CRSBAR_M_PORT_NUM_UDLIP2*1 +: 1]),
  .S_AXI_BREADY(axim_bready[CRSBAR_M_PORT_NUM_UDLIP2*1 +: 1]),
  .S_AXI_ARID(axim_arid[CRSBAR_M_PORT_NUM_UDLIP2*MAINAXI_S_AXI_ID_WIDTH +: MAINAXI_S_AXI_ID_WIDTH]),
  .S_AXI_ARADDR(axim_araddr[CRSBAR_M_PORT_NUM_UDLIP2*32 +: 32]),
  .S_AXI_ARLEN(axim_arlen[CRSBAR_M_PORT_NUM_UDLIP2*8 +: 8]),
  .S_AXI_ARSIZE(axim_arsize[CRSBAR_M_PORT_NUM_UDLIP2*3 +: 3]),
  .S_AXI_ARBURST(axim_arburst[CRSBAR_M_PORT_NUM_UDLIP2*2 +: 2]),
  .S_AXI_ARLOCK(axim_arlock[CRSBAR_M_PORT_NUM_UDLIP2*1 +: 1]),
  .S_AXI_ARCACHE(axim_arcache[CRSBAR_M_PORT_NUM_UDLIP2*4 +: 4]),
  .S_AXI_ARPROT(axim_arprot[CRSBAR_M_PORT_NUM_UDLIP2*3 +: 3]),
  .S_AXI_ARVALID(axim_arvalid[CRSBAR_M_PORT_NUM_UDLIP2*1 +: 1]),
  .S_AXI_ARREADY(axim_arready[CRSBAR_M_PORT_NUM_UDLIP2*1 +: 1]),
  .S_AXI_RID(axim_rid[CRSBAR_M_PORT_NUM_UDLIP2*MAINAXI_S_AXI_ID_WIDTH +: MAINAXI_S_AXI_ID_WIDTH]),
  .S_AXI_RDATA(axim_rdata[CRSBAR_M_PORT_NUM_UDLIP2*32 +: 32]),
  .S_AXI_RRESP(axim_rresp[CRSBAR_M_PORT_NUM_UDLIP2*2 +: 2]),
  .S_AXI_RLAST(axim_rlast[CRSBAR_M_PORT_NUM_UDLIP2*1 +: 1]),
  .S_AXI_RVALID(axim_rvalid[CRSBAR_M_PORT_NUM_UDLIP2*1 +: 1]),
  .S_AXI_RREADY(axim_rready[CRSBAR_M_PORT_NUM_UDLIP2*1 +: 1]),
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

// UDL IP AXI Bus-3 (Dummy)
sc_axi_slave # (
  .P_AD_W(32),
  .P_DT_W(32),
  .P_ID_W(MAINAXI_S_AXI_ID_WIDTH)
) axi_slave_udlip3_dummy (
  // AXI Interface
  .S_AXI_ACLK(MAXI_CLK),
  .S_AXI_ARESETN(SYS_RSTB),
  .S_AXI_AWID(axim_awid[CRSBAR_M_PORT_NUM_UDLIP3*MAINAXI_S_AXI_ID_WIDTH +: MAINAXI_S_AXI_ID_WIDTH]),
  .S_AXI_AWADDR(axim_awaddr[CRSBAR_M_PORT_NUM_UDLIP3*32 +: 32]),
  .S_AXI_AWLEN(axim_awlen[CRSBAR_M_PORT_NUM_UDLIP3*8 +: 8]),
  .S_AXI_AWSIZE(axim_awsize[CRSBAR_M_PORT_NUM_UDLIP3*3 +: 3]),
  .S_AXI_AWBURST(axim_awburst[CRSBAR_M_PORT_NUM_UDLIP3*2 +: 2]),
  .S_AXI_AWLOCK(axim_awlock[CRSBAR_M_PORT_NUM_UDLIP3*1 +: 1]),
  .S_AXI_AWCACHE(axim_awcache[CRSBAR_M_PORT_NUM_UDLIP3*4 +: 4]),
  .S_AXI_AWPROT(axim_awprot[CRSBAR_M_PORT_NUM_UDLIP3*3 +: 3]),
  .S_AXI_AWVALID(axim_awvalid[CRSBAR_M_PORT_NUM_UDLIP3*1 +: 1]),
  .S_AXI_AWREADY(axim_awready[CRSBAR_M_PORT_NUM_UDLIP3*1 +: 1]),
  .S_AXI_WDATA(axim_wdata[CRSBAR_M_PORT_NUM_UDLIP3*32 +: 32]),
  .S_AXI_WSTRB(axim_wstrb[CRSBAR_M_PORT_NUM_UDLIP3*4 +: 4]),
  .S_AXI_WLAST(axim_wlast[CRSBAR_M_PORT_NUM_UDLIP3*1 +: 1]),
  .S_AXI_WVALID(axim_wvalid[CRSBAR_M_PORT_NUM_UDLIP3*1 +: 1]),
  .S_AXI_WREADY(axim_wready[CRSBAR_M_PORT_NUM_UDLIP3*1 +: 1]),
  .S_AXI_BID(axim_bid[CRSBAR_M_PORT_NUM_UDLIP3*MAINAXI_S_AXI_ID_WIDTH +: MAINAXI_S_AXI_ID_WIDTH]),
  .S_AXI_BRESP(axim_bresp[CRSBAR_M_PORT_NUM_UDLIP3*2 +: 2]),
  .S_AXI_BVALID(axim_bvalid[CRSBAR_M_PORT_NUM_UDLIP3*1 +: 1]),
  .S_AXI_BREADY(axim_bready[CRSBAR_M_PORT_NUM_UDLIP3*1 +: 1]),
  .S_AXI_ARID(axim_arid[CRSBAR_M_PORT_NUM_UDLIP3*MAINAXI_S_AXI_ID_WIDTH +: MAINAXI_S_AXI_ID_WIDTH]),
  .S_AXI_ARADDR(axim_araddr[CRSBAR_M_PORT_NUM_UDLIP3*32 +: 32]),
  .S_AXI_ARLEN(axim_arlen[CRSBAR_M_PORT_NUM_UDLIP3*8 +: 8]),
  .S_AXI_ARSIZE(axim_arsize[CRSBAR_M_PORT_NUM_UDLIP3*3 +: 3]),
  .S_AXI_ARBURST(axim_arburst[CRSBAR_M_PORT_NUM_UDLIP3*2 +: 2]),
  .S_AXI_ARLOCK(axim_arlock[CRSBAR_M_PORT_NUM_UDLIP3*1 +: 1]),
  .S_AXI_ARCACHE(axim_arcache[CRSBAR_M_PORT_NUM_UDLIP3*4 +: 4]),
  .S_AXI_ARPROT(axim_arprot[CRSBAR_M_PORT_NUM_UDLIP3*3 +: 3]),
  .S_AXI_ARVALID(axim_arvalid[CRSBAR_M_PORT_NUM_UDLIP3*1 +: 1]),
  .S_AXI_ARREADY(axim_arready[CRSBAR_M_PORT_NUM_UDLIP3*1 +: 1]),
  .S_AXI_RID(axim_rid[CRSBAR_M_PORT_NUM_UDLIP3*MAINAXI_S_AXI_ID_WIDTH +: MAINAXI_S_AXI_ID_WIDTH]),
  .S_AXI_RDATA(axim_rdata[CRSBAR_M_PORT_NUM_UDLIP3*32 +: 32]),
  .S_AXI_RRESP(axim_rresp[CRSBAR_M_PORT_NUM_UDLIP3*2 +: 2]),
  .S_AXI_RLAST(axim_rlast[CRSBAR_M_PORT_NUM_UDLIP3*1 +: 1]),
  .S_AXI_RVALID(axim_rvalid[CRSBAR_M_PORT_NUM_UDLIP3*1 +: 1]),
  .S_AXI_RREADY(axim_rready[CRSBAR_M_PORT_NUM_UDLIP3*1 +: 1]),
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

// UDL IP AXI Bus-4 (Dummy)
sc_axi_slave # (
  .P_AD_W(32),
  .P_DT_W(32),
  .P_ID_W(MAINAXI_S_AXI_ID_WIDTH)
) axi_slave_udlip4_dummy (
  // AXI Interface
  .S_AXI_ACLK(MAXI_CLK),
  .S_AXI_ARESETN(SYS_RSTB),
  .S_AXI_AWID(axim_awid[CRSBAR_M_PORT_NUM_UDLIP4*MAINAXI_S_AXI_ID_WIDTH +: MAINAXI_S_AXI_ID_WIDTH]),
  .S_AXI_AWADDR(axim_awaddr[CRSBAR_M_PORT_NUM_UDLIP4*32 +: 32]),
  .S_AXI_AWLEN(axim_awlen[CRSBAR_M_PORT_NUM_UDLIP4*8 +: 8]),
  .S_AXI_AWSIZE(axim_awsize[CRSBAR_M_PORT_NUM_UDLIP4*3 +: 3]),
  .S_AXI_AWBURST(axim_awburst[CRSBAR_M_PORT_NUM_UDLIP4*2 +: 2]),
  .S_AXI_AWLOCK(axim_awlock[CRSBAR_M_PORT_NUM_UDLIP4*1 +: 1]),
  .S_AXI_AWCACHE(axim_awcache[CRSBAR_M_PORT_NUM_UDLIP4*4 +: 4]),
  .S_AXI_AWPROT(axim_awprot[CRSBAR_M_PORT_NUM_UDLIP4*3 +: 3]),
  .S_AXI_AWVALID(axim_awvalid[CRSBAR_M_PORT_NUM_UDLIP4*1 +: 1]),
  .S_AXI_AWREADY(axim_awready[CRSBAR_M_PORT_NUM_UDLIP4*1 +: 1]),
  .S_AXI_WDATA(axim_wdata[CRSBAR_M_PORT_NUM_UDLIP4*32 +: 32]),
  .S_AXI_WSTRB(axim_wstrb[CRSBAR_M_PORT_NUM_UDLIP4*4 +: 4]),
  .S_AXI_WLAST(axim_wlast[CRSBAR_M_PORT_NUM_UDLIP4*1 +: 1]),
  .S_AXI_WVALID(axim_wvalid[CRSBAR_M_PORT_NUM_UDLIP4*1 +: 1]),
  .S_AXI_WREADY(axim_wready[CRSBAR_M_PORT_NUM_UDLIP4*1 +: 1]),
  .S_AXI_BID(axim_bid[CRSBAR_M_PORT_NUM_UDLIP4*MAINAXI_S_AXI_ID_WIDTH +: MAINAXI_S_AXI_ID_WIDTH]),
  .S_AXI_BRESP(axim_bresp[CRSBAR_M_PORT_NUM_UDLIP4*2 +: 2]),
  .S_AXI_BVALID(axim_bvalid[CRSBAR_M_PORT_NUM_UDLIP4*1 +: 1]),
  .S_AXI_BREADY(axim_bready[CRSBAR_M_PORT_NUM_UDLIP4*1 +: 1]),
  .S_AXI_ARID(axim_arid[CRSBAR_M_PORT_NUM_UDLIP4*MAINAXI_S_AXI_ID_WIDTH +: MAINAXI_S_AXI_ID_WIDTH]),
  .S_AXI_ARADDR(axim_araddr[CRSBAR_M_PORT_NUM_UDLIP4*32 +: 32]),
  .S_AXI_ARLEN(axim_arlen[CRSBAR_M_PORT_NUM_UDLIP4*8 +: 8]),
  .S_AXI_ARSIZE(axim_arsize[CRSBAR_M_PORT_NUM_UDLIP4*3 +: 3]),
  .S_AXI_ARBURST(axim_arburst[CRSBAR_M_PORT_NUM_UDLIP4*2 +: 2]),
  .S_AXI_ARLOCK(axim_arlock[CRSBAR_M_PORT_NUM_UDLIP4*1 +: 1]),
  .S_AXI_ARCACHE(axim_arcache[CRSBAR_M_PORT_NUM_UDLIP4*4 +: 4]),
  .S_AXI_ARPROT(axim_arprot[CRSBAR_M_PORT_NUM_UDLIP4*3 +: 3]),
  .S_AXI_ARVALID(axim_arvalid[CRSBAR_M_PORT_NUM_UDLIP4*1 +: 1]),
  .S_AXI_ARREADY(axim_arready[CRSBAR_M_PORT_NUM_UDLIP4*1 +: 1]),
  .S_AXI_RID(axim_rid[CRSBAR_M_PORT_NUM_UDLIP4*MAINAXI_S_AXI_ID_WIDTH +: MAINAXI_S_AXI_ID_WIDTH]),
  .S_AXI_RDATA(axim_rdata[CRSBAR_M_PORT_NUM_UDLIP4*32 +: 32]),
  .S_AXI_RRESP(axim_rresp[CRSBAR_M_PORT_NUM_UDLIP4*2 +: 2]),
  .S_AXI_RLAST(axim_rlast[CRSBAR_M_PORT_NUM_UDLIP4*1 +: 1]),
  .S_AXI_RVALID(axim_rvalid[CRSBAR_M_PORT_NUM_UDLIP4*1 +: 1]),
  .S_AXI_RREADY(axim_rready[CRSBAR_M_PORT_NUM_UDLIP4*1 +: 1]),
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

endmodule
