//-----------------------------------------------
// Module: sc_clk_conv_bus
//  Space Cubics Clock Converter (Bus) Module
//-----------------------------------------------
// Copyright © 2021 Space Cubics, LLC.
//-----------------------------------------------
module sc_clk_conv_bus # (
  parameter P_USE_VLD  = 0,
  parameter P_DT_WIDTH = 1
) (
  input IN_RSTB,
  input IN_CLK,
  input IN_VALID,
  input [P_DT_WIDTH-1:0] IN_DATA,

  input SYNC_RSTB,
  input SYNC_CLK,
  output reg SYNC_VALID,
  output reg [P_DT_WIDTH-1:0] SYNC_DATA
);

reg r_valid_p1;
reg [P_DT_WIDTH-1:0] r_data_p1;
reg r_data_chg;
wire w_conv_pls;

wire w_conv_pls_sync;

always @ (posedge IN_CLK or negedge IN_RSTB) begin
  if (!IN_RSTB) begin
    r_valid_p1 <= 0;
    r_data_p1  <= 0;
    r_data_chg <= 0;
  end else begin
    r_valid_p1 <= IN_VALID;
    r_data_p1  <= IN_DATA;
    r_data_chg <= IN_DATA != r_data_p1;
  end
end

assign w_conv_pls = (P_USE_VLD) ? r_valid_p1 :
                                  r_data_chg ;

sc_clk_conv_pls # (
  .P_POLARITY(1) // 1: Positive 0: Negative
) bus_conv_req (
  .IN_RSTB(IN_RSTB),        // input
  .IN_CLK(IN_CLK),          // input
  .IN_PLS(w_conv_pls),      // input
  .SYNC_RSTB(SYNC_RSTB),    // input
  .SYNC_CLK(SYNC_CLK),      // input
  .SYNC_PLS(w_conv_pls_sync) // output
);

always @ (posedge SYNC_CLK or negedge SYNC_RSTB) begin
  if (!SYNC_RSTB) begin
    SYNC_VALID <= 0;
    SYNC_DATA  <= 0;
  end else begin
    SYNC_VALID <= w_conv_pls_sync;
    if (w_conv_pls_sync)
      SYNC_DATA <= r_data_p1;
  end
end

endmodule
