# --------------------------------------------------
# Space Cubics OBC A1 (SC-OBC-A1)
# sc_obc_a1_fpga Place script
#  place.tcl
#  Copyright © 2022 Space Cubics, LLC.
# --------------------------------------------------

source tcl/set_environment.tcl
source tcl/set_device.tcl

# check argument
if {${argc} < 2} {
    puts "Not enough arguments."
    puts " vivado -mode tcl -source (script) -tclargs (TOP Module) (Synthesis Design Check Point)"
    exit 1
}
set arglist ${argv}

# set top module
set topmodule [lindex ${arglist} 0]
puts "TOP Module: ${topmodule}"
set arglist [lreplace ${arglist} 0 0];

# set rtl list
set dcpfile [lindex ${arglist} 0]
puts "Design Check Point: ${dcpfile}"
set arglist [lreplace ${arglist} 0 0];

# create design export directory
set outdir ${rootd}/place
file mkdir ${outdir}

# Read Checkpoint
read_checkpoint ${dcpfile}
link_design -name ${topmodule} -part ${xil_part} -top ${topmodule}

# Read xdc file
read_xdc ${xdcd}/${topmodule}_io.xdc

# Floorplan
#source tcl/floorplan.tcl

# Pre-Place BlockRAM
#source tcl/pre_place.tcl

# Place
place_design -timing_summary

# Post-Place
place_design -post_place_opt

# Optimize after Place
phys_opt_design -placement_opt -critical_cell_opt
report_high_fanout_nets

# Export design report
if { [file exists $reptd] == 0} then {
    file mkdir ${reptd}
}
report_io -file ${reptd}/report_io.log

# Export design
write_verilog -force -mode funcsim -cell ${topmodule} ${rootd}/place/${topmodule}_place_funcsim_netlist.v
write_verilog -force -mode design  -cell ${topmodule} ${rootd}/place/${topmodule}_place_design_netlist.v
write_checkpoint -force ${rootd}/place/${topmodule}_place.dcp

exit 0
