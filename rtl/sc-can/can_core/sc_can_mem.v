//-----------------------------------------------
// sc_can_mem
//  Space Cubics CAN Controller Memory Module
//-----------------------------------------------
// Copyright © 2022 Space Cubics, LLC.
//-----------------------------------------------
module sc_can_mem # (
  parameter SC_CAN_MEM_DT_WIDTH = 8,
  parameter SC_CAN_MEM_AD_WIDTH = 4,
  parameter SC_CAN_MEM_TYPE = 0 // 0: BlockRAM 1: Frip Frop
)
(
  input WR_RSTB,
  input WR_CLK,
  input RD_RSTB,
  input RD_CLK,

  // Write Port (WR_CLK Sync)
  input WR_EN,
  input [SC_CAN_MEM_AD_WIDTH-1:0] WR_ADR,
  input [SC_CAN_MEM_DT_WIDTH-1:0] WR_DAT,

  // Read Port (RD_CLK Sync)
  input [SC_CAN_MEM_AD_WIDTH-1:0] RD_ADR,
  output reg [SC_CAN_MEM_DT_WIDTH-1:0] RD_DAT
);

(* ram_style = "block" *) reg [SC_CAN_MEM_DT_WIDTH-1:0] mem_bram [0:2**SC_CAN_MEM_AD_WIDTH-1] ;
(* ram_style = "registers" *) reg [SC_CAN_MEM_DT_WIDTH-1:0] mem_ff [0:2**SC_CAN_MEM_AD_WIDTH-1] ;

reg [SC_CAN_MEM_DT_WIDTH-1:0] mout;

// Write/Read Control
generate
  if (SC_CAN_MEM_TYPE) begin
    always@ (posedge WR_CLK) begin
      if (WR_EN)
        mem_ff[WR_ADR] <= WR_DAT;
    end
    always@ (posedge RD_CLK) begin
      mout <= mem_ff[RD_ADR];
    end
  end else begin
    always@ (posedge WR_CLK) begin
      if (WR_EN)
        mem_bram[WR_ADR] <= WR_DAT;
    end
    always@ (posedge RD_CLK) begin
      mout <= mem_bram[RD_ADR];
    end
  end
endgenerate

always@ (posedge RD_CLK) begin
  RD_DAT <= mout;
end

endmodule
