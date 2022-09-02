//-----------------------------------------------
// Space Cubics OBC A1 FPGA
//  I2C Slave Model
//  Module: i2c_model
//-----------------------------------------------
// Copyright © 2022 Space Cubics, LLC.
//-----------------------------------------------

`timescale 1ps/1ps

module i2c_model # (
  parameter rclk_delay_time_init = 1900,
  parameter rclk_hold_time_init = 900,
  parameter clk_period_init = 100,
  parameter clk_period_allowable_init = 10
) (
  input SYS_CLK,
  input I2C_SCL,
  inout I2C_SDA
);

// Simulation finish control
reg fctrl = 0;

task FINISH_CTRL;
  input SW;
begin
  fctrl = SW;
  if (fctrl)
    $display($time, " | %m Finish control enable");
  else
    $display($time, " | %m Finish control disable");
end
endtask

// Timing Parameter Control
reg [31:0] rclk_delay_time = rclk_delay_time_init;
reg [31:0] rclk_hold_time  = rclk_hold_time_init;
reg [31:0] clk_period      = clk_period_init;
reg [31:0] clk_period_allowable = clk_period_allowable_init;

task SET_RCLK_DELAY_TIME;
  input [31:0] set_rclk_delay_time;
begin
  rclk_delay_time = set_rclk_delay_time;
  $display($time, " | %m Set RCLK Delay Time: %d ps", rclk_delay_time);
end
endtask

task SET_RCLK_HOLD_TIME;
  input [31:0] set_rclk_hold_time;
begin
  rclk_hold_time = set_rclk_hold_time;
  $display($time, " | %m Set RCLK Hold Time: %d ps", rclk_hold_time);
end
endtask

task SET_CLK_PERIOD;
  input [31:0] set_clk_period;
begin
  clk_period = set_clk_period;
  $display($time, " | %m Set Clock Period: %d ps", clk_period);
end
endtask

task SET_CLK_PERIOD_ALLOWABLE;
  input [31:0] set_clk_period_allowable;
begin
  clk_period_allowable = set_clk_period_allowable;
  $display($time, " | %m Set Clock Period Allowable error: %d ps", clk_period_allowable);
end
endtask

reg clk_period_check_off = 0;
task SET_CLK_PERIOD_CHECK_OFF;
  input set_clk_period_check_off;
begin
  clk_period_check_off = set_clk_period_check_off;
  if (clk_period_check_off)
    $display($time, " | %m Set Clock Period Check Off Enable");
  else
    $display($time, " | %m Set Clock Period Check Off Disable");
end
endtask

// Sim model initialize
reg model_reset = 1;
initial begin
  #10000
  model_reset = 1'b1;
  #1;
  model_reset = 1'b0;
  #1;
  model_reset = 1'b1;
end

reg adr_10b_en = 0;
reg [9:0] dev_adr = 0;
reg rx_exp_on = 0;

reg [7:0] i2c_rxdata_exp [0:255];
reg [7:0] i2c_txdata [0:255];
integer depth;

reg txhandshake = 0;

reg clk_stop = 1;

reg start_detect;
reg restart_detect;
reg restart_pulse;
reg stop_detect;
reg [31:0] count = 0;
reg i2c_dat;
reg i2c_oen;
reg txnack = 0;
reg [7:0] i2c_rxdata = 8'h00;
reg rxhandshake = 0;
reg rxvalid = 0;
integer test = 0;

reg i2c_complete;
reg [31:0] pcount;
reg [7:0] data_num;
reg transdir = 0;
reg [9:0] adr_lat = 0;
reg adr10b_1st = 0;
reg transdir_lat = 0;
reg devadr_ng = 0;

task SET_DEVADR;
  input set_adr_10b_en;
  input [9:0] set_dev_adr;
begin
  adr_10b_en = set_adr_10b_en;
  if (adr_10b_en)
    $display($time, " | %m Set 10bit Address Mode Enable");
  dev_adr = set_dev_adr;
  $display($time, " | %m Set Device Address: 0x%h", dev_adr);
end
endtask

task RX_EXP_COMP_EN;
  input SW;
begin
  rx_exp_on = SW;
  if (rx_exp_on)
    $display($time, " | %m RX WriteData Expected value comparison enable");
  else
    $display($time, " | %m RX WriteData Expected value comparison disable");
end
endtask

initial begin
  for (depth=0; depth<256; depth = depth + 1) begin
    i2c_rxdata_exp[depth] = 8'h00;
    i2c_txdata[depth]     = 8'h01 + depth;
  end
end

task RX_EXP_VAL_SET;
  input [7:0] bytenum;
  input [7:0] exp_dat;
begin
  i2c_rxdata_exp[bytenum] = exp_dat;
end
endtask

task TX_VAL_SET;
  input [7:0] bytenum;
  input [7:0] tx_dat;
begin
  i2c_txdata[bytenum] = tx_dat;
end
endtask

task SET_TX_HANDSHAKE;
  input LEVEL;
begin
  txhandshake = LEVEL;
  if (txhandshake)
    $display($time, " | %m Set Handhsake High Level");
  else
    $display($time, " | %m Set Handhsake Low Level");
end
endtask

// Start/Stop Detect
initial begin
  clk_stop = 1;
  @ (negedge I2C_SCL);
  clk_stop = 0;
  forever begin
    @ (posedge I2C_SCL);
    #(clk_period/2 +10);
    if (~I2C_SCL) begin
      clk_stop = 0;
    end
    else begin
      clk_stop = 1;
      @ (negedge I2C_SCL);
      clk_stop = 0;
    end
  end
end

reg [31:0] clk_period_ns_cnt = 0;
// Clock Period Checker
always begin
  @ (posedge I2C_SCL);
  if (~clk_stop & ~clk_period_check_off) begin
    while (~clk_stop & I2C_SCL) begin
      if (~&clk_period_ns_cnt)
        clk_period_ns_cnt = clk_period_ns_cnt + 1;
      #1000;
    end
    while (~clk_stop & ~I2C_SCL) begin
      if (~&clk_period_ns_cnt)
        clk_period_ns_cnt = clk_period_ns_cnt + 1;
      #1000;
    end
    if (((clk_period_ns_cnt < ((clk_period - clk_period_allowable)/1000)) |
         (clk_period_ns_cnt > ((clk_period + clk_period_allowable)/1000))) & ~clk_stop) begin
      $display($time, " | %m I2C Clock Period Error!!!!!! | Clock period: %d[ns]", clk_period_ns_cnt);
      if (fctrl) begin
        repeat(1000) @ (posedge SYS_CLK);
        $finish();
      end
    end
  end
  clk_period_ns_cnt = 0;
end

always @ (negedge I2C_SDA or negedge model_reset) begin
  if (!model_reset) begin
    start_detect   <= 1'b0;
  end
  else begin
    #1;
    if (I2C_SCL & ~I2C_SDA & ~start_detect & clk_stop) begin
      start_detect   <= 1'b1;
      count = 8;
    end
  end
end

always @ (posedge I2C_SDA or negedge I2C_SDA or negedge model_reset) begin
  if (!model_reset) begin
    restart_detect <= 1'b0;
    stop_detect    <= 1'b0;
  end
  else begin
    #1;
    if (start_detect) begin
      if (I2C_SCL & ~I2C_SDA) begin
        restart_detect <= 1'b1;
        transdir       <= 1'b0;
        count = 8;
      end
      else if (I2C_SCL & I2C_SDA) begin
        stop_detect  <= 1'b1;
        transdir     <= 1'b0;
        start_detect <= 1'b0;
        @ (posedge start_detect);
        stop_detect <= 1'b0;
      end
    end
  end
end

initial begin
  restart_pulse = 0;
  forever begin
    @ (posedge restart_detect);
    #1;
    restart_pulse = 1;
    #10;
    restart_pulse = 0;
    @ (negedge restart_detect);
  end
end

// Data/Handshake Control
initial begin
  #12;
  i2c_dat = 1'b0;
  i2c_oen = 1'b0;
  @ (posedge model_reset);
  forever begin
    // Start detect
    if (!start_detect) begin
      @ (posedge start_detect);
      txnack = 0;
    end

    // Data Resceive
    while (count>0) begin
      if (~transdir | txnack) begin
        test = 1;
        @ (posedge I2C_SCL);
        i2c_rxdata[count-1] = I2C_SDA;
      end
      else begin
        test = 2;
        i2c_oen = 1'b1;
        i2c_dat = i2c_txdata[data_num][count-1];
        @ (negedge I2C_SCL);
      end
      count = count -1;
    end

    // Handshake
    if (~transdir) begin
      test = 100;
      @ (negedge I2C_SCL or posedge stop_detect);
      if (~I2C_SCL) begin
        #(rclk_delay_time);
        test = 4;
        if ((pcount == 1) | restart_detect) begin
          txnack = 0;
          if ((adr_10b_en &
               ((restart_detect & (i2c_rxdata[7:1] != {5'b11110, adr_lat[9:8]})) |
                (pcount == 1 & ((~adr10b_1st & (i2c_rxdata[7:3] != 5'b11110)) |
                                 (adr10b_1st & ({adr_lat[9:8], i2c_rxdata} != dev_adr)))))) |
              (~adr_10b_en & i2c_rxdata[7:1] != dev_adr[6:0])) begin
            i2c_dat = 1'b1;
            txnack = 1'b1;
          end else begin
            i2c_dat = 1'b0;
          end
        end else begin
          if (txhandshake)
            txnack = 1'b1;
          i2c_dat = txnack;
        end
        i2c_oen = 1'b1;
        @ (negedge I2C_SCL);
        #(rclk_hold_time);
        i2c_oen = 1'b0;
      end
    end
    else begin
      test = 3;
      i2c_oen     = 1'b0;
      @ (posedge I2C_SCL);
      rxhandshake = I2C_SDA;
      @ (negedge I2C_SCL);
    end
    test    = 5;
    rxvalid = 1;
    #5;

    if (rxhandshake) begin
      if (~stop_detect & ~restart_detect)
        @ (posedge (stop_detect | restart_detect));
    end

    test           = 6;
    if (~rxhandshake)
      restart_detect = 1'b0;
    rxvalid        = 0;
    count          = 8;
    rxhandshake    = 0;
  end
end
assign I2C_SDA = (i2c_oen & ~i2c_dat) ? 1'b0 : 1'bz;

initial begin
  forever begin
    i2c_complete = 0;
    pcount       = 1;
    data_num     = 0;
    transdir     = 0;
    devadr_ng    = 0;

    @ (posedge start_detect);
    while (~i2c_complete) begin

      @ (posedge rxvalid or posedge stop_detect);
      if (stop_detect) begin
        i2c_complete = 1;
      end
      else begin
        if (restart_detect) begin
          $display($time, " | %m Restart Receive");
          data_num = 0;
          transdir = i2c_rxdata[0];
          if (adr_10b_en) begin
            if (i2c_rxdata[7:1] != {5'b11110, adr_lat[9:8]}) begin
              $display($time, " | %m Receive 1st Address Not Match | R/nW: %b | TX: NACK", i2c_rxdata[0]);
              devadr_ng = 1;
            end
            else
              $display($time, " | %m Receive Device Address: 0x%h | R/nW: %b | TX: ACK", adr_lat, i2c_rxdata[0]);
          end else begin
            if (i2c_rxdata[7:1] != dev_adr[6:0]) begin
              $display($time, " | %m Receive Device Address: 0x%h | R/nW: %b | TX: NACK", i2c_rxdata[7:1], i2c_rxdata[0]);
              devadr_ng = 1;
            end
            else
              $display($time, " | %m Receive Device Address: 0x%h | R/nW: %b | TX: ACK", i2c_rxdata[7:1], i2c_rxdata[0]);
          end
        end
        else begin
          case (pcount)
            1: begin
              if (adr_10b_en) begin
                if (~adr10b_1st) begin
                  if (i2c_rxdata[7:3] == 5'b11110) begin
                    // Device Address : 1
                    adr10b_1st = 1'b1;
                    transdir_lat = i2c_rxdata[0];
                    adr_lat[9:8] = i2c_rxdata[2:1];
                  end else begin
                    $display($time, " | %m Receive 1st Address Not Match | R/nW: %b | TX: NACK", transdir_lat);
                    devadr_ng = 1;
                  end
                end else begin
                  // Device Address : 2
                  transdir = transdir_lat;
                  adr_lat[7:0] = i2c_rxdata;
                  if (adr_lat != dev_adr) begin
                    $display($time, " | %m Receive Device Address: 0x%h | R/nW: %b | TX: NACK", adr_lat, transdir_lat);
                    devadr_ng = 1;
                  end
                  else
                    $display($time, " | %m Receive Device Address: 0x%h | R/nW: %b | TX: ACK", adr_lat, transdir_lat);
                  adr10b_1st = 0;
                  transdir_lat = 0;
                  pcount = 2;
                end
              end else begin
                // Device Address
                transdir = i2c_rxdata[0];
                if (i2c_rxdata[7:1] != dev_adr[6:0]) begin
                  $display($time, " | %m Receive Device Address: 0x%h | R/nW: %b | TX: NACK", i2c_rxdata[7:1], i2c_rxdata[0]);
                  devadr_ng = 1;
                end
                else
                  $display($time, " | %m Receive Device Address: 0x%h | R/nW: %b | TX: ACK", i2c_rxdata[7:1], i2c_rxdata[0]);
                pcount = 2;
              end
            end
            2: begin
              if (~devadr_ng) begin
                // Read/Write
                if (~transdir) begin
                  $display($time, " | %m WDATA:%h (WR_Bytes: %d)",i2c_rxdata, data_num);
                  if (rx_exp_on & (i2c_rxdata !== i2c_rxdata_exp[data_num])) begin
                    $display($time, " | %m RX WriteData Error!!!!!! | EXP: %h", i2c_rxdata_exp[data_num]);
                    if (fctrl) begin
                      repeat(1000) @ (posedge SYS_CLK);
                      $finish();
                    end
                  end
                end
                data_num = data_num + 1;
              end
            end
          endcase
        end
      end
    end
  end
end

endmodule
