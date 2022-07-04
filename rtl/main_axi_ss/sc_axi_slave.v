//-----------------------------------------------
// Module: sc_axi_slave
//  Space Cubics AXI SLAVE Module
//-----------------------------------------------
// Copyright © 2020 Space Cubics, LLC.
//-----------------------------------------------
module sc_axi_slave # (
  parameter P_AD_W = 32,
  parameter P_DT_W = 32,
  parameter P_ID_W = 8
) (
  // AXI Interface
  input S_AXI_ACLK,
  input S_AXI_ARESETN,
  input [P_ID_W-1:0] S_AXI_AWID,
  input [P_AD_W-1:0] S_AXI_AWADDR,
  input [7:0] S_AXI_AWLEN,
  input [2:0] S_AXI_AWSIZE,
  input [1:0] S_AXI_AWBURST,
  input S_AXI_AWLOCK,
  input [3:0] S_AXI_AWCACHE,
  input [2:0] S_AXI_AWPROT,
  input S_AXI_AWVALID,
  output reg S_AXI_AWREADY,
  input [P_DT_W-1:0] S_AXI_WDATA,
  input [P_DT_W/8-1:0] S_AXI_WSTRB,
  input S_AXI_WLAST,
  input S_AXI_WVALID,
  output reg S_AXI_WREADY,
  output reg [P_ID_W-1:0] S_AXI_BID,
  output reg [1:0] S_AXI_BRESP,
  output reg S_AXI_BVALID,
  input S_AXI_BREADY,
  input [P_ID_W-1:0] S_AXI_ARID,
  input [P_AD_W-1:0] S_AXI_ARADDR,
  input [7:0] S_AXI_ARLEN,
  input [2:0] S_AXI_ARSIZE,
  input [1:0] S_AXI_ARBURST,
  input S_AXI_ARLOCK,
  input [3:0] S_AXI_ARCACHE,
  input [2:0] S_AXI_ARPROT,
  input S_AXI_ARVALID,
  output reg S_AXI_ARREADY,
  output reg [P_ID_W-1:0] S_AXI_RID,
  output reg [P_DT_W-1:0] S_AXI_RDATA,
  output reg [1:0] S_AXI_RRESP,
  output reg S_AXI_RLAST,
  output reg S_AXI_RVALID,
  input S_AXI_RREADY,

  // Register Interface
  output reg REG_WEN,
  output reg [P_AD_W-1:0] REG_WADDR,
  output reg [P_DT_W/8-1:0] REG_WBTEN,
  output reg [P_DT_W-1:0] REG_WDATA,
  output reg REG_REN,
  output reg [P_AD_W-1:0] REG_RADDR,
  input [P_DT_W-1:0] REG_RDATA,
  input REG_WACCERR,
  input REG_RACCERR,
  input REG_RWAIT
);

parameter [2:0] p_bank_width = (P_DT_W == (2 << 4)) ? 3'h2 :
                               (P_DT_W == (2 << 5)) ? 3'h3 :
                               (P_DT_W == (2 << 6)) ? 3'h4 :
                               (P_DT_W == (2 << 7)) ? 3'h5 :
                               (P_DT_W == (2 << 8)) ? 3'h6 :
                               (P_DT_W == (2 << 9)) ? 3'h7 :
                                                      3'h1 ;

reg [2:0] r_rstn_retim;
reg r_rstn_pedge;

wire w_axi_awen;
wire w_axi_wen;
wire w_axi_ben;

reg [1:0] r_wch_status;

reg r_aw_lat_wflg;
reg [P_ID_W-1:0] r_awid_lat [0:1];
reg [P_AD_W-1:0] r_awaddr_lat [0:1];
reg [7:0] r_awlen_lat [0:1];
reg [2:0] r_awsize_lat [0:1];
reg [1:0] r_awburst_lat [0:1];

reg r_aw_lat_full;
reg [P_DT_W-1:0] r_wdata_lat;
reg [P_DT_W/8-1:0] r_wstrb_lat;

reg r_aw_lat_rflg;
reg r_wstate;
reg [P_ID_W-1:0] r_wid;
reg [1:0] r_wburst;
reg [7:0] r_wlen;

wire w_axi_aren;
wire w_axi_ren;

