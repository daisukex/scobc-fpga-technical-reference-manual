//-----------------------------------------------
// Module: sc_hrmem_sram_acc_ctrl_w32
//  Space Cubics StaticRAM Access Controller (32bit)
//-----------------------------------------------
// Copyright © 2022 Space Cubics, LLC.
//-----------------------------------------------
module sc_hrmem_sram_acc_ctrl_w32 # (
  parameter P_RD_LTCY = 2
) (
  // System Interface
  input CLK,
  input RESET_N,

  // RAM Access Control Interface
  input INIT_EN,
  input [19:0] INIT_ADR,

  input WEN,
  input [19:0] WADR,
  input [3:0] WBTEN,
  input [31:0] WDATA,

  input REN,
  input [19:0] RADR,
  input [3:0] RBTEN,
  output reg [31:0] RDATA,

  output reg ECC1ERR,
  output reg [19:0] ECCERR_ADR,
  output reg [3:0] ECCERR_BTEN,

  // SRAM Interface
  output reg [19:0] SR_A,

  output reg SR1_CEB,
  output reg SR1_OEB,
  output reg SR1_WEB,
  output reg SR1_BHEB,
  output reg SR1_BLEB,
  inout  [15:0] SR1_IO,
  input  SR1_ERR,

  output reg SR2_CEB,
  output reg SR2_OEB,
  output reg SR2_WEB,
  output reg SR2_BHEB,
  output reg SR2_BLEB,
  inout  [15:0] SR2_IO,
  input  SR2_ERR
);

wire w_wen_sel;
wire [19:0] w_wadr_sel;
wire [3:0] w_wbten_sel;
wire [31:0] w_wdata_sel;

reg r_wen_sel_p1;
reg [19:0] r_wadr_sel_p1;
reg [3:0] r_wbten_sel_p1;
reg [31:0] r_wdata_sel_p1;

reg [P_RD_LTCY-2:0] r_ren_p;
reg [19:0] r_radr_p [0:P_RD_LTCY-2];
reg [3:0] r_rbten_p [0:P_RD_LTCY-2];

wire w_ren_sel;
wire [19:0] w_radr_sel;
wire [3:0] w_rbten_sel;

reg [15:0] r_sr1_dout;
reg [15:0] r_sr2_dout;
wire [15:0] w_sr1_din;
wire [15:0] w_sr2_din;

integer i;

