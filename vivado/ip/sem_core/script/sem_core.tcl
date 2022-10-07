# -----------------------------------------------
# Xilinx SEM Controller IP generate tcl script
#  Copyright © 2022 Space Cubics, LLC.
# -----------------------------------------------

# Set valiable
set module [lindex $argv 0]
set device [lindex $argv 1]

puts ${module}

create_project -force -part ${device} ${module} ${module}_prj

# Create IP
create_ip -name sem -vendor xilinx.com -library ip -module_name ${module} -force -dir .
set_property -dict [list CONFIG.CLOCK_FREQ {24} \
                        CONFIG.COMPONENT_NAME {sem_core} \
                        CONFIG.ENABLE_CORRECTION {true} \
                        CONFIG.ENABLE_CLASSIFICATION {false} \
                        CONFIG.ENABLE_INJECTION {true} \
                        CONFIG.CORRECTION_METHOD {enhanced_repair} \
                        CONFIG.INJECTION_SHIM {pins} \
                        CONFIG.RETRIEVAL_SHIM {none}] [get_ips ${module}]

# Copy .xci from vivado project directory
file copy -force ${module}/${module}.xci .

exit
