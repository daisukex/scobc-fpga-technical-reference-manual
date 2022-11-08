//-----------------------------------------------
// Space Cubics OBC FPGA System Monitor
//  Clock State Checker
//  Module: clk_checker
//-----------------------------------------------
// Copyright © 2022 Space Cubics, LLC.
//-----------------------------------------------

module clk_checker # (
  parameter DIV_COUNT = 16,
  parameter DIV_BUS_WIDTH = 4,
  parameter CHK_LIMIT = 255,
  parameter CHK_BUS_WIDTH = 8
) (
  input TARGET_CLK,
  input HCLK,
  input HRESETN,
  output reg CLK_STATE,
  output reg CLK_STOP
);

reg tclk_toggle = 0;
reg [DIV_BUS_WIDTH-1:0] tclk_count = 0;
always @ (posedge TARGET_CLK) begin
  if (tclk_count == 0) begin
    tclk_toggle <= ~tclk_toggle;
    tclk_count <= DIV_COUNT;
  end
  else
    tclk_count <= tclk_count - 1;
end

reg sync_clk;
reg [1:0] tclk_p;
always @ (posedge HCLK) begin
  if (!HRESETN) begin
    sync_clk <= 1'b0;
    tclk_p <= 2'b00;
  end
  else begin
    sync_clk <= tclk_toggle;
    tclk_p <= {tclk_p[0], sync_clk};
  end
end

reg [CHK_BUS_WIDTH-1:0] mclk_count;
always @ (posedge HCLK) begin
  if (!HRESETN) begin
    mclk_count <= 0;
    CLK_STATE <= 1'b0;
    CLK_STOP <= 1'b0;
  end
  else begin
    CLK_STOP <= 1'b0;
    mclk_count <= mclk_count + 1;
    if (tclk_p[1] != tclk_p[0]) begin
      mclk_count <= 0;
      CLK_STATE <= 1'b1;
    end
    else if (mclk_count == CHK_LIMIT-1) begin
      mclk_count <= 0;
      CLK_STATE <= 1'b0;
      CLK_STOP <= 1'b1;
    end
  end
end

endmodule
