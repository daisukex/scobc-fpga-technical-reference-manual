//-----------------------------------------------
// Module: sysreg
//  Space Cubics OBC FPGA System Register
//  System Register Main
//-----------------------------------------------
// Copyright © 2022 Space Cubics, LLC.
//-----------------------------------------------
`include "sysreg_version.vh"
`include "sysreg_map.vh"

module sysreg_main # (
  parameter BUILD_INFO = 32'h00000000
) (
  // System Interface
  input HCLK,
  input HRESETN,
  input POR_RSTB,

  // Register Interface
  input [31:0] REG_WADR,
  input [3:0] REG_WENB,
  input [31:0] REG_WDAT,
  output REG_WWAT,
  input [31:0] REG_RADR,
  input REG_RENB,
  output reg [31:0] REG_RDAT,

  // Input/Output Signals
  output reg CFGITCMEN,
  output reg SYS_RST_REQ,
  input [1:0] TRCH_BOOT,
  output [1:0] CLKMODE,
  output reg CMC_REQ,
  input CMC_ACK
);

integer n, b;
wire [15:0] WRAD = {REG_WADR[15:2],2'b00};
wire [15:0] RDAD = {REG_RADR[15:2],2'b00};

// Code Memory Select Register
//----------------------------------------------
reg [7:0] cfgitcmen_p;
always @ (posedge HCLK) begin
  if (!POR_RSTB) begin
    CFGITCMEN <= 1'b1;
    SYS_RST_REQ <= 1'b0;
    cfgitcmen_p <= 8'hFF;
  end
  else begin
    if (WRAD == `SYSREG_CODEMSEL &
        REG_WENB[3:2] & REG_WDAT[`SR_ITCMENPKC +:16] == 16'h5A5A) begin
      if (REG_WENB[0])
        CFGITCMEN <= REG_WDAT[`SR_ITCMEN];
    end
    cfgitcmen_p <= {cfgitcmen_p[6:0], CFGITCMEN};
    SYS_RST_REQ <= CFGITCMEN ^ cfgitcmen_p[7];
  end
end
wire [31:0] rd_codemsel = 32'h0000_0000 | (CFGITCMEN << `SR_ITCMEN);

// System Clock Control Register
//----------------------------------------------
(* dont_touch = "yes" *) reg [2:0] clk_change_req;
wire clk_change_req_mvote;
(* dont_touch = "yes" *) reg [2:0] clk_mode [0:1];
reg [2:0] sync_cmc_ack;
always @ (posedge HCLK) begin
  if (!POR_RSTB | !HRESETN) begin
    clk_mode[0] <= {3{TRCH_BOOT[0]}};
    clk_mode[1] <= {3{TRCH_BOOT[1]}};
    clk_change_req <= 3'b111;
  end
  else begin
    if (WRAD == `SYSREG_SYSCLKCTL & REG_WENB[0] & !REG_WWAT) begin
      clk_mode[0] <= {3{REG_WDAT[`SR_CLKMODE]}};
      clk_mode[1] <= {3{REG_WDAT[`SR_CLKMODE+1]}};
      clk_change_req <= 3'b111;
    end
    if (sync_cmc_ack[2])
      clk_change_req <= 3'b000;
  end
end
sclib_mvote clkchange_mvote (.IN(clk_change_req), .OUT(clk_change_req_mvote));
sclib_mvote clkmode0_mvote  (.IN(clk_mode[0]),    .OUT(CLKMODE[0]));
sclib_mvote clkmode1_mvote  (.IN(clk_mode[1]),    .OUT(CLKMODE[1]));
wire [31:0] rd_sysclkctl = 32'h0000_0000 | (CLKMODE << `SR_CLKMODE);

reg [7:0] clk_change_delay;
always @ (posedge HCLK) begin
  if (!HRESETN | sync_cmc_ack[2]) begin
    clk_change_delay <= 8'h00;
    CMC_REQ <= 1'b0;
  end
  else begin
    clk_change_delay <= {clk_change_delay[6:0], clk_change_req_mvote};
    if (clk_change_delay[7:4] == 4'hF)
      CMC_REQ <= 1'b1;
  end
end
always @ (posedge HCLK) begin
  sync_cmc_ack <= {sync_cmc_ack[1:0], CMC_ACK};
end
assign REG_WWAT = WRAD == `SYSREG_SYSCLKCTL & |REG_WENB & (CMC_REQ | sync_cmc_ack[2]);

// Scratch Pad Register
//----------------------------------------------
(* dont_touch = "yes" *) reg [31:0] spad1 [0:3];
(* dont_touch = "yes" *) reg [31:0] spad2 [0:3];
(* dont_touch = "yes" *) reg [31:0] spad3 [0:3];
(* dont_touch = "yes" *) reg [31:0] spad4 [0:3];
reg [31:0] rd_spad1, rd_spad2, rd_spad3, rd_spad4;
always @ (posedge HCLK) begin
  if (!HRESETN) begin
    for (n=0; n<=3; n=n+1) begin
      spad1[n] <= 32'h0000_0000;
      spad2[n] <= 32'h0000_0000;
      spad3[n] <= 32'h0000_0000;
      spad4[n] <= 32'h0000_0000;
    end
  end
  else begin
    for (n=0; n<=3; n=n+1) begin
      if (WRAD == `SYSREG_SPAD1 & REG_WENB[0]) spad1[n][ 0 +:8] <= REG_WDAT[ 0 +:8];
      if (WRAD == `SYSREG_SPAD1 & REG_WENB[1]) spad1[n][ 8 +:8] <= REG_WDAT[ 8 +:8];
      if (WRAD == `SYSREG_SPAD1 & REG_WENB[2]) spad1[n][15 +:8] <= REG_WDAT[15 +:8];
      if (WRAD == `SYSREG_SPAD1 & REG_WENB[3]) spad1[n][23 +:8] <= REG_WDAT[23 +:8];
      if (WRAD == `SYSREG_SPAD2 & REG_WENB[0]) spad2[n][ 0 +:8] <= REG_WDAT[ 0 +:8];
      if (WRAD == `SYSREG_SPAD2 & REG_WENB[1]) spad2[n][ 8 +:8] <= REG_WDAT[ 8 +:8];
      if (WRAD == `SYSREG_SPAD2 & REG_WENB[2]) spad2[n][15 +:8] <= REG_WDAT[15 +:8];
      if (WRAD == `SYSREG_SPAD2 & REG_WENB[3]) spad2[n][23 +:8] <= REG_WDAT[23 +:8];
      if (WRAD == `SYSREG_SPAD3 & REG_WENB[0]) spad3[n][ 0 +:8] <= REG_WDAT[ 0 +:8];
      if (WRAD == `SYSREG_SPAD3 & REG_WENB[1]) spad3[n][ 8 +:8] <= REG_WDAT[ 8 +:8];
      if (WRAD == `SYSREG_SPAD3 & REG_WENB[2]) spad3[n][15 +:8] <= REG_WDAT[15 +:8];
      if (WRAD == `SYSREG_SPAD3 & REG_WENB[3]) spad3[n][23 +:8] <= REG_WDAT[23 +:8];
      if (WRAD == `SYSREG_SPAD4 & REG_WENB[0]) spad4[n][ 0 +:8] <= REG_WDAT[ 0 +:8];
      if (WRAD == `SYSREG_SPAD4 & REG_WENB[1]) spad4[n][ 8 +:8] <= REG_WDAT[ 8 +:8];
      if (WRAD == `SYSREG_SPAD4 & REG_WENB[2]) spad4[n][15 +:8] <= REG_WDAT[15 +:8];
      if (WRAD == `SYSREG_SPAD4 & REG_WENB[3]) spad4[n][23 +:8] <= REG_WDAT[23 +:8];
    end
  end
end

always @ (*) begin
  for (b=0; b<32; b=b+1) begin
    rd_spad1[b] = (spad1[0][b] + spad1[1][b] + spad1[2][b]) >= 2;
    rd_spad2[b] = (spad2[0][b] + spad2[1][b] + spad2[2][b]) >= 2;
    rd_spad3[b] = (spad3[0][b] + spad3[1][b] + spad3[2][b]) >= 2;
    rd_spad4[b] = (spad4[0][b] + spad4[1][b] + spad4[2][b]) >= 2;
  end
end

// IP Version Register
//----------------------------------------------
wire [31:0] rd_version;
assign rd_version = 32'h0000_0000 |
                    (`SYSREG_MAJVERVAL << `SR_MAJVER) |
                    (`SYSREG_MINVERVAL << `SR_MINVER) |
                    (`SYSREG_PATVERVAL << `SR_PATVER);

// Register Read
//----------------------------------------------
always @ (posedge HCLK) begin
  if (!HRESETN)
    REG_RDAT <= 32'h0000_0000;
  else if (REG_RENB) begin
    if      (RDAD == `SYSREG_CODEMSEL)  REG_RDAT <= rd_codemsel;
    else if (RDAD == `SYSREG_SYSCLKCTL) REG_RDAT <= rd_sysclkctl;
    else if (RDAD == `SYSREG_SPAD1)     REG_RDAT <= rd_spad1;
    else if (RDAD == `SYSREG_SPAD2)     REG_RDAT <= rd_spad2;
    else if (RDAD == `SYSREG_SPAD3)     REG_RDAT <= rd_spad3;
    else if (RDAD == `SYSREG_SPAD4)     REG_RDAT <= rd_spad4;
    else if (RDAD == `SYSREG_VER)       REG_RDAT <= rd_version;
    else if (RDAD == `SYSREG_BUILDINFO) REG_RDAT <= BUILD_INFO;
    else                                REG_RDAT <= 32'h0000_00000;
  end
end

endmodule
