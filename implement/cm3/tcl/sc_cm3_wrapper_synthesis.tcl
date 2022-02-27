# --------------------------------------------------
# Space Cubics Cortex-M3 SubSystem
# sc_cm3_wrapper synthesis script
#  sc_cm3_wrapper_synthesis.tcl
#  Copyright © 2022 Space Cubics, LLC.
# --------------------------------------------------

source tcl/set_environment.tcl
source tcl/set_device.tcl

# setting variable
set target_ip sc_cm3_wrapper
set outdir ${rootd}/${target_ip}
file mkdir ${outdir}

# read verilog
foreach rtl $argv {
    read_verilog ${rtl}
}

# read xdc
create_fileset -constrset ${target_ip}_xdc
add_files -fileset ${target_ip}_xdc ${xdcd}/${target_ip}.xdc

# Synthesis IP Core
synth_design \
    -mode out_of_context \
    -directive AreaOptimized_high \
    -flatten_hierarchy full \
    -name ${target_ip} \
    -verbose -part ${xil_part} \
    -top ${target_ip}

# Save design
write_verilog -force -mode funcsim -cell ${target_ip} ${outdir}/${target_ip}_funcsim_netlist.v
write_verilog -force -mode design  -cell ${target_ip} ${outdir}/${target_ip}_design_netlist.v
write_checkpoint -force ${target_ip}.dcp
report_utilization

#exit
