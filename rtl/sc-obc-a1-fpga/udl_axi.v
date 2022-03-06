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
  output [MAINAXI_UDL_M_AXI_ID_WIDTH-1:0] UDL_M_AXI_AWID,
  output [31:0] UDL_M_AXI_AWADDR,
  output [7:0] UDL_M_AXI_AWLEN,
  output [2:0] UDL_M_AXI_AWSIZE,
  output [1:0] UDL_M_AXI_AWBURST,
  output UDL_M_AXI_AWLOCK,
  output [3:0] UDL_M_AXI_AWCACHE,
  output [2:0] UDL_M_AXI_AWPROT,
  output [3:0] UDL_M_AXI_AWQOS,
  output UDL_M_AXI_AWVALID,
  input  UDL_M_AXI_AWREADY,
  output [31:0] UDL_M_AXI_WDATA,
  output [3:0] UDL_M_AXI_WSTRB,
  output UDL_M_AXI_WLAST,
  output UDL_M_AXI_WVALID,
  input  UDL_M_AXI_WREADY,
  input  [MAINAXI_UDL_M_AXI_ID_WIDTH-1:0] UDL_M_AXI_BID,
  input  [1:0] UDL_M_AXI_BRESP,
  input  UDL_M_AXI_BVALID,
  output UDL_M_AXI_BREADY,
  output [MAINAXI_UDL_M_AXI_ID_WIDTH-1:0] UDL_M_AXI_ARID,
  output [31:0] UDL_M_AXI_ARADDR,
  output [7:0] UDL_M_AXI_ARLEN,
  output [2:0] UDL_M_AXI_ARSIZE,
  output [1:0] UDL_M_AXI_ARBURST,
  output UDL_M_AXI_ARLOCK,
  output [3:0] UDL_M_AXI_ARCACHE,
  output [2:0] UDL_M_AXI_ARPROT,
  output [3:0] UDL_M_AXI_ARQOS,
  output UDL_M_AXI_ARVALID,
  input  UDL_M_AXI_ARREADY,
  input  [MAINAXI_UDL_M_AXI_ID_WIDTH-1:0] UDL_M_AXI_RID,
  input  [31:0] UDL_M_AXI_RDATA,
  input  [1:0] UDL_M_AXI_RRESP,
  input  UDL_M_AXI_RLAST,
  input  UDL_M_AXI_RVALID,
  output UDL_M_AXI_RREADY,

  // UDL AXI4 Slave Interface
  input  [MAINAXI_S_AXI_ID_WIDTH-1:0] UDL_S_AXI_AWID,
  input  [31:0] UDL_S_AXI_AWADDR,
  input  [7:0] UDL_S_AXI_AWLEN,
  input  [2:0] UDL_S_AXI_AWSIZE,
  input  [1:0] UDL_S_AXI_AWBURST,
  input  UDL_S_AXI_AWLOCK,
  input  [3:0] UDL_S_AXI_AWCACHE,
  input  [2:0] UDL_S_AXI_AWPROT,
  input  [3:0] UDL_S_AXI_AWREGION,
  input  [3:0] UDL_S_AXI_AWQOS,
  input  UDL_S_AXI_AWVALID,
  output UDL_S_AXI_AWREADY,
  input  [31:0] UDL_S_AXI_WDATA,
  input  [3:0] UDL_S_AXI_WSTRB,
  input  UDL_S_AXI_WLAST,
  input  UDL_S_AXI_WVALID,
  output UDL_S_AXI_WREADY,
  output [MAINAXI_S_AXI_ID_WIDTH-1:0] UDL_S_AXI_BID,
  output [1:0] UDL_S_AXI_BRESP,
  output UDL_S_AXI_BVALID,
  input  UDL_S_AXI_BREADY,
  input  [MAINAXI_S_AXI_ID_WIDTH-1:0] UDL_S_AXI_ARID,
  input  [31:0] UDL_S_AXI_ARADDR,
  input  [7:0] UDL_S_AXI_ARLEN,
  input  [2:0] UDL_S_AXI_ARSIZE,
  input  [1:0] UDL_S_AXI_ARBURST,
  input  UDL_S_AXI_ARLOCK,
  input  [3:0] UDL_S_AXI_ARCACHE,
  input  [2:0] UDL_S_AXI_ARPROT,
  input  [3:0] UDL_S_AXI_ARREGION,
  input  [3:0] UDL_S_AXI_ARQOS,
  input  UDL_S_AXI_ARVALID,
  output UDL_S_AXI_ARREADY,
  output [MAINAXI_S_AXI_ID_WIDTH-1:0] UDL_S_AXI_RID,
  output [31:0] UDL_S_AXI_RDATA,
  output [1:0] UDL_S_AXI_RRESP,
  output UDL_S_AXI_RLAST,
  output UDL_S_AXI_RVALID,
  input  UDL_S_AXI_RREADY

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

