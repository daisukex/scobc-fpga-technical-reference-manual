# -----------------------------------------------
# ARM Cortex-M3 generate tcl script
#  Copyright © 2022 Space Cubics, LLC.
# -----------------------------------------------

# Set valiable
set module        [lindex $argv 0]
set add_repo_path ../Arm_ipi_repository
set device        [lindex $argv 1]

create_project -force -part ${device} ${module} ${module}_prj

# Read IP Repository
if { [file exists ${add_repo_path} ] == 1} then {
    set_property ip_repo_paths ${add_repo_path} [current_project]
}
update_ip_catalog

# Create IP
create_ip -name CORTEXM3_AXI -vendor Arm.com -library CortexM -version 1.1 -module_name ${module} -dir .
set_property -dict [list \
                        CONFIG.NUM_IRQ {240} \
                        CONFIG.LVL_WIDTH {3} \
                        CONFIG.MPU_PRESENT {true} \
                        CONFIG.WIC_PRESENT {false} \
                        CONFIG.WIC_LINES {3} \
                        CONFIG.BB_PRESENT {true} \
                        CONFIG.DEBUG_LVL {2} \
                        CONFIG.TRACE_LVL {1} \
                        CONFIG.JTAG_PRESENT {true} \
                        CONFIG.ITCM_SIZE {"1000"} \
                        CONFIG.ITCM_INIT_RAM {false} \
                        CONFIG.DTCM_SIZE {"0100"} \
                        CONFIG.DTCM_INIT_RAM {false} \
                        CONFIG.STRB_MAX {3} \
                        CONFIG.STRB_WIDTH {4} \
                       ] [get_ips ${module}]

# Copy .xci from vivado project directory
file copy -force ${module}/${module}.xci .

exit
