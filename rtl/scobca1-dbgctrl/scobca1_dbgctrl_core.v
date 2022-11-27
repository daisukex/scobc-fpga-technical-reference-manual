//-----------------------------------------------
// Space Cubics SC-OBC-A1
// SC-OBC-A1 Debug Controller Core Module
// Module: scobca1_dbgctrl_core
//-----------------------------------------------
// Copyright © 2022 Space Cubics, LLC.
//-----------------------------------------------

module scobca1_dbgctrl_core (
  // System Interface
  input  SYS_CLK,
  input  SYS_RSTB,

  // FPGA Interface
  inout  [19:0] SRAM_A,
  inout  SRAM1_CE_B,
  inout  SRAM1_OE_B,
  inout  SRAM1_WE_B,
  inout  SRAM1_BHE_B,
  inout  SRAM1_BLE_B,
  inout  SRAM2_CE_B,
  inout  SRAM2_OE_B,
  inout  SRAM2_WE_B,
  inout  SRAM2_BHE_B,
  inout  SRAM2_BLE_B,
  input  [15:0] SRAM1_IO,
  input  [15:0] SRAM2_IO,

  inout  CFG_MEM_CS_B,
  inout  [3:0] CFG_MEM_IO,

  inout  DATA_MEM1_CS_B,
  inout  [3:0] DATA_MEM1_IO,

  inout  DATA_MEM2_CS_B,
  inout  [3:0] DATA_MEM2_IO,

  inout  FRAM1_CS_B,
  inout  [3:0] FRAM1_IO,

  inout  FRAM2_CS_B,
  inout  [3:0] FRAM2_IO,

  input  SYSCLK1,
  input  SYSCLK2,

  inout  FPGA_EXT_SCL,
  inout  FPGA_EXT_SDA,

  inout  FPGA_BOOT0,
  inout  FPGA_BOOT1,
  inout  FPGA_WATCHDOG,
  inout  FPGA_RESERVE,
  inout  FPGA_PWR_CYCLE_REQ,

  input  ULPI_CLOCK,
  inout  ULPI_RESET_B,
  inout  ULPI_CS,

  inout  [15:0] UIO1,
  inout  [15:0] UIO2,
  inout  [5:0] UIO4,

  inout  [15:0] RSV,

  // IP Interface
  input  [19:0] SRAM_A_IPOUT,
  input  SRAM1_CE_B_IPOUT,
  input  SRAM1_OE_B_IPOUT,
  input  SRAM1_WE_B_IPOUT,
  input  SRAM1_BHE_B_IPOUT,
  input  SRAM1_BLE_B_IPOUT,
  input  SRAM2_CE_B_IPOUT,
  input  SRAM2_OE_B_IPOUT,
  input  SRAM2_WE_B_IPOUT,
  input  SRAM2_BHE_B_IPOUT,
  input  SRAM2_BLE_B_IPOUT,

  input  CFG_MEM_CS_B_IPOUT,
  input  [3:0] CFG_MEM_OE_IPOUT,
  input  [3:0] CFG_MEM_DOUT_IPOUT,
  output [3:0] CFG_MEM_DIN_IPIN,

  input  DATA_MEM1_CS_B_IPOUT,
  input  [3:0] DATA_MEM1_OE_IPOUT,
  input  [3:0] DATA_MEM1_DOUT_IPOUT,
  output [3:0] DATA_MEM1_DIN_IPIN,

  input  DATA_MEM2_CS_B_IPOUT,
  input  [3:0] DATA_MEM2_OE_IPOUT,
  input  [3:0] DATA_MEM2_DOUT_IPOUT,
  output [3:0] DATA_MEM2_DIN_IPIN,

  input  FRAM1_CS_B_IPOUT,
  input  [3:0] FRAM1_OE_IPOUT,
  input  [3:0] FRAM1_DOUT_IPOUT,
  output [3:0] FRAM1_DIN_IPIN,

  input  FRAM2_CS_B_IPOUT,
  input  [3:0] FRAM2_OE_IPOUT,
  input  [3:0] FRAM2_DOUT_IPOUT,
  output [3:0] FRAM2_DIN_IPIN,

  input  FPGA_WATCHDOG_IPOUT,
  input  FPGA_PWR_CYCLE_REQ_IPOUT,

  input  [15:0] RSV_IPOUT,
  output [15:0] RSV_IPIN,

  // Debug Register Interface
  input  [2*20-1:0] SRAM_A_GPIO_MODE_SEL,
  input  [1:0] SRAM1_CE_B_GPIO_MODE_SEL,
  input  [1:0] SRAM1_OE_B_GPIO_MODE_SEL,
  input  [1:0] SRAM1_WE_B_GPIO_MODE_SEL,
  input  [1:0] SRAM1_BHE_B_GPIO_MODE_SEL,
  input  [1:0] SRAM1_BLE_B_GPIO_MODE_SEL,
  input  [1:0] SRAM2_CE_B_GPIO_MODE_SEL,
  input  [1:0] SRAM2_OE_B_GPIO_MODE_SEL,
  input  [1:0] SRAM2_WE_B_GPIO_MODE_SEL,
  input  [1:0] SRAM2_BHE_B_GPIO_MODE_SEL,
  input  [1:0] SRAM2_BLE_B_GPIO_MODE_SEL,
  output [19:0] SRAM_A_GPIO_IN,
  output SRAM1_CE_B_GPIO_IN,
  output SRAM1_OE_B_GPIO_IN,
  output SRAM1_WE_B_GPIO_IN,
  output SRAM1_BHE_B_GPIO_IN,
  output SRAM1_BLE_B_GPIO_IN,
  output SRAM2_CE_B_GPIO_IN,
  output SRAM2_OE_B_GPIO_IN,
  output SRAM2_WE_B_GPIO_IN,
  output SRAM2_BHE_B_GPIO_IN,
  output SRAM2_BLE_B_GPIO_IN,

  input  [1:0] CFG_MEM_CS_B_GPIO_MODE_SEL,
  input  [2*4-1:0] CFG_MEM_IO_GPIO_MODE_SEL,
  output CFG_MEM_CS_B_GPIO_IN,
  output [3:0] CFG_MEM_IO_GPIO_IN,

  input  [1:0] DATA_MEM1_CS_B_GPIO_MODE_SEL,
  input  [2*4-1:0] DATA_MEM1_IO_GPIO_MODE_SEL,
  input  [1:0] DATA_MEM2_CS_B_GPIO_MODE_SEL,
  input  [2*4-1:0] DATA_MEM2_IO_GPIO_MODE_SEL,
  output DATA_MEM1_CS_B_GPIO_IN,
  output [3:0] DATA_MEM1_IO_GPIO_IN,
  output DATA_MEM2_CS_B_GPIO_IN,
  output [3:0] DATA_MEM2_IO_GPIO_IN,

  input  [1:0] FRAM1_CS_B_GPIO_MODE_SEL,
  input  [2*4-1:0] FRAM1_IO_GPIO_MODE_SEL,
  input  [1:0] FRAM2_CS_B_GPIO_MODE_SEL,
  input  [2*4-1:0] FRAM2_IO_GPIO_MODE_SEL,
  output FRAM1_CS_B_GPIO_IN,
  output [3:0] FRAM1_IO_GPIO_IN,
  output FRAM2_CS_B_GPIO_IN,
  output [3:0] FRAM2_IO_GPIO_IN,

  output SYSCLK2_STATE,
  output SYSCLK1_STATE,

  input  [1:0] EXT_I2C_SCL_GPIO_MODE_SEL,
  input  [1:0] EXT_I2C_SDA_GPIO_MODE_SEL,
  output EXT_I2C_SCL_GPIO_IN,
  output EXT_I2C_SDA_GPIO_IN,

  output reg [31:0] FPGA_BOOT_SHIFTREG_IN,
  input  [1:0] FPGA_BOOT0_GPIO_MODE_SEL,
  output FPGA_BOOT0_GPIO_IN,
  input  [1:0] FPGA_BOOT1_GPIO_MODE_SEL,
  output FPGA_BOOT1_GPIO_IN,
  input  [1:0] FPGA_WATCHDOG_GPIO_MODE_SEL,
  input  [1:0] FPGA_PWR_CYCLE_REQ_GPIO_MODE_SEL,
  input  [1:0] FPGA_RESERVE_GPIO_MODE_SEL,
  output FPGA_WATCHDOG_GPIO_IN,
  output FPGA_PWR_CYCLE_REQ_GPIO_IN,
  output FPGA_RESERVE_GPIO_IN,

  output ULPI_CLOCK_STATE,
  input  [1:0] ULPI_RESET_B_GPIO_MODE_SEL,
  input  [1:0] ULPI_CS_GPIO_MODE_SEL,
  output ULPI_RESET_B_GPIO_IN,
  output ULPI_CS_GPIO_IN,

  input  [2*16-1:0] UIO1_GPIO_MODE_SEL,
  output [15:0] UIO1_GPIO_IN,

  input  [2*16-1:0] UIO2_GPIO_MODE_SEL,
  output [15:0] UIO2_GPIO_IN,

  input  [2*6-1:0] UIO4_GPIO_MODE_SEL,
  output [5:0] UIO4_GPIO_IN,

  input  [2*16-1:0] RSV_GPIO_MODE_SEL,
  output [15:0] RSV_GPIO_IN
);

