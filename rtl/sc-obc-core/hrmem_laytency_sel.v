//-----------------------------------------------
// Module: hrmem_latency_sel
//  HRMEM RD_LTCY_MODE signal selector
//-----------------------------------------------
// Copyright © 2022 Space Cubics, LLC.
//-----------------------------------------------

module hrmem_latency_sel (
  input SYS_CLK,
  input SYS_RSTB,
  input [1:0] CLKMODE,
  input CMC_REQ,
  input CMC_ACK,
  output reg LATENCY_SEL
);

reg sync_cmc_ack;
reg cmc_req_p;
reg [1:0] cmc_ack_p;
always @ (posedge SYS_CLK) begin
  sync_cmc_ack <= CMC_ACK;
  cmc_ack_p <= {cmc_ack_p[0], sync_cmc_ack};
  cmc_req_p <= CMC_REQ;
end

reg [1:0] l_clkmode;
always @ (posedge SYS_CLK) begin
  if (!SYS_RSTB) begin
    l_clkmode <= 2'b10;
    LATENCY_SEL <= 1;
  end
  else begin
    if (!cmc_ack_p[1] & cmc_ack_p[0])
      l_clkmode <= CLKMODE;

    if (l_clkmode == 2'b10 & CLKMODE != 2'b10) begin
      if (!cmc_ack_p[1] & cmc_ack_p[0])
        LATENCY_SEL <= 0;
    end
    else if (l_clkmode != 2'b10 & CLKMODE == 2'b10) begin
      if (!cmc_req_p & CMC_REQ)
        LATENCY_SEL <= 1;
    end
  end
end

endmodule
