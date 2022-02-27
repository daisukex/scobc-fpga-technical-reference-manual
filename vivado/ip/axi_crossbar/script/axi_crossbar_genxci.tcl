# -----------------------------------------------
# Xilinx AXI Crossbar IP generate tcl script
#  Copyright © 2022 Space Cubics, LLC.
# -----------------------------------------------

# Set valiable
set module        [lindex $argv 0]
set device        [lindex $argv 1]

puts ${module}
source ${module}.config

create_project -force -part ${device} ${module} ${module}_prj

# Create IP
create_ip -name axi_crossbar -vendor xilinx.com -library ip -module_name ${module} -force -dir .
set_property -dict ${axi_crossbar_configuration} [get_ips ${module}]

# Copy .xci from vivado project directory
file copy -force ${module}/${module}.xci .

exit
