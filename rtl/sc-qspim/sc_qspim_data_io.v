//-----------------------------------------------
// Module: sc_qspim_data_io
//  Space Cubics Quad-SPI Master IO Control Module
//-----------------------------------------------
// Copyright © 2020 Space Cubics, LLC.
//-----------------------------------------------
module sc_qspim_data_io (

  input  [3:0] QSPI_OE,
  input  [3:0] QSPI_DOUT,
  output [3:0] QSPI_DIN,

  inout  [3:0] QSPI_IO

);

assign QSPI_IO[0] = (QSPI_OE[0]) ? QSPI_DOUT[0] : 1'bz;
assign QSPI_IO[1] = (QSPI_OE[1]) ? QSPI_DOUT[1] : 1'bz;
assign QSPI_IO[2] = (QSPI_OE[2]) ? QSPI_DOUT[2] : 1'bz;
assign QSPI_IO[3] = (QSPI_OE[3]) ? QSPI_DOUT[3] : 1'bz;
assign QSPI_DIN = QSPI_IO;

endmodule
