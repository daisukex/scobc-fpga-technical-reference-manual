//-----------------------------------------------
// Module: uart_rx_sync
// Space Cubics UART Core Recive Synchronizer
//-----------------------------------------------
// Copyright © 2018 Space Cubics, LLC.
//-----------------------------------------------
module uart_rx_sync (
  input  SYSCLK,
  input  RESETB,
  input  RXEN,
  input  UART_RX,
  input  RXCOMPLITE,
  output SYNC_RX_DATA,
  output SYNC_RX_TIM,
  input  [15:0] DIVIDER_RATE
);

// RX Signal Retiming
reg [1:0] rx_retime;
reg [2:0] rx_sampling;
always @ (posedge SYSCLK or negedge RESETB)
begin
  if (!RESETB) begin
    rx_retime   <= 2'b11;
    rx_sampling <= 3'b111;
  end
  else begin
    if (RXEN)
      rx_retime <= {rx_retime[0], UART_RX};
    else
      rx_retime <= {rx_retime[0], 1'b1};

    rx_sampling <= {rx_sampling[1:0], rx_retime[1]};
  end
end

reg rx_logic1;
wire [3:0] rx_sampdata;
assign rx_sampdata = {rx_sampling[2:0], rx_retime[1]};
always @ (posedge SYSCLK or negedge RESETB)
begin
  if (!RESETB) begin
    rx_logic1 <= 1'b1;
  end
  else begin
    if (rx_sampdata == 4'hF) begin
      rx_logic1 <= 1'b1;
    end
    if (rx_sampdata == 4'h0) begin
      rx_logic1 <= 1'b0;
    end
  end
end

// Clock Counter
reg [15:0] counter;
reg rxactive;
always @ (posedge SYSCLK or negedge RESETB)
begin
  if (!RESETB)
    counter <= 16'h0;
  else if (~rxactive | counter == DIVIDER_RATE)
    counter <= 16'h0;
  else
    counter <= counter + 1;
end

// RX Control
always @ (posedge SYSCLK or negedge RESETB)
begin
  if (!RESETB)
    rxactive <= 1'b0;
  else if (RXCOMPLITE)
    rxactive <= 1'b0;
  else if (~rxactive & rx_sampdata == 4'h0)
    rxactive <= 1'b1;
end

assign SYNC_RX_DATA = rx_logic1;
assign SYNC_RX_TIM  = (counter == (DIVIDER_RATE/2));

endmodule
