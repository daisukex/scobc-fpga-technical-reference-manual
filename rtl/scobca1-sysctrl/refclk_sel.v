//-----------------------------------------------
// Space Cubics SCSAT1
// Referance Clock Selector
// Module: refclk_sel
//-----------------------------------------------
// Copyright © 2021 Space Cubics, LLC.
//-----------------------------------------------

module refclk_sel (
  input SYSCLK1,
  output SYSCLK1_EN,
  input SYSCLK2,
  output SYSCLK2_EN,
  output REFCLK,
  output REFCLK_SEL,
  output REFCLK_VALID
);

parameter CLK1_DTCT_CNT_V = 16;
parameter CLK2_DTCT_CNT_V = 24;
parameter CLK_DTCT_CNT_W = 5;

wire [2:1] clkin;
assign clkin[1] = SYSCLK1;
assign clkin[2] = SYSCLK2;
wire [2:1] cfgdn_rstb_clk;
reg [CLK_DTCT_CNT_W-1:0] clk_d_count [1:2];
wire [2:1] clk_valid;
reg [2:0] clk_d_count_en1 = 3'b111;
reg [2:0] clk_d_count_en2 = 3'b111;
wire [2:1] clk_d_count_en;

genvar clkn;
generate
  for(clkn=1; clkn<=2; clkn=clkn+1) begin: clk_detect
    // Clock Detect Counter
    cfg_rstb cfg_rstb (
      .CLK(clkin[clkn]),
      .CFG_RSTB(cfgdn_rstb_clk[clkn])
    );

    always @ (negedge cfgdn_rstb_clk[clkn] or posedge clkin[clkn]) begin
      if (!cfgdn_rstb_clk[clkn])
        clk_d_count[clkn] <= 0;
      else if (clk_d_count_en[clkn]) begin
        if ((clkn==1 & clk_d_count[clkn] != CLK1_DTCT_CNT_V-1) |
            (clkn==2 & clk_d_count[clkn] != CLK2_DTCT_CNT_V-1))
          clk_d_count[clkn] <= clk_d_count[clkn] + 1;
      end
      else
        clk_d_count[clkn] <= 0;
    end

    // Clock Detect Latch
    reg clk_detect_data;
    always @ (*) begin
      if (clkn==1) begin
        if (clk_d_count[clkn] == CLK1_DTCT_CNT_V-1)
          clk_detect_data = 1'b1;
        else
          clk_detect_data = 1'b0;
      end
      else begin
        if (clk_d_count[clkn] == CLK2_DTCT_CNT_V-1)
          clk_detect_data = 1'b1;
        else
          clk_detect_data = 1'b0;
      end
    end

    sclib_tmr_ff # (
      .DW(1),
      .SRVAL(1'b0)
    ) clk_detect (
      .D(clk_detect_data),
      .CLK(clkin[clkn]),
      .SRB(cfgdn_rstb_clk[clkn]),
      .Q(clk_valid[clkn])
    );
  end
endgenerate

// Reference Clock Selector
wire clksel;
reg clksel_1st;
wire clksel_latch;
always @ (*) begin
  case (clk_valid)
    2'b00: clksel_1st = 0;
    2'b01: clksel_1st = 0;
    2'b10: clksel_1st = 1;
    default: clksel_1st = 0;
  endcase
end
assign clksel = (clksel_latch) ? REFCLK_SEL: clksel_1st;

BUFGCTRL # (
  .INIT_OUT(1),
  .PRESELECT_I0("TRUE"),
  .PRESELECT_I1("FALSE")
) refclkmux (
  .CE0(clk_valid[1]), .CE1(clk_valid[2]),
  .IGNORE0(1'b1),     .IGNORE1(1'b1),
  .I0(SYSCLK1),       .I1(SYSCLK2),
  .S0(~clksel),       .S1(clksel),
  .O(REFCLK)
);

always @ (posedge REFCLK) begin
  if (clk_d_count_en == 2'b11) begin
    if (clk_valid[1])
      clk_d_count_en2 = 3'b000;
    else if (clk_valid[2])
      clk_d_count_en1 = 3'b000;
  end
end

sclib_mvote clk_en_1 (.IN(clk_d_count_en1), .OUT(clk_d_count_en[1]));
sclib_mvote clk_en_2 (.IN(clk_d_count_en2), .OUT(clk_d_count_en[2]));
assign SYSCLK1_EN = clk_d_count_en[1];
assign SYSCLK2_EN = clk_d_count_en[2];

(* dont_touch = "yes" *) reg [2:0] ref_sel = 0;
(* dont_touch = "yes" *) reg [2:0] ref_valid = 0;
always @ (posedge REFCLK) begin
  if (!clksel_latch & |clk_valid) begin
    ref_valid <= {3{1'b1}};
    ref_sel <= {3{clksel}};
  end
end
sclib_mvote mvote_clk_valid (.IN(ref_valid), .OUT(clksel_latch));
sclib_mvote mvote_clk_sel   (.IN(ref_sel),   .OUT(REFCLK_SEL));

sclib_rstb_sync sys_rstb (
  .CLK(REFCLK),
  .RSTB_IN(clksel_latch),
  .RSTB_OUT(REFCLK_VALID)
);

endmodule
