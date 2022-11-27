//-----------------------------------------------
// Space Cubics SC-OBC-A1
// SC-OBC-A1 Debug Controller Register
// Module: scobca1_dbg_reg
//-----------------------------------------------
// Copyright © 2022 Space Cubics, LLC.
//-----------------------------------------------
`include "scobca1_dbg_reg_map.vh"

module scobca1_dbg_reg (
  // System Interface
  input HCLK,
  input HRESETN,

  // AHB Interface
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

  // Debug Register Input/Output
  output reg [2*20-1:0] SRAM_A_GPIO_MODE_SEL,
  output reg [1:0] SRAM1_CE_B_GPIO_MODE_SEL,
  output reg [1:0] SRAM1_OE_B_GPIO_MODE_SEL,
  output reg [1:0] SRAM1_WE_B_GPIO_MODE_SEL,
  output reg [1:0] SRAM1_BHE_B_GPIO_MODE_SEL,
  output reg [1:0] SRAM1_BLE_B_GPIO_MODE_SEL,
  output reg [1:0] SRAM2_CE_B_GPIO_MODE_SEL,
  output reg [1:0] SRAM2_OE_B_GPIO_MODE_SEL,
  output reg [1:0] SRAM2_WE_B_GPIO_MODE_SEL,
  output reg [1:0] SRAM2_BHE_B_GPIO_MODE_SEL,
  output reg [1:0] SRAM2_BLE_B_GPIO_MODE_SEL,
  input [19:0] SRAM_A_GPIO_IN,
  input SRAM1_CE_B_GPIO_IN,
  input SRAM1_OE_B_GPIO_IN,
  input SRAM1_WE_B_GPIO_IN,
  input SRAM1_BHE_B_GPIO_IN,
  input SRAM1_BLE_B_GPIO_IN,
  input SRAM2_CE_B_GPIO_IN,
  input SRAM2_OE_B_GPIO_IN,
  input SRAM2_WE_B_GPIO_IN,
  input SRAM2_BHE_B_GPIO_IN,
  input SRAM2_BLE_B_GPIO_IN,
  input [31:0] SRAM_IO,
  input SRAM1_ERR,
  input SRAM2_ERR,

  output reg [1:0] CFG_MEM_CS_B_GPIO_MODE_SEL,
  output reg [2*4-1:0] CFG_MEM_IO_GPIO_MODE_SEL,
  input CFG_MEM_CS_B_GPIO_IN,
  input [3:0] CFG_MEM_IO_GPIO_IN,

  output reg [1:0] DATA_MEM1_CS_B_GPIO_MODE_SEL,
  output reg [2*4-1:0] DATA_MEM1_IO_GPIO_MODE_SEL,
  output reg [1:0] DATA_MEM2_CS_B_GPIO_MODE_SEL,
  output reg [2*4-1:0] DATA_MEM2_IO_GPIO_MODE_SEL,
  input DATA_MEM1_CS_B_GPIO_IN,
  input [3:0] DATA_MEM1_IO_GPIO_IN,
  input DATA_MEM2_CS_B_GPIO_IN,
  input [3:0] DATA_MEM2_IO_GPIO_IN,

  output reg [1:0] FRAM1_CS_B_GPIO_MODE_SEL,
  output reg [2*4-1:0] FRAM1_IO_GPIO_MODE_SEL,
  output reg [1:0] FRAM2_CS_B_GPIO_MODE_SEL,
  output reg [2*4-1:0] FRAM2_IO_GPIO_MODE_SEL,
  input FRAM1_CS_B_GPIO_IN,
  input [3:0] FRAM1_IO_GPIO_IN,
  input FRAM2_CS_B_GPIO_IN,
  input [3:0] FRAM2_IO_GPIO_IN,

  input SYSCLK2_STATE,
  input SYSCLK1_STATE,

  input TEMP_ALERT_B,
  input CVM_WARNING_B,
  input CVM_CRITICAL_B,

  output reg [1:0] EXT_I2C_SCL_GPIO_MODE_SEL,
  output reg [1:0] EXT_I2C_SDA_GPIO_MODE_SEL,
  input EXT_I2C_SCL_GPIO_IN,
  input EXT_I2C_SDA_GPIO_IN,

  input [31:0] FPGA_BOOT_SHIFTREG_IN,
  output reg [1:0] FPGA_WATCHDOG_GPIO_MODE_SEL,
  output reg [1:0] FPGA_PWR_CYCLE_REQ_GPIO_MODE_SEL,
  output reg [1:0] FPGA_RESERVE_GPIO_MODE_SEL,
  output reg [1:0] FPGA_BOOT0_GPIO_MODE_SEL,
  output reg [1:0] FPGA_BOOT1_GPIO_MODE_SEL,
  input FPGA_WATCHDOG_GPIO_IN,
  input FPGA_PWR_CYCLE_REQ_GPIO_IN,
  input FPGA_RESERVE_GPIO_IN,
  input FPGA_BOOT0_GPIO_IN,
  input FPGA_BOOT1_GPIO_IN,

  input ULPI_CLOCK_STATE,
  output reg [1:0] ULPI_RESET_B_GPIO_MODE_SEL,
  output reg [1:0] ULPI_CS_GPIO_MODE_SEL,
  input ULPI_RESET_B_GPIO_IN,
  input ULPI_CS_GPIO_IN,

  input PUDC_B,

  output reg [2*16-1:0] UIO1_GPIO_MODE_SEL,
  input [15:0] UIO1_GPIO_IN,

  output reg [2*16-1:0] UIO2_GPIO_MODE_SEL,
  input [15:0] UIO2_GPIO_IN,

  output reg [2*6-1:0] UIO4_GPIO_MODE_SEL,
  input [5:0] UIO4_GPIO_IN,

  output reg [2*16-1:0] RSV_GPIO_MODE_SEL,
  input [15:0] RSV_GPIO_IN
);

wire [31:0] REG_WADR;
wire [3:0] REG_WENB;
wire [31:0] REG_WDAT;
wire [31:0] REG_RADR;
wire REG_RENB;
reg [31:0] REG_RDAT;

sc_ahbip_slave # (
  .CYCLE_MODE(1)
) ahb_slave (
  // AHB Interface
  .HCLK(HCLK),
  .HRESETN(HRESETN),
  .HSEL(SHSEL),
  .HADDR(SHADDR),
  .HTRANS(SHTRANS),
  .HSIZE(SHSIZE),
  .HBURST(SHBURST),
  .HWRITE(SHWRITE),
  .HREADYIN(SHREADYIN),
  .HREADYOUT(SHREADYOUT),
  .HWDATA(SHWDATA),
  .HRDATA(SHRDATA),
  .HRESP(SHRESP),

  // Register Interface
  .REG_WADR(REG_WADR),
  .REG_WTYP(/*open*/),
  .REG_WENB(REG_WENB),
  .REG_WDAT(REG_WDAT),
  .REG_WWAT(1'b0),
  .REG_WERR(1'b0),

  .REG_RADR(REG_RADR),
  .REG_RTYP(/*open*/),
  .REG_RENB(REG_RENB),
  .REG_RDAT(REG_RDAT),
  .REG_RWAT(1'b0),
  .REG_RERR(1'b0)
);

wire [15:0] WADR = {REG_WADR[15:2],2'b00};
wire [15:0] RADR = {REG_RADR[15:2],2'b00};

integer num;

// SRAM_Axx Control Register
// ----------------------------------------
reg [1:0] r_sram_a_gpio_mode_sel [0:19];
always @ (posedge HCLK) begin
  for (num=0; num<20; num=num+1) begin
    if (!HRESETN)
      r_sram_a_gpio_mode_sel[19-num] <= 0;
    else if ((WADR == `DBG_SRAM_A_CTRLR+(16'h4 * num)) & REG_WENB[0])
      r_sram_a_gpio_mode_sel[19-num] <= REG_WDAT[`DBG_SRAM_A_GPIOMD +: 2];
  end
end

reg [31:0] rd_dbg_sram_a_ctrlr [0:19];
always @ (*) begin
  for (num=0; num<20; num=num+1)
    rd_dbg_sram_a_ctrlr[num] = 32'h0000_0000 | (r_sram_a_gpio_mode_sel[19-num] << `DBG_SRAM_A_GPIOMD);
end

always @ (*) begin
  for (num=0; num<20; num=num+1)
    SRAM_A_GPIO_MODE_SEL[2*num +: 2] = r_sram_a_gpio_mode_sel[num];
end

// SRAM1_CE_B Control Register
// ----------------------------------------
always @ (posedge HCLK) begin
  if (!HRESETN)
    SRAM1_CE_B_GPIO_MODE_SEL <= 0;
  else if ((WADR == `DBG_SRAM1_CEB_CTRLR) & REG_WENB[0])
    SRAM1_CE_B_GPIO_MODE_SEL <= REG_WDAT[`DBG_SRAM1_CEB_GPIOMD +: 2];
end

wire [31:0] rd_dbg_sram1_ceb_ctrlr = 32'h0000_0000 | (SRAM1_CE_B_GPIO_MODE_SEL << `DBG_SRAM1_CEB_GPIOMD);

// SRAM1_OE_B Control Register
// ----------------------------------------
always @ (posedge HCLK) begin
  if (!HRESETN)
    SRAM1_OE_B_GPIO_MODE_SEL <= 0;
  else if ((WADR == `DBG_SRAM1_OEB_CTRLR) & REG_WENB[0])
    SRAM1_OE_B_GPIO_MODE_SEL <= REG_WDAT[`DBG_SRAM1_OEB_GPIOMD +: 2];
end

wire [31:0] rd_dbg_sram1_oeb_ctrlr = 32'h0000_0000 | (SRAM1_OE_B_GPIO_MODE_SEL << `DBG_SRAM1_OEB_GPIOMD);

// SRAM1_WE_B Control Register
// ----------------------------------------
always @ (posedge HCLK) begin
  if (!HRESETN)
    SRAM1_WE_B_GPIO_MODE_SEL <= 0;
  else if ((WADR == `DBG_SRAM1_WEB_CTRLR) & REG_WENB[0])
    SRAM1_WE_B_GPIO_MODE_SEL <= REG_WDAT[`DBG_SRAM1_WEB_GPIOMD +: 2];
end

wire [31:0] rd_dbg_sram1_web_ctrlr = 32'h0000_0000 | (SRAM1_WE_B_GPIO_MODE_SEL << `DBG_SRAM1_WEB_GPIOMD);

// SRAM1_BHE_B Control Register
// ----------------------------------------
always @ (posedge HCLK) begin
  if (!HRESETN)
    SRAM1_BHE_B_GPIO_MODE_SEL <= 0;
  else if ((WADR == `DBG_SRAM1_BHEB_CTRLR) & REG_WENB[0])
    SRAM1_BHE_B_GPIO_MODE_SEL <= REG_WDAT[`DBG_SRAM1_BHEB_GPIOMD +: 2];
end

wire [31:0] rd_dbg_sram1_bheb_ctrlr = 32'h0000_0000 | (SRAM1_BHE_B_GPIO_MODE_SEL << `DBG_SRAM1_BHEB_GPIOMD);

// SRAM1_BLE_B Control Register
// ----------------------------------------
always @ (posedge HCLK) begin
  if (!HRESETN)
    SRAM1_BLE_B_GPIO_MODE_SEL <= 0;
  else if ((WADR == `DBG_SRAM1_BLEB_CTRLR) & REG_WENB[0])
    SRAM1_BLE_B_GPIO_MODE_SEL <= REG_WDAT[`DBG_SRAM1_BLEB_GPIOMD +: 2];
end

wire [31:0] rd_dbg_sram1_bleb_ctrlr = 32'h0000_0000 | (SRAM1_BLE_B_GPIO_MODE_SEL << `DBG_SRAM1_BLEB_GPIOMD);

// SRAM2_CE_B Control Register
// ----------------------------------------
always @ (posedge HCLK) begin
  if (!HRESETN)
    SRAM2_CE_B_GPIO_MODE_SEL <= 0;
  else if ((WADR == `DBG_SRAM2_CEB_CTRLR) & REG_WENB[0])
    SRAM2_CE_B_GPIO_MODE_SEL <= REG_WDAT[`DBG_SRAM2_CEB_GPIOMD +: 2];
end

wire [31:0] rd_dbg_sram2_ceb_ctrlr = 32'h0000_0000 | (SRAM2_CE_B_GPIO_MODE_SEL << `DBG_SRAM2_CEB_GPIOMD);

// SRAM2_OE_B Control Register
// ----------------------------------------
always @ (posedge HCLK) begin
  if (!HRESETN)
    SRAM2_OE_B_GPIO_MODE_SEL <= 0;
  else if ((WADR == `DBG_SRAM2_OEB_CTRLR) & REG_WENB[0])
    SRAM2_OE_B_GPIO_MODE_SEL <= REG_WDAT[`DBG_SRAM2_OEB_GPIOMD +: 2];
end

wire [31:0] rd_dbg_sram2_oeb_ctrlr = 32'h0000_0000 | (SRAM2_OE_B_GPIO_MODE_SEL << `DBG_SRAM2_OEB_GPIOMD);

// SRAM2_WE_B Control Register
// ----------------------------------------
always @ (posedge HCLK) begin
  if (!HRESETN)
    SRAM2_WE_B_GPIO_MODE_SEL <= 0;
  else if ((WADR == `DBG_SRAM2_WEB_CTRLR) & REG_WENB[0])
    SRAM2_WE_B_GPIO_MODE_SEL <= REG_WDAT[`DBG_SRAM2_WEB_GPIOMD +: 2];
end

wire [31:0] rd_dbg_sram2_web_ctrlr = 32'h0000_0000 | (SRAM2_WE_B_GPIO_MODE_SEL << `DBG_SRAM2_WEB_GPIOMD);

// SRAM2_BHE_B Control Register
// ----------------------------------------
always @ (posedge HCLK) begin
  if (!HRESETN)
    SRAM2_BHE_B_GPIO_MODE_SEL <= 0;
  else if ((WADR == `DBG_SRAM2_BHEB_CTRLR) & REG_WENB[0])
    SRAM2_BHE_B_GPIO_MODE_SEL <= REG_WDAT[`DBG_SRAM2_BHEB_GPIOMD +: 2];
end

wire [31:0] rd_dbg_sram2_bheb_ctrlr = 32'h0000_0000 | (SRAM2_BHE_B_GPIO_MODE_SEL << `DBG_SRAM2_BHEB_GPIOMD);

// SRAM2_BLE_B Control Register
// ----------------------------------------
always @ (posedge HCLK) begin
  if (!HRESETN)
    SRAM2_BLE_B_GPIO_MODE_SEL <= 0;
  else if ((WADR == `DBG_SRAM2_BLEB_CTRLR) & REG_WENB[0])
    SRAM2_BLE_B_GPIO_MODE_SEL <= REG_WDAT[`DBG_SRAM2_BLEB_GPIOMD +: 2];
end

wire [31:0] rd_dbg_sram2_bleb_ctrlr = 32'h0000_0000 | (SRAM2_BLE_B_GPIO_MODE_SEL << `DBG_SRAM2_BLEB_GPIOMD);

// SRAM I/F Monitor Register
// ----------------------------------------
wire [31:0] rd_dbg_sram_monr = 32'h0000_0000 | (SRAM_A_GPIO_IN      << `DBG_SRAM_A_MON)
                                             | (SRAM1_CE_B_GPIO_IN  << `DBG_SRAM1_CEB_MON)
                                             | (SRAM1_OE_B_GPIO_IN  << `DBG_SRAM1_OEB_MON)
                                             | (SRAM1_WE_B_GPIO_IN  << `DBG_SRAM1_WEB_MON)
                                             | (SRAM1_BHE_B_GPIO_IN << `DBG_SRAM1_BHEB_MON)
                                             | (SRAM1_BLE_B_GPIO_IN << `DBG_SRAM1_BLEB_MON)
                                             | (SRAM2_CE_B_GPIO_IN  << `DBG_SRAM2_CEB_MON)
                                             | (SRAM2_OE_B_GPIO_IN  << `DBG_SRAM2_OEB_MON)
                                             | (SRAM2_WE_B_GPIO_IN  << `DBG_SRAM2_WEB_MON)
                                             | (SRAM2_BHE_B_GPIO_IN << `DBG_SRAM2_BHEB_MON)
                                             | (SRAM2_BLE_B_GPIO_IN << `DBG_SRAM2_BLEB_MON);

// SRAM ERR Monitor Register
// ----------------------------------------
reg sram1_err_1p;
reg sram2_err_1p;
reg sram1_err_monr;
reg sram2_err_monr;
always @ (posedge HCLK) begin
  if (!HRESETN) begin
    sram1_err_1p <= 0;
    sram2_err_1p <= 0;
    sram1_err_monr <= 0;
    sram2_err_monr <= 0;
  end
  else begin
    sram1_err_1p <= SRAM1_ERR;
    sram2_err_1p <= SRAM2_ERR;
    if (!sram1_err_1p & SRAM1_ERR)
      sram1_err_monr <= 1;
    if (!sram2_err_1p & SRAM2_ERR)
      sram2_err_monr <= 1;
    if ((WADR == `DBG_SRAM_ERR_MONR) & REG_WENB[0]) begin
      sram1_err_monr <= 0;
      sram2_err_monr <= 0;
    end
  end
end
wire [31:0] rd_dbg_sram_err_monr = 32'h0000_0000 | (sram1_err_monr << `DBG_SRAM1_ERR)
                                                 | (sram2_err_monr << `DBG_SRAM2_ERR);

// CFG_MEM_CS_B Control Register
// ----------------------------------------
always @ (posedge HCLK) begin
  if (!HRESETN)
    CFG_MEM_CS_B_GPIO_MODE_SEL <= 0;
  else if ((WADR == `DBG_CFG_MEM_CSB_CTRLR) & REG_WENB[0])
    CFG_MEM_CS_B_GPIO_MODE_SEL <= REG_WDAT[`DBG_CFG_MEM_CSB_GPIOMD +: 2];
end

wire [31:0] rd_dbg_cfg_mem_csb_ctrlr = 32'h0000_0000 | (CFG_MEM_CS_B_GPIO_MODE_SEL << `DBG_CFG_MEM_CSB_GPIOMD);

// CFG_MEM_IOx Control Register
// ----------------------------------------
reg [1:0] r_cfg_mem_io_gpio_mode_sel [0:3];
always @ (posedge HCLK) begin
  for (num=0; num<4; num=num+1) begin
    if (!HRESETN)
      r_cfg_mem_io_gpio_mode_sel[3-num] <= 0;
    else if ((WADR == `DBG_CFG_MEM_IO_CTRLR+(16'h4 * num)) & REG_WENB[0])
      r_cfg_mem_io_gpio_mode_sel[3-num] <= REG_WDAT[`DBG_CFG_MEM_IO_GPIOMD +: 2];
  end
end

reg [31:0] rd_dbg_cfg_mem_io_ctrlr [0:3];
always @ (*) begin
  for (num=0; num<4; num=num+1)
    rd_dbg_cfg_mem_io_ctrlr[num] = 32'h0000_0000 | (r_cfg_mem_io_gpio_mode_sel[3-num] << `DBG_CFG_MEM_IO_GPIOMD);
end

always @ (*) begin
  for (num=0; num<4; num=num+1)
    CFG_MEM_IO_GPIO_MODE_SEL[2*num +: 2] = r_cfg_mem_io_gpio_mode_sel[num];
end

// QSPI CFG_MEM I/F Monitor Register
// ----------------------------------------
wire [31:0] rd_dbg_cfg_mem_monr = 32'h0000_0000 | (CFG_MEM_CS_B_GPIO_IN << `DBG_CFG_MEM_CSB_MON)
                                                | (CFG_MEM_IO_GPIO_IN   << `DBG_CFG_MEM_IO_MON);

// DATA_MEM1_CS_B Control Register
// ----------------------------------------
always @ (posedge HCLK) begin
  if (!HRESETN)
    DATA_MEM1_CS_B_GPIO_MODE_SEL <= 0;
  else if ((WADR == `DBG_DATA_MEM1_CSB_CTRLR) & REG_WENB[0])
    DATA_MEM1_CS_B_GPIO_MODE_SEL <= REG_WDAT[`DBG_DATA_MEM1_CSB_GPIOMD +: 2];
end

wire [31:0] rd_dbg_data_mem1_csb_ctrlr = 32'h0000_0000 | (DATA_MEM1_CS_B_GPIO_MODE_SEL << `DBG_DATA_MEM1_CSB_GPIOMD);

// DATA_MEM1_IOx Control Register
// ----------------------------------------
reg [1:0] r_data_mem1_io_gpio_mode_sel [0:3];
always @ (posedge HCLK) begin
  for (num=0; num<4; num=num+1) begin
    if (!HRESETN)
      r_data_mem1_io_gpio_mode_sel[3-num] <= 0;
    else if ((WADR == `DBG_DATA_MEM1_IO_CTRLR+(16'h4 * num)) & REG_WENB[0])
      r_data_mem1_io_gpio_mode_sel[3-num] <= REG_WDAT[`DBG_DATA_MEM1_IO_GPIOMD +: 2];
  end
end

reg [31:0] rd_dbg_data_mem1_io_ctrlr [0:3];
always @ (*) begin
  for (num=0; num<4; num=num+1)
    rd_dbg_data_mem1_io_ctrlr[num] = 32'h0000_0000 | (r_data_mem1_io_gpio_mode_sel[3-num] << `DBG_DATA_MEM1_IO_GPIOMD);
end

always @ (*) begin
  for (num=0; num<4; num=num+1)
    DATA_MEM1_IO_GPIO_MODE_SEL[2*num +: 2] = r_data_mem1_io_gpio_mode_sel[num];
end

// DATA_MEM2_CS_B Control Register
// ----------------------------------------
always @ (posedge HCLK) begin
  if (!HRESETN)
    DATA_MEM2_CS_B_GPIO_MODE_SEL <= 0;
  else if ((WADR == `DBG_DATA_MEM2_CSB_CTRLR) & REG_WENB[0])
    DATA_MEM2_CS_B_GPIO_MODE_SEL <= REG_WDAT[`DBG_DATA_MEM2_CSB_GPIOMD +: 2];
end

wire [31:0] rd_dbg_data_mem2_csb_ctrlr = 32'h0000_0000 | (DATA_MEM2_CS_B_GPIO_MODE_SEL << `DBG_DATA_MEM2_CSB_GPIOMD);

// DATA_MEM2_IOx Control Register
// ----------------------------------------
reg [1:0] r_data_mem2_io_gpio_mode_sel [0:3];
always @ (posedge HCLK) begin
  for (num=0; num<4; num=num+1) begin
    if (!HRESETN)
      r_data_mem2_io_gpio_mode_sel[3-num] <= 0;
    else if ((WADR == `DBG_DATA_MEM2_IO_CTRLR+(16'h4 * num)) & REG_WENB[0])
      r_data_mem2_io_gpio_mode_sel[3-num] <= REG_WDAT[`DBG_DATA_MEM2_IO_GPIOMD +: 2];
  end
end

reg [31:0] rd_dbg_data_mem2_io_ctrlr [0:3];
always @ (*) begin
  for (num=0; num<4; num=num+1)
    rd_dbg_data_mem2_io_ctrlr[num] = 32'h0000_0000 | (r_data_mem2_io_gpio_mode_sel[3-num] << `DBG_DATA_MEM2_IO_GPIOMD);
end

always @ (*) begin
  for (num=0; num<4; num=num+1)
    DATA_MEM2_IO_GPIO_MODE_SEL[2*num +: 2] = r_data_mem2_io_gpio_mode_sel[num];
end

// QSPI DATA_MEM I/F Monitor Register
// ----------------------------------------
wire [31:0] rd_dbg_data_mem_monr = 32'h0000_0000 | (DATA_MEM1_CS_B_GPIO_IN << `DBG_DATA_MEM1_CSB_MON)
                                                 | (DATA_MEM1_IO_GPIO_IN   << `DBG_DATA_MEM1_IO_MON)
                                                 | (DATA_MEM2_CS_B_GPIO_IN << `DBG_DATA_MEM2_CSB_MON)
                                                 | (DATA_MEM2_IO_GPIO_IN   << `DBG_DATA_MEM2_IO_MON);

// FRAM1_CS_B Control Register
// ----------------------------------------
always @ (posedge HCLK) begin
  if (!HRESETN)
    FRAM1_CS_B_GPIO_MODE_SEL <= 0;
  else if ((WADR == `DBG_FRAM1_CSB_CTRLR) & REG_WENB[0])
    FRAM1_CS_B_GPIO_MODE_SEL <= REG_WDAT[`DBG_FRAM1_CSB_GPIOMD +: 2];
end

wire [31:0] rd_dbg_fram1_csb_ctrlr = 32'h0000_0000 | (FRAM1_CS_B_GPIO_MODE_SEL << `DBG_FRAM1_CSB_GPIOMD);

// FRAM1_IOx Control Register
// ----------------------------------------
reg [1:0] r_fram1_io_gpio_mode_sel [0:3];
always @ (posedge HCLK) begin
  for (num=0; num<4; num=num+1) begin
    if (!HRESETN)
      r_fram1_io_gpio_mode_sel[3-num] <= 0;
    else if ((WADR == `DBG_FRAM1_IO_CTRLR+(16'h4 * num)) & REG_WENB[0])
      r_fram1_io_gpio_mode_sel[3-num] <= REG_WDAT[`DBG_FRAM1_IO_GPIOMD +: 2];
  end
end

reg [31:0] rd_dbg_fram1_io_ctrlr [0:3];
always @ (*) begin
  for (num=0; num<4; num=num+1)
    rd_dbg_fram1_io_ctrlr[num] = 32'h0000_0000 | (r_fram1_io_gpio_mode_sel[3-num] << `DBG_FRAM1_IO_GPIOMD);
end

always @ (*) begin
  for (num=0; num<4; num=num+1)
    FRAM1_IO_GPIO_MODE_SEL[2*num +: 2] = r_fram1_io_gpio_mode_sel[num];
end

// FRAM2_CS_B Control Register
// ----------------------------------------
always @ (posedge HCLK) begin
  if (!HRESETN)
    FRAM2_CS_B_GPIO_MODE_SEL <= 0;
  else if ((WADR == `DBG_FRAM2_CSB_CTRLR) & REG_WENB[0])
    FRAM2_CS_B_GPIO_MODE_SEL <= REG_WDAT[`DBG_FRAM2_CSB_GPIOMD +: 2];
end

wire [31:0] rd_dbg_fram2_csb_ctrlr = 32'h0000_0000 | (FRAM2_CS_B_GPIO_MODE_SEL << `DBG_FRAM2_CSB_GPIOMD);

// FRAM2_IOx Control Register
// ----------------------------------------
reg [1:0] r_fram2_io_gpio_mode_sel [0:3];
always @ (posedge HCLK) begin
  for (num=0; num<4; num=num+1) begin
    if (!HRESETN)
      r_fram2_io_gpio_mode_sel[3-num] <= 0;
    else if ((WADR == `DBG_FRAM2_IO_CTRLR+(16'h4 * num)) & REG_WENB[0])
      r_fram2_io_gpio_mode_sel[3-num] <= REG_WDAT[`DBG_FRAM2_IO_GPIOMD +: 2];
  end
end

reg [31:0] rd_dbg_fram2_io_ctrlr [0:3];
always @ (*) begin
  for (num=0; num<4; num=num+1)
    rd_dbg_fram2_io_ctrlr[num] = 32'h0000_0000 | (r_fram2_io_gpio_mode_sel[3-num] << `DBG_FRAM2_IO_GPIOMD);
end

always @ (*) begin
  for (num=0; num<4; num=num+1)
    FRAM2_IO_GPIO_MODE_SEL[2*num +: 2] = r_fram2_io_gpio_mode_sel[num];
end

// QSPI FRAM I/F Monitor Register
// ----------------------------------------
wire [31:0] rd_dbg_fram_monr = 32'h0000_0000 | (FRAM1_CS_B_GPIO_IN << `DBG_FRAM1_CSB_MON)
                                             | (FRAM1_IO_GPIO_IN   << `DBG_FRAM1_IO_MON)
                                             | (FRAM2_CS_B_GPIO_IN << `DBG_FRAM2_CSB_MON)
                                             | (FRAM2_IO_GPIO_IN   << `DBG_FRAM2_IO_MON);

// SYSCLK Monitor Register
// ----------------------------------------
wire [31:0] rd_dbg_sysclk_monr = 32'h0000_0000 | (SYSCLK2_STATE << `DBG_SYSCLK2_STS)
                                               | (SYSCLK1_STATE << `DBG_SYSCLK1_STS);

// CVM/TEMP Monitor Register
// ----------------------------------------
wire [31:0] rd_dbg_cvmtmp_monr = 32'h0000_0000 | (TEMP_ALERT_B   << `DBG_TMPALERT_MON)
                                               | (CVM_WARNING_B  << `DBG_CVMWARNING_MON)
                                               | (CVM_CRITICAL_B << `DBG_CVMCRITICAL_MON);

// EXT_I2C_SCL Control Register
// ----------------------------------------
always @ (posedge HCLK) begin
  if (!HRESETN)
    EXT_I2C_SCL_GPIO_MODE_SEL <= 2'b11;
  else if ((WADR == `DBG_EXTI2C_SCL_CTLR) & REG_WENB[0])
    EXT_I2C_SCL_GPIO_MODE_SEL <= REG_WDAT[`DBG_EXTI2C_SCL_GPIOMD +: 2];
end

wire [31:0] rd_dbg_exti2c_scl_ctlr = 32'h0000_0000 | (EXT_I2C_SCL_GPIO_MODE_SEL << `DBG_EXTI2C_SCL_GPIOMD);

// EXT_I2C_SDA Control Register
// ----------------------------------------
always @ (posedge HCLK) begin
  if (!HRESETN)
    EXT_I2C_SDA_GPIO_MODE_SEL <= 2'b01;
  else if ((WADR == `DBG_EXTI2C_SDA_CTLR) & REG_WENB[0])
    EXT_I2C_SDA_GPIO_MODE_SEL <= REG_WDAT[`DBG_EXTI2C_SDA_GPIOMD +: 2];
end

wire [31:0] rd_dbg_exti2c_sda_ctlr = 32'h0000_0000 | (EXT_I2C_SDA_GPIO_MODE_SEL << `DBG_EXTI2C_SDA_GPIOMD);

// External I2C I/F Monitor Register
// ----------------------------------------
wire [31:0] rd_dbg_exti2c_monr = 32'h0000_0000 | (EXT_I2C_SCL_GPIO_IN << `DBG_EXTI2C_SCL_MON)
                                               | (EXT_I2C_SDA_GPIO_IN << `DBG_EXTI2C_SDA_MON);

// FPGA_BOOT Monitor Register
// ----------------------------------------
wire [31:0] rd_dbg_boot_monr = 32'h0000_0000 | (FPGA_BOOT_SHIFTREG_IN << `DBG_BOOTSHIFT_MON);

// FPGA_WATCHDOG Control Register
// ----------------------------------------
always @ (posedge HCLK) begin
  if (!HRESETN)
    FPGA_WATCHDOG_GPIO_MODE_SEL <= 0;
  else if ((WADR == `DBG_WATCHDOG_CTRLR) & REG_WENB[0])
    FPGA_WATCHDOG_GPIO_MODE_SEL <= REG_WDAT[`DBG_WATCHDOG_GPIOMD +: 2];
end

wire [31:0] rd_dbg_watchdog_ctrlr = 32'h0000_0000 | (FPGA_WATCHDOG_GPIO_MODE_SEL << `DBG_WATCHDOG_GPIOMD);

// FPGA_PWR_CYCLE_REQ Control Register
// ----------------------------------------
always @ (posedge HCLK) begin
  if (!HRESETN)
    FPGA_PWR_CYCLE_REQ_GPIO_MODE_SEL <= 0;
  else if ((WADR == `DBG_PWR_CYCLE_REQ_CTRLR) & REG_WENB[0])
    FPGA_PWR_CYCLE_REQ_GPIO_MODE_SEL <= REG_WDAT[`DBG_PWR_CYCLE_REQ_GPIOMD +: 2];
end

wire [31:0] rd_dbg_pwr_cycle_req_ctrlr = 32'h0000_0000 | (FPGA_PWR_CYCLE_REQ_GPIO_MODE_SEL << `DBG_PWR_CYCLE_REQ_GPIOMD);

// FPGA_RESERVE Control Register
// ----------------------------------------
always @ (posedge HCLK) begin
  if (!HRESETN)
    FPGA_RESERVE_GPIO_MODE_SEL <= 2'b01;
  else if ((WADR == `DBG_RESERVE_CTRLR) & REG_WENB[0])
    FPGA_RESERVE_GPIO_MODE_SEL <= REG_WDAT[`DBG_RESERVE_GPIOMD +: 2];
end

wire [31:0] rd_dbg_reserve_ctrlr = 32'h0000_0000 | (FPGA_RESERVE_GPIO_MODE_SEL << `DBG_RESERVE_GPIOMD);

// TRCH I/F Monitor Register
// ----------------------------------------
wire [31:0] rd_dbg_trch_monr = 32'h0000_0000 | (FPGA_BOOT1_GPIO_IN         << `DBG_FPGA_BOOT1_MON)
                                             | (FPGA_BOOT0_GPIO_IN         << `DBG_FPGA_BOOT0_MON)
                                             | (FPGA_WATCHDOG_GPIO_IN      << `DBG_WATCHDOG_MON)
                                             | (FPGA_PWR_CYCLE_REQ_GPIO_IN << `DBG_PWR_CYCLE_REQ_MON)
                                             | (FPGA_RESERVE_GPIO_IN       << `DBG_RESERVE_MON);

// FPGA_BOOT0 Control Register
// ----------------------------------------
always @ (posedge HCLK) begin
  if (!HRESETN)
    FPGA_BOOT0_GPIO_MODE_SEL <= 0;
  else if ((WADR == `DBG_FPGA_BOOT0_CTRLR) & REG_WENB[0])
    FPGA_BOOT0_GPIO_MODE_SEL <= REG_WDAT[`DBG_FPGA_BOOT0_GPIOMD +: 2];
end
wire [31:0] rd_dbg_fpga_boot0_ctrlr = 32'h0000_0000 | (FPGA_BOOT0_GPIO_MODE_SEL << `DBG_FPGA_BOOT0_GPIOMD);

// FPGA_BOOT1 Control Register
// ----------------------------------------
always @ (posedge HCLK) begin
  if (!HRESETN)
    FPGA_BOOT1_GPIO_MODE_SEL <= 0;
  else if ((WADR == `DBG_FPGA_BOOT1_CTRLR) & REG_WENB[0])
    FPGA_BOOT1_GPIO_MODE_SEL <= REG_WDAT[`DBG_FPGA_BOOT1_GPIOMD +: 2];
end
wire [31:0] rd_dbg_fpga_boot1_ctrlr = 32'h0000_0000 | (FPGA_BOOT1_GPIO_MODE_SEL << `DBG_FPGA_BOOT1_GPIOMD);

// ULPI_CLOCK Monitor Register
// ----------------------------------------
wire [31:0] rd_dbg_ulpi_clock_monr = 32'h0000_0000 | (ULPI_CLOCK_STATE << `DBG_ULPI_CLOCK_STS);

// ULPI_RESET_B Control Register
// ----------------------------------------
always @ (posedge HCLK) begin
  if (!HRESETN)
    ULPI_RESET_B_GPIO_MODE_SEL <= 2'b11;
  else if ((WADR == `DBG_ULPI_RESET_B_CTRLR) & REG_WENB[0])
    ULPI_RESET_B_GPIO_MODE_SEL <= REG_WDAT[`DBG_ULPI_RESET_B_GPIOMD +: 2];
end

wire [31:0] rd_dbg_ulpi_reset_b_ctrlr = 32'h0000_0000 | (ULPI_RESET_B_GPIO_MODE_SEL << `DBG_ULPI_RESET_B_GPIOMD);

// ULPI_CS Control Register
// ----------------------------------------
always @ (posedge HCLK) begin
  if (!HRESETN)
    ULPI_CS_GPIO_MODE_SEL <= 2'b10;
  else if ((WADR == `DBG_ULPI_CS_CTRLR) & REG_WENB[0])
    ULPI_CS_GPIO_MODE_SEL <= REG_WDAT[`DBG_ULPI_CS_GPIOMD +: 2];
end

wire [31:0] rd_dbg_ulpi_cs_ctrlr = 32'h0000_0000 | (ULPI_CS_GPIO_MODE_SEL << `DBG_ULPI_CS_GPIOMD);

// ULPI I/F Monitor Register
// ----------------------------------------
wire [31:0] rd_dbg_ulpi_monr = 32'h0000_0000 | (ULPI_RESET_B_GPIO_IN << `DBG_ULPI_RESET_B_MON)
                                             | (ULPI_CS_GPIO_IN      << `DBG_ULPI_CS_MON);

// FPGA Config I/F Monitor Register
// ----------------------------------------
wire [31:0] rd_dbg_fpga_cfg_monr = 32'h0000_0000 | (PUDC_B << `DBG_PUDCB_MON);

// UIO1_xx Control Register
// ----------------------------------------
reg [1:0] r_uio1_gpio_mode_sel [0:15];
always @ (posedge HCLK) begin
  for (num=0; num<16; num=num+1) begin
    if (!HRESETN)
      r_uio1_gpio_mode_sel[num] <= 2'b10;
    else if ((WADR == `DBG_UIO1_CTRLR+(16'h4 * num)) & REG_WENB[0])
      r_uio1_gpio_mode_sel[num] <= REG_WDAT[`DBG_UIO1_GPIOMD +: 2];
  end
end

reg [31:0] rd_dbg_uio1_ctrlr [0:15];
always @ (*) begin
  for (num=0; num<16; num=num+1)
    rd_dbg_uio1_ctrlr[num] = 32'h0000_0000 | (r_uio1_gpio_mode_sel[num] << `DBG_UIO1_GPIOMD);
end

always @ (*) begin
  for (num=0; num<16; num=num+1)
    UIO1_GPIO_MODE_SEL[2*num +: 2] = r_uio1_gpio_mode_sel[num];
end

// UIO1 I/F Monitor Register
// ----------------------------------------
wire [31:0] rd_dbg_uio1_monr = 32'h0000_0000 | (UIO1_GPIO_IN << `DBG_UIO1_MON);

// UIO2_xx Control Register
// ----------------------------------------
reg [1:0] r_uio2_gpio_mode_sel [0:15];
always @ (posedge HCLK) begin
  for (num=0; num<16; num=num+1) begin
    if (!HRESETN)
      r_uio2_gpio_mode_sel[num] <= 2'b01;
    else if ((WADR == `DBG_UIO2_CTRLR+(16'h4 * num)) & REG_WENB[0])
      r_uio2_gpio_mode_sel[num] <= REG_WDAT[`DBG_UIO2_GPIOMD +: 2];
  end
end

reg [31:0] rd_dbg_uio2_ctrlr [0:15];
always @ (*) begin
  for (num=0; num<16; num=num+1)
    rd_dbg_uio2_ctrlr[num] = 32'h0000_0000 | (r_uio2_gpio_mode_sel[num] << `DBG_UIO2_GPIOMD);
end

always @ (*) begin
  for (num=0; num<16; num=num+1)
    UIO2_GPIO_MODE_SEL[2*num +: 2] = r_uio2_gpio_mode_sel[num];
end

// UIO2 I/F Monitor Register
// ----------------------------------------
wire [31:0] rd_dbg_uio2_monr = 32'h0000_0000 | (UIO2_GPIO_IN << `DBG_UIO2_MON);

// UIO4_xx Control Register
// ----------------------------------------
reg [1:0] r_uio4_gpio_mode_sel [0:5];
always @ (posedge HCLK) begin
  for (num=0; num<6; num=num+1) begin
    if (!HRESETN) begin
      if (num < 3)
        r_uio4_gpio_mode_sel[num] <= 2'b10;
      else
        r_uio4_gpio_mode_sel[num] <= 2'b01;
    end
    else if ((WADR == `DBG_UIO4_CTRLR+(6'h4 * num)) & REG_WENB[0])
      r_uio4_gpio_mode_sel[num] <= REG_WDAT[`DBG_UIO4_GPIOMD +: 2];
  end
end

reg [31:0] rd_dbg_uio4_ctrlr [0:5];
always @ (*) begin
  for (num=0; num<6; num=num+1)
    rd_dbg_uio4_ctrlr[num] = 32'h0000_0000 | (r_uio4_gpio_mode_sel[num] << `DBG_UIO4_GPIOMD);
end

always @ (*) begin
  for (num=0; num<6; num=num+1)
    UIO4_GPIO_MODE_SEL[2*num +: 2] = r_uio4_gpio_mode_sel[num];
end

// UIO4 I/F Monitor Register
// ----------------------------------------
wire [31:0] rd_dbg_uio4_monr = 32'h0000_0000 | (UIO4_GPIO_IN << `DBG_UIO4_MON);

// RSV_xx Control Register
// ----------------------------------------
reg [1:0] r_rsv_gpio_mode_sel [0:15];
always @ (posedge HCLK) begin
  for (num=0; num<16; num=num+1) begin
    if (!HRESETN)
      r_rsv_gpio_mode_sel[num] <= 0;
    else if ((WADR == `DBG_RSV_CTRLR+(16'h4 * num)) & REG_WENB[0])
      r_rsv_gpio_mode_sel[num] <= REG_WDAT[`DBG_RSV_GPIOMD +: 2];
  end
end

reg [31:0] rd_dbg_rsv_ctrlr [0:15];
always @ (*) begin
  for (num=0; num<16; num=num+1)
    rd_dbg_rsv_ctrlr[num] = 32'h0000_0000 | (r_rsv_gpio_mode_sel[num] << `DBG_RSV_GPIOMD);
end

always @ (*) begin
  for (num=0; num<16; num=num+1)
    RSV_GPIO_MODE_SEL[2*num +: 2] = r_rsv_gpio_mode_sel[num];
end

// RSV I/F Monitor Register
// ----------------------------------------
wire [31:0] rd_dbg_rsv_monr = 32'h0000_0000 | (RSV_GPIO_IN << `DBG_RSV_MON);

// Register Read
// ----------------------------------------
always @ (posedge HCLK) begin
  if (!HRESETN)
    REG_RDAT <= 32'h0000_0000;
  else if (REG_RENB) begin
    REG_RDAT <= 32'h0000_0000;
    for (num=0; num<20; num=num+1) begin
      if (RADR == `DBG_SRAM_A_CTRLR+(16'h4 * num)) REG_RDAT <= rd_dbg_sram_a_ctrlr[num];
    end
    if (RADR == `DBG_SRAM1_CEB_CTRLR) REG_RDAT <= rd_dbg_sram1_ceb_ctrlr;
    if (RADR == `DBG_SRAM1_OEB_CTRLR) REG_RDAT <= rd_dbg_sram1_oeb_ctrlr;
    if (RADR == `DBG_SRAM1_WEB_CTRLR) REG_RDAT <= rd_dbg_sram1_web_ctrlr;
    if (RADR == `DBG_SRAM1_BHEB_CTRLR) REG_RDAT <= rd_dbg_sram1_bheb_ctrlr;
    if (RADR == `DBG_SRAM1_BLEB_CTRLR) REG_RDAT <= rd_dbg_sram1_bleb_ctrlr;
    if (RADR == `DBG_SRAM2_CEB_CTRLR) REG_RDAT <= rd_dbg_sram2_ceb_ctrlr;
    if (RADR == `DBG_SRAM2_OEB_CTRLR) REG_RDAT <= rd_dbg_sram2_oeb_ctrlr;
    if (RADR == `DBG_SRAM2_WEB_CTRLR) REG_RDAT <= rd_dbg_sram2_web_ctrlr;
    if (RADR == `DBG_SRAM2_BHEB_CTRLR) REG_RDAT <= rd_dbg_sram2_bheb_ctrlr;
    if (RADR == `DBG_SRAM2_BLEB_CTRLR) REG_RDAT <= rd_dbg_sram2_bleb_ctrlr;
    if (RADR == `DBG_SRAM_MONR) REG_RDAT <= rd_dbg_sram_monr;
    if (RADR == `DBG_SRAM_IO_MONR) REG_RDAT <= SRAM_IO;
    if (RADR == `DBG_SRAM_ERR_MONR) REG_RDAT <= rd_dbg_sram_err_monr;
    if (RADR == `DBG_CFG_MEM_CSB_CTRLR) REG_RDAT <= rd_dbg_cfg_mem_csb_ctrlr;
    for (num=0; num<4; num=num+1) begin
      if (RADR == `DBG_CFG_MEM_IO_CTRLR+(16'h4 * num)) REG_RDAT <= rd_dbg_cfg_mem_io_ctrlr[num];
    end
    if (RADR == `DBG_CFG_MEM_MONR) REG_RDAT <= rd_dbg_cfg_mem_monr;
    if (RADR == `DBG_DATA_MEM1_CSB_CTRLR) REG_RDAT <= rd_dbg_data_mem1_csb_ctrlr;
    for (num=0; num<4; num=num+1) begin
      if (RADR == `DBG_DATA_MEM1_IO_CTRLR+(16'h4 * num)) REG_RDAT <= rd_dbg_data_mem1_io_ctrlr[num];
    end
    if (RADR == `DBG_DATA_MEM2_CSB_CTRLR) REG_RDAT <= rd_dbg_data_mem2_csb_ctrlr;
    for (num=0; num<4; num=num+1) begin
      if (RADR == `DBG_DATA_MEM2_IO_CTRLR+(16'h4 * num)) REG_RDAT <= rd_dbg_data_mem2_io_ctrlr[num];
    end
    if (RADR == `DBG_DATA_MEM_MONR) REG_RDAT <= rd_dbg_data_mem_monr;
    if (RADR == `DBG_FRAM1_CSB_CTRLR) REG_RDAT <= rd_dbg_fram1_csb_ctrlr;
    for (num=0; num<4; num=num+1) begin
      if (RADR == `DBG_FRAM1_IO_CTRLR+(16'h4 * num)) REG_RDAT <= rd_dbg_fram1_io_ctrlr[num];
    end
    if (RADR == `DBG_FRAM2_CSB_CTRLR) REG_RDAT <= rd_dbg_fram2_csb_ctrlr;
    for (num=0; num<4; num=num+1) begin
      if (RADR == `DBG_FRAM2_IO_CTRLR+(16'h4 * num)) REG_RDAT <= rd_dbg_fram2_io_ctrlr[num];
    end
    if (RADR == `DBG_FRAM_MONR) REG_RDAT <= rd_dbg_fram_monr;
    if (RADR == `DBG_SYSCLK_MONR) REG_RDAT <= rd_dbg_sysclk_monr;
    if (RADR == `DBG_CVMTMP_MONR) REG_RDAT <= rd_dbg_cvmtmp_monr;
    if (RADR == `DBG_EXTI2C_SCL_CTLR) REG_RDAT <= rd_dbg_exti2c_scl_ctlr;
    if (RADR == `DBG_EXTI2C_SDA_CTLR) REG_RDAT <= rd_dbg_exti2c_sda_ctlr;
    if (RADR == `DBG_EXTI2C_MONR) REG_RDAT <= rd_dbg_exti2c_monr;
    if (RADR == `DBG_BOOT_MONR) REG_RDAT <= rd_dbg_boot_monr;
    if (RADR == `DBG_WATCHDOG_CTRLR) REG_RDAT <= rd_dbg_watchdog_ctrlr;
    if (RADR == `DBG_PWR_CYCLE_REQ_CTRLR) REG_RDAT <= rd_dbg_pwr_cycle_req_ctrlr;
    if (RADR == `DBG_RESERVE_CTRLR) REG_RDAT <= rd_dbg_reserve_ctrlr;
    if (RADR == `DBG_TRCH_MONR) REG_RDAT <= rd_dbg_trch_monr;
    if (RADR == `DBG_FPGA_BOOT0_CTRLR) REG_RDAT <= rd_dbg_fpga_boot0_ctrlr;
    if (RADR == `DBG_FPGA_BOOT1_CTRLR) REG_RDAT <= rd_dbg_fpga_boot1_ctrlr;
    if (RADR == `DBG_ULPI_CLOCK_MONR) REG_RDAT <= rd_dbg_ulpi_clock_monr;
    if (RADR == `DBG_ULPI_RESET_B_CTRLR) REG_RDAT <= rd_dbg_ulpi_reset_b_ctrlr;
    if (RADR == `DBG_ULPI_CS_CTRLR) REG_RDAT <= rd_dbg_ulpi_cs_ctrlr;
    if (RADR == `DBG_ULPI_MONR) REG_RDAT <= rd_dbg_ulpi_monr;
    if (RADR == `DBG_FPGA_CFG_MONR) REG_RDAT <= rd_dbg_fpga_cfg_monr;
    for (num=0; num<16; num=num+1) begin
      if (RADR == `DBG_UIO1_CTRLR+(16'h4 * num)) REG_RDAT <= rd_dbg_uio1_ctrlr[num];
    end
    if (RADR == `DBG_UIO1_MONR) REG_RDAT <= rd_dbg_uio1_monr;
    for (num=0; num<16; num=num+1) begin
      if (RADR == `DBG_UIO2_CTRLR+(16'h4 * num)) REG_RDAT <= rd_dbg_uio2_ctrlr[num];
    end
    if (RADR == `DBG_UIO2_MONR) REG_RDAT <= rd_dbg_uio2_monr;
    for (num=0; num<6; num=num+1) begin
      if (RADR == `DBG_UIO4_CTRLR+(16'h4 * num)) REG_RDAT <= rd_dbg_uio4_ctrlr[num];
    end
    if (RADR == `DBG_UIO4_MONR) REG_RDAT <= rd_dbg_uio4_monr;
    for (num=0; num<16; num=num+1) begin
      if (RADR == `DBG_RSV_CTRLR+(16'h4 * num)) REG_RDAT <= rd_dbg_rsv_ctrlr[num];
    end
    if (RADR == `DBG_RSV_MONR) REG_RDAT <= rd_dbg_rsv_monr;
  end
end

endmodule
