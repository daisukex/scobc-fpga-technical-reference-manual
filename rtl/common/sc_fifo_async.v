//-----------------------------------------------
// Module: sc_fifo_async
//  Space Cubics Asynchronous FIFO Module
//-----------------------------------------------
// Copyright © 2021 Space Cubics, LLC.
//-----------------------------------------------
module sc_fifo_async # (
  parameter P_FIFO_WIDTH = 8,
  parameter P_FIFO_DEPTH = 4,
  parameter P_FIFO_TYPE = 0, // 0: BlockRAM 1: Shift Register
  parameter P_DCNT_SYNC_TYPE = 0 // 0: WR_CLK SYNC 1: RD_CLK SYNC
)
(
  input WR_RSTB,
  input WR_CLK,
  input RD_RSTB,
  input RD_CLK,

  // Write Port (WR_CLK Sync)
  input WR_EN,
  input [P_FIFO_WIDTH-1:0] DIN,

  input FIFO_RST,

  output reg FULL,
  output reg OVERFLOW,
  input [P_FIFO_DEPTH:0] OVER_TH_LVL,
  output reg OVER_TH,

  // Read Port (RD_CLK Sync)
  input RD_EN,
  output reg [P_FIFO_WIDTH-1:0] DOUT,

  output reg EMPTY,
  output reg UNDERFLOW,
  input [P_FIFO_DEPTH:0] UNDER_TH_LVL,
  output reg UNDER_TH,

  // Data Count (DCNT_SYNC_TYPE Sync)
  output reg [P_FIFO_DEPTH:0] DATA_COUNT

);

reg [P_FIFO_DEPTH-1:0] r_write_ptr;
reg [P_FIFO_DEPTH-1:0] r_read_ptr;

(* ram_style = "block" *) reg [P_FIFO_WIDTH-1:0] mem_bram [0:2**P_FIFO_DEPTH-1] ;
(* ram_style = "registers" *) reg [P_FIFO_WIDTH-1:0] mem_ff [0:2**P_FIFO_DEPTH-1] ;

reg [P_FIFO_WIDTH-1:0] mout;

wire [P_FIFO_DEPTH:0] w_data_count_sync;
wire [P_FIFO_DEPTH:0] w_data_count_wsync;
wire [P_FIFO_DEPTH:0] w_data_count_rsync;

wire w_fifo_rst_rsync;
wire w_wr_en_rsync;
wire w_rd_en_wsync;

// FIFO Pointer
always @ (posedge WR_CLK or negedge WR_RSTB) begin
  if (!WR_RSTB) begin
    r_write_ptr <= 0;
  end else if (FIFO_RST) begin
    r_write_ptr <= 0;
  end else begin
    if (WR_EN)
      r_write_ptr <= r_write_ptr + 1;
  end
end

always @ (posedge RD_CLK or negedge RD_RSTB) begin
  if (!RD_RSTB) begin
    r_read_ptr <= 0;
  end else if (w_fifo_rst_rsync) begin
    r_read_ptr <= 0;
  end else begin
    if (RD_EN)
      r_read_ptr <= r_read_ptr  + 1;
  end
end

// Write/Read Control
always@ (posedge RD_CLK) begin
  DOUT <= mout;
end

generate
  if (P_FIFO_TYPE) begin
    always@ (posedge WR_CLK) begin
      if (WR_EN)
        mem_ff[r_write_ptr] <= DIN;
    end
    always@ (posedge RD_CLK) begin
      mout <= mem_ff[r_read_ptr];
    end
  end else begin
    always@ (posedge WR_CLK) begin
      if (WR_EN)
        mem_bram[r_write_ptr] <= DIN;
    end
    always@ (posedge RD_CLK) begin
      mout <= mem_bram[r_read_ptr];
    end
  end
endgenerate

