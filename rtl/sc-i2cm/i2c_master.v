//-----------------------------------------------
// Module: i2c_master
//  I2C Master Controller
//-----------------------------------------------
// Copyright © 2021 Space Cubics, LLC.
//-----------------------------------------------
module i2c_master # (
  parameter P_FIFO_DPTBW = 4, // Renge: 1-15
  parameter P_FIFO_TYPE = 0, // 0: BlockRAM 1: Shift Register
  parameter [15:0] P_INIT_THDSTA = 16'h0027,
  parameter [15:0] P_INIT_TSUSTO = 16'h0027,
  parameter [15:0] P_INIT_TSUSTA = 16'h0027,
  parameter [15:0] P_INIT_THIGH  = 16'h002D,
  parameter [15:0] P_INIT_THDDAT = 16'h0003,
  parameter [15:0] P_INIT_TSUDAT = 16'h002D,
  parameter [15:0] P_INIT_TBUF   = 16'h0037
) (
  // System Interface
  input  SYSCLK,
  input  SYSRST_N,
  input  MODULE_RSTN,
  output I2CM_INT,

  // AHB Interface
  input  SHSEL,
  input  [31:0] SHADDR,
  input  [1:0] SHTRANS,
  input  [2:0] SHSIZE,
  input  [2:0] SHBURST,
  input  SHWRITE,
  input  SHREADYIN,
  output SHREADYOUT,
  input  [31:0] SHWDATA,
  output [31:0] SHRDATA,
  output [1:0] SHRESP,

  // I2C Bus Interface
  inout  I2C_SDA,
  inout  I2C_SCL
);

wire i2cm_resetn;

wire w_ahb_rd;
wire [31:0] w_ahb_addr;
wire w_ahb_wait;
wire w_reg_dphase;
wire w_reg_w1r0;
wire [31:0] w_reg_addr;
wire [3:0] w_reg_byteen;
wire [31:0] w_reg_wdata;
wire [31:0] w_reg_rdata;

wire w_reg_i2cm_en;
wire w_reg_i2cm_sbusy;
wire w_reg_i2cm_obusy;
wire [15:0] w_reg_scl_toprod;
wire [15:0] w_reg_thdsta;
wire [15:0] w_reg_tsusto;
wire [15:0] w_reg_tsusta;
wire [15:0] w_reg_thigh;
wire [15:0] w_reg_thddat;
wire [15:0] w_reg_tsudat;
wire [15:0] w_reg_tbuf;
wire [15:0] w_reg_smpl_delay;
wire w_reg_int_comp;
wire w_reg_int_arb_lst;
wire w_reg_int_ack_err;
wire w_reg_int_bit_err;
wire w_reg_int_scl_to;
wire w_reg_i2cm_en_off;

wire w_reg_txf_wen;
wire [9:0] w_reg_txf_wdata;
wire w_reg_txf_rst;
wire [P_FIFO_DPTBW:0] w_reg_txf_uthl;
wire [P_FIFO_DPTBW:0] w_reg_txf_cap;
wire w_reg_int_txf_uth;
wire w_reg_int_txf_ovf;

wire w_tx_data_ready;

wire w_reg_rxf_ren;
wire [7:0] w_reg_rxf_rdata;
wire w_reg_rxf_rst;
wire [P_FIFO_DPTBW:0] w_reg_rxf_othl;
wire [P_FIFO_DPTBW:0] w_reg_rxf_cap;
wire w_reg_int_rxf_oth;
wire w_reg_int_rxf_udf;

wire w_rx_data_ready;

wire w_main_txf_ren;
wire [9:0] w_main_txf_rdata;
wire w_main_rxf_wen;
wire [7:0] w_main_rxf_wdata;

wire w_sda_in;
wire w_sda_out;
wire w_scl_in;
wire w_scl_out;

assign i2cm_resetn = SYSRST_N & MODULE_RSTN;

