//-----------------------------------------------
// Module: sc_clk_conv_lvl
//  Space Cubics Clock Converter (Level) Module
//-----------------------------------------------
// Copyright © 2021 Space Cubics, LLC.
//-----------------------------------------------
module sc_clk_conv_lvl # (
  parameter P_INIT_VAL = 0
) (
  input IN_RSTB,
  input IN_CLK,
  input IN_SIG,

  input SYNC_RSTB,
  input SYNC_CLK,
  output reg SYNC_SIG
);

reg r_sig_p1;

reg r_sig_sync;

always @ (posedge IN_CLK or negedge IN_RSTB) begin
  if (!IN_RSTB) begin
    r_sig_p1 <= P_INIT_VAL;
  end else begin
    r_sig_p1 <= IN_SIG;
  end
end

always @ (posedge SYNC_CLK or negedge SYNC_RSTB) begin
  if (!SYNC_RSTB) begin
    r_sig_sync <= P_INIT_VAL;
    SYNC_SIG   <= P_INIT_VAL;
  end else begin
    r_sig_sync <= r_sig_p1;
    SYNC_SIG   <= r_sig_sync;
  end
end

endmodule
