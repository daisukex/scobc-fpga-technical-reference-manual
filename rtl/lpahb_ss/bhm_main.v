//-----------------------------------------------
// Module: bhm_main
//  Space Cubics OBC Board Health Monitor Main Controller
//-----------------------------------------------
// Copyright © 2022 Space Cubics, LLC.
//-----------------------------------------------

module bhm_main # (
  parameter [5:0] INITSET_NUM = 6'd1,
  parameter [27*INITSET_NUM-1:0] INITSET_VAL = 27'h0
) (
  // System Interface
  input SYSCLK,
  input SYSRST_N,

  // Register Interface
  input INIT_REQ,
  input [4:0] INIT_EN,

  input [4:0] MONI_EN,
  output reg [4:0] MONI_EN_OFF,

  output reg TEMP_ALERT,
  output reg CVM_WARN,
  output reg CVM_CRIT,
  output reg [5:0] I2C_ACC_ERR,
  output reg SW_ACC_END,
  output reg INIT_ACC_END,

  output reg [11:0] CVM_UPD,
  output reg [16*12-1:0] CVM_DAT,
  output reg [2:0] TEMP_UPD,
  output reg [16*3-1:0] TEMP_DAT,

  input SW_REQ,
  input [2:0] SW_DEVSEL,
  input [7:0] SW_DEVADR,
  input SW_RWSEL,
  input [15:0] SW_WRDATA,
  output reg [15:0] SW_RDDATA,

  input [15:0] CLKPSC,
  input [7:0] I2CACC_CNT,

  output reg [5:0] BUSY,

  // Hardware Scheduler Interface
  input CVM_DATA_REQ_TRG,
  input TEMP_DATA_REQ_TRG,

  // Device Interface
  input CVM_CRITICAL_B,
  input CVM_WARNING_B,
  input TEMP_ALERT_B,

  // I2C Controller Interface
  output reg [15:0] I2C_THDSTA,
  output reg [15:0] I2C_TSUSTO,
  output reg [15:0] I2C_TSUSTA,
  output reg [15:0] I2C_THIGH,
  output reg [15:0] I2C_THDDAT,
  output reg [15:0] I2C_TSUDAT,
  output reg [15:0] I2C_TBUF,

  output reg I2C_EN,
  input I2C_EN_OFF,
  input I2C_COMP,
  input [1:0] I2C_BUSY,
  input [2:0] I2C_ERR,

  input I2C_TX_DATA_REQ,
  output reg [9:0] I2C_TX_DATA,
  output reg I2C_TX_DATA_READY,

  input I2C_RX_DATA_VAL,
  input [7:0] I2C_RX_DATA
);

reg [2:0] cvm_critical_b_retim;
reg [2:0] cvm_warning_b_retim;
reg [2:0] temp_alert_b_retim;

reg [1:0] cvm_data_req_trg_retim;
reg [1:0] temp_data_req_trg_retim;
reg moni_cvm_req;
reg moni_temp_req;

reg [5:0] init_cnt;
reg [3:0] moni_cvm_cnt;
reg [1:0] moni_temp_cnt;
reg [4:0] init_acc_off;
reg [6:0] acc_slvadr;
reg [7:0] acc_regadr;
reg acc_rw;
reg [15:0] acc_wdat;
reg i2crun_judge;
reg moni_cvm_acc_end;
reg moni_temp_acc_end;
reg [2:0] bhm_state;

reg i2c_phase_rd;
reg [1:0] tx_byte_cnt;
reg [7:0] retry_cnt;
reg acc_rbyte;
reg [15:0] acc_rdat;

// Board Health State
localparam BHM_ST_IDLE      = 3'h0,
           BHM_ST_SWACC     = 3'h1,
           BHM_ST_INIT      = 3'h2,
           BHM_ST_MONI_CVM  = 3'h3,
           BHM_ST_MONI_TEMP = 3'h4,
           BHM_ST_ACCEND    = 3'h5;

// Slave Address
localparam SLVADR_CVM1  = 7'b1000000,
           SLVADR_CVM2  = 7'b1000001,
           SLVADR_TEMP1 = 7'b1001100,
           SLVADR_TEMP2 = 7'b1001101,
           SLVADR_TEMP3 = 7'b1001110;

