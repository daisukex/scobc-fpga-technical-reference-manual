//-----------------------------------------------
// Space Cubics OBC Core
//  eFuse Register
//  Module: efuse_reg.v
//-----------------------------------------------
// Copyright © 2022 Space Cubics, LLC.
//-----------------------------------------------

module efuse_reg (
  input SYS_CLK,
  input SYS_RSTB,
  output reg [56:0] FUSE_DNA,
  output [31:0] FUSE_USR
);

reg [5:0] count;
reg read;
reg shift;
wire dout;
always @ (posedge SYS_CLK) begin
  if (!SYS_RSTB) begin
    count <= 0;
    read  <= 1'b1;
    shift <= 1'b0;
  end
  else if (count < 58) begin
    FUSE_DNA <= {dout, FUSE_DNA[56:1]};
    count <= count + 1;
    if (count == 0) begin
      read  <= 0;
      shift <= 1;
    end
    else if (count == 57)
      shift <= 0;
  end
end

DNA_PORT # (
  .SIM_DNA_VALUE(57'h014C5296C06A854)
) dna_port (
  .DIN(1'b0),
  .READ(read),
  .SHIFT(shift),
  .CLK(SYS_CLK),
  .DOUT(dout)
);

EFUSE_USR # (
  .SIM_EFUSE_VALUE(32'h1234_5678)
) efuse_usr (
  .EFUSEUSR(FUSE_USR)
);

endmodule
