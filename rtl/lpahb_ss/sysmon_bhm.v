//-----------------------------------------------
// Module: sysmon_bhm
//  Space Cubics OBC FPGA System Monitor OBC Board Health Monitor
//-----------------------------------------------
// Copyright © 2022 Space Cubics, LLC.
//-----------------------------------------------

module sysmon_bhm # (
  parameter [5:0] SC_SYSMON_BHM_INITSET_NUM = 6'd1,
  parameter [27*SC_SYSMON_BHM_INITSET_NUM-1:0] SC_SYSMON_BHM_INITSET_VAL = 27'h0
) (
  // System Interface
  input HCLK,
  input HRESETN,

  // Register Interface
  input BHM_INIT_REQ,
  input [4:0] BHM_INIT_EN,

  input [4:0] BHM_MONI_EN,
  output [4:0] BHM_MONI_EN_OFF,

  output BHM_TEMP_ALERT,
  output BHM_CVM_WARN,
  output BHM_CVM_CRIT,
  output [5:0] BHM_I2C_ERR,
  output BHM_SW_ACC_END,
  output BHM_INIT_ACC_END,

  output [11:0] BHM_CVM_UPD,
  output [16*12-1:0] BHM_CVM_DAT,
  output [2:0] BHM_TEMP_UPD,
  output [16*3-1:0] BHM_TEMP_DAT,

  input BHM_SW_REQ,
  input [2:0] BHM_SW_DEVSEL,
  input [7:0] BHM_SW_DEVADR,
  input BHM_SW_RWSEL,
  input [15:0] BHM_SW_WRDATA,
  output [15:0] BHM_SW_RDDATA,

  input [15:0] BHM_CLKPSC,
  input [7:0] BHM_I2CACC_CNT,

  output [5:0] BHM_BUSY,

  // Hardware Scheduler Interface
  input CVM_DATA_REQ_TRG,
  input TEMP_DATA_REQ_TRG,

  // Device Interface
  input CVM_CRITICAL_B,
  input CVM_WARNING_B,
  input TEMP_ALERT_B,

  // I2C Interface
  inout INTERNAL_I2C_SCL,
  inout INTERNAL_I2C_SDA
);

wire [15:0] i2c_thdsta;
wire [15:0] i2c_tsusto;
wire [15:0] i2c_tsusta;
wire [15:0] i2c_thigh;
wire [15:0] i2c_thddat;
wire [15:0] i2c_tsudat;
wire [15:0] i2c_tbuf;

wire i2c_en;
wire i2c_en_off;
wire i2c_comp;
wire [1:0] i2c_busy;
wire [2:0] i2c_err;

wire i2c_tx_data_req;
wire [9:0] i2c_tx_data;
wire i2c_tx_data_ready;

wire i2c_rx_data_val;
wire [7:0] i2c_rx_data;

wire sda_in;
wire sda_out;
wire scl_in;
wire scl_out;

