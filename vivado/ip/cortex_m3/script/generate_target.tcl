# --------------------------------------------------
# Xilinx IP generate_target tcl script
#  Copyright © 2022 Space Cubics, LLC.
# --------------------------------------------------

# Set valiable
set module        [lindex $argv 0]
set device        [lindex $argv 1]
set_part ${device}
set add_repo_path ../Arm_ipi_repository


if { [file exists ${module}/${module}.xci] == 0} then {
    puts "xci not defined"
    exit
}

# Read IP Repository
if { [file exists ${add_repo_path} ] == 1} then {
    set_property ip_repo_paths ${add_repo_path} [current_project]
}
update_ip_catalog

read_ip ${module}/${module}.xci
generate_target -force {synthesis simulation} [get_files ${module}/${module}.xci]

exit
