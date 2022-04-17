//-----------------------------------------------
// Module: system_monitor.v
//  Space Cubics OBC FPGA System Register
//-----------------------------------------------
// Copyright © 2022 Space Cubics, LLC.
//-----------------------------------------------

module system_monitor (
  // System Interface
  input HCLK,
  input HRESETN,
  input REF_CLK,
  input SYS_RSTB_SYNC_REFCLK,

  // AHB Interface
  input HSEL,
  input [31:0] HADDR,
  input [1:0] HTRANS,
  input [2:0] HSIZE,
  input [2:0] HBURST,
  input HWRITE,
  input HREADYIN,
  output HREADYOUT,
  input [31:0] HWDATA,
  output [31:0] HRDATA,
  output [1:0] HRESP,

  output FPGA_WATCHDOG,
  output WDOG_RST_REQ
);

wire [31:0] REG_WADR;
wire [3:0] REG_WENB;
wire [31:0] REG_WDAT;
wire REG_WWAT;
wire [31:0] REG_RADR;
wire REG_RENB;
wire [31:0] REG_RDAT;

sc_ahbip_slave # (
  .CYCLE_MODE(1)
) ahb_slave (
  // AHB Interface
  .HCLK(HCLK),
  .HRESETN(HRESETN),
  .HSEL(HSEL),
  .HADDR(HADDR),
  .HTRANS(HTRANS),
  .HSIZE(HSIZE),
  .HBURST(HBURST),
  .HWRITE(HWRITE),
  .HREADYIN(HREADYIN),
  .HREADYOUT(HREADYOUT),
  .HWDATA(HWDATA),
  .HRDATA(HRDATA),
  .HRESP(HRESP),

  // Register Interface
  .REG_WADR(REG_WADR),
  .REG_WTYP(/*open*/),
  .REG_WENB(REG_WENB),
  .REG_WDAT(REG_WDAT),
  .REG_WWAT(REG_WWAT),
  .REG_WERR(1'b0),

  .REG_RADR(REG_RADR),
  .REG_RTYP(/*open*/),
  .REG_RENB(REG_RENB),
  .REG_RDAT(REG_RDAT),
  .REG_RWAT(1'b0),
  .REG_RERR(1'b0)
);

sysmon_reg sysmon_reg (
  .HCLK(HCLK),
  .HRESETN(HRESETN),
  .REF_CLK(REF_CLK),
  .SYS_RSTB_SYNC_REFCLK(SYS_RSTB_SYNC_REFCLK),

  // Register Interface
  .REG_WADR(REG_WADR),
  .REG_WENB(REG_WENB),
  .REG_WDAT(REG_WDAT),
  .REG_WWAT(REG_WWAT),

  .REG_RADR(REG_RADR),
  .REG_RENB(REG_RENB),
  .REG_RDAT(REG_RDAT),
  .REG_RWAT(REG_RWAT),

  .FPGA_WATCHDOG(FPGA_WATCHDOG),
  .WDOG_RST_REQ(WDOG_RST_REQ)
);

endmodule
