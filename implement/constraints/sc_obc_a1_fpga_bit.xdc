# --------------------------------------------------
# Space Cubics OBC A1 (SC-OBC-A1)
# FPGA Bitstream export format file (.xdc)
#  sc_obc_a1_fpga_bit.tcl
#  Copyright © 2022 Space Cubics, LLC.
# --------------------------------------------------

set_property BITSTREAM.CONFIG.UNUSEDPIN PULLNONE [current_design]
set_property BITSTREAM.CONFIG.SPI_BUSWIDTH  4 [current_design]
set_property BITSTREAM.CONFIG.CONFIGRATE   50 [current_design]
set_property BITSTREAM.GENERAL.COMPRESS  TRUE [current_design]
