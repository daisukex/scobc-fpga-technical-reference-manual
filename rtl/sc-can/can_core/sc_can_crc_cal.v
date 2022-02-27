//-----------------------------------------------
// Module: sc_can_crc_cal
//  Space Cubics CAN Controller CRC Calculator
//-----------------------------------------------
// Copyright © 2021 Space Cubics, LLC.
//-----------------------------------------------
module sc_can_crc_cal (
  input CAN_CLK,
  input CAN_RSTB,
  input CRCINIT,
  input CRCEN,
  input DIN,
  output reg [14:0] CRC_CAL
);

wire w_crc_next;
assign w_crc_next = DIN ^ CRC_CAL[14];

always @ (posedge CAN_CLK or negedge CAN_RSTB) begin
  if (!CAN_RSTB) begin
    CRC_CAL <= 0;
  end else if (CRCINIT) begin
    CRC_CAL <= 0;
  end else if (CRCEN) begin
    if (w_crc_next)
      CRC_CAL <= {CRC_CAL[13:0], 1'b0} ^ 15'h4599;
    else
      CRC_CAL <= {CRC_CAL[13:0], 1'b0};
  end
end

endmodule
