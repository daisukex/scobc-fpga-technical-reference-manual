//-----------------------------------------------
// Space Cubics SC-OBC-A1
// SC-OBC-A1 Clock State
// Module: scobca1_state
//-----------------------------------------------
// Copyright © 2021 Space Cubics, LLC.
//-----------------------------------------------

module scobca1_state (
  input REF_CLK,
  input REF_RSTB,
  input [1:0] CLKMODE,
  input CMC_REQ,
  output reg CMC_ACK,
  output [1:0] REG_CLKMODE,
  input PLLLOCK,
  output reg PLLPWRDWN,
  input SLEEPING,
  output SLEEPHOLDREQN,
  input SLEEPHOLDACKN
);

localparam SYNC_BIT = 6;
localparam SLEEP_SYNC_BIT = 5;
localparam SLEEP_COUNT_BIT = 8;
localparam SLEEPHOLD_SYNC_BIT = 5;

// Clock Mode Signal
// --------------------------------------------------
reg sync_cmc_req;
reg [SYNC_BIT-1:0] cmc_req_p;
reg clkmode_active;
always @ (posedge REF_CLK or negedge REF_RSTB) begin
  if (!REF_RSTB) begin
    sync_cmc_req <= 1'b0;
    cmc_req_p <= 0;
    CMC_ACK <= 1'b0;
    clkmode_active <= 1'b0;
  end
  else begin
    sync_cmc_req <= CMC_REQ;
    cmc_req_p <= {cmc_req_p[SYNC_BIT-2:0], sync_cmc_req};
    if (cmc_req_p[1:0] == 2'b01)
      clkmode_active <= 1'b0;
    else if (cmc_req_p == {SYNC_BIT{1'b1}}) begin
      CMC_ACK <= 1'b1;
      clkmode_active <= 1'b1;
    end
    else
      CMC_ACK <= 1'b0;
  end
end

reg [1:0] next_clkmode;
always @ (*) begin
  if (cmc_req_p[2:1] == 2'b01)
    next_clkmode = CLKMODE;
end

tmr_ff # (.DW(2), .SRVAL(2'b00))
clkmode_ff (.D(next_clkmode), .CLK(REF_CLK), .SRB(REF_RSTB), .Q(REG_CLKMODE));

// PLL Lock Synchronizer
// --------------------------------------------------
reg sync_plllock;
reg [2:0] plllock_p;
always @ (posedge REF_CLK or negedge REF_RSTB) begin
  if (!REF_RSTB) begin
    sync_plllock <= 1'b0;
    plllock_p <= 0;
  end
  else begin
    sync_plllock <= PLLLOCK;
    plllock_p <= {plllock_p[1:0], sync_plllock};
  end
end

// SLEEPING detect
// --------------------------------------------------
reg sync_sleeping;
reg [SLEEP_SYNC_BIT-1:0] sleeping_p;
reg [SLEEP_COUNT_BIT-1:0] sleeping_count;
wire sleep_valid;
reg sleep_hold_data;
always @ (posedge REF_CLK or negedge REF_RSTB) begin
  if (!REF_RSTB) begin
    sync_sleeping <= 1'b0;
    sleeping_p <= 0;
    sleeping_count <= 0;
  end
  else begin
    sync_sleeping <= SLEEPING;
    sleeping_p <= {sleeping_p[SLEEP_SYNC_BIT-2:0], sync_sleeping};
    if (sleeping_p[SLEEP_SYNC_BIT-1:SLEEP_SYNC_BIT-2] == 2'b11) begin
      if (!sleep_hold_data)
        sleeping_count <= sleeping_count + 1;
    end
    else
      sleeping_count <= 0;
  end
end

always @ (*) begin
  if (sleeping_count == {SLEEP_COUNT_BIT{1'b0}})
    sleep_hold_data = 1'b0;
  else if (sleeping_count == {SLEEP_COUNT_BIT{1'b1}})
    sleep_hold_data = 1'b1;
  else
    sleep_hold_data = sleep_valid;
end
tmr_ff # (.DW(1), .SRVAL(2'b00))
sleep_hold (.D(sleep_hold_data), .CLK(REF_CLK), .SRB(REF_RSTB), .Q(sleep_valid));

// SLEEPHOLDREQn control
// --------------------------------------------------
reg holdreq_data;
always @ (*) begin
  if (SLEEPHOLDREQN & sleep_valid)
    holdreq_data = 1'b0;
  else if (!SLEEPHOLDREQN & !sleep_valid & (plllock_p[2] | REG_CLKMODE == 2'b00))
    holdreq_data = 1'b1;
  else
    holdreq_data = SLEEPHOLDREQN;
end

tmr_ff # (.DW(1), .SRVAL(1'b1))
hold_req  (.D(holdreq_data), .CLK(REF_CLK), .SRB(REF_RSTB), .Q(SLEEPHOLDREQN));

// SLEEPHOLDACKn detect
// --------------------------------------------------
reg sync_sleepholdack;
reg [SLEEPHOLD_SYNC_BIT-1:0] sleepholdack_p;
wire sleepholdack_data = (sleepholdack_p == 0);
wire holdack_valid;
always @ (posedge REF_CLK or negedge REF_RSTB) begin
  if (!REF_RSTB) begin
    sync_sleepholdack <= 1'b1;
    sleepholdack_p <= {SLEEPHOLD_SYNC_BIT{1'b1}};
  end
  else begin
    sync_sleepholdack <= SLEEPHOLDACKN;
    sleepholdack_p <= {sleepholdack_p[SLEEPHOLD_SYNC_BIT-2:0], sync_sleepholdack};
  end
end
tmr_ff # (.DW(1), .SRVAL(1'b1))
holdack  (.D(sleepholdack_data), .CLK(REF_CLK), .SRB(REF_RSTB), .Q(holdack_valid));

// Clock Control State Machine
// --------------------------------------------------
reg [1:0] next_state;
wire [1:0] pll_state;
parameter SPEND  = 2'b00,
          LWAIT  = 2'b01,
          ULWAIT = 2'b10,
          RUN    = 2'b11;

tmr_ff # (.DW(2), .SRVAL(1'b0))
n_state_ff (.D(next_state), .CLK(REF_CLK), .SRB(REF_RSTB), .Q(pll_state));

always @ (posedge REF_CLK or negedge REF_RSTB) begin
  if (!REF_RSTB) begin
    next_state <= SPEND;
    PLLPWRDWN <= 1'b1;
  end

  // Suspend State
  else if (pll_state == SPEND) begin
    if (!sleep_valid & clkmode_active) begin
      if (REG_CLKMODE != 2'b00) begin
        next_state <= LWAIT;
        PLLPWRDWN <= 1'b0;
      end
    end
  end

  // Lock Wait State
  else if (pll_state == LWAIT) begin
    if (plllock_p[2])
      next_state <= RUN;
  end

  // Unlock Wait State
  else if (pll_state == ULWAIT) begin
    if (!plllock_p[2])
      next_state <= SPEND;
  end

  // RUN State
  else if (pll_state == RUN) begin
    if (sleep_valid & holdack_valid) begin
      next_state <= ULWAIT;
      PLLPWRDWN <= 1'b1;
    end
    else if (clkmode_active) begin
      if (REG_CLKMODE == 2'b00) begin
        next_state <= ULWAIT;
        PLLPWRDWN <= 1'b1;
      end
    end
  end
end

endmodule
