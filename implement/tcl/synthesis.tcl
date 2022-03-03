# --------------------------------------------------
# Space Cubics OBC A1 (SC-OBC-A1)
# sc_obc_a1_fpga Synthesis script
#  synthesis.tcl
#  Copyright © 2022 Space Cubics, LLC.
# --------------------------------------------------

source tcl/set_environment.tcl
source tcl/set_device.tcl

proc read_verilog_from_rtllist {rtllist} {
    set fid [open ${rtllist} r]
    while {[gets $fid rtlpath] >= 0} {
        read_verilog ${rtlpath}
    }
}

proc read_dcp_from_vallist {rootd vallist} {
    for {set i 0} {$i < [llength ${vallist}]} {incr i} {
        set xcin [lindex ${vallist} ${i}]
        read_checkpoint ${xcin}
    }
}

# check argument
if {${argc} <= 2} {
    puts "Not enough arguments."
    puts " vivado -mode tcl -source (script) -tclargs (TOP Module) (RTL list) (IP list)..."
    exit 1
}
set arglist ${argv}

# set top module
set topmodule [lindex ${arglist} 0]
puts "TOP Module: ${topmodule}"
set arglist [lreplace ${arglist} 0 0];

# set rtl list
set rtllist [lindex ${arglist} 0]
puts "RTL list file: ${rtllist}"
set arglist [lreplace ${arglist} 0 0];

# Create design export directory
set outdir ${rootd}/synthesis
file mkdir ${outdir}

# Read RTL
read_verilog_from_rtllist ${rtllist}

# Read IP
read_dcp_from_vallist ${rootd} ${arglist}

# SDC Setting
if { [ file exists ${xdcd}/${topmodule}_timing.xdc ] == 1 } then {
    create_fileset -constrset ${topmodule}_timing_xdc
    add_files -fileset ${topmodule}_timing_xdc ${xdcd}/${topmodule}_timing.xdc
    set sdc 1
} else {
    set sdc 0
}

# Synthesis TOP Module
if {$sdc} then {
    synth_design -constrset ${topmodule}_timing_xdc -retiming -name ${topmodule} -verbose -part ${xil_part} -top ${topmodule}
} else {
    synth_design -retiming -name ${topmodule} -verbose -part ${xil_part} -top ${topmodule}
}

# Report Timing
reset_timing
report_clocks
report_clock_interaction
report_clock_networks

# Optimize
opt_design -directive Explore -debug_log
opt_design -propconst -sweep -resynth_area -resynth_seq_area -remap -merge_equivalent_drivers -debug_log
# Export design
write_verilog -force -mode funcsim -cell ${topmodule} ${rootd}/synthesis/${topmodule}_synthesis_funcsim_netlist.v
write_verilog -force -mode design  -cell ${topmodule} ${rootd}/synthesis/${topmodule}_synthesis_design_netlist.v
write_checkpoint -force ${rootd}/synthesis/${topmodule}_synthesis.dcp

exit 0
