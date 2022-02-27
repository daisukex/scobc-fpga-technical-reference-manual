//-----------------------------------------------
// Space Cubics AXIM2AHBS_NB Core
//  AXI Master to AHB Slave (No Burst) Module
//  Module : sc_axim2ahbs_nb
//-----------------------------------------------
// Copyright © 2022 Space Cubics, LLC.
//-----------------------------------------------

module sc_axim2ahbs_nb # (
  parameter AXIM2AHBSNB_ID_WIDTH      = 4,
  parameter AXIM2AHBSNB_HCLK_IDLE_BIT = 5
) (
  // Global Signal
  input ACLK,
  input ARESETN,

  // AXI Master Interface
  //--------------------------------------
  // Write Address Channel Signal
  input  [AXIM2AHBSNB_ID_WIDTH-1:0] AWID,
  input  [31:0] AWADDR,
  input  [7:0] AWLEN,
  input  [2:0] AWSIZE,
  input  [1:0] AWBURST,
  input  AWVALID,
  output reg AWREADY,

  // Write Data Channel Signal
  input  [31:0] WDATA,
  input  [3:0] WSTRB,
  input  WLAST,
  input  WVALID,
  output reg WREADY,

  // Write Responce Channel Signal
  output reg [1:0] BRESP,
  output reg BVALID,
  input  BREADY,
  output reg [AXIM2AHBSNB_ID_WIDTH-1:0] BID,

  // Read Address Channel Signal
  input  [AXIM2AHBSNB_ID_WIDTH-1:0] ARID,
  input  [31:0] ARADDR,
  input  [7:0] ARLEN,
  input  [2:0] ARSIZE,
  input  [1:0] ARBURST,
  input  ARVALID,
  output reg ARREADY,

  // Read Data Channel Signal
  output reg [AXIM2AHBSNB_ID_WIDTH-1:0] RID,
  output reg [31:0] RDATA,
  output reg [1:0] RRESP,
  output reg RLAST,
  output reg RVALID,
  input  RREADY,

  // AHB Slave Interface
  //--------------------------------------
  output reg [31:0] HADDR,
  output reg [1:0] HTRANS,
  output HWRITE,
  output reg [2:0] HSIZE,
  output [2:0] HBURST,
  output reg [31:0] HWDATA,
  input  [31:0] HRDATA,
  input  HREADY,
  input  [1:0] HRESP,
  output reg HCLKEN
);

// AXI State Parameter
parameter XIDL = 2'b00, // IDLE State
          XDAT = 2'b01, // AXI Data
          XRES = 2'b10, // AXI Responce
          XERR = 2'b11; // AXI Error

// AXI Write Channel
//----------------------------------------
reg [2:0] xwstate;
wire log_wa_valid;
wire log_wd_valid;
assign log_wa_valid = AWVALID & AWREADY;
assign log_wd_valid = WVALID & WREADY;

reg xwad_valid;
reg xwdt_valid;
reg xwdt_error;
reg [AXIM2AHBSNB_ID_WIDTH:0] reg_awid;
reg [31:0] reg_awaddr;
reg [7:0] reg_awlen;
wire [3:0] hwstb;
wire hwdt_comp;

// Write Address Latch
always @ (posedge ACLK or negedge ARESETN) begin
  if (!ARESETN) begin
    xwad_valid <= 0;
    reg_awid <= 0;
    reg_awaddr <= 0;
    reg_awlen <= 0;
    AWREADY <= 1'b0;
  end
  else begin
    if (xwstate == XERR) begin
      if (log_wd_valid & WLAST) begin
        AWREADY <= 1'b1;
        xwad_valid <= 0;
      end
    end
    else if (hwdt_comp) begin
      AWREADY <= 1'b1;
      xwad_valid <= 0;
    end
    else if (log_wa_valid) begin
      reg_awid <= AWID;
      reg_awaddr <= AWADDR;
      reg_awlen <= AWLEN;
      AWREADY <= 1'b0;
      xwad_valid <= 1;
    end
    else if (!xwad_valid & !AWREADY)
      AWREADY <= 1'b1;
  end
end

