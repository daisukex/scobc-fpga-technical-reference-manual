//-----------------------------------------------
// Space Cubics OBC Core
//  Space Cubics CORE TOP
//  Module: sc_obc_core
//-----------------------------------------------
// Copyright © 2022 Space Cubics, LLC.
//-----------------------------------------------

`include "system_monitor_map.vh"

module sysmon_reg (
  input HCLK,
  input HRESETN,
  input REF_CLK,
  input SYS_RSTB_SYNC_REFCLK,

  // Register Interface
  input [31:0] REG_WADR,
  input [3:0] REG_WENB,
  input [31:0] REG_WDAT,
  output REG_WWAT,

  input [31:0] REG_RADR,
  input REG_RENB,
  output reg [31:0] REG_RDAT,
  output REG_RWAT,

  output reg FPGA_WATCHDOG,
  output WDOG_RST_REQ,

  // XADC Interace
  output [6:0] XADC_DADDR,
  output XADC_DEN,
  output XADC_DWE,
  input XADC_DRDY,
  output [15:0] XADC_DI,
  input [15:0] XADC_DO
);

wire [23:0] SWDOG_LOWCUP_VALUE = 24'hB71AFF;
localparam SW_WDOC_TIME_INIT = 3'h7;
localparam WDOG_TGL_ITVAL = 24'hB71AFF;
localparam SWDOG_RELOAD_WIDTH = 5;
integer bt;
wire [15:0] WADR = {REG_WADR[15:2],2'b00};
wire [15:0] RADR = {REG_RADR[15:2],2'b00};

reg xadc_access;
wire xadc_wcycle = {WADR[15:12], 12'h000} == `SYSMON_XADC_BASE & |REG_WENB;
wire xadc_rcycle = {RADR[15:12], 12'h000} == `SYSMON_XADC_BASE & REG_RENB;
reg xadc_rcycle_latch;
reg xadc_dvalid;
wire xadc_valid = xadc_access & XADC_DRDY;
assign REG_WWAT  = xadc_wcycle & ~xadc_valid;
assign REG_RWAT  = xadc_rcycle_latch & ~xadc_dvalid;

// Watchdog Control Register
// ----------------------------------------
wire [2:0] swdog_time;
reg [2:0] swdog_time_d;
always @ (*) begin
  swdog_time_d = swdog_time;
  if (WADR == `SYSMON_WDOG_CTRL) begin
    if (chk_enbit(3, `SM_SW_WDOG_TIME, REG_WENB))
      swdog_time_d = REG_WDAT[`SM_SW_WDOG_TIME +:3];
  end
end
sclib_tmr_ff # (.DW(3), .SRVAL(SW_WDOC_TIME_INIT)) swdog_time_reg       (.D(swdog_time_d),       .CLK(HCLK), .SRB(HRESETN), .Q(swdog_time));
wire [31:0] rd_wdogctrl = 32'h0000_0000 | (swdog_time << `SM_SW_WDOG_TIME);

// Watchdog Expire after Reset
// ----------------------------------------
reg [3:0] sync_wdog_expire;
reg wdog_expire_hclk;
wire wdog_expire;
always @ (posedge HCLK) begin
  if (!HRESETN)
    sync_wdog_expire <= 0;
  else
    sync_wdog_expire <= {sync_wdog_expire[2:0], wdog_expire};
end
always @ (*) begin
  wdog_expire_hclk = WDOG_RST_REQ;
  if (|sync_wdog_expire[3:1])
    wdog_expire_hclk = 1'b1;
end
sclib_tmr_ff # (.DW(1), .SRVAL(1'b0)) wdog_reset_req_reg (.D(wdog_expire_hclk), .CLK(HCLK), .SRB(HRESETN), .Q(WDOG_RST_REQ));

