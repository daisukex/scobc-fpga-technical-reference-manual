//-----------------------------------------------
// Module: sc_fifo
//  Space Cubics FIFO Module
//-----------------------------------------------
// Copyright © 2020 Space Cubics, LLC.
//-----------------------------------------------
module sc_fifo # (
  parameter P_FIFO_WIDTH = 8,
  parameter P_FIFO_DEPTH = 4,
  parameter P_FIFO_TYPE = 0 // 0: BlockRAM 1: Shift Register
)
(
  input CLK,
  input SRST_N,
  input FIFO_RST,

  input WR_EN,
  input [P_FIFO_WIDTH-1:0] DIN,
  input RD_EN,
  output reg [P_FIFO_WIDTH-1:0] DOUT,

  input [P_FIFO_DEPTH:0] OVER_TH_LVL,
  input [P_FIFO_DEPTH:0] UNDER_TH_LVL,

  output reg FULL,
  output reg EMPTY,
  output reg OVERFLOW,
  output reg UNDERFLOW,
  output reg OVER_TH,
  output reg UNDER_TH,
  output reg [P_FIFO_DEPTH:0] DATA_COUNT
);

reg [P_FIFO_DEPTH-1:0] r_write_ptr;
reg [P_FIFO_DEPTH-1:0] r_read_ptr;

(* ram_style = "block" *) reg [P_FIFO_WIDTH-1:0] mem_bram [0:2**P_FIFO_DEPTH-1] ;
(* ram_style = "registers" *) reg [P_FIFO_WIDTH-1:0] mem_ff [0:2**P_FIFO_DEPTH-1] ;

reg [P_FIFO_WIDTH-1:0] mout;

// FIFO Pointer
always @ (posedge CLK or negedge SRST_N) begin
  if (!SRST_N) begin
    r_write_ptr <= 0;
    r_read_ptr  <= 0;
  end else if (FIFO_RST) begin
    r_write_ptr <= 0;
    r_read_ptr  <= 0;
  end else begin
    if (WR_EN)
      r_write_ptr <= r_write_ptr + 1;
    if (RD_EN)
      r_read_ptr  <= r_read_ptr  + 1;
  end
end

// Write/Read Control
always@ (posedge CLK) begin
  DOUT           <= mout;
end

generate
  if (P_FIFO_TYPE) begin
    always@ (posedge CLK) begin
      if (WR_EN)
        mem_ff[r_write_ptr] <= DIN;
      mout <= mem_ff[r_read_ptr];
    end
  end else begin
    always@ (posedge CLK) begin
      if (WR_EN)
        mem_bram[r_write_ptr] <= DIN;
      mout <= mem_bram[r_read_ptr];
    end
  end
endgenerate

// Interrupt,Data Counter
always @ (posedge CLK or negedge SRST_N) begin
  if (!SRST_N) begin
    FULL       <= 0;
    EMPTY      <= 0;
    OVERFLOW   <= 0;
    UNDERFLOW  <= 0;
    OVER_TH    <= 0;
    UNDER_TH   <= 0;
    DATA_COUNT <= 0;
  end else if (FIFO_RST) begin
    FULL       <= 0;
    EMPTY      <= 0;
    OVERFLOW   <= 0;
    UNDERFLOW  <= 0;
    OVER_TH    <= 0;
    UNDER_TH   <= 0;
    DATA_COUNT <= 0;
  end else begin
    FULL       <= 0;
    EMPTY      <= 0;
    OVERFLOW   <= 0;
    UNDERFLOW  <= 0;
    OVER_TH    <= 0;
    UNDER_TH   <= 0;
    if (WR_EN & ~RD_EN) begin
      if (DATA_COUNT[P_FIFO_DEPTH]) begin
        OVERFLOW <= 1'b1;
      end else begin
        DATA_COUNT <= DATA_COUNT + 1;
        if (&DATA_COUNT[P_FIFO_DEPTH-1:0])
          FULL <= 1'b1;
        if (|OVER_TH_LVL & (DATA_COUNT == OVER_TH_LVL))
          OVER_TH <= 1'b1;
      end
    end else if (RD_EN & ~WR_EN) begin
      if (~|DATA_COUNT) begin
        UNDERFLOW <= 1'b1;
      end else begin
        DATA_COUNT <= DATA_COUNT - 1;
        if (~|DATA_COUNT[P_FIFO_DEPTH:1])
          EMPTY <= 1'b1;
        if (~UNDER_TH_LVL[P_FIFO_DEPTH] & (DATA_COUNT == UNDER_TH_LVL))
          UNDER_TH <= 1'b1;
      end
    end
  end
end

endmodule
