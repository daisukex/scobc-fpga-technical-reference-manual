# --------------------------------------------------
# Xilinx IP generate_target tcl script
#  Copyright © 2022 Space Cubics, LLC.
# --------------------------------------------------

# Set valiable
set module        [lindex $argv 0]
set device        [lindex $argv 1]
set_part ${device}

if { [file exists ${module}/${module}.xci] == 0} then {
    puts "xci not defined"
    exit
}

read_ip ${module}/${module}.xci
generate_target -force {synthesis simulation} [get_files ${module}/${module}.xci]

exit
