//-----------------------------------------------
// Space Cubics General Purpose Timer
// Module: sc_gptmr
//  General Purpose Timer Top Module
//-----------------------------------------------
// Copyright © 2022 Space Cubics, LLC.
//-----------------------------------------------
module sc_gptmr # (
  // Number of Global Timer Compare Channel: Range 1-16
  parameter GTMR_COMPARE_CHANNEL = 4,
  // Global Timer Prescaler Bit Width: Range 1-32
  parameter GTMR_PRESCALER_BIT_WIDTH = 21,
  // Number of Software Interrupt Timer Compare Channel: Range 1-16
  parameter SITMR_COMPARE_CHANNEL = 8,
  // Number of Hardware Interrupt Timer Compare Channel: Range 1-8
  parameter HITMR_COMPARE_CHANNEL = 8
) (
  // System Interface
  input HRESETN,
  input HCLK,
  input TMR_RSTB,
  input TMR_CLK,
  input MODULE_RSTN,

  // Configuration Interface
  input [GTMR_PRESCALER_BIT_WIDTH-1:0] GTMR_PRESCALER_VALUE,

  // AHB Slave Interface
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

  // Interrupt Signal
  output GTMR_INT,
  output SITMR_INT,
  output [7:0] HITMR_INT_REQ,
  input [7:0] HITMR_INT_ACK
);

genvar ch;

wire gtmr_value_set;
wire [27:0] gtmr_value;
wire [31:0] gtmr_count;
wire [32*GTMR_COMPARE_CHANNEL-1:0] gtmr_compare_value;
wire gtmr_rollover_int;
wire [GTMR_COMPARE_CHANNEL-1:0] gtmr_compare_int;

wire sitmr_en;
wire [31:0] sitmr_count;
wire sitmr_rst;
wire sitmr_run_mode;
wire sitmr_enb_mode;
wire [15:0] sitmr_prescaler;
wire [32*SITMR_COMPARE_CHANNEL-1:0] sitmr_compare_value;
wire sitmr_rollover_int;
wire [SITMR_COMPARE_CHANNEL-1:0] sitmr_compare_int;

wire hitmr_en;
wire [31:0] hitmr_count;
wire hitmr_rst;
wire hitmr_run_mode;
wire hitmr_enb_mode;
wire [2*HITMR_COMPARE_CHANNEL-1:0] hitmr_op_mode;
wire [15:0] hitmr_prescaler;
wire [32*HITMR_COMPARE_CHANNEL-1:0] hitmr_compare_value;

wire [HITMR_COMPARE_CHANNEL-1:0] internal_hitmr_int_req;
wire [HITMR_COMPARE_CHANNEL-1:0] internal_hitmr_int_ack;

wire  gptmr_hresetn = HRESETN & MODULE_RSTN;
wire sync_gptmr_mrstb;
sclib_rstb_sync gptmr_mrstb_sync (
  .CLK(TMR_CLK),
  .RSTB_IN(MODULE_RSTN),
  .RSTB_OUT(sync_gptmr_mrstb)
);
wire gptmr_ref_rstb = TMR_RSTB & sync_gptmr_mrstb;

