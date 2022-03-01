//-----------------------------------------------
// Space Cubics Verification Task Package
//  Version 0.1
//-----------------------------------------------
// Copyright © 2022 Space Cubics, LLC.
//-----------------------------------------------

parameter TESTCASE_NAME_MAX_WORD_COUNT = 128;
parameter SIM_LABEL_MAX_WORD_COUNT = 128;
parameter DISPLAY_TEST_MAX_WORD_COUNT = 128;

wire [TESTCASE_NAME_MAX_WORD_COUNT*8-1:0] testcase_name;
reg [SIM_LABEL_MAX_WORD_COUNT*8-1:0] label;
integer simcount = 0;

initial begin: _print_testcase_name
  integer dc;
  $display();
  $write(" Simulation Start: ");
  for (dc=TESTCASE_NAME_MAX_WORD_COUNT; dc>=1; dc=dc-1) begin
    if (testcase_name[dc*8-8 +:8] != "")
      $write("%s", testcase_name[dc*8-8 +:8]);
  end
  $display();
  $display();
  $display("            Time[ps] | Simulation Log");
  display_divider(3);
end

always @ (simcount) begin: _print_label
  integer dc;
  if (simcount != 0) begin
    display_divider(2);
    $write("%d", $time);
    $write(" | SIMCOUNT: %d : ", simcount);
    for (dc=SIM_LABEL_MAX_WORD_COUNT; dc>=1; dc=dc-1) begin
      if (label[dc*8-8 +:8] != "")
        $write("%s", label[dc*8-8 +:8]);
    end
    $display();
  end
end

task display_text;
  input [DISPLAY_TEST_MAX_WORD_COUNT*8-1:0] text;
  input display_time;
  input newline;
  reg [31:0] dc;
begin
  if (display_time === 1)
    $write($time);
  else
    $write("                    ");
  $write(" | ");
  for (dc=DISPLAY_TEST_MAX_WORD_COUNT; dc>=1; dc=dc-1) begin
    if (text[dc*8-8 +:8] != "")
      $write("%s", text[dc*8-8 +:8]);
  end
  if (newline)
    $display();
end
endtask

task display_subcount_text;
  input [31:0] subcount;
  input [DISPLAY_TEST_MAX_WORD_COUNT*8-1:0] text;
  input display_time;
  reg [31:0] dc;
begin
    display_divider(3);
  if (display_time === 1)
    $write($time);
  else
    $write("                    ");
  $write(" | %0d-%0d. ", simcount, subcount);
  for (dc=DISPLAY_TEST_MAX_WORD_COUNT; dc>=1; dc=dc-1) begin
    if (text[dc*8-8 +:8] != "")
      $write("%s", text[dc*8-8 +:8]);
  end
  $display();
end
endtask

task display_divider;
  input [1:0] dtype;
begin
  case (dtype)
    2'h2: $display("==========================================================================================================================");
    2'h1: $display("--------------------------------------------------------------------------------------------------------------------------");
    2'h3: $display("---------------------+----------------------------------------------------------------------------------------------------");
    default: $display();
  endcase
end
endtask

task simfinish;
  input [31:0] error_count;
  reg [31:0] dc;
begin
  display_divider(2);
  if (error_count==0)
    $write(" Sim Finish: PASS ");
  else
    $write(" Sim Finish: FAIL ");

  for (dc=TESTCASE_NAME_MAX_WORD_COUNT; dc>=1; dc=dc-1) begin
    if (testcase_name[dc*8-8 +:8] != "")
      $write("%s", testcase_name[dc*8-8 +:8]);
  end
  $display("");
  if (error_count!=0)
    $display("           Error %d", error_count);
  display_divider(1);
  $finish();
end
endtask

reg [31:0] timeout_ms = 1000;
initial begin: timeout_check
  integer tc;
  integer toreg;
  tc = 0;
  toreg = timeout_ms;
  forever begin
    // Update timeout_ms variable
    if (toreg != timeout_ms) begin
      toreg = timeout_ms;
      tc = 0;
    end

    // Timeout check
    if (timeout_ms <= tc) begin
      $display($time, " | Timeout Detect (%d [ms])", tc);
      $display("                     | Simulation finish");
      simfinish(1);
    end
    #(1_000_000_000);
    tc = tc + 1;
  end
end

