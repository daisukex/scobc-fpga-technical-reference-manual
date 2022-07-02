`timescale 1ps/1ps

module pic (
  input FPGA_CFG_MEM,
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

endmodule