genvar gn;

// SRAM I/F GPIO Control
generate
  for(gn=0; gn<20; gn=gn+1) begin : sram_a_gen
    assign SRAM_A[gn] = (SRAM_A_GPIO_MODE_SEL[gn*2 +: 2] == 2'b00) ? SRAM_A_IPOUT[gn]:
                        (SRAM_A_GPIO_MODE_SEL[gn*2 +: 2] == 2'b01) ? 1'bz:
                        (SRAM_A_GPIO_MODE_SEL[gn*2 +: 2] == 2'b10) ? 1'b0: 1'b1;
    assign SRAM_A_GPIO_IN[gn] = SRAM_A[gn];
  end
endgenerate

assign SRAM1_CE_B = (SRAM1_CE_B_GPIO_MODE_SEL == 2'b00) ? SRAM1_CE_B_IPOUT:
                    (SRAM1_CE_B_GPIO_MODE_SEL == 2'b01) ? 1'bz:
                    (SRAM1_CE_B_GPIO_MODE_SEL == 2'b10) ? 1'b0: 1'b1;
assign SRAM1_CE_B_GPIO_IN = SRAM1_CE_B;

assign SRAM1_OE_B = (SRAM1_OE_B_GPIO_MODE_SEL == 2'b00) ? SRAM1_OE_B_IPOUT:
                    (SRAM1_OE_B_GPIO_MODE_SEL == 2'b01) ? 1'bz:
                    (SRAM1_OE_B_GPIO_MODE_SEL == 2'b10) ? 1'b0: 1'b1;
assign SRAM1_OE_B_GPIO_IN = SRAM1_OE_B;

assign SRAM1_WE_B = (SRAM1_WE_B_GPIO_MODE_SEL == 2'b00) ? SRAM1_WE_B_IPOUT:
                    (SRAM1_WE_B_GPIO_MODE_SEL == 2'b01) ? 1'bz:
                    (SRAM1_WE_B_GPIO_MODE_SEL == 2'b10) ? 1'b0: 1'b1;
assign SRAM1_WE_B_GPIO_IN = SRAM1_WE_B;

assign SRAM1_BHE_B = (SRAM1_BHE_B_GPIO_MODE_SEL == 2'b00) ? SRAM1_BHE_B_IPOUT:
                     (SRAM1_BHE_B_GPIO_MODE_SEL == 2'b01) ? 1'bz:
                     (SRAM1_BHE_B_GPIO_MODE_SEL == 2'b10) ? 1'b0: 1'b1;
assign SRAM1_BHE_B_GPIO_IN = SRAM1_BHE_B;

assign SRAM1_BLE_B = (SRAM1_BLE_B_GPIO_MODE_SEL == 2'b00) ? SRAM1_BLE_B_IPOUT:
                     (SRAM1_BLE_B_GPIO_MODE_SEL == 2'b01) ? 1'bz:
                     (SRAM1_BLE_B_GPIO_MODE_SEL == 2'b10) ? 1'b0: 1'b1;
assign SRAM1_BLE_B_GPIO_IN = SRAM1_BLE_B;

assign SRAM2_CE_B = (SRAM2_CE_B_GPIO_MODE_SEL == 2'b00) ? SRAM2_CE_B_IPOUT:
                    (SRAM2_CE_B_GPIO_MODE_SEL == 2'b01) ? 1'bz:
                    (SRAM2_CE_B_GPIO_MODE_SEL == 2'b10) ? 1'b0: 1'b1;
assign SRAM2_CE_B_GPIO_IN = SRAM2_CE_B;

assign SRAM2_OE_B = (SRAM2_OE_B_GPIO_MODE_SEL == 2'b00) ? SRAM2_OE_B_IPOUT:
                    (SRAM2_OE_B_GPIO_MODE_SEL == 2'b01) ? 1'bz:
                    (SRAM2_OE_B_GPIO_MODE_SEL == 2'b10) ? 1'b0: 1'b1;
assign SRAM2_OE_B_GPIO_IN = SRAM2_OE_B;

assign SRAM2_WE_B = (SRAM2_WE_B_GPIO_MODE_SEL == 2'b00) ? SRAM2_WE_B_IPOUT:
                    (SRAM2_WE_B_GPIO_MODE_SEL == 2'b01) ? 1'bz:
                    (SRAM2_WE_B_GPIO_MODE_SEL == 2'b10) ? 1'b0: 1'b1;
assign SRAM2_WE_B_GPIO_IN = SRAM2_WE_B;

assign SRAM2_BHE_B = (SRAM2_BHE_B_GPIO_MODE_SEL == 2'b00) ? SRAM2_BHE_B_IPOUT:
                     (SRAM2_BHE_B_GPIO_MODE_SEL == 2'b01) ? 1'bz:
                     (SRAM2_BHE_B_GPIO_MODE_SEL == 2'b10) ? 1'b0: 1'b1;
assign SRAM2_BHE_B_GPIO_IN = SRAM2_BHE_B;

assign SRAM2_BLE_B = (SRAM2_BLE_B_GPIO_MODE_SEL == 2'b00) ? SRAM2_BLE_B_IPOUT:
                     (SRAM2_BLE_B_GPIO_MODE_SEL == 2'b01) ? 1'bz:
                     (SRAM2_BLE_B_GPIO_MODE_SEL == 2'b10) ? 1'b0: 1'b1;
assign SRAM2_BLE_B_GPIO_IN = SRAM2_BLE_B;

// CFG_MEM I/F GPIO Control
assign CFG_MEM_CS_B = (CFG_MEM_CS_B_GPIO_MODE_SEL == 2'b00) ? CFG_MEM_CS_B_IPOUT:
                      (CFG_MEM_CS_B_GPIO_MODE_SEL == 2'b01) ? 1'bz:
                      (CFG_MEM_CS_B_GPIO_MODE_SEL == 2'b10) ? 1'b0: 1'b1;
assign CFG_MEM_CS_B_GPIO_IN = CFG_MEM_CS_B;

wire [3:0] w_cfg_mem_oe;
wire [3:0] w_cfg_mem_dout;
generate
  for(gn=0; gn<4; gn=gn+1) begin : cfg_mem_io_gen
    assign w_cfg_mem_oe[gn] = (CFG_MEM_IO_GPIO_MODE_SEL[gn*2 +: 2] == 2'b00) ? CFG_MEM_OE_IPOUT[gn]:
                              (CFG_MEM_IO_GPIO_MODE_SEL[gn*2 +: 2] == 2'b01) ? 1'b0: 1'b1;
    assign w_cfg_mem_dout[gn] = (CFG_MEM_IO_GPIO_MODE_SEL[gn*2 +: 2] == 2'b00) ? CFG_MEM_DOUT_IPOUT[gn]:
                                (CFG_MEM_IO_GPIO_MODE_SEL[gn*2 +: 2] == 2'b11) ? 1'b1: 1'b0;
  end
endgenerate
sc_qspim_data_io cfg_mem_qspi_data_io (
  .QSPI_OE(w_cfg_mem_oe),
  .QSPI_DOUT(w_cfg_mem_dout),
  .QSPI_DIN(CFG_MEM_DIN_IPIN),
  .QSPI_IO(CFG_MEM_IO)
);
assign CFG_MEM_IO_GPIO_IN = CFG_MEM_IO;

// DATA_MEM1 I/F GPIO Control
assign DATA_MEM1_CS_B = (DATA_MEM1_CS_B_GPIO_MODE_SEL == 2'b00) ? DATA_MEM1_CS_B_IPOUT:
                        (DATA_MEM1_CS_B_GPIO_MODE_SEL == 2'b01) ? 1'bz:
                        (DATA_MEM1_CS_B_GPIO_MODE_SEL == 2'b10) ? 1'b0: 1'b1;
assign DATA_MEM1_CS_B_GPIO_IN = DATA_MEM1_CS_B;

wire [3:0] w_data_mem1_oe;
wire [3:0] w_data_mem1_dout;
generate
  for(gn=0; gn<4; gn=gn+1) begin : data_mem1_io_gen
    assign w_data_mem1_oe[gn] = (DATA_MEM1_IO_GPIO_MODE_SEL[gn*2 +: 2] == 2'b00) ? DATA_MEM1_OE_IPOUT[gn]:
                                (DATA_MEM1_IO_GPIO_MODE_SEL[gn*2 +: 2] == 2'b01) ? 1'b0: 1'b1;
    assign w_data_mem1_dout[gn] = (DATA_MEM1_IO_GPIO_MODE_SEL[gn*2 +: 2] == 2'b00) ? DATA_MEM1_DOUT_IPOUT[gn]:
                                  (DATA_MEM1_IO_GPIO_MODE_SEL[gn*2 +: 2] == 2'b11) ? 1'b1: 1'b0;
  end
endgenerate
sc_qspim_data_io data_mem1_qspi_data_io (
  .QSPI_OE(w_data_mem1_oe),
  .QSPI_DOUT(w_data_mem1_dout),
  .QSPI_DIN(DATA_MEM1_DIN_IPIN),
  .QSPI_IO(DATA_MEM1_IO)
);
assign DATA_MEM1_IO_GPIO_IN = DATA_MEM1_IO;

// DATA_MEM2 I/F GPIO Control
assign DATA_MEM2_CS_B = (DATA_MEM2_CS_B_GPIO_MODE_SEL == 2'b00) ? DATA_MEM2_CS_B_IPOUT:
                        (DATA_MEM2_CS_B_GPIO_MODE_SEL == 2'b01) ? 1'bz:
                        (DATA_MEM2_CS_B_GPIO_MODE_SEL == 2'b10) ? 1'b0: 1'b1;
assign DATA_MEM2_CS_B_GPIO_IN = DATA_MEM2_CS_B;

wire [3:0] w_data_mem2_oe;
wire [3:0] w_data_mem2_dout;
generate
  for(gn=0; gn<4; gn=gn+1) begin : data_mem2_io_gen
    assign w_data_mem2_oe[gn] = (DATA_MEM2_IO_GPIO_MODE_SEL[gn*2 +: 2] == 2'b00) ? DATA_MEM2_OE_IPOUT[gn]:
                                (DATA_MEM2_IO_GPIO_MODE_SEL[gn*2 +: 2] == 2'b01) ? 1'b0: 1'b1;
    assign w_data_mem2_dout[gn] = (DATA_MEM2_IO_GPIO_MODE_SEL[gn*2 +: 2] == 2'b00) ? DATA_MEM2_DOUT_IPOUT[gn]:
                                  (DATA_MEM2_IO_GPIO_MODE_SEL[gn*2 +: 2] == 2'b11) ? 1'b1: 1'b0;
  end
endgenerate
sc_qspim_data_io data_mem2_qspi_data_io (
  .QSPI_OE(w_data_mem2_oe),
  .QSPI_DOUT(w_data_mem2_dout),
  .QSPI_DIN(DATA_MEM2_DIN_IPIN),
  .QSPI_IO(DATA_MEM2_IO)
);
assign DATA_MEM2_IO_GPIO_IN = DATA_MEM2_IO;

// FRAM1 I/F GPIO Control
assign FRAM1_CS_B = (FRAM1_CS_B_GPIO_MODE_SEL == 2'b00) ? FRAM1_CS_B_IPOUT:
                    (FRAM1_CS_B_GPIO_MODE_SEL == 2'b01) ? 1'bz:
                    (FRAM1_CS_B_GPIO_MODE_SEL == 2'b10) ? 1'b0: 1'b1;
assign FRAM1_CS_B_GPIO_IN = FRAM1_CS_B;

wire [3:0] w_fram1_oe;
wire [3:0] w_fram1_dout;
generate
  for(gn=0; gn<4; gn=gn+1) begin : fram1_io_gen
    assign w_fram1_oe[gn] = (FRAM1_IO_GPIO_MODE_SEL[gn*2 +: 2] == 2'b00) ? FRAM1_OE_IPOUT[gn]:
                            (FRAM1_IO_GPIO_MODE_SEL[gn*2 +: 2] == 2'b01) ? 1'b0: 1'b1;
    assign w_fram1_dout[gn] = (FRAM1_IO_GPIO_MODE_SEL[gn*2 +: 2] == 2'b00) ? FRAM1_DOUT_IPOUT[gn]:
                              (FRAM1_IO_GPIO_MODE_SEL[gn*2 +: 2] == 2'b11) ? 1'b1: 1'b0;
  end
endgenerate
sc_qspim_data_io fram1_qspi_data_io (
  .QSPI_OE(w_fram1_oe),
  .QSPI_DOUT(w_fram1_dout),
  .QSPI_DIN(FRAM1_DIN_IPIN),
  .QSPI_IO(FRAM1_IO)
);
assign FRAM1_IO_GPIO_IN = FRAM1_IO;

// FRAM2 I/F GPIO Control
assign FRAM2_CS_B = (FRAM2_CS_B_GPIO_MODE_SEL == 2'b00) ? FRAM2_CS_B_IPOUT:
                    (FRAM2_CS_B_GPIO_MODE_SEL == 2'b01) ? 1'bz:
                    (FRAM2_CS_B_GPIO_MODE_SEL == 2'b10) ? 1'b0: 1'b1;
assign FRAM2_CS_B_GPIO_IN = FRAM2_CS_B;

wire [3:0] w_fram2_oe;
wire [3:0] w_fram2_dout;
generate
  for(gn=0; gn<4; gn=gn+1) begin : fram2_io_gen
    assign w_fram2_oe[gn] = (FRAM2_IO_GPIO_MODE_SEL[gn*2 +: 2] == 2'b00) ? FRAM2_OE_IPOUT[gn]:
                            (FRAM2_IO_GPIO_MODE_SEL[gn*2 +: 2] == 2'b01) ? 1'b0: 1'b1;
    assign w_fram2_dout[gn] = (FRAM2_IO_GPIO_MODE_SEL[gn*2 +: 2] == 2'b00) ? FRAM2_DOUT_IPOUT[gn]:
                              (FRAM2_IO_GPIO_MODE_SEL[gn*2 +: 2] == 2'b11) ? 1'b1: 1'b0;
  end
endgenerate
sc_qspim_data_io fram2_qspi_data_io (
  .QSPI_OE(w_fram2_oe),
  .QSPI_DOUT(w_fram2_dout),
  .QSPI_DIN(FRAM2_DIN_IPIN),
  .QSPI_IO(FRAM2_IO)
);
assign FRAM2_IO_GPIO_IN = FRAM2_IO;

// OSC I/F Monitor
clk_checker # (
  .DIV_COUNT(8),
  .DIV_BUS_WIDTH(3),
  .CHK_LIMIT(255),
  .CHK_BUS_WIDTH(8)
) sysclk1_chk (
  .TARGET_CLK(SYSCLK1),
  .HCLK(SYS_CLK),
  .HRESETN(SYS_RSTB),
  .CLK_STATE(SYSCLK1_STATE),
  .CLK_STOP(/*open*/)
);

clk_checker # (
  .DIV_COUNT(8),
  .DIV_BUS_WIDTH(3),
  .CHK_LIMIT(255),
  .CHK_BUS_WIDTH(8)
) sysclk2_chk (
  .TARGET_CLK(SYSCLK2),
  .HCLK(SYS_CLK),
  .HRESETN(SYS_RSTB),
  .CLK_STATE(SYSCLK2_STATE),
  .CLK_STOP(/*open*/)
);

// External I2C I/F GPIO Control
assign FPGA_EXT_SCL = (EXT_I2C_SCL_GPIO_MODE_SEL == 2'b00) ? 1'bz:
                      (EXT_I2C_SCL_GPIO_MODE_SEL == 2'b01) ? 1'bz:
                      (EXT_I2C_SCL_GPIO_MODE_SEL == 2'b10) ? 1'b0: 1'bz;
assign EXT_I2C_SCL_GPIO_IN = FPGA_EXT_SCL;

assign FPGA_EXT_SDA = (EXT_I2C_SDA_GPIO_MODE_SEL == 2'b00) ? 1'bz:
                      (EXT_I2C_SDA_GPIO_MODE_SEL == 2'b01) ? 1'bz:
                      (EXT_I2C_SDA_GPIO_MODE_SEL == 2'b10) ? 1'b0: 1'bz;
assign EXT_I2C_SDA_GPIO_IN = FPGA_EXT_SDA;

// FPGA_BOOT Monitor
wire boot_clk;
BUFR boot_clk_bufr (
  .O(boot_clk),
  .CE(1'b1),
  .CLR(1'b0),
  .I(FPGA_BOOT1)
);
always @ (posedge boot_clk)
  FPGA_BOOT_SHIFTREG_IN <= {FPGA_BOOT_SHIFTREG_IN[30:0], FPGA_BOOT0};

// FPGA BOOT0 Control
assign FPGA_BOOT0 = (FPGA_BOOT0_GPIO_MODE_SEL == 2'b00) ? 1'bz:
                    (FPGA_BOOT0_GPIO_MODE_SEL == 2'b01) ? 1'bz:
                    (FPGA_BOOT0_GPIO_MODE_SEL == 2'b10) ? 1'b0: 1'b1;
assign FPGA_BOOT0_GPIO_IN = FPGA_BOOT0;

// FPGA BOOT1 Control
assign FPGA_BOOT1 = (FPGA_BOOT1_GPIO_MODE_SEL == 2'b00) ? 1'bz:
                    (FPGA_BOOT1_GPIO_MODE_SEL == 2'b01) ? 1'bz:
                    (FPGA_BOOT1_GPIO_MODE_SEL == 2'b10) ? 1'b0: 1'b1;
assign FPGA_BOOT1_GPIO_IN = FPGA_BOOT1;

// TRCH I/F GPIO Control
assign FPGA_WATCHDOG = (FPGA_WATCHDOG_GPIO_MODE_SEL == 2'b00) ? FPGA_WATCHDOG_IPOUT:
                       (FPGA_WATCHDOG_GPIO_MODE_SEL == 2'b01) ? 1'bz:
                       (FPGA_WATCHDOG_GPIO_MODE_SEL == 2'b10) ? 1'b0: 1'b1;
assign FPGA_WATCHDOG_GPIO_IN = FPGA_WATCHDOG;

assign FPGA_PWR_CYCLE_REQ = (FPGA_PWR_CYCLE_REQ_GPIO_MODE_SEL == 2'b00) ? FPGA_PWR_CYCLE_REQ_IPOUT:
                            (FPGA_PWR_CYCLE_REQ_GPIO_MODE_SEL == 2'b01) ? 1'bz:
                            (FPGA_PWR_CYCLE_REQ_GPIO_MODE_SEL == 2'b10) ? 1'b0: 1'b1;
assign FPGA_PWR_CYCLE_REQ_GPIO_IN = FPGA_PWR_CYCLE_REQ;

assign FPGA_RESERVE = (FPGA_RESERVE_GPIO_MODE_SEL == 2'b00) ? 1'bz:
                      (FPGA_RESERVE_GPIO_MODE_SEL == 2'b01) ? 1'bz:
                      (FPGA_RESERVE_GPIO_MODE_SEL == 2'b10) ? 1'b0: 1'b1;
assign FPGA_RESERVE_GPIO_IN = FPGA_RESERVE;

// ULPI I/F Monitor
clk_checker # (
  .DIV_COUNT(8),
  .DIV_BUS_WIDTH(3),
  .CHK_LIMIT(255),
  .CHK_BUS_WIDTH(8)
) ulpi_clock_chk (
  .TARGET_CLK(ULPI_CLOCK),
  .HCLK(SYS_CLK),
  .HRESETN(SYS_RSTB),
  .CLK_STATE(ULPI_CLOCK_STATE),
  .CLK_STOP(/*open*/)
);

// ULPI I/F GPIO Control
assign ULPI_RESET_B = (ULPI_RESET_B_GPIO_MODE_SEL == 2'b00) ? 1'bz:
                      (ULPI_RESET_B_GPIO_MODE_SEL == 2'b01) ? 1'bz:
                      (ULPI_RESET_B_GPIO_MODE_SEL == 2'b10) ? 1'b0: 1'b1;
assign ULPI_RESET_B_GPIO_IN = ULPI_RESET_B;

assign ULPI_CS = (ULPI_CS_GPIO_MODE_SEL == 2'b00) ? 1'bz:
                 (ULPI_CS_GPIO_MODE_SEL == 2'b01) ? 1'bz:
                 (ULPI_CS_GPIO_MODE_SEL == 2'b10) ? 1'b0: 1'b1;
assign ULPI_CS_GPIO_IN = ULPI_CS;

// UIO1 I/F GPIO Control
generate
  for(gn=0; gn<16; gn=gn+1) begin : uio1_gen
    assign UIO1[gn] = (UIO1_GPIO_MODE_SEL[gn*2 +: 2] == 2'b00) ? 1'bz:
                      (UIO1_GPIO_MODE_SEL[gn*2 +: 2] == 2'b01) ? 1'bz:
                      (UIO1_GPIO_MODE_SEL[gn*2 +: 2] == 2'b10) ? 1'b0: 1'b1;
    assign UIO1_GPIO_IN[gn] = UIO1[gn];
  end
endgenerate

// UIO2 I/F GPIO Control
generate
  for(gn=0; gn<16; gn=gn+1) begin : uio2_gen
    assign UIO2[gn] = (UIO2_GPIO_MODE_SEL[gn*2 +: 2] == 2'b00) ? 1'bz:
                      (UIO2_GPIO_MODE_SEL[gn*2 +: 2] == 2'b01) ? 1'bz:
                      (UIO2_GPIO_MODE_SEL[gn*2 +: 2] == 2'b10) ? 1'b0: 1'b1;
    assign UIO2_GPIO_IN[gn] = UIO2[gn];
  end
endgenerate

// UIO4 I/F GPIO Control
generate
  for(gn=0; gn<6; gn=gn+1) begin : uio4_gen
    assign UIO4[gn] = (UIO4_GPIO_MODE_SEL[gn*2 +: 2] == 2'b00) ? 1'bz:
                      (UIO4_GPIO_MODE_SEL[gn*2 +: 2] == 2'b01) ? 1'bz:
                      (UIO4_GPIO_MODE_SEL[gn*2 +: 2] == 2'b10) ? 1'b0: 1'b1;
    assign UIO4_GPIO_IN[gn] = UIO4[gn];
  end
endgenerate

// RSV I/F GPIO Control
generate
  for(gn=0; gn<16; gn=gn+1) begin : rsv_gen
    assign RSV[gn] = (RSV_GPIO_MODE_SEL[gn*2 +: 2] == 2'b00) ? RSV_IPOUT[gn]:
                     (RSV_GPIO_MODE_SEL[gn*2 +: 2] == 2'b01) ? 1'bz:
                     (RSV_GPIO_MODE_SEL[gn*2 +: 2] == 2'b10) ? 1'b0: 1'b1;
    assign RSV_GPIO_IN[gn] = RSV[gn];
    assign RSV_IPIN[gn] = RSV[gn];
  end
endgenerate

endmodule
