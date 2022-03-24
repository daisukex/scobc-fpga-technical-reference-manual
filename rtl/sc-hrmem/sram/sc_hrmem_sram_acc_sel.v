//-----------------------------------------------
// Module: sc_hrmem_sram_acc_sel
//  Space Cubics StaticRAM Access Selector
//-----------------------------------------------
// Copyright © 2022 Space Cubics, LLC.
//-----------------------------------------------
module sc_hrmem_sram_acc_sel # (
  parameter P_AD_W = 20,
  parameter P_DT_W = 32
) (
  // System Interface
  input                   CLK,
  input                   RESET_N,

  // AXI SRAM Controller Interface
  input                   AXI_WEN,
  input      [P_AD_W-1:0] AXI_WADR,
  input    [P_DT_W/8-1:0] AXI_WBTEN,
  input      [P_DT_W-1:0] AXI_WDATA,

  input                   AXI_REN,
  input      [P_AD_W-1:0] AXI_RADR,
  input    [P_DT_W/8-1:0] AXI_RBTEN,

  // MEM Scrub Controller Interface
  input                   MEM_COR_VAL,
  input      [P_AD_W-1:0] MEM_COR_ADR,
  input      [P_DT_W/8-1:0] MEM_COR_BTEN,
  input      [P_DT_W-1:0] MEM_COR_DATA,
  input                   MEM_COR_VAL_BEF,
  output                  MEM_COR_VAL_CXL,
  output     [P_AD_W-1:0] MEM_COR_ADR_CXL,
  output     [P_DT_W/8-1:0] MEM_COR_BTEN_CXL,
  output     [P_DT_W-1:0] MEM_COR_DATA_CXL,

  input                   MEM_ATRD_VAL,
  input      [P_AD_W-1:0] MEM_ATRD_ADR,

  // Debug Interface
  output reg              RAM_RD_AXI,
  output                  RAM_RD_ATRD,
  output                  RAM_RD_ATRD_CXL,

  // SRAM Interface
  output                  RAM_WEN,
  output reg [P_AD_W-1:0] RAM_WADR,
  output reg [P_DT_W/8-1:0] RAM_WBTEN,
  output reg [P_DT_W-1:0] RAM_WDATA,

  output                  RAM_REN,
  output reg [P_DT_W/8-1:0] RAM_RBTEN,
  output reg [P_AD_W-1:0] RAM_RADR
);

reg              axi_wen_1p;
reg [P_AD_W-1:0] axi_wadr_1p;
reg [P_DT_W/8-1:0] axi_wbten_1p;
reg [P_DT_W-1:0] axi_wdata_1p;
reg              cor_val_1p;

reg pre_ram_wen;

reg pre_ram_ren;
reg pre_rd_atrd;

// AXI Write Access I/F Signal Retiming
always @ (posedge CLK or negedge RESET_N) begin
  if (!RESET_N) begin
    axi_wen_1p    <= 0;
    axi_wadr_1p   <= 0;
    axi_wbten_1p  <= 0;
    axi_wdata_1p  <= 0;
    cor_val_1p    <= 0;
  end else begin
    axi_wen_1p    <= AXI_WEN;
    axi_wadr_1p   <= AXI_WADR;
    axi_wbten_1p  <= AXI_WBTEN;
    axi_wdata_1p  <= AXI_WDATA;
    cor_val_1p    <= MEM_COR_VAL;
  end
end

// Write Access I/F Select
always @ (posedge CLK or negedge RESET_N) begin
  if (!RESET_N) begin
    pre_ram_wen <= 0;
    RAM_WADR    <= 0;
    RAM_WBTEN   <= 0;
    RAM_WDATA   <= 0;
  end else if (axi_wen_1p) begin
    pre_ram_wen <= 1;
    RAM_WADR    <= axi_wadr_1p;
    RAM_WBTEN   <= axi_wbten_1p;
    RAM_WDATA   <= axi_wdata_1p;
  end else if (MEM_COR_VAL) begin
    pre_ram_wen <= 1;
    RAM_WADR    <= MEM_COR_ADR;
    RAM_WBTEN   <= MEM_COR_BTEN;
    RAM_WDATA   <= MEM_COR_DATA;
  end else begin
    pre_ram_wen <= 0;
    RAM_WADR    <= 0;
    RAM_WBTEN   <= 0;
    RAM_WDATA   <= 0;
  end
end

assign RAM_WEN = pre_ram_wen & ~(cor_val_1p & AXI_REN);
assign MEM_COR_VAL_CXL = pre_ram_wen & cor_val_1p & AXI_REN;
assign MEM_COR_ADR_CXL = (MEM_COR_VAL_CXL) ? RAM_WADR: 0;
assign MEM_COR_BTEN_CXL = (MEM_COR_VAL_CXL) ? RAM_WBTEN: 0;
assign MEM_COR_DATA_CXL = (MEM_COR_VAL_CXL) ? RAM_WDATA: 0;

// Read Access I/F Select
always @ (posedge CLK or negedge RESET_N) begin
  if (!RESET_N) begin
    pre_ram_ren <= 0;
    RAM_RADR    <= 0;
    RAM_RBTEN   <= 0;
    RAM_RD_AXI  <= 0;
    pre_rd_atrd <= 0;
  end else if (AXI_REN) begin
    pre_ram_ren <= 1;
    RAM_RADR    <= AXI_RADR;
    RAM_RBTEN   <= AXI_RBTEN;
    RAM_RD_AXI  <= 1;
    pre_rd_atrd <= 0;
  end else if (MEM_ATRD_VAL) begin
    pre_ram_ren <= 1;
    RAM_RADR    <= MEM_ATRD_ADR;
    RAM_RBTEN   <= {P_DT_W/8{1'b1}};
    RAM_RD_AXI  <= 0;
    pre_rd_atrd <= 1;
  end else begin
    pre_ram_ren <= 0;
    RAM_RADR    <= 0;
    RAM_RBTEN   <= 0;
    RAM_RD_AXI  <= 0;
    pre_rd_atrd <= 0;
  end
end

assign RAM_REN = pre_ram_ren & ~(AXI_WEN | AXI_REN | MEM_COR_VAL_BEF);
assign RAM_RD_ATRD = pre_rd_atrd & ~(AXI_WEN | AXI_REN | MEM_COR_VAL_BEF);
assign RAM_RD_ATRD_CXL = pre_rd_atrd & (AXI_WEN | AXI_REN | MEM_COR_VAL_BEF);

endmodule