// Watchdog Service Register
// ----------------------------------------
reg swdog_reload;
reg wdog_wsr_phase;
reg swdog_reload_pulse;
reg [SWDOG_RELOAD_WIDTH-1:0] swdog_reload_shift;
always @ (posedge HCLK) begin
  if (!HRESETN) begin
    swdog_reload <= 1'b0;
    wdog_wsr_phase <= 1'b0;
  end
  else begin
    swdog_reload <= 1'b0;
    if (WADR == `SYSMON_WDOG_WSR & chk_enbit(16, `SM_WDOG_WSR, REG_WENB)) begin
      if (!wdog_wsr_phase & REG_WDAT[`SM_WDOG_WSR +:16] == 16'h5A5A |
           wdog_wsr_phase & REG_WDAT[`SM_WDOG_WSR +:16] == 16'hA5A5) begin
        swdog_reload <= 1'b1;
        wdog_wsr_phase <= ~wdog_wsr_phase;
      end
    end
  end
end

always @ (posedge HCLK) begin
  if (!HRESETN)
    swdog_reload_pulse <= 1'b0;
  else begin
    swdog_reload_shift <= {swdog_reload_shift[SWDOG_RELOAD_WIDTH-2:0], swdog_reload};
    swdog_reload_pulse <= |swdog_reload_shift;
  end
end

// Watchdog Signal Interval Register
// ----------------------------------------
wire [23:0] wdog_sig_interval;
reg [23:0] wdog_sig_interval_d;
always @ (*) begin
  wdog_sig_interval_d = wdog_sig_interval;
  for (bt=0; bt<3; bt=bt+1) begin
    if (WADR == `SYSMON_WDOG_SIVAL & REG_WENB[bt])
      wdog_sig_interval_d[`SM_WDOG_SIVAL+bt*8 +:8] = REG_WDAT[`SM_WDOG_SIVAL+bt*8 +:8];
  end
end
sclib_tmr_ff # (.DW(24), .SRVAL(WDOG_TGL_ITVAL)) wdog_sig_interval_reg (.D(wdog_sig_interval_d), .CLK(HCLK), .SRB(HRESETN), .Q(wdog_sig_interval));
wire [31:0] rd_wdogsigival = 32'h0000_0000 | (wdog_sig_interval << `SM_WDOG_SIVAL);

// Watchdog Signal Interval Register
// ----------------------------------------
reg [23:0] swdog_l_cnt;
reg [7:0] swdog_h_cnt;
reg wdog_expire_d;
reg [2:0] sync_swdog_reload;
always @ (posedge REF_CLK) begin
  if (!SYS_RSTB_SYNC_REFCLK) begin
    swdog_l_cnt <= SWDOG_LOWCUP_VALUE;
    swdog_h_cnt <= 8'hFF >> 7-swdog_time;
  end
  else begin
    if (!sync_swdog_reload[2] & sync_swdog_reload[1]) begin
      swdog_l_cnt <= SWDOG_LOWCUP_VALUE;
      swdog_h_cnt <= 8'hFF >> 7-swdog_time;
    end
    else if (swdog_l_cnt == 24'h00_0000) begin
      if (swdog_h_cnt != 8'h00) begin
      swdog_l_cnt <= SWDOG_LOWCUP_VALUE;
      swdog_h_cnt <= swdog_h_cnt - 1;
      end
    end
    else
      swdog_l_cnt <= swdog_l_cnt - 1;
  end
end
always @ (*) begin
  wdog_expire_d = wdog_expire;
  if (swdog_l_cnt == 24'h00_0000 & swdog_h_cnt == 8'h00)
    wdog_expire_d = 1'b1;
end
sclib_tmr_ff # (.DW(1), .SRVAL(1'b0)) wdog_expire_reg (.D(wdog_expire_d), .CLK(REF_CLK), .SRB(SYS_RSTB_SYNC_REFCLK), .Q(wdog_expire));

// Synchronizer for Software watchdog
// ----------------------------------------
always @ (posedge REF_CLK) begin
  if (!SYS_RSTB_SYNC_REFCLK)
    sync_swdog_reload <= 0;
  else
    sync_swdog_reload <= {sync_swdog_reload[1:0], swdog_reload_pulse};
end

// Watchdog Signal Counter
// ----------------------------------------
reg [23:0] wdog_sig_counter;
always @ (posedge REF_CLK) begin
  if (!SYS_RSTB_SYNC_REFCLK) begin
    wdog_sig_counter <= 24'h000000;
    FPGA_WATCHDOG <= 1'b0;
  end
  else if (!wdog_expire) begin
    if (wdog_sig_interval == wdog_sig_counter) begin
      wdog_sig_counter <= 24'h000000;
      FPGA_WATCHDOG <= ~FPGA_WATCHDOG;
    end
    else
      wdog_sig_counter <= wdog_sig_counter + 1;
  end
end

// XADC Register Access
// ----------------------------------------
reg [6:0] latch_reg_radr;
assign XADC_DADDR = xadc_wcycle ? REG_WADR[10:4]: latch_reg_radr;
assign XADC_DEN = xadc_wcycle | xadc_rcycle_latch;
assign XADC_DWE = xadc_wcycle ? 1'b1: 1'b0;
assign XADC_DI = REG_WDAT[15:0];

always @ (posedge HCLK) begin
  if (!HRESETN)
    xadc_rcycle_latch <= 1'b0;
  else if (xadc_rcycle_latch & xadc_dvalid)
    xadc_rcycle_latch <= 1'b0;
  else if (xadc_rcycle) begin
    xadc_rcycle_latch <= 1'b1;
    latch_reg_radr <= REG_RADR[10:4];
  end
end

always @ (posedge HCLK) begin
  if (!HRESETN) begin
    xadc_access <= 1'b0;
    xadc_dvalid <= 1'b0;
  end
  else begin
    xadc_dvalid <= 1'b0;
    if (xadc_valid) begin
      xadc_access <= 1'b0;
      xadc_dvalid <= 1'b1;
    end
    else if (xadc_wcycle | xadc_rcycle)
      xadc_access <= 1'b1;
  end
end

// Register Read
// ----------------------------------------
always @ (posedge HCLK) begin
  if (!HRESETN)
    REG_RDAT <= 32'h0000_0000;
  else if (REG_RENB | xadc_valid) begin
    if      (RADR == `SYSMON_WDOG_CTRL)  REG_RDAT <= rd_wdogctrl;
    else if (RADR == `SYSMON_WDOG_SIVAL) REG_RDAT <= rd_wdogsigival;
    else if (xadc_valid)                 REG_RDAT <= {16'h0000, XADC_DO};
    else                                 REG_RDAT <= 32'h0000_00000;
  end
end

function chk_enbit;
  input [4:0] bit_width;
  input [4:0] base_bit;
  input [3:0] enb;
  reg [31:0] enable_bit;
  reg [3:0] exp_bit;
  reg [4:0] lp;
begin
  enable_bit = 32'h0000_0000;
  for(lp=0; lp<bit_width; lp=lp+1) begin
    enable_bit = enable_bit | 1'b1 << (base_bit + lp);
  end
  exp_bit[0] = |enable_bit[ 0 +:8];
  exp_bit[1] = |enable_bit[ 8 +:8];
  exp_bit[2] = |enable_bit[16 +:8];
  exp_bit[3] = |enable_bit[24 +:8];

  chk_enbit = &(~exp_bit | (exp_bit & enb));
end
endfunction

endmodule
