//-----------------------------------------------
// Space Cubics General Purpose Timer
// Module: sc_gptmr_reg
//  General Purpose Timer Register
//-----------------------------------------------
// Copyright © 2022 Space Cubics, LLC.
//-----------------------------------------------
`include "sc_gptmr_version.vh"
`include "sc_gptmr_reg_map.vh"

module sc_gptmr_reg # (
  parameter GTMR_COMPARE_CHANNEL = 4,  // Global Timer Compare Channel (1-16)
  parameter SITMR_COMPARE_CHANNEL = 8, // Software Interrupt Timer Compare Channel (1-16)
  parameter HITMR_COMPARE_CHANNEL = 8  // Hardware Interrupt Timer Compare Channel (1- 8)
) (
  // AHB Register Interface
  input HCLK,
  input HRESETN,

  // Bus Interface
  input [31:0] REG_WADR,
  input [3:0] REG_WENB,
  input [31:0] REG_WDAT,
  output REG_WWAT,

  input [31:0] REG_RADR,
  input REG_RENB,
  output [31:0] REG_RDAT,
  output REG_RWAT,

  // Register Interface
  input SYNC_CLK,
  input SYNC_RSTB,

  // Global Timer Register
  output reg GTMR_VALUE_SET,
  output reg [27:0] GTMR_VALUE,
  input [31:0] GTMR_COUNT,
  output reg [32*GTMR_COMPARE_CHANNEL-1:0] GTMR_COMPARE_VALUE,
  input GTMR_ROLLOVER_INT,
  input [GTMR_COMPARE_CHANNEL-1:0] GTMR_COMPARE_INT,

  // Software Interrupt Timer Register
  output reg SITMR_EN,
  input [31:0] SITMR_COUNT,
  output reg SITMR_RST,
  output reg SITMR_RUN_MODE,
  output reg SITMR_ENB_MODE,
  output reg [15:0] SITMR_PRESCALER,
  output reg [32*SITMR_COMPARE_CHANNEL-1:0] SITMR_COMPARE_VALUE,
  input SITMR_ROLLOVER_INT,
  input [SITMR_COMPARE_CHANNEL-1:0] SITMR_COMPARE_INT,

  // Hardware Interrupt Timer Register
  output reg HITMR_EN,
  input [31:0] HITMR_COUNT,
  output reg HITMR_RST,
  output reg HITMR_RUN_MODE,
  output reg HITMR_ENB_MODE,
  output reg [2*HITMR_COMPARE_CHANNEL-1:0] HITMR_OP_MODE,
  output reg [15:0] HITMR_PRESCALER,
  output reg [32*HITMR_COMPARE_CHANNEL-1:0] HITMR_COMPARE_VALUE,

  // Interrupt Signal
  output reg GTMR_INT,
  output reg SITMR_INT
);

integer ch;
wire [15:0] sync_wadr;
wire [3:0] sync_wenb;
wire [31:0] sync_wdat;
wire [15:0] sync_radr;
wire sync_renb;
reg [31:0] sync_rdat;
reg sync_rdvd;

wire reg_waen = 1'b1;
wire reg_raen = 1'b1;

// AHB Interface Synchronizer
//----------------------------------------------
sc_gptmr_syncreg # (
  .ADDR_WIDTH(16)
) ahb_slave_syncreg (
  // AHB Slave Interface
  .REG_CLK(HCLK),
  .REG_RSTB(HRESETN),

  // Write Channel
  .REG_WAEN(reg_waen),
  .REG_WADR(REG_WADR[15:0]),
  .REG_WENB(REG_WENB),
  .REG_WDAT(REG_WDAT),
  .REG_WWAT(REG_WWAT),
  // Read Channel
  .REG_RAEN(reg_raen),
  .REG_RADR(REG_RADR[15:0]),
  .REG_RENB(REG_RENB),
  .REG_RDAT(REG_RDAT),
  .REG_RWAT(REG_RWAT),

  // Synchronous Interface
  .SYNC_CLK(SYNC_CLK),
  .SYNC_RSTB(SYNC_RSTB),
  //  Write Channel
  .SYNC_WADR(sync_wadr),
  .SYNC_WENB(sync_wenb),
  .SYNC_WDAT(sync_wdat),
  // Read Channel
  .SYNC_RADR(sync_radr),
  .SYNC_RENB(sync_renb),
  .SYNC_RDAT(sync_rdat),
  .SYNC_RDVD(sync_rdvd)
);

