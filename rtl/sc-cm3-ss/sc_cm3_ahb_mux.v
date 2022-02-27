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

reg ivalid;
reg iburst;
reg dvalid;
reg dburst;
reg [1:0] cycle_id;
reg [1:0] htns [0:1];
reg [31:0] hadr [0:1];
reg [2:0] hbst [0:1];
reg hwrt;
reg [2:0] hsze [0:1];
reg [3:0] hprt [0:1];
reg [31:0] hwdt;
reg hinvalid;

wire itstart = (HTRANSI == NSQ);
wire ittrans = (HTRANSI == SEQ);
wire itidle  = (HTRANSI == IDL);
wire dtstart = (HTRANSD == NSQ);
wire dttrans = (HTRANSD == SEQ);
wire dtidle  = (HTRANSD == IDL);

// I-Code/D-Code AHB Controller
always @ (posedge HCLK or negedge HRESETN) begin
  if (!HRESETN) begin
    ivalid <= 1'b0;
    iburst <= 1'b0;
    dvalid <= 1'b0;
    dburst <= 1'b0;
    HRDATAI <= 32'h0;
    HREADYI <= 1'b1;
    HRESPI <= 2'b00;
    HRDATAD <= 32'h0;
    HREADYD <= 1'b1;
    HRESPD <= 2'b00;
  end
  else begin

    if (itstart & HREADYI) begin
      ivalid <= 1'b1;
      if (HBURSTI != 3'b000)
        iburst <= 1'b1;
      else
        iburst <= 1'b0;
    end
    else if (cycle_id[0] & HREADY) begin
      if (~iburst | (iburst & (itstart | itidle))) begin
        iburst <= 1'b0;
        ivalid <= 1'b0;
      end
    end
    else if (iburst & (itstart | itidle))
      iburst <= 1'b0;

    if (itstart & HREADYI) begin
      HREADYI <= 1'b0;
      htns[0] <= HTRANSI;
      hadr[0] <= HADDRI;
      hbst[0] <= HBURSTI;
      hsze[0] <= HSIZEI;
      hprt[0] <= HPROTI;
    end
    else if (iburst & HREADYI) begin
      htns[0] <= HTRANSI;
      hadr[0] <= HADDRI;
      hbst[0] <= HBURSTI;
      hsze[0] <= HSIZEI;
      hprt[0] <= HPROTI;
    end

    if (cycle_id[0] & hinvalid)
      HREADYI <= 1'b0;
    else if (cycle_id[0] & HREADY) begin
      HRDATAI <= HRDATA;
      HREADYI <= 1'b1;
      HRESPI <= HRESP;
    end

    if (dtstart & HREADYD) begin
      dvalid <= 1'b1;
      if (HBURSTD != 3'b000)
        dburst <= 1'b1;
      else
        dburst <= 1'b0;
    end
    else if (cycle_id[1] & HREADY) begin
      if (~dburst | (dburst & (dtstart | dtidle))) begin
        dvalid <= 1'b0;
        dburst <= 1'b0;
      end
    end
    else if (dburst & (dtstart | dtidle))
      dburst <= 1'b0;

    if (dtstart & HREADYD) begin
      HREADYD <= 1'b0;
      htns[1] <= HTRANSD;
      hadr[1] <= HADDRD;
      hbst[1] <= HBURSTD;
      hwrt <= HWRITED;
      hsze[1] <= HSIZED;
      hprt[1] <= 4'b1111;
    end
    else if (dburst & HREADYD) begin
      htns[1] <= HTRANSD;
      hadr[1] <= HADDRD;
      hbst[1] <= HBURSTD;
      hwrt <= HWRITED;
      hsze[1] <= HSIZED;
      hprt[1] <= 4'b1111;
    end

    if (dvalid & hwrt)
      hwdt <= HWDATAD;

    if (cycle_id[1] & hinvalid)
      HREADYD <= 1'b0;
    else if (cycle_id[1] & HREADY) begin
      HRDATAD <= HRDATA;
      HREADYD <= 1'b1;
      HRESPD <= HRESP;
    end
  end
end

// AHB Cycle Controller
always @ (posedge HCLK or negedge HRESETN) begin
  if (!HRESETN)
    cycle_id <= 2'b00;
  else begin
    if (HREADY & ~hinvalid) begin
      if (~cycle_id[0] & ivalid)
        cycle_id[0] <= 1'b1;
      else if ((~iburst & cycle_id[0]) | (iburst & (itstart | itidle)))
        cycle_id[0] <= 1'b0;

      if (~cycle_id[1] & dvalid)
        cycle_id[1] <= 1'b1;
      else if ((~dburst & cycle_id[1]) | (dburst & (dtstart | dtidle)))
        cycle_id[1] <= 1'b0;
    end
  end
end

reg adphase;
always @ (posedge HCLK or negedge HRESETN) begin
  if (!HRESETN)
    adphase <= 1'b0;
  else if ((itstart | ittrans) & HREADYI)
    adphase <= 1'b1;
  else if ((dtstart | dttrans) & HREADYD)
    adphase <= 1'b1;
  else
    adphase <= 1'b0;
end

always @ (*) begin
  HTRANS = IDL;
  HADDR = 32'h0;
  HBURST = 3'h0;
  HWRITE = 1'b0;
  HSIZE = 3'h0;
  HPROT = 4'b1111;
  HWDATA = 32'h0;
  if (adphase) begin
    if (cycle_id == 2'b00) begin
      if (ivalid) begin
        HTRANS = htns[0];
        HADDR = hadr[0];
        HBURST = hbst[0];
        HWRITE = 1'b0;
        HSIZE = hsze[0];
        HPROT = hprt[0];
      end
      else if (dvalid) begin
        HTRANS = htns[1];
        HADDR = hadr[1];
        HBURST = hbst[1];
        HWRITE = hwrt;
        HSIZE = hsze[1];
        HPROT = hprt[1];
      end
    end

    else if (cycle_id == 2'b01) begin
      if (iburst) begin
        HTRANS = htns[0];
        HADDR  = hadr[0];
        HBURST = hbst[0];
        HWRITE = 1'b0;
        HSIZE  = hsze[0];
        HPROT  = hprt[0];
      end
      else if (dvalid) begin
        HTRANS = htns[1];
        HADDR  = hadr[1];
        HBURST = hbst[1];
        HWRITE = hwrt;
        HSIZE  = hsze[1];
        HPROT  = hprt[1];
      end
    end

    else if (cycle_id == 2'b10) begin
      if (dburst) begin
        HTRANS = htns[1];
        HADDR  = hadr[1];
        HBURST = hbst[1];
        HWRITE = hwrt;
        HSIZE  = hsze[1];
        HPROT  = hprt[1];
      end
      else if (ivalid) begin
        HTRANS = htns[0];
        HADDR  = hadr[0];
        HBURST = hbst[0];
        HWRITE = 1'b0;
        HSIZE  = hsze[0];
        HPROT  = hprt[0];
      end
    end
  end
  else begin
    if (iburst) begin
      HTRANS = BSY;
      HADDR  = hadr[0];
      HBURST = hbst[0];
      HWRITE = 1'b0;
      HSIZE  = hsze[0];
      HPROT  = hprt[0];
    end
    else if (dburst) begin
      HTRANS = BSY;
      HADDR  = hadr[1];
      HBURST = hbst[1];
      HWRITE = hwrt;
      HSIZE  = hsze[1];
      HPROT  = hprt[1];
    end
  end

  if (cycle_id[1] & hwrt)
    HWDATA = hwdt;
end

wire [31:0] dbg_hadr0 = hadr[0];
wire [31:0] dbg_hadr1 = hadr[1];

always @ (posedge HCLK or negedge HRESETN) begin
  if (!HRESETN)
    hinvalid <= 1'b0;
  else if (HTRANS == BSY)
    hinvalid <= 1'b1;
  else
    hinvalid <= 1'b0;
end

endmodule
