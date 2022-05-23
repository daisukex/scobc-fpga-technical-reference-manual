//-----------------------------------------------
// Module: sc_hrmem_ahb_sram_ctrl_vsaxi
//  Space Cubics AHB StaticRAM Controller (Arbitration with AXI Contorller)
//-----------------------------------------------
// Copyright © 2022 Space Cubics, LLC.
//-----------------------------------------------
module sc_hrmem_ahb_sram_ctrl_vsaxi # (
  parameter P_AHB_AD_W = 22,
  parameter P_DT_W     = 32,
  parameter P_BANK_W   = 2,
  parameter P_RD_LTCY  = 3,
  parameter P_H_PRIO   = 1
) (
  // System Interface
  input                       HCLK,
  input                       HRESETN,
  input                       RAM_INIT_DONE,

  // AHB Slave Interface
  input                       HSEL,
  input      [P_AHB_AD_W-1:0] HADDR,
  input      [1:0]            HTRANS,
  input      [2:0]            HSIZE,
  input      [2:0]            HBURST,
  input                       HWRITE,
  input      [3:0]            HPROT,
  input      [P_DT_W-1:0]     HWDATA,
  output     [P_DT_W-1:0]     HRDATA,
  output     [1:0]            HRESP,
  input                       HREADYIN,
  output                      HREADYOUT,

  // Other AHB SRAM Controller Interface
  output                      SELF_WR_ACC_START,
  output reg                  SELF_WR_ACC_BUSY,
  output                      SELF_WR_ACC_END,
  output                      SELF_RD_ACC_START,
  output reg                  SELF_RD_ACC_BUSY,
  output                      SELF_RD_ACC_END,
  output reg [2:0]            SELF_STATE,
  output reg                  SELF_BURST_EN,
  output                      SELF_ST_BURST,
  input                       OTHER_WR_ACC_START,
  input                       OTHER_WR_ACC_BUSY,
  input                       OTHER_WR_ACC_END,
  input      [2:0]            OTHER_WR_STATE,
  input                       OTHER_WR_BURST_EN,
  input                       OTHER_RD_ACC_START,
  input                       OTHER_RD_ACC_BUSY,
  input                       OTHER_RD_ACC_END,
  input      [1:0]            OTHER_RD_STATE,
  input                       OTHER_RD_BURST_EN,
  input                       OTHER_RD_ST_BURST,

  // Prefetch Controller Interface
  input      [1:0]            PF_MODE_SEL,
  output                      PF_SRCH_VAL,
  input                       PF_RD_VAL,
  input                       PF_RWAIT,
  output                      PF_RD_DT_MSK,
  input                       PF_ACC_VAL,
  input      [P_AHB_AD_W-1:0] PF_ACC_ADR,

  // RAM Interface
  output reg                  RAM_WEN,
  output reg [P_AHB_AD_W-1:0] RAM_WADR,
  output reg [P_DT_W-1:0]     RAM_WDATA,
  output reg [P_DT_W/8-1:0]   RAM_WBTEN,
  output                      RAM_REN,
  output     [P_AHB_AD_W-1:0] RAM_RADR,
  output     [P_DT_W/8-1:0]   RAM_RBTEN,
  input                       RAM_RDT_VAL,
  input      [P_DT_W-1:0]     RAM_RDATA
);

wire                 w_hready;

wire                 w_self_acc_start;

reg [1:0]            r_htrans_p1;
reg                  r_self_wr_acc_end_p1;
reg                  r_self_wr_acc_end_p2;
reg                  r_self_wr_acc_end_p3;
reg                  r_other_wr_acc_end_p1;
reg                  r_other_wr_acc_end_p2;
reg [P_RD_LTCY-1:0]  r_self_rd_b_acc_end_p;
reg [P_RD_LTCY-2:0]  r_self_rd_after_b_st_p;
reg [P_RD_LTCY-2:0]  r_self_rd_busy_p;
reg                  r_self_rd_burst_dt_msk;
reg                  r_other_rd_burst_en_p1;
reg [1:0]            r_other_rd_state_p1;

wire                 w_wr2rd_wait;

reg [P_AHB_AD_W-1:0] r_haddr_lat;
reg [2:0]            r_hsize_lat;
reg [2:0]            r_hburst_lat;
reg                  r_hwrite_lat;
reg [3:0]            r_hprot_lat;

wire                 w_wait_flg;
wire                 w_wait_end;

reg                  r_pre_rdyout;
reg [P_DT_W-1:0]     r_pre_rdata;
reg                  r_pf_wait_end_lat;
reg                  r_mstbusy_wait;

reg [P_DT_W-1:0]     r_ram_rdata_rbten;

wire                 w_pf_acc_wait;

wire                 w_rdff_write;
wire                 w_rdff_read;

reg [7:0]            r_rdff_w_pntr;
reg [7:0]            r_rdff_r_pntr;
reg                  r_rdff_amfull;
reg                  r_rdff_r_mask;
wire                 w_rdff_val;

reg [P_DT_W-1:0]     r_ram_rdata_ff [0:P_RD_LTCY*2-1];

reg                  r_pf_acc_wait_lat;
reg                  r_pf_acc_wait_lat_p1;

reg                  r_ram_rstart;
reg                  r_ram_ren_burst;
reg [P_AHB_AD_W-1:0] r_ram_radr_burst;
reg [P_DT_W/8-1:0]   r_ram_rbten;

reg [P_DT_W/8-1:0]   r_ahb_rbten;
reg [P_DT_W/8-1:0]   r_rbten_lat;

reg                  r_pf_val_lat;
reg [P_DT_W-1:0]     r_pf_data_lat;

reg                  r_by2nsq_rdt_lat_en;
reg [P_DT_W-1:0]     r_by2nsq_rdt_lat_val;

integer i;
genvar gn;

// Self State
parameter P_IDLE       = 3'h0,
          P_WAIT_CONF  = 3'h1,
          P_WR_DATA    = 3'h2,
          P_WR_RESP    = 3'h3,
          P_WAIT_WR2RD = 3'h4,
          P_RD_DATA    = 3'h5,
          P_RD_RESP    = 3'h6,
          P_RD_PFER    = 3'h7;

