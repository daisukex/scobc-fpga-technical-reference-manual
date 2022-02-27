//-----------------------------------------------
// Space Cubics SC-OBC-A1
// SC-OBC-A1 Output Select
// Module: scobca1_outsel
//-----------------------------------------------
// Copyright © 2021 Space Cubics, LLC.
//-----------------------------------------------

module scobca1_outsel # (
  parameter USER1_MODE = 0,
  parameter USER2_MODE = 0
) (
  input REF_CLK,
  input REF_RSTB,
  input PLLLOCK,
  input PLLCLK96M,
  input PLLCLK48M,
  input PLLCLK19M2,
  input USERCLK1,
  input USERCLK2,
  input [1:0] REG_CLKMODE,
  output SYS_CLK,
  output MAXI_CLK,
  output USER_CLK1,
  output USER_CLK2,
  output ULPI_REFCLK
);

wire clksel;

BUFGCTRL # (
  .INIT_OUT(0),
  .PRESELECT_I0("FALSE"),
  .PRESELECT_I1("FALSE")
) clkmux48m (
  .CE0(1'b1),           .CE1(PLLLOCK),
  .IGNORE0(1'b0),       .IGNORE1(1'b0),
  .I0(REF_CLK),         .I1(PLLCLK48M),
  .S0(~REG_CLKMODE[0]), .S1(REG_CLKMODE[0]),
  .O(clksel)
);

BUFGCTRL # (
  .INIT_OUT(0),
  .PRESELECT_I0("FALSE"),
  .PRESELECT_I1("FALSE")
) clkmux96m (
  .CE0(1'b1),           .CE1(PLLLOCK),
  .IGNORE0(1'b0),       .IGNORE1(1'b0),
  .I0(clksel),          .I1(PLLCLK96M),
  .S0(~REG_CLKMODE[1]), .S1(REG_CLKMODE[1]),
  .O(SYS_CLK)
);

if (USER1_MODE == 1) begin
BUFGCTRL # (
  .INIT_OUT(0),
  .PRESELECT_I0("FALSE"),
  .PRESELECT_I1("FALSE")
) clkmuxuclk1 (
  .CE0(1'b1),           .CE1(PLLLOCK),
  .IGNORE0(1'b0),       .IGNORE1(1'b0),
  .I0(REF_CLK),         .I1(USERCLK1),
  .S0(~REG_CLKMODE[0]), .S1(REG_CLKMODE[0]),
  .O(USER_CLK1)
);
end
else begin
assign USER_CLK1 = USERCLK1;
end

if (USER2_MODE == 1) begin
BUFGCTRL # (
  .INIT_OUT(0),
  .PRESELECT_I0("FALSE"),
  .PRESELECT_I1("FALSE")
) clkmuxuclk2 (
  .CE0(1'b1),           .CE1(PLLLOCK),
  .IGNORE0(1'b0),       .IGNORE1(1'b0),
  .I0(REF_CLK),         .I1(USERCLK2),
  .S0(~REG_CLKMODE[0]), .S1(REG_CLKMODE[0]),
  .O(USER_CLK2)
);
end
else begin
assign USER_CLK2 = USERCLK2;
end

assign MAXI_CLK = SYS_CLK;
assign ULPI_REFCLK = PLLCLK19M2;

endmodule
