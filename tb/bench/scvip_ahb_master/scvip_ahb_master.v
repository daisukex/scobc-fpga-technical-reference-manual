//-----------------------------------------------
// Space Cubics AHB IP
//  AHB Master Verification IP (Version b0.1)
//  Module: scvip_ahb_master
//-----------------------------------------------
// Copyright © 2022 Space Cubics, LLC.
//-----------------------------------------------

`timescale 1ps/1ps

module scvip_ahb_master # (
  SCVIP_AHBM_MAX_TRANS_CYCLE = 1,
  SCVIP_AHBM_DISPLAY_SEPARATER = 1
) (
  // System Interface
  input HCLK,
  input HRESETN,

  // AHB Interface
  output reg [31:0] HADDR,
  output reg [1:0] HTRANS,
  output reg HWRITE,
  output reg [2:0] HSIZE,
  output reg [2:0] HBURST,
  output reg [31:0] HWDATA,
  input [31:0] HRDATA,
  input HREADY,
  input [1:0] HRESP,
  output [31:0] ECOUNT,
  output [17:0] SENSITIVITY,
  output reg [32*SCVIP_AHBM_MAX_TRANS_CYCLE-1:0] TRANSDATA
);

// AHB Protocol Parameter
// -----------------------------------------------------------------------------------------------------
parameter HT_IDLE   = 2'b00,
          HT_BUSY   = 2'b01,
          HT_NONSEQ = 2'b10,
          HT_SEQ    = 2'b11;

parameter HB_SINGLE = 3'b000,
          HB_INCR   = 3'b001,
          HB_WRAP4  = 3'b010,
          HB_INCR4  = 3'b011,
          HB_WRAP8  = 3'b100,
          HB_INCR8  = 3'b101,
          HB_WRAP16 = 3'b110,
          HB_INCR16 = 3'b111;

parameter HS_1BYTE = 3'b000,
          HS_2BYTE = 3'b001,
          HS_4BYTE = 3'b010,
          HS_8BYTE = 3'b011,
          HS_16BYTE = 3'b100,
          HS_32BYTE = 3'b101,
          HS_64BYTE = 3'b110,
          HS_128BYTE = 3'b111;

parameter HR_OKAY = 2'b00,
          HR_ERROR = 2'b01,
          HR_RETRY = 2'b10,
          HR_SPLIT = 2'b11;

// Sensitivity
// -----------------------------------------------------------------------------------------------------
parameter SENS_NONE = 2'b00, // Does nothing for the event.
          SENS_INFO = 2'b01, // Notify you when an event occurs.
          SENS_ERRR = 2'b10, // Counts errors when an event occurs. The simulation keeps running.
          SENS_STOP = 2'b11; // Simulation will stop when an event occurs.

reg [1:0] wsens [0:3];
reg [1:0] rsens [0:3];
reg [1:0] esens;
reg display_separate = SCVIP_AHBM_DISPLAY_SEPARATER;

initial begin
  wsens[HR_OKAY]  = SENS_INFO; // Write Transaction Responce OKAY : Info
  wsens[HR_ERROR] = SENS_INFO; // Write Transaction Responce ERROR: Error
  wsens[HR_RETRY] = SENS_INFO; // Write Transaction Responce RETRY: Info
  wsens[HR_SPLIT] = SENS_STOP; // Write Transaction Responce SPLIT: Error

  rsens[HR_OKAY]  = SENS_INFO; // Read Transaction Responce OKAY : Info
  rsens[HR_ERROR] = SENS_INFO; // Read Transaction Responce ERROR: Error
  rsens[HR_RETRY] = SENS_INFO; // Read Transaction Responce RETRY: Info
  rsens[HR_SPLIT] = SENS_STOP; // Read Transaction Responce SPLIT: Error

  esens           = SENS_STOP; // Read Transaction Data Error    : Error
end
assign SENSITIVITY = {esens,
                      wsens[HR_SPLIT], wsens[HR_RETRY], wsens[HR_ERROR], wsens[HR_OKAY],
                      rsens[HR_SPLIT], rsens[HR_RETRY], rsens[HR_ERROR], rsens[HR_OKAY]};

task CHANGE_SENSITIVITY;
  input [17:0] sensitivity;
begin
  esens           = sensitivity[17:16];

  wsens[HR_SPLIT] = sensitivity[15:14];
  wsens[HR_RETRY] = sensitivity[13:12];
  wsens[HR_ERROR] = sensitivity[11:10];
  wsens[HR_OKAY]  = sensitivity[9:8];

  rsens[HR_SPLIT] = sensitivity[7:6];
  rsens[HR_RETRY] = sensitivity[5:4];
  rsens[HR_ERROR] = sensitivity[3:2];
  rsens[HR_OKAY]  = sensitivity[1:0];
end
endtask

// SC-VIP AHB Master System Task
// -----------------------------------------------------------------------------------------------------
reg [31:0] scvip_ahb_master_error = 0;

task scvip_ahb_master_stop;
  input w1r0;
  input [1:0] etype;
  input [8*5-1:0] resp_string;
  reg [7:0] null_string;
begin
  if (display_separate == 0)
    $display(" --------------------+---------------------------------------------+---------------");
  $display($time, " | SC-VIP AHB Master Transaction Error         |");
  if (etype == 2'b00)
    $display("%20s |  Read Data Compare Error                    |", null_string);
  else if (etype == 2'b01)
    $display("%20s |  HRESP Check Error (%s)                  |", null_string, resp_string);
  $display("%20s |  Error Count: %5d                         |", null_string, scvip_ahb_master_error);
  $display(" --------------------+---------------------------------------------+---------------");
  repeat (10) @ (posedge HCLK);
  $finish();
end
endtask

// SC-VIP AHB Master Display and Error control Task
// -----------------------------------------------------------------------------------------------------
task display_ahb_wr;
  input [31:0] addr;
  input [2:0] size;
  input [1:0] btype;
  input [4:0] cycle;
  input [31:0] wdata;
  input [4:0] trans_cycle;
  input [1:0] resp;
  reg [8*8-1:0] ttype_string;
  reg [8*5-1:0] size_string;
  reg [8*5-1:0] resp_string;
  reg [7:0] null_string;
begin
  ttype_string = to_string_ttype(cycle, btype);
  size_string  = to_string_size(size);
  resp_string  = to_string_resp(resp);

  if (wsens[resp] != SENS_NONE) begin
    if (display_separate & cycle == trans_cycle & resp != HR_RETRY)
      $display("                     +---------------------------------------------+---------------");
    if (trans_cycle == 1) begin
      $display($time, " | AHB WRITE | ADDR: %4h_%4h SIZE: %4s     |", addr[31:16], addr[15:0], size_string);
      if (cycle == 1)
        $display("%20s | %s  | DATA: %4h_%4h                 | RESP: %s", null_string, ttype_string, wdata[31:16], wdata[15:0], resp_string);
      else
        $display("%20s | %s  | DATA: %4h_%4h (%2d)            | RESP: %s", null_string, ttype_string, wdata[31:16], wdata[15:0], trans_cycle, resp_string);
    end
    else
        $display("%20s |           | DATA: %4h_%4h (%2d)            | RESP: %s", null_string, wdata[31:16], wdata[15:0], trans_cycle, resp_string);
  end
  if (wsens[resp] == SENS_ERRR | wsens[resp] == SENS_STOP)
    scvip_ahb_master_error = scvip_ahb_master_error + 1;
  if (wsens[resp] == SENS_STOP)
    scvip_ahb_master_stop(1, 2'b01, resp_string);
end
endtask
assign ECOUNT = scvip_ahb_master_error;

task display_ahb_rd;
  input [31:0] addr;
  input [2:0] size;
  input [1:0] btype;
  input [4:0] cycle;
  input [31:0] rdata;
  input [31:0] expdata;
  input result;
  input [4:0] trans_cycle;
  input [1:0] resp;
  reg [8*8-1:0] ttype_string;
  reg [8*5-1:0] size_string;
  reg [8*5-1:0] resp_string;
  reg [7:0] null_string;
begin
  ttype_string = to_string_ttype(cycle, btype);
  size_string  = to_string_size(size);
  resp_string  = to_string_resp(resp);

  if (rsens[resp] != SENS_NONE) begin
    if (display_separate & cycle == trans_cycle & resp != HR_RETRY)
      $display("                     +---------------------------------------------+---------------");
    if (trans_cycle == 1) begin
      $display($time, " | AHB READ  | ADDR: %4h_%4h SIZE: %4s     |", addr[31:16], addr[15:0], size_string);
      if (cycle == 1)
        $display("%20s | %s  | DATA: %4h_%4h                 | RESP: %s", null_string, ttype_string, rdata[31:16], rdata[15:0], resp_string);
      else
        $display("%20s | %s  | DATA: %4h_%4h (%2d)            | RESP: %s", null_string, ttype_string, rdata[31:16], rdata[15:0], trans_cycle, resp_string);
    end
    else
      $display("%20s |           | DATA: %4h_%4h (%2d)            | RESP: %s", null_string, rdata[31:16], rdata[15:0], trans_cycle, resp_string);
    if (result === 1'b0 & (esens == SENS_ERRR | esens == SENS_STOP))
        $display("%20s |           | +ERROR+ (EXPDATA: %4h_%4h)    |", null_string, expdata[31:16], expdata[15:0]);
    else if (result === 1'b0)
        $display("%20s |           | +MISMATCH+ (EXPDATA: %4h_%4h) |", null_string, expdata[31:16], expdata[15:0]);
  end
  if (!result & (esens == SENS_ERRR | esens == SENS_STOP))
    scvip_ahb_master_error = scvip_ahb_master_error + 1;
  if (!result & esens == SENS_STOP)
    scvip_ahb_master_stop(0, 2'b00, resp_string);

  if (rsens[resp] == SENS_ERRR | rsens[resp] == SENS_STOP)
    scvip_ahb_master_error = scvip_ahb_master_error + 1;
  if (rsens[resp] == SENS_STOP)
    scvip_ahb_master_stop(0, 2'b01, resp_string);
end
endtask

function [8*8-1:0] to_string_ttype (input [4:0] cycle, input [1:0] btype);
begin
  // Transfer Type
  if (cycle == 5'h1)
    to_string_ttype = "(SINGLE)";
  else if (btype == 2'b11)
    to_string_ttype = "(INCR)  ";
  case ({btype, cycle})
    7'b01_00100: to_string_ttype = "(INCR4) ";
    7'b01_01000: to_string_ttype = "(INCR8) ";
    7'b01_10000: to_string_ttype = "(INCR16)";
    7'b10_00100: to_string_ttype = "(WRAP4) ";
    7'b10_01000: to_string_ttype = "(WRAP8) ";
    7'b10_10000: to_string_ttype = "(WRAP16)";
  endcase
end
endfunction

function [8*5-1:0] to_string_size (input [2:0] size);
begin
  case (size)
    3'b001: to_string_size = "1Byte";
    3'b010: to_string_size = "2Byte";
    3'b100: to_string_size = "4Byte";
  endcase
end
endfunction

function [8*5-1:0] to_string_resp (input [1:0] resp);
begin
  case (resp)
    2'b00: to_string_resp = "OKAY ";
    2'b01: to_string_resp = "ERROR";
    2'b10: to_string_resp = "RETRY";
    2'b11: to_string_resp = "SPLIT";
  endcase
end
endfunction

// System Handler
// -----------------------------------------------------------------------------------------------------
task PROTOCOL_ERR;
  input [30*8-1:0] message;
begin
  $display("scvip_ahb_master protocol error");
  $display("%s",message);
  repeat(5) @ (posedge HCLK);
  $finish();
end
endtask

// AHB Bus Model
// -----------------------------------------------------------------------------------------------------
// Reset
initial begin
  forever begin
    @ (negedge HRESETN);
    ahb_trans_bus_init();
  end
end

// task AHB_TRANS
// ----------------------------------------------------------------------
//  num_of_trans | 16bit | Number of transaction
//  addr         | 32bit | Address
//  write        |  1bit | Direction
//               |       |  1: write, 0: read
//  btype        |  2bit | Burst type
//               |       |  11: Incrementing burst of unspecified length,
//               |       |  01: Incrementing burst
//               |       |  10: Wrapping burst
//  size         |  3bit | Data Size
//               |       |  001: 1byte, 010: 2byte, 100: 4byte
//  cycle        |  5bit | Number of transaction cycle (Burst beat)
//               |       |  00001: 1beat (single) - 10000: 16beat
//  data         | 16bit | Write data value or Expected value of read data

reg [1:0] ahb_trans_data_phase_resp;
task AHB_TRANS;
  input [15:0] num_of_trans;
  input [32*SCVIP_AHBM_MAX_TRANS_CYCLE:0] addr;
  input [SCVIP_AHBM_MAX_TRANS_CYCLE-1:0] write;
  input [2*SCVIP_AHBM_MAX_TRANS_CYCLE-1:0] btype;
  input [3*SCVIP_AHBM_MAX_TRANS_CYCLE-1:0] size;
  input [5*SCVIP_AHBM_MAX_TRANS_CYCLE-1:0] cycle;
  input [32*SCVIP_AHBM_MAX_TRANS_CYCLE:0] data;
  input [32*SCVIP_AHBM_MAX_TRANS_CYCLE:0] mask;

  reg end_of_loop;
  reg first_cycle;
  reg [15:0] trans_number;
  reg step_number;
  reg [15:0] trans_pointer;
  reg [15:0] data_pointer;
  reg [31:0] c_addr;
  reg c_write;
  reg [2:0] c_size;
  reg [4:0] c_cycle;
  reg [1:0] c_btype;
  reg [31:0] c_data;
  reg [31:0] c_mask;
  reg [15:0] c_pt_head;
  reg [4:0] trans_cycle;
  reg [31:0] d_addr;
  reg d_write;
  reg [2:0] d_size;
  reg [4:0] d_cycle;
  reg [1:0] d_btype;
  reg [31:0] d_data;
  reg [31:0] d_mask;
  reg [15:0] d_pt_head;
  reg [4:0] data_cycle;
  reg [1:0] ad_valid;
  reg [1:0] ad_update;
  reg [1:0] next_ad_idle;
begin
  // Signal initialize
  end_of_loop   = 0;
  first_cycle   = 1;
  trans_cycle   = 0;
  c_cycle       = 0;
  trans_pointer = 0;
  data_pointer  = 0;
  trans_number  = 1;
  step_number   = 0;
  ad_update     = 2'b10;
  next_ad_idle  = 0;
  ad_valid      = 2'b00;

  // Data Transfer
  while (!end_of_loop) begin

    @ (posedge HCLK);
    #1;

    // Output New Data
    // ---------------
    if (ad_update[0]) begin
      d_addr    = c_addr;
      d_write   = c_write;
      d_size    = c_size;
      d_cycle   = c_cycle;
      d_btype   = c_btype;
      d_data    = c_data;
      d_mask    = c_mask;
      d_pt_head = c_pt_head;
      data_cycle = trans_cycle;
      if (c_write)
        ahb_trans_wr_data_phase(c_data);
      else
        ahb_trans_wr_data_phase(32'h0000_0000);
      ad_update[0] = 0;
      ad_valid[0] = 1;
    end

    // Output New Address
    //-------------------
    if (ad_update[1]) begin
      if (|next_ad_idle) begin
        ahb_trans_addr_phase_idle();
        next_ad_idle[1] = 0;
        if (next_ad_idle[0])
          end_of_loop = 1;
      end
      else begin
        if (first_cycle) begin
          c_addr    = addr [32*trans_pointer +:32];
          c_write   = write[   trans_pointer +: 1];
          c_size    = size [ 3*trans_pointer +: 3];
          c_cycle   = cycle[ 5*trans_pointer +: 5];
          c_btype   = btype[ 2*trans_pointer +: 2];
          c_data    = data[32*trans_pointer +:32];
          c_mask    = mask[32*trans_pointer +:32];
          c_pt_head = trans_pointer;
          ahb_trans_addr_phase_first_cycle(c_addr, c_write, c_size, c_cycle, c_btype);
          trans_cycle = 1;
          first_cycle = 0;
        end
        else begin
          ahb_trans_addr_phase(c_addr, c_size, c_btype);
          c_addr = HADDR;
          c_data = data[32*trans_pointer +:32];
          c_mask = mask[32*trans_pointer +:32];
          trans_cycle = trans_cycle + 1;
        end
        trans_pointer = trans_pointer + 1;
        if (trans_number == num_of_trans & c_cycle == trans_cycle)
          next_ad_idle[0] = 1;
      end
      ad_valid[1] = 1;
      ad_update[1] = 0;
    end

    @ (negedge HCLK);
    #1;

    // Address Data Control
    // --------------------
    ahb_trans_check_resp();
    if (ad_valid[1]) begin
      ad_valid[1] = 0;
      if (!HREADY) begin
        // HRESP: RETRY
        if (ahb_trans_data_phase_resp == HR_RETRY) begin
          ad_update[1] = 1;
          next_ad_idle = 2'b10;
          end_of_loop = 0;
        end
        // If it is OKYA or ERROR response and !HREADY, it waits in ahb_trans_check_resp.
      end
      else begin
        // HRESP: OKAY, ERROR
        if (ahb_trans_data_phase_resp == HR_OKAY |
            ahb_trans_data_phase_resp == HR_ERROR) begin
          ad_valid[1] = 0;
          ad_update = 2'b11;
          step_number = 0;
          if (trans_cycle == c_cycle) begin
            first_cycle = 1;
            trans_number = trans_number + 1;
            step_number = 1;
          end
        end
        // HRESP: RETRY
        else if (ahb_trans_data_phase_resp == HR_RETRY) begin
          ad_valid[1] = 0;
          ad_update = 2'b10;
          first_cycle = 1;
          if (step_number)
            trans_number = trans_number - 1;
          trans_pointer = d_pt_head;
          data_pointer = d_pt_head;
          end_of_loop = 0;
        end
      end
    end

    // Responce Check
    // --------------
    if (ad_valid[0]) begin
      if (d_write)
        ahb_trans_data_phase_wr_check_resp(d_addr, d_size, d_btype, d_cycle, d_data, data_cycle);
      else
        ahb_trans_data_phase_rd_check_data_and_resp(d_addr, d_size, d_btype, d_cycle, d_data, d_mask, data_cycle);

      if (HREADY) begin
        ad_valid[0]  = 0;
        if (ahb_trans_data_phase_resp != HR_RETRY) begin
          if (d_write)
            TRANSDATA[32*data_pointer +:32] = HWDATA;
          else
            TRANSDATA[32*data_pointer +:32] = HRDATA;
          data_pointer = data_pointer + 1;
        end
      end
    end
  end
  @ (posedge HCLK);
  ahb_trans_bus_init();
end
endtask

task ahb_trans_bus_init;
begin
  HADDR  = 32'h0;
  HTRANS = 2'h0;
  HWRITE = 1'b0;
  HSIZE  = 3'h0;
  HBURST = 3'h0;
  HWDATA = 32'h0;
end
endtask

task ahb_trans_addr_phase_first_cycle;
  input [31:0] addr;
  input write;
  input [2:0] size;
  input [4:0] cycle;
  input [1:0] btype;
begin
  HADDR = addr;
  HTRANS = HT_NONSEQ;
  HWRITE = write;
  case (size)
    3'h1: HSIZE = HS_1BYTE;
    3'h2: HSIZE = HS_2BYTE;
    3'h4: HSIZE = HS_4BYTE;
    default: PROTOCOL_ERR("HSIZE");
  endcase

  if (cycle == 4'b0001)
    HBURST = HB_SINGLE;
  else if (btype == 2'b11)
    HBURST = HB_INCR;
  else begin
    case ({btype, cycle})
      7'b01_00100: HBURST = HB_INCR4;
      7'b01_01000: HBURST = HB_INCR8;
      7'b01_10000: HBURST = HB_INCR16;
      7'b10_00100: HBURST = HB_WRAP4;
      7'b10_01000: HBURST = HB_WRAP8;
      7'b10_10000: HBURST = HB_WRAP16;
      default: PROTOCOL_ERR("HBURST");
    endcase
  end
end
endtask

task ahb_trans_addr_phase;
  input [31:0] addr;
  input [2:0] size;
  input [1:0] btype;
begin
  if (btype == 2'b00 | btype == 2'b01)
    HADDR = addr + size;
  HTRANS = HT_SEQ;
end
endtask

task ahb_trans_addr_phase_idle;
begin
  HTRANS = HT_IDLE;
  HWRITE = 1'b0;
  HBURST = HB_SINGLE;
end
endtask

task ahb_trans_wr_data_phase;
  input [31:0] wdata;
begin
  HWDATA = wdata;
end
endtask

task ahb_trans_check_resp;
begin
  while (!HREADY & (HRESP == HR_OKAY | HRESP == HR_ERROR)) begin
    @ (posedge HCLK);
    #1;
  end
  ahb_trans_data_phase_resp = HRESP;
end
endtask

task ahb_trans_data_phase_wr_check_resp;
  input [31:0] addr;
  input [2:0] size;
  input [1:0] btype;
  input [4:0] cycle;
  input [31:0] wdata;
  input [4:0] trans_cycle;
begin
  if (HREADY & HRESP == HR_OKAY)
    display_ahb_wr(addr, size, btype, cycle, wdata, trans_cycle, HRESP);
  else if (HREADY & HRESP == HR_RETRY)
    display_ahb_wr(addr, size, btype, cycle, wdata, trans_cycle, HRESP);
  else if (HREADY & HRESP == HR_ERROR)
    display_ahb_wr(addr, size, btype, cycle, wdata, trans_cycle, HRESP);
  else if (HREADY & HRESP == HR_SPLIT)
    display_ahb_wr(addr, size, btype, cycle, wdata, trans_cycle, HRESP);
end
endtask

reg [31:0] dispmask;
task ahb_trans_data_phase_rd_check_data_and_resp;
  input [31:0] addr;
  input [2:0] size;
  input [1:0] btype;
  input [4:0] cycle;
  input [31:0] expdata;
  input [31:0] mask;
  input [4:0] trans_cycle;
  reg [31:0] rdmask;
  reg result;
  reg [31:0] disp_rdata;
  reg [31:0] disp_edata;
begin
  result = 1'bx;
  if (HREADY & HRESP == HR_OKAY) begin
    rdmask     = mask & ahb_trans_create_rd_mask(addr, size);
    result     = ahb_trans_check_rd_data(HRDATA, expdata, rdmask);
    ahb_trans_convert_mask(rdmask);
    disp_rdata = dispmask | (HRDATA & rdmask);
    disp_edata = dispmask | (expdata & rdmask);
    display_ahb_rd(addr, size, btype, cycle, disp_rdata, disp_edata, result, trans_cycle, HRESP);
  end
  else if (HREADY & HRESP == HR_RETRY)
    display_ahb_rd(addr, size, btype, cycle, HRDATA, expdata, result, trans_cycle, HRESP);
  else if (HREADY & HRESP == HR_ERROR)
    display_ahb_rd(addr, size, btype, cycle, HRDATA, expdata, result, trans_cycle, HRESP);
  else if (HREADY & HRESP == HR_SPLIT)
    display_ahb_rd(addr, size, btype, cycle, HRDATA, expdata, result, trans_cycle, HRESP);
end
endtask

task ahb_trans_convert_mask;
  input [31:0] rdmask;
begin
  dispmask = 32'hXXXX_XXXX;
  if (|rdmask[3:0])   dispmask[3:0]   = 4'h0;
  if (|rdmask[7:4])   dispmask[7:4]   = 4'h0;
  if (|rdmask[11:8])  dispmask[11:8]  = 4'h0;
  if (|rdmask[15:12]) dispmask[15:12] = 4'h0;
  if (|rdmask[19:16]) dispmask[19:16] = 4'h0;
  if (|rdmask[23:20]) dispmask[23:20] = 4'h0;
  if (|rdmask[27:24]) dispmask[27:24] = 4'h0;
  if (|rdmask[31:28]) dispmask[31:28] = 4'h0;
end
endtask

function [31:0] ahb_trans_create_rd_mask (
  input [31:0] addr,
  input [2:0]  size
);
begin
  if (size == 3'b010 & addr[1:0] == 2'b00)
    ahb_trans_create_rd_mask = 32'h0000_FFFF;
  else if (size == 3'b010 & addr[1:0] == 2'b10)
    ahb_trans_create_rd_mask = 32'hFFFF_0000;
  else if (size == 3'b001 & addr[1:0] == 2'b00)
    ahb_trans_create_rd_mask = 32'h0000_00FF;
  else if (size == 3'b001 & addr[1:0] == 2'b01)
    ahb_trans_create_rd_mask = 32'h0000_FF00;
  else if (size == 3'b001 & addr[1:0] == 2'b10)
    ahb_trans_create_rd_mask = 32'h00FF_0000;
  else if (size == 3'b001 & addr[1:0] == 2'b11)
    ahb_trans_create_rd_mask = 32'hFF00_0000;
  else
    ahb_trans_create_rd_mask = 32'hFFFF_FFFF;
end
endfunction

function ahb_trans_check_rd_data (
  input [31:0] rdata,
  input [31:0] expdata,
  input [31:0] mask
);
begin
  ahb_trans_check_rd_data = ((rdata & mask) == (expdata & mask));
end
endfunction

endmodule
