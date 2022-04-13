//-----------------------------------------------
// Module: sc_can_txhpb
//  Space Cubics CAN Controller TX High Priority Buffer
//-----------------------------------------------
// Copyright © 2021 Space Cubics, LLC.
//-----------------------------------------------
module sc_can_txhpb (
  input CAN_CLK,
  input CAN_RSTB,

  input TXHPB_RST,

  input TXHPB1_WEN,
  input [31:0] TXHPB1_WDATA,
  input TXHPB2_WEN,
  input [3:0] TXHPB2_WDATA,
  input TXHPB3_WEN,
  input [31:0] TXHPB3_WDATA,
  input TXHPB4_WEN,
  input [31:0] TXHPB4_WDATA,

  output reg TXHPB_DVALID,

  input TXHPB_REN,
  output reg [99:0] TXHPB_RDATA,
  input TXHPB_RD_END,

  output reg TXHPB_OVERFLOW,
  output reg TXHPB_UNDERFLOW
);

reg [3:0] r_txhpb_en;
reg [99:0] r_txhpb_data;
reg [99:0] r_txhpb_rout;

always @ (posedge CAN_CLK or negedge CAN_RSTB) begin
  if (!CAN_RSTB) begin
    r_txhpb_en   <= 0;
    r_txhpb_data <= 0;
    r_txhpb_rout <= 0;
    TXHPB_DVALID <= 0;
    TXHPB_RDATA  <= 0;
  end else if (TXHPB_RST) begin
    r_txhpb_en   <= 0;
    r_txhpb_data <= 0;
    r_txhpb_rout <= 0;
    TXHPB_DVALID <= 0;
    TXHPB_RDATA  <= 0;
  end else begin
    if (TXHPB_RD_END) begin
      r_txhpb_en   <= 0;
      r_txhpb_data <= 0;
    end
    else begin
      if (TXHPB1_WEN & ~r_txhpb_en[0]) begin
        r_txhpb_en[0]       <= 1'b1;
        r_txhpb_data[99:68] <= TXHPB1_WDATA;
      end
      if (TXHPB2_WEN & ~r_txhpb_en[1]) begin
        r_txhpb_en[1]       <= 1'b1;
        r_txhpb_data[67:64] <= TXHPB2_WDATA;
      end
      if (TXHPB3_WEN & ~r_txhpb_en[2]) begin
        r_txhpb_en[2]       <= 1'b1;
        r_txhpb_data[63:32] <= TXHPB3_WDATA;
      end
      if (TXHPB4_WEN & ~r_txhpb_en[3]) begin
        r_txhpb_en[3]       <= 1'b1;
        r_txhpb_data[31:0]  <= TXHPB4_WDATA;
      end
    end
    if (TXHPB_REN & TXHPB_DVALID)
      r_txhpb_rout <= r_txhpb_data;
    TXHPB_DVALID <= &r_txhpb_en;
    TXHPB_RDATA  <= r_txhpb_rout;
  end
end

always @ (posedge CAN_CLK or negedge CAN_RSTB) begin
  if (!CAN_RSTB) begin
    TXHPB_OVERFLOW  <= 0;
    TXHPB_UNDERFLOW <= 0;
  end else if (TXHPB_RST) begin
    TXHPB_OVERFLOW  <= 0;
    TXHPB_UNDERFLOW <= 0;
  end else begin
    TXHPB_OVERFLOW  <= 0;
    TXHPB_UNDERFLOW <= 0;
    if ((r_txhpb_en[0] & TXHPB1_WEN) | (r_txhpb_en[1] & TXHPB2_WEN) |
        (r_txhpb_en[2] & TXHPB3_WEN) | (r_txhpb_en[3] & TXHPB4_WEN) )
      TXHPB_OVERFLOW  <= 1'b1;
    if (~TXHPB_DVALID & TXHPB_REN)
      TXHPB_UNDERFLOW <= 1'b1;
  end
end

endmodule