wire [15:0] wadr = {sync_wadr[15:2], 2'b00};
wire [15:0] radr = {sync_radr[15:2], 2'b00};

// Global Timer Register
//--------------------------------------------------
always @ (posedge SYNC_CLK) begin
  if (!SYNC_RSTB) begin
    GTMR_VALUE_SET <= 1'b0;
  end
  else begin
    GTMR_VALUE_SET <= 1'b0;
    if (wadr == `GPTMR_GTR & |sync_wenb) begin
      GTMR_VALUE_SET <= 1'b1;
      if (sync_wenb[0]) GTMR_VALUE[0 +:4]  <= sync_wdat[`GPTMR_GTINT    +:4];
      if (sync_wenb[1]) GTMR_VALUE[4 +:8]  <= sync_wdat[`GPTMR_GTINT+4  +:8];
      if (sync_wenb[2]) GTMR_VALUE[12 +:8] <= sync_wdat[`GPTMR_GTINT+12 +:8];
      if (sync_wenb[3]) GTMR_VALUE[20 +:8] <= sync_wdat[`GPTMR_GTINT+20 +:8];
    end
  end
end
wire [31:0] rd_gptmr_gtr = 32'h0000_0000 | (GTMR_COUNT[31:4] << `GPTMR_GTINT)
                                         | (GTMR_COUNT[3:0]  << `GPTMR_GTFLOAT);

// Timer Enable Control Register
//--------------------------------------------------
always @ (posedge SYNC_CLK) begin
  if (!SYNC_RSTB) begin
    SITMR_EN <= 1'b0;
    HITMR_EN <= 1'b0;
  end
  else if (wadr == `GPTMR_TECR & sync_wenb[0]) begin
    SITMR_EN <= sync_wdat[`GPTMR_SITEN];
    HITMR_EN <= sync_wdat[`GPTMR_HITEN];
  end
end
wire [31:0] rd_gptmr_tecr = 32'h0000_0000 | (HITMR_EN << `GPTMR_HITEN)
                                          | (SITMR_EN << `GPTMR_SITEN);

// Software Interrupt Timer Remaining Register
//----------------------------------------------
wire [31:0] rd_gptmr_sitrr = 32'h0000_0000 | (SITMR_COUNT << `GPTMR_SITCNT);

// Hardware Interrupt Timer Remaining Register
//----------------------------------------------
wire [31:0] rd_gptmr_hitrr = 32'h0000_0000 | (HITMR_COUNT << `GPTMR_HITCNT);

// Global Timer Interrupt Status Register
// ----------------------------------------
reg gtmr_rollover_int;
reg [GTMR_COMPARE_CHANNEL-1:0] gtmr_outcomp_int;
reg [31:0] gtmr_comp_value [0:GTMR_COMPARE_CHANNEL-1];
always @ (posedge SYNC_CLK) begin
  if (!SYNC_RSTB) begin
    gtmr_rollover_int <= 1'b0;
    gtmr_outcomp_int <= 0;
  end
  else begin
    if (wadr == `GPTMR_GTSR) begin
      if (sync_wenb[2] & sync_wdat[`GPTMR_GTROVSTS])
        gtmr_rollover_int <= 1'b0;

      for (ch=0; ch<GTMR_COMPARE_CHANNEL; ch=ch+1) begin
        if (sync_wenb[0] & ch < 8 & sync_wdat[`GPTMR_GTOCFSTS+ch])            gtmr_outcomp_int[ch] <= 0;
        if (sync_wenb[1] & ch >= 8 & ch < 16 & sync_wdat[`GPTMR_GTOCFSTS+ch]) gtmr_outcomp_int[ch] <= 0;
      end
    end

    if (GTMR_ROLLOVER_INT)
      gtmr_rollover_int <= 1'b1;
    for (ch=0; ch<GTMR_COMPARE_CHANNEL; ch=ch+1) begin
      if (GTMR_COMPARE_INT[ch])
        gtmr_outcomp_int[ch] <= 1'b1;
    end
  end
end
always @ (*) begin
  for (ch=0; ch<GTMR_COMPARE_CHANNEL; ch=ch+1) begin
    GTMR_COMPARE_VALUE[32*ch +:32] = gtmr_comp_value[ch];
  end
end
wire [31:0] rd_gptmr_gtsr = 32'h0000_0000 | (gtmr_rollover_int << `GPTMR_GTROVSTS)
                                          | (gtmr_outcomp_int << `GPTMR_GTOCFSTS);

// Global Timer Interrupt Enable Register
//----------------------------------------------
reg gtmr_rollover_enb;
reg [GTMR_COMPARE_CHANNEL-1:0] gtmr_outcomp_enb;
always @ (posedge SYNC_CLK) begin
  if (!SYNC_RSTB) begin
    gtmr_rollover_enb <= 1'b0;
    gtmr_outcomp_enb <= 0;
  end
  else if (wadr == `GPTMR_GTER) begin
    // Rollover Interrupt Enable
    if (sync_wenb[2]) gtmr_rollover_enb <= sync_wdat[`GPTMR_GTROVENB];
    // Output Compare Enable
    for (ch=0; ch<GTMR_COMPARE_CHANNEL; ch=ch+1) begin
      if (ch < 8 & sync_wenb[0])            gtmr_outcomp_enb[ch] <= sync_wdat[`GPTMR_GTOCFENB+ch];
      if (ch >= 8 & ch < 16 & sync_wenb[1]) gtmr_outcomp_enb[ch] <= sync_wdat[`GPTMR_GTOCFENB+ch];
    end
  end
end
wire [31:0] rd_gptmr_gter = 32'h0000_0000 | (gtmr_rollover_enb << `GPTMR_GTROVENB)
                                          | (gtmr_outcomp_enb  << `GPTMR_GTOCFENB);

// Global Timer Interrupt Signal
// ----------------------------------------
always @ (posedge SYNC_CLK) begin
  if (!SYNC_RSTB)
    GTMR_INT <= 1'b0;
  else
    GTMR_INT <= (gtmr_rollover_int & gtmr_rollover_enb) |
               |(gtmr_outcomp_int & gtmr_outcomp_enb);
end

// Global Timer Output Compare Register
//----------------------------------------------
always @ (posedge SYNC_CLK) begin
  if (!SYNC_RSTB) begin
    for (ch=0; ch<GTMR_COMPARE_CHANNEL; ch=ch+1) begin
      gtmr_comp_value[ch] <= 32'h0000_0000;
    end
  end
  else begin
    for (ch=0; ch<GTMR_COMPARE_CHANNEL; ch=ch+1) begin
      if (wadr == (`GPTMR_GTOCR+(4*ch))) begin
        if (sync_wenb[0]) gtmr_comp_value[ch][0 +:8]  <= sync_wdat[7:0];
        if (sync_wenb[1]) gtmr_comp_value[ch][8 +:8]  <= sync_wdat[15:8];
        if (sync_wenb[2]) gtmr_comp_value[ch][16 +:8] <= sync_wdat[23:16];
        if (sync_wenb[3]) gtmr_comp_value[ch][24 +:8] <= sync_wdat[31:24];
      end
    end
  end
