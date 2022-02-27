//-----------------------------------------------
// Module: sysreg
//  Space Cubics OBC FPGA System Register
//-----------------------------------------------
// Copyright © 2021 Space Cubics, LLC.
//-----------------------------------------------
`include "sysreg_version.vh"
`include "sysreg_map.vh"

module sysreg (
  // System Interface
  input SYSCLK,
  input RESETB,
  input POR_RSTB,

  // AHB Interface
  input SHSEL,
  input [31:0] SHADDR,
  input [1:0] SHTRANS,
  input [2:0] SHSIZE,
  input [2:0] SHBURST,
  input SHWRITE,
  input SHREADYIN,
  output SHREADYOUT,
  input [31:0] SHWDATA,
  output [31:0] SHRDATA,
  output [1:0] SHRESP,

  // System Register Output
  output reg SYS_RESET_REQ,
  output reg CFGITCMEN,
  output reg [1:0] CLKMODE,
  output reg CMC_REQ,
  input CMC_ACK
);

wire w_reg_dphase;
wire w_reg_w1r0;
wire [31:0] w_reg_addr;
wire  [3:0] w_reg_byteen;
wire [31:0] w_reg_wdata;
wire [31:0] w_reg_rdata;

// AHB Slave
sc_ahb_slave ahb_slave (
  // AHB Interface
  .HCLK(SYSCLK),             // input
  .HRESETN(RESETB),          // input
  .HSEL(SHSEL),              // input
  .HADDR(SHADDR),            // input  [31:0]
  .HTRANS(SHTRANS),          // input  [1:0]
  .HSIZE(SHSIZE),            // input  [2:0]
  .HBURST(SHBURST),          // input  [2:0]
  .HWRITE(SHWRITE),          // input
  .HREADYIN(SHREADYIN),      // input
  .HREADYOUT(SHREADYOUT),    // output
  .HWDATA(SHWDATA),          // input  [31:0]
  .HRDATA(SHRDATA),          // output [31:0]
  .HRESP(SHRESP),            // output [1:0]

  // Register Interface
  .AHB_WR(/*open*/),         // output
  .AHB_RD(/*open*/),         // output
  .AHB_ADDR(/*open*/),       // output [31:0]
  .AHB_WAIT(1'b0),           // input
  .REG_DPHASE(w_reg_dphase), // output
  .REG_W1R0(w_reg_w1r0),     // output
  .REG_ADDR(w_reg_addr),     // output [31:0]
  .REG_BYTEEN(w_reg_byteen), // output [3:0]
  .REG_WDATA(w_reg_wdata),   // output [31:0]
  .REG_RDATA(w_reg_rdata),   // input  [31:0]
  .REG_ACCERR(1'b0)          // input
);

wire w_reg_write;
wire w_reg_read;
assign w_reg_write = w_reg_dphase &  w_reg_w1r0;
assign w_reg_read  = w_reg_dphase & !w_reg_w1r0;

// Address Decoder
wire w_hit_cfgmemctl;
wire hit_sysclkctl;
wire w_hit_spad1;
wire w_hit_spad2;
wire w_hit_spad3;
wire w_hit_spad4;
wire w_hit_sysregver;
assign w_hit_cfgmemctl   = ({w_reg_addr[15:2] , 2'b00} == `SYSREG_CFGMEMCTL);
assign hit_sysclkctl     = ({w_reg_addr[15:2] , 2'b00} == `SYSREG_SYSCLKCTL);
assign w_hit_spad1       = ({w_reg_addr[15:2] , 2'b00} == `SYSREG_SPAD1);
assign w_hit_spad2       = ({w_reg_addr[15:2] , 2'b00} == `SYSREG_SPAD2);
assign w_hit_spad3       = ({w_reg_addr[15:2] , 2'b00} == `SYSREG_SPAD3);
assign w_hit_spad4       = ({w_reg_addr[15:2] , 2'b00} == `SYSREG_SPAD4);
assign w_hit_sysregver   = ({w_reg_addr[15:2] , 2'b00} == `SYSREG_VER);

// Configuration Memory Control Register
//----------------------------------------------
reg [7:0] r_cpu_cfgitcmen_p;
always @ (posedge SYSCLK or negedge POR_RSTB) begin
  if (!POR_RSTB) begin
    CFGITCMEN         <= 1'b1;
    r_cpu_cfgitcmen_p <= 8'hFF;
    SYS_RESET_REQ     <= 1'b0;
  end else begin
    if (w_hit_cfgmemctl & w_reg_write & &w_reg_byteen[3:2] &
        w_reg_wdata[`SYSREG_CFGMEMCTLPKC +: 16] == 16'h5A5A) begin
      if (w_reg_byteen[0])
        CFGITCMEN <= w_reg_wdata[`SYSREG_ITCMEN];
    end
    r_cpu_cfgitcmen_p <= {r_cpu_cfgitcmen_p[6:0], CFGITCMEN};
    SYS_RESET_REQ     <= CFGITCMEN ^ r_cpu_cfgitcmen_p[7];
  end
end

wire [31:0] w_rd_cfgmemctl;
assign w_rd_cfgmemctl = (w_hit_cfgmemctl & w_reg_read) ?
                        {{32-1-`SYSREG_ITCMEN{1'b0}}, CFGITCMEN, {`SYSREG_ITCMEN{1'b0}}} :
                        32'h0;

// System Clock Control Register
//----------------------------------------------
reg clkmode_change;
always @ (posedge SYSCLK or negedge RESETB) begin
  if (!RESETB) begin
    CLKMODE <= 2'b10;
    clkmode_change <= 1'b1;
  end
  else begin
    clkmode_change <= 1'b0;
    if (hit_sysclkctl & w_reg_write & w_reg_byteen[0]) begin
      CLKMODE <= w_reg_wdata[`SYSREG_CLKMODE +:2];
      clkmode_change <= 1'b1;
    end
  end
end
wire [31:0] rd_sysclkctl;
assign rd_sysclkctl = (hit_sysclkctl & w_reg_read) ?
                      (32'h0 | CLKMODE<<`SYSREG_CLKMODE):
                       32'h0;

reg clkmode_change_p;
reg clkmode_change_latch;
reg [5:0] clkmode_change_delay;
reg [4:0] sync_cmc_ack;
always @ (posedge SYSCLK or negedge RESETB) begin
  if (!RESETB) begin
    clkmode_change_p <= 1'b0;
    clkmode_change_latch <= 1'b0;
    clkmode_change_delay <= 0;
    CMC_REQ <= 1'b0;
  end
  else begin
    sync_cmc_ack <= {sync_cmc_ack[3:0], CMC_ACK};
    clkmode_change_p <= clkmode_change;
    clkmode_change_delay <= {clkmode_change_delay[4:0], clkmode_change_latch};

    if (&clkmode_change_delay[5:3]) begin
      clkmode_change_latch <= 1'b0;
      CMC_REQ <= 1'b1;
    end
    else if (!clkmode_change_p & clkmode_change)
      clkmode_change_latch <= 1'b1;

    if (CMC_REQ & &sync_cmc_ack[4:2])
      CMC_REQ <= 1'b0;
  end
end

// Scratch Pad 1 Register
//----------------------------------------------
reg [31:0] r_spad1;
always @ (posedge SYSCLK or negedge RESETB) begin
  if (!RESETB) begin
    r_spad1 <= 0;
  end else begin
    if (w_hit_spad1 & w_reg_write) begin
      if (w_reg_byteen[3])
        r_spad1[24 +: 8] <= w_reg_wdata[(24+`SYSREG_SPAD1CTL) +: 8];
      if (w_reg_byteen[2])
        r_spad1[16 +: 8] <= w_reg_wdata[(16+`SYSREG_SPAD1CTL) +: 8];
      if (w_reg_byteen[1])
        r_spad1[8 +: 8]  <= w_reg_wdata[(8+`SYSREG_SPAD1CTL) +: 8];
      if (w_reg_byteen[0])
        r_spad1[0 +: 8]  <= w_reg_wdata[(0+`SYSREG_SPAD1CTL) +: 8];
    end
  end
end

wire [31:0] w_rd_spad1;
assign w_rd_spad1 = (w_hit_spad1 & w_reg_read) ?
                    {{32-32-`SYSREG_SPAD1CTL{1'b0}}, r_spad1, {`SYSREG_SPAD1CTL{1'b0}}} :
                    32'h0;

// Scratch Pad 2 Register
//----------------------------------------------
reg [31:0] r_spad2;
always @ (posedge SYSCLK or negedge RESETB) begin
  if (!RESETB) begin
    r_spad2 <= 0;
  end else begin
    if (w_hit_spad2 & w_reg_write) begin
      if (w_reg_byteen[3])
        r_spad2[24 +: 8] <= w_reg_wdata[(24+`SYSREG_SPAD2CTL) +: 8];
      if (w_reg_byteen[2])
        r_spad2[16 +: 8] <= w_reg_wdata[(16+`SYSREG_SPAD2CTL) +: 8];
      if (w_reg_byteen[1])
        r_spad2[8 +: 8]  <= w_reg_wdata[(8+`SYSREG_SPAD2CTL) +: 8];
      if (w_reg_byteen[0])
        r_spad2[0 +: 8]  <= w_reg_wdata[(0+`SYSREG_SPAD2CTL) +: 8];
    end
  end
end

wire [31:0] w_rd_spad2;
assign w_rd_spad2 = (w_hit_spad2 & w_reg_read) ?
                    {{32-32-`SYSREG_SPAD2CTL{1'b0}}, r_spad2, {`SYSREG_SPAD2CTL{1'b0}}} :
                    32'h0;

// Scratch Pad 3 Register
//----------------------------------------------
reg [31:0] r_spad3;
always @ (posedge SYSCLK or negedge RESETB) begin
  if (!RESETB) begin
    r_spad3 <= 0;
  end else begin
    if (w_hit_spad3 & w_reg_write) begin
      if (w_reg_byteen[3])
        r_spad3[24 +: 8] <= w_reg_wdata[(24+`SYSREG_SPAD3CTL) +: 8];
      if (w_reg_byteen[2])
        r_spad3[16 +: 8] <= w_reg_wdata[(16+`SYSREG_SPAD3CTL) +: 8];
      if (w_reg_byteen[1])
        r_spad3[8 +: 8]  <= w_reg_wdata[(8+`SYSREG_SPAD3CTL) +: 8];
      if (w_reg_byteen[0])
        r_spad3[0 +: 8]  <= w_reg_wdata[(0+`SYSREG_SPAD3CTL) +: 8];
    end
  end
end

wire [31:0] w_rd_spad3;
assign w_rd_spad3 = (w_hit_spad3 & w_reg_read) ?
                    {{32-32-`SYSREG_SPAD3CTL{1'b0}}, r_spad3, {`SYSREG_SPAD3CTL{1'b0}}} :
                    32'h0;

// Scratch Pad 4 Register
//----------------------------------------------
reg [31:0] r_spad4;
always @ (posedge SYSCLK or negedge RESETB) begin
  if (!RESETB) begin
    r_spad4 <= 0;
  end else begin
    if (w_hit_spad4 & w_reg_write) begin
      if (w_reg_byteen[3])
        r_spad4[24 +: 8] <= w_reg_wdata[(24+`SYSREG_SPAD4CTL) +: 8];
      if (w_reg_byteen[2])
        r_spad4[16 +: 8] <= w_reg_wdata[(16+`SYSREG_SPAD4CTL) +: 8];
      if (w_reg_byteen[1])
        r_spad4[8 +: 8]  <= w_reg_wdata[(8+`SYSREG_SPAD4CTL) +: 8];
      if (w_reg_byteen[0])
        r_spad4[0 +: 8]  <= w_reg_wdata[(0+`SYSREG_SPAD4CTL) +: 8];
    end
  end
end

wire [31:0] w_rd_spad4;
assign w_rd_spad4 = (w_hit_spad4 & w_reg_read) ?
                    {{32-32-`SYSREG_SPAD4CTL{1'b0}}, r_spad4, {`SYSREG_SPAD4CTL{1'b0}}} :
                    32'h0;

// IP Version Register
//----------------------------------------------
wire [31:0] w_rd_sysregver;
assign w_rd_sysregver = (w_hit_sysregver & w_reg_read) ?
                        {{32- 8-`SYSREG_MAJVER{1'b0}},  `SYSREG_MAJVERVAL,  {`SYSREG_MAJVER{1'b0}}} |
                        {{32- 8-`SYSREG_MINVER{1'b0}},  `SYSREG_MINVERVAL,  {`SYSREG_MINVER{1'b0}}} |
                        {{32-16-`SYSREG_PATVER{1'b0}},  `SYSREG_PATVERVAL,  {`SYSREG_PATVER{1'b0}}} :
                        32'h0;

// AHB Read Data
//----------------------------------------------
assign w_reg_rdata = w_rd_cfgmemctl |
                     rd_sysclkctl |
                     w_rd_spad1 |
                     w_rd_spad2 |
                     w_rd_spad3 |
                     w_rd_spad4 |
                     w_rd_sysregver;

endmodule
