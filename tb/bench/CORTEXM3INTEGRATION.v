module CORTEXM3INTEGRATION (
  input ISOLATEn,
  input RETAINn,
  input nTRST,
  input SWCLKTCK,
  input SWDITMS,
  input TDI,
  input PORESETn,
  input SYSRESETn,
  input RSTBYPASS,
  input CGBYPASS,
  input FCLK,
  input HCLK,
  input TRACECLKIN,
  input STCLK,
  input [25:0]STCALIB,
  input [31:0]AUXFAULT,
  input BIGEND,
  input [239:0]INTISR,
  input INTNMI,
  input HREADYI,
  input [31:0]HRDATAI,
  input [1:0]HRESPI,
  input IFLUSH,
  input HREADYD,
  input [31:0]HRDATAD,
  input [1:0]HRESPD,
  input EXRESPD,
  input SE,
  input HREADYS,
  input [31:0]HRDATAS,
  input [1:0]HRESPS,
  input EXRESPS,
  input EDBGRQ,
  input DBGRESTART,
  input RXEV,
  input SLEEPHOLDREQn,
  input WICENREQ,
  input FIXMASTERTYPE,
  input [47:0]TSVALUEB,
  input TSCLKCHANGE,
  input MPUDISABLE,
  input DBGEN,
  input CDBGPWRUPACK,
  output TDO,
  output nTDOEN,
  output SWDOEN,
  output SWDO,
  output SWV,
  output JTAGNSW,
  output TRACECLK,
  output [3:0]TRACEDATA,
  output TRCENA,
  output [1:0]HTRANSI,
  output [2:0]HSIZEI,
  output [31:0]HADDRI,
  output [2:0]HBURSTI,
  output [3:0]HPROTI,
  output [1:0]MEMATTRI,
  output [1:0]HTRANSD,
  output [2:0]HSIZED,
  output [31:0]HADDRD,
  output [2:0]HBURSTD,
  output [3:0]HPROTD,
  output [1:0]MEMATTRD,
  output [1:0]HMASTERD,
  output EXREQD,
  output HWRITED,
  output [31:0]HWDATAD,
  output [1:0]HTRANSS,
  output [2:0]HSIZES,
  output [31:0]HADDRS,
  output [2:0]HBURSTS,
  output [3:0]HPROTS,
  output [1:0]MEMATTRS,
  output [1:0]HMASTERS,
  output EXREQS,
  output HWRITES,
  output [31:0]HWDATAS,
  output HMASTLOCKS,
  output [3:0]BRCHSTAT,
  output HALTED,
  output LOCKUP,
  output SLEEPING,
  output SLEEPDEEP,
  output [8:0]ETMINTNUM,
  output [2:0]ETMINTSTAT,
  output SYSRESETREQ,
  output TXEV,
  output [7:0]CURRPRI,
  output DBGRESTARTED,
  output SLEEPHOLDACKn,
  output GATEHCLK,
  output [148:0]INTERNALSTATE,
  output [31:0]HTMDHADDR,
  output [1:0]HTMDHTRANS,
  output [2:0]HTMDHSIZE,
  output [2:0]HTMDHBURST,
  output [3:0]HTMDHPROT,
  output [31:0]HTMDHWDATA,
  output HTMDHWRITE,
  output [31:0]HTMDHRDATA,
  output HTMDHREADY,
  output [1:0]HTMDHRESP,
  output WICENACK,
  output WAKEUP,
  output CDBGPWRUPREQ
);

assign TDO = 0;
assign nTDOEN = 1;
assign SWDOEN = 1;
assign SWDO = 0;
assign SWV = 0;
assign JTAGNSW = 0;
assign TRACECLK = 0;
assign TRACEDATA = 0;
assign TRCENA = 0;
assign HPROTI = 0;
assign MEMATTRI = 0;
assign HPROTD = 0;
assign MEMATTRD = 0;
assign HMASTERD = 0;
assign EXREQD = 0;
assign  HPROTS   = 0;
assign MEMATTRS = 0;
assign  HMASTERS = 0;
assign EXREQS = 0;
assign HMASTLOCKS = 0;
assign BRCHSTAT = 0;
assign HALTED = 0;
assign LOCKUP = 0;
assign SLEEPING = 0;
assign SLEEPDEEP = 0;
assign ETMINTNUM = 0;
assign ETMINTSTAT = 0;
assign SYSRESETREQ = 0;
assign TXEV = 0;
assign CURRPRI = 0;
assign DBGRESTARTED = 0;
assign SLEEPHOLDACKn = 1;
assign GATEHCLK = 0;
assign INTERNALSTATE = 0;
assign HTMDHADDR = 0;
assign HTMDHTRANS = 0;
assign HTMDHSIZE = 0;
assign HTMDHBURST = 0;
assign HTMDHPROT = 0;
assign HTMDHWDATA = 0;
assign HTMDHWRITE = 0;
assign HTMDHRDATA = 0;
assign HTMDHREADY = 0;
assign HTMDHRESP = 0;
assign WICENACK = 0;
assign WAKEUP = 0;
assign CDBGPWRUPREQ = 0;

endmodule