// Device Alert to Interrupt
always @ (posedge SYSCLK) begin
  if (!SYSRST_N) begin
    cvm_critical_b_retim <= 3'b111;
    cvm_warning_b_retim  <= 3'b111;
    temp_alert_b_retim   <= 3'b111;
    CVM_CRIT             <= 0;
    CVM_WARN             <= 0;
    TEMP_ALERT           <= 0;
  end
  else begin
    cvm_critical_b_retim <= {cvm_critical_b_retim[1:0], CVM_CRITICAL_B};
    cvm_warning_b_retim  <= {cvm_warning_b_retim[1:0], CVM_WARNING_B};
    temp_alert_b_retim   <= {temp_alert_b_retim[1:0], TEMP_ALERT_B};
    CVM_CRIT             <= ~cvm_critical_b_retim[1] & cvm_critical_b_retim[2];
    CVM_WARN             <= ~cvm_warning_b_retim[1] & cvm_warning_b_retim[2];
    TEMP_ALERT           <= ~temp_alert_b_retim[1] & temp_alert_b_retim[2];
  end
end

// Monitoring Data Request
always @ (posedge SYSCLK) begin
  if (!SYSRST_N) begin
    cvm_data_req_trg_retim  <= 0;
    temp_data_req_trg_retim <= 0;
    moni_cvm_req            <= 0;
    moni_temp_req           <= 0;
  end
  else begin
    cvm_data_req_trg_retim  <= {cvm_data_req_trg_retim[0], CVM_DATA_REQ_TRG};
    temp_data_req_trg_retim <= {temp_data_req_trg_retim[0], TEMP_DATA_REQ_TRG};
    if (cvm_data_req_trg_retim[0] & ~cvm_data_req_trg_retim[1])
      moni_cvm_req <= 1'b1;
    else if (moni_cvm_acc_end)
      moni_cvm_req <= 0;
    if (temp_data_req_trg_retim[0] & ~temp_data_req_trg_retim[1])
      moni_temp_req <= 1'b1;
    else if (moni_temp_acc_end)
      moni_temp_req <= 0;
  end
end

// I2C Enable
always @ (posedge SYSCLK) begin
  if (!SYSRST_N)
    I2C_EN <= 0;
  else
    I2C_EN <= ~I2C_EN_OFF;
end

