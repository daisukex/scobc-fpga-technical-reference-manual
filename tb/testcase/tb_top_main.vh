//-----------------------------------------------
// Space Cubics OBC Core
//  Testbench main module 
//  Module: tb_top_main.vh
//-----------------------------------------------
// Copyright © 2022 Space Cubics, LLC.
//-----------------------------------------------

localparam SYSCLK_PERIOD = 41666;
localparam I2CCLK_PERIOD = 33333;

reg sysclk1 = 0;
wire sysclk1en;
initial begin
  forever begin
    #(SYSCLK_PERIOD/2);
    if (sysclk1en)
      sysclk1 = ~sysclk1;
  end
end

reg sysclk2 = 0;
wire sysclk2en;
initial begin
  forever begin
    #(SYSCLK_PERIOD/2);
    if (sysclk2en)
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

wire SYS_CLK;
wire REF_CLK;
wire SYS_RSTB;
wire SYS_RSTB_SYNC_REFCLK;
wire PLLLOCK;
wire CMC_REQ;
wire CMC_ACK;

wire init_req;
wire init_done;
wire [1:0] CLKMODE;
wire sleeping;
wire sleepholdreq;
wire sleepholdackn;
wire sys_rst_req;
wire reg_rst_req;
wire cpu_lockup;
wire cpu_lockup_rsten;
wire por_rstb;
wire por_rstb_sync_refclk;
wire bus_rstb;

wire console_tx;
wire console_rx;
wire can_tx;
wire can_rx = can_tx;

wire (pull1, pull0) internal_i2cm_sda = 1'b1;
wire (pull1, pull0) internal_i2cm_scl = 1'b1;
wire (pull1, pull0) external_i2cm_sda = 1'b1;
wire (pull1, pull0) external_i2cm_scl = 1'b1;
wire cfg_mem_sck;
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

scobca1_sysctrl # (
  .SYSCTRL_USER_CLK1_DIVIDE(100),
  .SYSCTRL_USER_CLK1_MODE(0),
  .SYSCTRL_USER_CLK2_DIVIDE(100),
  .SYSCTRL_USER_CLK2_MODE(0)
) sysctrl (
  .SYSCLK1(sysclk1),
  .SYSCLK1_EN(sysclk1en),
  .SYSCLK2(sysclk2),
  .SYSCLK2_EN(sysclk2en),
  .INIT_REQ(init_req),
  .INIT_DONE(init_done),
  .CLKMODE(CLKMODE),
  .CMC_REQ(CMC_REQ),
  .CMC_ACK(CMC_ACK),
  .PLLLOCK(PLLLOCK),
  .SLEEPING(sleeping),
  .SLEEPHOLDREQN(sleepholdreq),
  .SLEEPHOLDACKN(sleepholdackn),
  .SYS_RST_REQ(sys_rst_req),
  .REG_RST_REQ(reg_rst_req),
  .CPU_LOCKUP(cpu_lockup),
  .CPU_LOCKUP_RSTEN(cpu_lockup_rsten),
  .REF_CLK(REF_CLK),
  .SYS_CLK(SYS_CLK),
  .MAXI_CLK(/*open*/),
  .ULPI_REFCLK(/*open*/),
  .USER_CLK1(/*open*/),
  .USER_CLK2(/*open*/),
  .POR_RSTB(por_rstb),
  .POR_RSTB_SYNC_REFCLK(por_rstb_sync_refclk),
  .SYS_RSTB(SYS_RSTB),
  .SYS_RSTB_SYNC_REFCLK(SYS_RSTB_SYNC_REFCLK),
  .SYS_RSTB_SYNC_USERCLK1(/*open*/),
  .SYS_RSTB_SYNC_USERCLK2(/*open*/),
  .BUS_RSTB(bus_rstb)
);

