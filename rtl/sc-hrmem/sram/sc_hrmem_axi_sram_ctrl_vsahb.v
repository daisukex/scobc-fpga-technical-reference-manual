//-----------------------------------------------
// Module: sc_hrmem_axi_sram_ctrl_vsahb
//  Space Cubics AXI StaticRAM Controller (Arbitration with AHB Contorller)
//-----------------------------------------------
// Copyright © 2022 Space Cubics, LLC.
//-----------------------------------------------
module sc_hrmem_axi_sram_ctrl_vsahb # (
  parameter P_AXI_ID_W = 1,
  parameter P_AXI_AD_W = 22,
  parameter P_DT_W     = 32,
  parameter P_BANK_W   = 2,
  parameter P_RD_LTCY  = 3,
  parameter P_H_PRIO   = 1
) (
  // System Interface
  input                       S_AXI_ACLK,
  input                       S_AXI_ARESETN,
  input                       RAM_INIT_DONE,

  // AXI Slave Interface
  input      [P_AXI_ID_W-1:0] S_AXI_AWID,
  input      [P_AXI_AD_W-1:0] S_AXI_AWADDR,
  input      [7:0]            S_AXI_AWLEN,
  input      [2:0]            S_AXI_AWSIZE,
  input      [1:0]            S_AXI_AWBURST,
  input                       S_AXI_AWLOCK,
  input      [3:0]            S_AXI_AWCACHE,
  input      [2:0]            S_AXI_AWPROT,
  input                       S_AXI_AWVALID,
  output reg                  S_AXI_AWREADY,
  input      [P_DT_W-1:0]     S_AXI_WDATA,
  input      [P_DT_W/8-1:0]   S_AXI_WSTRB,
  input                       S_AXI_WLAST,
  input                       S_AXI_WVALID,
  output reg                  S_AXI_WREADY,
  output reg [P_AXI_ID_W-1:0] S_AXI_BID,
  output     [1:0]            S_AXI_BRESP,
  output reg                  S_AXI_BVALID,
  input                       S_AXI_BREADY,
  input      [P_AXI_ID_W-1:0] S_AXI_ARID,
  input      [P_AXI_AD_W-1:0] S_AXI_ARADDR,
  input      [7:0]            S_AXI_ARLEN,
  input      [2:0]            S_AXI_ARSIZE,
  input      [1:0]            S_AXI_ARBURST,
  input                       S_AXI_ARLOCK,
  input      [3:0]            S_AXI_ARCACHE,
  input      [2:0]            S_AXI_ARPROT,
  input                       S_AXI_ARVALID,
  output                      S_AXI_ARREADY,
  output     [P_AXI_ID_W-1:0] S_AXI_RID,
  output     [P_DT_W-1:0]     S_AXI_RDATA,
  output     [1:0]            S_AXI_RRESP,
  output                      S_AXI_RLAST,
  output                      S_AXI_RVALID,
  input                       S_AXI_RREADY,

  // Other AXI SRAM Controller Interface
  output                      SELF_WR_ACC_START,
  output reg                  SELF_WR_ACC_BUSY,
  output                      SELF_WR_ACC_END,
  output     [2:0]            SELF_WR_STATE,
  output                      SELF_WR_BURST_EN,
  output                      SELF_RD_ACC_START,
  output reg                  SELF_RD_ACC_BUSY,
  output                      SELF_RD_ACC_END,
  output     [1:0]            SELF_RD_STATE,
  output                      SELF_RD_BURST_EN,
  output                      SELF_RD_ST_BURST,
  input                       OTHER_WR_ACC_START,
  input                       OTHER_WR_ACC_BUSY,
  input                       OTHER_WR_ACC_END,
  input                       OTHER_RD_ACC_START,
  input                       OTHER_RD_ACC_BUSY,
  input                       OTHER_RD_ACC_END,
  input      [2:0]            OTHER_STATE,
  input                       OTHER_BURST_EN,
  input                       OTHER_ST_BURST,

  // Prefetch Controller Interface
  input      [1:0]            PF_MODE_SEL,
  output                      PF_SRCH_VAL,
  input                       PF_RD_VAL,
  input                       PF_RWAIT,
  input                       PF_ACC_VAL,
  input      [P_AXI_AD_W-1:0] PF_ACC_ADR,

  // RAM Interface
  output reg                  RAM_WEN,
  output reg [P_AXI_AD_W-1:0] RAM_WADR,
  output reg [P_DT_W-1:0]     RAM_WDATA,
  output reg [P_DT_W/8-1:0]   RAM_WBTEN,
  output                      RAM_REN,
  output     [P_AXI_AD_W-1:0] RAM_RADR,
  output     [P_DT_W/8-1:0]   RAM_RBTEN,
  input                       RAM_RDT_VAL,
  input      [P_DT_W-1:0]     RAM_RDATA
);

reg                  r_pf_rwait_p1;
reg                  r_self_wr_acc_end_p1;
reg                  r_self_wr_acc_end_p2;
reg                  r_other_wr_acc_end_p1;
reg                  r_other_wr_acc_end_p2;
reg                  r_other_wr_acc_end_p3;
reg                  r_other_rd_b_acc_end_p1;
reg                  r_other_rd_b_acc_end_p2;
reg [2:0]            r_other_state_p1;
wire                 w_other_rd_b_acc_end_wait;

wire                 w_axi_awen;
wire                 w_axi_wen;
wire                 w_axi_ben;

reg [1:0]            r_bvld_retim;
reg [P_AXI_ID_W-1:0] r_awid_lat;
reg [P_AXI_AD_W-1:0] r_awaddr_lat;
reg [7:0]            r_awlen_lat;
reg [2:0]            r_awsize_lat;
reg [1:0]            r_awburst_lat;
reg [P_DT_W-1:0]     r_wdata_lat;
reg [P_DT_W/8-1:0]   r_wstrb_lat;

wire                 w_wr_wait_flg;
wire                 w_wr_wait_start;
wire                 w_wr_wait_end;

reg                  r_comp_wdata_wait;
reg                  r_ram_wstart;
reg                  r_pf_wait_end_lat;
reg [2:0]            r_wr_state;

wire                 w_axi_aren;
wire                 w_axi_ren;

reg [P_AXI_ID_W-1:0] r_arid_lat;
reg [P_AXI_AD_W-1:0] r_araddr_lat;
reg [7:0]            r_arlen_lat;
reg [2:0]            r_arsize_lat;
reg [1:0]            r_arburst_lat;
reg [2:0]            r_arprot_lat;

wire                 w_rd_wait_start;
wire                 w_rd_wait_end;

reg [P_DT_W-1:0]     r_ram_rdata_rbten;