// Board Health State Control
always @ (posedge SYSCLK) begin
  if (!SYSRST_N) begin
    init_cnt          <= 0;
    moni_cvm_cnt      <= 0;
    moni_temp_cnt     <= 0;
    init_acc_off      <= 0;
    acc_slvadr        <= 0;
    acc_regadr        <= 0;
    acc_rw            <= 0;
    acc_wdat          <= 0;
    i2crun_judge      <= 0;
    moni_cvm_acc_end  <= 0;
    moni_temp_acc_end <= 0;
    MONI_EN_OFF       <= 0;
    I2C_ACC_ERR       <= 0;
    SW_ACC_END        <= 0;
    INIT_ACC_END      <= 0;
    I2C_TX_DATA_READY <= 0;
    CVM_UPD           <= 0;
    CVM_DAT           <= 0;
    TEMP_UPD          <= 0;
    TEMP_DAT          <= 0;
    SW_RDDATA         <= 0;
    bhm_state         <= BHM_ST_IDLE;
  end
  else begin
    case (bhm_state)
      BHM_ST_IDLE : begin
        acc_slvadr        <= 0;
        acc_regadr        <= 0;
        acc_rw            <= 0;
        acc_wdat          <= 0;
        i2crun_judge      <= 0;
        moni_cvm_acc_end  <= 0;
        moni_temp_acc_end <= 0;
        MONI_EN_OFF       <= 0;
        I2C_ACC_ERR       <= 0;
        SW_ACC_END        <= 0;
        INIT_ACC_END      <= 0;
        I2C_TX_DATA_READY <= 0;
        CVM_UPD           <= 0;
        TEMP_UPD          <= 0;
        if (~|I2C_BUSY) begin
          if (SW_REQ) begin
            case (SW_DEVSEL)
              3'h0:    acc_slvadr <= SLVADR_CVM1;
              3'h1:    acc_slvadr <= SLVADR_CVM2;
              3'h2:    acc_slvadr <= SLVADR_TEMP1;
              3'h3:    acc_slvadr <= SLVADR_TEMP2;
              default: acc_slvadr <= SLVADR_TEMP3;
            endcase
            acc_regadr        <= SW_DEVADR;
            acc_rw            <= SW_RWSEL;
            acc_wdat          <= SW_WRDATA;
            I2C_TX_DATA_READY <= 1'b1;
            bhm_state         <= BHM_ST_SWACC;
          end
          else if (INIT_REQ & (|init_cnt | ~(|moni_cvm_cnt | |moni_temp_cnt))) begin
            case (INITSET_VAL[27*init_cnt+24 +: 3])
              3'h0:    acc_slvadr <= SLVADR_CVM1;
              3'h1:    acc_slvadr <= SLVADR_CVM2;
              3'h2:    acc_slvadr <= SLVADR_TEMP1;
              3'h3:    acc_slvadr <= SLVADR_TEMP2;
              default: acc_slvadr <= SLVADR_TEMP3;
            endcase
            acc_regadr   <= INITSET_VAL[27*init_cnt+16 +: 8];
            acc_rw       <= 0;
            acc_wdat     <= INITSET_VAL[27*init_cnt +: 16];
            i2crun_judge <= 1'b1;
            bhm_state    <= BHM_ST_INIT;
          end
          else if (moni_cvm_req & (|moni_cvm_cnt | ~(|init_cnt | |moni_temp_cnt))) begin
            case (moni_cvm_cnt)
              4'h0:    begin acc_slvadr <= SLVADR_CVM1; acc_regadr <= 8'h01; end
              4'h1:    begin acc_slvadr <= SLVADR_CVM1; acc_regadr <= 8'h02; end
              4'h2:    begin acc_slvadr <= SLVADR_CVM1; acc_regadr <= 8'h03; end
              4'h3:    begin acc_slvadr <= SLVADR_CVM1; acc_regadr <= 8'h04; end
              4'h4:    begin acc_slvadr <= SLVADR_CVM1; acc_regadr <= 8'h05; end
              4'h5:    begin acc_slvadr <= SLVADR_CVM1; acc_regadr <= 8'h06; end
              4'h6:    begin acc_slvadr <= SLVADR_CVM2; acc_regadr <= 8'h01; end
              4'h7:    begin acc_slvadr <= SLVADR_CVM2; acc_regadr <= 8'h02; end
              4'h8:    begin acc_slvadr <= SLVADR_CVM2; acc_regadr <= 8'h03; end
              4'h9:    begin acc_slvadr <= SLVADR_CVM2; acc_regadr <= 8'h04; end
              4'hA:    begin acc_slvadr <= SLVADR_CVM2; acc_regadr <= 8'h05; end
              default: begin acc_slvadr <= SLVADR_CVM2; acc_regadr <= 8'h06; end
            endcase
            acc_rw       <= 1'b1;
            i2crun_judge <= 1'b1;
            bhm_state    <= BHM_ST_MONI_CVM;
          end
          else if (moni_temp_req & (|moni_temp_cnt | ~(|init_cnt | |moni_cvm_cnt))) begin
            case (moni_temp_cnt)
              2'h0:    acc_slvadr <= SLVADR_TEMP1;
              2'h1:    acc_slvadr <= SLVADR_TEMP2;
              default: acc_slvadr <= SLVADR_TEMP3;
            endcase
            acc_regadr   <= 8'h00;
            acc_rw       <= 1'b1;
            i2crun_judge <= 1'b1;
            bhm_state    <= BHM_ST_MONI_TEMP;
          end
        end
      end
      BHM_ST_SWACC : begin
        if (|I2C_ERR) begin
          if (retry_cnt >= I2CACC_CNT) begin
            I2C_ACC_ERR[5]    <= 1'b1;
            SW_ACC_END        <= 1'b1;
            I2C_TX_DATA_READY <= 0;
            bhm_state         <= BHM_ST_ACCEND;
          end
          else
            I2C_TX_DATA_READY <= 1'b1;
        end
        else if (I2C_TX_DATA_REQ & &tx_byte_cnt)
          I2C_TX_DATA_READY <= 0;
        else if (I2C_COMP) begin
          if (acc_rw) begin
            if (i2c_phase_rd) begin
              SW_ACC_END <= 1'b1;
              SW_RDDATA  <= acc_rdat;
              bhm_state  <= BHM_ST_ACCEND;
            end
          end
          else begin
            SW_ACC_END <= 1'b1;
            bhm_state  <= BHM_ST_ACCEND;
          end
        end
      end
      BHM_ST_INIT : begin
        if (i2crun_judge) begin
          i2crun_judge <= 0;
          if (((acc_slvadr == SLVADR_CVM1)  & (~INIT_EN[0] | init_acc_off[0])) |
              ((acc_slvadr == SLVADR_CVM2)  & (~INIT_EN[1] | init_acc_off[1])) |
              ((acc_slvadr == SLVADR_TEMP1) & (~INIT_EN[2] | init_acc_off[2])) |
              ((acc_slvadr == SLVADR_TEMP2) & (~INIT_EN[3] | init_acc_off[3])) |
              ((acc_slvadr == SLVADR_TEMP3) & (~INIT_EN[4] | init_acc_off[4])) ) begin
            if (init_cnt >= (INITSET_NUM - 1)) begin
              init_cnt     <= 0;
              init_acc_off <= 0;
              INIT_ACC_END <= 1'b1;
            end
            else
              init_cnt <= init_cnt + 1;
            bhm_state <= BHM_ST_ACCEND;
          end
          else
            I2C_TX_DATA_READY <= 1'b1;
        end
        else if (|I2C_ERR) begin
          if (retry_cnt >= I2CACC_CNT) begin
            if (init_cnt >= (INITSET_NUM - 1)) begin
              init_cnt     <= 0;
              init_acc_off <= 0;
              INIT_ACC_END <= 1'b1;
            end
            else begin
              init_cnt <= init_cnt + 1;
              case (INITSET_VAL[27*init_cnt+24 +: 3])
                3'h0:    init_acc_off[0] <= 1'b1;
                3'h1:    init_acc_off[1] <= 1'b1;
                3'h2:    init_acc_off[2] <= 1'b1;
                3'h3:    init_acc_off[3] <= 1'b1;
                default: init_acc_off[4] <= 1'b1;
              endcase
            end
            case (INITSET_VAL[27*init_cnt+24 +: 3])
              3'h0:    I2C_ACC_ERR[0] <= 1'b1;
              3'h1:    I2C_ACC_ERR[1] <= 1'b1;
              3'h2:    I2C_ACC_ERR[2] <= 1'b1;
              3'h3:    I2C_ACC_ERR[3] <= 1'b1;
              default: I2C_ACC_ERR[4] <= 1'b1;
            endcase
            I2C_TX_DATA_READY <= 0;
            bhm_state         <= BHM_ST_ACCEND;
          end
          else
            I2C_TX_DATA_READY <= 1'b1;
        end
        else if (I2C_TX_DATA_REQ & &tx_byte_cnt)
          I2C_TX_DATA_READY <= 0;
        else if (I2C_COMP) begin
          if (init_cnt >= (INITSET_NUM - 1)) begin
            init_cnt     <= 0;
            init_acc_off <= 0;
            INIT_ACC_END <= 1'b1;
          end
          else
            init_cnt <= init_cnt + 1;
          bhm_state <= BHM_ST_ACCEND;
        end
      end
      BHM_ST_MONI_CVM : begin
        if (i2crun_judge) begin
          i2crun_judge <= 0;
          if (((acc_slvadr == SLVADR_CVM1) & ~MONI_EN[0]) |
              ((acc_slvadr == SLVADR_CVM2) & ~MONI_EN[1]) ) begin
            if (moni_cvm_cnt >= 4'hB) begin
              moni_cvm_cnt     <= 0;
              moni_cvm_acc_end <= 1'b1;
            end
            else
              moni_cvm_cnt <= moni_cvm_cnt + 1;
            bhm_state <= BHM_ST_ACCEND;
          end
          else
            I2C_TX_DATA_READY <= 1'b1;
        end
        else if (|I2C_ERR) begin
          if (retry_cnt >= I2CACC_CNT) begin
            if (moni_cvm_cnt >= 4'hB) begin
              moni_cvm_cnt     <= 0;
              moni_cvm_acc_end <= 1'b1;
            end
            else
              moni_cvm_cnt <= moni_cvm_cnt + 1;
            if (moni_cvm_cnt < 4'h6) begin
              MONI_EN_OFF[0] <= 1'b1;
              I2C_ACC_ERR[0] <= 1'b1;
            end
            else begin
              MONI_EN_OFF[1] <= 1'b1;
              I2C_ACC_ERR[1] <= 1'b1;
            end
            I2C_TX_DATA_READY <= 0;
            bhm_state         <= BHM_ST_ACCEND;
          end
          else
            I2C_TX_DATA_READY <= 1'b1;
        end
        else if (I2C_TX_DATA_REQ & &tx_byte_cnt)
          I2C_TX_DATA_READY <= 0;
        else if (I2C_COMP) begin
          if (i2c_phase_rd) begin
            if (moni_cvm_cnt >= 4'hB) begin
              moni_cvm_cnt     <= 0;
              moni_cvm_acc_end <= 1'b1;
            end
            else
              moni_cvm_cnt <= moni_cvm_cnt + 1;
            if (moni_cvm_cnt < 4'hC) begin
              CVM_UPD[moni_cvm_cnt]          <= 1'b1;
              CVM_DAT[16*moni_cvm_cnt +: 16] <= acc_rdat;
            end
            bhm_state <= BHM_ST_ACCEND;
          end
        end
      end
      BHM_ST_MONI_TEMP : begin
        if (i2crun_judge) begin
          i2crun_judge <= 0;
          if (((acc_slvadr == SLVADR_TEMP1) & ~MONI_EN[2]) |
              ((acc_slvadr == SLVADR_TEMP2) & ~MONI_EN[3]) |
              ((acc_slvadr == SLVADR_TEMP3) & ~MONI_EN[4]) ) begin
            if (moni_temp_cnt >= 2'h2) begin
              moni_temp_cnt     <= 0;
              moni_temp_acc_end <= 1'b1;
            end
            else
              moni_temp_cnt <= moni_temp_cnt + 1;
            bhm_state <= BHM_ST_ACCEND;
          end
          else
            I2C_TX_DATA_READY <= 1'b1;
        end
        else if (|I2C_ERR) begin
          if (retry_cnt >= I2CACC_CNT) begin
            if (moni_temp_cnt >= 2'h2) begin
              moni_temp_cnt     <= 0;
              moni_temp_acc_end <= 1'b1;
            end
            else
              moni_temp_cnt <= moni_temp_cnt + 1;
            if (moni_temp_cnt == 2'h0) begin
              MONI_EN_OFF[2] <= 1'b1;
              I2C_ACC_ERR[2] <= 1'b1;
            end
            else if (moni_temp_cnt == 2'h1) begin
              MONI_EN_OFF[3] <= 1'b1;
              I2C_ACC_ERR[3] <= 1'b1;
            end
            else begin
              MONI_EN_OFF[4] <= 1'b1;
              I2C_ACC_ERR[4] <= 1'b1;
            end
            I2C_TX_DATA_READY <= 0;
            bhm_state         <= BHM_ST_ACCEND;
          end
          else
            I2C_TX_DATA_READY <= 1'b1;
        end
        else if (I2C_TX_DATA_REQ & &tx_byte_cnt)
          I2C_TX_DATA_READY <= 0;
        else if (I2C_COMP) begin
          if (i2c_phase_rd) begin
            if (moni_temp_cnt >= 2'h2) begin
              moni_temp_cnt     <= 0;
              moni_temp_acc_end <= 1'b1;
            end
            else
              moni_temp_cnt <= moni_temp_cnt + 1;
            if (moni_temp_cnt < 2'h3) begin
              TEMP_UPD[moni_temp_cnt]          <= 1'b1;
              TEMP_DAT[16*moni_temp_cnt +: 16] <= acc_rdat;
            end
            bhm_state <= BHM_ST_ACCEND;
          end
        end
      end
      default : begin
        acc_slvadr        <= 0;
        acc_regadr        <= 0;
        acc_rw            <= 0;
        acc_wdat          <= 0;
        i2crun_judge      <= 0;
        moni_cvm_acc_end  <= 0;
        moni_temp_acc_end <= 0;
        MONI_EN_OFF       <= 0;
        I2C_ACC_ERR       <= 0;
        SW_ACC_END        <= 0;
        INIT_ACC_END      <= 0;
        I2C_TX_DATA_READY <= 0;
        CVM_UPD           <= 0;
        TEMP_UPD          <= 0;
        bhm_state         <= BHM_ST_IDLE;
      end
    endcase
  end
end

always @ (posedge SYSCLK) begin
  if (!SYSRST_N) begin
    i2c_phase_rd <= 0;
    tx_byte_cnt  <= 0;
    retry_cnt    <= 0;
    I2C_TX_DATA  <= 0;
  end
  else if (bhm_state == BHM_ST_IDLE) begin
    i2c_phase_rd <= 0;
    tx_byte_cnt  <= 0;
    retry_cnt    <= 0;
  end
  else if (|I2C_ERR | ~I2C_BUSY[0]) begin
    i2c_phase_rd <= 0;
    tx_byte_cnt  <= 0;
    if (|I2C_ERR) begin
      if (retry_cnt >= I2CACC_CNT)
        retry_cnt <= 0;
      else
        retry_cnt <= retry_cnt + 1;
    end
  end
  else if (I2C_TX_DATA_REQ) begin
    tx_byte_cnt <= tx_byte_cnt + 1;
    case ({acc_rw, tx_byte_cnt})
      3'b0_00 : I2C_TX_DATA <= {2'h0, acc_slvadr, 1'b0}; // W: Write Slave Address & Wbit
      3'b0_01 : I2C_TX_DATA <= {2'h0, acc_regadr};       // W: Write Register Pointer
      3'b0_10 : I2C_TX_DATA <= {2'h0, acc_wdat[15:8]};   // W: Write Data MSB
      3'b0_11 : I2C_TX_DATA <= {2'h1, acc_wdat[7:0]};    // W: Write Data LSB
      3'b1_00 : I2C_TX_DATA <= {2'h0, acc_slvadr, 1'b0}; // R-1: Write Slave Address & Wbit
      3'b1_01 : I2C_TX_DATA <= {2'h1, acc_regadr};       // R-1: Write Register Pointer
      3'b1_10 : I2C_TX_DATA <= {2'h0, acc_slvadr, 1'b1}; // R-2: Write Slave Address & Rbit
      default : I2C_TX_DATA <= {2'h1, 8'h01};            // R-2: Read 2Byte Data
    endcase
  end
  else if (I2C_COMP) begin
    if (acc_rw) begin
      if (i2c_phase_rd) begin
        i2c_phase_rd <= 0;
        tx_byte_cnt  <= 0;
        retry_cnt    <= 0;
      end
      else
        i2c_phase_rd <= 1'b1;
    end
    else begin
      tx_byte_cnt <= 0;
      retry_cnt   <= 0;
    end
  end
end

always @ (posedge SYSCLK) begin
  if (!SYSRST_N) begin
    acc_rbyte <= 0;
    acc_rdat  <= 0;
  end
  else if (bhm_state == BHM_ST_IDLE) begin
    acc_rbyte <= 0;
    acc_rdat  <= 0;
  end
  else if (I2C_RX_DATA_VAL) begin
    if (acc_rbyte) begin
      acc_rbyte      <= 0;
      acc_rdat[7:0]  <= I2C_RX_DATA;
    end
    else begin
      acc_rbyte      <= 1'b1;
      acc_rdat[15:8] <= I2C_RX_DATA;
    end
  end
end

always @ (posedge SYSCLK) begin
  if (!SYSRST_N) begin
    I2C_THDSTA <= 0;
    I2C_TSUSTO <= 0;
    I2C_TSUSTA <= 0;
    I2C_THIGH  <= 0;
    I2C_THDDAT <= 0;
    I2C_TSUDAT <= 0;
    I2C_TBUF   <= 0;
  end
  else begin
    I2C_THDSTA <= {1'b0, CLKPSC[15:1]};
    I2C_TSUSTO <= {1'b0, CLKPSC[15:1]};
    I2C_TSUSTA <= {1'b0, CLKPSC[15:1]};
    I2C_THIGH  <= {1'b0, CLKPSC[15:1]} - 16'h5;
    I2C_THDDAT <= 16'h0004;
    I2C_TSUDAT <= {1'b0, CLKPSC[15:1]};
    I2C_TBUF   <= {1'b0, CLKPSC[15:1]} + 16'h5;
  end
end

always @ (posedge SYSCLK) begin
  if (!SYSRST_N)
    BUSY <= 0;
  else if ((bhm_state == BHM_ST_IDLE) & ~|I2C_BUSY)
    BUSY <= 6'b000000;
  else if (bhm_state == BHM_ST_SWACC)
    BUSY <= 6'b100000;
  else if ((bhm_state == BHM_ST_INIT)     |
           (bhm_state == BHM_ST_MONI_CVM) |
           (bhm_state == BHM_ST_MONI_TEMP)) begin
    if (acc_slvadr == SLVADR_CVM1)
      BUSY <= 6'b000001;
    else if (acc_slvadr == SLVADR_CVM2)
      BUSY <= 6'b000010;
    else if (acc_slvadr == SLVADR_TEMP1)
      BUSY <= 6'b000100;
    else if (acc_slvadr == SLVADR_TEMP2)
      BUSY <= 6'b001000;
    else if (acc_slvadr == SLVADR_TEMP3)
      BUSY <= 6'b010000;
  end
end

endmodule
