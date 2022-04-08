//-----------------------------------------------
// Space Cubics Cortex-M3 SubSystem
//  Cortex-M3 I-Code/D-Code AHB Multiplexer
//  Module: sc_cm3_ahb_mux
//-----------------------------------------------
// Copyright © 2022 Space Cubics, LLC.
//-----------------------------------------------

module sc_cm3_ahb_mux (
  // System Interface
  input HCLK,
  input HRESETN,

  // AHB I-Code Bus
  input  [1:0] HTRANSI,
  input  [31:0] HADDRI,
  input  [2:0] HBURSTI,
  input  [2:0] HSIZEI,
  input  [3:0] HPROTI,
  input  [31:0] HWDATAI,
  output reg [31:0] HRDATAI,
  output reg HREADYI,
  output reg [1:0] HRESPI,

  // AHB D-Code Bus
  input  [1:0] HTRANSD,
  input  [31:0] HADDRD,
  input  [2:0] HBURSTD,
  input  HWRITED,
  input  [2:0] HSIZED,
  input  [31:0] HWDATAD,
  output reg [31:0] HRDATAD,
  output reg HREADYD,
  output reg [1:0] HRESPD,

  // AHB MUX Bus
  output reg [1:0] HTRANS,
  output reg [31:0] HADDR,
  output reg [2:0] HBURST,
  output reg HWRITE,
  output reg [2:0] HSIZE,
  output reg [3:0] HPROT,
  output reg [31:0] HWDATA,
  input [31:0] HRDATA,
  input HREADY,
  input [1:0] HRESP
);

parameter IDL = 2'b00,
          BSY = 2'b01,
          NSQ = 2'b10,
          SEQ = 2'b11;

reg [3:0] tbuf [0:1];
reg tbwp, tbrp;
reg [1:0]  tns [0:1];
reg [31:0] adr [0:1];
reg [2:0]  bst [0:1];
reg [0:1]  wrt;
reg [2:0]  sze [0:1];
reg [3:0]  prt [0:1];
reg [2:0] hchsel;
reg [2:0] hdtval;
reg mhadp;
reg mhdtp;
reg [1:0] mhresp;
reg [31:0] mhrdata;

wire itstart = (HTRANSI == NSQ);
wire ittrans = (HTRANSI == SEQ);
wire itidle  = (HTRANSI == IDL);
wire dtstart = (HTRANSD == NSQ);
wire dttrans = (HTRANSD == SEQ);
wire dtidle  = (HTRANSD == IDL);