sc_gptmr_ahb_slave # (
  .GTMR_COMPARE_CHANNEL(GTMR_COMPARE_CHANNEL),
  .SITMR_COMPARE_CHANNEL(SITMR_COMPARE_CHANNEL),
  .HITMR_COMPARE_CHANNEL(HITMR_COMPARE_CHANNEL)
) gptmr_slave (
  // System Interface
  .HRESETN(gptmr_hresetn),
  .HCLK(HCLK),
  .TMR_RSTB(gptmr_ref_rstb),
  .TMR_CLK(TMR_CLK),

  // AHB Slave Interface
  .SHSEL(SHSEL),
  .SHADDR(SHADDR),
  .SHTRANS(SHTRANS),
  .SHSIZE(SHSIZE),
  .SHBURST(SHBURST),
  .SHWRITE(SHWRITE),
  .SHREADYIN(SHREADYIN),
  .SHREADYOUT(SHREADYOUT),
  .SHWDATA(SHWDATA),
  .SHRDATA(SHRDATA),
  .SHRESP(SHRESP),

  // Register Interface
  // Timer Core Interface
  .GTMR_VALUE_SET(gtmr_value_set),
  .GTMR_VALUE(gtmr_value),
  .GTMR_COUNT(gtmr_count),
  .GTMR_COMPARE_VALUE(gtmr_compare_value),
  .GTMR_ROLLOVER_INT(gtmr_rollover_int),
  .GTMR_COMPARE_INT(gtmr_compare_int),

  // Software Interrupt Timer Register
  .SITMR_EN(sitmr_en),
  .SITMR_COUNT(sitmr_count),
  .SITMR_RST(sitmr_rst),
  .SITMR_RUN_MODE(sitmr_run_mode),
  .SITMR_ENB_MODE(sitmr_enb_mode),
  .SITMR_PRESCALER(sitmr_prescaler),
  .SITMR_COMPARE_VALUE(sitmr_compare_value),
  .SITMR_ROLLOVER_INT(sitmr_rollover_int),
  .SITMR_COMPARE_INT(sitmr_compare_int),

  // Hardware Interrupt Timer Register
  .HITMR_EN(hitmr_en),
  .HITMR_COUNT(hitmr_count),
  .HITMR_RST(hitmr_rst),
  .HITMR_RUN_MODE(hitmr_run_mode),
  .HITMR_ENB_MODE(hitmr_enb_mode),
  .HITMR_OP_MODE(hitmr_op_mode),
  .HITMR_PRESCALER(hitmr_prescaler),
  .HITMR_COMPARE_VALUE(hitmr_compare_value),

  // Interrupt Signal
  .GTMR_INT(GTMR_INT),
  .SITMR_INT(SITMR_INT)
);

sc_gptmr_core # (
  .GTMR_PRESCALER_BIT_WIDTH(GTMR_PRESCALER_BIT_WIDTH),
  .GTMR_COMPARE_CHANNEL(GTMR_COMPARE_CHANNEL),
  .SITMR_COMPARE_CHANNEL(SITMR_COMPARE_CHANNEL),
  .HITMR_COMPARE_CHANNEL(HITMR_COMPARE_CHANNEL)
) gptmr_core (
  // System Interface
  .TMR_RSTB(gptmr_ref_rstb),
  .TMR_CLK(TMR_CLK),

  // Register Interface
  //  Global Timer Signal
  .GTMR_VALUE_SET(gtmr_value_set),
  .GTMR_VALUE(gtmr_value),
  .GTMR_COUNT(gtmr_count),
  .GTMR_PRESCALER_VALUE(GTMR_PRESCALER_VALUE),
  .GTMR_COMPARE_VALUE(gtmr_compare_value),
  .GTMR_ROLLOVER_INT(gtmr_rollover_int),
  .GTMR_COMPARE_INT(gtmr_compare_int),

  // Software Interrupt Timer Signal
  .SITMR_EN(sitmr_en),
  .SITMR_COUNT(sitmr_count),
  .SITMR_RST(sitmr_rst),
  .SITMR_RUN_MODE(sitmr_run_mode),
  .SITMR_ENB_MODE(sitmr_enb_mode),
  .SITMR_PRESCALER(sitmr_prescaler),
  .SITMR_COMPARE_VALUE(sitmr_compare_value),
  .SITMR_ROLLOVER_INT(sitmr_rollover_int),
  .SITMR_COMPARE_INT(sitmr_compare_int),

  // Hardware Interrupt Timer Signal
  .HITMR_EN(hitmr_en),
  .HITMR_COUNT(hitmr_count),
  .HITMR_RST(hitmr_rst),
  .HITMR_RUN_MODE(hitmr_run_mode),
  .HITMR_ENB_MODE(hitmr_enb_mode),
  .HITMR_OP_MODE(hitmr_op_mode),
  .HITMR_PRESCALER(hitmr_prescaler),
  .HITMR_COMPARE_VALUE(hitmr_compare_value),
  .HITMR_INT_REQ(internal_hitmr_int_req),
  .HITMR_INT_ACK(internal_hitmr_int_ack)
);

generate
  for(ch=0; ch<8; ch=ch+1) begin : gen_hitmr_int_sig
    if (ch < HITMR_COMPARE_CHANNEL) begin
      assign HITMR_INT_REQ[ch] = internal_hitmr_int_req[ch];
      assign internal_hitmr_int_ack[ch] = HITMR_INT_ACK[ch];
    end
    else begin
      assign HITMR_INT_REQ[ch] = 1'b0;
    end
  end
endgenerate

endmodule
