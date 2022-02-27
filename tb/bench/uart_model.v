`timescale 1ps/1ps

module uart_model (
  input  UART_RX,
  output UART_TX
);

// initialize
reg RESETB;
initial begin
  RESETB = 1'b0;
  #1;
  RESETB = 1'b1;
end

reg r_uart_tx = 1'b1;
assign UART_TX = r_uart_tx;

// Finish Control 0: not finish, 1: finish
reg fctrl;
task FINISH_CTRL;
  input SW;
begin
  fctrl = SW;
  if (fctrl)
    $display($time, " | %m Finish control enable");
  else
    $display($time, " | %m Finish control disable");
end
endtask

// UART Clock Period Control
reg [31:0] CLOCK_PERIOD = 32'd8680555;

task UART_CLK_PERIOD_CTL;
  input [31:0] CLK_PERI;
begin
  CLOCK_PERIOD = CLK_PERI;
  $display($time, " | %m UART Clock Period Setting: %d ps (BaudRate: %d bps)", CLOCK_PERIOD, (40'd1000000000000 / CLOCK_PERIOD));
end
endtask

reg UART_CLK;
initial begin
  UART_CLK = 0;
  #5;
  forever begin
    #(CLOCK_PERIOD/2);
    UART_CLK = ~UART_CLK;
  end
end

// UART Format Control
reg [3:0] D_BIT  = 4'd8;
reg       P_EN   = 1'd0;
reg [1:0] P_TYPE = 2'd0;
reg [1:0] S_BIT  = 2'd1;

task UART_FRAME_CTL;
  input [1:0] D_BIT_SEL;
  input       P_EN_SEL;
  input [1:0] P_TYPE_SEL;
  input       S_BIT_SEL;
begin
  D_BIT  = {2'b00, D_BIT_SEL} + 5;
  P_EN   = P_EN_SEL;
  P_TYPE = P_TYPE_SEL;
  S_BIT  = {1'b0, S_BIT_SEL}  + 1;
  $display($time, " | %m Flame Data bit Setting: %h bit", D_BIT);
  if (P_EN)
    case (P_TYPE)
      0       : $display($time, " | %m Flame Parity bit Setting: Even");
      1       : $display($time, " | %m Flame Parity bit Setting: Odd");
      2       : $display($time, " | %m Flame Parity bit Setting: Always '0'");
      default : $display($time, " | %m Flame Parity bit Setting: Always '1'");
    endcase
  else
    $display($time, " | %m Flame Parity bit Setting: Not Parity");
  $display($time, " | %m Flame Stop bit Setting: %h bit", S_BIT);
end
endtask

integer init_num;

// UART RX
//--------------------------------------------------------

// UART Receive Data Expected value comparison Setting 0: Disable, 1: Enable
reg rcv_data_exp_on = 0 ;
task RX_DATA_EXP_COMP_EN;
  input SW;
begin
  rcv_data_exp_on = SW;
  if (rcv_data_exp_on)
    $display($time, " | %m UART Receive Data Expected value comparison enable");
  else
    $display($time, " | %m UART Receive Data Expected value comparison disable");
end
endtask

// UART Receive Data Console Display Setting 0: Disable, 1: Enable
reg rcv_data_cns_on = 0 ;
task RX_DATA_CNS_DISP_EN;
  input SW;
begin
  rcv_data_cns_on = SW;
  if (rcv_data_cns_on)
    $display($time, " | %m UART Receive Data Console Display enable");
  else
    $display($time, " | %m UART Receive Data Console Display disable");
end
endtask

reg [7:0] rx_data_expdata [0:65535];
initial begin
  #1;
  for(init_num=0; init_num<65535; init_num=init_num+1) begin
    rx_data_expdata[init_num] = 8'h0;
  end
end

reg [15:0] bnum = 0;
task RX_DATA_EXP_VAL_SET;
  input [7:0] data;
begin
  rx_data_expdata[bnum] = data;
  bnum = bnum + 1;
end
endtask

parameter RX_IDLE = 2'b00,
          RX_DAT  = 2'b01,
          RX_PRTY = 2'b10,
          RX_STOP = 2'b11;

reg [31:0] rx_count;
reg        rx_valid;
reg  [7:0] rx_data;
reg        rx_dvalid;
reg        rx_parity;
reg  [1:0] rx_state;

// RX Clock Control
reg rx_clk_stop = 1;
reg UART_RXCLK = 0;
always @ (negedge UART_RX or posedge UART_RXCLK) begin
  if (UART_RX & UART_RXCLK & rx_state == RX_IDLE)
    rx_clk_stop = 1;
  if (~UART_RX & rx_clk_stop) begin
    #(CLOCK_PERIOD/2);
    rx_clk_stop = 0;
  end
end

initial begin
  UART_RXCLK = 0;
  forever begin
    if (rx_clk_stop)
      @ (negedge rx_clk_stop);
    else
      #(CLOCK_PERIOD/2);

    UART_RXCLK = 1;
    #(CLOCK_PERIOD/2);
    UART_RXCLK = 0;
  end
end

always @ (posedge UART_RXCLK or negedge RESETB) begin
  if (!RESETB) begin
    rx_count  <= 0;
    rx_valid  <= 1'b0;
    rx_data   <= 8'h00;
    rx_parity <= 1'b0;
    rx_dvalid <= 1'b0;
    rx_state  <= RX_IDLE;
  end else if (rx_state == RX_IDLE) begin
    rx_count  <= 0;
    rx_valid  <= 1'b0;
    rx_data   <= 8'h00;
    rx_parity <= 1'b0;
    rx_dvalid <= 1'b0;
    if (!UART_RX) begin
      rx_valid  <= 1'b1;
      rx_state  <= RX_DAT;
    end
  end else if (rx_state == RX_DAT) begin
    rx_count          <= rx_count + 1;
    rx_data[rx_count] <= UART_RX;
    rx_parity         <= rx_parity ^ UART_RX;
    if (rx_count == (D_BIT - 1)) begin
      rx_count  <= 0;
      if (P_EN)
        rx_state <= RX_PRTY;
      else
        rx_state <= RX_STOP;
    end
  end else if (rx_state == RX_PRTY) begin
    if ((P_TYPE[1] & UART_RX != P_TYPE[0]) | (~P_TYPE[1] & UART_RX != (rx_parity ^ P_TYPE[0]))) begin
      $display($time, " | %m RX: Parity Error!!!!!!");
      if (fctrl) begin
        #10000;
        $finish();
      end
    end
    rx_state <= RX_STOP;
  end else if (rx_state == RX_STOP) begin
    rx_count <= rx_count + 1;
    if (!UART_RX) begin
      $display($time, " | %m RX: Frame Error!!!!!!");
      if (fctrl) begin
        #10000;
        $finish();
      end
    end
    if (S_BIT != 2'b10 | rx_count != 0) begin
      rx_dvalid <= 1'b1;
      rx_state  <= RX_IDLE;
    end
  end
end

reg [15:0] rxbit_count;
always @ (posedge UART_CLK or negedge RESETB) begin
  if (!RESETB) begin
    rxbit_count <= 0;
  end else if (rx_dvalid) begin
    if (rcv_data_exp_on) begin
      if (rx_data != rx_data_expdata[rxbit_count]) begin
        $display($time, " | %m RX: Data ERROR!!!!!! RDATA:0x%h       | EXP_RDATA:0x%h", rx_data, rx_data_expdata[rxbit_count]);
        if (fctrl) begin
          #10000;
          $finish();
        end
      end else if (~rcv_data_cns_on) begin
        $display($time, " | %m RX: Data OK.         RDATA:0x%h", rx_data);
      end
    end else if (~rcv_data_cns_on) begin
      $display($time, " | %m RX: Data             RDATA:0x%h", rx_data);
    end
    if (rcv_data_cns_on) begin
      if (rx_data != 8'h0a)
        $write("%s", rx_data);
    end
    rxbit_count <= rxbit_count + 1;
  end
end

// UART TX
//--------------------------------------------------------
reg tx_trg = 0;
reg tx_en  = 0;
reg [7:0] txdata = 0;
reg tx_ins_ferr = 0;
reg tx_ins_perr = 0;
integer tx_count = 0;
reg tx_parbit = 0;

task UART_TX_TRANS;
  input [7:0] data;
  input       ins_ferr;
  input       ins_perr;
begin
  while (tx_en) begin
    #10;
  end
  txdata      = data;
  tx_ins_ferr = ins_ferr;
  tx_ins_perr = ins_perr;
  tx_trg      = 1; #10;
  tx_trg      = 0; #10;
end
endtask

always @ (posedge tx_trg) begin
  tx_en     = 1'b1;
  tx_parbit = 1'b0;
  @ (posedge UART_CLK);

  // START
  r_uart_tx  = 1'b0;

  // DATA
  tx_count    = 0;
  while(D_BIT > tx_count) begin
    @ (posedge UART_CLK);
    r_uart_tx = txdata[tx_count];
    tx_count  = tx_count + 1;
    tx_parbit = r_uart_tx ^ tx_parbit;
  end

  // PARITY
  if (P_EN) begin
    @ (posedge UART_CLK);
    if (P_TYPE[1]) r_uart_tx = P_TYPE[0] ^ tx_ins_perr;
    else           r_uart_tx = P_TYPE[0] ^ tx_parbit ^ tx_ins_perr;
  end

  // STOP
  if (S_BIT[1]) begin
    @ (posedge UART_CLK);
    r_uart_tx = 1'b1;
  end
  @ (posedge UART_CLK);
  if (tx_ins_ferr) r_uart_tx = 1'b0;
  else             r_uart_tx = 1'b1;

  // IDLE
  @ (posedge UART_CLK);
  r_uart_tx = 1'b1;
  tx_en     = 1'b0;
end

endmodule