end

// Software Interrupt Timer Control Register
//----------------------------------------------
always @ (posedge SYNC_CLK) begin
  if (!SYNC_RSTB | SITMR_RST) begin
    SITMR_RST <= 1'b0;
    SITMR_RUN_MODE <= 1'b0;
    SITMR_ENB_MODE <= 1'b0;
  end
  else begin
    SITMR_RST <= 1'b0;
    if (wadr == `GPTMR_SITCR & sync_wenb[0]) begin
      if (sync_wdat[`GPTMR_SITSWR])
        SITMR_RST <= 1'b1;
      SITMR_RUN_MODE <= sync_wdat[`GPTMR_SITRUNMD];
      SITMR_ENB_MODE <= sync_wdat[`GPTMR_SITENBMD];
    end
  end
end
wire [31:0] rd_gptmr_sitcr = 32'h0000_0000 | (SITMR_RST      << `GPTMR_SITSWR)
                                           | (SITMR_RUN_MODE << `GPTMR_SITRUNMD)
                                           | (SITMR_ENB_MODE << `GPTMR_SITENBMD);

// Software Interrupt Timer Prescaler Register
//----------------------------------------------
always @ (posedge SYNC_CLK) begin
  if (!SYNC_RSTB | SITMR_RST)
    SITMR_PRESCALER <= 16'h0000;
  else if (wadr == `GPTMR_SITPR) begin
    if (sync_wenb[0]) SITMR_PRESCALER[7:0]  <= sync_wdat[7:0];
    if (sync_wenb[1]) SITMR_PRESCALER[15:8] <= sync_wdat[15:8];
  end
end
wire [31:0] rd_gptmr_sitpr = 32'h0000_0000 | (SITMR_PRESCALER << `GPTMR_SITPSC);

