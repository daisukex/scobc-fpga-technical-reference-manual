# --------------------------------------------------
# Space Cubics Cortex-M3 SubSystem
# Generate Cortex-M3 component script
#  generate_cm3_components.tcl
#  Copyright © 2022 Space Cubics, LLC.
# --------------------------------------------------

source tcl/set_environment.tcl
source tcl/set_device.tcl

# setting ip core name
set target_ip cortex_m3
set outdir ${rootd}/${target_ip}
file mkdir ${outdir}

if { [file exists ${xcid}/${target_ip}/cortex_m3.xci] == 0} then {
    puts "xci not defined"
    exit
}

# Setting ARM design repository
set_property ip_repo_paths ${arm_ipd} [current_fileset]

read_ip ${xcid}/${target_ip}/${target_ip}.xci
generate_target -force {synthesis simulation implementation} [get_files ${target_ip}.xci]

# xdc setting
create_fileset -constrset ${target_ip}_xdc
add_files -fileset ${target_ip}_xdc ${xdcd}/${target_ip}.xdc

# Elaborate Cortex-M3
synth_design \
    -mode out_of_context \
    -constrset ${target_ip}_xdc \
    -flatten_hierarchy none \
    -name ${target_ip} \
    -verbose -part ${xil_part} \
    -top ${target_ip}

# Export Design
write_verilog -force -mode design  -cell ${target_ip}        ${rootd}/${target_ip}/${target_ip}_design.v
write_verilog -force -mode design  -cell CORTEXM3INTEGRATION ${rootd}/${target_ip}/CORTEXM3INTEGRATION_design.v
write_verilog -force -mode design  -cell AhbSToAxi           AhbSToAxi_design.v

exit