wire [MAINAXI_S_AXI_ID_WIDTH*CRSBAR_S_PORTS-1:0] s_axi_awid;
wire [32*CRSBAR_S_PORTS-1:0] s_axi_awaddr;
wire [8*CRSBAR_S_PORTS-1:0] s_axi_awlen;
wire [3*CRSBAR_S_PORTS-1:0] s_axi_awsize;
wire [2*CRSBAR_S_PORTS-1:0] s_axi_awburst;
wire [1*CRSBAR_S_PORTS-1:0] s_axi_awlock;
wire [4*CRSBAR_S_PORTS-1:0] s_axi_awcache;
wire [3*CRSBAR_S_PORTS-1:0] s_axi_awprot;
wire [4*CRSBAR_S_PORTS-1:0] s_axi_awqos;
wire [1*CRSBAR_S_PORTS-1:0] s_axi_awvalid;
wire [1*CRSBAR_S_PORTS-1:0] s_axi_awready;
wire [32*CRSBAR_S_PORTS-1:0] s_axi_wdata;
wire [4*CRSBAR_S_PORTS-1:0] s_axi_wstrb;
wire [1*CRSBAR_S_PORTS-1:0] s_axi_wlast;
wire [1*CRSBAR_S_PORTS-1:0] s_axi_wvalid;
wire [1*CRSBAR_S_PORTS-1:0] s_axi_wready;
wire [MAINAXI_S_AXI_ID_WIDTH*CRSBAR_S_PORTS-1:0] s_axi_bid;
wire [2*CRSBAR_S_PORTS-1:0] s_axi_bresp;
wire [1*CRSBAR_S_PORTS-1:0] s_axi_bvalid;
wire [1*CRSBAR_S_PORTS-1:0] s_axi_bready;
wire [MAINAXI_S_AXI_ID_WIDTH*CRSBAR_S_PORTS-1:0] s_axi_arid;
wire [32*CRSBAR_S_PORTS-1:0] s_axi_araddr;
wire [8*CRSBAR_S_PORTS-1:0] s_axi_arlen;
wire [3*CRSBAR_S_PORTS-1:0] s_axi_arsize;
wire [2*CRSBAR_S_PORTS-1:0] s_axi_arburst;
wire [1*CRSBAR_S_PORTS-1:0] s_axi_arlock;
wire [4*CRSBAR_S_PORTS-1:0] s_axi_arcache;
wire [3*CRSBAR_S_PORTS-1:0] s_axi_arprot;
wire [4*CRSBAR_S_PORTS-1:0] s_axi_arqos;
wire [1*CRSBAR_S_PORTS-1:0] s_axi_arvalid;
wire [1*CRSBAR_S_PORTS-1:0] s_axi_arready;
wire [MAINAXI_S_AXI_ID_WIDTH*CRSBAR_S_PORTS-1:0] s_axi_rid;
wire [32*CRSBAR_S_PORTS-1:0] s_axi_rdata;
wire [2*CRSBAR_S_PORTS-1:0] s_axi_rresp;
wire [1*CRSBAR_S_PORTS-1:0] s_axi_rlast;
wire [1*CRSBAR_S_PORTS-1:0] s_axi_rvalid;
wire [1*CRSBAR_S_PORTS-1:0] s_axi_rready;

wire [MAINAXI_S_AXI_ID_WIDTH*CRSBAR_M_PORTS-1:0] m_axi_awid;
wire [32*CRSBAR_M_PORTS-1:0] m_axi_awaddr;
wire [8*CRSBAR_M_PORTS-1:0] m_axi_awlen;
wire [3*CRSBAR_M_PORTS-1:0] m_axi_awsize;
wire [2*CRSBAR_M_PORTS-1:0] m_axi_awburst;
wire [1*CRSBAR_M_PORTS-1:0] m_axi_awlock;
wire [4*CRSBAR_M_PORTS-1:0] m_axi_awcache;
wire [3*CRSBAR_M_PORTS-1:0] m_axi_awprot;
wire [4*CRSBAR_M_PORTS-1:0] m_axi_awregion;
wire [4*CRSBAR_M_PORTS-1:0] m_axi_awqos;
wire [1*CRSBAR_M_PORTS-1:0] m_axi_awvalid;
wire [1*CRSBAR_M_PORTS-1:0] m_axi_awready;
wire [32*CRSBAR_M_PORTS-1:0] m_axi_wdata;
wire [4*CRSBAR_M_PORTS-1:0] m_axi_wstrb;
wire [1*CRSBAR_M_PORTS-1:0] m_axi_wlast;
wire [1*CRSBAR_M_PORTS-1:0] m_axi_wvalid;
wire [1*CRSBAR_M_PORTS-1:0] m_axi_wready;
wire [MAINAXI_S_AXI_ID_WIDTH*CRSBAR_M_PORTS-1:0] m_axi_bid;
wire [2*CRSBAR_M_PORTS-1:0] m_axi_bresp;
wire [1*CRSBAR_M_PORTS-1:0] m_axi_bvalid;
wire [1*CRSBAR_M_PORTS-1:0] m_axi_bready;
wire [MAINAXI_S_AXI_ID_WIDTH*CRSBAR_M_PORTS-1:0] m_axi_arid;
wire [32*CRSBAR_M_PORTS-1:0] m_axi_araddr;
wire [8*CRSBAR_M_PORTS-1:0] m_axi_arlen;
wire [3*CRSBAR_M_PORTS-1:0] m_axi_arsize;
wire [2*CRSBAR_M_PORTS-1:0] m_axi_arburst;
wire [1*CRSBAR_M_PORTS-1:0] m_axi_arlock;
wire [4*CRSBAR_M_PORTS-1:0] m_axi_arcache;
wire [3*CRSBAR_M_PORTS-1:0] m_axi_arprot;
wire [4*CRSBAR_M_PORTS-1:0] m_axi_arregion;
wire [4*CRSBAR_M_PORTS-1:0] m_axi_arqos;
wire [1*CRSBAR_M_PORTS-1:0] m_axi_arvalid;
wire [1*CRSBAR_M_PORTS-1:0] m_axi_arready;
wire [MAINAXI_S_AXI_ID_WIDTH*CRSBAR_M_PORTS-1:0] m_axi_rid;
wire [32*CRSBAR_M_PORTS-1:0] m_axi_rdata;
wire [2*CRSBAR_M_PORTS-1:0] m_axi_rresp;
wire [1*CRSBAR_M_PORTS-1:0] m_axi_rlast;
wire [1*CRSBAR_M_PORTS-1:0] m_axi_rvalid;
wire [1*CRSBAR_M_PORTS-1:0] m_axi_rready;