// SC OBC Board Health Monitor Main Controller
bhm_main # (
  .INITSET_NUM(SC_SYSMON_BHM_INITSET_NUM),
  .INITSET_VAL(SC_SYSMON_BHM_INITSET_VAL)
) bhm_main (
  // System Interface
  .SYSCLK(HCLK),
  .SYSRST_N(HRESETN),

  // Register Interface
  .INIT_REQ(BHM_INIT_REQ),
  .INIT_EN(BHM_INIT_EN),

  .MONI_EN(BHM_MONI_EN),
  .MONI_EN_OFF(BHM_MONI_EN_OFF),

  .TEMP_ALERT(BHM_TEMP_ALERT),
  .CVM_WARN(BHM_CVM_WARN),
  .CVM_CRIT(BHM_CVM_CRIT),
  .I2C_ACC_ERR(BHM_I2C_ERR),
  .SW_ACC_END(BHM_SW_ACC_END),
  .INIT_ACC_END(BHM_INIT_ACC_END),

  .CVM_UPD(BHM_CVM_UPD),
  .CVM_DAT(BHM_CVM_DAT),
  .TEMP_UPD(BHM_TEMP_UPD),
  .TEMP_DAT(BHM_TEMP_DAT),

  .SW_REQ(BHM_SW_REQ),
  .SW_DEVSEL(BHM_SW_DEVSEL),
  .SW_DEVADR(BHM_SW_DEVADR),
  .SW_RWSEL(BHM_SW_RWSEL),
  .SW_WRDATA(BHM_SW_WRDATA),
  .SW_RDDATA(BHM_SW_RDDATA),

  .CLKPSC(BHM_CLKPSC),
  .I2CACC_CNT(BHM_I2CACC_CNT),

  .BUSY(BHM_BUSY),

  // Hardware Scheduler Interface
  .CVM_DATA_REQ_TRG(CVM_DATA_REQ_TRG),
  .TEMP_DATA_REQ_TRG(TEMP_DATA_REQ_TRG),

  // Device Interface
  .CVM_CRITICAL_B(CVM_CRITICAL_B),
  .CVM_WARNING_B(CVM_WARNING_B),
  .TEMP_ALERT_B(TEMP_ALERT_B),

  // I2C Controller Interface
  .I2C_THDSTA(i2c_thdsta),
  .I2C_TSUSTO(i2c_tsusto),
  .I2C_TSUSTA(i2c_tsusta),
  .I2C_THIGH(i2c_thigh),
  .I2C_THDDAT(i2c_thddat),
  .I2C_TSUDAT(i2c_tsudat),
  .I2C_TBUF(i2c_tbuf),

  .I2C_EN(i2c_en),
  .I2C_EN_OFF(i2c_en_off),
  .I2C_COMP(i2c_comp),
  .I2C_BUSY(i2c_busy),
  .I2C_ERR(i2c_err),

  .I2C_TX_DATA_REQ(i2c_tx_data_req),
  .I2C_TX_DATA(i2c_tx_data),
  .I2C_TX_DATA_READY(i2c_tx_data_ready),

  .I2C_RX_DATA_VAL(i2c_rx_data_val),
  .I2C_RX_DATA(i2c_rx_data)
);

// I2C Master Main Controller
i2cm_main i2cm_main (
  // System Interface
  .SYSCLK(HCLK),
  .SYSRST_N(HRESETN),

  // Register Interface
  .REG_I2CM_EN(i2c_en),
  .REG_I2CM_SBUSY(i2c_busy[0]),
  .REG_I2CM_OBUSY(i2c_busy[1]),
  .REG_SCL_TOPROD(16'h0),
  .REG_THDSTA(i2c_thdsta),
  .REG_TSUSTO(i2c_tsusto),
  .REG_TSUSTA(i2c_tsusta),
  .REG_THIGH(i2c_thigh),
  .REG_THDDAT(i2c_thddat),
  .REG_TSUDAT(i2c_tsudat),
  .REG_TBUF(i2c_tbuf),
  .REG_SMPL_DELAY(16'h0),
  .REG_INT_COMP(i2c_comp),
  .REG_INT_ARB_LST(i2c_err[2]),
  .REG_INT_ACK_ERR(i2c_err[0]),
  .REG_INT_BIT_ERR(i2c_err[1]),
  .REG_INT_SCL_TO(/*open*/),
  .REG_I2CM_EN_OFF(i2c_en_off),

  // TX DATA Interface
  .TX_DATA_REQ(i2c_tx_data_req),
  .TX_DATA_IN(i2c_tx_data),
  .TX_DATA_READY(i2c_tx_data_ready),

  // RX DATA Interface
  .RX_DATA_VAL(i2c_rx_data_val),
  .RX_DATA_OUT(i2c_rx_data),
  .RX_DATA_READY(1'b1),

  // I2C Interface
  .SDA_IN(sda_in),
  .SDA_OUT(sda_out),
  .SCL_IN(scl_in),
  .SCL_OUT(scl_out)
);

// I2C I/O
i2c_io i2c_io (
  .SDA_IN(sda_in),
  .SDA_OUT(sda_out),
  .SCL_IN(scl_in),
  .SCL_OUT(scl_out),

  .SDA_IO(INTERNAL_I2C_SDA),
  .SCL_IO(INTERNAL_I2C_SCL)
);

endmodule
