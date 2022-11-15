//-----------------------------------------------
// Space Cubics OBC Core
//  Low Performance AHB SubSystem
//  Module: sc_obc_core
//-----------------------------------------------
// Copyright © 2022 Space Cubics, LLC.
//-----------------------------------------------

module lpahb_ss # (
  parameter BUILD_INFO = 32'h00000000,
  parameter LPAHB_AXI_ID_WIDTH = 3,
  parameter LPAHB_UART_DIV_INIT = 16'h0340
) (
  // System Interface
  input ACLK,
  input ARESETN,
  input REF_CLK,
  input SYS_RSTB_SYNC_REFCLK,
  output UARTLITE_ISR,
  output EXTERNAL_I2CM_ISR,
  output SYSMON_HW_ISR,
  output SYSMON_BHM_ISR,
  output GPTMR_GTMR_ISR,
  output GPTMR_SITMR_ISR,
  input [1:0] TRCH_BOOT,
  output [1:0] CLKMODE,
  output CMC_REQ,
  input CMC_ACK,
  output PWR_CYCLE_REQ,

  // Clock Monitor Interface
  input [1:0] OSC_CLKEN,
  input SYS_CLK,
  input MAXI_CLK,
  input ULPI_REFCLK,
  input USER_CLK1,
  input USER_CLK2,
  input PLLLOCK,

  // AXI Write Address Channel
  input [LPAHB_AXI_ID_WIDTH-1:0] AWID,
  input [31:0] AWADDR,
  input [7:0] AWLEN,
  input [2:0] AWSIZE,
  input [1:0] AWBURST,
  input AWVALID,
  output AWREADY,

  // AXI Write Data Channel
  input [31:0] WDATA,
  input [3:0] WSTRB,
  input WLAST,
  input WVALID,
  output WREADY,

  // AXI Write Responce Channel
  output [LPAHB_AXI_ID_WIDTH-1:0] BID,
  output [1:0] BRESP,
  output BVALID,
  input BREADY,

  // AXI Read Address Channel
  input [LPAHB_AXI_ID_WIDTH-1:0] ARID,
  input [31:0] ARADDR,
  input [7:0] ARLEN,
  input [2:0] ARSIZE,
  input [1:0] ARBURST,
  input ARVALID,
  output ARREADY,

  // AXI Read Data Channel
  output [LPAHB_AXI_ID_WIDTH-1:0] RID,
  output [31:0] RDATA,
  output [1:0] RRESP,
  output RLAST,
  output RVALID,
  input RREADY,

  // System Register Control Signal
  input POR_RSTB,
  output CFGITCMEN,
  output SYSREG_RST_REQ,

  // Configuration Memory Interface
  input CFG_MEM_MON,
  output CFG_MEM_OWNER,
  output CFG_MEM_REGSEL,
  input CFG_MEM_BUSY,

  // Uart Lite
  output UART_TX,
  input UART_RX,

  // Internal I2C
  inout INTERNAL_I2CM_SDA,
  inout INTERNAL_I2CM_SCL,
  input CVM_CRITICAL_B,
  input CVM_WARNING_B,
  input TEMP_ALERT_B,

  // External I2C
  inout EXTERNAL_I2CM_SDA,
  inout EXTERNAL_I2CM_SCL,

  output FPGA_WATCHDOG
);

wire reg_rst_req;
wire wdog_rst_req;
assign SYSREG_RST_REQ = reg_rst_req | wdog_rst_req;
wire hclk = ACLK;
wire hresetn = ARESETN;
wire [31:0] mhaddr;
wire [1:0] mhtrans;
wire mhwrite;
wire [2:0] mhsize;
wire [2:0] mhburst;
wire [31:0] mhwdata;
wire [31:0] mhrdata;
wire mhready;
wire [1:0] mhresp;
wire hclken;
wire dhreadyin;
wire dhreadyout;
wire [1:0] dhresp;
wire [7:0] gptmr_hitmr_isr;
wire cvm_data_req_trg;
wire temp_data_req_trg;

