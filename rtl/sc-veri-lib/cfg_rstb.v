//-----------------------------------------------
// Space Cubics Standard IP Core
//  Configuration Reset for Xilinx 7 series
//  Module: cfg_rstb
//-----------------------------------------------
// Copyright © 2021 Space Cubics, LLC.
//-----------------------------------------------

module cfg_rstb # (
  parameter SREG_NUM = 4
) (
  input CLK,
  output CFG_RSTB
);

reg [SREG_NUM-1: 0] rstsf = 0;
(* dont_touch = "yes" *) reg [2:0] rsthd = 0;

always @ (posedge CLK) begin
  rstsf <= {rstsf[SREG_NUM-2: 0], 1'b1};
  if (rstsf[SREG_NUM-1])
    rsthd <= 3'b111;
end

reg rstb_hold;
always @ (*) begin
  case (rsthd)
    3'b011:  rstb_hold = 1'b1;
    3'b101:  rstb_hold = 1'b1;
    3'b110:  rstb_hold = 1'b1;
    3'b111:  rstb_hold = 1'b1;
    default: rstb_hold = 1'b0;
  endcase
end

assign CFG_RSTB = rstb_hold | rstsf[SREG_NUM-1];

endmodule
