`timescale 1ps/1ps

module pic (
  input FPGA_CFG_MEM,
  input FPGA_PWR_CYCLE_REQ,
  output CFG_MEM_SEL
);

reg CFGMEMSEL = 0;
reg PIC_CFG_MEM = 0;

task CFG_MEM_MODE;
  input sw;
begin
  CFGMEMSEL = sw;
  if (sw)
    $display($time, " | PIC Configuration Mode: FPGA");
  else
    $display($time, " | PIC Configuration Mode: PIC");
end
endtask

assign CFG_MEM_SEL = (!CFGMEMSEL) ? PIC_CFG_MEM: FPGA_CFG_MEM;

task CHECK_PWR_CYCLE_REQ;
  input value;
begin
  if (FPGA_PWR_CYCLE_REQ === value)
    $display($time, " | PIC PWR_CYCLE_REQ CHECK OK (VALUE: %b)", value);
  else begin
    $display($time, " | PIC PWR_CYCLE_REQ CHECK NG (VALUE: %b, EXP: %b)", FPGA_PWR_CYCLE_REQ, value);
    $finish();
  end
end
endtask

endmodule
