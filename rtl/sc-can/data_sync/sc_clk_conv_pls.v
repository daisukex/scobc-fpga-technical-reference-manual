//-----------------------------------------------
// Module: sc_clk_conv_pls
//  Space Cubics Clock Converter (Pulse) Module
//-----------------------------------------------
// Copyright © 2021 Space Cubics, LLC.
//-----------------------------------------------
module sc_clk_conv_pls # (
  parameter P_POLARITY = 1 // 1: Positive 0: Negative
) (
  input IN_RSTB,
  input IN_CLK,
  input IN_PLS,

  input SYNC_RSTB,
  input SYNC_CLK,
  output reg SYNC_PLS
);

wire w_pls_act;
reg r_pin_latch;
reg r_pls_req;
wire w_pls_req_mask;
reg [1:0] r_pls_ack_sync;

reg [2:0] r_pls_req_sync;

assign w_pls_act = (IN_PLS == P_POLARITY);

always @ (posedge IN_CLK or negedge IN_RSTB) begin
  if (!IN_RSTB) begin
    r_pin_latch <= 0;
  end else begin
    if (w_pls_req_mask & w_pls_act)
      r_pin_latch <= 1'b1;
    else if (~w_pls_req_mask)
      r_pin_latch <= 1'b0;
  end
end

always @ (posedge IN_CLK or negedge IN_RSTB) begin
  if (!IN_RSTB) begin
    r_pls_req <= 0;
  end else begin
    if (~w_pls_req_mask & (w_pls_act | r_pin_latch))
      r_pls_req <= 1'b1;
    else if (r_pls_ack_sync[1])
      r_pls_req <= 1'b0;
  end
end

assign w_pls_req_mask = (r_pls_req | r_pls_ack_sync[1]);

always @ (posedge IN_CLK or negedge IN_RSTB) begin
  if (!IN_RSTB) begin
    r_pls_ack_sync <= 0;
  end else begin
    r_pls_ack_sync <= {r_pls_ack_sync[0], r_pls_req_sync[1]};
  end
end

always @ (posedge SYNC_CLK or negedge SYNC_RSTB) begin
  if (!SYNC_RSTB) begin
    r_pls_req_sync <= 0;
  end else begin
    r_pls_req_sync <= {r_pls_req_sync[1:0], r_pls_req};
  end
end

always @ (posedge SYNC_CLK or negedge SYNC_RSTB) begin
  if (!SYNC_RSTB) begin
    SYNC_PLS <= ~P_POLARITY;
  end else begin
    SYNC_PLS <= (r_pls_req_sync[1] & ~r_pls_req_sync[2]) ^ ~P_POLARITY;
  end
end

endmodule