reg                  r_pre_arready;
reg                  r_pre_rvalid;
reg [P_AXI_ID_W-1:0] r_pre_rid;
reg [P_DT_W-1:0]     r_pre_rdata;
reg                  r_pre_rlast;
reg [7:0]            r_ren_cnt;
reg [1:0]            r_rd_state;

wire                 w_pf_acc_wait;

wire                 w_rdff_write;
wire                 w_rdff_read;

reg [7:0]            r_rdff_w_pntr;
reg [7:0]            r_rdff_r_pntr;
reg                  r_rdff_full;
wire                 w_rdff_val;

reg [P_DT_W-1:0]     r_ram_rdata_ff [0:P_RD_LTCY-1];

reg                  r_pf_acc_wait_lat;
reg                  r_pf_acc_wait_lat_p1;

reg [7:0]            r_rlen_cnt;
reg                  r_rd_burst_en;
reg                  r_ram_ren_burst;
reg [P_AXI_AD_W-1:0] r_ram_radr_burst;
reg [P_DT_W/8-1:0]   r_ram_rbten;

reg [P_DT_W/8-1:0]   r_axi_rbten;
reg [P_DT_W/8-1:0]   r_rbten_lat;

reg                  r_pf_val_lat;
reg [P_DT_W-1:0]     r_pf_data_lat;
reg                  r_pre_val_lat;

integer i;
genvar gn;

// Self State
parameter P_WR_IDLE = 3'h0,
          P_WR_ADR  = 3'h1,
          P_WR_DAT  = 3'h2,
          P_WR_WAIT = 3'h3,
          P_WR_RSP  = 3'h4;

parameter P_RD_IDLE = 2'h0,
          P_RD_WAIT = 2'h1,
          P_RD_READ = 2'h2,
          P_RD_PFRD = 2'h3;

// Other State
parameter P_IDLE       = 3'h0,
          P_WAIT_CONF  = 3'h1,
          P_WR_DATA    = 3'h2,
          P_WR_RESP    = 3'h3,
          P_WAIT_WR2RD = 3'h4,
          P_RD_DATA    = 3'h5,
          P_RD_RESP    = 3'h6,
          P_RD_PFER    = 3'h7;

always @ (posedge S_AXI_ACLK or negedge S_AXI_ARESETN) begin
  if (!S_AXI_ARESETN) begin
    r_pf_rwait_p1           <= 0;
    r_self_wr_acc_end_p1    <= 0;
    r_self_wr_acc_end_p2    <= 0;
    r_other_wr_acc_end_p1   <= 0;
    r_other_wr_acc_end_p2   <= 0;
    r_other_wr_acc_end_p3   <= 0;
    r_other_rd_b_acc_end_p1 <= 0;
    r_other_rd_b_acc_end_p2 <= 0;
    r_other_state_p1        <= 0;
  end else begin
    r_pf_rwait_p1           <= PF_RWAIT;
    r_self_wr_acc_end_p1    <= SELF_WR_ACC_END;
    r_self_wr_acc_end_p2    <= r_self_wr_acc_end_p1;
    r_other_wr_acc_end_p1   <= OTHER_WR_ACC_END;
    r_other_wr_acc_end_p2   <= r_other_wr_acc_end_p1;
    r_other_wr_acc_end_p3   <= r_other_wr_acc_end_p2;
    r_other_rd_b_acc_end_p1 <= (OTHER_RD_ACC_END & OTHER_BURST_EN);
    r_other_rd_b_acc_end_p2 <= r_other_rd_b_acc_end_p1;
    r_other_state_p1        <= OTHER_STATE;
  end
end

assign w_other_rd_b_acc_end_wait = r_other_rd_b_acc_end_p1 | r_other_rd_b_acc_end_p2;

////////////////////////////////
// Write Chanel               //
////////////////////////////////
assign w_axi_awen = S_AXI_AWVALID & S_AXI_AWREADY;
assign w_axi_wen  = S_AXI_WVALID  & S_AXI_WREADY;
assign w_axi_ben  = S_AXI_BVALID  & S_AXI_BREADY;

always @ (posedge S_AXI_ACLK or negedge S_AXI_ARESETN) begin
  if (!S_AXI_ARESETN) begin
    r_bvld_retim  <= 0;
    r_awid_lat    <= 0;
    r_awaddr_lat  <= 0;
    r_awlen_lat   <= 0;
    r_awsize_lat  <= 0;
    r_awburst_lat <= 0;
    r_wdata_lat   <= 0;
    r_wstrb_lat   <= 0;
  end else begin
    r_bvld_retim <= {r_bvld_retim[0], S_AXI_BVALID};
    if (w_axi_awen) begin
      r_awid_lat    <= S_AXI_AWID;
      r_awaddr_lat  <= S_AXI_AWADDR;
      r_awlen_lat   <= S_AXI_AWLEN;
      r_awsize_lat  <= S_AXI_AWSIZE;
      r_awburst_lat <= S_AXI_AWBURST;
    end
    if (w_axi_wen) begin
      r_wdata_lat <= S_AXI_WDATA;
      r_wstrb_lat <= S_AXI_WSTRB;
    end
  end
end

assign S_AXI_BRESP = 2'b00;

assign w_wr_wait_flg = ((P_H_PRIO == 0) & OTHER_WR_ACC_START) |
                       SELF_RD_ACC_START | OTHER_RD_ACC_START |
                       OTHER_WR_ACC_BUSY | OTHER_WR_ACC_END |
                       (SELF_RD_ACC_BUSY & ~SELF_RD_ACC_END &
                        (SELF_RD_BURST_EN | (SELF_RD_STATE == P_RD_WAIT))) |
                       (OTHER_RD_ACC_BUSY & ~OTHER_RD_ACC_END &
                        (OTHER_BURST_EN | (OTHER_STATE == P_WAIT_CONF) | (OTHER_STATE == P_WAIT_WR2RD)) |
                        ((OTHER_STATE == P_RD_DATA) & (r_other_state_p1 == P_WAIT_CONF))) |
                       w_other_rd_b_acc_end_wait |
                       PF_RWAIT;

assign w_wr_wait_start = SELF_WR_ACC_START & w_wr_wait_flg;