reg [P_ID_W-1:0] r_arid_lat;
reg [P_DT_W/8-1:0] r_reg_rbten;

reg r_rstate;
reg [1:0] r_rburst;
reg [7:0] r_rlen;
reg [7:0] r_rlen_cnt;

reg r_wait_flg;
reg [3:0] r_wait_cnt;
reg [3:0] r_read_extend_cnt;

integer i;

// Reset release Timing
always @ (posedge S_AXI_ACLK or negedge S_AXI_ARESETN) begin
  if (!S_AXI_ARESETN) begin
    r_rstn_retim <= 0;
    r_rstn_pedge <= 0;
  end else begin
    r_rstn_retim <= {r_rstn_retim[1:0], 1'b1};
    r_rstn_pedge <= r_rstn_retim[1] & ~r_rstn_retim[2];
  end
end

// Write Chanel
assign w_axi_awen = S_AXI_AWVALID & S_AXI_AWREADY;
assign w_axi_wen  = S_AXI_WVALID  & S_AXI_WREADY;
assign w_axi_ben  = S_AXI_BVALID  & S_AXI_BREADY;

always @ (posedge S_AXI_ACLK or negedge S_AXI_ARESETN) begin
  if (!S_AXI_ARESETN) begin
    r_wch_status <= 2'b01;
  end else if (w_axi_awen & (w_axi_wen & S_AXI_WLAST)) begin
    r_wch_status <= r_wch_status;
  end else if (w_axi_awen) begin
    r_wch_status <= r_wch_status + 2'b01;
  end else if (w_axi_wen & S_AXI_WLAST) begin
    r_wch_status <= r_wch_status - 2'b01;
  end
end

always @ (posedge S_AXI_ACLK or negedge S_AXI_ARESETN) begin
  if (!S_AXI_ARESETN) begin
    S_AXI_AWREADY <= 0;
  end else if (r_rstn_pedge) begin
    S_AXI_AWREADY <= 1;
  end else if (w_axi_wen & S_AXI_WLAST) begin
    S_AXI_AWREADY <= 1;
  end else if (r_wch_status >= 2'b10 & w_axi_awen) begin
    S_AXI_AWREADY <= 0;
  end
end

always @ (posedge S_AXI_ACLK or negedge S_AXI_ARESETN) begin
  if (!S_AXI_ARESETN) begin
    S_AXI_WREADY <= 0;
  end else if (r_rstn_pedge) begin
    S_AXI_WREADY <= 1;
  end else if (w_axi_awen) begin
    S_AXI_WREADY <= 1;
  end else if (r_wch_status <= 2'b01 & w_axi_wen) begin
    S_AXI_WREADY <= 0;
  end
end

always @ (posedge S_AXI_ACLK or negedge S_AXI_ARESETN) begin
  if (!S_AXI_ARESETN) begin
    S_AXI_BVALID <= 0;
    S_AXI_BRESP  <= 0;
    S_AXI_BID    <= 0;
  end else if (((w_axi_awen | r_wch_status >= 2'b10) & (w_axi_wen & S_AXI_WLAST)) |
                (w_axi_awen & r_wch_status == 2'b00)) begin
    S_AXI_BVALID <= 1;
    S_AXI_BRESP  <= {REG_WACCERR, 1'b0};
    if (r_wch_status >= 2'b10) begin
      if (r_wstate)
        S_AXI_BID <= r_wid;
      else
        S_AXI_BID <= r_awid_lat[r_aw_lat_rflg];
    end else begin
      S_AXI_BID <= S_AXI_AWID;
    end
  end else if (S_AXI_BREADY) begin
    S_AXI_BVALID <= 0;
    S_AXI_BRESP  <= 0;
    S_AXI_BID    <= 0;
  end
end

always @ (posedge S_AXI_ACLK or negedge S_AXI_ARESETN) begin
  if (!S_AXI_ARESETN) begin
    r_aw_lat_wflg    <= 0;
    r_awid_lat[0]    <= 0;
    r_awid_lat[1]    <= 0;
    r_awaddr_lat[0]  <= 0;
    r_awaddr_lat[1]  <= 0;
    r_awlen_lat[0]   <= 0;
    r_awlen_lat[1]   <= 0;
    r_awsize_lat[0]  <= 0;
    r_awsize_lat[1]  <= 0;
    r_awburst_lat[0] <= 0;
    r_awburst_lat[1] <= 0;
  end else if (w_axi_awen & (r_wch_status >= 2'b10 |
                            (r_wch_status == 2'b01 & ~S_AXI_WVALID))) begin
    r_aw_lat_wflg                <= ~r_aw_lat_wflg;
    r_awid_lat[r_aw_lat_wflg]    <= S_AXI_AWID;
    r_awaddr_lat[r_aw_lat_wflg]  <= S_AXI_AWADDR;
    r_awlen_lat[r_aw_lat_wflg]   <= S_AXI_AWLEN;
    r_awsize_lat[r_aw_lat_wflg]  <= S_AXI_AWSIZE;
    r_awburst_lat[r_aw_lat_wflg] <= S_AXI_AWBURST;
  end
end

always @ (posedge S_AXI_ACLK or negedge S_AXI_ARESETN) begin
  if (!S_AXI_ARESETN) begin
    r_aw_lat_full <= 0;
  end else if (r_aw_lat_wflg != r_aw_lat_rflg & w_axi_awen & ~S_AXI_WVALID) begin
    r_aw_lat_full <= 1;
  end else if (S_AXI_WVALID & ~w_axi_awen) begin
    r_aw_lat_full <= 0;
  end
end

always @ (posedge S_AXI_ACLK or negedge S_AXI_ARESETN) begin
  if (!S_AXI_ARESETN) begin
    r_wdata_lat <= 0;
    r_wstrb_lat <= 0;
  end else if (w_axi_wen) begin
    r_wdata_lat <= S_AXI_WDATA;
    r_wstrb_lat <= S_AXI_WSTRB;
  end
end

always @ (posedge S_AXI_ACLK or negedge S_AXI_ARESETN) begin
  if (!S_AXI_ARESETN) begin
    r_aw_lat_rflg <= 0;
    r_wstate      <= 0;
    r_wid         <= 0;
    r_wburst      <= 0;
    r_wlen        <= 0;
    REG_WEN       <= 0;
    REG_WADDR     <= 0;
    REG_WBTEN     <= 0;
    REG_WDATA     <= 0;
  end else if (~r_wstate) begin
    if (w_axi_wen) begin
      if (r_aw_lat_wflg != r_aw_lat_rflg | r_aw_lat_full) begin
        r_aw_lat_rflg <= ~r_aw_lat_rflg;
        r_wstate      <= 1;
        r_wid         <= r_awid_lat[r_aw_lat_rflg];
        r_wburst      <= r_awburst_lat[r_aw_lat_rflg];
        r_wlen        <= r_awlen_lat[r_aw_lat_rflg];
        REG_WEN       <= 1;
        REG_WADDR     <= r_awaddr_lat[r_aw_lat_rflg];
        if ((1 << r_awsize_lat[r_aw_lat_rflg]) > (P_DT_W/8)) begin
          REG_WBTEN     <= {(P_DT_W/8){1'b1}};
        end else begin
          case (r_awsize_lat[r_aw_lat_rflg])
            0:       REG_WBTEN <= (  {1{1'b1}} << r_awaddr_lat[r_aw_lat_rflg][p_bank_width-1:0]) & S_AXI_WSTRB;
            1:       REG_WBTEN <= (  {2{1'b1}} << r_awaddr_lat[r_aw_lat_rflg][p_bank_width-1:0]) & S_AXI_WSTRB;
            2:       REG_WBTEN <= (  {4{1'b1}} << r_awaddr_lat[r_aw_lat_rflg][p_bank_width-1:0]) & S_AXI_WSTRB;
            3:       REG_WBTEN <= (  {8{1'b1}} << r_awaddr_lat[r_aw_lat_rflg][p_bank_width-1:0]) & S_AXI_WSTRB;
            4:       REG_WBTEN <= ( {16{1'b1}} << r_awaddr_lat[r_aw_lat_rflg][p_bank_width-1:0]) & S_AXI_WSTRB;
            5:       REG_WBTEN <= ( {32{1'b1}} << r_awaddr_lat[r_aw_lat_rflg][p_bank_width-1:0]) & S_AXI_WSTRB;
            6:       REG_WBTEN <= ( {64{1'b1}} << r_awaddr_lat[r_aw_lat_rflg][p_bank_width-1:0]) & S_AXI_WSTRB;
            default: REG_WBTEN <= ({128{1'b1}} << r_awaddr_lat[r_aw_lat_rflg][p_bank_width-1:0]) & S_AXI_WSTRB;
          endcase
        end
        REG_WDATA     <= S_AXI_WDATA;
      end else if (w_axi_awen) begin
        r_wstate      <= 1;
        r_wid         <= S_AXI_AWID;
        r_wburst      <= S_AXI_AWBURST;
        r_wlen        <= S_AXI_AWLEN;
        REG_WEN       <= 1;
        REG_WADDR     <= S_AXI_AWADDR;
        if ((1 << S_AXI_AWSIZE) > (P_DT_W/8)) begin
          REG_WBTEN     <= {(P_DT_W/8){1'b1}};
        end else begin
          case (S_AXI_AWSIZE)
            0:       REG_WBTEN <= (  {1{1'b1}} << S_AXI_AWADDR[p_bank_width-1:0]) & S_AXI_WSTRB;
            1:       REG_WBTEN <= (  {2{1'b1}} << S_AXI_AWADDR[p_bank_width-1:0]) & S_AXI_WSTRB;
            2:       REG_WBTEN <= (  {4{1'b1}} << S_AXI_AWADDR[p_bank_width-1:0]) & S_AXI_WSTRB;
            3:       REG_WBTEN <= (  {8{1'b1}} << S_AXI_AWADDR[p_bank_width-1:0]) & S_AXI_WSTRB;
            4:       REG_WBTEN <= ( {16{1'b1}} << S_AXI_AWADDR[p_bank_width-1:0]) & S_AXI_WSTRB;
            5:       REG_WBTEN <= ( {32{1'b1}} << S_AXI_AWADDR[p_bank_width-1:0]) & S_AXI_WSTRB;
            6:       REG_WBTEN <= ( {64{1'b1}} << S_AXI_AWADDR[p_bank_width-1:0]) & S_AXI_WSTRB;
            default: REG_WBTEN <= ({128{1'b1}} << S_AXI_AWADDR[p_bank_width-1:0]) & S_AXI_WSTRB;
          endcase
        end
        REG_WDATA     <= S_AXI_WDATA;
      end
    end else if (w_axi_awen & ~S_AXI_WREADY) begin
      r_wstate      <= 1;
      r_wid         <= S_AXI_AWID;
      r_wburst      <= S_AXI_AWBURST;
      r_wlen        <= S_AXI_AWLEN;
      REG_WEN       <= 1;
      REG_WADDR     <= S_AXI_AWADDR;
      if ((1 << S_AXI_AWSIZE) > (P_DT_W/8)) begin
        REG_WBTEN     <= {(P_DT_W/8){1'b1}};
      end else begin
        case (S_AXI_AWSIZE)
          0:       REG_WBTEN <= (  {1{1'b1}} << S_AXI_AWADDR[p_bank_width-1:0]) & r_wstrb_lat;
          1:       REG_WBTEN <= (  {2{1'b1}} << S_AXI_AWADDR[p_bank_width-1:0]) & r_wstrb_lat;
          2:       REG_WBTEN <= (  {4{1'b1}} << S_AXI_AWADDR[p_bank_width-1:0]) & r_wstrb_lat;
          3:       REG_WBTEN <= (  {8{1'b1}} << S_AXI_AWADDR[p_bank_width-1:0]) & r_wstrb_lat;
          4:       REG_WBTEN <= ( {16{1'b1}} << S_AXI_AWADDR[p_bank_width-1:0]) & r_wstrb_lat;
          5:       REG_WBTEN <= ( {32{1'b1}} << S_AXI_AWADDR[p_bank_width-1:0]) & r_wstrb_lat;
          6:       REG_WBTEN <= ( {64{1'b1}} << S_AXI_AWADDR[p_bank_width-1:0]) & r_wstrb_lat;
          default: REG_WBTEN <= ({128{1'b1}} << S_AXI_AWADDR[p_bank_width-1:0]) & r_wstrb_lat;
        endcase
      end
      REG_WDATA     <= r_wdata_lat;
    end
  end else if (w_axi_ben) begin
    r_wstate      <= 0;
    r_wid         <= 0;
    r_wburst      <= 0;
    r_wlen        <= 0;
    REG_WEN       <= 0;
    REG_WADDR     <= 0;
    REG_WBTEN     <= 0;
    REG_WDATA     <= 0;
  end else if (w_axi_wen) begin
    REG_WEN <= 1;
    if (r_wburst == 2'b10) begin
      if (r_wlen == 8'h01 & REG_WADDR[p_bank_width])
        REG_WADDR <= {REG_WADDR[P_AD_W-1:p_bank_width+1], {p_bank_width+1{1'b0}}};
      else if (r_wlen == 8'h03 & (&REG_WADDR[p_bank_width +: 2]))
        REG_WADDR <= {REG_WADDR[P_AD_W-1:p_bank_width+2], {p_bank_width+2{1'b0}}};
      else if (r_wlen == 8'h07 & (&REG_WADDR[p_bank_width +: 3]))
        REG_WADDR <= {REG_WADDR[P_AD_W-1:p_bank_width+3], {p_bank_width+3{1'b0}}};
      else if (r_wlen == 8'h0F & (&REG_WADDR[p_bank_width +: 4]))
        REG_WADDR <= {REG_WADDR[P_AD_W-1:p_bank_width+4], {p_bank_width+4{1'b0}}};
      else
        REG_WADDR <= REG_WADDR + (1 << p_bank_width);
    end else if (r_wburst == 2'b01) begin
      REG_WADDR <= REG_WADDR + (1 << p_bank_width);
    end
    REG_WDATA <= S_AXI_WDATA;
  end else begin
    REG_WEN       <= 0;
    REG_WADDR     <= 0;
    REG_WBTEN     <= 0;
    REG_WDATA     <= 0;
  end
end

// Read Chanel
assign w_axi_aren = S_AXI_ARVALID & S_AXI_ARREADY;
assign w_axi_ren  = S_AXI_RVALID  & S_AXI_RREADY;

always @ (posedge S_AXI_ACLK or negedge S_AXI_ARESETN) begin
  if (!S_AXI_ARESETN) begin
    S_AXI_ARREADY <= 0;
  end else if (r_rstn_pedge) begin
    S_AXI_ARREADY <= 1;
  end else if (w_axi_ren & S_AXI_RLAST) begin
    S_AXI_ARREADY <= 1;
  end else if (w_axi_aren) begin
    S_AXI_ARREADY <= 0;
  end
end

always @ (posedge S_AXI_ACLK or negedge S_AXI_ARESETN) begin
  if (!S_AXI_ARESETN) begin
    r_rstate      <= 0;
    r_rburst      <= 0;
    r_rlen        <= 0;
    r_rlen_cnt    <= 0;
    r_arid_lat    <= 0;
    REG_REN       <= 0;
    REG_RADDR     <= 0;
    r_reg_rbten   <= 0;
  end else if (~r_rstate & w_axi_aren) begin
    r_rstate      <= 1;
    r_rburst      <= S_AXI_ARBURST;
    r_rlen        <= S_AXI_ARLEN;
    r_rlen_cnt    <= 0;
    r_arid_lat    <= S_AXI_ARID;
    REG_REN       <= 1;
    REG_RADDR     <= S_AXI_ARADDR;
    if ((1 << S_AXI_ARSIZE) > (P_DT_W/8)) begin
      r_reg_rbten   <= {(P_DT_W/8){1'b1}};
    end else begin
      case (S_AXI_ARSIZE)
        0:       r_reg_rbten <=   {1{1'b1}} << S_AXI_ARADDR[p_bank_width-1:0];
        1:       r_reg_rbten <=   {2{1'b1}} << S_AXI_ARADDR[p_bank_width-1:0];
        2:       r_reg_rbten <=   {4{1'b1}} << S_AXI_ARADDR[p_bank_width-1:0];
        3:       r_reg_rbten <=   {8{1'b1}} << S_AXI_ARADDR[p_bank_width-1:0];
        4:       r_reg_rbten <=  {16{1'b1}} << S_AXI_ARADDR[p_bank_width-1:0];
        5:       r_reg_rbten <=  {32{1'b1}} << S_AXI_ARADDR[p_bank_width-1:0];
        6:       r_reg_rbten <=  {64{1'b1}} << S_AXI_ARADDR[p_bank_width-1:0];
        default: r_reg_rbten <= {128{1'b1}} << S_AXI_ARADDR[p_bank_width-1:0];
      endcase
    end
  end else if (r_rstate) begin
    if (r_rlen_cnt >= r_rlen) begin
      r_rstate      <= 0;
      r_rburst      <= 0;
      r_rlen        <= 0;
      r_rlen_cnt    <= 0;
      REG_REN       <= 0;
      REG_RADDR     <= 0;
    end else begin
      r_rlen_cnt    <= r_rlen_cnt + 8'h1;
      if (r_rburst == 2'b10) begin
        if (r_rlen == 8'h01 & REG_RADDR[p_bank_width])
          REG_RADDR <= {REG_RADDR[P_AD_W-1:p_bank_width+1], {p_bank_width+1{1'b0}}};
        else if (r_rlen == 8'h03 & (&REG_RADDR[p_bank_width +: 2]))
          REG_RADDR <= {REG_RADDR[P_AD_W-1:p_bank_width+2], {p_bank_width+2{1'b0}}};
        else if (r_rlen == 8'h07 & (&REG_RADDR[p_bank_width +: 3]))
          REG_RADDR <= {REG_RADDR[P_AD_W-1:p_bank_width+3], {p_bank_width+3{1'b0}}};
        else if (r_rlen == 8'h0F & (&REG_RADDR[p_bank_width +: 4]))
          REG_RADDR <= {REG_RADDR[P_AD_W-1:p_bank_width+4], {p_bank_width+4{1'b0}}};
        else
          REG_RADDR <= REG_RADDR + (1 << p_bank_width);
      end else if (r_rburst == 2'b01) begin
        REG_RADDR <= REG_RADDR + (1 << p_bank_width);
      end
    end
  end
end

always @ (posedge S_AXI_ACLK or negedge S_AXI_ARESETN) begin
  if (!S_AXI_ARESETN) begin
    r_wait_flg <= 0;
    r_wait_cnt <= 0;
  end else if (REG_RWAIT) begin
    r_wait_flg <= 1;
    r_wait_cnt <= r_wait_cnt + 1;
  end else if (~REG_REN & r_read_extend_cnt >= r_wait_cnt - 1) begin
    r_wait_flg <= 0;
    r_wait_cnt <= 0;
  end
end

always @ (posedge S_AXI_ACLK or negedge S_AXI_ARESETN) begin
  if (!S_AXI_ARESETN) begin
    r_read_extend_cnt <= 0;
  end else if (~REG_REN & r_wait_flg) begin
    if (~REG_RWAIT & r_read_extend_cnt >= r_wait_cnt - 1)
      r_read_extend_cnt <= 0;
    else
      r_read_extend_cnt <= r_read_extend_cnt + 1;
  end else begin
    r_read_extend_cnt <= 0;
  end
end

always @ (posedge S_AXI_ACLK or negedge S_AXI_ARESETN) begin
  if (!S_AXI_ARESETN) begin
    S_AXI_RID    <= 0;
    S_AXI_RDATA  <= 0;
    S_AXI_RVALID <= 0;
    S_AXI_RLAST  <= 0;
    S_AXI_RRESP  <= 0;
  end else begin
    if (S_AXI_RREADY) begin
      if ((REG_REN | r_wait_flg) & ~REG_RWAIT) begin
        S_AXI_RVALID <= 1'b1;
        S_AXI_RID    <= r_arid_lat;
        S_AXI_RRESP  <= {REG_RACCERR, 1'b0};
      end else begin
        S_AXI_RVALID <= 0;
        S_AXI_RID    <= 0;
        S_AXI_RRESP  <= 0;
      end
      for (i=0; i<P_DT_W/8; i=i+1) begin
        S_AXI_RDATA[i*8 +: 8] <= REG_RDATA[i*8 +: 8] & {8{r_reg_rbten[i]}};
      end
      S_AXI_RLAST  <= ~REG_RWAIT &
                      ((~r_wait_flg &  REG_REN & r_rlen_cnt        >= r_rlen) |
                       ( r_wait_flg & ~REG_REN & r_read_extend_cnt >= r_wait_cnt - 1));
    end
  end
end

endmodule
