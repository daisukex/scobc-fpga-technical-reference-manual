# --------------------------------------------------
# Space Cubics OBC A1 (SC-OBC-A1)
# Device parameter script
#  set_device.tcl
#  Copyright © 2022 Space Cubics, LLC.
# --------------------------------------------------

# Device parameter
set xil_device  xc7a200t
set xil_package fbg676
set xil_speed   -1
set xil_part    ${xil_device}${xil_package}${xil_speed}

# set_part
set_part ${xil_part}
