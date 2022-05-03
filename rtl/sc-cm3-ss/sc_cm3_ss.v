//-----------------------------------------------
// Space Cubics Cortex-M3 SubSystem
//  Cortex-M3 SubSystem Top
//  Module: sc_cm3_ss
//-----------------------------------------------
// Copyright © 2022 Space Cubics, LLC.
//-----------------------------------------------

module sc_cm3_ss # (
  `include "sc_cm3_param.vh"
) (
  // System Interface
  input SYS_CLK,
  input REF_CLK,
  input SYS_RST_N,
  input DBG_RST_N,
  output SYS_RST_REQ,
  input CFGITCMEN,
  output CPU_LOCKUP,
  output CPU_HALTED,
  output CPU_SLEEPING,
  input CPU_SLEEPHOLDREQN,
  output CPU_SLEEPHOLDACKN,
  input CPU_WICENREQ,
  output CPU_WICENACK,
  output CPU_WAKEUP,

  // Interrupt Signal
  input [CM3SS_PRIMARY_ISR_NUM-1:0] INTISR1,
  input [CM3SS_SECONDARY_ISR_NUM-1:0] INTISR2,
  input NMI,

  // CM3_COD_AHB Interface
  output CM3_COD_HSEL,
  output [1:0] CM3_COD_HTRANS,
  output [31:0] CM3_COD_HADDR,
  output [2:0] CM3_COD_HBURST,
  output CM3_COD_HWRITE,
  output [2:0] CM3_COD_HSIZE,
  output [3:0] CM3_COD_HPROT,
  output [31:0] CM3_COD_HWDATA,
  input CM3_COD_HREADY,
  input [31:0] CM3_COD_HRDATA,
  input [1:0] CM3_COD_HRESP,

  // CM3_SYS_AXI3 Write Address Channel
  output [31:0] CM3_SYS_AWADDR,
  output [3:0] CM3_SYS_AWLEN,
  output [2:0] CM3_SYS_AWSIZE,
  output [1:0] CM3_SYS_AWBURST,
  output [1:0] CM3_SYS_AWLOCK,
  output [3:0] CM3_SYS_AWCACHE,
  output [2:0] CM3_SYS_AWPROT,
  output CM3_SYS_AWUSER,
  output CM3_SYS_AWVALID,
  input  CM3_SYS_AWREADY,

  // CM3_SYS_AXI3 Write Data Channel
  output [31:0] CM3_SYS_WDATA,
  output [3:0] CM3_SYS_WSTRB,
  output CM3_SYS_WLAST,
  output CM3_SYS_WVALID,
  input  CM3_SYS_WREADY,

  // CM3_SYS_AXI3 Write Responce Channel
  input  [1:0] CM3_SYS_BRESP,
  input  CM3_SYS_BVALID,
  output CM3_SYS_BREADY,

  // CM3_SYS_AXI3 Read Address Channel
  output [31:0] CM3_SYS_ARADDR,
  output [3:0] CM3_SYS_ARLEN,
  output [2:0] CM3_SYS_ARSIZE,
  output [1:0] CM3_SYS_ARBURST,
  output [1:0] CM3_SYS_ARLOCK,
  output [3:0] CM3_SYS_ARCACHE,
  output [2:0] CM3_SYS_ARPROT,
  output CM3_SYS_ARUSER,
  output CM3_SYS_ARVALID,
  input  CM3_SYS_ARREADY,

  // CM3_SYS_AXI3 Read Data Channel
  input  [31:0] CM3_SYS_RDATA,
  input  [1:0] CM3_SYS_RRESP,
  input  CM3_SYS_RLAST,
  input  CM3_SYS_RVALID,
  output CM3_SYS_RREADY,

  // SWJ-DP Interface
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

wire SYSRESETREQ;
wire HSEL;
wire [1:0] HTRANSI;
wire [2:0] HSIZEI;
wire [31:0] HADDRI;
wire [2:0] HBURSTI;
wire [3:0] HPROTI;
wire HREADYI;
wire [31:0] HRDATAI;

wire [1:0] HRESPI;
wire [1:0] HTRANSD;
wire [2:0] HSIZED;
wire [31:0] HADDRD;
wire [2:0] HBURSTD;
wire [3:0] HPROTD;
wire HWRITED;
wire [31:0] HWDATAD;
wire HREADYD;
wire [31:0] HRDATAD;
wire [1:0] HRESPD;
wire EXREQD;
wire EXRESPD;
wire [1:0] HTRANS;
wire [2:0] HSIZE;
wire [31:0] HADDR;
wire [2:0] HBURST;
wire [3:0] HPROT;
wire HWRITE;
wire [31:0] HWDATA;
wire [1:0] HTRANSS;
wire [2:0] HSIZES;
wire [31:0] HADDRS;
wire [2:0] HBURSTS;
wire [3:0] HPROTS;
wire HWRITES;
wire HREADYS;
wire [31:0] HWDATAS;
assign CM3_SYS_WDATA = HWDATAS;
wire [1:0] HRESPS;
wire HMASTLOCKS;
wire EXREQS;
wire EXRESPS;
wire AHB_HREADY;
wire [31:0] AHB_HRDATA;
wire [1:0] AHB_HRESP;
wire HSEL_ITCM;
wire HREADY_ITCM;
wire [31:0] HRDATA_ITCM;
wire [1:0] HRESP_ITCM;
wire [1:0] AWLOCK;
wire [1:0] ARLOCK;

// Generate System Tick
reg [3:0] st_divider;
reg st_clk;
always @ (posedge REF_CLK) begin
  if (!SYS_RST_N) begin
    st_clk <= 0;
    st_divider <= 0;
  end
  else if (st_divider == 11) begin
    st_clk <= ~st_clk;
    st_divider <= 0;
  end
  else
    st_divider <= st_divider + 1;
end
wire [25:0] stcalib;
assign stcalib[25]   = 1'b0;
assign stcalib[24]   = 1'b0;
assign stcalib[23:0] = 24'h4E1F;

sc_cm3_wrapper cpu_wrapper (
  // System Interface
  .HCLK(SYS_CLK),
  .SYSRESETn(SYS_RST_N),
  .DBGRESETn(DBG_RST_N),
  .SYSRESETREQ(SYS_RST_REQ),
  .NMI(NMI),
  .INTISR1(INTISR1),
  .INTISR2(INTISR2),

  // System Tick Clock and System Timer Signals
  .STCLK(st_clk),
  .STCALIB(stcalib),

  // AHB I-Code Interface
  .HTRANSI(HTRANSI),
  .HSIZEI(HSIZEI),
  .HADDRI(HADDRI),
  .HBURSTI(HBURSTI),
  .HPROTI(HPROTI),
  .HREADYI(HREADYI),
  .HRDATAI(HRDATAI),
  .HRESPI(HRESPI),

  // AHB D-Code Interface
  .HTRANSD(HTRANSD),
  .HSIZED(HSIZED),
  .HADDRD(HADDRD),
  .HBURSTD(HBURSTD),
  .HPROTD(HPROTD),
  .HWRITED(HWRITED),
  .HWDATAD(HWDATAD),
  .HREADYD(HREADYD),
  .HRDATAD(HRDATAD),
  .HRESPD(HRESPD),
  .EXREQD(EXREQD),
  .EXRESPD(EXRESPD),

  // AHB SYS Interface
  .HTRANSS(HTRANSS),
  .HSIZES(HSIZES),
  .HADDRS(HADDRS),
  .HBURSTS(HBURSTS),
  .HPROTS(HPROTS),
  .HWRITES(HWRITES),
  .HWDATAS(HWDATAS),
  .HREADYS(HREADYS),
  .HRDATAS(CM3_SYS_RDATA),
  .HRESPS(HRESPS),
  .HMASTLOCKS(HMASTLOCKS),
  .EXREQS(EXREQS),
  .EXRESPS(EXRESPS),

  // Miscellaneous
  .HALTED(CPU_HALTED),
  .LOCKUP(CPU_LOCKUP),
  .SLEEPING(CPU_SLEEPING),
  .SLEEPHOLDREQn(CPU_SLEEPHOLDREQN),
  .SLEEPHOLDACKn(CPU_SLEEPHOLDACKN),
  .WICENREQ(CPU_WICENREQ),
  .WICENACK(CPU_WICENACK),
  .WAKEUP(CPU_WAKEUP),

  // SWJ-DP Interface
  .nTRST(NTRST),
  .SWCLKTCK(SWCLKTCK),
  .SWDITMS(SWDITMS),
  .SWDOEN(SWDOEN),
  .SWDO(SWDO),
  .TDI(TDI),
  .TDO(TDO),
  .nTDOEN(NTDOEN),
  .SWV(SWV),
  .JTAGNSW(JTAGNSW)
);

sc_cm3_ex_mon ex_monitor (
  // System Interface
  .HCLK(SYS_CLK),
  .HRESETN(SYS_RST_N),

  // Exclusive Monitor AHB
  .HTRANS(HTRANSD),
  .HADDR(HADDRD),
  .HWRITE(HWRITED),
  .HREADY(HREADYD),
  .HRESP(HRESPD),
  .EXREQ(EXREQD),
  .EXRESP(EXRESPD)
);

AhbSToAxi ahbstoaxi (
  .CLK(SYS_CLK),
  .RESETn(SYS_RST_N),
  .HREADY(1'b1),
  .HSEL(1'b1),
  .HADDR(HADDRS),
  .HTRANS(HTRANSS),
  .HWRITE(HWRITES),
  .HSIZE(HSIZES),
  .HBURST(HBURSTS),
  .HPROT(HPROTS),
  .HMASTLOCK(HMASTLOCKS),
  .HAUSER(1'b0),
  .HREADYOUT(HREADYS),
  .HRESP(HRESPS),
  .AWADDR(CM3_SYS_AWADDR),
  .AWLEN(CM3_SYS_AWLEN),
  .AWSIZE(CM3_SYS_AWSIZE),
  .AWBURST(CM3_SYS_AWBURST),
  .AWLOCK(AWLOCK),
  .AWCACHE(CM3_SYS_AWCACHE),
  .AWPROT(CM3_SYS_AWPROT),
  .AWUSER(CM3_SYS_AWUSER),
  .AWVALID(CM3_SYS_AWVALID),
  .AWREADY(CM3_SYS_AWREADY),
  .WSTRB(CM3_SYS_WSTRB),
  .WLAST(CM3_SYS_WLAST),
  .WVALID(CM3_SYS_WVALID),
  .WREADY(CM3_SYS_WREADY),
  .BRESP(CM3_SYS_BRESP),
  .BVALID(CM3_SYS_BVALID),
  .BREADY(CM3_SYS_BREADY),
  .ARADDR(CM3_SYS_ARADDR),
  .ARLEN(CM3_SYS_ARLEN),
  .ARSIZE(CM3_SYS_ARSIZE),
  .ARBURST(CM3_SYS_ARBURST),
  .ARLOCK(ARLOCK),
  .ARCACHE(CM3_SYS_ARCACHE),
  .ARPROT(CM3_SYS_ARPROT),
  .ARUSER(CM3_SYS_ARUSER),
  .ARVALID(CM3_SYS_ARVALID),
  .ARREADY(CM3_SYS_ARREADY),
  .RRESP(CM3_SYS_RRESP),
  .RLAST(CM3_SYS_RLAST),
  .RVALID(CM3_SYS_RVALID),
  .RREADY(CM3_SYS_RREADY),
  .CSYSREQ(1'b0),
  .CSYSACK(/*open*/),
  .CACTIVE(/*open*/),
  .SCANENABLE(1'b0),
  .SCANINCLK(1'b0),
  .SCANOUTCLK(/*open*/)
);

sc_cm3_ex_translator ex_translator (
  // System Interface
  .HCLK(SYS_CLK),
  .HRESETN(SYS_RST_N),

  // AHB Interface
  .HTRANS(HTRANSS),
  .HWRITE(HWRITES),
  .HREADY(HREADYS),
  .EXREQ(EXREQS),
  .EXRESP(EXRESPS),

  // AXI Interface
  .AWVALID(CM3_SYS_AWVALID),
  .AWLOCK_I(AWLOCK),
  .AWLOCK_O(CM3_SYS_AWLOCK),
  .ARVALID(CM3_SYS_ARVALID),
  .ARLOCK_I(ARLOCK),
  .ARLOCK_O(CM3_SYS_ARLOCK),
  .BVALID(CM3_SYS_BVALID),
  .BREADY(CM3_SYS_BREADY),
  .BRESP(CM3_SYS_BRESP),
  .RVALID(CM3_SYS_RVALID),
  .RREADY(CM3_SYS_RREADY),
  .RRESP(CM3_SYS_RRESP)
);

sc_cm3_ahb_decoder ahb_decoder (
  .HCLK(SYS_CLK),
  .HRESETN(SYS_RST_N),
  .CFGITCMEN(CFGITCMEN),
  .HADDR(HADDR),
  .HSEL_ITCM(HSEL_ITCM),
  .HSEL_SRAM(CM3_COD_HSEL),
  .HREADY_ITCM(HREADY_ITCM),
  .HREADY_SRAM(CM3_COD_HREADY),
  .HRDATA_ITCM(HRDATA_ITCM),
  .HRDATA_SRAM(CM3_COD_HRDATA),
  .HRESP_ITCM(HRESP_ITCM),
  .HRESP_SRAM(CM3_COD_HRESP),
  .HREADY(AHB_HREADY),
  .HRDATA(AHB_HRDATA),
  .HRESP(AHB_HRESP)
);

sc_cm3_ahb_mux ahb_mux (
  // System Interface
  .HCLK(SYS_CLK),
  .HRESETN(SYS_RST_N),

  // AHB I-Code Bus
  .HTRANSI(HTRANSI),
  .HADDRI(HADDRI),
  .HBURSTI(HBURSTI),
  .HSIZEI(HSIZEI),
  .HPROTI(HPROTI),
  .HWDATAI(32'h0),
  .HRDATAI(HRDATAI),
  .HREADYI(HREADYI),
  .HRESPI(HRESPI),

  // AHB D-Code Bus
  .HTRANSD(HTRANSD),
  .HADDRD(HADDRD),
  .HBURSTD(HBURSTD),
  .HWRITED(HWRITED),
  .HSIZED(HSIZED),
  .HWDATAD(HWDATAD),
  .HRDATAD(HRDATAD),
  .HREADYD(HREADYD),
  .HRESPD(HRESPD),

  // AHB MUX Bus
  .HTRANS(HTRANS),
  .HADDR(HADDR),
  .HBURST(HBURST),
  .HWRITE(HWRITE),
  .HSIZE(HSIZE),
  .HPROT(HPROT),
  .HWDATA(HWDATA),
  .HRDATA(AHB_HRDATA),
  .HREADY(AHB_HREADY),
  .HRESP(AHB_HRESP)
);

assign CM3_COD_HTRANS = HTRANS;
assign CM3_COD_HADDR = HADDR;
assign CM3_COD_HBURST = HBURST;
assign CM3_COD_HWRITE = HWRITE;
assign CM3_COD_HSIZE = HSIZE;
assign CM3_COD_HPROT = HPROT;
assign CM3_COD_HWDATA = HWDATA;

ahb_memory # (
  .MEM_SIZE_KB(CM3SS_ITCM_SIZE_KB),
  .MEM_ADDR_BW(CM3SS_ITCM_ADDR_BW),
  .MEM_INIT(CM3SS_ITCM_INIT),
  .MEM_INIT_FILE(CM3SS_ITCM_INIT_FILE)
) itcm (
  .HCLK(SYS_CLK),
  .HRESETN(SYS_RST_N),
  .HSEL(HSEL_ITCM),
  .HTRANS(HTRANS),
  .HADDR(HADDR),
  .HBURST(HBURST),
  .HWRITE(HWRITE),
  .HSIZE(HSIZE),
  .HPROT(HPROT),
  .HWDATA(HWDATA),
  .HREADY(HREADY_ITCM),
  .HRDATA(HRDATA_ITCM),
  .HRESP(HRESP_ITCM)
);

endmodule
