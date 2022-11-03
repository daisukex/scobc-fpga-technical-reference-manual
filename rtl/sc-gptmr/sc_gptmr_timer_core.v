//-----------------------------------------------
// Space Cubics General Purpose Timer
// Module: sc_gptmr_timer_core
//  General Purpose Timer Timer Core
//-----------------------------------------------
// Copyright © 2022 Space Cubics, LLC.
//-----------------------------------------------
module sc_gptmr_timer_core # (
  parameter COMPARE_CHANNEL = 8,
  parameter TIMER_BIT_WIDTH = 32,
  parameter PRESCALER_BIT_WIDTH = 16
) (
  // System Interface
  input CLK,
  input RSTB,

  // Register Interface
  input ENABLE,
  input RESET,
  input RUN_MODE,
  input ENB_MODE,
  input [2*COMPARE_CHANNEL-1:0] OP_MODE,
  input UPDATE,
  input [TIMER_BIT_WIDTH-1:0] UPDATE_VALUE,
  input [PRESCALER_BIT_WIDTH-1:0] PRESCALER,
  input [32*COMPARE_CHANNEL-1:0] COMPARE_VALUE,
  output reg [31:0] COUNT,

  // Interrupt Signal
  output reg ROLLOVER_INT,
  output reg [COMPARE_CHANNEL-1:0] COMPARE_INT_REQ,
  input [COMPARE_CHANNEL-1:0] COMPARE_INT_ACK
);

integer ch;
reg [COMPARE_CHANNEL-1:0] compare_match;

// Timer Enable Rise Edge
reg en_p1;
wire en_redge;
always @ (posedge CLK) begin
  if (!RSTB | RESET)
    en_p1 <= 0;
  else
    en_p1 <= ENABLE;
end
assign en_redge = ~en_p1 & ENABLE;

// Timer
reg [PRESCALER_BIT_WIDTH-1:0] pcnt;
wire pcnt_update = (pcnt >= PRESCALER);
always @ (posedge CLK) begin
  if (!RSTB | RESET |
     (ENB_MODE & en_redge)) begin
    pcnt <= 0;
    COUNT <= 0;
  end
  else if (UPDATE) begin
    pcnt <= 0;
    COUNT <= UPDATE_VALUE;
  end
  else if (ENABLE) begin
    pcnt <= pcnt + 1;
    if (pcnt_update) begin
      pcnt <= 0;
      COUNT <= COUNT + 1;
    end
    if (!RUN_MODE & compare_match[0])
      COUNT <= 0;
  end
end

// Compare Match
always @ (*) begin
  for (ch=0; ch<COMPARE_CHANNEL; ch=ch+1) begin
    if ((COMPARE_VALUE[32*ch +:32] != 32'h0000_0000) &
        (pcnt == 0) & (COUNT == COMPARE_VALUE[32*ch +:32]))
      compare_match[ch] = 1'b1;
    else
      compare_match[ch] = 1'b0;
  end
end

// Intrerrupt Acknowledge signal Synchronizer
reg [COMPARE_CHANNEL-1:0] sync_comp_int_ack;
reg [1:0] comp_int_ack_p [0:COMPARE_CHANNEL-1];
always @ (posedge CLK) begin
  if (!RSTB | RESET) begin
    sync_comp_int_ack <= 0;
    for (ch=0; ch<COMPARE_CHANNEL; ch=ch+1) begin
      comp_int_ack_p[ch] <= 2'b00;
    end
  end
  else begin
    for (ch=0; ch<COMPARE_CHANNEL; ch=ch+1) begin
      sync_comp_int_ack[ch] <= COMPARE_INT_ACK[ch];
      comp_int_ack_p[ch] <= {comp_int_ack_p[ch][0], sync_comp_int_ack[ch]};
    end
  end
end

// Interrupt Signal
always @ (posedge CLK) begin
  if (!RSTB | RESET) begin
    ROLLOVER_INT <= 0;
    COMPARE_INT_REQ <= 0;
  end
  else begin
    ROLLOVER_INT <= 0;
    if (ENABLE) begin
      if (pcnt_update & &COUNT)
        ROLLOVER_INT <= 1;
      for (ch=0; ch<COMPARE_CHANNEL; ch=ch+1) begin
        // Toggle Interrupt
        if (OP_MODE[2*ch +:2] == 2'b01) begin
          if (compare_match[ch])
            COMPARE_INT_REQ[ch] <= ~COMPARE_INT_REQ[ch];
        end
        // Pulse Interrupt
        else if (OP_MODE[2*ch +:2] == 2'b10) begin
          if (compare_match[ch])
            COMPARE_INT_REQ[ch] <= 1'b1;
          else
            COMPARE_INT_REQ[ch] <= 1'b0;
        end
        // Handshake Interrupt
        else if (OP_MODE[2*ch +:2] == 2'b11) begin
          if (COMPARE_INT_REQ[ch]) begin
            if (~comp_int_ack_p[ch][1] & comp_int_ack_p[ch][0])
            COMPARE_INT_REQ[ch] <= 1'b0;
          end
          else if (compare_match[ch])
            COMPARE_INT_REQ[ch] <= 1'b1;
        end
      end
    end
  end
end

endmodule