localparam LPAHB_HCLK_IDLE_BIT = 5;
localparam AHB_NUMBER_OF_SLAVE = 7;
localparam AHB_S0_BASE_ADDR = 16'h4F00;
localparam AHB_S0_ADDR_WIDTH = 16;
localparam AHB_S1_BASE_ADDR = 16'h4F01;
localparam AHB_S1_ADDR_WIDTH = 16;
localparam AHB_S2_BASE_ADDR = 16'h4F02;
localparam AHB_S2_ADDR_WIDTH = 16;
localparam AHB_S3_BASE_ADDR = 16'h4F03;
localparam AHB_S3_ADDR_WIDTH = 16;
localparam AHB_S4_BASE_ADDR = 16'h4F04;
localparam AHB_S4_ADDR_WIDTH = 16;
localparam AHB_S5_BASE_ADDR = 16'h4F05;
localparam AHB_S5_ADDR_WIDTH = 16;
localparam AHB_S6_BASE_ADDR = 16'h4FF0;
localparam AHB_S6_ADDR_WIDTH = 16;

wire [AHB_NUMBER_OF_SLAVE-1:0] shsel;
wire [32*AHB_NUMBER_OF_SLAVE-1:0] shrdata;
wire [2*AHB_NUMBER_OF_SLAVE-1:0] shresp;
wire [AHB_NUMBER_OF_SLAVE-1:0] shreadyout;
wire [AHB_NUMBER_OF_SLAVE-1:0] shreadyin;

localparam AHB_SYSREG_CH = 0;
localparam AHB_UARTLT_CH = 1;
localparam AHB_EMPTY_CH = 2;
localparam AHB_ETI2CM_CH = 3;
localparam AHB_SYSMON_CH = 4;
localparam AHB_GPTMR_CH = 5;
localparam AHB_DEBUG_CH = 6;

// AXI-AHB Bridge
// --------------------------------------------------
sc_axim2ahbs_nb # (
  .AXIM2AHBSNB_ID_WIDTH(LPAHB_AXI_ID_WIDTH),
  .AXIM2AHBSNB_HCLK_IDLE_BIT(LPAHB_HCLK_IDLE_BIT)
) axim2ahbs (
  // Global Signal
  .ACLK(ACLK),
  .ARESETN(ARESETN),

  // Write Address Channel Signal
  .AWID(AWID),
  .AWADDR(AWADDR),
  .AWLEN(AWLEN),
  .AWSIZE(AWSIZE),
  .AWBURST(AWBURST),
  .AWVALID(AWVALID),
  .AWREADY(AWREADY),

  // Write Data Channel Signal
  .WDATA(WDATA),
  .WSTRB(WSTRB),
  .WLAST(WLAST),
  .WVALID(WVALID),
  .WREADY(WREADY),

  // Write Responce Channel Signal
  .BRESP(BRESP),
  .BVALID(BVALID),
  .BREADY(BREADY),
  .BID(BID),

  // Read Address Channel Signal
  .ARID(ARID),
  .ARADDR(ARADDR),
  .ARLEN(ARLEN),
  .ARSIZE(ARSIZE),
  .ARBURST(ARBURST),
  .ARVALID(ARVALID),
  .ARREADY(ARREADY),

  // Read Data Channel Signal
  .RID(RID),
  .RDATA(RDATA),
  .RRESP(RRESP),
  .RLAST(RLAST),
  .RVALID(RVALID),
  .RREADY(RREADY),

  // AHB Slave Interface
  .HADDR(mhaddr),
  .HTRANS(mhtrans),
  .HWRITE(mhwrite),
  .HSIZE(mhsize),
  .HBURST(mhburst),
  .HWDATA(mhwdata),
  .HRDATA(mhrdata),
  .HREADY(mhready),
  .HRESP(mhresp),
  .HCLKEN(hclken)
);

