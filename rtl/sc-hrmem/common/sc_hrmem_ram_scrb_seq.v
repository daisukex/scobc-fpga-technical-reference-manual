//-----------------------------------------------
// Module: sc_hrmem_ram_scrb_seq
//  Space Cubics RAM Scrub Sequencer
//-----------------------------------------------
// Copyright © 2022 Space Cubics, LLC.
//-----------------------------------------------
module sc_hrmem_ram_scrb_seq # (
  parameter P_MEM_NUM = 4
) (
  // System Interface
  input                  CLK,
  input                  RESET_N,

  // Register Interface
  input                  ECC_COL_EN,
  input                  MEM_SCRB_EN,
  input  [15:0]          MEM_SCRB_CYCLE,

  // UNIT RAM Interface
  output [P_MEM_NUM-1:0] MEM_SCRB_ACT
);

reg [15:0]          mem_scrb_cycle_1p;
reg [15:0]          mem_scrb_cycle_cnt;
reg                 mem_scrb_val;
reg [P_MEM_NUM-1:0] mem_scrb_sel;

always @ (posedge CLK or negedge RESET_N) begin
  if (!RESET_N) begin
    mem_scrb_cycle_1p  <= 0;
    mem_scrb_cycle_cnt <= 0;
    mem_scrb_val       <= 0;
  end else begin
    mem_scrb_cycle_1p <= MEM_SCRB_CYCLE;
    if (ECC_COL_EN) begin
      if (MEM_SCRB_CYCLE <= mem_scrb_cycle_cnt) begin
        mem_scrb_cycle_cnt <= 0;
        mem_scrb_val       <= 1;
      end else begin
        mem_scrb_cycle_cnt <= mem_scrb_cycle_cnt + 1;
        mem_scrb_val       <= 0;
      end
    end else begin
      mem_scrb_cycle_cnt <= 0;
      mem_scrb_val       <= 0;
    end
  end
end

always @ (posedge CLK or negedge RESET_N) begin
  if (!RESET_N) begin
    mem_scrb_sel <= 0;
  end else if (ECC_COL_EN) begin
    if (~|MEM_SCRB_CYCLE)
      mem_scrb_sel <= {P_MEM_NUM{1'b1}};
    else if (MEM_SCRB_CYCLE != mem_scrb_cycle_1p)
      mem_scrb_sel <= 0;
    else if (P_MEM_NUM <= 1)
      mem_scrb_sel <= mem_scrb_val;
    else
      mem_scrb_sel <= {mem_scrb_sel[P_MEM_NUM-2:0], mem_scrb_val};
  end else begin
    mem_scrb_sel <= 0;
  end
end

assign MEM_SCRB_ACT = {P_MEM_NUM{MEM_SCRB_EN}} & mem_scrb_sel;

endmodule