// Interrupt to CPU
assign UDL_INTISR = {CM3SS_UDL_ISR_NUM{1'b0}};

// UDL AXI4 Master Interface (Dummy Clamp)
assign UDL_M_AXI_AWID = {MAINAXI_UDL_M_AXI_ID_WIDTH{1'b0}};
assign UDL_M_AXI_AWADDR = 32'h0;
assign UDL_M_AXI_AWLEN = 8'h0;
assign UDL_M_AXI_AWSIZE = 3'h0;
assign UDL_M_AXI_AWBURST = 2'h0;
assign UDL_M_AXI_AWLOCK = 1'b0;
assign UDL_M_AXI_AWCACHE = 4'h0;
assign UDL_M_AXI_AWPROT = 3'h0;
assign UDL_M_AXI_AWQOS = 4'h0;
assign UDL_M_AXI_AWVALID = 1'b0;
assign UDL_M_AXI_WDATA = 32'h0;
assign UDL_M_AXI_WSTRB = 4'h0;
assign UDL_M_AXI_WLAST = 1'b0;
assign UDL_M_AXI_WVALID = 1'b0;
assign UDL_M_AXI_BREADY = 1'b1;
assign UDL_M_AXI_ARID = {MAINAXI_UDL_M_AXI_ID_WIDTH{1'b0}};
assign UDL_M_AXI_ARADDR = 32'h0;
assign UDL_M_AXI_ARLEN = 8'h0;
assign UDL_M_AXI_ARSIZE = 3'h0;
assign UDL_M_AXI_ARBURST = 2'h0;
assign UDL_M_AXI_ARLOCK = 1'b0;
assign UDL_M_AXI_ARCACHE = 4'h0;
assign UDL_M_AXI_ARPROT = 3'h0;
assign UDL_M_AXI_ARQOS = 4'h0;
assign UDL_M_AXI_ARVALID = 1'b0;
assign UDL_M_AXI_RREADY = 1'b1;

// MAINAXI AXI4 Slave Interface to main_axi_crossbar
assign s_axi_awid[CRSBAR_S_PORT_NUM_MAINAXI*MAINAXI_S_AXI_ID_WIDTH +: MAINAXI_S_AXI_ID_WIDTH] = UDL_S_AXI_AWID;
assign s_axi_awaddr[CRSBAR_S_PORT_NUM_MAINAXI*32 +: 32] = UDL_S_AXI_AWADDR;
assign s_axi_awlen[CRSBAR_S_PORT_NUM_MAINAXI*8 +: 8] = UDL_S_AXI_AWLEN;
assign s_axi_awsize[CRSBAR_S_PORT_NUM_MAINAXI*3 +: 3] = UDL_S_AXI_AWSIZE;
assign s_axi_awburst[CRSBAR_S_PORT_NUM_MAINAXI*2 +: 2] = UDL_S_AXI_AWBURST;
assign s_axi_awlock[CRSBAR_S_PORT_NUM_MAINAXI*1 +: 1] = UDL_S_AXI_AWLOCK;
assign s_axi_awcache[CRSBAR_S_PORT_NUM_MAINAXI*4 +: 4] = UDL_S_AXI_AWCACHE;
assign s_axi_awprot[CRSBAR_S_PORT_NUM_MAINAXI*3 +: 3] = UDL_S_AXI_AWPROT;
assign s_axi_awqos[CRSBAR_S_PORT_NUM_MAINAXI*4 +: 4] = UDL_S_AXI_AWQOS;
assign s_axi_awvalid[CRSBAR_S_PORT_NUM_MAINAXI*1 +: 1] = UDL_S_AXI_AWVALID;
assign s_axi_wdata[CRSBAR_S_PORT_NUM_MAINAXI*32 +:32] = UDL_S_AXI_WDATA;
assign s_axi_wstrb[CRSBAR_S_PORT_NUM_MAINAXI*4 +: 4] = UDL_S_AXI_WSTRB;
assign s_axi_wlast[CRSBAR_S_PORT_NUM_MAINAXI*1 +: 1] = UDL_S_AXI_WLAST;
assign s_axi_wvalid[CRSBAR_S_PORT_NUM_MAINAXI*1 +: 1] = UDL_S_AXI_WVALID;
assign s_axi_bready[CRSBAR_S_PORT_NUM_MAINAXI*1 +: 1] = UDL_S_AXI_BREADY;
assign s_axi_arid[CRSBAR_S_PORT_NUM_MAINAXI*MAINAXI_S_AXI_ID_WIDTH +: MAINAXI_S_AXI_ID_WIDTH] = UDL_S_AXI_ARID;
assign s_axi_araddr[CRSBAR_S_PORT_NUM_MAINAXI*32 +:32] = UDL_S_AXI_ARADDR;
assign s_axi_arlen[CRSBAR_S_PORT_NUM_MAINAXI*8 +: 8] = UDL_S_AXI_ARLEN;
assign s_axi_arsize[CRSBAR_S_PORT_NUM_MAINAXI*3 +: 3] = UDL_S_AXI_ARSIZE;
assign s_axi_arburst[CRSBAR_S_PORT_NUM_MAINAXI*2 +: 2] = UDL_S_AXI_ARBURST;
assign s_axi_arlock[CRSBAR_S_PORT_NUM_MAINAXI*1 +: 1] = UDL_S_AXI_ARLOCK;
assign s_axi_arcache[CRSBAR_S_PORT_NUM_MAINAXI*4 +: 4] = UDL_S_AXI_ARCACHE;
assign s_axi_arprot[CRSBAR_S_PORT_NUM_MAINAXI*3 +: 3] = UDL_S_AXI_ARPROT;
assign s_axi_arqos[CRSBAR_S_PORT_NUM_MAINAXI*4 +: 4] = UDL_S_AXI_ARQOS;
assign s_axi_arvalid[CRSBAR_S_PORT_NUM_MAINAXI*1 +: 1] = UDL_S_AXI_ARVALID;
assign s_axi_rready[CRSBAR_S_PORT_NUM_MAINAXI*1 +: 1] = UDL_S_AXI_RREADY;
assign UDL_S_AXI_AWREADY = s_axi_awready[CRSBAR_S_PORT_NUM_MAINAXI*1 +: 1];
assign UDL_S_AXI_WREADY = s_axi_wready[CRSBAR_S_PORT_NUM_MAINAXI*1 +: 1];
assign UDL_S_AXI_BID = s_axi_bid[CRSBAR_S_PORT_NUM_MAINAXI*MAINAXI_S_AXI_ID_WIDTH +: MAINAXI_S_AXI_ID_WIDTH];
assign UDL_S_AXI_BRESP = s_axi_bresp[CRSBAR_S_PORT_NUM_MAINAXI*2 +: 2];
assign UDL_S_AXI_BVALID = s_axi_bvalid[CRSBAR_S_PORT_NUM_MAINAXI*1 +: 1];
assign UDL_S_AXI_ARREADY = s_axi_arready[CRSBAR_S_PORT_NUM_MAINAXI*1 +: 1];
assign UDL_S_AXI_RID = s_axi_rid[CRSBAR_S_PORT_NUM_MAINAXI*MAINAXI_S_AXI_ID_WIDTH +: MAINAXI_S_AXI_ID_WIDTH];
assign UDL_S_AXI_RDATA = s_axi_rdata[CRSBAR_S_PORT_NUM_MAINAXI*32 +: 32];
assign UDL_S_AXI_RRESP = s_axi_rresp[CRSBAR_S_PORT_NUM_MAINAXI*2 +: 2];
assign UDL_S_AXI_RLAST = s_axi_rlast[CRSBAR_S_PORT_NUM_MAINAXI*1 +: 1];
assign UDL_S_AXI_RVALID = s_axi_rvalid[CRSBAR_S_PORT_NUM_MAINAXI*1 +: 1];

// UDL AXI Bus Crossvar
udl_axi_crossbar udl_axi_crossbar (
  .aclk(MAXI_CLK),
  .aresetn(BUS_RSTB),
  .s_axi_awid(s_axi_awid),
  .s_axi_awaddr(s_axi_awaddr),
  .s_axi_awlen(s_axi_awlen),
  .s_axi_awsize(s_axi_awsize),
  .s_axi_awburst(s_axi_awburst),
  .s_axi_awlock(s_axi_awlock),
  .s_axi_awcache(s_axi_awcache),
  .s_axi_awprot(s_axi_awprot),
  .s_axi_awqos(s_axi_awqos),
  .s_axi_awvalid(s_axi_awvalid),
  .s_axi_awready(s_axi_awready),
  .s_axi_wdata(s_axi_wdata),
  .s_axi_wstrb(s_axi_wstrb),
  .s_axi_wlast(s_axi_wlast),
  .s_axi_wvalid(s_axi_wvalid),
  .s_axi_wready(s_axi_wready),
  .s_axi_bid(s_axi_bid),
  .s_axi_bresp(s_axi_bresp),
  .s_axi_bvalid(s_axi_bvalid),
  .s_axi_bready(s_axi_bready),
  .s_axi_arid(s_axi_arid),
  .s_axi_araddr(s_axi_araddr),
  .s_axi_arlen(s_axi_arlen),
  .s_axi_arsize(s_axi_arsize),
  .s_axi_arburst(s_axi_arburst),
  .s_axi_arlock(s_axi_arlock),
  .s_axi_arcache(s_axi_arcache),
  .s_axi_arprot(s_axi_arprot),
  .s_axi_arqos(s_axi_arqos),
  .s_axi_arvalid(s_axi_arvalid),
  .s_axi_arready(s_axi_arready),
  .s_axi_rid(s_axi_rid),
  .s_axi_rdata(s_axi_rdata),
  .s_axi_rresp(s_axi_rresp),
  .s_axi_rlast(s_axi_rlast),
  .s_axi_rvalid(s_axi_rvalid),
  .s_axi_rready(s_axi_rready),
  .m_axi_awid(m_axi_awid),
  .m_axi_awaddr(m_axi_awaddr),
  .m_axi_awlen(m_axi_awlen),
  .m_axi_awsize(m_axi_awsize),
  .m_axi_awburst(m_axi_awburst),
  .m_axi_awlock(m_axi_awlock),
  .m_axi_awcache(m_axi_awcache),
  .m_axi_awprot(m_axi_awprot),
  .m_axi_awregion(m_axi_awregion),
  .m_axi_awqos(m_axi_awqos),
  .m_axi_awvalid(m_axi_awvalid),
  .m_axi_awready(m_axi_awready),
  .m_axi_wdata(m_axi_wdata),
  .m_axi_wstrb(m_axi_wstrb),
  .m_axi_wlast(m_axi_wlast),
  .m_axi_wvalid(m_axi_wvalid),
  .m_axi_wready(m_axi_wready),
  .m_axi_bid(m_axi_bid),
  .m_axi_bresp(m_axi_bresp),
  .m_axi_bvalid(m_axi_bvalid),
  .m_axi_bready(m_axi_bready),
  .m_axi_arid(m_axi_arid),
  .m_axi_araddr(m_axi_araddr),
  .m_axi_arlen(m_axi_arlen),
  .m_axi_arsize(m_axi_arsize),
  .m_axi_arburst(m_axi_arburst),
  .m_axi_arlock(m_axi_arlock),
  .m_axi_arcache(m_axi_arcache),
  .m_axi_arprot(m_axi_arprot),
  .m_axi_arregion(m_axi_arregion),
  .m_axi_arqos(m_axi_arqos),
  .m_axi_arvalid(m_axi_arvalid),
  .m_axi_arready(m_axi_arready),
  .m_axi_rid(m_axi_rid),
  .m_axi_rdata(m_axi_rdata),
  .m_axi_rresp(m_axi_rresp),
  .m_axi_rlast(m_axi_rlast),
  .m_axi_rvalid(m_axi_rvalid),
  .m_axi_rready(m_axi_rready)
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
  .S_AXI_AWID(m_axi_awid[CRSBAR_M_PORT_NUM_UDLIP1*MAINAXI_S_AXI_ID_WIDTH +: MAINAXI_S_AXI_ID_WIDTH]),
  .S_AXI_AWADDR(m_axi_awaddr[CRSBAR_M_PORT_NUM_UDLIP1*32 +: 32]),
  .S_AXI_AWLEN(m_axi_awlen[CRSBAR_M_PORT_NUM_UDLIP1*8 +: 8]),
  .S_AXI_AWSIZE(m_axi_awsize[CRSBAR_M_PORT_NUM_UDLIP1*3 +: 3]),
  .S_AXI_AWBURST(m_axi_awburst[CRSBAR_M_PORT_NUM_UDLIP1*2 +: 2]),
  .S_AXI_AWLOCK(m_axi_awlock[CRSBAR_M_PORT_NUM_UDLIP1*1 +: 1]),
  .S_AXI_AWCACHE(m_axi_awcache[CRSBAR_M_PORT_NUM_UDLIP1*4 +: 4]),
  .S_AXI_AWPROT(m_axi_awprot[CRSBAR_M_PORT_NUM_UDLIP1*3 +: 3]),
  .S_AXI_AWVALID(m_axi_awvalid[CRSBAR_M_PORT_NUM_UDLIP1*1 +: 1]),
  .S_AXI_AWREADY(m_axi_awready[CRSBAR_M_PORT_NUM_UDLIP1*1 +: 1]),
  .S_AXI_WDATA(m_axi_wdata[CRSBAR_M_PORT_NUM_UDLIP1*32 +: 32]),
  .S_AXI_WSTRB(m_axi_wstrb[CRSBAR_M_PORT_NUM_UDLIP1*4 +: 4]),
  .S_AXI_WLAST(m_axi_wlast[CRSBAR_M_PORT_NUM_UDLIP1*1 +: 1]),
  .S_AXI_WVALID(m_axi_wvalid[CRSBAR_M_PORT_NUM_UDLIP1*1 +: 1]),
  .S_AXI_WREADY(m_axi_wready[CRSBAR_M_PORT_NUM_UDLIP1*1 +: 1]),
  .S_AXI_BID(m_axi_bid[CRSBAR_M_PORT_NUM_UDLIP1*MAINAXI_S_AXI_ID_WIDTH +: MAINAXI_S_AXI_ID_WIDTH]),
  .S_AXI_BRESP(m_axi_bresp[CRSBAR_M_PORT_NUM_UDLIP1*2 +: 2]),
  .S_AXI_BVALID(m_axi_bvalid[CRSBAR_M_PORT_NUM_UDLIP1*1 +: 1]),
  .S_AXI_BREADY(m_axi_bready[CRSBAR_M_PORT_NUM_UDLIP1*1 +: 1]),
  .S_AXI_ARID(m_axi_arid[CRSBAR_M_PORT_NUM_UDLIP1*MAINAXI_S_AXI_ID_WIDTH +: MAINAXI_S_AXI_ID_WIDTH]),
  .S_AXI_ARADDR(m_axi_araddr[CRSBAR_M_PORT_NUM_UDLIP1*32 +: 32]),
  .S_AXI_ARLEN(m_axi_arlen[CRSBAR_M_PORT_NUM_UDLIP1*8 +: 8]),
  .S_AXI_ARSIZE(m_axi_arsize[CRSBAR_M_PORT_NUM_UDLIP1*3 +: 3]),
  .S_AXI_ARBURST(m_axi_arburst[CRSBAR_M_PORT_NUM_UDLIP1*2 +: 2]),
  .S_AXI_ARLOCK(m_axi_arlock[CRSBAR_M_PORT_NUM_UDLIP1*1 +: 1]),
  .S_AXI_ARCACHE(m_axi_arcache[CRSBAR_M_PORT_NUM_UDLIP1*4 +: 4]),
  .S_AXI_ARPROT(m_axi_arprot[CRSBAR_M_PORT_NUM_UDLIP1*3 +: 3]),
  .S_AXI_ARVALID(m_axi_arvalid[CRSBAR_M_PORT_NUM_UDLIP1*1 +: 1]),
  .S_AXI_ARREADY(m_axi_arready[CRSBAR_M_PORT_NUM_UDLIP1*1 +: 1]),
  .S_AXI_RID(m_axi_rid[CRSBAR_M_PORT_NUM_UDLIP1*MAINAXI_S_AXI_ID_WIDTH +: MAINAXI_S_AXI_ID_WIDTH]),
  .S_AXI_RDATA(m_axi_rdata[CRSBAR_M_PORT_NUM_UDLIP1*32 +: 32]),
  .S_AXI_RRESP(m_axi_rresp[CRSBAR_M_PORT_NUM_UDLIP1*2 +: 2]),
  .S_AXI_RLAST(m_axi_rlast[CRSBAR_M_PORT_NUM_UDLIP1*1 +: 1]),
  .S_AXI_RVALID(m_axi_rvalid[CRSBAR_M_PORT_NUM_UDLIP1*1 +: 1]),
  .S_AXI_RREADY(m_axi_rready[CRSBAR_M_PORT_NUM_UDLIP1*1 +: 1]),
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
  .S_AXI_AWID(m_axi_awid[CRSBAR_M_PORT_NUM_UDLIP2*MAINAXI_S_AXI_ID_WIDTH +: MAINAXI_S_AXI_ID_WIDTH]),
  .S_AXI_AWADDR(m_axi_awaddr[CRSBAR_M_PORT_NUM_UDLIP2*32 +: 32]),
  .S_AXI_AWLEN(m_axi_awlen[CRSBAR_M_PORT_NUM_UDLIP2*8 +: 8]),
  .S_AXI_AWSIZE(m_axi_awsize[CRSBAR_M_PORT_NUM_UDLIP2*3 +: 3]),
  .S_AXI_AWBURST(m_axi_awburst[CRSBAR_M_PORT_NUM_UDLIP2*2 +: 2]),
  .S_AXI_AWLOCK(m_axi_awlock[CRSBAR_M_PORT_NUM_UDLIP2*1 +: 1]),
  .S_AXI_AWCACHE(m_axi_awcache[CRSBAR_M_PORT_NUM_UDLIP2*4 +: 4]),
  .S_AXI_AWPROT(m_axi_awprot[CRSBAR_M_PORT_NUM_UDLIP2*3 +: 3]),
  .S_AXI_AWVALID(m_axi_awvalid[CRSBAR_M_PORT_NUM_UDLIP2*1 +: 1]),
  .S_AXI_AWREADY(m_axi_awready[CRSBAR_M_PORT_NUM_UDLIP2*1 +: 1]),
  .S_AXI_WDATA(m_axi_wdata[CRSBAR_M_PORT_NUM_UDLIP2*32 +: 32]),
  .S_AXI_WSTRB(m_axi_wstrb[CRSBAR_M_PORT_NUM_UDLIP2*4 +: 4]),
  .S_AXI_WLAST(m_axi_wlast[CRSBAR_M_PORT_NUM_UDLIP2*1 +: 1]),
  .S_AXI_WVALID(m_axi_wvalid[CRSBAR_M_PORT_NUM_UDLIP2*1 +: 1]),
  .S_AXI_WREADY(m_axi_wready[CRSBAR_M_PORT_NUM_UDLIP2*1 +: 1]),
  .S_AXI_BID(m_axi_bid[CRSBAR_M_PORT_NUM_UDLIP2*MAINAXI_S_AXI_ID_WIDTH +: MAINAXI_S_AXI_ID_WIDTH]),
  .S_AXI_BRESP(m_axi_bresp[CRSBAR_M_PORT_NUM_UDLIP2*2 +: 2]),
  .S_AXI_BVALID(m_axi_bvalid[CRSBAR_M_PORT_NUM_UDLIP2*1 +: 1]),
  .S_AXI_BREADY(m_axi_bready[CRSBAR_M_PORT_NUM_UDLIP2*1 +: 1]),
  .S_AXI_ARID(m_axi_arid[CRSBAR_M_PORT_NUM_UDLIP2*MAINAXI_S_AXI_ID_WIDTH +: MAINAXI_S_AXI_ID_WIDTH]),
  .S_AXI_ARADDR(m_axi_araddr[CRSBAR_M_PORT_NUM_UDLIP2*32 +: 32]),
  .S_AXI_ARLEN(m_axi_arlen[CRSBAR_M_PORT_NUM_UDLIP2*8 +: 8]),
  .S_AXI_ARSIZE(m_axi_arsize[CRSBAR_M_PORT_NUM_UDLIP2*3 +: 3]),
  .S_AXI_ARBURST(m_axi_arburst[CRSBAR_M_PORT_NUM_UDLIP2*2 +: 2]),
  .S_AXI_ARLOCK(m_axi_arlock[CRSBAR_M_PORT_NUM_UDLIP2*1 +: 1]),
  .S_AXI_ARCACHE(m_axi_arcache[CRSBAR_M_PORT_NUM_UDLIP2*4 +: 4]),
  .S_AXI_ARPROT(m_axi_arprot[CRSBAR_M_PORT_NUM_UDLIP2*3 +: 3]),
  .S_AXI_ARVALID(m_axi_arvalid[CRSBAR_M_PORT_NUM_UDLIP2*1 +: 1]),
  .S_AXI_ARREADY(m_axi_arready[CRSBAR_M_PORT_NUM_UDLIP2*1 +: 1]),
  .S_AXI_RID(m_axi_rid[CRSBAR_M_PORT_NUM_UDLIP2*MAINAXI_S_AXI_ID_WIDTH +: MAINAXI_S_AXI_ID_WIDTH]),
  .S_AXI_RDATA(m_axi_rdata[CRSBAR_M_PORT_NUM_UDLIP2*32 +: 32]),
  .S_AXI_RRESP(m_axi_rresp[CRSBAR_M_PORT_NUM_UDLIP2*2 +: 2]),
  .S_AXI_RLAST(m_axi_rlast[CRSBAR_M_PORT_NUM_UDLIP2*1 +: 1]),
  .S_AXI_RVALID(m_axi_rvalid[CRSBAR_M_PORT_NUM_UDLIP2*1 +: 1]),
  .S_AXI_RREADY(m_axi_rready[CRSBAR_M_PORT_NUM_UDLIP2*1 +: 1]),
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
  .S_AXI_AWID(m_axi_awid[CRSBAR_M_PORT_NUM_UDLIP3*MAINAXI_S_AXI_ID_WIDTH +: MAINAXI_S_AXI_ID_WIDTH]),
  .S_AXI_AWADDR(m_axi_awaddr[CRSBAR_M_PORT_NUM_UDLIP3*32 +: 32]),
  .S_AXI_AWLEN(m_axi_awlen[CRSBAR_M_PORT_NUM_UDLIP3*8 +: 8]),
  .S_AXI_AWSIZE(m_axi_awsize[CRSBAR_M_PORT_NUM_UDLIP3*3 +: 3]),
  .S_AXI_AWBURST(m_axi_awburst[CRSBAR_M_PORT_NUM_UDLIP3*2 +: 2]),
  .S_AXI_AWLOCK(m_axi_awlock[CRSBAR_M_PORT_NUM_UDLIP3*1 +: 1]),
  .S_AXI_AWCACHE(m_axi_awcache[CRSBAR_M_PORT_NUM_UDLIP3*4 +: 4]),
  .S_AXI_AWPROT(m_axi_awprot[CRSBAR_M_PORT_NUM_UDLIP3*3 +: 3]),
  .S_AXI_AWVALID(m_axi_awvalid[CRSBAR_M_PORT_NUM_UDLIP3*1 +: 1]),
  .S_AXI_AWREADY(m_axi_awready[CRSBAR_M_PORT_NUM_UDLIP3*1 +: 1]),
  .S_AXI_WDATA(m_axi_wdata[CRSBAR_M_PORT_NUM_UDLIP3*32 +: 32]),
  .S_AXI_WSTRB(m_axi_wstrb[CRSBAR_M_PORT_NUM_UDLIP3*4 +: 4]),
  .S_AXI_WLAST(m_axi_wlast[CRSBAR_M_PORT_NUM_UDLIP3*1 +: 1]),
  .S_AXI_WVALID(m_axi_wvalid[CRSBAR_M_PORT_NUM_UDLIP3*1 +: 1]),
  .S_AXI_WREADY(m_axi_wready[CRSBAR_M_PORT_NUM_UDLIP3*1 +: 1]),
  .S_AXI_BID(m_axi_bid[CRSBAR_M_PORT_NUM_UDLIP3*MAINAXI_S_AXI_ID_WIDTH +: MAINAXI_S_AXI_ID_WIDTH]),
  .S_AXI_BRESP(m_axi_bresp[CRSBAR_M_PORT_NUM_UDLIP3*2 +: 2]),
  .S_AXI_BVALID(m_axi_bvalid[CRSBAR_M_PORT_NUM_UDLIP3*1 +: 1]),
  .S_AXI_BREADY(m_axi_bready[CRSBAR_M_PORT_NUM_UDLIP3*1 +: 1]),
  .S_AXI_ARID(m_axi_arid[CRSBAR_M_PORT_NUM_UDLIP3*MAINAXI_S_AXI_ID_WIDTH +: MAINAXI_S_AXI_ID_WIDTH]),
  .S_AXI_ARADDR(m_axi_araddr[CRSBAR_M_PORT_NUM_UDLIP3*32 +: 32]),
  .S_AXI_ARLEN(m_axi_arlen[CRSBAR_M_PORT_NUM_UDLIP3*8 +: 8]),
  .S_AXI_ARSIZE(m_axi_arsize[CRSBAR_M_PORT_NUM_UDLIP3*3 +: 3]),
  .S_AXI_ARBURST(m_axi_arburst[CRSBAR_M_PORT_NUM_UDLIP3*2 +: 2]),
  .S_AXI_ARLOCK(m_axi_arlock[CRSBAR_M_PORT_NUM_UDLIP3*1 +: 1]),
  .S_AXI_ARCACHE(m_axi_arcache[CRSBAR_M_PORT_NUM_UDLIP3*4 +: 4]),
  .S_AXI_ARPROT(m_axi_arprot[CRSBAR_M_PORT_NUM_UDLIP3*3 +: 3]),
  .S_AXI_ARVALID(m_axi_arvalid[CRSBAR_M_PORT_NUM_UDLIP3*1 +: 1]),
  .S_AXI_ARREADY(m_axi_arready[CRSBAR_M_PORT_NUM_UDLIP3*1 +: 1]),
  .S_AXI_RID(m_axi_rid[CRSBAR_M_PORT_NUM_UDLIP3*MAINAXI_S_AXI_ID_WIDTH +: MAINAXI_S_AXI_ID_WIDTH]),
  .S_AXI_RDATA(m_axi_rdata[CRSBAR_M_PORT_NUM_UDLIP3*32 +: 32]),
  .S_AXI_RRESP(m_axi_rresp[CRSBAR_M_PORT_NUM_UDLIP3*2 +: 2]),
  .S_AXI_RLAST(m_axi_rlast[CRSBAR_M_PORT_NUM_UDLIP3*1 +: 1]),
  .S_AXI_RVALID(m_axi_rvalid[CRSBAR_M_PORT_NUM_UDLIP3*1 +: 1]),
  .S_AXI_RREADY(m_axi_rready[CRSBAR_M_PORT_NUM_UDLIP3*1 +: 1]),
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
  .S_AXI_AWID(m_axi_awid[CRSBAR_M_PORT_NUM_UDLIP4*MAINAXI_S_AXI_ID_WIDTH +: MAINAXI_S_AXI_ID_WIDTH]),
  .S_AXI_AWADDR(m_axi_awaddr[CRSBAR_M_PORT_NUM_UDLIP4*32 +: 32]),
  .S_AXI_AWLEN(m_axi_awlen[CRSBAR_M_PORT_NUM_UDLIP4*8 +: 8]),
  .S_AXI_AWSIZE(m_axi_awsize[CRSBAR_M_PORT_NUM_UDLIP4*3 +: 3]),
  .S_AXI_AWBURST(m_axi_awburst[CRSBAR_M_PORT_NUM_UDLIP4*2 +: 2]),
  .S_AXI_AWLOCK(m_axi_awlock[CRSBAR_M_PORT_NUM_UDLIP4*1 +: 1]),
  .S_AXI_AWCACHE(m_axi_awcache[CRSBAR_M_PORT_NUM_UDLIP4*4 +: 4]),
  .S_AXI_AWPROT(m_axi_awprot[CRSBAR_M_PORT_NUM_UDLIP4*3 +: 3]),
  .S_AXI_AWVALID(m_axi_awvalid[CRSBAR_M_PORT_NUM_UDLIP4*1 +: 1]),
  .S_AXI_AWREADY(m_axi_awready[CRSBAR_M_PORT_NUM_UDLIP4*1 +: 1]),
  .S_AXI_WDATA(m_axi_wdata[CRSBAR_M_PORT_NUM_UDLIP4*32 +: 32]),
  .S_AXI_WSTRB(m_axi_wstrb[CRSBAR_M_PORT_NUM_UDLIP4*4 +: 4]),
  .S_AXI_WLAST(m_axi_wlast[CRSBAR_M_PORT_NUM_UDLIP4*1 +: 1]),
  .S_AXI_WVALID(m_axi_wvalid[CRSBAR_M_PORT_NUM_UDLIP4*1 +: 1]),
  .S_AXI_WREADY(m_axi_wready[CRSBAR_M_PORT_NUM_UDLIP4*1 +: 1]),
  .S_AXI_BID(m_axi_bid[CRSBAR_M_PORT_NUM_UDLIP4*MAINAXI_S_AXI_ID_WIDTH +: MAINAXI_S_AXI_ID_WIDTH]),
  .S_AXI_BRESP(m_axi_bresp[CRSBAR_M_PORT_NUM_UDLIP4*2 +: 2]),
  .S_AXI_BVALID(m_axi_bvalid[CRSBAR_M_PORT_NUM_UDLIP4*1 +: 1]),
  .S_AXI_BREADY(m_axi_bready[CRSBAR_M_PORT_NUM_UDLIP4*1 +: 1]),
  .S_AXI_ARID(m_axi_arid[CRSBAR_M_PORT_NUM_UDLIP4*MAINAXI_S_AXI_ID_WIDTH +: MAINAXI_S_AXI_ID_WIDTH]),
  .S_AXI_ARADDR(m_axi_araddr[CRSBAR_M_PORT_NUM_UDLIP4*32 +: 32]),
  .S_AXI_ARLEN(m_axi_arlen[CRSBAR_M_PORT_NUM_UDLIP4*8 +: 8]),
  .S_AXI_ARSIZE(m_axi_arsize[CRSBAR_M_PORT_NUM_UDLIP4*3 +: 3]),
  .S_AXI_ARBURST(m_axi_arburst[CRSBAR_M_PORT_NUM_UDLIP4*2 +: 2]),
  .S_AXI_ARLOCK(m_axi_arlock[CRSBAR_M_PORT_NUM_UDLIP4*1 +: 1]),
  .S_AXI_ARCACHE(m_axi_arcache[CRSBAR_M_PORT_NUM_UDLIP4*4 +: 4]),
  .S_AXI_ARPROT(m_axi_arprot[CRSBAR_M_PORT_NUM_UDLIP4*3 +: 3]),
  .S_AXI_ARVALID(m_axi_arvalid[CRSBAR_M_PORT_NUM_UDLIP4*1 +: 1]),
  .S_AXI_ARREADY(m_axi_arready[CRSBAR_M_PORT_NUM_UDLIP4*1 +: 1]),
  .S_AXI_RID(m_axi_rid[CRSBAR_M_PORT_NUM_UDLIP4*MAINAXI_S_AXI_ID_WIDTH +: MAINAXI_S_AXI_ID_WIDTH]),
  .S_AXI_RDATA(m_axi_rdata[CRSBAR_M_PORT_NUM_UDLIP4*32 +: 32]),
  .S_AXI_RRESP(m_axi_rresp[CRSBAR_M_PORT_NUM_UDLIP4*2 +: 2]),
  .S_AXI_RLAST(m_axi_rlast[CRSBAR_M_PORT_NUM_UDLIP4*1 +: 1]),
  .S_AXI_RVALID(m_axi_rvalid[CRSBAR_M_PORT_NUM_UDLIP4*1 +: 1]),
  .S_AXI_RREADY(m_axi_rready[CRSBAR_M_PORT_NUM_UDLIP4*1 +: 1]),
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
