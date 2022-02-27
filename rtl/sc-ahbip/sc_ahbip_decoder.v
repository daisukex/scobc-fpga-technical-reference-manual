//-----------------------------------------------
// Space Cubics AHB Bus IP
//  AHB Central Address Decoder
//  Module: sc_ahbip_decoder.v
//-----------------------------------------------
// Copyright © 2022 Space Cubics, LLC.
//-----------------------------------------------

module sc_ahbip_decoder # (
  `include "sc_ahbip_parameter.vh"
) (
  // System Interface
  input HCLK,
  input HRESETN,

  // Master Interface
  input [31:0] MHADDR,
  input [1:0] MHTRANS,

  // Slave Interface
  output [SC_AHBIP_NUMBER_OF_SLAVE-1:0] SHSEL,

  // Default slave
  input DHREADYIN,
  output reg DHREADYOUT,
  output reg [1:0] DHRESP
);

genvar i;
generate
  for (i=0; i<SC_AHBIP_NUMBER_OF_SLAVE; i=i+1) begin: CENTRAL_ADDR_DECODER
    if (i == 0) assign SHSEL[0] = MHADDR[31:SC_AHBIP_S0_ADDR_WIDTH] == SC_AHBIP_S0_BASE_ADDR;
    if (i == 1) assign SHSEL[1] = MHADDR[31:SC_AHBIP_S1_ADDR_WIDTH] == SC_AHBIP_S1_BASE_ADDR;
    if (i == 2) assign SHSEL[2] = MHADDR[31:SC_AHBIP_S2_ADDR_WIDTH] == SC_AHBIP_S2_BASE_ADDR;
    if (i == 3) assign SHSEL[3] = MHADDR[31:SC_AHBIP_S3_ADDR_WIDTH] == SC_AHBIP_S3_BASE_ADDR;
    if (i == 4) assign SHSEL[4] = MHADDR[31:SC_AHBIP_S4_ADDR_WIDTH] == SC_AHBIP_S4_BASE_ADDR;
    if (i == 5) assign SHSEL[5] = MHADDR[31:SC_AHBIP_S5_ADDR_WIDTH] == SC_AHBIP_S5_BASE_ADDR;
    if (i == 6) assign SHSEL[6] = MHADDR[31:SC_AHBIP_S6_ADDR_WIDTH] == SC_AHBIP_S6_BASE_ADDR;
    if (i == 7) assign SHSEL[7] = MHADDR[31:SC_AHBIP_S7_ADDR_WIDTH] == SC_AHBIP_S7_BASE_ADDR;
  end
endgenerate

// Default Slave
reg addec_error;
always @ (posedge HCLK) begin
  if (!HRESETN) begin
    addec_error <= 1'b0;
    DHREADYOUT <= 1'b1;
    DHRESP <= 2'b00;
  end
  else if (DHREADYIN & DHREADYOUT & SHSEL == 0 & MHTRANS[1]) begin
    addec_error <= 1'b1;
    DHREADYOUT  <= 1'b0;
    DHRESP <= 2'b01;
  end
  else if (addec_error) begin
    DHREADYOUT <= 1'b1;
    DHRESP <= 2'b01;
  end
  else
    DHRESP <= 2'b00;
end

endmodule
