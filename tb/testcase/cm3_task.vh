wire [239:0] CM3_ISR = tb_top.dut.cm3_ss.cpu_wrapper.CORTEXM3INTEGRATION.INTISR;
wire [239:0] CM3_CLK = tb_top.dut.cm3_ss.cpu_wrapper.CORTEXM3INTEGRATION.HCLK;

task cm3_isr_check;
  input [7:0] isr;
  input [31:0] count_limit;
  reg [31:0] count;
begin
  while (~CM3_ISR[isr]) begin
    @ (posedge CM3_CLK);
    count = count + 1;
    if (count >= count_limit) begin
      display_text("Cortex-M3 Interrupt Assert Check Error", 1, 0);
      $display("ISR[%0d]", isr);
      repeat(100) @ (posedge SYS_CLK);
      simfinish(1);
    end
  end
end
endtask

task cm3_sys_ipcore_interrupt_check_and_write_clear;
  input [31:0] addr;
  input [32:0] interrupt_bit;
begin
  read_transaction( .master(2), .addr(addr), .expdata(interrupt_bit), .chkbit(interrupt_bit), .check(1));
  write_transaction(.master(2), .addr(addr),    .data(interrupt_bit));
  read_transaction( .master(2), .addr(addr), .expdata(32'h0000_0000), .chkbit(interrupt_bit), .check(1));
end
endtask
