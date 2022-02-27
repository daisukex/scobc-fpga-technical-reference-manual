# --------------------------------------------------
# Space Cubics Cortex-M3 SubSystem
# Device parameter script
#  set_device.tcl
#  Copyright © 2022 Space Cubics, LLC.
# --------------------------------------------------

# Device parameter
set xil_device  xc7a200
set xil_package tfbg676
set xil_speed   -1
set xil_part    ${xil_device}${xil_package}${xil_speed}

# set_part
set_part ${xil_part}
