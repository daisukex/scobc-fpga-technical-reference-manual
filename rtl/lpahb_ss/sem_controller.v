//-----------------------------------------------
// Space Cubics OBC Core
//  Soft Error Mitigation Controller
//  Module: sem_controller
//-----------------------------------------------
// Copyright © 2022 Space Cubics, LLC.
//-----------------------------------------------

module sem_controller (
  input CLK,
  input RSTB,
  output [4:0] SEM_CURRENT_STATUS,
  output reg [4:0] SEM_PREVIOUS_STATUS,
  output reg SEM_STATUS_CHANGE,
  input [7:0] HEARTBEAT_TIMEOUT,
  output reg HEARTBEAT_TIMEOUT_DETECT,
  output reg HALTED_DETECT,
  output reg UNCORRECT_DETECT,
  output reg ECORRECT_DETECT,
  input INJECT_REQ,
  output reg INJECT_ACK,
  input [39:0] INJECT_ADDRESS
);

wire status_heartbeat;
wire status_initialization;
wire status_observation;
wire status_correction;
wire status_classification;
wire status_injection;
wire status_uncorrectable;
assign SEM_CURRENT_STATUS = {status_injection, status_classification, status_correction,
                             status_observation, status_initialization};
wire status_idle = ~status_initialization & ~status_observation &
                   ~status_correction & ~status_classification &
                   ~status_injection;
wire status_halt = status_initialization & status_observation &
                   status_correction & status_classification &
                   status_injection;

wire [31:0] icap_o;
wire icap_csib;
wire icap_rdwrb;
wire [31:0] icap_i;
wire fecc_crcerr;
wire fecc_eccerr;
wire fecc_eccerrsingle;
wire fecc_syndromevalid;
wire [12:0] fecc_syndrome;
wire [25:0] fecc_far;
wire [4:0] fecc_synbit;
wire [6:0] fecc_synword;