// I-Code/D-Code AHB Controller
// ------------------------------
always @ (posedge HCLK) begin
  if (!HRESETN) begin
    HREADYI <= 1'b1;
    HREADYD <= 1'b1;
    tbuf[0] <= 4'b0000;
    tbuf[1] <= 4'b0000;
    tbwp <= 0;
    tbrp <= 0;
    hchsel <= 2'b00;
    hdtval <= 2'b00;
  end
  else begin
    // Address Queue
    if (HREADYI & itstart) begin
      tbuf[tbwp][1:0] <= 2'b01;
      tbuf[tbwp][2] <= 1'b0;
      tbuf[tbwp][3] <= HBURSTI != 3'b000;
      tbwp <= ~tbwp;
      HREADYI <= 1'b0;
    end
    else if (HREADYD & dtstart) begin
      tbuf[tbwp][1:0] <= 2'b10;
      tbuf[tbwp][2] <= HWRITED;
      tbuf[tbwp][3] <= HBURSTD != 3'b000;
      tbwp <= ~tbwp;
      HREADYD <= 1'b0;
    end

    if (HREADYI & (itstart | ittrans)) begin
      tns[0] <= HTRANSI;
      adr[0] <= HADDRI;
      bst[0] <= HBURSTI;
      wrt[0] <= 1'b0;
      sze[0] <= HSIZEI;
      prt[0] <= HPROTI;
      HREADYI <= 1'b0;
    end
    else if (ittrans & HREADY)
      tns[0] <= BSY;

    if (HREADYD & (dtstart | dttrans)) begin
      tns[1] <= HTRANSD;
      adr[1] <= HADDRD;
      bst[1] <= HBURSTD;
      wrt[1] <= HWRITED;
      sze[1] <= HSIZED;
      prt[1] <= 4'b1111;
      HREADYD <= 1'b0;
    end
    else if (dttrans & HREADY)
      tns[1] <= BSY;

    // Trans queue read pointer
    if (HREADY) begin
      if (mhadp & !tbuf[tbrp][3]) begin
        tbrp <= ~tbrp;
        tbuf[tbrp][1:0] <= 2'b00;
      end
      else if (mhadp & tbuf[tbrp][3] &
             ((tbuf[tbrp][1:0] == 2'b01 & (itstart | itidle)) |
              (tbuf[tbrp][1:0] == 2'b10 & (dtstart | dtidle)))) begin
        tbrp <= ~tbrp;
        tbuf[tbrp][1:0] <= 2'b00;
      end
      else if (mhadp & tbuf[~tbrp][1:0] != 2'b00) begin
        tbrp <= ~tbrp;
        tbuf[tbrp][1:0] <= 2'b00;
      end
    end

    if (HREADY) begin
      hdtval <= 2'b00;
      hchsel <= tbuf[tbrp][1:0];
      if (mhdtp) begin
        if (hchsel[0]) begin
          hdtval[0] <= 1'b1;
          HREADYI <= 1'b1;
        end
        if (hchsel[1]) begin
          hdtval[1] <= 1'b1;
          HREADYD <= 1'b1;
        end
      end
    end
  end
end

// I-Code/D-Code AHB Signal Select
// ----------------------------------------
always @ (*) begin
  HRDATAI <= 32'h0000_0000;
  HRESPI <= 2'b00;
  HRDATAD <= 32'h0000_0000;
  HRESPD <= 2'b00;
  if (hdtval[0]) begin
    HRDATAI <= mhrdata;
    HRESPI <= mhresp;
  end
  if (hdtval[1]) begin
    HRDATAD <= mhrdata;
    HRESPD <= mhresp;
  end
end

always @ (posedge HCLK) begin
  if (!HRESETN)
    HWDATA <= 32'h0000_0000;
  else if (HREADY & tbuf[tbrp][1:0] == 2'b10 & tbuf[tbrp][2] == 1'b1)
    HWDATA <= HWDATAD;
end

// Mux AHB Cycle Selector
// ----------------------------------------
always @ (*) begin
  if (tbuf[tbrp][1:0] == 2'b01) begin
    HTRANS = tns[0];
    HADDR = adr[0];
    HBURST = bst[0];
    HWRITE = wrt[0];
    HSIZE = sze[0];
    HPROT = prt[0];
    mhadp = 1;
  end
  else if (tbuf[tbrp][1:0] == 2'b10) begin
    HTRANS = tns[1];
    HADDR = adr[1];
    HBURST = bst[1];
    HWRITE = wrt[1];
    HSIZE = sze[1];
    HPROT = prt[1];
    mhadp = 1;
  end
  else begin
    HTRANS = IDL;
    HADDR = 32'h0000_0000;
    HBURST = 3'b000;
    HWRITE = 1'b0;
    HSIZE = 3'b000;
    HPROT = 4'b1111;
    mhadp = 0;
  end
end

always @ (posedge HCLK) begin
  if (!HRESETN) begin
    mhdtp <= 0;
    mhresp <= 2'b00;
    mhrdata <= 32'h0000_0000;
  end
  else if (HREADY) begin
    mhdtp <= mhadp & (HTRANS != BSY);
    if (mhdtp) begin
      mhresp <= HRESP;
      mhrdata <= HRDATA;
    end
  end
end

endmodule