// Software Interrupt Timer Status Register
//----------------------------------------------
reg sitmr_rollover_int;
reg [SITMR_COMPARE_CHANNEL-1:0] sitmr_outcomp_int;
always @ (posedge SYNC_CLK) begin
  if (!SYNC_RSTB | SITMR_RST) begin
    sitmr_rollover_int <= 1'b0;
    sitmr_outcomp_int  <= 0;
  end
  else begin
    if (wadr == `GPTMR_SITSR) begin
      if (sync_wenb[2] & sync_wdat[`GPTMR_SITROVSTS])
        sitmr_rollover_int <= 1'b0;

      for (ch=0; ch<SITMR_COMPARE_CHANNEL; ch=ch+1) begin
        if (sync_wenb[0] & ch < 8 & sync_wdat[`GPTMR_SITOCFSTS+ch])            sitmr_outcomp_int[ch] <= 0;
        if (sync_wenb[1] & ch >= 8 & ch < 16 & sync_wdat[`GPTMR_SITOCFSTS+ch]) sitmr_outcomp_int[ch] <= 0;
      end
    end

    if (SITMR_ROLLOVER_INT)
      sitmr_rollover_int <= 1'b1;
    for (ch=0; ch<SITMR_COMPARE_CHANNEL; ch=ch+1) begin
      if (SITMR_COMPARE_INT[ch])
        sitmr_outcomp_int[ch] <= 1'b1;
    end
  end
end
wire [31:0] rd_gptmr_sitsr = 32'h0000_0000 | (sitmr_rollover_int << `GPTMR_SITROVSTS)
                                           | (sitmr_outcomp_int << `GPTMR_SITOCFSTS);

// Software Interrupt Timer Enable Register
//----------------------------------------------
reg sitmr_rollover_enb;
reg [SITMR_COMPARE_CHANNEL-1:0] sitmr_outcomp_enb;
always @ (posedge SYNC_CLK) begin
  if (!SYNC_RSTB | SITMR_RST) begin
    sitmr_rollover_enb <= 1'b0;
    sitmr_outcomp_enb <= 0;
  end
  else if (wadr == `GPTMR_SITER) begin
    // Rollover Interrupt Enable
    if (sync_wenb[2]) sitmr_rollover_enb <= sync_wdat[`GPTMR_SITROVENB];
    // Output Compare Enable
    for (ch=0; ch<SITMR_COMPARE_CHANNEL; ch=ch+1) begin
      if (ch < 8 & sync_wenb[0])          sitmr_outcomp_enb[ch] <= sync_wdat[`GPTMR_SITOCFENB+ch];
      if (ch >= 8 & ch < 16 & sync_wenb[1]) sitmr_outcomp_enb[ch] <= sync_wdat[`GPTMR_SITOCFENB+ch];
    end
  end
end
wire [31:0] rd_gptmr_siter = 32'h0000_0000 | (sitmr_rollover_enb << `GPTMR_SITROVENB)
                                           | (sitmr_outcomp_enb << `GPTMR_SITOCFENB);

// Software Interrupt Timer Interrupt Signal
// ----------------------------------------
always @ (posedge SYNC_CLK) begin
  if (!SYNC_RSTB)
    SITMR_INT <= 1'b0;
  else
    SITMR_INT <= (sitmr_rollover_int & sitmr_rollover_enb) |
                |(sitmr_outcomp_int & sitmr_outcomp_enb);
end

// Software Interrupt Timer Output Compare Register
//----------------------------------------------
reg [31:0] sitmr_comp_value [0:SITMR_COMPARE_CHANNEL-1];
always @ (posedge SYNC_CLK) begin
  if (!SYNC_RSTB | SITMR_RST) begin
    for (ch=0; ch<SITMR_COMPARE_CHANNEL; ch=ch+1) begin
      sitmr_comp_value[ch] <= 32'h0000_0000;
    end
  end
  else begin
    for (ch=0; ch<SITMR_COMPARE_CHANNEL; ch=ch+1) begin
      if (wadr == (`GPTMR_SITOCR+(4*ch))) begin
        if (sync_wenb[0]) sitmr_comp_value[ch][0 +:8]  <= sync_wdat[7:0];
        if (sync_wenb[1]) sitmr_comp_value[ch][8 +:8]  <= sync_wdat[15:8];
        if (sync_wenb[2]) sitmr_comp_value[ch][16 +:8] <= sync_wdat[23:16];
        if (sync_wenb[3]) sitmr_comp_value[ch][24 +:8] <= sync_wdat[31:24];
      end
    end
  end
