//-----------------------------------------------
// Space Cubics Standard IP Core
// AHB Slave Core
// Module: sc_ahb_slave
//-----------------------------------------------
// Copyright © 2020 Space Cubics, LLC.
//-----------------------------------------------
module sc_ahb_slave (
  // AHB Interface
  input  HCLK,
  input  HRESETN,
  input  HSEL,
  input  [31:0] HADDR,
  input  [1:0]  HTRANS,
  input  [2:0]  HSIZE,
  input  [2:0]  HBURST,
  input  HWRITE,
  input  HREADYIN,
  output HREADYOUT,
  input  [31:0] HWDATA,
  output [31:0] HRDATA,
  output [1:0] HRESP,

  // Register Interface
  output AHB_WR,
  output AHB_RD,
  output [31:0] AHB_ADDR,
  input  AHB_WAIT,
  output reg REG_DPHASE,
  output reg REG_W1R0,
  output reg [31:0] REG_ADDR,
  output reg [3:0] REG_BYTEEN,
  output [31:0] REG_WDATA,
  input  [31:0] REG_RDATA,
  input  REG_ACCERR
);

wire acc_byte;
wire acc_half;
wire acc_word;
wire [3:0] byte_en;
reg [2:0] awsize;
reg reg_accerr_p1;
reg hready_wait;

parameter
  SINGLE = 3'b000,
  INCR   = 3'b001,
  INCR4  = 3'b011,
  INCR8  = 3'b101,
  INCR16 = 3'b111;

parameter
  NONSEQ = 2'b10,
  SEQ    = 2'b11;

assign AHB_RD = HSEL & HTRANS[1] & HREADYIN & ~HWRITE;
assign AHB_WR = HSEL & HTRANS[1] & HREADYIN & HWRITE;
assign AHB_ADDR = HADDR;

assign acc_byte = (HSIZE == 3'b000);
assign acc_half = (HSIZE == 3'b001);
assign acc_word = HSIZE[1];

assign byte_en[0] = acc_byte & (HADDR[1:0] == 2'b00)
                  | acc_half & ~|HADDR[1:0]
                  | acc_word;
assign byte_en[1] = acc_byte & (HADDR[1:0] == 2'b01)
                  | acc_half & ~HADDR[1]
                  | acc_word;
assign byte_en[2] = acc_byte & (HADDR[1:0] == 2'b10)
                  | acc_half & (HADDR[1] ^ HADDR[0])
                  | acc_word;
assign byte_en[3] = acc_byte & (HADDR[1:0] == 2'b11)
                  | acc_half & HADDR[1]
                  | acc_word;

assign REG_WDATA = HWDATA;

always @ (negedge HRESETN or posedge HCLK)
begin
  if (!HRESETN) begin
    REG_DPHASE <= 1'b0;
  end
  else begin
    if (!REG_DPHASE)
      REG_DPHASE <= AHB_RD | AHB_WR;
    else
      REG_DPHASE <= ~HREADYOUT | AHB_RD | AHB_WR;
  end
end

always @ (negedge HRESETN or posedge HCLK)
begin
  if (!HRESETN) begin
    REG_ADDR   <= 32'h0;
    REG_BYTEEN <= 4'h0;
    REG_W1R0   <= 1'b0;
    awsize     <= 3'h0;
  end
  else if ((AHB_RD | AHB_WR ) & (HTRANS == NONSEQ)) begin
    REG_ADDR   <= HADDR;
    REG_BYTEEN <= byte_en;
    awsize     <= (acc_byte) ? 3'h1:
                  (acc_half) ? 3'h2: 3'h4;
    REG_W1R0   <= AHB_WR;
  end
  else if ((AHB_RD | AHB_WR) & (HTRANS == SEQ)) begin
    REG_ADDR <= REG_ADDR + {29'h0, awsize};
  end
end

assign HRDATA = (REG_DPHASE) ? {{8{REG_BYTEEN[3]}} & REG_RDATA[31:24],
                                {8{REG_BYTEEN[2]}} & REG_RDATA[23:16],
                                {8{REG_BYTEEN[1]}} & REG_RDATA[15:8],
                                {8{REG_BYTEEN[0]}} & REG_RDATA[7:0]}
                             : 32'h0;
assign HRESP = (REG_DPHASE) ? {1'b0, REG_ACCERR} : 2'b00;

always @ (negedge HRESETN or posedge HCLK)
begin
  if (!HRESETN) begin
    reg_accerr_p1 <= 1'b0;
    hready_wait   <= 1'b1;
  end
  else begin
    reg_accerr_p1 <= REG_ACCERR;
    hready_wait   <= ~AHB_WAIT;
  end
end

assign HREADYOUT = hready_wait & ~(REG_ACCERR & ~reg_accerr_p1);

endmodule
