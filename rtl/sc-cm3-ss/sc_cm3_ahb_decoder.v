//-----------------------------------------------
// Space Cubics Cortex-M3 SubSystem
//  Cortex-M3 AHB Decoder
//  Module: sc_cm3_ahb_decoder
//-----------------------------------------------
// Copyright © 2022 Space Cubics, LLC.
//-----------------------------------------------

module sc_cm3_ahb_decoder (
  input HCLK,
  input HRESETN,
  input CFGITCMEN,
  input [31:0] HADDR,
  output reg HSEL_ITCM,
  output reg HSEL_SRAM,
  input HREADY_ITCM,
  input HREADY_SRAM,
  input [31:0] HRDATA_ITCM,
  input [31:0] HRDATA_SRAM,
  input [1:0] HRESP_ITCM,
  input [1:0] HRESP_SRAM,
  output HREADY,
  output [31:0] HRDATA,
  output [1:0] HRESP
);

localparam CODE_LOW_ADDR_MIN  = 32'h0000_0000;
localparam CODE_LOW_ADDR_MAX  = 32'h0FFF_FFFF;
localparam CODE_HIGH_ADDR_MIN = 32'h1000_0000;
localparam CODE_HIGH_ADDR_MAX = 32'h1FFF_FFFF;

wire cfgitcm_ff;

tmr_ff #  (.DW(1), .SRVAL(1'b1))
l_cfgitcm (.D(CFGITCMEN), .CLK(HRESETN), .SRB(HRESETN), .Q(cfgitcm_ff));

always @ (*) begin
  HSEL_ITCM = 1'b0;
  HSEL_SRAM = 1'b0;
  if (HADDR >= CODE_LOW_ADDR_MIN & HADDR <= CODE_LOW_ADDR_MAX) begin
    if (cfgitcm_ff)
      HSEL_ITCM = 1'b1;
    else
      HSEL_SRAM = 1'b1;
  end
  else if (HADDR >= CODE_HIGH_ADDR_MIN & HADDR <= CODE_HIGH_ADDR_MAX) begin
    if (cfgitcm_ff)
      HSEL_SRAM = 1'b1;
    else
      HSEL_ITCM = 1'b1;
  end
end

assign HREADY = (cfgitcm_ff) ? HREADY_ITCM: HREADY_SRAM;
assign HRDATA = (cfgitcm_ff) ? HRDATA_ITCM: HRDATA_SRAM;
assign HRESP  = (cfgitcm_ff) ? HRESP_ITCM:  HRESP_SRAM;

endmodule