// AHB Slave
sc_ahb_slave ahb_slave (
  // AHB Interface
  .HCLK(SYSCLK),             // input
  .HRESETN(i2cm_resetn),     // input
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
  .AHB_RD(w_ahb_rd),         // output
  .AHB_ADDR(w_ahb_addr),     // output [31:0]
  .AHB_WAIT(w_ahb_wait),     // input
  .REG_DPHASE(w_reg_dphase), // output
  .REG_W1R0(w_reg_w1r0),     // output
  .REG_ADDR(w_reg_addr),     // output [31:0]
  .REG_BYTEEN(w_reg_byteen), // output [3:0]
  .REG_WDATA(w_reg_wdata),   // output [31:0]
  .REG_RDATA(w_reg_rdata),   // input  [31:0]
  .REG_ACCERR(1'b0)          // input
);

// I2C Master Controller Register
i2cm_reg # (
  .P_FIFO_DPTBW(P_FIFO_DPTBW),
  .P_INIT_THDSTA(P_INIT_THDSTA),
  .P_INIT_TSUSTO(P_INIT_TSUSTO),
  .P_INIT_TSUSTA(P_INIT_TSUSTA),
  .P_INIT_THIGH(P_INIT_THIGH),
  .P_INIT_THDDAT(P_INIT_THDDAT),
  .P_INIT_TSUDAT(P_INIT_TSUDAT),
  .P_INIT_TBUF(P_INIT_TBUF)
) i2cm_reg (
  // System Interface
  .SYSCLK(SYSCLK),                      // input
  .SYSRST_N(i2cm_resetn),               // input

  // AHB Interface
  .REG_ACC(w_reg_dphase),               // input
  .REG_W1R0(w_reg_w1r0),                // input
  .REG_ADDR(w_reg_addr),                // input [31:0]
  .REG_BYTEEN(w_reg_byteen),            // input [3:0]
  .REG_WDATA(w_reg_wdata),              // input [31:0]
  .REG_RDATA(w_reg_rdata),              // output [31:0]
  .AHB_RD(w_ahb_rd),                    // input
  .AHB_ADDR(w_ahb_addr),                // input [31:0]
  .AHB_WAIT(w_ahb_wait),                // output

  // MAIN Controller Interface
  .REG_I2CM_EN(w_reg_i2cm_en),          // output
  .REG_I2CM_SBUSY(w_reg_i2cm_sbusy),    // input
  .REG_I2CM_OBUSY(w_reg_i2cm_obusy),    // input
  .REG_SCL_TOPROD(w_reg_scl_toprod),    // output [15:0]
  .REG_THDSTA(w_reg_thdsta),            // output [15:0]
  .REG_TSUSTO(w_reg_tsusto),            // output [15:0]
  .REG_TSUSTA(w_reg_tsusta),            // output [15:0]
  .REG_THIGH(w_reg_thigh),              // output [15:0]
  .REG_THDDAT(w_reg_thddat),            // output [15:0]
  .REG_TSUDAT(w_reg_tsudat),            // output [15:0]
  .REG_TBUF(w_reg_tbuf),                // output [15:0]
  .REG_SMPL_DELAY(w_reg_smpl_delay),    // output [15:0]
  .REG_INT_COMP(w_reg_int_comp),        // input
  .REG_INT_ARB_LST(w_reg_int_arb_lst),  // input
  .REG_INT_ACK_ERR(w_reg_int_ack_err),  // input
  .REG_INT_BIT_ERR(w_reg_int_bit_err),  // input
  .REG_INT_SCL_TO(w_reg_int_scl_to),    // input
  .REG_I2CM_EN_OFF(w_reg_i2cm_en_off),  // input

  // TX FIFO Interface
  .REG_TXF_WEN(w_reg_txf_wen),          // output
  .REG_TXF_WDATA(w_reg_txf_wdata),      // output [9:0]
  .REG_TXF_RST(w_reg_txf_rst),          // output
  .REG_TXF_UTHL(w_reg_txf_uthl),        // output [P_FIFO_DPTBW:0]
  .REG_TXF_CAP(w_reg_txf_cap),          // input  [P_FIFO_DPTBW:0]
  .REG_INT_TXF_UTH(w_reg_int_txf_uth),  // input
  .REG_INT_TXF_OVF(w_reg_int_txf_ovf),  // input

  // RX FIFO Interface
  .REG_RXF_REN(w_reg_rxf_ren),          // output
  .REG_RXF_RDATA(w_reg_rxf_rdata),      // input [7:0]
  .REG_RXF_RST(w_reg_rxf_rst),          // output
  .REG_RXF_OTHL(w_reg_rxf_othl),        // output [P_FIFO_DPTBW:0]
  .REG_RXF_CAP(w_reg_rxf_cap),          // input [P_FIFO_DPTBW:0]
  .REG_INT_RXF_OTH(w_reg_int_rxf_oth),  // input
  .REG_INT_RXF_UDF(w_reg_int_rxf_udf),  // input

  // Interrupt Interface
  .I2CM_INT(I2CM_INT)                   // output
);

