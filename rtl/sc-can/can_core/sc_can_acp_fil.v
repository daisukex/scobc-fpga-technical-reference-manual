//-----------------------------------------------
// Module: sc_can_acp_fil
//  Space Cubics CAN Controller Acceptance Filter
//-----------------------------------------------
// Copyright © 2021 Space Cubics, LLC.
//-----------------------------------------------
module sc_can_acp_fil (
  input CAN_CLK,
  input CAN_RSTB,

  input ID_CHKEN,

  input [10:0] RX_ID1,
  input RX_SRR,
  input RX_IDE,
  input [17:0] RX_ID2,
  input RX_RTR,

  input [3:0] REG_ACF_EN,
  input [31:0] REG_ACF1_ID_MASK,
  input [31:0] REG_ACF1_ID_VAL,
  input [31:0] REG_ACF2_ID_MASK,
  input [31:0] REG_ACF2_ID_VAL,
  input [31:0] REG_ACF3_ID_MASK,
  input [31:0] REG_ACF3_ID_VAL,
  input [31:0] REG_ACF4_ID_MASK,
  input [31:0] REG_ACF4_ID_VAL,

  output reg ID_MATCH
);

wire [31:0] w_acf_mask [0:3];
wire [31:0] w_acf_val [0:3];
reg [3:0] r_acf_match;

assign w_acf_mask[0] = REG_ACF1_ID_MASK;
assign w_acf_mask[1] = REG_ACF2_ID_MASK;
assign w_acf_mask[2] = REG_ACF3_ID_MASK;
assign w_acf_mask[3] = REG_ACF4_ID_MASK;
assign w_acf_val[0] = REG_ACF1_ID_VAL;
assign w_acf_val[1] = REG_ACF2_ID_VAL;
assign w_acf_val[2] = REG_ACF3_ID_VAL;
assign w_acf_val[3] = REG_ACF4_ID_VAL;

genvar gn;
generate
  for(gn=0; gn<4; gn=gn+1) begin : can_acf_gen
    always @ (posedge CAN_CLK or negedge CAN_RSTB) begin
      if (!CAN_RSTB) begin
        r_acf_match[gn] <= 0;
      end else begin
        r_acf_match[gn] <= 0;
        if (ID_CHKEN) begin
          if (~|REG_ACF_EN)
            r_acf_match[gn] <= 1'b1;
          else if (REG_ACF_EN[gn] &
                   ((RX_ID1[10] == w_acf_val[gn][31]) | ~w_acf_mask[gn][31]) &
                   ((RX_ID1[9]  == w_acf_val[gn][30]) | ~w_acf_mask[gn][30]) &
                   ((RX_ID1[8]  == w_acf_val[gn][29]) | ~w_acf_mask[gn][29]) &
                   ((RX_ID1[7]  == w_acf_val[gn][28]) | ~w_acf_mask[gn][28]) &
                   ((RX_ID1[6]  == w_acf_val[gn][27]) | ~w_acf_mask[gn][27]) &
                   ((RX_ID1[5]  == w_acf_val[gn][26]) | ~w_acf_mask[gn][26]) &
                   ((RX_ID1[4]  == w_acf_val[gn][25]) | ~w_acf_mask[gn][25]) &
                   ((RX_ID1[3]  == w_acf_val[gn][24]) | ~w_acf_mask[gn][24]) &
                   ((RX_ID1[2]  == w_acf_val[gn][23]) | ~w_acf_mask[gn][23]) &
                   ((RX_ID1[1]  == w_acf_val[gn][22]) | ~w_acf_mask[gn][22]) &
                   ((RX_ID1[0]  == w_acf_val[gn][21]) | ~w_acf_mask[gn][21]) &
                   ((RX_SRR     == w_acf_val[gn][20]) | ~w_acf_mask[gn][20]) &
                   ((RX_IDE     == w_acf_val[gn][19]) | ~w_acf_mask[gn][19]) &
                   ((RX_ID2[17] == w_acf_val[gn][18]) | ~w_acf_mask[gn][18] | ~RX_IDE) &
                   ((RX_ID2[16] == w_acf_val[gn][17]) | ~w_acf_mask[gn][17] | ~RX_IDE) &
                   ((RX_ID2[15] == w_acf_val[gn][16]) | ~w_acf_mask[gn][16] | ~RX_IDE) &
                   ((RX_ID2[14] == w_acf_val[gn][15]) | ~w_acf_mask[gn][15] | ~RX_IDE) &
                   ((RX_ID2[13] == w_acf_val[gn][14]) | ~w_acf_mask[gn][14] | ~RX_IDE) &
                   ((RX_ID2[12] == w_acf_val[gn][13]) | ~w_acf_mask[gn][13] | ~RX_IDE) &
                   ((RX_ID2[11] == w_acf_val[gn][12]) | ~w_acf_mask[gn][12] | ~RX_IDE) &
                   ((RX_ID2[10] == w_acf_val[gn][11]) | ~w_acf_mask[gn][11] | ~RX_IDE) &
                   ((RX_ID2[9]  == w_acf_val[gn][10]) | ~w_acf_mask[gn][10] | ~RX_IDE) &
                   ((RX_ID2[8]  == w_acf_val[gn][9])  | ~w_acf_mask[gn][9]  | ~RX_IDE) &
                   ((RX_ID2[7]  == w_acf_val[gn][8])  | ~w_acf_mask[gn][8]  | ~RX_IDE) &
                   ((RX_ID2[6]  == w_acf_val[gn][7])  | ~w_acf_mask[gn][7]  | ~RX_IDE) &
                   ((RX_ID2[5]  == w_acf_val[gn][6])  | ~w_acf_mask[gn][6]  | ~RX_IDE) &
                   ((RX_ID2[4]  == w_acf_val[gn][5])  | ~w_acf_mask[gn][5]  | ~RX_IDE) &
                   ((RX_ID2[3]  == w_acf_val[gn][4])  | ~w_acf_mask[gn][4]  | ~RX_IDE) &
                   ((RX_ID2[2]  == w_acf_val[gn][3])  | ~w_acf_mask[gn][3]  | ~RX_IDE) &
                   ((RX_ID2[1]  == w_acf_val[gn][2])  | ~w_acf_mask[gn][2]  | ~RX_IDE) &
                   ((RX_ID2[0]  == w_acf_val[gn][1])  | ~w_acf_mask[gn][1]  | ~RX_IDE) &
                   ((RX_RTR     == w_acf_val[gn][0])  | ~w_acf_mask[gn][0]  | ~RX_IDE) )
            r_acf_match[gn] <= 1'b1;
        end
      end
    end
  end
endgenerate

always @ (posedge CAN_CLK or negedge CAN_RSTB) begin
  if (!CAN_RSTB) begin
    ID_MATCH <= 0;
  end else begin
    ID_MATCH <= |r_acf_match;
  end
end

endmodule