assign w_wr_wait_end = ((SELF_RD_ACC_END & ~(OTHER_WR_ACC_BUSY | OTHER_RD_ACC_BUSY)) |
                        (((SELF_RD_ACC_BUSY &
                           ~((SELF_RD_STATE == P_RD_WAIT) | OTHER_RD_ACC_START | OTHER_RD_ACC_BUSY)) |
                          (OTHER_RD_ACC_BUSY & ~(SELF_RD_ACC_START | SELF_RD_ACC_BUSY))) &
                         ((P_H_PRIO == 1) | ~OTHER_WR_ACC_BUSY) &
                         ~OTHER_BURST_EN) |
                        ((r_other_wr_acc_end_p1 | OTHER_RD_ACC_END) & ~SELF_RD_ACC_BUSY) |
                        ((((P_H_PRIO == 1) & (OTHER_WR_ACC_BUSY & (OTHER_STATE == P_WAIT_CONF))) |
                           (OTHER_STATE == P_IDLE)) &
                         ~PF_RWAIT & (SELF_RD_STATE == P_RD_IDLE) & ~(SELF_RD_ACC_START | OTHER_RD_ACC_START))) &
                       ~(((SELF_RD_STATE == P_RD_WAIT) & w_rd_wait_end) |
                         SELF_RD_BURST_EN | w_other_rd_b_acc_end_wait | (OTHER_STATE == P_WAIT_WR2RD) |
                         (OTHER_RD_ACC_BUSY & (OTHER_STATE == P_WAIT_CONF)) |
                         ((P_H_PRIO == 0) & OTHER_WR_ACC_BUSY));

