//-----------------------------------------------
// Space Cubics AHB IP
//  AHB Master Verification Package File
//  Module: scvip_ahb_master
//-----------------------------------------------
// Copyright © 2022 Space Cubics, LLC.
//-----------------------------------------------

parameter SCVIP_AHBM_NUM_OF_MASTER = 3;
parameter SCVIP_AHBM_MAX_TRANS_CYCLE = 128;
reg [SCVIP_AHBM_MAX_TRANS_CYCLE*32-1:0] WriteData;
reg [SCVIP_AHBM_MAX_TRANS_CYCLE*32-1:0] ReadData;

parameter AHB_SIZE_1BYTE = 1,
          AHB_SIZE_2BYTE = 2,
          AHB_SIZE_4BYTE = 4;

parameter AHB_BURST_TYPE_INCR = 1,
          AHB_BURST_TYPE_WRAP = 2,
          AHB_BURST_TYPE_INCX = 3;

parameter AHB_READ  = 0,
          AHB_WRITE = 1;

parameter AHB_LEN_SINGLE = 5'b00001,
          AHB_LEN_4BEAT  = 5'b00100,
          AHB_LEN_8BEAT  = 5'b01000,
          AHB_LEN_16BEAT = 5'b01000;

parameter SENS_NONE = 2'b00, // Does nothing for the event.
          SENS_INFO = 2'b01, // Notify you when an event occurs.
          SENS_ERRR = 2'b10, // Counts errors when an event occurs. The simulation keeps running.
          SENS_STOP = 2'b11; // Simulation will stop when an event occurs.

wire HCLK;
wire HRESETN;
wire [31:0] HADDR [0:SCVIP_AHBM_NUM_OF_MASTER-1];
wire [1:0] HTRANS [0:SCVIP_AHBM_NUM_OF_MASTER-1];
wire HWRITE [0:SCVIP_AHBM_NUM_OF_MASTER];
wire [2:0] HSIZE [0:SCVIP_AHBM_NUM_OF_MASTER-1];
wire [2:0] HBURST [0:SCVIP_AHBM_NUM_OF_MASTER-1];
wire [31:0] HWDATA [0:SCVIP_AHBM_NUM_OF_MASTER-1];
wire [31:0] HRDATA [0:SCVIP_AHBM_NUM_OF_MASTER-1];
wire HREADY [0:SCVIP_AHBM_NUM_OF_MASTER];
wire [1:0] HRESP [0:SCVIP_AHBM_NUM_OF_MASTER-1];

