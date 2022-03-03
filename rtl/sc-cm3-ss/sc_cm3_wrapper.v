//-----------------------------------------------
// Space Cubics Cortex-M3 SubSystem
//  Cortex-M3 Wrapper
//  Module: sc_cm3_wrapper
//-----------------------------------------------
// Copyright © 2022 Space Cubics, LLC.
//-----------------------------------------------

module sc_cm3_wrapper # (
  `include "sc_cm3_param.vh"
) (
  // System Interface
  input HCLK,
  input SYSRESETn,
  input DBGRESETn,
  output SYSRESETREQ,
  input NMI,
  input [CM3SS_PRIMARY_ISR_NUM-1:0] INTISR1,
  input [CM3SS_SECONDARY_ISR_NUM-1:0] INTISR2,

  // System Tick Clock and System Timer Signals
  input STCLK,
  input [25:0] STCALIB,

  // AHB I-Code Interface
  output [1:0] HTRANSI,
  output [2:0] HSIZEI,
  output [31:0] HADDRI,
  output [2:0] HBURSTI,
  output [3:0] HPROTI,
  input HREADYI,
  input [31:0] HRDATAI,
  input [1:0] HRESPI,

  // AHB D-Code Interface
  output [1:0] HTRANSD,
  output [2:0] HSIZED,
  output [31:0] HADDRD,
  output [2:0] HBURSTD,
  output [3:0] HPROTD,
  output HWRITED,
  output [31:0] HWDATAD,
  input HREADYD,
  input [31:0] HRDATAD,
  input [1:0] HRESPD,
  output EXREQD,
  input EXRESPD,

  // AHB SYS Interface
  output [1:0] HTRANSS,
  output [2:0] HSIZES,
  output [31:0] HADDRS,
  output [2:0] HBURSTS,
  output [3:0] HPROTS,
  output HWRITES,
  output [31:0] HWDATAS,
  input HREADYS,
  input [31:0] HRDATAS,
  input [1:0] HRESPS,
  output HMASTLOCKS,
  output EXREQS,
  input EXRESPS,

  // Miscellaneous
  output HALTED,
  output LOCKUP,
  output SLEEPING,
  input SLEEPHOLDREQn,
  output SLEEPHOLDACKn,
  input WICENREQ,
  output WICENACK,
  output WAKEUP,

  // SWJ-DP Interface
  input nTRST,
  input SWCLKTCK,
  input SWDITMS,
  output SWDOEN,
  output SWDO,
  input TDI,
  output TDO,
  output nTDOEN,
  output SWV,
  output JTAGNSW
);

// INTISR signal: 240bit
wire [239:0] INTISR ={{224-CM3SS_SECONDARY_ISR_NUM{1'b0}}, INTISR2,
                      {16-CM3SS_PRIMARY_ISR_NUM{1'b0}},    INTISR1};

wire CDBGPWRUPREQ;
reg [47:0] TSVALUEB;
wire TRCENA;
wire ENABLECNT = ~HALTED & TRCENA;
wire CM3_SLEEPING;
assign SLEEPING = CM3_SLEEPING & ~CDBGPWRUPREQ;

CORTEXM3INTEGRATION CORTEXM3INTEGRATION (
  .HCLK(HCLK),
  .FCLK(HCLK),
  .TRACECLKIN(HCLK),
  .PORESETn(DBGRESETn),
  .SYSRESETn(SYSRESETn),
  .SYSRESETREQ(SYSRESETREQ),
  .INTNMI(NMI),
  .INTISR(INTISR),
  .GATEHCLK(/*open*/),

  // System Tick Clock and System Timer Signals
  .STCLK(STCLK),
  .STCALIB(STCALIB),

  // AHB I-Code Interface
  .HTRANSI(HTRANSI),
  .HSIZEI(HSIZEI),
  .HADDRI(HADDRI),
  .HBURSTI(HBURSTI),
  .HPROTI(HPROTI),
  .HREADYI(HREADYI),
  .HRDATAI(HRDATAI),
  .HRESPI(HRESPI),
  .MEMATTRI(/*open*/),

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
  .HMASTERD(/*open*/),
  .MEMATTRD(/*open*/),

  // AHB SYS Interface
  .HTRANSS(HTRANSS),
  .HSIZES(HSIZES),
  .HADDRS(HADDRS),
  .HBURSTS(HBURSTS),
  .HPROTS(HPROTS),
  .HWRITES(HWRITES),
  .HWDATAS(HWDATAS),
  .HREADYS(HREADYS),
  .HRDATAS(HRDATAS),
  .HRESPS(HRESPS),
  .HMASTLOCKS(HMASTLOCKS),
  .EXREQS(EXREQS),
  .EXRESPS(EXRESPS),
  .HMASTERS(/*open*/),
  .MEMATTRS(/*open*/),

  // Master ID signal
  .FIXMASTERTYPE(1'b1),

  // AHB Trace Macro Interface
  .HTMDHADDR(/*open 32bit*/),
  .HTMDHTRANS(/*open 2bit*/),
  .HTMDHSIZE(/*open 3bit*/),
  .HTMDHBURST(/*open 3bit*/),
  .HTMDHPROT(/*open 4bit*/),
  .HTMDHWDATA(/*open 32bit*/),
  .HTMDHWRITE(/*open 1bit*/),
  .HTMDHRDATA(/*open 32bit*/),
  .HTMDHREADY(/*open 1bit*/),
  .HTMDHRESP(/*open 2bit*/),

  // Miscellaneous
  .MPUDISABLE(1'b0),
  .BIGEND(1'b0),
  .HALTED(HALTED),
  .LOCKUP(LOCKUP),
  .SLEEPING(CM3_SLEEPING),
  .SLEEPHOLDREQn(SLEEPHOLDREQn),
  .SLEEPHOLDACKn(SLEEPHOLDACKn),
  .SLEEPDEEP(/*open*/),
  .WAKEUP(WAKEUP),
  .WICENREQ(WICENREQ),
  .WICENACK(WICENACK),
  .TSCLKCHANGE(1'b0),
  .TSVALUEB(TSVALUEB),
  .IFLUSH(1'b0),
  .AUXFAULT(32'h0),
  .BRCHSTAT(/*open*/),
  .CURRPRI(/*open*/),

  // Event Interface
  .TXEV(/*open*/),
  .RXEV(1'b0),

  // SWJ-DP Interface
  .nTRST(nTRST),
  .SWCLKTCK(SWCLKTCK),
  .SWDITMS(SWDITMS),
  .SWDOEN(SWDOEN),
  .SWDO(SWDO),
  .TDI(TDI),
  .TDO(TDO),
  .nTDOEN(nTDOEN),
  .SWV(SWV),
  .JTAGNSW(JTAGNSW),

  // Debug Interface
  .DBGEN(1'b1),
  .EDBGRQ(1'b0),
  .TRACECLK(/*open*/),
  .TRACEDATA(/*open*/),
  .TRCENA(TRCENA),
  .DBGRESTART(1'b0),
  .DBGRESTARTED(/*open*/),
  .ETMINTNUM(/*open*/),
  .ETMINTSTAT(/*open*/),
  .CDBGPWRUPACK(CDBGPWRUPREQ),
  .CDBGPWRUPREQ(CDBGPWRUPREQ),
  .INTERNALSTATE(/*open*/),

  // Power domain signals
  .ISOLATEn(1'b1),
  .RETAINn(1'b1),

  // LSI Test Interface
  .SE(1'b0),
  .RSTBYPASS(1'b0),
  .CGBYPASS(1'b0)
);

always @ (posedge HCLK or negedge DBGRESETn) begin
  if (!DBGRESETn)
    TSVALUEB <= 0;
  else if (ENABLECNT)
    TSVALUEB <= TSVALUEB + 1;
end

endmodule