end
always @ (*) begin
  for (ch=0; ch<SITMR_COMPARE_CHANNEL; ch=ch+1) begin
    SITMR_COMPARE_VALUE[32*ch +:32] = sitmr_comp_value[ch];
  end
end

// Hardware Interrupt Timer Control Register
//----------------------------------------------
reg [1:0] hitmr_op_mode [0:HITMR_COMPARE_CHANNEL-1];
always @ (posedge SYNC_CLK) begin
  if (!SYNC_RSTB | HITMR_RST) begin
    HITMR_RST <= 1'b0;
    HITMR_RUN_MODE <= 1'b0;
    HITMR_ENB_MODE <= 1'b0;
    for (ch=0; ch<HITMR_COMPARE_CHANNEL; ch=ch+1)
      hitmr_op_mode[ch] <= 2'b00;
  end
  else begin
    HITMR_RST <= 1'b0;
    if (wadr == `GPTMR_HITCR) begin
      if (sync_wenb[0]) begin
        if (sync_wdat[`GPTMR_HITSWR]) HITMR_RST <= 1'b1;
        HITMR_RUN_MODE <= sync_wdat[`GPTMR_HITRUNMD];
        HITMR_ENB_MODE <= sync_wdat[`GPTMR_HITENBMD];
      end
      for (ch=0; ch<HITMR_COMPARE_CHANNEL; ch=ch+1) begin
        if (sync_wenb[2] & ch < 4)           hitmr_op_mode[ch] <= sync_wdat[`GPTMR_HITOPMD+(2*ch) +:2];
        if (sync_wenb[3] & ch >= 4 & ch < 8) hitmr_op_mode[ch] <= sync_wdat[`GPTMR_HITOPMD+(2*ch) +:2];
      end
    end
  end
end
always @ (*) begin
  for (ch=0; ch<HITMR_COMPARE_CHANNEL; ch=ch+1) begin
    HITMR_OP_MODE[2*ch +:2] = hitmr_op_mode[ch];
  end
end
wire [31:0] rd_gptmr_hitcr = 32'h0000_0000 | (HITMR_OP_MODE  << `GPTMR_HITOPMD)
                                           | (HITMR_RST      << `GPTMR_HITSWR)
                                           | (HITMR_RUN_MODE << `GPTMR_HITRUNMD)
                                           | (HITMR_ENB_MODE << `GPTMR_HITENBMD);

// Hardware Interrupt Timer Prescaler Register
//----------------------------------------------
always @ (posedge SYNC_CLK) begin
  if (!SYNC_RSTB | HITMR_RST)
    HITMR_PRESCALER <= 16'h0000;
  else if (wadr == `GPTMR_HITPR) begin
    if (sync_wenb[0]) HITMR_PRESCALER[7:0]  <= sync_wdat[7:0];
    if (sync_wenb[1]) HITMR_PRESCALER[15:8] <= sync_wdat[15:8];
  end
end
wire [31:0] rd_gptmr_hitpr = 32'h0000_0000 | (HITMR_PRESCALER << `GPTMR_HITPSC);

