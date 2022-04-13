//-----------------------------------------------
// Space Cubics Standard IP Core
//  Triple modular redundancy Flip Flop
//  Module: sclib_tmr_ff
//-----------------------------------------------
// Copyright © 2021 Space Cubics, LLC.
//-----------------------------------------------

module sclib_tmr_ff # (
  parameter DW = 1,      // Data Width
  parameter SRVAL = 1'b0 // SetReset Value
) (
  input [DW-1:0] D,
  input CLK,
  input SRB,
  output reg [DW-1:0] Q
);

(* dont_touch = "yes" *) reg [DW-1:0] d_tmr_0;
(* dont_touch = "yes" *) reg [DW-1:0] d_tmr_1;
(* dont_touch = "yes" *) reg [DW-1:0] d_tmr_2;

always @ (posedge CLK or negedge SRB) begin
  if (!SRB) begin
    d_tmr_0 <= SRVAL;
    d_tmr_1 <= SRVAL;
    d_tmr_2 <= SRVAL;
  end
  else begin
    d_tmr_0 <= D;
    d_tmr_1 <= D;
    d_tmr_2 <= D;
  end
end

genvar b;
generate
  for (b=0; b<DW; b=b+1) begin: mvote
    always @ (*) begin
      case ({d_tmr_2[b], d_tmr_1[b], d_tmr_0[b]})
        3'b011: Q[b] = 1'b1;
        3'b101: Q[b] = 1'b1;
        3'b110: Q[b] = 1'b1;
        3'b111: Q[b] = 1'b1;
        default: Q[b] = 1'b0;
      endcase
    end
  end
endgenerate

endmodule