// Write Data Latch
reg [31:0] reg_wdata;
reg [3:0] reg_wstrb;
reg reg_wlast;
always @ (posedge ACLK or negedge ARESETN) begin
  if (!ARESETN) begin
    xwdt_valid <= 0;
    reg_wdata <= 0;
    reg_wstrb <= 0;
    reg_wlast <= 0;
    WREADY <= 1'b0;
  end
  else begin
    if (xwstate == XERR) begin
      WREADY <= 1'b1;
      if (log_wd_valid & WLAST)
        xwdt_valid <= 0;
    end
    else if (hwdt_comp) begin
      WREADY <= 1'b1;
      xwdt_valid <= 0;
    end
    else if (log_wd_valid) begin
      reg_wdata <= WDATA;
      reg_wstrb <= WSTRB;
      reg_wlast <= WLAST;
      WREADY <= 1'b0;
      xwdt_valid <= 1;
    end
    else if (!xwdt_valid & !WREADY)
      WREADY <= 1'b1;
  end
end

// AXI Write State Machine
wire req_ahb_write;
always @ (posedge ACLK or negedge ARESETN) begin
  if (!ARESETN) begin
    BID <= 0;
    BRESP <= 2'b00;
    BVALID <= 1'b0;
    xwdt_error <= 1'b0;
    xwstate <= XIDL;
  end

  // xIDLE State
  else if (xwstate == XIDL) begin
    if (log_wa_valid & (log_wd_valid | xwdt_valid)) begin
      if (AWLEN != 0)
        xwstate <= XERR;
      else
        xwstate <= XDAT;
    end
    else if (xwad_valid & log_wd_valid) begin
      if (reg_awlen != 0)
        xwstate <= XERR;
      else
        xwstate <= XDAT;
    end
  end

  // xWrite Data State
  else if (xwstate == XDAT) begin
    if (hwdt_comp) begin
      BID <= reg_awid;
      if (xwdt_error | (HREADY & HRESP == 2'b01))
        BRESP <= 2'b10;
      else
        BRESP <= 2'b00;
      BVALID <= 1'b1;
      xwstate <= XRES;
    end
    else if (HREADY & HRESP == 2'b01)
      xwdt_error <= 1'b1;
  end

  // xWrite Responce State
  else if (xwstate == XRES) begin
    if (BREADY) begin
      BID <= 0;
      BRESP <= 2'b00;
      BVALID <= 1'b0;
      xwstate <= XIDL;
    end
  end

  // xWrite Error State
  else if (xwstate == XERR) begin
    if (log_wd_valid) begin
      if (WLAST) begin
        BID <= reg_awid;
        BRESP <= 2'b10;
        BVALID <= 1'b1;
        xwstate <= XRES;
      end
    end
  end
end
assign req_ahb_write = (xwstate == XIDL) &
                       ((log_wd_valid | AWLEN == 0) & (xwad_valid & reg_awlen == 0)) &
                       (log_wd_valid | xwdt_valid);
assign hwstb  = (log_wd_valid) ? WSTRB: (xwad_valid) ? reg_wstrb: 4'h0;

// AXI Read Channel
//----------------------------------------
reg [2:0] xrstate;
wire log_ra_valid;
wire log_rd_valid;
assign log_ra_valid = ARVALID & ARREADY;
assign log_rd_valid = RVALID & RREADY;

reg xrad_valid;
reg [AXIM2AHBSNB_ID_WIDTH:0] reg_arid;
reg [31:0] reg_araddr;
reg [7:0] reg_arlen;
reg [2:0] reg_arsize;
reg [1:0] reg_arburst;
wire hrdt_comp;

// Read Address Latch
always @ (posedge ACLK or negedge ARESETN) begin
  if (!ARESETN) begin
    xrad_valid <= 0;
    reg_arid <= 0;
    reg_araddr <= 0;
    reg_arlen <= 0;
    reg_arsize <= 0;
    reg_arburst <= 0;
    ARREADY <= 1'b0;
  end
  else begin
    if (xrstate == XERR) begin
      if (log_rd_valid & RLAST) begin
        ARREADY <= 1'b1;
        xrad_valid <= 0;
      end
    end
    else if (hrdt_comp) begin
      ARREADY <= 1'b1;
      xrad_valid <= 0;
    end
    else if (log_ra_valid) begin
      reg_arid <= ARID;
      reg_araddr <= ARADDR;
      reg_arlen <= ARLEN;
      reg_arsize <= ARSIZE;
      reg_arburst <= ARBURST;
      ARREADY <= 1'b0;
      xrad_valid <= 1;
    end
    else if (!xrad_valid & !ARREADY)
      ARREADY <= 1'b1;
  end
end

//  AXI Read State Machine
wire req_ahb_read;
always @ (posedge ACLK or negedge ARESETN) begin
  // Reset
  if (!ARESETN) begin
    RID <= 0;
    RDATA <= 32'h0000_0000;
    RRESP <= 2'b00;
    RLAST <= 1'b0;
    RVALID <= 1'b0;
    xrstate <= XIDL;
  end

  // xIDLE State
  else if (xrstate == XIDL) begin
    if (log_ra_valid) begin
      if (ARLEN == 0)
        xrstate <= XDAT;
      else begin
        RDATA <= 32'h0;
        RRESP <= 2'b10;
        RLAST <= 1'b0;
        RVALID <= 1'b1;
        xrstate <= XERR;
      end
    end
  end

  // xRead Data State
  else if (xrstate == XDAT) begin
    if (log_rd_valid) begin
      RDATA <= 32'h0;
      RRESP <= 2'b00;
      RLAST <= 1'b0;
      RVALID <= 1'b0;
      xrstate <= XIDL;
    end
    else if (hrdt_comp) begin
      RDATA <= HRDATA;
      if (HRESP == 2'b01)
        RRESP <= 2'b10;
      else
        RRESP <= 2'b00;
      RVALID <= 1'b1;
      RLAST <= 1'b1;
    end
  end

  // xRead Error State
  else if (xrstate == XERR) begin
    if (log_rd_valid) begin
      if (reg_arlen == 0) begin
        RDATA <= 32'h0;
        RRESP <= 2'b00;
        RLAST <= 1'b0;
        RVALID <= 1'b0;
        xrstate <= XIDL;
      end
      else begin
        if (reg_arlen == 1)
          RLAST <= 1'b1;
        reg_arlen <= reg_arlen - 1;
      end
    end
  end
end
assign req_ahb_read = log_ra_valid & (ARLEN == 0);

// AHB Bus Controller
//----------------------------------------
parameter HIDL = 2'b00,
          HADR = 2'b01,
          HWDT = 2'b10,
          HRDT = 2'b11;

// AHB Cycle Parameter
wire [11:0] ahb_param [15:0];
assign ahb_param[4'b0000] = {3'b000, 2'h0, 1'b0, 3'b000, 2'h0, 1'b0};
assign ahb_param[4'b0001] = {3'b000, 2'h0, 1'b0, 3'b000, 2'h0, 1'b1};
assign ahb_param[4'b0010] = {3'b000, 2'h0, 1'b0, 3'b000, 2'h1, 1'b1};
assign ahb_param[4'b0011] = {3'b000, 2'h0, 1'b0, 3'b001, 2'h0, 1'b1};
assign ahb_param[4'b0100] = {3'b000, 2'h0, 1'b0, 3'b000, 2'h2, 1'b1};
assign ahb_param[4'b0101] = {3'b000, 2'h0, 1'b1, 3'b000, 2'h2, 1'b1};
assign ahb_param[4'b0110] = {3'b000, 2'h1, 1'b1, 3'b000, 2'h2, 1'b1};
assign ahb_param[4'b0111] = {3'b001, 2'h0, 1'b1, 3'b000, 2'h2, 1'b1};
assign ahb_param[4'b1000] = {3'b000, 2'h0, 1'b0, 3'b000, 2'h3, 1'b1};
assign ahb_param[4'b1001] = {3'b000, 2'h3, 1'b1, 3'b000, 2'h0, 1'b1};
assign ahb_param[4'b1010] = {3'b000, 2'h3, 1'b1, 3'b000, 2'h1, 1'b1};
assign ahb_param[4'b1011] = {3'b000, 2'h3, 1'b0, 3'b001, 2'h0, 1'b1};
assign ahb_param[4'b1100] = {3'b000, 2'h0, 1'b0, 3'b001, 2'h2, 1'b1};
assign ahb_param[4'b1101] = {3'b001, 2'h2, 1'b1, 3'b000, 2'h0, 1'b1};
assign ahb_param[4'b1110] = {3'b001, 2'h2, 1'b1, 3'b000, 2'h1, 1'b1};
assign ahb_param[4'b1111] = {3'b000, 2'h0, 1'b0, 3'b010, 2'h0, 1'b1};

// AHB State Machine
reg dir_r0w1;
reg ahb_cycle;
reg [1:0] had_state;
reg [1:0] hdt_state;
reg rem_write;
reg rem_ahb_cycle;
always @ (posedge ACLK or negedge ARESETN) begin
  if (!ARESETN) begin
    dir_r0w1 <= 1'b0;
    ahb_cycle <= 0;
    HTRANS <= 2'b00;
    rem_write <= 1'b0;
    rem_ahb_cycle <= 1'b0;
    had_state <= HIDL;
    hdt_state <= HIDL;
  end
  else begin
    // Address Channel
    if (had_state == HIDL) begin
      if (HREADY) begin
        if (HRESP == 2'b10) begin
          HTRANS <= 2'b10;
          ahb_cycle <= rem_ahb_cycle;
          had_state <= HADR;
          dir_r0w1 <= rem_write;
        end
        else if (req_ahb_read & req_ahb_write) begin
          HTRANS <= 2'b10;
          had_state <= HADR;
          if (!dir_r0w1) begin
            ahb_cycle <= ahb_param[hwstb][6];
            dir_r0w1 <= 1'b1;
          end
          else begin
            ahb_cycle <= 0;
            dir_r0w1 <= 1'b0;
          end
        end
        else if (req_ahb_read) begin
          ahb_cycle <= 0;
          dir_r0w1 <= 1'b0;
          HTRANS <= 2'b10;
          had_state <= HADR;
        end
        else if (req_ahb_write) begin
          ahb_cycle <= ahb_param[hwstb][6];
          dir_r0w1 <= 1'b1;
          HTRANS <= 2'b10;
          had_state <= HADR;
        end
      end
    end
    else if (had_state == HADR) begin
      if (HREADY) begin
        if (ahb_cycle)
          ahb_cycle <= 0;
        else if (req_ahb_read) begin
          ahb_cycle <= 0;
          dir_r0w1 <= 1'b0;
        end
        else if (req_ahb_write) begin
          ahb_cycle <= ahb_param[hwstb][6];
          dir_r0w1 <= 1'b1;
        end
        else begin
          HTRANS <= 2'b00;
          had_state <= HIDL;
        end
      end
      else if (HRESP == 2'b10) begin
        HTRANS <= 2'b00;
        had_state <= HIDL;
      end
    end

    // Data Channel
    if (hdt_state == HIDL) begin
      if (HREADY & had_state == HADR) begin
        rem_write <= HWRITE;
        rem_ahb_cycle <= ahb_cycle;
        if (dir_r0w1)
          hdt_state <= HWDT;
        else
          hdt_state <= HRDT;
      end
    end
    else if (hdt_state == HWDT) begin
      if (HREADY) begin
        if (had_state == HADR) begin
          rem_write <= HWRITE;
          rem_ahb_cycle <= ahb_cycle;
          if (dir_r0w1)
            hdt_state <= HWDT;
          else
            hdt_state <= HRDT;
        end
        else
          hdt_state <= HIDL;
      end
    end
    else if (hdt_state == HRDT) begin
      if (HREADY) begin
        if (had_state != HADR)
          hdt_state <= HIDL;
      end
    end
  end
end
assign hwdt_comp = (hdt_state == HWDT) & HREADY & ((HRESP == 2'b00 & !rem_ahb_cycle) | HRESP == 2'b01);
assign hrdt_comp = (hdt_state == HRDT) & HREADY & (HRESP == 2'b00 | HRESP == 2'b01);

always @ (*) begin
  if (had_state == HADR) begin
    if (dir_r0w1) begin
      if (ahb_cycle) begin
        HADDR = {reg_awaddr[31:2], ahb_param[hwstb][8:7]};
        HSIZE = ahb_param[hwstb][11:9];
      end
      else begin
        HADDR = {reg_awaddr[31:2], ahb_param[hwstb][2:1]};
        HSIZE = ahb_param[hwstb][5:3];
      end
    end
    else begin
      HADDR = reg_araddr;
      HSIZE = reg_arsize;
    end
  end
  else begin
    HADDR = 0;
    HSIZE = 3'b010;
  end
end
assign HWRITE = dir_r0w1;
assign HBURST = 3'b000;

always @ (*) begin
  if (hdt_state == HWDT)
    HWDATA = reg_wdata;
  else
    HWDATA = 32'h0;
end

// HCLK Control
//----------------------------------------
reg [AXIM2AHBSNB_HCLK_IDLE_BIT-1:0] idle_count;
always @ (posedge ACLK or negedge ARESETN) begin
  if (!ARESETN) begin
    HCLKEN <= 1'b0;
    idle_count <= 0;
  end
  else if (log_wa_valid | log_wd_valid | log_ra_valid) begin
    HCLKEN <= 1'b1;
    idle_count <= 0;
  end
  else if (had_state == HIDL & hdt_state == HIDL) begin
    if (idle_count == {AXIM2AHBSNB_HCLK_IDLE_BIT{1'b1}}) begin
      HCLKEN <= 1'b0;
      idle_count <= 0;
    end
    else
      idle_count <= idle_count + 1;
  end
end

endmodule