// Data Counter
generate
  if (P_DCNT_SYNC_TYPE == 0) begin

    always @ (posedge WR_CLK or negedge WR_RSTB) begin
      if (!WR_RSTB)
        DATA_COUNT <= 0;
      else if (FIFO_RST)
        DATA_COUNT <= 0;
      else begin
        if (WR_EN & ~w_rd_en_wsync) begin
          if (~DATA_COUNT[P_FIFO_DEPTH])
            DATA_COUNT <= DATA_COUNT + 1;
        end
        else if (w_rd_en_wsync & ~WR_EN) begin
          if (|DATA_COUNT)
            DATA_COUNT <= DATA_COUNT - 1;
        end
      end
    end

    sc_clk_conv_bus # (
      .P_USE_VLD(0),
      .P_DT_WIDTH(P_FIFO_DEPTH+1)
    ) cconv_dcount_rd (
      .IN_RSTB(WR_RSTB),            // input
      .IN_CLK(WR_CLK),              // input
      .IN_VALID(1'b0),              // input
      .IN_DATA(DATA_COUNT),         // input [P_DT_WIDTH-1:0]
      .SYNC_RSTB(RD_RSTB),          // input
      .SYNC_CLK(RD_CLK),            // input
      .SYNC_VALID(/*open*/),        // output
      .SYNC_DATA(w_data_count_sync) // output [P_DT_WIDTH-1:0]
    );
    assign w_data_count_wsync = DATA_COUNT;
    assign w_data_count_rsync = w_data_count_sync;

  end
  else begin

    always @ (posedge RD_CLK or negedge RD_RSTB) begin
      if (!RD_RSTB)
        DATA_COUNT <= 0;
      else if (w_fifo_rst_rsync)
        DATA_COUNT <= 0;
      else begin
        if (w_wr_en_rsync & ~RD_EN) begin
          if (~DATA_COUNT[P_FIFO_DEPTH])
            DATA_COUNT <= DATA_COUNT + 1;
        end
        else if (RD_EN & ~w_wr_en_rsync) begin
          if (|DATA_COUNT)
            DATA_COUNT <= DATA_COUNT - 1;
        end
      end
    end

    sc_clk_conv_bus # (
      .P_USE_VLD(0),
      .P_DT_WIDTH(P_FIFO_DEPTH+1)
    ) cconv_dcount_wr (
      .IN_RSTB(RD_RSTB),            // input
      .IN_CLK(RD_CLK),              // input
      .IN_VALID(1'b0),              // input
      .IN_DATA(DATA_COUNT),         // input [P_DT_WIDTH-1:0]
      .SYNC_RSTB(WR_RSTB),          // input
      .SYNC_CLK(WR_CLK),            // input
      .SYNC_VALID(/*open*/),        // output
      .SYNC_DATA(w_data_count_sync) // output [P_DT_WIDTH-1:0]
    );
    assign w_data_count_wsync = w_data_count_sync;
    assign w_data_count_rsync = DATA_COUNT;

  end
endgenerate

// Interrupt
always @ (posedge WR_CLK or negedge WR_RSTB) begin
  if (!WR_RSTB) begin
    FULL       <= 0;
    OVERFLOW   <= 0;
    OVER_TH    <= 0;
  end else if (FIFO_RST) begin
    FULL       <= 0;
    OVERFLOW   <= 0;
    OVER_TH    <= 0;
  end else begin
    FULL       <= 0;
    OVERFLOW   <= 0;
    OVER_TH    <= 0;
    if (WR_EN & ~w_rd_en_wsync) begin
      if (w_data_count_wsync[P_FIFO_DEPTH]) begin
        OVERFLOW <= 1'b1;
      end else begin
        if (&w_data_count_wsync[P_FIFO_DEPTH-1:0])
          FULL <= 1'b1;
        if (|OVER_TH_LVL & (w_data_count_wsync == OVER_TH_LVL))
          OVER_TH <= 1'b1;
      end
    end
  end
end

always @ (posedge RD_CLK or negedge RD_RSTB) begin
  if (!RD_RSTB) begin
    EMPTY      <= 0;
    UNDERFLOW  <= 0;
    UNDER_TH   <= 0;
  end else if (w_fifo_rst_rsync) begin
    EMPTY      <= 0;
    UNDERFLOW  <= 0;
    UNDER_TH   <= 0;
  end else begin
    EMPTY      <= 0;
    UNDERFLOW  <= 0;
    UNDER_TH   <= 0;
    if (RD_EN & ~w_wr_en_rsync) begin
      if (~|w_data_count_rsync) begin
        UNDERFLOW <= 1'b1;
      end else begin
        if (~|w_data_count_rsync[P_FIFO_DEPTH:1])
          EMPTY <= 1'b1;
        if (~UNDER_TH_LVL[P_FIFO_DEPTH] & (w_data_count_rsync == UNDER_TH_LVL))
          UNDER_TH <= 1'b1;
      end
    end
  end
end

// Clock Converter
sc_clk_conv_pls # (
  .P_POLARITY(1) // 1: Positive 0: Negative
) cconv_fifo_rst_rd (
  .IN_RSTB(WR_RSTB),          // input
  .IN_CLK(WR_CLK),            // input
  .IN_PLS(FIFO_RST),          // input
  .SYNC_RSTB(RD_RSTB),        // input
  .SYNC_CLK(RD_CLK),          // input
  .SYNC_PLS(w_fifo_rst_rsync) // output
);

sc_clk_conv_pls # (
  .P_POLARITY(1) // 1: Positive 0: Negative
) cconv_wr_en_rd (
  .IN_RSTB(WR_RSTB),       // input
  .IN_CLK(WR_CLK),         // input
  .IN_PLS(WR_EN),          // input
  .SYNC_RSTB(RD_RSTB),     // input
  .SYNC_CLK(RD_CLK),       // input
  .SYNC_PLS(w_wr_en_rsync) // output
);

sc_clk_conv_pls # (
  .P_POLARITY(1) // 1: Positive 0: Negative
) cconv_rd_en_wr (
  .IN_RSTB(RD_RSTB),       // input
  .IN_CLK(RD_CLK),         // input
  .IN_PLS(RD_EN),          // input
  .SYNC_RSTB(WR_RSTB),     // input
  .SYNC_CLK(WR_CLK),       // input
  .SYNC_PLS(w_rd_en_wsync) // output
);

endmodule
