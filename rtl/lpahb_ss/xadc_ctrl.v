//-----------------------------------------------
// Space Cubics OBC System Monitor
//  XADC Controller
//  Module: xadc_ctrl
//-----------------------------------------------
// Copyright © 2022 Space Cubics, LLC.
//-----------------------------------------------

module xadc_ctrl (
  input REF_CLK,
  input SYS_RSTB_SYNC_REFCLK,
  input HCLK,
  input HRESETN,
  input [6:0] XADC_DADDR,
  input XADC_DEN,
  input XADC_DWE,
  output reg XADC_DRDY,
  input [15:0] XADC_DI,
  output [15:0] XADC_DO,
  output [7:0] XADC_ALARM,
  output XADC_OVER_TEMP
);

// Control Regsiter
// ------------------------------------------------
// - Configuration Register (40h to 42h)
parameter XADC_INIT_40 = 16'h0000;
parameter XADC_INIT_41 = 16'h2ff0;
parameter XADC_INIT_42 = 16'h0400;

// Channel Sequencer Register
// ------------------------------------------------
// - ADC Channel Selection Register(48h and 49h)
//  0:   XADC Calibration   : Enable
//  1:   Reserved           : -
//  2:   Reserved           : -
//  3:   Reserved           : -
//  4:   Reserved           : -
//  5:   VCCPINT (for ZYNQ) : Disable
//  6:   VCCPAUX (for ZYNQ) : Disable
//  7:   VCCODDR (for ZYNQ) : Disable
//  8:   Temperature Sensor : Enable
//  9:   VCCINT             : Enable
// 10:   VCCAUX             : Enable
// 11:   VP, VN Analog Input: Disable
// 12:   VREFP              : Disable
// 13:   VREFN              : Disable
// 14:   VCCBRAM            : Enable
// 15:   Reserved           : -
parameter XADC_INIT_48 = 16'h4701;

// 0-15: VAUXP[n], VAUXN[n] : Diable
parameter XADC_INIT_49 = 16'h0000;

// - ADC Channel Averaging (4Ah and 4Bh)
parameter XADC_INIT_4A = 16'h0000;
parameter XADC_INIT_4B = 16'h0000;

// - ADC Channel Analog-Input Mode (4Ch and 4Dh)
parameter XADC_INIT_4C = 16'h0000;
parameter XADC_INIT_4D = 16'h0000;

// - ADC Channel Setting Time (4Eh and 4Fh)
parameter XADC_INIT_4E = 16'h0000;
parameter XADC_INIT_4F = 16'h0000;

// Alarm Regsiter
// ------------------------------------------------
parameter XADC_INIT_50 = 16'hb5ed; // Temperature upper
parameter XADC_INIT_51 = 16'h5999; // VCCINT upper
parameter XADC_INIT_52 = 16'hA147; // VCCAUX upper
parameter XADC_INIT_53 = 16'hCAC0; // OT alarm limit
parameter XADC_INIT_54 = 16'ha93a; // Temperature lower
parameter XADC_INIT_55 = 16'h5111; // VCCINT lower
parameter XADC_INIT_56 = 16'h91Eb; // VCCAUX lower
parameter XADC_INIT_57 = 16'hae4e; // OT alarm reset
parameter XADC_INIT_58 = 16'h5999; // VCCBRAM upper
parameter XADC_INIT_5C = 16'h5111; // VCCBRAM lower

localparam XADC_IDLE = 2'b01,
           XADC_RACC = 2'b10;
reg [1:0] xadc_state;
reg [2:0] sync_xadc_den;
always @ (posedge REF_CLK) begin
  if (!SYS_RSTB_SYNC_REFCLK)
    sync_xadc_den <= 3'b000;
  else
    sync_xadc_den <= {sync_xadc_den[1:0], XADC_DEN};
end
wire den = ~sync_xadc_den[2] & sync_xadc_den[1];

wire drdy;
reg drdy_tgl;
always @ (posedge REF_CLK) begin
  if (!SYS_RSTB_SYNC_REFCLK)
    drdy_tgl <= 1'b0;
  else if (drdy)
    drdy_tgl <= ~drdy_tgl;
end

reg [2:0] sync_drdy_tgl;
always @ (posedge HCLK) begin
  if (!HRESETN) begin
    sync_drdy_tgl <= 3'b000;
    XADC_DRDY <= 1'b0;
  end
  else begin
    sync_drdy_tgl <= {sync_drdy_tgl[1:0], drdy_tgl};
    XADC_DRDY <= 1'b0;
    if (sync_drdy_tgl[2] != sync_drdy_tgl[1])
      XADC_DRDY <= 1'b1;
  end
end

// 7 Series FPGAs XADC Dual 12-Bit 1 MSPS
// Analog-to-Digital Converter
// ------------------------------------------------
XADC # (
  .INIT_40(XADC_INIT_40),
  .INIT_41(XADC_INIT_41),
  .INIT_42(XADC_INIT_42),
  .INIT_48(XADC_INIT_48),
  .INIT_49(XADC_INIT_49),
  .INIT_4A(XADC_INIT_4A),
  .INIT_4B(XADC_INIT_4B),
  .INIT_4C(XADC_INIT_4C),
  .INIT_4D(XADC_INIT_4D),
  .INIT_4E(XADC_INIT_4E),
  .INIT_4F(XADC_INIT_4F),
  .INIT_50(XADC_INIT_50),
  .INIT_51(XADC_INIT_51),
  .INIT_52(XADC_INIT_52),
  .INIT_53(XADC_INIT_53),
  .INIT_54(XADC_INIT_54),
  .INIT_55(XADC_INIT_55),
  .INIT_56(XADC_INIT_56),
  .INIT_57(XADC_INIT_57),
  .INIT_58(XADC_INIT_58),
  .INIT_5C(XADC_INIT_5C),
  .SIM_MONITOR_FILE("testcase/check_xadc.txt")
) XADC_INST (
  // Dynamic Reconfiguration Port
  .DI(XADC_DI),
  .DO(XADC_DO),
  .DADDR(XADC_DADDR),
  .DEN(den),
  .DWE(XADC_DWE),
  .DCLK(REF_CLK),
  .DRDY(drdy),

  // Control and Clock
  .RESET(~SYS_RSTB_SYNC_REFCLK),
  .CONVST(1'b0),
  .CONVSTCLK(1'b0),

  // External Analog Inputs
  .VP(1'b0),
  .VN(1'b0),
  .VAUXN(16'h0000),
  .VAUXP(16'h0000),

  // Alarms
  .ALM(XADC_ALARM),
  .OT(XADC_OVER_TEMP),

  // Status
  .MUXADDR(/*open*/),
  .CHANNEL(/*open*/),
  .EOC(/*open*/),
  .EOS(/*open*/),
  .BUSY(/*open*/),
  .JTAGLOCKED(/*open*/),
  .JTAGMODIFIED(/*open*/),
  .JTAGBUSY(/*open*/)
);

endmodule
