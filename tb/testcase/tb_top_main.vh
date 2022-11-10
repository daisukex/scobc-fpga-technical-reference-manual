//-----------------------------------------------
// Space Cubics OBC A1 FPGA
//  Testbench main module
//  Module: tb_top_main.vh
//-----------------------------------------------
// Copyright © 2022 Space Cubics, LLC.
//-----------------------------------------------

parameter BUILD_INFO = 32'h00000000;
localparam SYSCLK_PERIOD = 41666;
localparam I2CCLK_PERIOD = 33333;

reg clken_ignore = 0;
reg sysclk1 = 0;
wire sysclk1en;
initial begin
  forever begin
    #(SYSCLK_PERIOD/2);
    if (sysclk1en | clken_ignore)
      sysclk1 = ~sysclk1;
  end
end

reg sysclk2 = 0;
wire sysclk2en;
initial begin
  forever begin
    #(SYSCLK_PERIOD/2);
    if (sysclk2en | clken_ignore)
      sysclk2 = ~sysclk2;
  end
end

reg i2cclk = 0;
initial begin
  forever begin
    #(I2CCLK_PERIOD/2);
    i2cclk = ~i2cclk;
  end
end

wire SYS_CLK  = dut.sys_clk;
wire SYS_RSTB = dut.sys_rstb;
wire REF_CLK  = dut.ref_clk;
wire PLLLOCK  = dut.plllock;
wire CMC_REQ  = dut.cmc_req;
wire CMC_ACK  = dut.cmc_ack;
wire cfg_mem_sel;
wire cfg_mem_mon;
reg [1:0] FPGA_BOOT = 2'b01;
wire FPGA_WATCHDOG;
wire pwr_cycle_req;

wire (pull1, pull0) cm3_tms_swdio = 1'b0;
wire console_tx;
wire console_rx;
wire can_tx;
wire can_rx = can_tx;

wire [19:0] sram_a;
wire sram1_ce_b;
wire sram1_oe_b;
wire sram1_we_b;
wire sram1_bhe_b;
wire sram1_ble_b;
wire sram1_err;
wire [15:0] sram1_io;
wire sram2_ce_b;
wire sram2_oe_b;
wire sram2_we_b;
wire sram2_bhe_b;
wire sram2_ble_b;
wire sram2_err;
wire [15:0] sram2_io;

wire ulpi_cs;
wire ulpi_clock;
wire ulpi_reset_b;
wire ulpi_dir;
wire ulpi_nxt;
wire ulpi_stp;
wire [7:0] ulpi_data;
wire ulpi_refclk;

wire (pull1, pull0) internal_i2cm_sda = 1'b1;
wire (pull1, pull0) internal_i2cm_scl = 1'b1;
wire (pull1, pull0) external_i2cm_sda = 1'b1;
wire (pull1, pull0) external_i2cm_scl = 1'b1;
wire cfg_mem_sck = dut.cfg_mem_sck;
wire cfg_mem_cs_b;
wire (pull1, pull0) [3:0] cfg_mem_io = 4'b1111;
wire data_mem1_sck;
wire data_mem1_cs_b;
wire (pull1, pull0) [3:0] data_mem1_io = 4'b1111;
wire data_mem2_sck;
wire data_mem2_cs_b;
wire (pull1, pull0) [3:0] data_mem2_io = 4'b1111;
wire fram1_sck;
wire fram1_cs_b;
wire (pull1, pull0) [3:0] fram1_io = 4'b1111;
wire fram2_sck;
wire fram2_cs_b;
wire (pull1, pull0) [3:0] fram2_io = 4'b1111;

