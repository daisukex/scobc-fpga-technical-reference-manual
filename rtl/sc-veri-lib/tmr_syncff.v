//-----------------------------------------------
// Space Cubics Standard Verilog Library
//  Triple modular redundancy Synchronizer F/F
//  Module: tmr_syncff
//-----------------------------------------------
// Copyright © 2021 Space Cubics, LLC.
//-----------------------------------------------

module tmr_syncff # (
  parameter SYNCC = 2,   // Synchronizer F/F Count
  parameter SRVAL = 1'b0 // SetReset Value
) (
  input D_AS,
  input CLK,
  input SRB,
  output reg Q_SY
);

(* dont_touch = "yes" *) reg [SYNCC-1:0] sync_0;
(* dont_touch = "yes" *) reg [SYNCC-1:0] sync_1;
(* dont_touch = "yes" *) reg [SYNCC-1:0] sync_2;

always @ (posedge CLK or negedge SRB) begin
  if (!SRB) begin
    sync_0 <= {SYNCC{SRVAL}};
    sync_1 <= {SYNCC{SRVAL}};
    sync_2 <= {SYNCC{SRVAL}};
  end
  else begin
    sync_0 <= {sync_0[SYNCC-2:0], D_AS};
    sync_1 <= {sync_1[SYNCC-2:0], D_AS};
    sync_2 <= {sync_2[SYNCC-2:0], D_AS};
  end
end

always @ (*) begin
  case ({sync_2[SYNCC-1], sync_1[SYNCC-1], sync_0[SYNCC-1]})
    3'b011: Q_SY = 1'b1;
    3'b101: Q_SY = 1'b1;
    3'b110: Q_SY = 1'b1;
    3'b111: Q_SY = 1'b1;
    default: Q_SY = 1'b0;
  endcase
end

endmodule
