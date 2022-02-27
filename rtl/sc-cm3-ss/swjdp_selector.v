//-----------------------------------------------
// Module: swjdp_selector
//  Space Cubics OBC SWJ-DP Selector
//-----------------------------------------------
// Copyright © 2021 Space Cubics, LLC.
//-----------------------------------------------

module swjdp_selector (
  // FPGA External Port
  input NTRST,
  input TDI,
  input SWCLKTCK,
  inout SWDIOTMS,
  // CPU Port
  output TDOSWO,
  output NTRST_OUT,
  output TDI_OUT,
  output SWCLKTCK_OUT,
  output SWDITMS_OUT,
  input SWDO_IN,
  input SWDOEN_IN,
  input JTAGNSW_IN,
  input TDO_IN,
  input SWV_IN,
  input NTDOEN_IN
);

wire tdoswo_oen;
wire tdoswo_data;

assign NTRST_OUT = NTRST;
assign TDI_OUT = TDI;
assign SWCLKTCK_OUT = SWCLKTCK;
assign SWDIOTMS = (SWDOEN_IN) ? SWDO_IN: 1'bz;
assign SWDITMS_OUT = SWDIOTMS;
assign tdoswo_oen = (JTAGNSW_IN) ? ~NTDOEN_IN: 1'b1;
assign tdoswo_data = (JTAGNSW_IN) ? TDO_IN: SWV_IN;
assign TDOSWO = (tdoswo_oen) ? tdoswo_data: 1'bz;

endmodule
