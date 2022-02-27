//-----------------------------------------------
// Space Cubics Standard IP Core
//  Majority Vote
//  Module: mvote
//-----------------------------------------------
// Copyright © 2021 Space Cubics, LLC.
//-----------------------------------------------

module mvote (
  input [2:0] IN,
  output reg OUT
);

always @ (*) begin
  case (IN)
    3'b011: OUT = 1'b1;
    3'b101: OUT = 1'b1;
    3'b110: OUT = 1'b1;
    3'b111: OUT = 1'b1;
    default: OUT = 1'b0;
  endcase
end

endmodule