sc_obc_core # (
  .CM3SS_UDL_ISR_NUM(16),
  .CM3SS_ITCM_SIZE_KB(128),
  .CM3SS_ITCM_ADDR_BW(14),
  .MAINAXI_UDL_M_AXI_ID_WIDTH(2),
  .MAINAXI_S_AXI_ID_WIDTH(3)
) dut (
  // Clock/Reset Signals
  // ------------------------------
  // Clock
  .REF_CLK(REF_CLK),
  .SYS_CLK(SYS_CLK),
  .PLLLOCK(PLLLOCK),
  // Reset
  .SYS_RST_REQ(sys_rst_req),
  .REG_RST_REQ(reg_rst_req),
  .POR_RSTB(por_rstb),
  .POR_RSTB_SYNC_REFCLK(por_rstb_sync_refclk),
  .SYS_RSTB(SYS_RSTB),
  .SYS_RSTB_SYNC_REFCLK(SYS_RSTB_SYNC_REFCLK),
  .BUS_RSTB(bus_rstb),
  // Clock Mode Control
  .CLKMODE(CLKMODE),
  .CMC_REQ(CMC_REQ),
  .CMC_ACK(CMC_ACK),

  // Logic Initilize Control Signals
  // ------------------------------
  .INIT_REQ(init_req),
  .INIT_DONE(init_done),

  // Cortex-M3 Signals
  // ------------------------------
  // Power Management Signals
  .SLEEPING(sleeping),
  .SLEEPHOLDREQN(sleepholdreq),
  .SLEEPHOLDACKN(sleepholdackn),
  // Lockup monitor and control
  .CPU_LOCKUP(cpu_lockup),
  .CPU_LOCKUP_RSTEN(cpu_lockup_rsten),

  // UDL Master Interface
  // ------------------------------
  // Write Address Channel
  .UDL_AXIM_AWID(2'b00),
  .UDL_AXIM_AWADDR(32'h00000000),
  .UDL_AXIM_AWLEN(8'h00),
  .UDL_AXIM_AWSIZE(3'h0),
  .UDL_AXIM_AWBURST(2'h0),
  .UDL_AXIM_AWLOCK(1'b0),
  .UDL_AXIM_AWCACHE(4'h0),
  .UDL_AXIM_AWPROT(3'h0),
  .UDL_AXIM_AWQOS(4'h0),
  .UDL_AXIM_AWVALID(1'b0),
  .UDL_AXIM_AWREADY(/*open*/),
  // Write Data Channel
  .UDL_AXIM_WDATA(32'h00000000),
  .UDL_AXIM_WSTRB(4'h0),
  .UDL_AXIM_WLAST(1'b0),
  .UDL_AXIM_WVALID(1'b0),
  .UDL_AXIM_WREADY(/*open*/),
  .UDL_AXIM_BID(/*open*/),
  // Write Responce Channel
  .UDL_AXIM_BRESP(/*open*/),
  .UDL_AXIM_BVALID(/*open*/),
  .UDL_AXIM_BREADY(1'b1),
  // Read Address Channel
  .UDL_AXIM_ARID(2'h0),
  .UDL_AXIM_ARADDR(32'h00000000),
  .UDL_AXIM_ARLEN(8'h0),
  .UDL_AXIM_ARSIZE(3'h0),
  .UDL_AXIM_ARBURST(2'h0),
  .UDL_AXIM_ARLOCK(1'b0),
  .UDL_AXIM_ARCACHE(4'h0),
  .UDL_AXIM_ARPROT(3'h0),
  .UDL_AXIM_ARQOS(4'h0),
  .UDL_AXIM_ARVALID(1'b0),
  .UDL_AXIM_ARREADY(/*open*/),
  // Read Data Channel
  .UDL_AXIM_RID(/*open*/),
  .UDL_AXIM_RDATA(/*open*/),
  .UDL_AXIM_RRESP(/*open*/),
  .UDL_AXIM_RLAST(/*open*/),
  .UDL_AXIM_RVALID(/*open*/),
  .UDL_AXIM_RREADY(1'b1),

  // UDL Slave Interface
  // ------------------------------
  // Write Address Channel
  .UDL_AXIS_AWID(/*open*/),
  .UDL_AXIS_AWADDR(/*open*/),
  .UDL_AXIS_AWLEN(/*open*/),
  .UDL_AXIS_AWSIZE(/*open*/),
  .UDL_AXIS_AWBURST(/*open*/),
  .UDL_AXIS_AWLOCK(/*open*/),
  .UDL_AXIS_AWCACHE(/*open*/),
  .UDL_AXIS_AWPROT(/*open*/),
  .UDL_AXIS_AWREGION(/*open*/),
  .UDL_AXIS_AWQOS(/*open*/),
  .UDL_AXIS_AWVALID(/*open*/),
  .UDL_AXIS_AWREADY(1'b1),
  // Write Data Channel
  .UDL_AXIS_WDATA(/*open*/),
  .UDL_AXIS_WSTRB(/*open*/),
  .UDL_AXIS_WLAST(/*open*/),
  .UDL_AXIS_WVALID(/*open*/),
  .UDL_AXIS_WREADY(1'b1),
  // Write Responce Channel
  .UDL_AXIS_BID(3'h0),
  .UDL_AXIS_BRESP(2'h0),
  .UDL_AXIS_BVALID(1'b0),
  .UDL_AXIS_BREADY(/*open*/),
  // Read Address Channel
  .UDL_AXIS_ARID(/*open*/),
  .UDL_AXIS_ARADDR(/*open*/),
  .UDL_AXIS_ARLEN(/*open*/),
  .UDL_AXIS_ARSIZE(/*open*/),
  .UDL_AXIS_ARBURST(/*open*/),
  .UDL_AXIS_ARLOCK(/*open*/),
  .UDL_AXIS_ARCACHE(/*open*/),
  .UDL_AXIS_ARPROT(/*open*/),
  .UDL_AXIS_ARREGION(/*open*/),
  .UDL_AXIS_ARQOS(/*open*/),
  .UDL_AXIS_ARVALID(/*open*/),
  .UDL_AXIS_ARREADY(1'b1),
  // Read Data Channel
  .UDL_AXIS_RID(3'h0),
  .UDL_AXIS_RDATA(32'h00000000),
  .UDL_AXIS_RRESP(2'h0),
  .UDL_AXIS_RLAST(1'b0),
  .UDL_AXIS_RVALID(1'b0),
  .UDL_AXIS_RREADY(/*open*/),
  .UDL_INTISR(16'h0000),

  // NOR Flash Configuration Memory Interface
  // ------------------------------
  .CFG_MEM_SCK(cfg_mem_sck),
  .CFG_MEM_CS_B(cfg_mem_cs_b),
  .CFG_MEM_IO(cfg_mem_io),

  // NOR Flash Data Memory Interface
  // ------------------------------
  .DATA_MEM1_SCK(data_mem1_sck),
  .DATA_MEM1_CS_B(data_mem1_cs_b),
  .DATA_MEM1_IO(data_mem1_io),
  .DATA_MEM2_SCK(data_mem2_sck),
  .DATA_MEM2_CS_B(data_mem2_cs_b),
  .DATA_MEM2_IO(data_mem2_io),

  // FeRAM Data Memory Interface
  // ------------------------------
  .FRAM1_SCK(fram1_sck),
  .FRAM1_CS_B(fram1_cs_b),
  .FRAM1_IO(fram1_io),
  .FRAM2_SCK(fram2_sck),
  .FRAM2_CS_B(fram2_cs_b),
  .FRAM2_IO(fram2_io),

  // CAN Interface
  // ------------------------------
  .CAN_TX(can_tx),
  .CAN_RX(can_rx),
  .CAN_SLEEP_EN(/*open*/),

  // Uart Lite Interface
  // ------------------------------
  .UART_TX(console_tx),
  .UART_RX(console_rx),

  // Internal I2C Interface
  // ------------------------------
  .INTERNAL_I2CM_SDA(internal_i2cm_sda),
  .INTERNAL_I2CM_SCL(internal_i2cm_scl),

  // External I2C Interface
  // ------------------------------
  .EXTERNAL_I2CM_SDA(external_i2cm_sda),
  .EXTERNAL_I2CM_SCL(external_i2cm_scl),

  // Coetex-M3 SWJ-DP Interface
  // ------------------------------
  .JTAGNSW(/*open*/),
  .SWCLKTCK(1'b0),
  .SWDITMS(1'b0),
  .SWDO(/*open*/),
  .SWDOEN(/*open*/),
  .SWV(/*open*/),
  .NTRST(1'b0),
  .TDI(1'b0),
  .TDO(/*open*/),
  .NTDOEN(/*open*/)
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
) internal_i2c (
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
