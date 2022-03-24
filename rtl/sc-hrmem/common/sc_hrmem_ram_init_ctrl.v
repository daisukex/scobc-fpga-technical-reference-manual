//-----------------------------------------------
// Module: sc_hrmem_ram_init_ctrl
//  Space Cubics BlockRAM Initialize Controller
//-----------------------------------------------
// Copyright © 2022 Space Cubics, LLC.
//-----------------------------------------------

module sc_hrmem_ram_init_ctrl # (
  parameter ADDR_WIDTH = 14,
  parameter MEM_DEPTH  = 12288,
  parameter ACC_INTVAL = 0
) (
  input  SYSCLK,
  input  RESETB,
  input  RAM_INIT_REQ,
  output reg [ADDR_WIDTH-1:0] RAM_INIT_ADDR,
  output RAM_INIT_EN,
  output reg RAM_INIT_DONE
);

reg init_acc_en;
reg [31:0] acc_itvl_cnt;

// RAM Initialize Address/Enable/Done
always @ (posedge SYSCLK or negedge RESETB) begin
  if (!RESETB) begin
    init_acc_en   <= 0;
    acc_itvl_cnt  <= 0;
    RAM_INIT_ADDR <= 0;
    RAM_INIT_DONE <= 0;
  end
  else if (~RAM_INIT_DONE) begin
    if (init_acc_en) begin
      acc_itvl_cnt <= acc_itvl_cnt + 1;
      if (acc_itvl_cnt >= ACC_INTVAL) begin
        acc_itvl_cnt  <= 0;
        RAM_INIT_ADDR <= RAM_INIT_ADDR + 1;
        if (RAM_INIT_ADDR >= MEM_DEPTH -1) begin
          init_acc_en   <= 0;
          RAM_INIT_ADDR <= 0;
          RAM_INIT_DONE <= 1;
        end
      end
    end
    else if (RAM_INIT_REQ)
      init_acc_en <= 1;
  end
end

assign RAM_INIT_EN = init_acc_en & (acc_itvl_cnt >= ACC_INTVAL);

endmodule
