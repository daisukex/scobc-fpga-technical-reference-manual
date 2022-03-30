//-----------------------------------------------
// Module: sysreg
//  Space Cubics OBC FPGA System Register
//-----------------------------------------------
// Copyright © 2021-2022 Space Cubics, LLC.
//-----------------------------------------------

module sysreg (
  // System Interface
  input SYSCLK,
  input RESETB,
  input POR_RSTB,

  // AHB Interface
  input SHSEL,
  input [31:0] SHADDR,
  input [1:0] SHTRANS,
  input [2:0] SHSIZE,
  input [2:0] SHBURST,
  input SHWRITE,
  input SHREADYIN,
  output SHREADYOUT,
  input [31:0] SHWDATA,
  output [31:0] SHRDATA,
  output [1:0] SHRESP,

  // System Register Output
  output SYS_RESET_REQ,
  output CFGITCMEN,
  input [1:0] TRCH_BOOT,
  output [1:0] CLKMODE,
  output CMC_REQ,
  input CMC_ACK
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
  .HCLK(SYSCLK),
  .HRESETN(RESETB),
  .HSEL(SHSEL),
  .HADDR(SHADDR),
  .HTRANS(SHTRANS),
  .HSIZE(SHSIZE),
  .HBURST(SHBURST),
  .HWRITE(SHWRITE),
  .HREADYIN(SHREADYIN),
  .HREADYOUT(SHREADYOUT),
  .HWDATA(SHWDATA),
  .HRDATA(SHRDATA),
  .HRESP(SHRESP),

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

sysreg_main sysreg_main (
  // System Interface
  .HCLK(SYSCLK),
  .HRESETN(RESETB),
  .POR_RSTB(POR_RSTB),

  // Register Interface
  .REG_WADR(REG_WADR),
  .REG_WENB(REG_WENB),
  .REG_WDAT(REG_WDAT),
  .REG_WWAT(REG_WWAT),
  .REG_RADR(REG_RADR),
  .REG_RENB(REG_RENB),
  .REG_RDAT(REG_RDAT),

  // Input/Output Signals
  .CFGITCMEN(CFGITCMEN),
  .SYS_RST_REQ(SYS_RESET_REQ),
  .TRCH_BOOT(TRCH_BOOT),
  .CLKMODE(CLKMODE),
  .CMC_REQ(CMC_REQ),
  .CMC_ACK(CMC_ACK)
);

endmodule