// Hardware Interrupt Timer Output Compare Register
//----------------------------------------------
reg [31:0] hitmr_comp_value [0:HITMR_COMPARE_CHANNEL-1];
always @ (posedge SYNC_CLK) begin
  if (!SYNC_RSTB | HITMR_RST) begin
    for (ch=0; ch<HITMR_COMPARE_CHANNEL; ch=ch+1) begin
      hitmr_comp_value[ch] <= 32'h0000_0000;
    end
  end
  else begin
    for (ch=0; ch<HITMR_COMPARE_CHANNEL; ch=ch+1) begin
      if (wadr == (`GPTMR_HITOCR+(4*ch))) begin
        if (sync_wenb[0]) hitmr_comp_value[ch][0 +:8]  <= sync_wdat[7:0];
        if (sync_wenb[1]) hitmr_comp_value[ch][8 +:8]  <= sync_wdat[15:8];
        if (sync_wenb[2]) hitmr_comp_value[ch][16 +:8] <= sync_wdat[23:16];
        if (sync_wenb[3]) hitmr_comp_value[ch][24 +:8] <= sync_wdat[31:24];
      end
    end
  end
end
always @ (*) begin
  for (ch=0; ch<HITMR_COMPARE_CHANNEL; ch=ch+1) begin
    HITMR_COMPARE_VALUE[32*ch +:32] = hitmr_comp_value[ch];
  end
end

// General Purpose Timer IP Version Register
//----------------------------------------------
wire [31:0] rd_gptmr_ver = 32'h0000_0000 | (`GPTMR_MAJVERVAL << `GPTMR_MAJVER)
                                         | (`GPTMR_MINVERVAL << `GPTMR_MINVER)
                                         | (`GPTMR_PATVERVAL << `GPTMR_PATVER);

// Register Read
//----------------------------------------------
always @ (posedge SYNC_CLK) begin
  if (!SYNC_RSTB)
    sync_rdvd <= 1'b0;
  else begin
    sync_rdvd <= 1'b0;
    if (sync_renb) begin
      if (radr == `GPTMR_GTR & GTMR_VALUE_SET)
        sync_rdvd <= 1'b0;
      else
        sync_rdvd <= 1'b1;

      if (radr == `GPTMR_GTR)   sync_rdat <= rd_gptmr_gtr;
      if (radr == `GPTMR_TECR)  sync_rdat <= rd_gptmr_tecr;
      if (radr == `GPTMR_SITRR) sync_rdat <= rd_gptmr_sitrr;
      if (radr == `GPTMR_HITRR) sync_rdat <= rd_gptmr_hitrr;
      if (radr == `GPTMR_GTSR)  sync_rdat <= rd_gptmr_gtsr;
      if (radr == `GPTMR_GTER)  sync_rdat <= rd_gptmr_gter;
      for (ch=0; ch<GTMR_COMPARE_CHANNEL; ch=ch+1) begin
        if (radr == `GPTMR_GTOCR+(`GPTMR_CH_OFFSET*ch)) sync_rdat <= gtmr_comp_value[ch];
      end
      if (radr == `GPTMR_SITCR) sync_rdat <= rd_gptmr_sitcr;
      if (radr == `GPTMR_SITPR) sync_rdat <= rd_gptmr_sitpr;
      if (radr == `GPTMR_SITSR) sync_rdat <= rd_gptmr_sitsr;
      if (radr == `GPTMR_SITER) sync_rdat <= rd_gptmr_siter;
      for (ch=0; ch<SITMR_COMPARE_CHANNEL; ch=ch+1) begin
        if (radr == `GPTMR_SITOCR+(`GPTMR_CH_OFFSET*ch)) sync_rdat <= sitmr_comp_value[ch];
      end
      if (radr == `GPTMR_HITCR) sync_rdat <= rd_gptmr_hitcr;
      if (radr == `GPTMR_HITPR) sync_rdat <= rd_gptmr_hitpr;
      for (ch=0; ch<HITMR_COMPARE_CHANNEL; ch=ch+1) begin
        if (radr == `GPTMR_HITOCR+(`GPTMR_CH_OFFSET*ch)) sync_rdat <= hitmr_comp_value[ch];
      end
      if (radr == `GPTMR_VER) sync_rdat <= rd_gptmr_ver;
    end
  end
end

endmodule