// AHB Bus IP
// --------------------------------------------------
// Central Address Decoder and Default Slave
sc_ahbip_decoder # (
  .SC_AHBIP_NUMBER_OF_SLAVE(AHB_NUMBER_OF_SLAVE),
  .SC_AHBIP_S0_BASE_ADDR(AHB_S0_BASE_ADDR),
  .SC_AHBIP_S0_ADDR_WIDTH(AHB_S0_ADDR_WIDTH),
  .SC_AHBIP_S1_BASE_ADDR(AHB_S1_BASE_ADDR),
  .SC_AHBIP_S1_ADDR_WIDTH(AHB_S1_ADDR_WIDTH),
  .SC_AHBIP_S2_BASE_ADDR(AHB_S2_BASE_ADDR),
  .SC_AHBIP_S2_ADDR_WIDTH(AHB_S2_ADDR_WIDTH),
  .SC_AHBIP_S3_BASE_ADDR(AHB_S3_BASE_ADDR),
  .SC_AHBIP_S3_ADDR_WIDTH(AHB_S3_ADDR_WIDTH),
  .SC_AHBIP_S4_BASE_ADDR(AHB_S4_BASE_ADDR),
  .SC_AHBIP_S4_ADDR_WIDTH(AHB_S4_ADDR_WIDTH),
  .SC_AHBIP_S5_BASE_ADDR(AHB_S5_BASE_ADDR),
  .SC_AHBIP_S5_ADDR_WIDTH(AHB_S5_ADDR_WIDTH),
  .SC_AHBIP_S6_BASE_ADDR(AHB_S6_BASE_ADDR),
  .SC_AHBIP_S6_ADDR_WIDTH(AHB_S6_ADDR_WIDTH)
) ahb_addr_dec (
  // System Interface
  .HCLK(hclk),
  .HRESETN(hresetn),

  // Master Interface
  .MHADDR(mhaddr),
  .MHTRANS(mhtrans),

  // Slave Interface
  .SHSEL(shsel),

  // Default slave
  .DHREADYIN(dhreadyin),
  .DHREADYOUT(dhreadyout),
  .DHRESP(dhresp)
);

// Read Data Multiplexer
sc_ahbip_rdmux # (
  .SC_AHBIP_NUMBER_OF_SLAVE(AHB_NUMBER_OF_SLAVE)
) ahb_rdata_mux (
  .HCLK(hclk),
  // AHB Central Address Decoder Interface
  .SHSEL(shsel),
  .DHREADYOUT(dhreadyout),
  .DHREADYIN(dhreadyin),
  .DHRESP(dhresp),

  // AHB Master Interface
  .MHTRANS(mhtrans),
  .MHRDATA(mhrdata),
  .MHRESP(mhresp),
  .MHREADY(mhready),

  // AHB Slave Interface
  .SHRDATA(shrdata),
  .SHRESP(shresp),
  .SHREADYOUT(shreadyout),
  .SHREADYIN(shreadyin)
);

sysreg # (
  .BUILD_INFO(BUILD_INFO)
) sysreg (
  // System Interface
  .SYSCLK(hclk),
  .RESETB(hresetn),
  .POR_RSTB(POR_RSTB),

  // AHB Interface
  .SHSEL(shsel[AHB_SYSREG_CH]),
  .SHADDR(mhaddr),
  .SHTRANS(mhtrans),
  .SHSIZE(mhsize),
  .SHBURST(mhburst),
  .SHWRITE(mhwrite),
  .SHREADYIN(shreadyin[AHB_SYSREG_CH]),
  .SHREADYOUT(shreadyout[AHB_SYSREG_CH]),
  .SHWDATA(mhwdata),
  .SHRDATA(shrdata[32*AHB_SYSREG_CH +:32]),
  .SHRESP(shresp[2*AHB_SYSREG_CH +:2]),

  // Output Signal
  .SYS_RESET_REQ(reg_rst_req),
  .CFGITCMEN(CFGITCMEN),
  .TRCH_BOOT(TRCH_BOOT),
  .CLKMODE(CLKMODE),
  .CMC_REQ(CMC_REQ),
  .CMC_ACK(CMC_ACK),
  .CFG_MEM_MON(CFG_MEM_MON),
  .CFG_MEM_OWNER(CFG_MEM_OWNER),
  .CFG_MEM_REGSEL(CFG_MEM_REGSEL),
  .CFG_MEM_BUSY(CFG_MEM_BUSY),
  .PWR_CYCLE_REQ(PWR_CYCLE_REQ)
);

