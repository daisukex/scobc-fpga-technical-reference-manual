//-----------------------------------------------
// Space Cubics OBC Core
//  Low Performance AHB SubSystem
//  Module: sc_obc_core
//-----------------------------------------------
// Copyright © 2022 Space Cubics, LLC.
//-----------------------------------------------

module lpahb_ss # (
  parameter LPAHB_AXI_ID_WIDTH = 3,
  parameter LPAHB_UART_DIV_INIT = 16'h0340
) (
  // System Interface
  input ACLK,
  input ARESETN,
  output UARTLITE_ISR,
  output INTERNAL_I2CM_ISR,
  output EXTERNAL_I2CM_ISR,
  output [1:0] CLKMODE,
  output CMC_REQ,
  input CMC_ACK,

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
  input [LPAHB_AXI_ID_WIDTH-1:0] BID,
  input [1:0] BRESP,
  input BVALID,
  output BREADY,

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

  // Uart Lite
  output UART_TX,
  input UART_RX,

  // Internal I2C
  inout INTERNAL_I2CM_SDA,
  inout INTERNAL_I2CM_SCL,

  // External I2C
  inout EXTERNAL_I2CM_SDA,
  inout EXTERNAL_I2CM_SCL
);

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

localparam LPAHB_HCLK_IDLE_BIT = 5;
localparam AHB_NUMBER_OF_SLAVE = 4;
localparam AHB_S0_BASE_ADDR = 16'h4F00;
localparam AHB_S0_ADDR_WIDTH = 16;
localparam AHB_S1_BASE_ADDR = 16'h4F01;
localparam AHB_S1_ADDR_WIDTH = 16;
localparam AHB_S2_BASE_ADDR = 16'h4F02;
localparam AHB_S2_ADDR_WIDTH = 16;
localparam AHB_S3_BASE_ADDR = 16'h4F03;
localparam AHB_S3_ADDR_WIDTH = 16;

wire [AHB_NUMBER_OF_SLAVE-1:0] shsel;
wire [32*AHB_NUMBER_OF_SLAVE-1:0] shrdata;
wire [2*AHB_NUMBER_OF_SLAVE-1:0] shresp;
wire [AHB_NUMBER_OF_SLAVE-1:0] shreadyout;
wire [AHB_NUMBER_OF_SLAVE-1:0] shreadyin;

localparam AHB_SYSREG_CH = 0;
localparam AHB_UARTLT_CH = 1;
localparam AHB_ITI2CM_CH = 2;
localparam AHB_ETI2CM_CH = 3;

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
  .SC_AHBIP_S3_ADDR_WIDTH(AHB_S3_ADDR_WIDTH)
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
  .SC_AHBIP_NUMBER_OF_SLAVE(AHB_NUMBER_OF_SLAVE),
  .SC_AHBIP_S0_BASE_ADDR(AHB_S0_BASE_ADDR),
  .SC_AHBIP_S0_ADDR_WIDTH(AHB_S0_ADDR_WIDTH),
  .SC_AHBIP_S1_BASE_ADDR(AHB_S1_BASE_ADDR),
  .SC_AHBIP_S1_ADDR_WIDTH(AHB_S1_ADDR_WIDTH),
  .SC_AHBIP_S2_BASE_ADDR(AHB_S2_BASE_ADDR),
  .SC_AHBIP_S2_ADDR_WIDTH(AHB_S2_ADDR_WIDTH),
  .SC_AHBIP_S3_BASE_ADDR(AHB_S3_BASE_ADDR),
  .SC_AHBIP_S3_ADDR_WIDTH(AHB_S3_ADDR_WIDTH)
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

sysreg sysreg (
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
  .SYS_RESET_REQ(SYSREG_RST_REQ),
  .CFGITCMEN(CFGITCMEN),
  .CLKMODE(CLKMODE),
  .CMC_REQ(CMC_REQ),
  .CMC_ACK(CMC_ACK)
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

// I2C Master for Internal I2C
// --------------------------------------------------
i2c_master # (
  .P_FIFO_DPTBW(4),
  .P_FIFO_TYPE(0),
  .P_INIT_THDSTA(16'h0063),
  .P_INIT_TSUSTO(16'h0063),
  .P_INIT_TSUSTA(16'h0063),
  .P_INIT_THIGH(16'h0072),
  .P_INIT_THDDAT(16'h0009),
  .P_INIT_TSUDAT(16'h0072),
  .P_INIT_TBUF(16'h008B)
) internal_i2cm (
  // System Interface
  .SYSCLK(hclk),
  .SYSRST_N(hresetn),
  .MODULE_RSTN(hresetn),
  .I2CM_INT(INTERNAL_I2CM_ISR),

  // AHB Interface
  .SHSEL(shsel[AHB_ITI2CM_CH]),
  .SHADDR(mhaddr),
  .SHTRANS(mhtrans),
  .SHSIZE(mhsize),
  .SHBURST(mhburst),
  .SHWRITE(mhwrite),
  .SHREADYIN(shreadyin[AHB_ITI2CM_CH]),
  .SHREADYOUT(shreadyout[AHB_ITI2CM_CH]),
  .SHWDATA(mhwdata),
  .SHRDATA(shrdata[32*AHB_ITI2CM_CH +:32]),
  .SHRESP(shresp[2*AHB_ITI2CM_CH +:2]),

  // I2C Bus Interface
  .I2C_SDA(INTERNAL_I2CM_SDA),
  .I2C_SCL(INTERNAL_I2CM_SCL)
);

// I2C Master for External I2C
// --------------------------------------------------
i2c_master # (
  .P_FIFO_DPTBW(4),
  .P_FIFO_TYPE(0),
  .P_INIT_THDSTA(16'h0063),
  .P_INIT_TSUSTO(16'h0063),
  .P_INIT_TSUSTA(16'h0063),
  .P_INIT_THIGH(16'h0072),
  .P_INIT_THDDAT(16'h0009),
  .P_INIT_TSUDAT(16'h0072),
  .P_INIT_TBUF(16'h008B)
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

endmodule