// SEM Status Control
// ----------------------------------------
reg [4:0] sem_status_1p;
reg [2:0] status_change_p;
reg [2:0] status_halt_p;
always @ (posedge CLK) begin
  if (!RSTB) begin
    sem_status_1p <= 5'h0;
    SEM_PREVIOUS_STATUS <= 0;
    status_change_p <= 3'b000;
    status_halt_p <= 3'b000;
    SEM_STATUS_CHANGE <= 1'b0;
    HALTED_DETECT <= 1'b0;
  end
  else begin
    sem_status_1p <= SEM_CURRENT_STATUS;
    status_change_p <= {status_change_p[1:0], 1'b0};
    SEM_STATUS_CHANGE <= (status_change_p[2:1] != 2'b00);
    status_halt_p <= {status_halt_p[1:0], 1'b0};
    HALTED_DETECT <= (status_halt_p[2:1] != 2'b00);
    if (sem_status_1p != SEM_CURRENT_STATUS) begin
      status_halt_p[0] <= status_halt;
      SEM_PREVIOUS_STATUS <= sem_status_1p;
      status_change_p[0]    <= 1'b1;
    end
  end
end

// SEM Heartbeat pulse checker
// ----------------------------------------
reg [7:0] heartbeat_counter;
reg [2:0] hertbeat_timeout_p;
reg first_pulse_detect;
always @ (posedge CLK) begin
  if (!RSTB) begin
    first_pulse_detect <= 1'b0;
    heartbeat_counter <= 8'h00;
    HEARTBEAT_TIMEOUT_DETECT <= 1'b0;
  end
  else if (!status_observation)
    heartbeat_counter <= 8'h00;
  else begin
    hertbeat_timeout_p <= {hertbeat_timeout_p[1:0], 1'b0};
    HEARTBEAT_TIMEOUT_DETECT <= (hertbeat_timeout_p[2:1] != 2'b00);
    if (status_heartbeat) begin
      first_pulse_detect <= 1'b1;
      heartbeat_counter <= 8'h00;
    end
    else if (heartbeat_counter == HEARTBEAT_TIMEOUT) begin
      hertbeat_timeout_p[0] <= 1'b1;
      heartbeat_counter <= 8'h00;
    end
    else if (first_pulse_detect)
      heartbeat_counter <= heartbeat_counter + 1;
  end
end

// SEM Error Correct/Uncorrect Detect
// ----------------------------------------
reg status_correction_1p;
reg [2:0] corectable_p;
reg [2:0] uncorectable_p;
always @ (posedge CLK) begin
  if (!RSTB) begin
    status_correction_1p <= 1'b0;
    ECORRECT_DETECT <= 1'b0;
    UNCORRECT_DETECT <= 1'b0;
    corectable_p <= 3'b000;
    uncorectable_p <= 3'b000;
  end
  else begin
    status_correction_1p <= status_correction;
    corectable_p <= {corectable_p[1:0], 1'b0};
    ECORRECT_DETECT <= (corectable_p[2:1] != 2'b00);
    uncorectable_p <= {uncorectable_p[1:0], 1'b0};
    UNCORRECT_DETECT <= (uncorectable_p[2:1] != 2'b00);
    if (status_correction_1p & ~status_correction) begin
      if (status_uncorrectable)
        uncorectable_p[0] <= 1'b1;
      else
        corectable_p[0] <= 1'b1;
    end
  end
end

// SEM Error Injection Command Control
// ----------------------------------------
reg [2:0] inject_req_p;
reg einject_pulse;
always @ (posedge CLK) begin
  if (!RSTB) begin
    einject_pulse <= 1'b0;
    inject_req_p  <= 3'b000;
    INJECT_ACK    <= 1'b0;
  end
  else begin
    inject_req_p <= {inject_req_p[1:0], INJECT_REQ};
    einject_pulse <= ~inject_req_p[2] & inject_req_p[1];
    if (!inject_req_p[1])
      INJECT_ACK <= 1'b0;
    else if (einject_pulse)
      INJECT_ACK <= 1'b1;
  end
end

sem_core sem_core (
  .status_heartbeat(status_heartbeat),
  .status_initialization(status_initialization),
  .status_observation(status_observation),
  .status_correction(status_correction),
  .status_classification(status_classification),
  .status_injection(status_injection),
  .status_essential(/*open*/),
  .status_uncorrectable(status_uncorrectable),
  .monitor_txdata(/*open*/),
  .monitor_txwrite(/*open*/),
  .monitor_txfull(1'b0),
  .monitor_rxdata(8'h0),
  .monitor_rxread(/*open*/),
  .monitor_rxempty(1'b1),
  .inject_strobe(einject_pulse),
  .inject_address(INJECT_ADDRESS),
  .icap_o(icap_o),
  .icap_csib(icap_csib),
  .icap_rdwrb(icap_rdwrb),
  .icap_i(icap_i),
  .icap_clk(CLK),
  .icap_request(/*open*/),
  .icap_grant(1'b1),
  .fecc_crcerr(fecc_crcerr),
  .fecc_eccerr(fecc_eccerr),
  .fecc_eccerrsingle(fecc_eccerrsingle),
  .fecc_syndromevalid(fecc_syndromevalid),
  .fecc_syndrome(fecc_syndrome),
  .fecc_far(fecc_far),
  .fecc_synbit(fecc_synbit),
  .fecc_synword(fecc_synword)
);

ICAPE2 icape2 (
  .CLK(CLK),
  .CSIB(icap_csib),
  .I(icap_i),
  .O(icap_o),
  .RDWRB(icap_rdwrb)
);

FRAME_ECCE2 frame_ecce2 (
  .CRCERROR(fecc_crcerr),
  .ECCERROR(fecc_eccerr),
  .ECCERRORSINGLE(fecc_eccerrsingle),
  .FAR(fecc_far),
  .SYNBIT(fecc_synbit),
  .SYNDROME(fecc_syndrome),
  .SYNDROMEVALID(fecc_syndromevalid),
  .SYNWORD(fecc_synword)
);

endmodule