// AHB UART-Lite for Cortex-M3 Console
// --------------------------------------------------
ahbuartlite # (
  .P_UDIV_INIT(LPAHB_UART_DIV_INIT),
  .P_UART_DATA_W(3'h7),
  .P_UART_STOP_W(1'b0),
  .P_UART_PRTY_EN(1'b0),
  .P_UART_PRTY_TYPE(2'h0),
  .P_FIFO_DEPTH(4)
) ahbuartlite (
  // System Interface
  .SYSCLK(hclk),
  .RESETB(hresetn),
  .MODULE_RSTN(hresetn),
  .INTERRUPT(UARTLITE_ISR),

  // AHB Interface
  .SHSEL(shsel[AHB_UARTLT_CH]),
  .SHADDR(mhaddr),
  .SHTRANS(mhtrans),
  .SHSIZE(mhsize),
  .SHBURST(mhburst),
  .SHWRITE(mhwrite),
  .SHREADYIN(shreadyin[AHB_UARTLT_CH]),
  .SHREADYOUT(shreadyout[AHB_UARTLT_CH]),
  .SHWDATA(mhwdata),
  .SHRDATA(shrdata[32*AHB_UARTLT_CH +:32]),
  .SHRESP(shresp[2*AHB_UARTLT_CH +:2]),

  // UART Interface
  .UART_TX(UART_TX),
  .UART_RX(UART_RX)
);

// AHB Channel 2 (Empty)
// --------------------------------------------------
assign shreadyout[AHB_EMPTY_CH] = 1'b1;
assign shrdata[32*AHB_EMPTY_CH +:32] = 0;
assign shresp[2*AHB_EMPTY_CH +:2] = 0;

// I2C Master for External I2C
// --------------------------------------------------
i2c_master # (
  .P_FIFO_DPTBW(4),
  .P_FIFO_TYPE(0),
  .P_INIT_THDSTA(16'h0029),
  .P_INIT_TSUSTO(16'h0029),
  .P_INIT_TSUSTA(16'h0029),
  .P_INIT_THIGH(16'h002F),
  .P_INIT_THDDAT(16'h0003),
  .P_INIT_TSUDAT(16'h002F),
  .P_INIT_TBUF(16'h003A)
) external_i2cm (
  // System Interface
  .SYSCLK(hclk),
  .SYSRST_N(hresetn),
  .MODULE_RSTN(hresetn),
  .I2CM_INT(EXTERNAL_I2CM_ISR),

  // AHB Interface
  .SHSEL(shsel[AHB_ETI2CM_CH]),
  .SHADDR(mhaddr),
  .SHTRANS(mhtrans),
  .SHSIZE(mhsize),
  .SHBURST(mhburst),
  .SHWRITE(mhwrite),
  .SHREADYIN(shreadyin[AHB_ETI2CM_CH]),
  .SHREADYOUT(shreadyout[AHB_ETI2CM_CH]),
  .SHWDATA(mhwdata),
  .SHRDATA(shrdata[32*AHB_ETI2CM_CH +:32]),
  .SHRESP(shresp[2*AHB_ETI2CM_CH +:2]),

  // I2C Bus Interface
  .I2C_SDA(EXTERNAL_I2CM_SDA),
  .I2C_SCL(EXTERNAL_I2CM_SCL)
);

system_monitor system_monitor (
  // System Interface
  .HCLK(hclk),
  .HRESETN(hresetn),
  .POR_RSTB(POR_RSTB),
  .REF_CLK(REF_CLK),
  .SYS_RSTB_SYNC_REFCLK(SYS_RSTB_SYNC_REFCLK),
  .SYSMON_HW_INT(SYSMON_HW_ISR),
  .SYSMON_BHM_INT(SYSMON_BHM_ISR),

  // AHB Interface
  .HSEL(shsel[AHB_SYSMON_CH]),
  .HADDR(mhaddr),
  .HTRANS(mhtrans),
  .HSIZE(mhsize),
  .HBURST(mhburst),
  .HWRITE(mhwrite),
  .HREADYIN(shreadyin[AHB_SYSMON_CH]),
  .HREADYOUT(shreadyout[AHB_SYSMON_CH]),
  .HWDATA(mhwdata),
  .HRDATA(shrdata[32*AHB_SYSMON_CH +:32]),
  .HRESP(shresp[2*AHB_SYSMON_CH +:2]),

  .FPGA_WATCHDOG(FPGA_WATCHDOG),
  .WDOG_RST_REQ(wdog_rst_req),

  .CVM_DATA_REQ_TRG(cvm_data_req_trg),
  .TEMP_DATA_REQ_TRG(temp_data_req_trg),
  .CVM_CRITICAL_B(CVM_CRITICAL_B),
  .CVM_WARNING_B(CVM_WARNING_B),
  .TEMP_ALERT_B(TEMP_ALERT_B),
  .INTERNAL_I2C_SCL(INTERNAL_I2CM_SCL),
  .INTERNAL_I2C_SDA(INTERNAL_I2CM_SDA),

  // Clock Monitor Interface
  .OSC_CLKEN(OSC_CLKEN),
  .SYS_CLK(SYS_CLK),
  .MAXI_CLK(MAXI_CLK),
  .ULPI_REFCLK(ULPI_REFCLK),
  .USER_CLK1(USER_CLK1),
  .USER_CLK2(USER_CLK2),
  .CMC_REQ(CMC_REQ),
  .CLKMODE(CLKMODE),
  .PLLLOCK(PLLLOCK)
);

// General Purpose Timer
sc_gptmr # (
  .GTMR_COMPARE_CHANNEL(4),
  .GTMR_PRESCALER_BIT_WIDTH(21),
  .SITMR_COMPARE_CHANNEL(8),
  .HITMR_COMPARE_CHANNEL(8)
) gptmr (
  // System Interface
  .HRESETN(hresetn),
  .HCLK(hclk),
  .TMR_RSTB(SYS_RSTB_SYNC_REFCLK),
  .TMR_CLK(REF_CLK),
  .MODULE_RSTN(1'b1),

  // Configuration Interface
  .GTMR_PRESCALER_VALUE(21'h16E35F),

  // AHB Slave Interface
  .SHSEL(shsel[AHB_GPTMR_CH]),
  .SHADDR(mhaddr),
  .SHTRANS(mhtrans),
  .SHSIZE(mhsize),
  .SHBURST(mhburst),
  .SHWRITE(mhwrite),
  .SHREADYIN(shreadyin[AHB_GPTMR_CH]),
  .SHREADYOUT(shreadyout[AHB_GPTMR_CH]),
  .SHWDATA(mhwdata),
  .SHRDATA(shrdata[32*AHB_GPTMR_CH +:32]),
  .SHRESP(shresp[2*AHB_GPTMR_CH +:2]),

  // Interrupt Signal
  .GTMR_INT(GPTMR_GTMR_ISR),
  .SITMR_INT(GPTMR_SITMR_ISR),
  .HITMR_INT_REQ(gptmr_hitmr_isr),
  .HITMR_INT_ACK(8'h0)
);

gptmr_pulse_sync sync_cvm_irs (
  .TMR_CLK(REF_CLK),
  .TMR_RSTB(SYS_RSTB_SYNC_REFCLK),
  .HCLK(hclk),
  .HRESETN(hresetn),
  .I_PULSE(gptmr_hitmr_isr[1]),
  .O_PULSE(cvm_data_req_trg)
);

gptmr_pulse_sync sync_temp_irs (
  .TMR_CLK(REF_CLK),
  .TMR_RSTB(SYS_RSTB_SYNC_REFCLK),
  .HCLK(hclk),
  .HRESETN(hresetn),
  .I_PULSE(gptmr_hitmr_isr[2]),
  .O_PULSE(temp_data_req_trg)
);



// Debug Controller Register
scobca1_dbg_reg dbg_reg (
  // System Interface
  .HCLK(hclk),
  .HRESETN(hresetn),

  // AHB Interface
  .SHSEL(shsel[AHB_DEBUG_CH]),
  .SHADDR(mhaddr),
  .SHTRANS(mhtrans),
  .SHSIZE(mhsize),
  .SHBURST(mhburst),
  .SHWRITE(mhwrite),
  .SHREADYIN(shreadyin[AHB_DEBUG_CH]),
  .SHREADYOUT(shreadyout[AHB_DEBUG_CH]),
  .SHWDATA(mhwdata),
  .SHRDATA(shrdata[32*AHB_DEBUG_CH +:32]),
  .SHRESP(shresp[2*AHB_DEBUG_CH +:2]),

  // Debug Register Input/Output
  .SRAM_A_GPIO_MODE_SEL(/*open*/),
  .SRAM1_CE_B_GPIO_MODE_SEL(/*open*/),
  .SRAM1_OE_B_GPIO_MODE_SEL(/*open*/),
  .SRAM1_WE_B_GPIO_MODE_SEL(/*open*/),
  .SRAM1_BHE_B_GPIO_MODE_SEL(/*open*/),
  .SRAM1_BLE_B_GPIO_MODE_SEL(/*open*/),
  .SRAM2_CE_B_GPIO_MODE_SEL(/*open*/),
  .SRAM2_OE_B_GPIO_MODE_SEL(/*open*/),
  .SRAM2_WE_B_GPIO_MODE_SEL(/*open*/),
  .SRAM2_BHE_B_GPIO_MODE_SEL(/*open*/),
  .SRAM2_BLE_B_GPIO_MODE_SEL(/*open*/),
  .SRAM_A_GPIO_IN(20'h0),
  .SRAM1_CE_B_GPIO_IN(1'b0),
  .SRAM1_OE_B_GPIO_IN(1'b0),
  .SRAM1_WE_B_GPIO_IN(1'b0),
  .SRAM1_BHE_B_GPIO_IN(1'b0),
  .SRAM1_BLE_B_GPIO_IN(1'b0),
  .SRAM2_CE_B_GPIO_IN(1'b0),
  .SRAM2_OE_B_GPIO_IN(1'b0),
  .SRAM2_WE_B_GPIO_IN(1'b0),
  .SRAM2_BHE_B_GPIO_IN(1'b0),
  .SRAM2_BLE_B_GPIO_IN(1'b0),

  .CFG_MEM_CS_B_GPIO_MODE_SEL(/*open*/),
  .CFG_MEM_IO_GPIO_MODE_SEL(/*open*/),
  .CFG_MEM_CS_B_GPIO_IN(1'b0),
  .CFG_MEM_IO_GPIO_IN(4'h0),

  .DATA_MEM1_CS_B_GPIO_MODE_SEL(/*open*/),
  .DATA_MEM1_IO_GPIO_MODE_SEL(/*open*/),
  .DATA_MEM2_CS_B_GPIO_MODE_SEL(/*open*/),
  .DATA_MEM2_IO_GPIO_MODE_SEL(/*open*/),
  .DATA_MEM1_CS_B_GPIO_IN(1'b0),
  .DATA_MEM1_IO_GPIO_IN(4'h0),
  .DATA_MEM2_CS_B_GPIO_IN(1'b0),
  .DATA_MEM2_IO_GPIO_IN(4'h0),

  .FRAM1_CS_B_GPIO_MODE_SEL(/*open*/),
  .FRAM1_IO_GPIO_MODE_SEL(/*open*/),
  .FRAM2_CS_B_GPIO_MODE_SEL(/*open*/),
  .FRAM2_IO_GPIO_MODE_SEL(/*open*/),
  .FRAM1_CS_B_GPIO_IN(1'b0),
  .FRAM1_IO_GPIO_IN(4'h0),
  .FRAM2_CS_B_GPIO_IN(1'b0),
  .FRAM2_IO_GPIO_IN(4'h0),

  .SYSCLK2_STATE(1'b0),
  .SYSCLK1_STATE(1'b0),

  .TEMP_ALERT_B(1'b0),
  .CVM_WARNING_B(1'b0),
  .CVM_CRITICAL_B(1'b0),

  .EXT_I2C_SCL_GPIO_MODE_SEL(/*open*/),
  .EXT_I2C_SDA_GPIO_MODE_SEL(/*open*/),
  .EXT_I2C_SCL_GPIO_IN(1'b0),
  .EXT_I2C_SDA_GPIO_IN(1'b0),

  .FPGA_BOOT_SHIFTREG_IN(32'h0),
  .FPGA_WATCHDOG_GPIO_MODE_SEL(/*open*/),
  .FPGA_PWR_CYCLE_REQ_GPIO_MODE_SEL(/*open*/),
  .FPGA_RESERVE_GPIO_MODE_SEL(/*open*/),
  .FPGA_WATCHDOG_GPIO_IN(1'b0),
  .FPGA_PWR_CYCLE_REQ_GPIO_IN(1'b0),
  .FPGA_RESERVE_GPIO_IN(1'b0),

  .ULPI_CLOCK_STATE(1'b0),
  .ULPI_RESET_B_GPIO_MODE_SEL(/*open*/),
  .ULPI_CS_GPIO_MODE_SEL(/*open*/),
  .ULPI_RESET_B_GPIO_IN(1'b0),
  .ULPI_CS_GPIO_IN(1'b0),

  .PUDC_B(1'b0),

  .UIO1_GPIO_MODE_SEL(/*open*/),
  .UIO1_GPIO_IN(16'h0),

  .UIO2_GPIO_MODE_SEL(/*open*/),
  .UIO2_GPIO_IN(16'h0),

  .UIO4_GPIO_MODE_SEL(/*open*/),
  .UIO4_GPIO_IN(6'h0),

  .RSV_GPIO_MODE_SEL(/*open*/),
  .RSV_GPIO_IN(16'h0)
);

endmodule