always @ (posedge S_AXI_ACLK or negedge S_AXI_ARESETN) begin
  if (!S_AXI_ARESETN) begin
    S_AXI_AWREADY     <= 0;
    S_AXI_WREADY      <= 0;
    S_AXI_BVALID      <= 0;
    S_AXI_BID         <= 0;
    r_comp_wdata_wait <= 0;
    RAM_WEN           <= 0;
    RAM_WADR          <= 0;
    RAM_WDATA         <= 0;
    RAM_WBTEN         <= 0;
    r_ram_wstart      <= 0;
    r_pf_wait_end_lat <= 0;
    r_wr_state        <= P_WR_IDLE;
  end else begin
    if (~RAM_INIT_DONE) begin
      S_AXI_AWREADY     <= 0;
      S_AXI_WREADY      <= 0;
      S_AXI_BVALID      <= 0;
      S_AXI_BID         <= 0;
      r_comp_wdata_wait <= 0;
      RAM_WEN           <= 0;
      RAM_WADR          <= 0;
      RAM_WDATA         <= 0;
      RAM_WBTEN         <= 0;
      r_ram_wstart      <= 0;
      r_pf_wait_end_lat <= 0;
      r_wr_state        <= P_WR_IDLE;
    end else begin
      case (r_wr_state)
        P_WR_IDLE : begin
          S_AXI_AWREADY     <= 1'b1;
          S_AXI_WREADY      <= 1'b1;
          S_AXI_BVALID      <= 0;
          S_AXI_BID         <= 0;
          r_comp_wdata_wait <= 0;
          RAM_WEN           <= 0;
          RAM_WADR          <= 0;
          RAM_WDATA         <= 0;
          RAM_WBTEN         <= 0;
          r_ram_wstart      <= 0;
          r_pf_wait_end_lat <= 0;
          if (w_axi_awen & w_axi_wen) begin
            S_AXI_AWREADY <= 0;
            S_AXI_WREADY  <= 0;
            if (w_wr_wait_start) begin
              if (~S_AXI_WLAST)
                r_comp_wdata_wait <= 1'b1;
              r_wr_state   <= P_WR_WAIT;
            end else begin
              RAM_WEN   <= 1'b1;
              RAM_WADR  <= S_AXI_AWADDR;
              RAM_WDATA <= S_AXI_WDATA;
              if ((1 << S_AXI_AWSIZE) > (P_DT_W/8)) begin
                RAM_WBTEN <= {(P_DT_W/8){1'b1}} & S_AXI_WSTRB;
              end else begin
                case (S_AXI_AWSIZE)
                  0:       RAM_WBTEN <= (  {1{1'b1}} << S_AXI_AWADDR[P_BANK_W-1:0]) & S_AXI_WSTRB;
                  1:       RAM_WBTEN <= (  {2{1'b1}} << S_AXI_AWADDR[P_BANK_W-1:0]) & S_AXI_WSTRB;
                  2:       RAM_WBTEN <= (  {4{1'b1}} << S_AXI_AWADDR[P_BANK_W-1:0]) & S_AXI_WSTRB;
                  3:       RAM_WBTEN <= (  {8{1'b1}} << S_AXI_AWADDR[P_BANK_W-1:0]) & S_AXI_WSTRB;
                  4:       RAM_WBTEN <= ( {16{1'b1}} << S_AXI_AWADDR[P_BANK_W-1:0]) & S_AXI_WSTRB;
                  5:       RAM_WBTEN <= ( {32{1'b1}} << S_AXI_AWADDR[P_BANK_W-1:0]) & S_AXI_WSTRB;
                  6:       RAM_WBTEN <= ( {64{1'b1}} << S_AXI_AWADDR[P_BANK_W-1:0]) & S_AXI_WSTRB;
                  default: RAM_WBTEN <= ({128{1'b1}} << S_AXI_AWADDR[P_BANK_W-1:0]) & S_AXI_WSTRB;
                endcase
              end
              r_ram_wstart <= 1'b1;
              if (S_AXI_WLAST) begin
                if (&S_AXI_WSTRB)
                  S_AXI_BVALID <= 1'b1;
                S_AXI_BID    <= S_AXI_AWID;
                r_wr_state   <= P_WR_RSP;
              end else begin
                r_wr_state   <= P_WR_DAT;
              end
            end
          end else if (w_axi_awen) begin
            S_AXI_AWREADY <= 0;
            r_wr_state    <= P_WR_DAT;
          end else if (w_axi_wen) begin
            S_AXI_WREADY <= 0;
            if (~S_AXI_WLAST)
              r_comp_wdata_wait <= 1'b1;
            r_wr_state   <= P_WR_ADR;
          end
        end
        P_WR_ADR : begin
          if (w_axi_awen) begin
            S_AXI_AWREADY <= 0;
            S_AXI_WREADY  <= 0;
            if (w_wr_wait_start) begin
              r_wr_state <= P_WR_WAIT;
            end else begin
              RAM_WEN   <= 1'b1;
              RAM_WADR  <= S_AXI_AWADDR;
              RAM_WDATA <= r_wdata_lat;
              if ((1 << S_AXI_AWSIZE) > (P_DT_W/8)) begin
                RAM_WBTEN <= {(P_DT_W/8){1'b1}} & r_wstrb_lat;
              end else begin
                case (S_AXI_AWSIZE)
                  0:       RAM_WBTEN <= (  {1{1'b1}} << S_AXI_AWADDR[P_BANK_W-1:0]) & r_wstrb_lat;
                  1:       RAM_WBTEN <= (  {2{1'b1}} << S_AXI_AWADDR[P_BANK_W-1:0]) & r_wstrb_lat;
                  2:       RAM_WBTEN <= (  {4{1'b1}} << S_AXI_AWADDR[P_BANK_W-1:0]) & r_wstrb_lat;
                  3:       RAM_WBTEN <= (  {8{1'b1}} << S_AXI_AWADDR[P_BANK_W-1:0]) & r_wstrb_lat;
                  4:       RAM_WBTEN <= ( {16{1'b1}} << S_AXI_AWADDR[P_BANK_W-1:0]) & r_wstrb_lat;
                  5:       RAM_WBTEN <= ( {32{1'b1}} << S_AXI_AWADDR[P_BANK_W-1:0]) & r_wstrb_lat;
                  6:       RAM_WBTEN <= ( {64{1'b1}} << S_AXI_AWADDR[P_BANK_W-1:0]) & r_wstrb_lat;
                  default: RAM_WBTEN <= ({128{1'b1}} << S_AXI_AWADDR[P_BANK_W-1:0]) & r_wstrb_lat;
                endcase
              end
              r_ram_wstart <= 1'b1;
              if (r_comp_wdata_wait) begin
                r_comp_wdata_wait <= 0;
                r_wr_state        <= P_WR_DAT;
              end else begin
                if (&r_wstrb_lat)
                  S_AXI_BVALID <= 1'b1;
                S_AXI_BID         <= S_AXI_AWID;
                r_wr_state        <= P_WR_RSP;
              end
            end
          end
        end
        P_WR_DAT : begin
          r_pf_wait_end_lat <= 0;
          if (w_axi_wen) begin
            S_AXI_WREADY <= 0;
            if (w_wr_wait_start) begin
              if (~S_AXI_WLAST)
                r_comp_wdata_wait <= 1'b1;
              r_wr_state   <= P_WR_WAIT;
            end else begin
              RAM_WEN   <= 1'b1;
              RAM_WDATA <= S_AXI_WDATA;
              if ((1 << r_awsize_lat) > (P_DT_W/8)) begin
                RAM_WBTEN <= {(P_DT_W/8){1'b1}} & S_AXI_WSTRB;
              end else begin
                case (r_awsize_lat)
                  0:       RAM_WBTEN <= (  {1{1'b1}} << r_awaddr_lat[P_BANK_W-1:0]) & S_AXI_WSTRB;
                  1:       RAM_WBTEN <= (  {2{1'b1}} << r_awaddr_lat[P_BANK_W-1:0]) & S_AXI_WSTRB;
                  2:       RAM_WBTEN <= (  {4{1'b1}} << r_awaddr_lat[P_BANK_W-1:0]) & S_AXI_WSTRB;
                  3:       RAM_WBTEN <= (  {8{1'b1}} << r_awaddr_lat[P_BANK_W-1:0]) & S_AXI_WSTRB;
                  4:       RAM_WBTEN <= ( {16{1'b1}} << r_awaddr_lat[P_BANK_W-1:0]) & S_AXI_WSTRB;
                  5:       RAM_WBTEN <= ( {32{1'b1}} << r_awaddr_lat[P_BANK_W-1:0]) & S_AXI_WSTRB;
                  6:       RAM_WBTEN <= ( {64{1'b1}} << r_awaddr_lat[P_BANK_W-1:0]) & S_AXI_WSTRB;
                  default: RAM_WBTEN <= ({128{1'b1}} << r_awaddr_lat[P_BANK_W-1:0]) & S_AXI_WSTRB;
                endcase
              end
              if (~r_ram_wstart) begin
                RAM_WADR     <= r_awaddr_lat;
                r_ram_wstart <= 1'b1;
              end else begin
                if (r_awburst_lat == 2'b10) begin
                  if (r_awlen_lat == 8'h01 & RAM_WADR[P_BANK_W])
                    RAM_WADR <= {RAM_WADR[P_AXI_AD_W-1:P_BANK_W+1], {P_BANK_W+1{1'b0}}};
                  else if (r_awlen_lat == 8'h03 & (&RAM_WADR[P_BANK_W +: 2]))
                    RAM_WADR <= {RAM_WADR[P_AXI_AD_W-1:P_BANK_W+2], {P_BANK_W+2{1'b0}}};
                  else if (r_awlen_lat == 8'h07 & (&RAM_WADR[P_BANK_W +: 3]))
                    RAM_WADR <= {RAM_WADR[P_AXI_AD_W-1:P_BANK_W+3], {P_BANK_W+3{1'b0}}};
                  else if (r_awlen_lat == 8'h0F & (&RAM_WADR[P_BANK_W +: 4]))
                    RAM_WADR <= {RAM_WADR[P_AXI_AD_W-1:P_BANK_W+4], {P_BANK_W+4{1'b0}}};
                  else
                    RAM_WADR <= RAM_WADR + (1 << P_BANK_W);
                end else if (r_awburst_lat == 2'b01) begin
                  RAM_WADR <= RAM_WADR + (1 << P_BANK_W);
                end
              end
              if (S_AXI_WLAST) begin
                if (&S_AXI_WSTRB)
                  S_AXI_BVALID <= 1'b1;
                S_AXI_BID    <= r_awid_lat;
                r_wr_state   <= P_WR_RSP;
              end
            end
          end else begin
            S_AXI_WREADY <= 1'b1;
            RAM_WEN      <= 0;
          end
        end
        P_WR_WAIT : begin
          if (PF_RWAIT) begin
            if (w_wr_wait_end)
              r_pf_wait_end_lat <= 1'b1;
          end else if (~w_wr_wait_flg) begin
            r_pf_wait_end_lat <= 0;
          end
          if ((w_wr_wait_end | (r_pf_wait_end_lat & ~w_wr_wait_flg)) & ~PF_RWAIT) begin
            if (r_comp_wdata_wait) begin
              r_comp_wdata_wait <= 0;
              r_wr_state        <= P_WR_DAT;
            end else begin
              if (&r_wstrb_lat)
                S_AXI_BVALID <= 1'b1;
              S_AXI_BID         <= r_awid_lat;
              r_wr_state        <= P_WR_RSP;
            end
            RAM_WEN   <= 1'b1;
            RAM_WADR  <= r_awaddr_lat;
            RAM_WDATA <= r_wdata_lat;
            if ((1 << r_awsize_lat) > (P_DT_W/8)) begin
              RAM_WBTEN <= {(P_DT_W/8){1'b1}} & r_wstrb_lat;
            end else begin
              case (r_awsize_lat)
                0:       RAM_WBTEN <= (  {1{1'b1}} << r_awaddr_lat[P_BANK_W-1:0]) & r_wstrb_lat;
                1:       RAM_WBTEN <= (  {2{1'b1}} << r_awaddr_lat[P_BANK_W-1:0]) & r_wstrb_lat;
                2:       RAM_WBTEN <= (  {4{1'b1}} << r_awaddr_lat[P_BANK_W-1:0]) & r_wstrb_lat;
                3:       RAM_WBTEN <= (  {8{1'b1}} << r_awaddr_lat[P_BANK_W-1:0]) & r_wstrb_lat;
                4:       RAM_WBTEN <= ( {16{1'b1}} << r_awaddr_lat[P_BANK_W-1:0]) & r_wstrb_lat;
                5:       RAM_WBTEN <= ( {32{1'b1}} << r_awaddr_lat[P_BANK_W-1:0]) & r_wstrb_lat;
                6:       RAM_WBTEN <= ( {64{1'b1}} << r_awaddr_lat[P_BANK_W-1:0]) & r_wstrb_lat;
                default: RAM_WBTEN <= ({128{1'b1}} << r_awaddr_lat[P_BANK_W-1:0]) & r_wstrb_lat;
              endcase
            end
            r_ram_wstart <= 1'b1;
          end
        end
        P_WR_RSP : begin
          RAM_WEN      <= 0;
          RAM_WADR     <= 0;
          RAM_WDATA    <= 0;
          RAM_WBTEN    <= 0;
          r_ram_wstart <= 0;
          r_pf_wait_end_lat <= 0;
          S_AXI_BVALID <= 1'b1;
          if (w_axi_ben) begin
            S_AXI_AWREADY <= 1'b1;
            S_AXI_WREADY  <= 1'b1;
            S_AXI_BVALID  <= 0;
            S_AXI_BID     <= 0;
            r_wr_state    <= P_WR_IDLE;
          end
        end
        default : begin
          S_AXI_AWREADY     <= 1'b1;
          S_AXI_WREADY      <= 1'b1;
          S_AXI_BVALID      <= 0;
          S_AXI_BID         <= 0;
          r_comp_wdata_wait <= 0;
          RAM_WEN           <= 0;
          RAM_WADR          <= 0;
          RAM_WDATA         <= 0;
          RAM_WBTEN         <= 0;
          r_ram_wstart      <= 0;
          r_pf_wait_end_lat <= 0;
          r_wr_state        <= P_WR_IDLE;
        end
      endcase
    end
  end
end

assign SELF_WR_ACC_START = ((r_wr_state == P_WR_IDLE) & w_axi_awen & w_axi_wen) |
                           ((r_wr_state == P_WR_ADR)  & w_axi_awen)             |
                           ((r_wr_state == P_WR_DAT)  & w_axi_wen  & ~SELF_WR_ACC_BUSY);

always @ (posedge S_AXI_ACLK or negedge S_AXI_ARESETN) begin
  if (!S_AXI_ARESETN) begin
    SELF_WR_ACC_BUSY <= 0;
  end else begin
    if (SELF_WR_ACC_START)
      SELF_WR_ACC_BUSY <= 1'b1;
    else if (SELF_WR_ACC_END)
      SELF_WR_ACC_BUSY <= 0;
  end
end

assign SELF_WR_ACC_END = r_bvld_retim[0] & ~r_bvld_retim[1];

assign SELF_WR_STATE = r_wr_state;
assign SELF_WR_BURST_EN = r_ram_wstart;

////////////////////////////////
// Read Chanel                //
////////////////////////////////
assign w_axi_aren = S_AXI_ARVALID & S_AXI_ARREADY;
assign w_axi_ren  = S_AXI_RVALID  & S_AXI_RREADY;

always @ (posedge S_AXI_ACLK or negedge S_AXI_ARESETN) begin
  if (!S_AXI_ARESETN) begin
    r_arid_lat    <= 0;
    r_araddr_lat  <= 0;
    r_arlen_lat   <= 0;
    r_arsize_lat  <= 0;
    r_arburst_lat <= 0;
    r_arprot_lat  <= 0;
  end else begin
    if (w_axi_aren) begin
      r_arid_lat    <= S_AXI_ARID;
      r_araddr_lat  <= S_AXI_ARADDR;
      r_arlen_lat   <= S_AXI_ARLEN;
      r_arsize_lat  <= S_AXI_ARSIZE;
      r_arburst_lat <= S_AXI_ARBURST;
      r_arprot_lat  <= S_AXI_ARPROT;
    end
  end
end

assign S_AXI_RRESP = 2'b00;

assign w_rd_wait_start = SELF_RD_ACC_START &
                         (((P_H_PRIO == 0) & OTHER_RD_ACC_START) |
                          (OTHER_RD_ACC_BUSY & ~OTHER_RD_ACC_END) |
                          SELF_WR_ACC_BUSY | r_self_wr_acc_end_p1 |
                          OTHER_WR_ACC_BUSY | r_other_wr_acc_end_p1 | r_other_wr_acc_end_p2);

assign w_rd_wait_end = (((r_self_wr_acc_end_p2 &
                           ~(((P_H_PRIO == 0) & OTHER_RD_ACC_BUSY) |
                             (OTHER_WR_ACC_BUSY & (OTHER_STATE != P_WAIT_CONF)) |
                             OTHER_WR_ACC_END)) |
                         ((OTHER_WR_ACC_BUSY & (OTHER_STATE == P_WAIT_CONF)) & ~SELF_WR_ACC_BUSY) |
                         (((OTHER_WR_ACC_BUSY & (OTHER_STATE == P_WAIT_CONF)) | (SELF_WR_STATE == P_WR_WAIT)) &
                          (((P_H_PRIO == 1) & (OTHER_STATE == P_WAIT_CONF)) | ~OTHER_RD_ACC_BUSY) &
                          ~((SELF_WR_ACC_BUSY & (SELF_WR_STATE != P_WR_WAIT)) |
                            (OTHER_WR_ACC_BUSY & (OTHER_STATE != P_WAIT_CONF))))) |
                        ((r_other_wr_acc_end_p3 | OTHER_RD_ACC_END) &
                         ~((SELF_WR_ACC_BUSY & (SELF_WR_STATE == P_WR_DAT)) | OTHER_WR_ACC_END |
                           ((P_H_PRIO == 0) & OTHER_RD_ACC_BUSY & (OTHER_STATE == P_WAIT_CONF)) |
                           (OTHER_STATE == P_WAIT_WR2RD))) |
                        (((SELF_WR_STATE == P_WR_IDLE) | (SELF_WR_STATE == P_WR_WAIT)) &
                         ((OTHER_STATE == P_IDLE) |
                          ((OTHER_WR_ACC_BUSY & (OTHER_STATE == P_WAIT_CONF)) |
                           ((P_H_PRIO == 1) & OTHER_RD_ACC_BUSY & (OTHER_STATE == P_WAIT_CONF)))))) &
                       ~(SELF_WR_BURST_EN | SELF_WR_ACC_END | r_self_wr_acc_end_p1 |
                         (OTHER_WR_ACC_BUSY & OTHER_BURST_EN & (OTHER_STATE != P_WAIT_CONF)) |
                         r_other_wr_acc_end_p1 | r_other_wr_acc_end_p2 | PF_RWAIT | r_pf_rwait_p1);

always @ (*) begin
  for (i=0; i<P_DT_W/8; i=i+1) begin
    r_ram_rdata_rbten[i*8 +: 8] = RAM_RDATA[i*8 +: 8] & {8{r_ram_rbten[i]}};
  end
end

always @ (posedge S_AXI_ACLK or negedge S_AXI_ARESETN) begin
  if (!S_AXI_ARESETN) begin
    r_pre_arready <= 0;
    r_pre_rvalid  <= 0;
    r_pre_rid     <= 0;
    r_pre_rdata   <= 0;
    r_pre_rlast   <= 0;
    r_ren_cnt     <= 0;
    r_rd_state    <= P_RD_IDLE;
  end else begin
    if (~RAM_INIT_DONE) begin
      r_pre_arready <= 0;
      r_pre_rvalid  <= 0;
      r_pre_rid     <= 0;
      r_pre_rdata   <= 0;
      r_pre_rlast   <= 0;
      r_ren_cnt     <= 0;
      r_rd_state    <= P_RD_IDLE;
    end else begin
      case (r_rd_state)
        P_RD_IDLE : begin
          r_pre_arready <= 1'b1;
          r_pre_rvalid  <= 0;
          r_pre_rid     <= 0;
          r_pre_rdata   <= 0;
          r_pre_rlast   <= 0;
          r_ren_cnt     <= 0;
          if (w_axi_aren) begin
            r_pre_arready <= 0;
            if (w_rd_wait_start)
              r_rd_state <= P_RD_WAIT;
            else if (PF_SRCH_VAL)
              r_rd_state <= P_RD_PFRD;
            else
              r_rd_state <= P_RD_READ;
          end
        end
        P_RD_WAIT : begin
          if (w_rd_wait_end)
            if (PF_SRCH_VAL)
              r_rd_state <= P_RD_PFRD;
            else
              r_rd_state <= P_RD_READ;
        end
        P_RD_READ : begin
          r_pre_rvalid <= 0;
          if (w_axi_ren & S_AXI_RLAST) begin
            r_pre_arready <= 1'b1;
            r_pre_rid     <= 0;
            r_pre_rdata   <= 0;
            r_pre_rlast   <= 0;
            r_ren_cnt     <= 0;
            r_rd_state    <= P_RD_IDLE;
          end else begin
            if ((RAM_RDT_VAL & ~w_rdff_write) | (w_rdff_val & S_AXI_RREADY)) begin
              r_pre_rvalid <= 1'b1;
              r_pre_rid    <= r_arid_lat;
              if (w_rdff_val) begin
                r_pre_rdata <= r_ram_rdata_ff[r_rdff_r_pntr];
              end else begin
                r_pre_rdata <= r_ram_rdata_rbten;
              end
              r_ren_cnt <= r_ren_cnt + 8'h1;
            end
            if ((RAM_RDT_VAL & ~|r_arlen_lat) |
                (w_axi_ren & r_ren_cnt >= r_arlen_lat))
              r_pre_rlast <= 1'b1;
          end
        end
        P_RD_PFRD : begin
          if (w_axi_ren & S_AXI_RLAST) begin
            r_pre_arready <= 1'b1;
            r_rd_state    <= P_RD_IDLE;
          end
        end
        default : begin
          r_pre_arready <= 1'b1;
          r_pre_rvalid  <= 0;
          r_pre_rid     <= 0;
          r_pre_rdata   <= 0;
          r_pre_rlast   <= 0;
          r_ren_cnt     <= 0;
          r_rd_state    <= P_RD_IDLE;
        end
      endcase
    end
  end
end

assign w_pf_acc_wait = PF_ACC_VAL;

assign S_AXI_ARREADY = r_pre_arready & ~w_pf_acc_wait;

assign SELF_RD_ACC_START = (r_rd_state == P_RD_IDLE) & w_axi_aren;

always @ (posedge S_AXI_ACLK or negedge S_AXI_ARESETN) begin
  if (!S_AXI_ARESETN) begin
    SELF_RD_ACC_BUSY <= 0;
  end else begin
    if (SELF_RD_ACC_START)
      SELF_RD_ACC_BUSY <= 1'b1;
    else if (SELF_RD_ACC_END)
      SELF_RD_ACC_BUSY <= 0;
  end
end

assign SELF_RD_ACC_END = w_axi_ren & S_AXI_RLAST;

assign SELF_RD_STATE = r_rd_state;

assign w_rdff_write = ((r_rd_state == P_RD_READ & S_AXI_RVALID & (~S_AXI_RREADY | w_rdff_val)) &
                       RAM_RDT_VAL);
assign w_rdff_read  = (r_rd_state == P_RD_READ & S_AXI_RREADY) & w_rdff_val;

always @ (posedge S_AXI_ACLK or negedge S_AXI_ARESETN) begin
  if (!S_AXI_ARESETN) begin
    r_rdff_w_pntr <= 0;
    r_rdff_r_pntr <= 0;
    r_rdff_full   <= 0;
  end else begin
    if (r_rd_state == P_RD_IDLE) begin
      r_rdff_w_pntr <= 0;
      r_rdff_r_pntr <= 0;
      r_rdff_full   <= 0;
    end else begin
      if (w_rdff_write) begin
        if (r_rdff_w_pntr >= P_RD_LTCY-1)
          r_rdff_w_pntr <= 0;
        else
          r_rdff_w_pntr <= r_rdff_w_pntr + 8'h1;
      end
      if (w_rdff_read) begin
        if (r_rdff_r_pntr >= P_RD_LTCY-1)
          r_rdff_r_pntr <= 0;
        else
          r_rdff_r_pntr <= r_rdff_r_pntr + 8'h1;
      end
      if (w_rdff_write & ~w_rdff_read) begin
        if ((r_rdff_w_pntr + 8'h1 == r_rdff_r_pntr) |
            (r_rdff_w_pntr == r_rdff_r_pntr + P_RD_LTCY - 8'h1))
          r_rdff_full <= 1;
      end else if (w_rdff_read & ~w_rdff_write) begin
        r_rdff_full <= 0;
      end
    end
  end
end

assign w_rdff_val = r_rdff_w_pntr != r_rdff_r_pntr | r_rdff_full;

generate
  for(gn=0; gn<P_RD_LTCY; gn=gn+1) begin : ram_rdata_ff_gen
    always @ (posedge S_AXI_ACLK or negedge S_AXI_ARESETN) begin
      if (!S_AXI_ARESETN) begin
        r_ram_rdata_ff[gn] <= 0;
      end else begin
        if (r_rd_state == P_RD_IDLE) begin
          r_ram_rdata_ff[gn] <= 0;
        end else begin
          if (w_rdff_write) begin
            if (r_rdff_w_pntr== gn)
              r_ram_rdata_ff[gn] <= r_ram_rdata_rbten;
          end
        end
      end
    end
  end
endgenerate

always @ (posedge S_AXI_ACLK or negedge S_AXI_ARESETN) begin
  if (!S_AXI_ARESETN) begin
    r_pf_acc_wait_lat    <= 0;
    r_pf_acc_wait_lat_p1 <= 0;
  end else begin
    r_pf_acc_wait_lat_p1 <= r_pf_acc_wait_lat;
    if (w_pf_acc_wait) begin
      if ((r_rd_state == P_RD_WAIT) & OTHER_RD_ACC_END)
        r_pf_acc_wait_lat <= 1'b1;
    end else begin
      r_pf_acc_wait_lat <= 0;
    end
  end
end

always @ (posedge S_AXI_ACLK or negedge S_AXI_ARESETN) begin
  if (!S_AXI_ARESETN) begin
     r_rlen_cnt        <= 0;
     r_rd_burst_en     <= 0;
     r_ram_ren_burst   <= 0;
     r_ram_radr_burst  <= 0;
     r_ram_rbten       <= 0;
  end else begin
    if (r_rd_state == P_RD_IDLE | r_rd_state == P_RD_WAIT) begin
      r_rlen_cnt        <= 0;
      r_rd_burst_en     <= 0;
      r_ram_ren_burst   <= 0;
      r_ram_radr_burst  <= 0;
      if (r_rd_state != P_RD_WAIT)
        r_ram_rbten       <= 0;
      if (SELF_RD_ACC_START) begin
        if ((1 << S_AXI_ARSIZE) > (P_DT_W/8)) begin
          r_ram_rbten <= {(P_DT_W/8){1'b1}};
        end else begin
          case (S_AXI_ARSIZE)
            0:       r_ram_rbten <=   {1{1'b1}} << S_AXI_ARADDR[P_BANK_W-1:0];
            1:       r_ram_rbten <=   {2{1'b1}} << S_AXI_ARADDR[P_BANK_W-1:0];
            2:       r_ram_rbten <=   {4{1'b1}} << S_AXI_ARADDR[P_BANK_W-1:0];
            3:       r_ram_rbten <=   {8{1'b1}} << S_AXI_ARADDR[P_BANK_W-1:0];
            4:       r_ram_rbten <=  {16{1'b1}} << S_AXI_ARADDR[P_BANK_W-1:0];
            5:       r_ram_rbten <=  {32{1'b1}} << S_AXI_ARADDR[P_BANK_W-1:0];
            6:       r_ram_rbten <=  {64{1'b1}} << S_AXI_ARADDR[P_BANK_W-1:0];
            default: r_ram_rbten <= {128{1'b1}} << S_AXI_ARADDR[P_BANK_W-1:0];
          endcase
        end
      end
      if (SELF_RD_ACC_START & |S_AXI_ARLEN & ~w_rd_wait_start) begin
        r_rd_burst_en <= 1'b1;
        r_rlen_cnt    <= 8'h1;
        if (S_AXI_ARBURST == 2'b10) begin
          if (S_AXI_ARLEN == 8'h01 & S_AXI_ARADDR[P_BANK_W])
            r_ram_radr_burst <= {S_AXI_ARADDR[P_AXI_AD_W-1:P_BANK_W+1], {P_BANK_W+1{1'b0}}};
          else if (S_AXI_ARLEN == 8'h03 & (&S_AXI_ARADDR[P_BANK_W +: 2]))
            r_ram_radr_burst <= {S_AXI_ARADDR[P_AXI_AD_W-1:P_BANK_W+2], {P_BANK_W+2{1'b0}}};
          else if (S_AXI_ARLEN == 8'h07 & (&S_AXI_ARADDR[P_BANK_W +: 3]))
            r_ram_radr_burst <= {S_AXI_ARADDR[P_AXI_AD_W-1:P_BANK_W+3], {P_BANK_W+3{1'b0}}};
          else if (S_AXI_ARLEN == 8'h0F & (&S_AXI_ARADDR[P_BANK_W +: 4]))
            r_ram_radr_burst <= {S_AXI_ARADDR[P_AXI_AD_W-1:P_BANK_W+4], {P_BANK_W+4{1'b0}}};
          else
            r_ram_radr_burst <= S_AXI_ARADDR + (1 << P_BANK_W);
        end else if (S_AXI_ARBURST == 2'b01) begin
          r_ram_radr_burst <= S_AXI_ARADDR + (1 << P_BANK_W);
        end else begin
          r_ram_radr_burst <= S_AXI_ARADDR;
        end
      end else if (r_rd_state == P_RD_WAIT & |r_arlen_lat & w_rd_wait_end) begin
        r_rd_burst_en <= 1'b1;
        r_rlen_cnt    <= 8'h1;
        if (r_arburst_lat == 2'b10) begin
          if (r_arlen_lat == 8'h01 & r_araddr_lat[P_BANK_W])
            r_ram_radr_burst <= {r_araddr_lat[P_AXI_AD_W-1:P_BANK_W+1], {P_BANK_W+1{1'b0}}};
          else if (r_arlen_lat == 8'h03 & (&r_araddr_lat[P_BANK_W +: 2]))
            r_ram_radr_burst <= {r_araddr_lat[P_AXI_AD_W-1:P_BANK_W+2], {P_BANK_W+2{1'b0}}};
          else if (r_arlen_lat == 8'h07 & (&r_araddr_lat[P_BANK_W +: 3]))
            r_ram_radr_burst <= {r_araddr_lat[P_AXI_AD_W-1:P_BANK_W+3], {P_BANK_W+3{1'b0}}};
          else if (r_arlen_lat == 8'h0F & (&r_araddr_lat[P_BANK_W +: 4]))
            r_ram_radr_burst <= {r_araddr_lat[P_AXI_AD_W-1:P_BANK_W+4], {P_BANK_W+4{1'b0}}};
          else
            r_ram_radr_burst <= r_araddr_lat + (1 << P_BANK_W);
        end else if (r_arburst_lat == 2'b01) begin
          r_ram_radr_burst <= r_araddr_lat + (1 << P_BANK_W);
        end else begin
          r_ram_radr_burst <= r_araddr_lat;
        end
      end
    end else if (r_rd_state == P_RD_READ & ((~S_AXI_RVALID | S_AXI_RREADY) | r_ram_ren_burst)) begin
      if (r_rd_burst_en) begin
        if (r_ram_ren_burst) begin
          r_ram_ren_burst <= 0;
          if (r_rlen_cnt >= r_arlen_lat) begin
            r_rd_burst_en    <= 0;
            r_ram_radr_burst <= 0;
          end else begin
            r_rlen_cnt <= r_rlen_cnt + 8'h1;
            if (r_arburst_lat == 2'b10) begin
              if (r_arlen_lat == 8'h01 & r_ram_radr_burst[P_BANK_W])
                r_ram_radr_burst <= {r_ram_radr_burst[P_AXI_AD_W-1:P_BANK_W+1], {P_BANK_W+1{1'b0}}};
              else if (r_arlen_lat == 8'h03 & (&r_ram_radr_burst[P_BANK_W +: 2]))
                r_ram_radr_burst <= {r_ram_radr_burst[P_AXI_AD_W-1:P_BANK_W+2], {P_BANK_W+2{1'b0}}};
              else if (r_arlen_lat == 8'h07 & (&r_ram_radr_burst[P_BANK_W +: 3]))
                r_ram_radr_burst <= {r_ram_radr_burst[P_AXI_AD_W-1:P_BANK_W+3], {P_BANK_W+3{1'b0}}};
              else if (r_arlen_lat == 8'h0F & (&r_ram_radr_burst[P_BANK_W +: 4]))
                r_ram_radr_burst <= {r_ram_radr_burst[P_AXI_AD_W-1:P_BANK_W+4], {P_BANK_W+4{1'b0}}};
              else
                r_ram_radr_burst <= r_ram_radr_burst + (1 << P_BANK_W);
            end else if (r_arburst_lat == 2'b01) begin
              r_ram_radr_burst <= r_ram_radr_burst + (1 << P_BANK_W);
            end
          end
        end else begin
          r_ram_ren_burst <= 1'b1;
        end
      end
    end
  end
end

assign SELF_RD_BURST_EN = r_rd_burst_en;
assign SELF_RD_ST_BURST = |S_AXI_ARLEN & w_axi_aren;

always @ (*) begin
  if ((1 << S_AXI_ARSIZE) > (P_DT_W/8)) begin
    r_axi_rbten = {(P_DT_W/8){1'b1}};
  end else begin
    case (S_AXI_ARSIZE)
      0:       r_axi_rbten =   {1{1'b1}} << S_AXI_ARADDR[P_BANK_W-1:0];
      1:       r_axi_rbten =   {2{1'b1}} << S_AXI_ARADDR[P_BANK_W-1:0];
      2:       r_axi_rbten =   {4{1'b1}} << S_AXI_ARADDR[P_BANK_W-1:0];
      3:       r_axi_rbten =   {8{1'b1}} << S_AXI_ARADDR[P_BANK_W-1:0];
      4:       r_axi_rbten =  {16{1'b1}} << S_AXI_ARADDR[P_BANK_W-1:0];
      5:       r_axi_rbten =  {32{1'b1}} << S_AXI_ARADDR[P_BANK_W-1:0];
      6:       r_axi_rbten =  {64{1'b1}} << S_AXI_ARADDR[P_BANK_W-1:0];
      default: r_axi_rbten = {128{1'b1}} << S_AXI_ARADDR[P_BANK_W-1:0];
    endcase
  end
end

always @ (*) begin
  if ((1 << r_arsize_lat) > (P_DT_W/8)) begin
    r_rbten_lat = {(P_DT_W/8){1'b1}};
  end else begin
    case (r_arsize_lat)
      0:       r_rbten_lat =   {1{1'b1}} << r_araddr_lat[P_BANK_W-1:0];
      1:       r_rbten_lat =   {2{1'b1}} << r_araddr_lat[P_BANK_W-1:0];
      2:       r_rbten_lat =   {4{1'b1}} << r_araddr_lat[P_BANK_W-1:0];
      3:       r_rbten_lat =   {8{1'b1}} << r_araddr_lat[P_BANK_W-1:0];
      4:       r_rbten_lat =  {16{1'b1}} << r_araddr_lat[P_BANK_W-1:0];
      5:       r_rbten_lat =  {32{1'b1}} << r_araddr_lat[P_BANK_W-1:0];
      6:       r_rbten_lat =  {64{1'b1}} << r_araddr_lat[P_BANK_W-1:0];
      default: r_rbten_lat = {128{1'b1}} << r_araddr_lat[P_BANK_W-1:0];
    endcase
  end
end

assign RAM_REN  = (SELF_RD_ACC_START & ~w_rd_wait_start) |
                  ((r_rd_state == P_RD_WAIT) & w_rd_wait_end) |
                  r_ram_ren_burst;
assign RAM_RADR = (SELF_RD_ACC_START & ~w_rd_wait_start)      ? S_AXI_ARADDR:
                  ((r_rd_state == P_RD_WAIT) & w_rd_wait_end) ? r_araddr_lat:
                                                                r_ram_radr_burst;

assign RAM_RBTEN = (SELF_RD_ACC_START & ~w_rd_wait_start)      ? r_axi_rbten:
                   ((r_rd_state == P_RD_WAIT) & w_rd_wait_end) ? r_rbten_lat:
                                                                 r_ram_rbten;

assign PF_SRCH_VAL = (SELF_RD_ACC_START & ~w_rd_wait_start & ~|S_AXI_ARLEN &
                      ((PF_MODE_SEL[0] & S_AXI_ARPROT[2]) |
                       (PF_MODE_SEL[1] & ~S_AXI_ARPROT[2] & (S_AXI_ARSIZE == P_BANK_W)))) |
                     ((r_rd_state == P_RD_WAIT) & w_rd_wait_end & ~|r_arlen_lat &
                      ((PF_MODE_SEL[0] & r_arprot_lat[2]) |
                       (PF_MODE_SEL[1] & ~r_arprot_lat[2] & &r_ram_rbten)));

always @ (posedge S_AXI_ACLK or negedge S_AXI_ARESETN) begin
  if (!S_AXI_ARESETN) begin
    r_pf_val_lat  <= 0;
    r_pf_data_lat <= 0;
    r_pre_val_lat <= 0;
  end else begin
    if (~S_AXI_RREADY) begin
      if (PF_RD_VAL) begin
        r_pf_val_lat  <= 1'b1;
        r_pf_data_lat <= r_ram_rdata_rbten;
      end
      if (r_pre_rvalid)
        r_pre_val_lat <= 1'b1;
    end else begin
      r_pf_val_lat  <= 0;
      r_pf_data_lat <= 0;
      r_pre_val_lat <= 0;
    end
  end
end

assign S_AXI_RVALID = PF_RD_VAL | r_pf_val_lat | r_pre_rvalid | r_pre_val_lat;
assign S_AXI_RID    = (PF_RD_VAL | r_pf_val_lat) ? r_arid_lat:
                                                   r_pre_rid;
assign S_AXI_RDATA  = (PF_RD_VAL)    ? r_ram_rdata_rbten:
                      (r_pf_val_lat) ? r_pf_data_lat:
                                       r_pre_rdata;
assign S_AXI_RLAST  = PF_RD_VAL | r_pf_val_lat | r_pre_rlast;

endmodule
