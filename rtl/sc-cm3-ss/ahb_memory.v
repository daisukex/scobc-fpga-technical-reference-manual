//-----------------------------------------------
// Space Cubics AHB Memory
//  Module: ahb_memory
//-----------------------------------------------
// Copyright © 2022 Space Cubics, LLC.
//-----------------------------------------------

module ahb_memory # (
  parameter MEM_SIZE_KB = 8,
  parameter MEM_ADDR_BW = 13,
  parameter MEM_INIT = "off",
  parameter MEM_INIT_FILE = "code.hex"
) (
  // System Interface
  input HCLK,
  input HRESETN,

  // AHB Interface
  input HSEL,
  input [1:0] HTRANS,
  input [31:0] HADDR,
  input [2:0] HBURST,
  input HWRITE,
  input [2:0] HSIZE,
  input [3:0] HPROT,
  input [31:0] HWDATA,
  output HREADY,
  output reg [31:0] HRDATA,
  output [1:0] HRESP
);

wire acc_byte;
wire acc_half;
wire acc_word;
wire [3:0] byte_en;
reg [3:0] ben;
reg [31:0] mem [0:256*MEM_SIZE_KB-1];
reg wen;
wire ren;
reg [MEM_ADDR_BW-3:0] waddr;
wire [MEM_ADDR_BW-3:0] raddr;

assign acc_byte = (HSIZE == 3'b000);
assign acc_half = (HSIZE == 3'b001);
assign acc_word = HSIZE[1];

assign byte_en[0] = acc_byte & (HADDR[1:0] == 2'b00)
                  | acc_half & ~HADDR[1]
                  | acc_word;
assign byte_en[1] = acc_byte & (HADDR[1:0] == 2'b01)
                  | acc_half & ~HADDR[1]
                  | acc_word;
assign byte_en[2] = acc_byte & (HADDR[1:0] == 2'b10)
                  | acc_half & HADDR[1]
                  | acc_word;
assign byte_en[3] = acc_byte & (HADDR[1:0] == 2'b11)
                  | acc_half & HADDR[1]
                  | acc_word;

assign HRESP = 2'b00;
assign HREADY = 1'b1;

// Memory Initialize
// --------------------------------------------------
if (MEM_INIT == "on") begin
  initial begin
    $readmemh(MEM_INIT_FILE, mem, 0, 256*MEM_SIZE_KB-1);
  end
end

// Memory Write
// --------------------------------------------------
always @ (posedge HCLK) begin
  if (!HRESETN) begin
    wen <= 1'b0;
    ben <= 4'b0000;
  end
  else begin
    wen <= 1'b0;
    ben <= 4'b0000;
    if (HSEL & HWRITE & HREADY) begin
      // NONSEQ / SEQ
      if (HTRANS == 2'b10 | HTRANS == 2'b11) begin
        wen <= 1'b1;
        waddr <= HADDR[MEM_ADDR_BW-1:2];
        ben <= byte_en;
      end
    end
  end
end

// Memory Write
always @ (posedge HCLK) begin
  if (wen) begin
    if (ben[0]) mem[waddr][7:0]   <= HWDATA[7:0];
    if (ben[1]) mem[waddr][15:8]  <= HWDATA[15:8];
    if (ben[2]) mem[waddr][23:16] <= HWDATA[23:16];
    if (ben[3]) mem[waddr][31:24] <= HWDATA[31:24];
  end
end

// Memory Read
// --------------------------------------------------
assign ren   = HSEL & ~HWRITE & (HTRANS == 2'b10 | HTRANS == 2'b11);
assign raddr = HADDR[MEM_ADDR_BW-1:2];

always @ (posedge HCLK) begin
  if (ren)
    HRDATA <= mem[raddr];
end

always @ (*) begin
  if (ren & wen & raddr == waddr)
    $display("read/write confrict addr:%x", raddr);
end
endmodule
