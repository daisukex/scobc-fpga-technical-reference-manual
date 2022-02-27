//-----------------------------------------------
// Space Cubics Standard IP Core
//  Reset Synchronizer
//  Module: sclib_rstb_sync
//-----------------------------------------------
// Copyright © 2021 Space Cubics, LLC.
//-----------------------------------------------

module sclib_rstb_sync # (
  parameter SREG_NUM = 4
) (
  input CLK,
  input RSTB_IN,
  output RSTB_OUT
);

reg [SREG_NUM-1:0] rstsf;
always @ (posedge CLK or negedge RSTB_IN) begin
  if (!RSTB_IN)
    rstsf <= 0;
  else
    rstsf <= {rstsf[SREG_NUM-2: 0], 1'b1};
end

(* dont_touch = "yes" *) reg [2:0] rsthd;
always @ (posedge CLK or negedge RSTB_IN) begin
  if (!RSTB_IN)
    rsthd <= 0;
  else
    rsthd <= {rsthd[1:0], rstsf[SREG_NUM-1]};
end

assign RSTB_OUT = |rsthd;

endmodule
