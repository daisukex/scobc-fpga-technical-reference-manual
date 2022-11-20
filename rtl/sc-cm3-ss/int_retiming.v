//-----------------------------------------------
// Module: isr_retiming
//  Cortex-M3 ISR Retiming
//-----------------------------------------------
// Copyright © 2022 Space Cubics, LLC.
//-----------------------------------------------

module isr_retiming # (
  parameter NUM_OF_INTERRUPT = 12
) (
  input SYS_CLK,
  input [NUM_OF_INTERRUPT-1:0] IN_ISR,
  output reg [NUM_OF_INTERRUPT-1:0] OUT_ISR
);

reg [NUM_OF_INTERRUPT-1:0] isr_retim;
always @ (posedge SYS_CLK) begin
  isr_retim <= IN_ISR;
  OUT_ISR <= isr_retim;
end

endmodule