sc_obc_a1_fpga # (
  .BUILD_INFO(BUILD_INFO),
  .SYSCTRL_USER_CLK1_DIVIDE(100),
  .SYSCTRL_USER_CLK1_MODE(0),
  .SYSCTRL_USER_CLK2_DIVIDE(100),
  .SYSCTRL_USER_CLK2_MODE(0),
  .CM3SS_UDL_ISR_NUM(16),
  .MAINAXI_UDL_M_AXI_ID_WIDTH(2),
  .MAINAXI_S_AXI_ID_WIDTH(3)
) dut (
  // System Interface
  .SYSCLK1(sysclk1),
  .SYSCLK1_EN(sysclk1en),
  .SYSCLK2(sysclk2),
  .SYSCLK2_EN(sysclk2en),
  .CDRST_B(1'b1),

  // Debug Interface
  .CM3_NTRST(console_rx),
  .CM3_TDI(1'b0),
  .CM3_TCK_SWCLK(1'b0),
  .CM3_TMS_SWDIO(cm3_tms_swdio),
  .CM3_TDO_SWO(/*open*/),

  // SRAM Interface
  .SRAM_A(sram_a),
  .SRAM1_CE_B(sram1_ce_b),
  .SRAM1_OE_B(sram1_oe_b),
  .SRAM1_WE_B(sram1_we_b),
  .SRAM1_BHE_B(sram1_bhe_b),
  .SRAM1_BLE_B(sram1_ble_b),
  .SRAM1_ERR(sram1_err),
  .SRAM1_IO(sram1_io),
  .SRAM2_CE_B(sram2_ce_b),
  .SRAM2_OE_B(sram2_oe_b),
  .SRAM2_WE_B(sram2_we_b),
  .SRAM2_BHE_B(sram2_bhe_b),
  .SRAM2_BLE_B(sram2_ble_b),
  .SRAM2_ERR(sram2_err),
  .SRAM2_IO(sram2_io),

  // CFG QSPI Flash Interface
  .CFG_MEM_SEL(cfg_mem_sel),
  .CFG_MEM_MON(cfg_mem_mon),
  .CFG_MEM_CS_B(cfg_mem_cs_b),
  .CFG_MEM_IO(cfg_mem_io),

  // Data QSPI Flash Interface
  .DATA_MEM1_CS_B(data_mem1_cs_b),
  .DATA_MEM1_SCK(data_mem1_sck),
  .DATA_MEM1_IO(data_mem1_io),
  .DATA_MEM2_CS_B(data_mem2_cs_b),
  .DATA_MEM2_SCK(data_mem2_sck),
  .DATA_MEM2_IO(data_mem2_io),

  // FRAM Interface
  .FRAM1_CS_B(fram1_cs_b),
  .FRAM1_SCK(fram1_sck),
  .FRAM1_IO(fram1_io),
  .FRAM2_CS_B(fram2_cs_b),
  .FRAM2_SCK(fram2_sck),
  .FRAM2_IO(fram2_io),

  // CAN Interface
  .FPGA_CAN_TX(can_tx),
  .FPGA_CAN_RX(can_rx),
  .FPGA_CAN_SLEEP_EN(/*open*/),

  // I2C Interface
  .FPGA_INT_SCL(internal_i2cm_scl),
  .FPGA_INT_SDA(internal_i2cm_sda),
  .CVM_CRITICAL_B(1'b1),
  .CVM_WARNING_B(1'b1),
  .TEMP_ALERT_B(1'b1),
  .FPGA_EXT_SCL(external_i2cm_scl),
  .FPGA_EXT_SDA(external_i2cm_sda),

  // TRCH Interface
  .FPGA_BOOT0(FPGA_BOOT[0]),
  .FPGA_BOOT1(FPGA_BOOT[1]),
  .FPGA_WATCHDOG(FPGA_WATCHDOG),
  .FPGA_RESERVE(/*open*/),
  .FPGA_PWR_CYCLE_REQ(pwr_cycle_req),

  // ULPI Interface
  .ULPI_CS(ulpi_cs),
  .ULPI_CLOCK(ulpi_clock),
  .ULPI_RESET_B(ulpi_reset_b),
  .ULPI_DIR(ulpi_dir),
  .ULPI_NXT(ulpi_nxt),
  .ULPI_STP(ulpi_stp),
  .ULPI_DATA(ulpi_data),
  .ULPI_REFCLK(ulpi_refclk),

  // User IO Interface
//  inout  [15:0] UIO1,
//  inout  [15:0] UIO2,
  .UIO4(console_tx)
);

pic pic (
  .FPGA_CFG_MEM(cfg_mem_sel),
  .FPGA_PWR_CYCLE_REQ(pwr_cycle_req),
  .CFG_MEM_SEL(cfg_mem_mon)
);

uart_model cm3_console (
  .UART_RX(console_tx),
  .UART_TX(console_rx)
);

i2c_model # (
  .rclk_delay_time_init(0),
  .rclk_hold_time_init(0),
  .clk_period_init(2500000),
  .clk_period_allowable_init(50000)
) cvm1 (
  .SYS_CLK(i2cclk),
  .I2C_SCL(internal_i2cm_scl),
  .I2C_SDA(internal_i2cm_sda)
);

i2c_model # (
  .rclk_delay_time_init(0),
  .rclk_hold_time_init(0),
  .clk_period_init(2500000),
  .clk_period_allowable_init(50000)
) cvm2 (
  .SYS_CLK(i2cclk),
  .I2C_SCL(internal_i2cm_scl),
  .I2C_SDA(internal_i2cm_sda)
);

i2c_model # (
  .rclk_delay_time_init(0),
  .rclk_hold_time_init(0),
  .clk_period_init(2500000),
  .clk_period_allowable_init(50000)
) temp1 (
  .SYS_CLK(i2cclk),
  .I2C_SCL(internal_i2cm_scl),
  .I2C_SDA(internal_i2cm_sda)
);

i2c_model # (
  .rclk_delay_time_init(0),
  .rclk_hold_time_init(0),
  .clk_period_init(2500000),
  .clk_period_allowable_init(50000)
) temp2 (
  .SYS_CLK(i2cclk),
  .I2C_SCL(internal_i2cm_scl),
  .I2C_SDA(internal_i2cm_sda)
);

i2c_model # (
  .rclk_delay_time_init(0),
  .rclk_hold_time_init(0),
  .clk_period_init(2500000),
  .clk_period_allowable_init(50000)
) temp3 (
  .SYS_CLK(i2cclk),
  .I2C_SCL(internal_i2cm_scl),
  .I2C_SDA(internal_i2cm_sda)
);

i2c_model # (
  .rclk_delay_time_init(0),
  .rclk_hold_time_init(0),
  .clk_period_init(2500000),
  .clk_period_allowable_init(50000)
) external_i2c (
  .SYS_CLK(i2cclk),
  .I2C_SCL(external_i2cm_scl),
  .I2C_SDA(external_i2cm_sda)
);

