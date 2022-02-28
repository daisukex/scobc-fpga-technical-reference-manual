# --------------------------------------------------
# Space Cubics OBC A1 (SC-OBC-A1)
# AXI Crossbar Synthesis script
#  synthesis_axi_crossbar_ip.tcl
#  Copyright © 2022 Space Cubics, LLC.
# --------------------------------------------------

source tcl/set_environment.tcl
source tcl/set_device.tcl

# setting ip core name
regsub -all ".xci" [lindex $argv 0] {} target_ip
puts ${target_ip}
set outdir ${rootd}/${target_ip}
file mkdir ${outdir}

if { [file exists ${axiipd}/${target_ip}/${target_ip}.xci] == 0} then {
    puts "xci not defined"
    exit
}

puts "Synthesis ${target_ip}"

# read ip
if { [file exists tcl/pre_read_${target_ip}.tcl] == 1} then {
    source tcl/pre_read_${target_ip}.tcl
}
read_ip ${axiipd}/${target_ip}/${target_ip}.xci
generate_target -force {synthesis simulation implementation} [get_files ${axiipd}/${target_ip}/${target_ip}.xci]

# xdc setting
if { [ file exists ${xdcd}/${target_ip}/synthesis_${target_ip}.sdc ] == 1 } then {
    create_fileset -constrset ${target_ip}_xdc
    add_files -fileset ${target_ip}_xdc ${xdcd}/${target_ip}/synthesis_${target_ip}.sdc
    set sdc 1
} else {
    set sdc 0
}

# Logic Synthesis IP Core
if {$sdc} then {
    synth_design \
        -mode out_of_context \
        -constrset ${target_ip}_xdc \
        -name ${target_ip} \
        -verbose -part ${xil_part} \
        -top ${target_ip}
} else {
    synth_design \
        -mode out_of_context \
        -name ${target_ip} \
        -verbose -part ${xil_part} \
        -top ${target_ip}
}

# Save design
write_verilog -force -mode funcsim -cell ${target_ip} ${rootd}/${target_ip}/${target_ip}_funcsim_netlist.v
write_verilog -force -mode design  -cell ${target_ip} ${rootd}/${target_ip}/${target_ip}_design_netlist.v
write_checkpoint -force ${rootd}/${target_ip}/${target_ip}.dcp
report_utilization

#exit
