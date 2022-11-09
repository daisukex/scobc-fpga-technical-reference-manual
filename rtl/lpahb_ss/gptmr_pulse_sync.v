//-----------------------------------------------
// Module: gptmr_pulse_sync
//  Space Cubics GPTMR Pulse Synchronizer
//-----------------------------------------------
// Copyright © 2022 Space Cubics, LLC.
//-----------------------------------------------

module gptmr_pulse_sync (
  input TMR_CLK,
  input TMR_RSTB,
  input HCLK,
  input HRESETN,
  input I_PULSE,
  output reg O_PULSE
);

reg i_1p;
reg i_2cycle;
always @ (posedge TMR_CLK) begin
  if (!TMR_RSTB) begin
    i_1p <= 1'b0;
    i_2cycle <= 1'b0;
  end
  else begin
    i_1p <= I_PULSE;
    i_2cycle <= I_PULSE | i_1p;
  end
end

reg [2:0] sync_o;
always @ (posedge HCLK) begin
  if (!HRESETN) begin
    sync_o <= 0;
    O_PULSE <= 1'b0;
  end
  else begin
    sync_o <= {sync_o[1:0], i_2cycle};
    O_PULSE <= ~sync_o[2] & sync_o[1];
  end
end

endmodule
