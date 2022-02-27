//-----------------------------------------------
// Space Cubics Standard Verilog Library
//  Triple modular redundancy Synchronizer and Latch
//  Module: tmr_synclatch
//-----------------------------------------------
// Copyright © 2022 Space Cubics, LLC.
//-----------------------------------------------

module tmr_synclatch # (
  parameter SYNCC = 2,   // Synchronizer F/F Count
  parameter SRVAL = 1'b0 // SetReset Value
) (
  input D_AS,
  input CLK,
  input SRB,
  output reg Q_SY
);

(* dont_touch = "yes" *) reg [SYNCC-1:0] sync_d_as;
(* dont_touch = "yes" *) reg [2:0] d_latch;

always @ (posedge CLK or negedge SRB) begin
  if (!SRB)
    sync_d_as <= {SYNCC{SRVAL}};
  else
    sync_d_as <= {sync_d_as[SYNCC-2:0], D_AS};
end

always @ (posedge CLK or negedge SRB) begin
  if (!SRB)
    d_latch <= {3{SRVAL}};
  else if (sync_d_as == {SYNCC{1'b0}})
    d_latch <= 3'b000;
  else if (sync_d_as == {SYNCC{1'b1}})
    d_latch <= 3'b111;
end

always @ (*) begin
  case (d_latch)
    3'b011: Q_SY = 1'b1;
    3'b101: Q_SY = 1'b1;
    3'b110: Q_SY = 1'b1;
    3'b111: Q_SY = 1'b1;
    default: Q_SY = 1'b0;
  endcase
end

endmodule