if (TB_SRAM_ENABLE === 1) begin: sram
CY7C1061GE_10 sram1 (
  .CE_b(sram1_ce_b),
  .WE_b(sram1_we_b),
  .OE_b(sram1_oe_b),
  .BHE_b(sram1_bhe_b),
  .BLE_b(sram1_ble_b),
  .A(sram_a),
  .DQ(sram1_io),
  .ERR(sram1_err)
);
CY7C1061GE_10 sram2 (
  .CE_b(sram2_ce_b),
  .WE_b(sram2_we_b),
  .OE_b(sram2_oe_b),
  .BHE_b(sram2_bhe_b),
  .BLE_b(sram2_ble_b),
  .A(sram_a),
  .DQ(sram2_io),
  .ERR(sram2_err)
);
end

if (TB_CFG_MEM1_ENABLE === 1) begin: cfg_mem1
s25fl256l # (
  .UserPreload(0),
  .TimingModel("S25FL256LAGNFV410_30pF")
) nor_flash (
  .SI(cfg_mem_io[0]),
  .SO(cfg_mem_io[1]),
  .SCK(cfg_mem_sck),
  .CSNeg(cfg_mem_cs_b),
  .RESETNeg(1'b1),
  .WPNeg(cfg_mem_io[2]),
  .IO3_RESETNeg(cfg_mem_io[3])
);
end

if (TB_DATA_MEM1_ENABLE === 1) begin: data_mem1
s25fl256l # (
  .UserPreload(0),
  .TimingModel("S25FL256LAGNFV410_30pF")
) nor_flash (
  .SI(data_mem1_io[0]),
  .SO(data_mem1_io[1]),
  .SCK(data_mem1_sck),
  .CSNeg(data_mem1_cs_b),
  .RESETNeg(1'b1),
  .WPNeg(data_mem1_io[2]),
  .IO3_RESETNeg(data_mem1_io[3])
);
end

if (TB_DATA_MEM2_ENABLE === 1) begin: data_mem2
s25fl256l # (
  .UserPreload(0),
  .TimingModel("S25FL256LAGNFV410_30pF")
) nor_flash (
  .SI(data_mem2_io[0]),
  .SO(data_mem2_io[1]),
  .SCK(data_mem2_sck),
  .CSNeg(data_mem2_cs_b),
  .RESETNeg(1'b1),
  .WPNeg(data_mem2_io[2]),
  .IO3_RESETNeg(data_mem2_io[3])
);
end

if (TB_FRAM1_ENABLE === 1) begin: fram1
cy15b104qs # (
  .UserPreload(0)
) fram (
  .SI(fram1_io[0]),
  .SO(fram1_io[1]),
  .SCK(fram1_sck),
  .CSNeg(fram1_cs_b),
  .WPNeg(fram1_io[2]),
  .RESETNeg(fram1_io[3])
);
end

if (TB_FRAM2_ENABLE === 1) begin: fram2
cy15b104qs # (
  .UserPreload(0)
) fram (
  .SI(fram2_io[0]),
  .SO(fram2_io[1]),
  .SCK(fram2_sck),
  .CSNeg(fram2_cs_b),
  .WPNeg(fram2_io[2]),
  .RESETNeg(fram2_io[3])
);
end