// Other State
parameter P_WR_IDLE = 3'h0,
          P_WR_ADR  = 3'h1,
          P_WR_DAT  = 3'h2,
          P_WR_WAIT = 3'h3,
          P_WR_RSP  = 3'h4;

parameter P_RD_IDLE = 2'h0,
          P_RD_WAIT = 2'h1,
          P_RD_READ = 2'h2,
          P_RD_PFRD = 2'h3;

assign w_hready = HREADYIN & HREADYOUT;

assign w_self_acc_start = ((SELF_STATE == P_IDLE) | SELF_WR_ACC_END | SELF_RD_ACC_END) &
                          HSEL & (HTRANS == 2'b10) & w_hready;
assign SELF_WR_ACC_START = w_self_acc_start & HWRITE;
assign SELF_RD_ACC_START = w_self_acc_start & ~HWRITE;
assign SELF_WR_ACC_END = ~HTRANS[0] & w_hready & (SELF_STATE == P_WR_RESP);
assign SELF_RD_ACC_END = ~HTRANS[0] & w_hready & ((SELF_STATE == P_RD_RESP) | PF_RD_VAL | r_pf_val_lat);

always @ (posedge HCLK or negedge HRESETN) begin
  if (!HRESETN) begin
    r_htrans_p1            <= 0;
    r_self_wr_acc_end_p1   <= 0;
    r_self_wr_acc_end_p2   <= 0;
    r_self_wr_acc_end_p3   <= 0;
    r_other_wr_acc_end_p1  <= 0;
    r_other_wr_acc_end_p2  <= 0;
    r_self_rd_b_acc_end_p  <= 0;
    r_self_rd_after_b_st_p <= 0;
    r_self_rd_busy_p       <= 0;
    r_self_rd_burst_dt_msk <= 0;
    r_other_rd_burst_en_p1 <= 0;
    r_other_rd_state_p1    <= 0;
  end
  else begin
    r_htrans_p1            <= HTRANS;
    r_self_wr_acc_end_p1   <= SELF_WR_ACC_END;
    r_self_wr_acc_end_p2   <= r_self_wr_acc_end_p1;
    r_self_wr_acc_end_p3   <= r_self_wr_acc_end_p2;
    r_other_wr_acc_end_p1  <= OTHER_WR_ACC_END;
    r_other_wr_acc_end_p2  <= r_other_wr_acc_end_p1;
    r_self_rd_b_acc_end_p  <= {r_self_rd_b_acc_end_p[P_RD_LTCY-2:0], SELF_RD_ACC_END & SELF_BURST_EN};
    r_self_rd_after_b_st_p <= {r_self_rd_after_b_st_p[P_RD_LTCY-3:0],
                               SELF_RD_ACC_START & ~w_wait_flg & ~w_wr2rd_wait & ~PF_SRCH_VAL};
    r_self_rd_busy_p       <= {r_self_rd_busy_p[P_RD_LTCY-3:0], RAM_REN & (HTRANS == 2'b01) & r_htrans_p1[1]};
    r_self_rd_burst_dt_msk <= ((SELF_RD_ACC_END & SELF_BURST_EN) | |r_self_rd_b_acc_end_p) &
                              ~(r_self_rd_after_b_st_p[P_RD_LTCY-2] | r_self_rd_busy_p[P_RD_LTCY-2]);
    r_other_rd_burst_en_p1 <= OTHER_RD_BURST_EN;
    r_other_rd_state_p1    <= OTHER_RD_STATE;
  end
end

assign PF_RD_DT_MSK = r_self_rd_burst_dt_msk;

assign w_wr2rd_wait = SELF_WR_ACC_END  | r_self_wr_acc_end_p1  | r_self_wr_acc_end_p2 |
                      OTHER_WR_ACC_END | r_other_wr_acc_end_p1;

always @ (posedge HCLK or negedge HRESETN) begin
  if (!HRESETN) begin
    SELF_BURST_EN    <= 0;
    SELF_WR_ACC_BUSY <= 0;
    SELF_RD_ACC_BUSY <= 0;
  end
  else begin
    if (w_self_acc_start)
      SELF_BURST_EN <= |HBURST;
    else if (SELF_WR_ACC_END | SELF_RD_ACC_END)
      SELF_BURST_EN <= 0;
    if (SELF_WR_ACC_START)
      SELF_WR_ACC_BUSY <= 1'b1;
    else if (SELF_WR_ACC_END)
      SELF_WR_ACC_BUSY <= 0;
    if (SELF_RD_ACC_START)
      SELF_RD_ACC_BUSY <= 1'b1;
    else if (SELF_RD_ACC_END)
      SELF_RD_ACC_BUSY <= 0;
  end
end

assign SELF_ST_BURST = |HBURST;

always @ (posedge HCLK or negedge HRESETN) begin
  if (!HRESETN) begin
    r_haddr_lat  <= 0;
    r_hsize_lat  <= 0;
    r_hburst_lat <= 0;
    r_hwrite_lat <= 0;
    r_hprot_lat  <= 0;
  end
  else begin
    if (HSEL & HTRANS[1] & w_hready) begin
      r_haddr_lat  <= HADDR;
      r_hsize_lat  <= HSIZE;
      r_hburst_lat <= HBURST;
      r_hwrite_lat <= HWRITE;
      r_hprot_lat  <= HPROT;
    end
  end
end

assign w_wait_flg = ((P_H_PRIO == 0) &
                     ((SELF_WR_ACC_START & OTHER_WR_ACC_START) | (SELF_RD_ACC_START & OTHER_RD_ACC_START))) |
                    (SELF_WR_ACC_START &
                     ((OTHER_WR_ACC_BUSY & ~((OTHER_WR_STATE == P_WR_RSP) | OTHER_WR_ACC_END)) |
                      (OTHER_RD_ACC_START & (OTHER_RD_ST_BURST | r_other_wr_acc_end_p1 |
                                             r_self_wr_acc_end_p1 | r_self_wr_acc_end_p2)) |
                      (OTHER_RD_STATE == P_RD_WAIT) |
                      ((OTHER_RD_STATE == P_RD_READ) & OTHER_RD_BURST_EN & ~OTHER_RD_ACC_END) |
                      PF_RWAIT)) |
                    (SELF_RD_ACC_START & ((OTHER_WR_ACC_BUSY | r_other_wr_acc_end_p1) |
                                          (OTHER_RD_ACC_BUSY & ~OTHER_RD_ACC_END)));

assign w_wait_end = (SELF_WR_ACC_BUSY & ~OTHER_RD_BURST_EN &
                     ((((OTHER_WR_STATE == P_WR_RSP) | OTHER_WR_ACC_END) & (OTHER_RD_STATE != P_RD_WAIT)) |
                      ((OTHER_RD_STATE == P_RD_READ) & ~(OTHER_WR_ACC_BUSY & (OTHER_WR_STATE == P_WR_DAT))) |
                      ((((P_H_PRIO == 1) & (OTHER_WR_STATE == P_WR_WAIT)) | (OTHER_WR_STATE == P_WR_IDLE)) &
                       ~PF_RWAIT & ~SELF_RD_ACC_START & ((OTHER_RD_STATE == P_RD_IDLE) & ~OTHER_RD_ACC_START)))) |
                    (SELF_RD_ACC_BUSY & ~OTHER_WR_BURST_EN &
                     ~((OTHER_RD_STATE == P_RD_READ) & (r_other_rd_state_p1 == P_RD_WAIT)) &
                     (r_other_wr_acc_end_p2 |
                      (((OTHER_WR_STATE == P_WR_WAIT) | (OTHER_WR_STATE == P_WR_IDLE)) &
                       (((P_H_PRIO == 1) & ~(OTHER_RD_BURST_EN | r_other_rd_burst_en_p1)) |
                        (OTHER_RD_STATE == P_RD_IDLE))) |
                      (r_self_wr_acc_end_p3 & (((P_H_PRIO == 1) | (OTHER_RD_STATE == P_RD_IDLE)) &
                                               (OTHER_WR_STATE != P_WR_DAT))))) |
                    (OTHER_RD_ACC_END & ~(OTHER_WR_ACC_BUSY & (OTHER_WR_STATE == P_WR_DAT))) |
                    (((SELF_WR_ACC_BUSY & (P_H_PRIO == 1) & (OTHER_WR_STATE == P_WR_WAIT)) |
                      (OTHER_WR_STATE == P_WR_IDLE)) &
                     ((SELF_RD_ACC_BUSY & (P_H_PRIO == 1) & (OTHER_RD_STATE == P_RD_WAIT)) |
                      (OTHER_RD_STATE == P_RD_IDLE)) &
                     (SELF_RD_ACC_BUSY | ~PF_RWAIT));

always @ (posedge HCLK or negedge HRESETN) begin
  if (!HRESETN) begin
    r_pre_rdyout      <= 0;
    RAM_WEN           <= 0;
    RAM_WADR          <= 0;
    RAM_WDATA         <= 0;
    RAM_WBTEN         <= 0;
    r_pre_rdata       <= 0;
    r_pf_wait_end_lat <= 0;
    r_mstbusy_wait    <= 0;
    SELF_STATE        <= P_IDLE;
  end
  else begin
    if (~RAM_INIT_DONE) begin
      r_pre_rdyout      <= 0;
      RAM_WEN           <= 0;
      RAM_WADR          <= 0;
      RAM_WDATA         <= 0;
      RAM_WBTEN         <= 0;
      r_pre_rdata       <= 0;
      r_pf_wait_end_lat <= 0;
      r_mstbusy_wait    <= 0;
      SELF_STATE        <= P_IDLE;
    end
    else begin
      case (SELF_STATE)
        P_IDLE : begin
          r_pre_rdyout      <= 1'b1;
          RAM_WEN           <= 0;
          RAM_WADR          <= 0;
          RAM_WDATA         <= 0;
          RAM_WBTEN         <= 0;
          r_pre_rdata       <= 0;
          r_pf_wait_end_lat <= 0;
          r_mstbusy_wait    <= 0;
          if (w_self_acc_start) begin
            r_pre_rdyout <= 0;
            if (w_wait_flg)
              SELF_STATE <= P_WAIT_CONF;
            else if (HWRITE)
              SELF_STATE <= P_WR_DATA;
            else if (w_wr2rd_wait)
              SELF_STATE <= P_WAIT_WR2RD;
            else if (PF_SRCH_VAL)
              SELF_STATE <= P_RD_PFER;
            else
              SELF_STATE <= P_RD_DATA;
          end
        end
        P_WAIT_CONF : begin
          if (PF_RWAIT) begin
            if (w_wait_end & r_hwrite_lat)
              r_pf_wait_end_lat <= 1'b1;
          end else if (~w_wait_flg) begin
            r_pf_wait_end_lat <= 0;
          end
          if ((w_wait_end | (r_pf_wait_end_lat & ~w_wait_flg)) &
              ~(r_hwrite_lat & PF_RWAIT)) begin
            if (r_hwrite_lat)
              SELF_STATE <= P_WR_DATA;
            else if (w_wr2rd_wait)
              SELF_STATE <= P_WAIT_WR2RD;
            else if (PF_SRCH_VAL)
              SELF_STATE <= P_RD_PFER;
            else
              SELF_STATE <= P_RD_DATA;
          end
        end
        P_WR_DATA : begin
          r_pre_rdyout <= 1'b1;
          if (~r_mstbusy_wait) begin
            RAM_WEN      <= 1'b1;
            RAM_WDATA    <= HWDATA;
            RAM_WADR     <= r_haddr_lat;
            if ((1 << r_hsize_lat) > (P_DT_W/8)) begin
              RAM_WBTEN <= {(P_DT_W/8){1'b1}};
            end
            else begin
              case (r_hsize_lat)
                0:       RAM_WBTEN <= (  {1{1'b1}} << r_haddr_lat[P_BANK_W-1:0]);
                1:       RAM_WBTEN <= (  {2{1'b1}} << r_haddr_lat[P_BANK_W-1:0]);
                2:       RAM_WBTEN <= (  {4{1'b1}} << r_haddr_lat[P_BANK_W-1:0]);
                3:       RAM_WBTEN <= (  {8{1'b1}} << r_haddr_lat[P_BANK_W-1:0]);
                4:       RAM_WBTEN <= ( {16{1'b1}} << r_haddr_lat[P_BANK_W-1:0]);
                5:       RAM_WBTEN <= ( {32{1'b1}} << r_haddr_lat[P_BANK_W-1:0]);
                6:       RAM_WBTEN <= ( {64{1'b1}} << r_haddr_lat[P_BANK_W-1:0]);
                default: RAM_WBTEN <= ({128{1'b1}} << r_haddr_lat[P_BANK_W-1:0]);
              endcase
            end
          end
          SELF_STATE <= P_WR_RESP;
        end
        P_WR_RESP : begin
          RAM_WEN   <= 0;
          RAM_WADR  <= 0;
          RAM_WDATA <= 0;
          RAM_WBTEN <= 0;
          if (~(r_mstbusy_wait & (HTRANS == 2'b01))) begin
            r_mstbusy_wait <= 0;
            if (SELF_WR_ACC_END) begin
              if (w_self_acc_start) begin
                r_pre_rdyout <= 0;
                if (w_wait_flg)
                  SELF_STATE <= P_WAIT_CONF;
                else if (HWRITE)
                  SELF_STATE <= P_WR_DATA;
                else if (w_wr2rd_wait)
                  SELF_STATE <= P_WAIT_WR2RD;
                else if (PF_SRCH_VAL)
                  SELF_STATE <= P_RD_PFER;
                else
                  SELF_STATE <= P_RD_DATA;
              end
              else begin
                r_pre_rdyout <= 1'b1;
                SELF_STATE   <= P_IDLE;
              end
            end
            else begin
              r_pre_rdyout  <= 0;
              SELF_STATE    <= P_WR_DATA;
            end
          end
          if (HTRANS == 2'b01)
            r_mstbusy_wait <= 1'b1;
        end
        P_WAIT_WR2RD : begin
          if (~w_wr2rd_wait) begin
            if (PF_SRCH_VAL)
              SELF_STATE <= P_RD_PFER;
            else
              SELF_STATE <= P_RD_DATA;
          end
        end
        P_RD_DATA : begin
          if ((RAM_RDT_VAL & ~(r_self_rd_burst_dt_msk | (~w_rdff_val & w_rdff_write))) |
              w_rdff_read | (r_mstbusy_wait & HREADYIN)) begin
            r_pre_rdyout <= 1'b1;
            if (~(r_mstbusy_wait & (HTRANS == 2'b01))) begin
              r_mstbusy_wait <= 0;
              if (w_rdff_val)
                r_pre_rdata <= r_ram_rdata_ff[r_rdff_r_pntr];
              else
                r_pre_rdata <= r_ram_rdata_rbten;
              SELF_STATE <= P_RD_RESP;
            end
          end
        end
        P_RD_RESP : begin
          r_pre_rdata <= 0;
          if (~(r_mstbusy_wait & (HTRANS == 2'b01))) begin
            r_mstbusy_wait <= 0;
            if (SELF_RD_ACC_END) begin
              if (w_self_acc_start) begin
                r_pre_rdyout <= 0;
                if (w_wait_flg)
                  SELF_STATE <= P_WAIT_CONF;
                else if (HWRITE)
                  SELF_STATE <= P_WR_DATA;
                else if (w_wr2rd_wait)
                  SELF_STATE <= P_WAIT_WR2RD;
                else if (PF_SRCH_VAL)
                  SELF_STATE <= P_RD_PFER;
                else
                  SELF_STATE <= P_RD_DATA;
              end
              else begin
                if (SELF_BURST_EN)
                  r_pre_rdyout <= 0;
                SELF_STATE   <= P_IDLE;
              end
            end
            else begin
              r_pre_rdyout  <= 0;
              SELF_STATE    <= P_RD_DATA;
            end
          end
          if (HTRANS == 2'b01)
            r_mstbusy_wait <= 1'b1;
        end
        P_RD_PFER : begin
          if (w_hready) begin
            if (w_self_acc_start) begin
              r_pre_rdyout <= 0;
              if (w_wait_flg)
                SELF_STATE <= P_WAIT_CONF;
              else if (HWRITE)
                SELF_STATE <= P_WR_DATA;
              else if (w_wr2rd_wait)
                SELF_STATE <= P_WAIT_WR2RD;
              else if (PF_SRCH_VAL)
                SELF_STATE <= P_RD_PFER;
              else
                SELF_STATE <= P_RD_DATA;
            end
            else begin
              r_pre_rdyout <= 1'b1;
              SELF_STATE   <= P_IDLE;
            end
          end
        end
        default : begin
          r_pre_rdyout      <= 1'b1;
          RAM_WEN           <= 0;
          RAM_WADR          <= 0;
          RAM_WDATA         <= 0;
          RAM_WBTEN         <= 0;
          r_pre_rdata       <= 0;
          r_pf_wait_end_lat <= 0;
          r_mstbusy_wait    <= 0;
          SELF_STATE        <= P_IDLE;
        end
      endcase
    end
  end
end

assign HRESP = 2'b00;
assign HREADYOUT = ((r_pre_rdyout & ~w_pf_acc_wait) | PF_RD_VAL) & ~((HTRANS == 2'b10) & (r_htrans_p1 == 2'b01));

always @ (*) begin
  for (i=0; i<P_DT_W/8; i=i+1) begin
    r_ram_rdata_rbten[i*8 +: 8] = RAM_RDATA[i*8 +: 8] & {8{r_ram_rbten[i]}};
  end
end

assign w_pf_acc_wait = PF_ACC_VAL;

assign w_rdff_write = (((SELF_STATE == P_RD_DATA) & (~HREADYIN | r_mstbusy_wait | w_rdff_val)) |
                       (SELF_STATE == P_RD_RESP)) &
                      (RAM_RDT_VAL & ~r_self_rd_burst_dt_msk);
assign w_rdff_read  = (SELF_STATE == P_RD_DATA) & HREADYIN & ~(r_mstbusy_wait & (HTRANS == 2'b01)) & w_rdff_val;

always @ (posedge HCLK or negedge HRESETN) begin
  if (!HRESETN) begin
    r_rdff_w_pntr <= 0;
    r_rdff_r_pntr <= 0;
    r_rdff_amfull <= 0;
    r_rdff_r_mask <= 0;
  end
  else begin
    if (SELF_RD_ACC_END) begin
      r_rdff_w_pntr <= 0;
      r_rdff_r_pntr <= 0;
      r_rdff_amfull <= 0;
      r_rdff_r_mask <= 0;
    end
    else begin
      if (w_rdff_write) begin
        if (r_rdff_w_pntr >= P_RD_LTCY*2-1)
          r_rdff_w_pntr <= 0;
        else
          r_rdff_w_pntr <= r_rdff_w_pntr + 8'h1;
      end
      if (w_rdff_read) begin
        if (r_rdff_r_pntr >= P_RD_LTCY*2-1)
          r_rdff_r_pntr <= 0;
        else
          r_rdff_r_pntr <= r_rdff_r_pntr + 8'h1;
      end
      if (w_rdff_write & ~w_rdff_read) begin
        if ((r_rdff_w_pntr + P_RD_LTCY == r_rdff_r_pntr) |
            (r_rdff_w_pntr == r_rdff_r_pntr + P_RD_LTCY))
          r_rdff_amfull <= 1'b1;
      end
      else if (w_rdff_read & ~w_rdff_write) begin
        if ((r_rdff_w_pntr + P_RD_LTCY - 8'h1 == r_rdff_r_pntr) |
            (r_rdff_w_pntr == r_rdff_r_pntr + P_RD_LTCY + 8'h1))
          r_rdff_amfull <= 0;
      end
      if (HTRANS == 2'b01) begin
        if (SELF_STATE == P_RD_RESP)
          r_rdff_r_mask <= 1'b1;
      end
      else if (w_hready)
        r_rdff_r_mask <= 0;
    end
  end
end

assign w_rdff_val = ((r_rdff_w_pntr != r_rdff_r_pntr) | r_rdff_amfull) &
                    ~(r_rdff_r_mask & ~((HTRANS != 2'b01) & w_hready));

generate
  for(gn=0; gn<P_RD_LTCY*2; gn=gn+1) begin : ram_rdata_ff_gen
    always @ (posedge HCLK or negedge HRESETN) begin
      if (!HRESETN) begin
        r_ram_rdata_ff[gn] <= 0;
      end
      else begin
        if (SELF_STATE == P_IDLE) begin
          r_ram_rdata_ff[gn] <= 0;
        end
        else begin
          if (w_rdff_write) begin
            if (r_rdff_w_pntr== gn)
              r_ram_rdata_ff[gn] <= r_ram_rdata_rbten;
          end
        end
      end
    end
  end
endgenerate

always @ (posedge HCLK or negedge HRESETN) begin
  if (!HRESETN) begin
    r_pf_acc_wait_lat    <= 0;
    r_pf_acc_wait_lat_p1 <= 0;
  end
  else begin
    r_pf_acc_wait_lat_p1 <= r_pf_acc_wait_lat;
    if (w_pf_acc_wait) begin
      if ((SELF_STATE == P_WAIT_CONF) & OTHER_RD_ACC_END)
        r_pf_acc_wait_lat <= 1'b1;
    end
    else begin
      r_pf_acc_wait_lat <= 0;
    end
  end
end

always @ (posedge HCLK or negedge HRESETN) begin
  if (!HRESETN) begin
     r_ram_rstart     <= 0;
     r_ram_ren_burst  <= 0;
     r_ram_radr_burst <= 0;
     r_ram_rbten      <= 0;
  end
  else begin
    if ((SELF_STATE == P_IDLE) | ((SELF_STATE == P_WAIT_CONF) & ~r_hwrite_lat) |
        (((SELF_STATE == P_WR_RESP) | (SELF_STATE == P_RD_RESP) | PF_RD_VAL) & (HTRANS == 2'b10)) |
        (SELF_STATE == P_WAIT_WR2RD)) begin
      r_ram_rstart     <= 0;
      r_ram_ren_burst  <= 0;
      r_ram_radr_burst <= 0;
      if (SELF_STATE == P_IDLE)
        r_ram_rbten       <= 0;
      if (SELF_RD_ACC_START) begin
        if ((1 << HSIZE) > (P_DT_W/8)) begin
          r_ram_rbten <= {(P_DT_W/8){1'b1}};
        end
        else begin
          case (HSIZE)
            0:       r_ram_rbten <=   {1{1'b1}} << HADDR[P_BANK_W-1:0];
            1:       r_ram_rbten <=   {2{1'b1}} << HADDR[P_BANK_W-1:0];
            2:       r_ram_rbten <=   {4{1'b1}} << HADDR[P_BANK_W-1:0];
            3:       r_ram_rbten <=   {8{1'b1}} << HADDR[P_BANK_W-1:0];
            4:       r_ram_rbten <=  {16{1'b1}} << HADDR[P_BANK_W-1:0];
            5:       r_ram_rbten <=  {32{1'b1}} << HADDR[P_BANK_W-1:0];
            6:       r_ram_rbten <=  {64{1'b1}} << HADDR[P_BANK_W-1:0];
            default: r_ram_rbten <= {128{1'b1}} << HADDR[P_BANK_W-1:0];
          endcase
        end
      end
      if (SELF_RD_ACC_START & |HBURST & ~w_wait_flg) begin
        r_ram_rstart <= 1'b1;
        if (HBURST[0]) begin
          r_ram_radr_burst <= HADDR + (1 << HSIZE);
        end
        else begin
          if (HBURST[2:1] == 2'b01 & (&HADDR[HSIZE +: 2])) begin
            case (HSIZE)
              0:       r_ram_radr_burst <= {HADDR[P_AHB_AD_W-1:2], {2{1'b0}}};
              1:       r_ram_radr_burst <= {HADDR[P_AHB_AD_W-1:3], {3{1'b0}}};
              2:       r_ram_radr_burst <= {HADDR[P_AHB_AD_W-1:4], {4{1'b0}}};
              3:       r_ram_radr_burst <= {HADDR[P_AHB_AD_W-1:5], {5{1'b0}}};
              4:       r_ram_radr_burst <= {HADDR[P_AHB_AD_W-1:6], {6{1'b0}}};
              5:       r_ram_radr_burst <= {HADDR[P_AHB_AD_W-1:7], {7{1'b0}}};
              6:       r_ram_radr_burst <= {HADDR[P_AHB_AD_W-1:8], {8{1'b0}}};
              default: r_ram_radr_burst <= {HADDR[P_AHB_AD_W-1:9], {9{1'b0}}};
            endcase
          end
          else if (HBURST[2:1] == 2'b10 & (&HADDR[HSIZE +: 3])) begin
            case (HSIZE)
              0:       r_ram_radr_burst <= {HADDR[P_AHB_AD_W-1: 3], { 3{1'b0}}};
              1:       r_ram_radr_burst <= {HADDR[P_AHB_AD_W-1: 4], { 4{1'b0}}};
              2:       r_ram_radr_burst <= {HADDR[P_AHB_AD_W-1: 5], { 5{1'b0}}};
              3:       r_ram_radr_burst <= {HADDR[P_AHB_AD_W-1: 6], { 6{1'b0}}};
              4:       r_ram_radr_burst <= {HADDR[P_AHB_AD_W-1: 7], { 7{1'b0}}};
              5:       r_ram_radr_burst <= {HADDR[P_AHB_AD_W-1: 8], { 8{1'b0}}};
              6:       r_ram_radr_burst <= {HADDR[P_AHB_AD_W-1: 9], { 9{1'b0}}};
              default: r_ram_radr_burst <= {HADDR[P_AHB_AD_W-1:10], {10{1'b0}}};
            endcase
          end
          else if (HBURST[2:1] == 2'b11 & (&HADDR[HSIZE +: 4])) begin
            case (HSIZE)
              0:       r_ram_radr_burst <= {HADDR[P_AHB_AD_W-1: 4], { 4{1'b0}}};
              1:       r_ram_radr_burst <= {HADDR[P_AHB_AD_W-1: 5], { 5{1'b0}}};
              2:       r_ram_radr_burst <= {HADDR[P_AHB_AD_W-1: 6], { 6{1'b0}}};
              3:       r_ram_radr_burst <= {HADDR[P_AHB_AD_W-1: 7], { 7{1'b0}}};
              4:       r_ram_radr_burst <= {HADDR[P_AHB_AD_W-1: 8], { 8{1'b0}}};
              5:       r_ram_radr_burst <= {HADDR[P_AHB_AD_W-1: 9], { 9{1'b0}}};
              6:       r_ram_radr_burst <= {HADDR[P_AHB_AD_W-1:10], {10{1'b0}}};
              default: r_ram_radr_burst <= {HADDR[P_AHB_AD_W-1:11], {11{1'b0}}};
            endcase
          end
          else
            r_ram_radr_burst <= HADDR + (1 << HSIZE);
        end
      end
      else if ((((SELF_STATE == P_WAIT_CONF) & ~r_hwrite_lat & w_wait_end) |
                (SELF_STATE == P_WAIT_WR2RD)) & ~w_wr2rd_wait & |r_hburst_lat) begin
        r_ram_rstart <= 1'b1;
        if (r_hburst_lat[0]) begin
          r_ram_radr_burst <= r_haddr_lat + (1 << r_hsize_lat);
        end
        else begin
          if (r_hburst_lat[2:1] == 2'b01 & (&r_haddr_lat[r_hsize_lat +: 2])) begin
            case (r_hsize_lat)
              0:       r_ram_radr_burst <= {r_haddr_lat[P_AHB_AD_W-1:2], {2{1'b0}}};
              1:       r_ram_radr_burst <= {r_haddr_lat[P_AHB_AD_W-1:3], {3{1'b0}}};
              2:       r_ram_radr_burst <= {r_haddr_lat[P_AHB_AD_W-1:4], {4{1'b0}}};
              3:       r_ram_radr_burst <= {r_haddr_lat[P_AHB_AD_W-1:5], {5{1'b0}}};
              4:       r_ram_radr_burst <= {r_haddr_lat[P_AHB_AD_W-1:6], {6{1'b0}}};
              5:       r_ram_radr_burst <= {r_haddr_lat[P_AHB_AD_W-1:7], {7{1'b0}}};
              6:       r_ram_radr_burst <= {r_haddr_lat[P_AHB_AD_W-1:8], {8{1'b0}}};
              default: r_ram_radr_burst <= {r_haddr_lat[P_AHB_AD_W-1:9], {9{1'b0}}};
            endcase
          end
          else if (r_hburst_lat[2:1] == 2'b10 & (&r_haddr_lat[r_hsize_lat +: 3])) begin
            case (r_hsize_lat)
              0:       r_ram_radr_burst <= {r_haddr_lat[P_AHB_AD_W-1: 3], { 3{1'b0}}};
              1:       r_ram_radr_burst <= {r_haddr_lat[P_AHB_AD_W-1: 4], { 4{1'b0}}};
              2:       r_ram_radr_burst <= {r_haddr_lat[P_AHB_AD_W-1: 5], { 5{1'b0}}};
              3:       r_ram_radr_burst <= {r_haddr_lat[P_AHB_AD_W-1: 6], { 6{1'b0}}};
              4:       r_ram_radr_burst <= {r_haddr_lat[P_AHB_AD_W-1: 7], { 7{1'b0}}};
              5:       r_ram_radr_burst <= {r_haddr_lat[P_AHB_AD_W-1: 8], { 8{1'b0}}};
              6:       r_ram_radr_burst <= {r_haddr_lat[P_AHB_AD_W-1: 9], { 9{1'b0}}};
              default: r_ram_radr_burst <= {r_haddr_lat[P_AHB_AD_W-1:10], {10{1'b0}}};
            endcase
          end
          else if (r_hburst_lat[2:1] == 2'b11 & (&r_haddr_lat[r_hsize_lat +: 4])) begin
            case (r_hsize_lat)
              0:       r_ram_radr_burst <= {r_haddr_lat[P_AHB_AD_W-1: 4], { 4{1'b0}}};
              1:       r_ram_radr_burst <= {r_haddr_lat[P_AHB_AD_W-1: 5], { 5{1'b0}}};
              2:       r_ram_radr_burst <= {r_haddr_lat[P_AHB_AD_W-1: 6], { 6{1'b0}}};
              3:       r_ram_radr_burst <= {r_haddr_lat[P_AHB_AD_W-1: 7], { 7{1'b0}}};
              4:       r_ram_radr_burst <= {r_haddr_lat[P_AHB_AD_W-1: 8], { 8{1'b0}}};
              5:       r_ram_radr_burst <= {r_haddr_lat[P_AHB_AD_W-1: 9], { 9{1'b0}}};
              6:       r_ram_radr_burst <= {r_haddr_lat[P_AHB_AD_W-1:10], {10{1'b0}}};
              default: r_ram_radr_burst <= {r_haddr_lat[P_AHB_AD_W-1:11], {11{1'b0}}};
            endcase
          end
          else
            r_ram_radr_burst <= r_haddr_lat + (1 << r_hsize_lat);
        end
      end
    end
    else if (((SELF_STATE == P_RD_DATA) | (SELF_STATE == P_RD_RESP)) &
             (~r_rdff_amfull | r_ram_ren_burst)) begin
      if (r_ram_rstart) begin
        if (SELF_RD_ACC_END) begin
          r_ram_ren_burst  <= 0;
          r_ram_rstart     <= 0;
          r_ram_radr_burst <= 0;
        end
        else if (r_ram_ren_burst) begin
          r_ram_ren_burst <= 0;
          if (r_hburst_lat[0]) begin
            r_ram_radr_burst <= r_ram_radr_burst + (1 << r_hsize_lat);
          end
          else begin
            if (r_hburst_lat[2:1] == 2'b01 & (&r_ram_radr_burst[r_hsize_lat +: 2])) begin
              case (r_hsize_lat)
                0:       r_ram_radr_burst <= {r_ram_radr_burst[P_AHB_AD_W-1:2], {2{1'b0}}};
                1:       r_ram_radr_burst <= {r_ram_radr_burst[P_AHB_AD_W-1:3], {3{1'b0}}};
                2:       r_ram_radr_burst <= {r_ram_radr_burst[P_AHB_AD_W-1:4], {4{1'b0}}};
                3:       r_ram_radr_burst <= {r_ram_radr_burst[P_AHB_AD_W-1:5], {5{1'b0}}};
                4:       r_ram_radr_burst <= {r_ram_radr_burst[P_AHB_AD_W-1:6], {6{1'b0}}};
                5:       r_ram_radr_burst <= {r_ram_radr_burst[P_AHB_AD_W-1:7], {7{1'b0}}};
                6:       r_ram_radr_burst <= {r_ram_radr_burst[P_AHB_AD_W-1:8], {8{1'b0}}};
                default: r_ram_radr_burst <= {r_ram_radr_burst[P_AHB_AD_W-1:9], {9{1'b0}}};
              endcase
            end
            else if (r_hburst_lat[2:1] == 2'b10 & (&r_ram_radr_burst[r_hsize_lat +: 3])) begin
              case (r_hsize_lat)
                0:       r_ram_radr_burst <= {r_ram_radr_burst[P_AHB_AD_W-1: 3], { 3{1'b0}}};
                1:       r_ram_radr_burst <= {r_ram_radr_burst[P_AHB_AD_W-1: 4], { 4{1'b0}}};
                2:       r_ram_radr_burst <= {r_ram_radr_burst[P_AHB_AD_W-1: 5], { 5{1'b0}}};
                3:       r_ram_radr_burst <= {r_ram_radr_burst[P_AHB_AD_W-1: 6], { 6{1'b0}}};
                4:       r_ram_radr_burst <= {r_ram_radr_burst[P_AHB_AD_W-1: 7], { 7{1'b0}}};
                5:       r_ram_radr_burst <= {r_ram_radr_burst[P_AHB_AD_W-1: 8], { 8{1'b0}}};
                6:       r_ram_radr_burst <= {r_ram_radr_burst[P_AHB_AD_W-1: 9], { 9{1'b0}}};
                default: r_ram_radr_burst <= {r_ram_radr_burst[P_AHB_AD_W-1:10], {10{1'b0}}};
              endcase
            end
            else if (r_hburst_lat[2:1] == 2'b11 & (&r_ram_radr_burst[r_hsize_lat +: 4])) begin
              case (r_hsize_lat)
                0:       r_ram_radr_burst <= {r_ram_radr_burst[P_AHB_AD_W-1: 4], { 4{1'b0}}};
                1:       r_ram_radr_burst <= {r_ram_radr_burst[P_AHB_AD_W-1: 5], { 5{1'b0}}};
                2:       r_ram_radr_burst <= {r_ram_radr_burst[P_AHB_AD_W-1: 6], { 6{1'b0}}};
                3:       r_ram_radr_burst <= {r_ram_radr_burst[P_AHB_AD_W-1: 7], { 7{1'b0}}};
                4:       r_ram_radr_burst <= {r_ram_radr_burst[P_AHB_AD_W-1: 8], { 8{1'b0}}};
                5:       r_ram_radr_burst <= {r_ram_radr_burst[P_AHB_AD_W-1: 9], { 9{1'b0}}};
                6:       r_ram_radr_burst <= {r_ram_radr_burst[P_AHB_AD_W-1:10], {10{1'b0}}};
                default: r_ram_radr_burst <= {r_ram_radr_burst[P_AHB_AD_W-1:11], {11{1'b0}}};
              endcase
            end
            else
              r_ram_radr_burst <= r_ram_radr_burst + (1 << r_hsize_lat);
          end
        end
        else begin
          r_ram_ren_burst <= 1'b1;
        end
      end
    end
  end
end

always @ (*) begin
  if ((1 << HSIZE) > (P_DT_W/8)) begin
    r_ahb_rbten = {(P_DT_W/8){1'b1}};
  end
  else begin
    case (HSIZE)
      0:       r_ahb_rbten =   {1{1'b1}} << HADDR[P_BANK_W-1:0];
      1:       r_ahb_rbten =   {2{1'b1}} << HADDR[P_BANK_W-1:0];
      2:       r_ahb_rbten =   {4{1'b1}} << HADDR[P_BANK_W-1:0];
      3:       r_ahb_rbten =   {8{1'b1}} << HADDR[P_BANK_W-1:0];
      4:       r_ahb_rbten =  {16{1'b1}} << HADDR[P_BANK_W-1:0];
      5:       r_ahb_rbten =  {32{1'b1}} << HADDR[P_BANK_W-1:0];
      6:       r_ahb_rbten =  {64{1'b1}} << HADDR[P_BANK_W-1:0];
      default: r_ahb_rbten = {128{1'b1}} << HADDR[P_BANK_W-1:0];
    endcase
  end
end

always @ (*) begin
  if ((1 << r_hsize_lat) > (P_DT_W/8)) begin
    r_rbten_lat = {(P_DT_W/8){1'b1}};
  end
  else begin
    case (r_hsize_lat)
      0:       r_rbten_lat =   {1{1'b1}} << r_haddr_lat[P_BANK_W-1:0];
      1:       r_rbten_lat =   {2{1'b1}} << r_haddr_lat[P_BANK_W-1:0];
      2:       r_rbten_lat =   {4{1'b1}} << r_haddr_lat[P_BANK_W-1:0];
      3:       r_rbten_lat =   {8{1'b1}} << r_haddr_lat[P_BANK_W-1:0];
      4:       r_rbten_lat =  {16{1'b1}} << r_haddr_lat[P_BANK_W-1:0];
      5:       r_rbten_lat =  {32{1'b1}} << r_haddr_lat[P_BANK_W-1:0];
      6:       r_rbten_lat =  {64{1'b1}} << r_haddr_lat[P_BANK_W-1:0];
      default: r_rbten_lat = {128{1'b1}} << r_haddr_lat[P_BANK_W-1:0];
    endcase
  end
end

assign RAM_REN  = (SELF_RD_ACC_START & ~w_wait_flg & ~w_wr2rd_wait) |
                  ((((SELF_STATE == P_WAIT_CONF) & SELF_RD_ACC_BUSY & w_wait_end) |
                    (SELF_STATE == P_WAIT_WR2RD)) & ~w_wr2rd_wait) |
                  (r_ram_ren_burst & ~((HTRANS == 2'b10) & (r_htrans_p1 == 2'b11) & ~HREADYOUT));
assign RAM_RADR = (SELF_RD_ACC_START & ~w_wait_flg & ~w_wr2rd_wait)                 ? HADDR:
                  ((((SELF_STATE == P_WAIT_CONF) & SELF_RD_ACC_BUSY & w_wait_end) |
                    (SELF_STATE == P_WAIT_WR2RD)) & ~w_wr2rd_wait)                  ? r_haddr_lat:
                                                                                      r_ram_radr_burst;

assign RAM_RBTEN = (SELF_RD_ACC_START & ~w_wait_flg & ~w_wr2rd_wait)                 ? r_ahb_rbten:
                   ((((SELF_STATE == P_WAIT_CONF) & SELF_RD_ACC_BUSY & w_wait_end) |
                     (SELF_STATE == P_WAIT_WR2RD)) & ~w_wr2rd_wait)                  ? r_rbten_lat:
                                                                                       r_ram_rbten;

assign PF_SRCH_VAL = (SELF_RD_ACC_START & ~w_wait_flg & ~w_wr2rd_wait & ~|HBURST &
                      ((PF_MODE_SEL[0] & ~HPROT[0]) |
                       (PF_MODE_SEL[1] & HPROT[0] & (HSIZE == P_BANK_W)))) |
                     ((((SELF_STATE == P_WAIT_CONF) & SELF_RD_ACC_BUSY & w_wait_end) |
                       ((SELF_STATE == P_WAIT_WR2RD) & ~w_wr2rd_wait)) & ~|r_hburst_lat &
                      ((PF_MODE_SEL[0] & ~r_hprot_lat[0]) |
                       (PF_MODE_SEL[1] & r_hprot_lat[0] & &r_ram_rbten)));

always @ (posedge HCLK or negedge HRESETN) begin
  if (!HRESETN) begin
    r_pf_val_lat  <= 0;
    r_pf_data_lat <= 0;
  end
  else begin
    if (~w_hready) begin
      if (PF_RD_VAL) begin
        r_pf_val_lat  <= 1'b1;
        r_pf_data_lat <= r_ram_rdata_rbten;
      end
    end
    else begin
      r_pf_val_lat  <= 0;
      r_pf_data_lat <= 0;
    end
  end
end

always @ (posedge HCLK or negedge HRESETN) begin
  if (!HRESETN) begin
    r_by2nsq_rdt_lat_en  <= 0;
    r_by2nsq_rdt_lat_val <= 0;
  end
  else begin
    if ((HTRANS == 2'b10) & (r_htrans_p1 == 2'b01) &
        ((SELF_STATE == P_RD_RESP) |
         ((SELF_STATE == P_RD_PFER) & (PF_RD_VAL | r_pf_val_lat)))) begin
      r_by2nsq_rdt_lat_en <= 1'b1;
      if (SELF_STATE == P_RD_RESP)
        r_by2nsq_rdt_lat_val <= r_pre_rdata;
      else begin
        if (r_pf_val_lat)
          r_by2nsq_rdt_lat_val <= r_pf_data_lat;
        else
          r_by2nsq_rdt_lat_val <= r_ram_rdata_rbten;
      end
    end
    else if (w_hready)
      r_by2nsq_rdt_lat_en <= 0;
  end
end

assign HRDATA  = (r_by2nsq_rdt_lat_en) ? r_by2nsq_rdt_lat_val:
                 (PF_RD_VAL)           ? r_ram_rdata_rbten:
                 (r_pf_val_lat)        ? r_pf_data_lat:
                                         r_pre_rdata;

endmodule
