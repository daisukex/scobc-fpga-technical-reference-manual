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
  output SYSMON_HW_INT,

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
  input [15:0] XADC_DO,

  // SEM Controller
  input [4:0] SEM_CURRENT_STATUS,
  input [4:0] SEM_PREVIOUS_STATUS,
  input SEM_STATUS_CHANGE,
  output reg [7:0] HEARTBEAT_TIMEOUT,
  input HEARTBEAT_TIMEOUT_DETECT,
  input HALTED_DETECT,
  input UNCORRECT_DETECT,
  input ECORRECT_DETECT,
  output reg INJECT_REQ,
  input INJECT_ACK,
  output reg [39:0] INJECT_ADDRESS
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
wire wdog_sw_reset;
reg wdog_sw_reset_d;
wire [15:0] rd_wsr;
always @ (*) begin
  swdog_time_d = swdog_time;
  wdog_sw_reset_d = wdog_sw_reset;
  if (WADR == `SYSMON_WDOG_CTRL) begin
    if (chk_enbit(3, `SM_SW_WDOG_TIME, REG_WENB))
      swdog_time_d = REG_WDAT[`SM_SW_WDOG_TIME +:3];
    if (chk_enbit(1, `SM_SW_WDOG_MODE, REG_WENB))
      wdog_sw_reset_d = REG_WDAT[`SM_SW_WDOG_MODE];
  end
end
sclib_tmr_ff # (.DW(3), .SRVAL(SW_WDOC_TIME_INIT)) swdog_time_reg       (.D(swdog_time_d),       .CLK(HCLK), .SRB(HRESETN), .Q(swdog_time));
sclib_tmr_ff # (.DW(1), .SRVAL(1'b0))              wdog_sw_reset_reg    (.D(wdog_sw_reset_d),    .CLK(HCLK), .SRB(HRESETN), .Q(wdog_sw_reset));
wire [31:0] rd_wdogctrl = 32'h0000_0000 | ((wdog_sw_reset << `SM_SW_WDOG_MODE) | (swdog_time << `SM_SW_WDOG_TIME) | (rd_wsr << `SM_WDOG_WSR));

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
  if (wdog_sw_reset & |sync_wdog_expire[3:1])
    wdog_expire_hclk = 1'b1;
end
sclib_tmr_ff # (.DW(1), .SRVAL(1'b0)) wdog_reset_req_reg (.D(wdog_expire_hclk), .CLK(HCLK), .SRB(HRESETN), .Q(WDOG_RST_REQ));

// Watchdog Service Register
// ----------------------------------------
reg swdog_reload;
reg wdog_wsr_phase;
reg swdog_reload_pulse;
reg [SWDOG_RELOAD_WIDTH-1:0] swdog_reload_shift;
assign rd_wsr = (wdog_wsr_phase) ? 16'hA5A5: 16'h5A5A;
always @ (posedge HCLK) begin
  if (!HRESETN) begin
    swdog_reload <= 1'b0;
    wdog_wsr_phase <= 1'b0;
  end
  else begin
    swdog_reload <= 1'b0;
    if (WADR == `SYSMON_WDOG_CTRL & chk_enbit(16, `SM_WDOG_WSR, REG_WENB)) begin
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

// System Monitor Interrupt
// ----------------------------------------
reg [2:0] sync_heartbeat_timeout;
reg [2:0] sync_halted;
reg [2:0] sync_uncorrect;
reg [2:0] sync_ecorrect;
always @ (posedge HCLK) begin
  sync_heartbeat_timeout <= {sync_heartbeat_timeout[1:0], HEARTBEAT_TIMEOUT_DETECT};
  sync_halted <= {sync_halted[1:0], HALTED_DETECT};
  sync_uncorrect <= {sync_uncorrect[1:0], UNCORRECT_DETECT};
  sync_ecorrect <= {sync_ecorrect[1:0], ECORRECT_DETECT};
end

