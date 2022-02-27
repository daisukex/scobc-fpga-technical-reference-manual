`timescale 1ps/1ps

module testcase (
  `include "testcase_port.vh"
);

`include "sc_verification_task_pkg.vh"

assign testcase_name = "SC-OBC-CORE System Boot Check";
initial begin
  timeout_ms = 5;
  @ (posedge SYS_RSTB);

  //--------------------------------------------------
  label    = "Check CMC (clock mode change) Handshake";
  simcount = 0;
  //--------------------------------------------------
  @ (posedge CMC_REQ);
  @ (posedge CMC_ACK);
  display_text("Assert CMC_REQ/CMC_ACK", 1, 1);
  @ (posedge PLLLOCK);
  display_text("Assert PLLLOCK", 1, 1);
  @ (negedge CMC_REQ);
  @ (negedge CMC_ACK);
  display_text("Negate CMC_REQ/CMC_ACK", 1, 1);


  repeat (100) @ (posedge SYS_CLK);
  simfinish(0);
end

endmodule
