//-----------------------------------------------
// Space Cubics General Purpose Timer
// Module: sc_gptmr_syncreg
//  Synchronizing Signals to Registers
//-----------------------------------------------
// Copyright © 2022 Space Cubics, LLC.
//-----------------------------------------------

module sc_gptmr_syncreg # (
  parameter ADDR_WIDTH = 16
) (
  // AHB Slave Interface
  input REG_CLK,
  input REG_RSTB,

  // Write Channel
  input REG_WAEN,
  input [ADDR_WIDTH-1:0] REG_WADR,
  input [3:0] REG_WENB,
  input [31:0] REG_WDAT,
  output reg REG_WWAT,
  // Read Channel
  input REG_RAEN,
  input [ADDR_WIDTH-1:0] REG_RADR,
  input REG_RENB,
  output [31:0] REG_RDAT,
  output reg REG_RWAT,

  // Synchronous Interface
  input SYNC_CLK,
  input SYNC_RSTB,
  //  Write Channel
  output [ADDR_WIDTH-1:0] SYNC_WADR,
  output [3:0] SYNC_WENB,
  output [31:0] SYNC_WDAT,
  // Read Channel
  output [ADDR_WIDTH-1:0] SYNC_RADR,
  output reg SYNC_RENB,
  input [31:0] SYNC_RDAT,
  input SYNC_RDVD
);

// Register Write Channel
// ----------------------------------------
reg [ADDR_WIDTH-1:0] latch_wadr;
reg [3:0] latch_wenb;
reg [31:0] latch_wdat;
reg write_req_toggle;
reg [1:0] reg_wack_p;
always @ (posedge REG_CLK) begin
  if (!REG_RSTB) begin
    write_req_toggle <= 1'b0;
    REG_WWAT <= 1'b0;
  end
  else if (reg_wack_p[1] != reg_wack_p[0])
    REG_WWAT <= 1'b0;
  else if (REG_WAEN & |REG_WENB & !REG_WWAT) begin
    latch_wadr <= REG_WADR;
    latch_wenb <= REG_WENB;
    latch_wdat <= REG_WDAT;
    write_req_toggle <= ~write_req_toggle;
    REG_WWAT <= 1'b1;
  end
end

reg sync_reg_wack;
reg write_ack_toggle;
always @ (posedge REG_CLK) begin
  if (!REG_RSTB) begin
    sync_reg_wack <= 1'b0;
    reg_wack_p <= 2'b00;
  end
  else begin
    sync_reg_wack <= write_ack_toggle;
    reg_wack_p <= {reg_wack_p[0], sync_reg_wack};
  end
end

reg sync_reg_wreq;
reg [1:0] reg_wreq_p;
wire writing_reg = reg_wreq_p[1] != reg_wreq_p[0];
always @ (posedge SYNC_CLK) begin
  if (!SYNC_RSTB) begin
    sync_reg_wreq <= 1'b0;
    reg_wreq_p <= 2'b00;
    write_ack_toggle <= 1'b0;
  end
  else begin
    sync_reg_wreq <= write_req_toggle;
    reg_wreq_p <= {reg_wreq_p[0], sync_reg_wreq};
    if (writing_reg)
      write_ack_toggle <= ~write_ack_toggle;
  end
end
assign SYNC_WENB = writing_reg ? latch_wenb: 4'b0000;
assign SYNC_WADR = latch_wadr;
assign SYNC_WDAT = latch_wdat;

// Register Read Channel
// ----------------------------------------
reg [ADDR_WIDTH-1:0] latch_radr;
reg read_req_toggle;
reg [1:0] reg_rack_p;
always @ (posedge REG_CLK) begin
  if (!REG_RSTB) begin
    read_req_toggle <= 1'b0;
    REG_RWAT <= 1'b0;
  end
  else if (reg_rack_p[1] != reg_rack_p[0])
    REG_RWAT <= 1'b0;
  else if (REG_RAEN & REG_RENB & !REG_RWAT) begin
    latch_radr <= REG_RADR;
    read_req_toggle <= ~read_req_toggle;
    REG_RWAT <= 1'b1;
  end
end

reg sync_reg_rack;
reg read_ack_toggle;
always @ (posedge REG_CLK) begin
  if (!REG_RSTB) begin
    sync_reg_rack <= 1'b0;
    reg_rack_p <= 2'b00;
  end
  else begin
    sync_reg_rack <= read_ack_toggle;
    reg_rack_p <= {reg_rack_p[0], sync_reg_rack};
  end
end

reg sync_reg_rreq;
reg [1:0] reg_rreq_p;
always @ (posedge SYNC_CLK) begin
  if (!SYNC_RSTB) begin
    sync_reg_rreq <= 1'b0;
    reg_rreq_p <= 2'b00;
  end
  else begin
    sync_reg_rreq <= read_req_toggle;
    reg_rreq_p <= {reg_rreq_p[0], sync_reg_rreq};
  end
end

assign SYNC_RADR = latch_radr;
reg [31:0] latch_rdat;
always @ (posedge SYNC_CLK) begin
  if (!SYNC_RSTB) begin
    SYNC_RENB <= 1'b0;
    latch_rdat <= 32'h0000_0000;
    read_ack_toggle <= 1'b0;
  end
  if (SYNC_RENB & SYNC_RDVD) begin
    SYNC_RENB <= 1'b0;
    latch_rdat <= SYNC_RDAT;
    read_ack_toggle <= ~read_ack_toggle;
  end
  else if (reg_rreq_p[1] != reg_rreq_p[0])
    SYNC_RENB <= 1'b1;
end
assign REG_RDAT = latch_rdat;

endmodule