// SEM Controller Interrupt Status
reg heartbeat_timeout_sts;
reg halted_sts;
reg uncorrect_sts;
reg ecorrect_sts;
always @ (posedge HCLK) begin
  if (!HRESETN) begin
    heartbeat_timeout_sts <= 1'b0;
    halted_sts <= 1'b0;
    uncorrect_sts <= 1'b0;
    ecorrect_sts <= 1'b0;
  end
  else begin
    if (WADR == `SYSMON_INT_STATUS) begin
      if (chk_enbit(1, `SEM_HTIMEOUT_INT, REG_WENB) & REG_WDAT[`SEM_HTIMEOUT_INT])
        heartbeat_timeout_sts <= 1'b0;
      if (chk_enbit(1, `SEM_HALTED_INT, REG_WENB) & REG_WDAT[`SEM_HALTED_INT])
        halted_sts <= 1'b0;
      if (chk_enbit(1, `SEM_UNCORRECT_INT, REG_WENB) & REG_WDAT[`SEM_UNCORRECT_INT])
        uncorrect_sts <= 1'b0;
      if (chk_enbit(1, `SEM_ECORRECT_INT, REG_WENB) & REG_WDAT[`SEM_ECORRECT_INT])
        ecorrect_sts <= 1'b0;
    end
    if (~sync_heartbeat_timeout[2] & sync_heartbeat_timeout[1])
      heartbeat_timeout_sts <= 1'b1;
    if (~sync_halted[2] & sync_halted[1])
      halted_sts <= 1'b1;
    if (~sync_uncorrect[2] & sync_uncorrect[1])
      uncorrect_sts <= 1'b1;
    if (~sync_ecorrect[2] & sync_ecorrect[1])
      ecorrect_sts <= 1'b1;
  end
end
wire [31:0] rd_sysmon_intsts = 32'h0000_0000 | (heartbeat_timeout_sts << `SEM_HTIMEOUT_INT)
                                             | (halted_sts << `SEM_HALTED_INT)
                                             | (uncorrect_sts << `SEM_UNCORRECT_INT)
                                             | (ecorrect_sts << `SEM_ECORRECT_INT);

// SEM Controller Interrupt Enable
reg heartbeat_timeout_enb;
reg halted_enb;
reg uncorrect_enb;
reg ecorrect_enb;
always @ (posedge HCLK) begin
  if (!HRESETN) begin
    heartbeat_timeout_enb <= 1'b0;
    halted_enb <= 1'b0;
    uncorrect_enb <= 1'b0;
    ecorrect_enb <= 1'b0;
  end
  else begin
    if (WADR == `SYSMON_INT_ENABLE) begin
      if (chk_enbit(1, `SEM_HTIMEOUT_ENB, REG_WENB))
        heartbeat_timeout_enb <= REG_WDAT[`SEM_HTIMEOUT_ENB];
      if (chk_enbit(1, `SEM_HALTED_ENB, REG_WENB))
        halted_enb <= REG_WDAT[`SEM_HALTED_ENB];
      if (chk_enbit(1, `SEM_UNCORRECT_ENB, REG_WENB))
        uncorrect_enb <= REG_WDAT[`SEM_UNCORRECT_ENB];
      if (chk_enbit(1, `SEM_ECORRECT_ENB, REG_WENB))
        ecorrect_enb <= REG_WDAT[`SEM_ECORRECT_ENB];
    end
  end
end
wire [31:0] rd_sysmon_intenb = 32'h0000_0000 | (heartbeat_timeout_enb << `SEM_HTIMEOUT_ENB)
                                             | (halted_enb << `SEM_HALTED_ENB)
                                             | (uncorrect_enb << `SEM_UNCORRECT_ENB)
                                             | (ecorrect_enb << `SEM_ECORRECT_ENB);

assign SYSMON_HW_INT = (ecorrect_enb & ecorrect_sts)
                     | (uncorrect_enb & uncorrect_sts)
                     | (halted_enb & halted_sts)
                     | (heartbeat_timeout_enb & heartbeat_timeout_sts);

// SEM Controller Register
// ----------------------------------------
// SEM State
reg [4:0] sem_pre_sts;
reg [4:0] sem_cur_sts;
reg [2:0] sync_status_change;
always @ (posedge HCLK) begin
  if (!HRESETN) begin
    sem_pre_sts <= 5'h0;
    sem_cur_sts <= 5'h0;
  end
  else begin
    sync_status_change <= {sync_status_change[1:0], SEM_STATUS_CHANGE};
    if (~sync_status_change[2] & sync_status_change[1]) begin
      sem_pre_sts <= SEM_PREVIOUS_STATUS;
      sem_cur_sts <= SEM_CURRENT_STATUS;
    end
  end
end
wire [31:0] rd_sem_state = 32'h0000_0000 | (sem_pre_sts[4] << `SEM_PRE_INJECT)
                                         | (sem_pre_sts[3] << `SEM_PRE_CLASSIFIC)
                                         | (sem_pre_sts[2] << `SEM_PRE_CORRECT)
                                         | (sem_pre_sts[1] << `SEM_PRE_OBSERVE)
                                         | (sem_pre_sts[0] << `SEM_PRE_INIT)
                                         | (sem_cur_sts[4] << `SEM_CUR_INJECT)
                                         | (sem_cur_sts[3] << `SEM_CUR_CLASSIFIC)
                                         | (sem_cur_sts[2] << `SEM_CUR_CORRECT)
                                         | (sem_cur_sts[1] << `SEM_CUR_OBSERVE)
                                         | (sem_cur_sts[0] << `SEM_CUR_INIT);

// SEM Correction Count
reg [15:0] sem_ecount;
always @ (posedge HCLK) begin
  if (!HRESETN)
    sem_ecount <= 0;
  else begin
    if (WADR == `SYSMON_SEM_ECCOUNT & chk_enbit(16, `SEM_CCOUNT, REG_WENB))
      sem_ecount <= 0;
    else if (~sync_ecorrect[2] & sync_ecorrect[1])
      sem_ecount <= sem_ecount + 1;
  end
end
wire [31:0] rd_sem_ccount = 32'h0000_0000 | (sem_ecount << `SEM_CCOUNT);

// SEM Heartbeat timeout
always @ (posedge HCLK) begin
  if (!HRESETN)
    HEARTBEAT_TIMEOUT <= 8'hFF;
  else begin
      if (WADR == `SYSMON_SEM_HTIMEOUT & chk_enbit(8, `SEM_HTIMEOUT, REG_WENB))
        HEARTBEAT_TIMEOUT <= REG_WDAT[`SEM_HTIMEOUT +:8];;
  end
end
wire [31:0] rd_sem_htimeout = 32'h0000_0000 | (HEARTBEAT_TIMEOUT << `SEM_HTIMEOUT);

// SEM Error Injection
reg [2:0] sync_inject_ack;
always @ (posedge HCLK) begin
  if (!HRESETN) begin
    INJECT_REQ <= 0;
    INJECT_ADDRESS <= 0;
    sync_inject_ack <= 3'b000;
  end
  else begin
    sync_inject_ack <= {sync_inject_ack[1:0], INJECT_ACK};
    if (WADR == `SYSMON_SEM_EINJECT1) begin
      if (chk_enbit(8, `SEM_EINJECT1, REG_WENB))
        INJECT_ADDRESS[0 +:8] <= REG_WDAT[`SEM_EINJECT1 +:8];
      if (chk_enbit(8, `SEM_EINJECT1+8, REG_WENB))
        INJECT_ADDRESS[8 +:8] <= REG_WDAT[`SEM_EINJECT1+8 +:8];
      if (chk_enbit(8, `SEM_EINJECT1+16, REG_WENB))
        INJECT_ADDRESS[16 +:8] <= REG_WDAT[`SEM_EINJECT1+16 +:8];
      if (chk_enbit(8, `SEM_EINJECT1+24, REG_WENB))
        INJECT_ADDRESS[24 +:8] <= REG_WDAT[`SEM_EINJECT1+24 +:8];
    end
    else if (WADR == `SYSMON_SEM_EINJECT2) begin
      if (chk_enbit(8, `SEM_EINJECT2, REG_WENB)) begin
        INJECT_ADDRESS[32 +:8] <= REG_WDAT[`SEM_EINJECT2 +:8];
        INJECT_REQ <= 1'b1;
      end
    end

    if (INJECT_REQ) begin
      if (~sync_inject_ack[2] & sync_inject_ack[1])
        INJECT_REQ <= 1'b0;
    end
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
    else if (RADR == `SYSMON_INT_STATUS) REG_RDAT <= rd_sysmon_intsts;
    else if (RADR == `SYSMON_INT_ENABLE) REG_RDAT <= rd_sysmon_intenb;
    else if (RADR == `SYSMON_SEM_STATE)  REG_RDAT <= rd_sem_state;
    else if (RADR == `SYSMON_SEM_ECCOUNT)REG_RDAT <= rd_sem_ccount;
    else if (RADR == `SYSMON_SEM_HTIMEOUT)REG_RDAT <= rd_sem_htimeout;
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
