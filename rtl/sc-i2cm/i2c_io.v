//-----------------------------------------------
// Module: i2c_io
//  I2C I/O Control Module
//-----------------------------------------------
// Copyright © 2021 Space Cubics, LLC.
//-----------------------------------------------
module i2c_io (

  output SDA_IN,
  input  SDA_OUT,
  output SCL_IN,
  input  SCL_OUT,

  inout  SDA_IO,
  inout  SCL_IO

);

assign SDA_IO = (~SDA_OUT) ? 1'b0: 1'bz;
assign SDA_IN = SDA_IO;
assign SCL_IO = (~SCL_OUT) ? 1'b0: 1'bz;
assign SCL_IN = SCL_IO;

endmodule
