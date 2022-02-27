//-----------------------------------------------
// Module: sc_can_err_cntr
//  Space Cubics CAN Controller Error Counter
//-----------------------------------------------
// Copyright © 2021 Space Cubics, LLC.
//-----------------------------------------------
module sc_can_err_cntr (
  input CAN_CLK,
  input CAN_RSTB,

  input CNTR_RST,

  input RX_CPLS1_U1,
  input RX_CPLS2_U8,
  input RX_CPLS3_U8,
  input RX_CPLS4_U8,
  input RX_COMP_PLS,

  input TX_CPLS1_U8,
  input TX_CPLS2_U8,
  input TX_CPLS3_U8,
  input TX_COMP_PLS,

  output reg [7:0] REG_TX_ECNT,
  output reg [7:0] REG_RX_ECNT,

  output reg BUS_OFF_REQ
);

reg [1:0] r_rx_cpls1_ritim;
reg [1:0] r_rx_cpls2_ritim;
reg [1:0] r_rx_cpls3_ritim;
reg [1:0] r_rx_cpls4_ritim;
reg [1:0] r_rx_cmpls_ritim;
reg [1:0] r_tx_cpls1_ritim;
reg [1:0] r_tx_cpls2_ritim;
reg [1:0] r_tx_cpls3_ritim;
reg [1:0] r_tx_cmpls_ritim;

wire [3:0] w_cpls_val [0:6];
reg [4:0] r_cnt_cal [0:2];
reg [5:0] r_rx_cnt_up_val;
reg [5:0] r_tx_cnt_up_val;
wire w_rx_cnt_up_pls;
wire w_tx_cnt_up_pls;
wire [8:0] w_rx_ecnt_carry;
wire [8:0] w_tx_ecnt_carry;

always @ (posedge CAN_CLK or negedge CAN_RSTB) begin
  if (!CAN_RSTB) begin
    r_rx_cpls1_ritim <= 0;
    r_rx_cpls2_ritim <= 0;
    r_rx_cpls3_ritim <= 0;
    r_rx_cpls4_ritim <= 0;
    r_rx_cmpls_ritim <= 0;
    r_tx_cpls1_ritim <= 0;
    r_tx_cpls2_ritim <= 0;
    r_tx_cpls3_ritim <= 0;
    r_tx_cmpls_ritim <= 0;
  end else begin
    r_rx_cpls1_ritim <= {r_rx_cpls1_ritim[0], RX_CPLS1_U1};
    r_rx_cpls2_ritim <= {r_rx_cpls2_ritim[0], RX_CPLS2_U8};
    r_rx_cpls3_ritim <= {r_rx_cpls3_ritim[0], RX_CPLS3_U8};
    r_rx_cpls4_ritim <= {r_rx_cpls4_ritim[0], RX_CPLS4_U8};
    r_rx_cmpls_ritim <= {r_rx_cmpls_ritim[0], RX_COMP_PLS};
    r_tx_cpls1_ritim <= {r_tx_cpls1_ritim[0], TX_CPLS1_U8};
    r_tx_cpls2_ritim <= {r_tx_cpls2_ritim[0], TX_CPLS2_U8};
    r_tx_cpls3_ritim <= {r_tx_cpls3_ritim[0], TX_CPLS3_U8};
    r_tx_cmpls_ritim <= {r_tx_cmpls_ritim[0], TX_COMP_PLS};
  end
end


assign w_cpls_val[0] = (RX_CPLS1_U1) ? 4'd1: 0;
assign w_cpls_val[1] = (RX_CPLS2_U8) ? 4'd8: 0;
assign w_cpls_val[2] = (RX_CPLS3_U8) ? 4'd8: 0;
assign w_cpls_val[3] = (RX_CPLS4_U8) ? 4'd8: 0;

assign w_cpls_val[4] = (TX_CPLS1_U8) ? 4'd8: 0;
assign w_cpls_val[5] = (TX_CPLS2_U8) ? 4'd8: 0;
assign w_cpls_val[6] = (r_tx_cpls3_ritim[0]) ? 4'd8: 0;

genvar gn;
generate
  for(gn=0; gn<3; gn=gn+1) begin : can_cntup_gen
    always @ (posedge CAN_CLK or negedge CAN_RSTB) begin
      if (!CAN_RSTB) begin
        r_cnt_cal[gn] <= 0;
      end else if (CNTR_RST) begin
        r_cnt_cal[gn] <= 0;
      end else begin
        r_cnt_cal[gn] <= {1'b0, w_cpls_val[2*gn]} +
                         {1'b0, w_cpls_val[2*gn+1]};
      end
    end
  end
endgenerate

always @ (posedge CAN_CLK or negedge CAN_RSTB) begin
  if (!CAN_RSTB) begin
    r_rx_cnt_up_val <= 0;
    r_tx_cnt_up_val <= 0;
  end else if (CNTR_RST) begin
    r_rx_cnt_up_val <= 0;
    r_tx_cnt_up_val <= 0;
  end else begin
    r_rx_cnt_up_val <= {1'b0, r_cnt_cal[0]} + {1'b0, r_cnt_cal[1]};
    r_tx_cnt_up_val <= {1'b0, r_cnt_cal[2]} + {2'b00, w_cpls_val[6]};
  end
end

assign w_rx_cnt_up_pls = r_rx_cpls1_ritim[1] | r_rx_cpls2_ritim[1] |
                         r_rx_cpls3_ritim[1] | r_rx_cpls4_ritim[1] ;
assign w_tx_cnt_up_pls = r_tx_cpls1_ritim[1] | r_tx_cpls2_ritim[1] |
                         r_tx_cpls3_ritim[1] ;

assign w_rx_ecnt_carry = {1'b0, REG_RX_ECNT} + {3'h0, r_rx_cnt_up_val};
assign w_tx_ecnt_carry = {1'b0, REG_TX_ECNT} + {3'h0, r_tx_cnt_up_val};

always @ (posedge CAN_CLK or negedge CAN_RSTB) begin
  if (!CAN_RSTB) begin
    REG_RX_ECNT <= 0;
    REG_TX_ECNT <= 0;
    BUS_OFF_REQ <= 0;
  end else if (CNTR_RST) begin
    REG_RX_ECNT <= 0;
    REG_TX_ECNT <= 0;
    BUS_OFF_REQ <= 0;
  end else begin
    BUS_OFF_REQ <= 0;
    if (r_rx_cmpls_ritim[1] & |REG_RX_ECNT) begin
      if (REG_RX_ECNT >= 8'd128)
        REG_RX_ECNT <= 8'd119;
      else
        REG_RX_ECNT <= REG_RX_ECNT - 1;
    end else if (w_rx_cnt_up_pls) begin
      if (w_rx_ecnt_carry[8])
        REG_RX_ECNT <= {8{1'b1}};
      else
        REG_RX_ECNT <= REG_RX_ECNT + {2'h0, r_rx_cnt_up_val};
    end
    if (r_tx_cmpls_ritim[1] & |REG_TX_ECNT) begin
      REG_TX_ECNT <= REG_TX_ECNT - 1;
    end else if (w_tx_cnt_up_pls) begin
      if (w_tx_ecnt_carry[8]) begin
        REG_TX_ECNT <= {8{1'b1}};
        BUS_OFF_REQ <= 1'b1;
      end else begin
        REG_TX_ECNT <= REG_TX_ECNT + {2'h0, r_tx_cnt_up_val};
      end
    end
  end
end

endmodule
