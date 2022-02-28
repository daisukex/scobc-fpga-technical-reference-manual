# --------------------------------------------------
# Space Cubics OBC A1 (SC-OBC-A1)
# Vivado implement enviroment script
#  set_enviroment.tcl
#  Copyright © 2022 Space Cubics, LLC.
# --------------------------------------------------

# log directory
set logd ./log

# data directory
set rootd   ./output
set xcid    ./ip
set axiipd  ${xcid}/axi_crossbar
set rtllist ./tcl/dut_rtl.list
set xdcd    ./constraint
set bitd    ./bitstream
