//-----------------------------------------------
// Space Cubics AHB Bus IP
//  AHB Read Data Multiplexer
//  Module: sc_ahbip_rdmux.v
//-----------------------------------------------
// Copyright © 2022 Space Cubics, LLC.
//-----------------------------------------------

module sc_ahbip_rdmux # (
  `include "sc_ahbip_parameter.vh"
) (
  input HCLK,
  // AHB Central Address Decoder Interface
  input [SC_AHBIP_NUMBER_OF_SLAVE-1:0] SHSEL,
  input DHREADYOUT,
  output DHREADYIN,
  input [1:0] DHRESP,

  // AHB Master Interface
  input [1:0] MHTRANS,
  output reg [31:0] MHRDATA,
  output reg [1:0] MHRESP,
  output MHREADY,

  // AHB Slave Interface
  input [32*SC_AHBIP_NUMBER_OF_SLAVE-1:0] SHRDATA,
  input [2*SC_AHBIP_NUMBER_OF_SLAVE-1:0] SHRESP,
  input [SC_AHBIP_NUMBER_OF_SLAVE-1:0] SHREADYOUT,
  output reg [SC_AHBIP_NUMBER_OF_SLAVE-1:0] SHREADYIN
);

genvar i;
reg [SC_AHBIP_NUMBER_OF_SLAVE-1:0] henable;

for (i=0; i<SC_AHBIP_NUMBER_OF_SLAVE; i=i+1) begin: shenb_logic
  always @ (posedge HCLK) begin
    if (MHREADY)
      henable[i] <= SHSEL[i] & MHTRANS != 2'b00;
  end
end

integer sn, osn;
always @ (*) begin
  MHRDATA = 32'h0000_0000;
  for (sn=0; sn<SC_AHBIP_NUMBER_OF_SLAVE; sn=sn+1) begin: shrdt_logic
    if (henable[sn])
      MHRDATA = SHRDATA[32*sn +:32];
  end
end

always @ (*) begin
  MHRESP = DHRESP;
  for (sn=0; sn<SC_AHBIP_NUMBER_OF_SLAVE; sn=sn+1) begin: shrsp_logic
    if (henable[sn])
      MHRESP = SHRESP[2*sn +:2];
  end
end

always @ (*) begin
  for (sn=0; sn<SC_AHBIP_NUMBER_OF_SLAVE; sn=sn+1) begin: shrdy_init
    SHREADYIN[sn] = DHREADYOUT;
  end
  for (sn=0; sn<SC_AHBIP_NUMBER_OF_SLAVE; sn=sn+1) begin: shrdy_logic
    for (osn=0; osn<SC_AHBIP_NUMBER_OF_SLAVE; osn=osn+1) begin: shrdy_marge
      if (osn != sn)
        SHREADYIN[sn] = SHREADYIN[sn] & SHREADYOUT[osn];
    end
  end
end
assign MHREADY = DHREADYOUT & &SHREADYOUT;
assign DHREADYIN = &SHREADYOUT;

endmodule