// TX_FIFO
sc_fifo # (
  .P_FIFO_WIDTH(10),
  .P_FIFO_DEPTH(P_FIFO_DPTBW),
  .P_FIFO_TYPE(P_FIFO_TYPE)              // 0: BlockRAM 1: Shift Register
) tx_fifo (
  .CLK(SYSCLK),                          // input
  .SRST_N(i2cm_resetn),                  // input
  .FIFO_RST(w_reg_txf_rst),              // input

  .WR_EN(w_reg_txf_wen),                 // input
  .DIN(w_reg_txf_wdata),                 // input [P_FIFO_WIDTH-1:0]
  .RD_EN(w_main_txf_ren),                // input
  .DOUT(w_main_txf_rdata),               // output [P_FIFO_WIDTH-1:0]

  .OVER_TH_LVL({P_FIFO_DPTBW+1{1'b0}}),  // input [P_FIFO_DEPTH:0]
  .UNDER_TH_LVL(w_reg_txf_uthl),         // input [P_FIFO_DEPTH:0]

  .FULL(/* open */),                     // output
  .EMPTY(/* open */),                    // output
  .OVERFLOW(w_reg_int_txf_ovf),          // output
  .UNDERFLOW(/* open */),                // output
  .OVER_TH(/* open */),                  // output
  .UNDER_TH(w_reg_int_txf_uth),          // output
  .DATA_COUNT(w_reg_txf_cap)             // output [P_FIFO_DEPTH:0]
);

assign w_tx_data_ready = |w_reg_txf_cap;

// RX_FIFO
sc_fifo # (
  .P_FIFO_WIDTH(8),
  .P_FIFO_DEPTH(P_FIFO_DPTBW),
  .P_FIFO_TYPE(P_FIFO_TYPE)               // 0: BlockRAM 1: Shift Register
) rx_fifo (
  .CLK(SYSCLK),                           // input
  .SRST_N(i2cm_resetn),                   // input
  .FIFO_RST(w_reg_rxf_rst),               // input

  .WR_EN(w_main_rxf_wen),                 // input
  .DIN(w_main_rxf_wdata),                 // input [P_FIFO_WIDTH-1:0]
  .RD_EN(w_reg_rxf_ren),                  // input
  .DOUT(w_reg_rxf_rdata),                 // output [P_FIFO_WIDTH-1:0]

  .OVER_TH_LVL(w_reg_rxf_othl),           // input [P_FIFO_DEPTH:0]
  .UNDER_TH_LVL({P_FIFO_DPTBW+1{1'b0}}),  // input [P_FIFO_DEPTH:0]

  .FULL(/* open */),                      // output
  .EMPTY(/* open */),                     // output
  .OVERFLOW(/* open */),                  // output
  .UNDERFLOW(w_reg_int_rxf_udf),          // output
  .OVER_TH(w_reg_int_rxf_oth),            // output
  .UNDER_TH(/* open */),                  // output
  .DATA_COUNT(w_reg_rxf_cap)              // output [P_FIFO_DEPTH:0]
);

assign w_rx_data_ready = ~w_reg_rxf_cap[P_FIFO_DPTBW];

// I2C Master Main Controller
i2cm_main i2cm_main (
  // System Interface
  .SYSCLK(SYSCLK),                      // input
  .SYSRST_N(i2cm_resetn),               // input

  // Register Interface
  .REG_I2CM_EN(w_reg_i2cm_en),          // input
  .REG_I2CM_SBUSY(w_reg_i2cm_sbusy),    // output
  .REG_I2CM_OBUSY(w_reg_i2cm_obusy),    // output
  .REG_SCL_TOPROD(w_reg_scl_toprod),    // input [15:0]
  .REG_THDSTA(w_reg_thdsta),            // input [15:0]
  .REG_TSUSTO(w_reg_tsusto),            // input [15:0]
  .REG_TSUSTA(w_reg_tsusta),            // input [15:0]
  .REG_THIGH(w_reg_thigh),              // input [15:0]
  .REG_THDDAT(w_reg_thddat),            // input [15:0]
  .REG_TSUDAT(w_reg_tsudat),            // input [15:0]
  .REG_TBUF(w_reg_tbuf),                // input [15:0]
  .REG_SMPL_DELAY(w_reg_smpl_delay),    // input [15:0]
  .REG_INT_COMP(w_reg_int_comp),        // output
  .REG_INT_ARB_LST(w_reg_int_arb_lst),  // output
  .REG_INT_ACK_ERR(w_reg_int_ack_err),  // output
  .REG_INT_BIT_ERR(w_reg_int_bit_err),  // output
  .REG_INT_SCL_TO(w_reg_int_scl_to),    // output
  .REG_I2CM_EN_OFF(w_reg_i2cm_en_off),  // output

  // TX DATA Interface
  .TX_DATA_REQ(w_main_txf_ren),         // output
  .TX_DATA_IN(w_main_txf_rdata),        // input [9:0]
  .TX_DATA_READY(w_tx_data_ready),      // input

  // RX DATA Interface
  .RX_DATA_VAL(w_main_rxf_wen),         // output
  .RX_DATA_OUT(w_main_rxf_wdata),       // output [7:0]
  .RX_DATA_READY(w_rx_data_ready),      // input

  // I2C Interface
  .SDA_IN(w_sda_in),                    // input
  .SDA_OUT(w_sda_out),                  // output
  .SCL_IN(w_scl_in),                    // input
  .SCL_OUT(w_scl_out)                   // output
);

// I2C I/O
i2c_io i2c_io (
  .SDA_IN(w_sda_in),    // output
  .SDA_OUT(w_sda_out),  // input
  .SCL_IN(w_scl_in),    // output
  .SCL_OUT(w_scl_out),  // input

  .SDA_IO(I2C_SDA),     // inout
  .SCL_IO(I2C_SCL)      // inout
);

endmodule