`include "scvip_ahb_master_bind.vh"

wire [17:0] SENSITIVITY [0:SCVIP_AHBM_NUM_OF_MASTER-1];
wire [32*SCVIP_AHBM_MAX_TRANS_CYCLE-1:0] TRANSDATA [0:SCVIP_AHBM_NUM_OF_MASTER-1];
genvar m;
generate
  for (m=0; m<SCVIP_AHBM_NUM_OF_MASTER; m=m+1) begin: ahbm
    scvip_ahb_master # (
      .SCVIP_AHBM_MAX_TRANS_CYCLE(SCVIP_AHBM_MAX_TRANS_CYCLE)
    ) ahb_master (
      // System Interface
      .HCLK(HCLK),
      .HRESETN(HRESETN),

      // AHB Interface
      .HADDR(HADDR[m]),
      .HTRANS(HTRANS[m]),
      .HWRITE(HWRITE[m]),
      .HSIZE(HSIZE[m]),
      .HBURST(HBURST[m]),
      .HWDATA(HWDATA[m]),
      .HRDATA(HRDATA[m]),
      .HREADY(HREADY[m]),
      .HRESP(HRESP[m]),
      .ECOUNT(),
      .SENSITIVITY(SENSITIVITY[m]),
      .TRANSDATA(TRANSDATA[m])
    );
  end
endgenerate

task automatic read_transaction (
  input integer master = 0,
  input [31:0] addr,
  input [2:0] size = AHB_SIZE_4BYTE,
  input [32*SCVIP_AHBM_MAX_TRANS_CYCLE-1:0] expdata,
  input [4:0] len = AHB_LEN_SINGLE,
  input [1:0] burst = AHB_BURST_TYPE_INCR,
  input [32*SCVIP_AHBM_MAX_TRANS_CYCLE-1:0] chkbit = {32*SCVIP_AHBM_MAX_TRANS_CYCLE{1'b1}},
  input check
);
  integer m;
  reg [32*SCVIP_AHBM_MAX_TRANS_CYCLE-1:0] baddr;
  reg [SCVIP_AHBM_MAX_TRANS_CYCLE-1:0] bwrite;
  reg [2*SCVIP_AHBM_MAX_TRANS_CYCLE-1:0] bbtype;
  reg [3*SCVIP_AHBM_MAX_TRANS_CYCLE-1:0] bsize;
  reg [5*SCVIP_AHBM_MAX_TRANS_CYCLE-1:0] bcycle;
  reg [17:0] reg_sens, set_sens;

  baddr[0 +:32] = addr;
  bwrite[0]     = AHB_READ;
  bbtype[0 +:2] = burst;
  bsize[0 +:3]  = size;
  bcycle[0 +:5] = len;

  reg_sens = SENSITIVITY[master];
  if (check)
    set_sens = {SENS_STOP, reg_sens[15:0]};
  else
    set_sens = {SENS_INFO, reg_sens[15:0]};

  case (master)
    0: ahbm[0].ahb_master.CHANGE_SENSITIVITY(set_sens);
    1: ahbm[1].ahb_master.CHANGE_SENSITIVITY(set_sens);
    2: ahbm[2].ahb_master.CHANGE_SENSITIVITY(set_sens);
  endcase


  case (master)
    0: ahbm[0].ahb_master.CHANGE_SENSITIVITY(set_sens);
    1: ahbm[1].ahb_master.CHANGE_SENSITIVITY(set_sens);
    2: ahbm[2].ahb_master.CHANGE_SENSITIVITY(set_sens);
  endcase

  case (master)
    0: ahbm[0].ahb_master.AHB_TRANS(1, baddr, bwrite, bbtype, bsize, bcycle, expdata, chkbit);
    1: ahbm[1].ahb_master.AHB_TRANS(1, baddr, bwrite, bbtype, bsize, bcycle, expdata, chkbit);
    2: ahbm[2].ahb_master.AHB_TRANS(1, baddr, bwrite, bbtype, bsize, bcycle, expdata, chkbit);
  endcase

  case (master)
    0: ahbm[0].ahb_master.CHANGE_SENSITIVITY(reg_sens);
    1: ahbm[1].ahb_master.CHANGE_SENSITIVITY(reg_sens);
    2: ahbm[2].ahb_master.CHANGE_SENSITIVITY(reg_sens);
  endcase

endtask

task automatic read_transaction_polling_wait (
  input integer master = 0,
  input [31:0] addr,
  input [2:0] size = AHB_SIZE_4BYTE,
  input [32*SCVIP_AHBM_MAX_TRANS_CYCLE-1:0] expdata,
  input [4:0] len = AHB_LEN_SINGLE,
  input [1:0] burst = AHB_BURST_TYPE_INCR,
  input [32*SCVIP_AHBM_MAX_TRANS_CYCLE-1:0] chkbit = {32*SCVIP_AHBM_MAX_TRANS_CYCLE{1'b1}},
  input [31:0] timeout = 100
);
  integer i;
  reg [32*SCVIP_AHBM_MAX_TRANS_CYCLE-1:0] baddr;
  reg [SCVIP_AHBM_MAX_TRANS_CYCLE-1:0] bwrite;
  reg [2*SCVIP_AHBM_MAX_TRANS_CYCLE-1:0] bbtype;
  reg [3*SCVIP_AHBM_MAX_TRANS_CYCLE-1:0] bsize;
  reg [5*SCVIP_AHBM_MAX_TRANS_CYCLE-1:0] bcycle;
  reg [17:0] reg_sens, set_sens;
  reg result = 0;
  reg count  = 0;

  baddr[0 +:32] = addr;
  bwrite[0]     = AHB_READ;
  bbtype[0 +:2] = burst;
  bsize[0 +:3]  = size;
  bcycle[0 +:5] = len;

  reg_sens      = SENSITIVITY[master];
  set_sens      = {SENS_INFO, reg_sens[15:0]};

  case (master)
    0: ahbm[0].ahb_master.CHANGE_SENSITIVITY(set_sens);
    1: ahbm[1].ahb_master.CHANGE_SENSITIVITY(set_sens);
    2: ahbm[2].ahb_master.CHANGE_SENSITIVITY(set_sens);
  endcase

  while (result == 0) begin
    count = count + 1;
    case (master)
      0: ahbm[0].ahb_master.AHB_TRANS(1, baddr, bwrite, bbtype, bsize, bcycle, expdata, chkbit);
      1: ahbm[1].ahb_master.AHB_TRANS(1, baddr, bwrite, bbtype, bsize, bcycle, expdata, chkbit);
      2: ahbm[2].ahb_master.AHB_TRANS(1, baddr, bwrite, bbtype, bsize, bcycle, expdata, chkbit);
    endcase

    result = 1;
    for (i=0; i<len; i=i+1) begin
      if ((TRANSDATA[master][32*i +:32] & chkbit[32*i +:32]) != (expdata[32*i +:32] & chkbit[32*i +:32]))
        result = 0;
    end

    if (count == timeout & result == 0) begin
      $display($time, " |           | +ERROR+ (Polling Timeout Error) |");
      repeat (10) @ (posedge HCLK);
      $finish();
    end
  end

  case (master)
    0: ahbm[0].ahb_master.CHANGE_SENSITIVITY(reg_sens);
    1: ahbm[1].ahb_master.CHANGE_SENSITIVITY(reg_sens);
    2: ahbm[2].ahb_master.CHANGE_SENSITIVITY(reg_sens);
  endcase

endtask

task automatic write_transaction (
  input integer master = 0,
  input [31:0] addr,
  input [2:0] size = AHB_SIZE_4BYTE,
  input [32*SCVIP_AHBM_MAX_TRANS_CYCLE-1:0] data,
  input [4:0] len = AHB_LEN_SINGLE,
  input [1:0] burst = AHB_BURST_TYPE_INCR
);
  integer m;
  reg [32*SCVIP_AHBM_MAX_TRANS_CYCLE-1:0] baddr;
  reg [SCVIP_AHBM_MAX_TRANS_CYCLE-1:0] bwrite;
  reg [2*SCVIP_AHBM_MAX_TRANS_CYCLE-1:0] bbtype;
  reg [3*SCVIP_AHBM_MAX_TRANS_CYCLE-1:0] bsize;
  reg [5*SCVIP_AHBM_MAX_TRANS_CYCLE-1:0] bcycle;
  reg [17:0] reg_sens, set_sens;


  baddr[0 +:32] = addr;
  bwrite[0]     = AHB_WRITE;
  bbtype[0 +:2] = burst;
  bsize[0 +:3]  = size;
  bcycle[0 +:5] = len;

  case (master)
    0: ahbm[0].ahb_master.AHB_TRANS(1, baddr, bwrite, bbtype, bsize, bcycle, data, 0);
    1: ahbm[1].ahb_master.AHB_TRANS(1, baddr, bwrite, bbtype, bsize, bcycle, data, 0);
    2: ahbm[2].ahb_master.AHB_TRANS(1, baddr, bwrite, bbtype, bsize, bcycle, data, 0);
  endcase

endtask
