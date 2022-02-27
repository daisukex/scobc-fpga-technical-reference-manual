//-----------------------------------------------
// Space Cubics SC-OBC-A1
// SC-OBC-A1 Reset Generator
// Module: scobca1_rst_gen
//-----------------------------------------------
// Copyright © 2021 Space Cubics, LLC.
//-----------------------------------------------

module scobca1_rst_gen # (
  parameter RESET_COUNTER_BIT = 6,
  parameter RESET_COUNTER_MAX = 64,
  parameter BUS_RESET_COUNT = 32,
  parameter SYS_RESET_COUNT = 64,
  parameter POR_RESET_COUNT = 64
) (
  input REF_CLK,
  input SYS_CLK,
  input USER_CLK1,
  input USER_CLK2,
  input REF_RSTB,
  input SYS_RST_REQ,
  input REG_RST_REQ,
  input CPU_LOCKUP,
  input CPU_LOCKUP_RSTEN,
  input CLK_OK,
  input INIT_DONE,
  output INIT_REQ,
  output POR_RSTB,
  output POR_RSTB_SYNC_REFCLK,
  output SYS_RSTB,
  output SYS_RSTB_SYNC_REFCLK,
  output SYS_RSTB_SYNC_USERCLK1,
  output SYS_RSTB_SYNC_USERCLK2,
  output BUS_RSTB
);

wire cpu_rst_req;
wire reg_rst_req;
wire cpu_lockup_rst;
wire lockup_rst;
wire cpu_rst;
wire por_rst;
wire sys_init_done;
assign cpu_lockup_rst = ~(CPU_LOCKUP & CPU_LOCKUP_RSTEN);

tmr_syncff # (.SYNCC(2), .SRVAL(1'b0))
sync_cpu_rst_req (.D_AS(~SYS_RST_REQ), .CLK(REF_CLK), .SRB(REF_RSTB), .Q_SY(cpu_rst_req));
tmr_syncff # (.SYNCC(2), .SRVAL(1'b0))
sync_reg_rst_req (.D_AS(~REG_RST_REQ), .CLK(REF_CLK), .SRB(REF_RSTB), .Q_SY(reg_rst_req));
tmr_syncff # (.SYNCC(2), .SRVAL(1'b0))
sync_lockup_rst (.D_AS(cpu_lockup_rst), .CLK(REF_CLK), .SRB(REF_RSTB), .Q_SY(lockup_rst));
tmr_synclatch # (.SYNCC(2), .SRVAL(1'b0))
sync_init_done  (.D_AS(INIT_DONE), .CLK(REF_CLK), .SRB(REF_RSTB), .Q_SY(sys_init_done));

assign por_rst = REF_RSTB;
assign INIT_REQ = REF_RSTB;
assign cpu_rst = cpu_rst_req & reg_rst_req & lockup_rst;

// Reset Counter
//--------------------------------------------------
wire por_reset_latch;
wire cpu_reset_latch;
reg [RESET_COUNTER_BIT-1:0] reset_counter;
reg sys_reset;
reg bus_reset;
reg por_reset;
wire sys_reset_reg;
wire bus_reset_reg;
wire por_reset_reg;

tmr_ff # (.DW(1), .SRVAL(1'b0)) por_rst_ff (.D(por_rst), .CLK(REF_CLK), .SRB(1'b1), .Q(por_reset_latch));
tmr_ff # (.DW(1), .SRVAL(1'b0)) cpu_rst_ff (.D(cpu_rst), .CLK(REF_CLK), .SRB(1'b1), .Q(cpu_reset_latch));

always @ (posedge REF_CLK) begin
  if (!(por_reset_latch & sys_init_done) | !cpu_reset_latch)
    reset_counter <= 0;
  else if (CLK_OK) begin
    if (reset_counter != RESET_COUNTER_MAX -1)
      reset_counter <= reset_counter + 1;
  end
end

always @ (*) begin
  sys_reset = sys_reset_reg;
  bus_reset = bus_reset_reg;
  por_reset = por_reset_reg;
  if (!(por_reset_latch & sys_init_done)) begin
    sys_reset = 1'b0;
    bus_reset = 1'b0;
    por_reset = 1'b0;
  end
  else if (!cpu_reset_latch) begin
    sys_reset = 1'b0;
    bus_reset = 1'b0;
  end
  else begin
    if (reset_counter >= SYS_RESET_COUNT - 1)
      sys_reset = 1'b1;
    if (reset_counter >= BUS_RESET_COUNT - 1)
      bus_reset = 1'b1;
    if (reset_counter >= POR_RESET_COUNT - 1)
      por_reset = 1'b1;
  end
end

tmr_ff # (.DW(1), .SRVAL(1'b0)) por_rst_reg (.D(por_reset), .CLK(REF_CLK), .SRB(1'b1), .Q(por_reset_reg));
tmr_ff # (.DW(1), .SRVAL(1'b0)) cpu_rst_reg (.D(sys_reset), .CLK(REF_CLK), .SRB(1'b1), .Q(sys_reset_reg));
tmr_ff # (.DW(1), .SRVAL(1'b0)) bus_rst_reg (.D(bus_reset), .CLK(REF_CLK), .SRB(1'b1), .Q(bus_reset_reg));

tmr_syncff # (.SYNCC(2), .SRVAL(1'b0))
sync_por_rst (.D_AS(por_reset_reg), .CLK(SYS_CLK), .SRB(1'b1), .Q_SY(POR_RSTB));
assign POR_RSTB_SYNC_REFCLK = por_reset_reg;
tmr_syncff # (.SYNCC(2), .SRVAL(1'b0))
sync_cpu_rst (.D_AS(sys_reset_reg), .CLK(SYS_CLK), .SRB(1'b1), .Q_SY(SYS_RSTB));
assign SYS_RSTB_SYNC_REFCLK = sys_reset_reg;
tmr_syncff # (.SYNCC(2), .SRVAL(1'b0))
sync_sys_rst_uclk1 (.D_AS(sys_reset_reg), .CLK(USER_CLK1), .SRB(1'b1), .Q_SY(SYS_RSTB_SYNC_USERCLK1));
tmr_syncff # (.SYNCC(2), .SRVAL(1'b0))
sync_sys_rst_uclk2 (.D_AS(sys_reset_reg), .CLK(USER_CLK2), .SRB(1'b1), .Q_SY(SYS_RSTB_SYNC_USERCLK2));
tmr_syncff # (.SYNCC(2), .SRVAL(1'b0))
sync_bus_rst (.D_AS(bus_reset_reg), .CLK(SYS_CLK), .SRB(1'b1), .Q_SY(BUS_RSTB));

endmodule