assign w_wen_sel   = INIT_EN | WEN;
assign w_wadr_sel  = (INIT_EN) ? INIT_ADR : WADR;
assign w_wbten_sel = (INIT_EN) ? {4{1'b1}} : WBTEN;
assign w_wdata_sel = (INIT_EN) ? {32{1'b0}} : WDATA;

always@ (posedge CLK) begin
  r_wen_sel_p1   <= w_wen_sel;
  r_wadr_sel_p1  <= w_wadr_sel;
  r_wbten_sel_p1 <= w_wbten_sel;
  r_wdata_sel_p1 <= w_wdata_sel;
end

always@ (posedge CLK or negedge RESET_N) begin
  if (!RESET_N) begin
    for (i=0; i<P_RD_LTCY-1; i=i+1) begin
      r_ren_p[i]   <= 0;
      r_radr_p[i]  <= 0;
      r_rbten_p[i] <= 0;
    end
  end
  else begin
    r_ren_p[0]   <= REN;
    r_radr_p[0]  <= RADR;
    r_rbten_p[0] <= RBTEN;
    if (P_RD_LTCY > 2) begin
      for (i=1; i<P_RD_LTCY-1; i=i+1) begin
        r_ren_p[i]   <= r_ren_p[i-1];
        r_radr_p[i]  <= r_radr_p[i-1];
        r_rbten_p[i] <= r_rbten_p[i-1];
      end
    end
  end
end

assign w_ren_sel   = REN | r_ren_p[0];
assign w_radr_sel  = (REN) ? RADR: r_radr_p[0];
assign w_rbten_sel = (REN) ? RBTEN: r_rbten_p[0];

always@ (posedge CLK) begin
  if (w_wen_sel) begin
    SR_A    <= w_wadr_sel;
    SR1_OEB <= 1'b1;
    SR2_OEB <= 1'b1;
    if (|w_wbten_sel[1:0]) begin
      SR1_CEB    <= 0;
      SR1_WEB    <= 0;
      SR1_BHEB   <= ~w_wbten_sel[1];
      SR1_BLEB   <= ~w_wbten_sel[0];
      r_sr1_dout <= w_wdata_sel[15:0];
    end
    else begin
      SR1_CEB    <= 1'b1;
      SR1_WEB    <= 1'b1;
      SR1_BHEB   <= 1'b1;
      SR1_BLEB   <= 1'b1;
      r_sr1_dout <= 0;
    end
    if (|w_wbten_sel[3:2]) begin
      SR2_CEB    <= 0;
      SR2_WEB    <= 0;
      SR2_BHEB   <= ~w_wbten_sel[3];
      SR2_BLEB   <= ~w_wbten_sel[2];
      r_sr2_dout <= w_wdata_sel[31:16];
    end
    else begin
      SR2_CEB    <= 1'b1;
      SR2_WEB    <= 1'b1;
      SR2_BHEB   <= 1'b1;
      SR2_BLEB   <= 1'b1;
      r_sr2_dout <= 0;
    end
  end
  else if (r_wen_sel_p1) begin
    SR_A     <= r_wadr_sel_p1;
    SR1_CEB  <= 1'b1;
    SR1_OEB  <= 1'b1;
    SR1_WEB  <= 1'b1;
    SR1_BHEB <= 1'b1;
    SR1_BLEB <= 1'b1;
    SR2_CEB  <= 1'b1;
    SR2_OEB  <= 1'b1;
    SR2_WEB  <= 1'b1;
    SR2_BHEB <= 1'b1;
    SR2_BLEB <= 1'b1;
    if (|r_wbten_sel_p1[1:0])
      r_sr1_dout <= r_wdata_sel_p1[15:0];
    else
      r_sr1_dout <= 0;
    if (|r_wbten_sel_p1[3:2])
      r_sr2_dout <= r_wdata_sel_p1[31:16];
    else
      r_sr2_dout <= 0;
  end
  else if (w_ren_sel) begin
    SR_A       <= w_radr_sel;
    SR1_WEB    <= 1'b1;
    SR2_WEB    <= 1'b1;
    r_sr1_dout <= 0;
    r_sr2_dout <= 0;
    if (|w_rbten_sel[1:0]) begin
      SR1_CEB  <= 0;
      SR1_OEB  <= 0;
      SR1_BHEB <= ~w_rbten_sel[1];
      SR1_BLEB <= ~w_rbten_sel[0];
    end
    else begin
      SR1_CEB  <= 1'b1;
      SR1_OEB  <= 1'b1;
      SR1_BHEB <= 1'b1;
      SR1_BLEB <= 1'b1;
    end
    if (|w_rbten_sel[3:2]) begin
      SR2_CEB  <= 0;
      SR2_OEB  <= 0;
      SR2_BHEB <= ~w_rbten_sel[3];
      SR2_BLEB <= ~w_rbten_sel[2];
    end
    else begin
      SR2_CEB  <= 1'b1;
      SR2_OEB  <= 1'b1;
      SR2_BHEB <= 1'b1;
      SR2_BLEB <= 1'b1;
    end
  end
  else begin
    SR_A       <= 0;
    SR1_CEB    <= 1'b1;
    SR1_OEB    <= 1'b1;
    SR1_WEB    <= 1'b1;
    SR1_BHEB   <= 1'b1;
    SR1_BLEB   <= 1'b1;
    r_sr1_dout <= 0;
    SR2_CEB    <= 1'b1;
    SR2_OEB    <= 1'b1;
    SR2_WEB    <= 1'b1;
    SR2_BHEB   <= 1'b1;
    SR2_BLEB   <= 1'b1;
    r_sr2_dout <= 0;
  end
end

always@ (posedge CLK or negedge RESET_N) begin
  if (!RESET_N) begin
    RDATA       <= 0;
    ECC1ERR     <= 0;
    ECCERR_ADR  <= 0;
    ECCERR_BTEN <= 0;
  end
  else if (r_ren_p[P_RD_LTCY-2]) begin
    RDATA       <= 0;
    ECC1ERR     <= 0;
    ECCERR_ADR  <= 0;
    ECCERR_BTEN <= 0;
    if (r_rbten_p[P_RD_LTCY-2][3])
      RDATA[31:24] <= w_sr2_din[15:8];
    if (r_rbten_p[P_RD_LTCY-2][2])
      RDATA[23:16] <= w_sr2_din[7:0];
    if (r_rbten_p[P_RD_LTCY-2][1])
      RDATA[15:8]  <= w_sr1_din[15:8];
    if (r_rbten_p[P_RD_LTCY-2][0])
      RDATA[7:0]   <= w_sr1_din[7:0];
    if ((|r_rbten_p[P_RD_LTCY-2][1:0] & SR1_ERR) | (|r_rbten_p[P_RD_LTCY-2][3:2] & SR2_ERR)) begin
      ECC1ERR     <= 1'b1;
      ECCERR_ADR  <= r_radr_p[P_RD_LTCY-2];
      ECCERR_BTEN <= r_rbten_p[P_RD_LTCY-2];
    end
  end
  else begin
    RDATA       <= 0;
    ECC1ERR     <= 0;
    ECCERR_ADR  <= 0;
    ECCERR_BTEN <= 0;
  end
end

assign SR1_IO = (SR1_OEB) ? r_sr1_dout : {16{1'bz}};
assign w_sr1_din = SR1_IO;
assign SR2_IO = (SR2_OEB) ? r_sr2_dout : {16{1'bz}};
assign w_sr2_din = SR2_IO;

endmodule
