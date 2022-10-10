# --------------------------------------------------
# Space Cubics OBC A1 (SC-OBC-A1)
# sc_obc_a1_fpga Route script
#  route.tcl
#  Copyright © 2022 Space Cubics, LLC.
# --------------------------------------------------

source tcl/set_environment.tcl
source tcl/set_device.tcl

# check argument
if {${argc} < 2} {
    puts "Not enough arguments."
    puts " vivado -mode tcl -source (script) -tclargs (TOP Module) (Place Design Check Point)"
    exit 1
}

set arglist ${argv}

# set top module
set topmodule [lindex ${arglist} 0]
puts "TOP Module: ${topmodule}"
set arglist [lreplace ${arglist} 0 0];

# set design checkpoint
set dcpfile [lindex ${arglist} 0]
puts "Design Check Point: ${dcpfile}"
set arglist [lreplace ${arglist} 0 0];

# create design export directory
set outdir ${rootd}/route
file mkdir ${outdir}

# Read Checkpoint
read_checkpoint ${dcpfile}
link_design -name ${topmodule} -part ${xil_part} -top ${topmodule}

# Route
route_design -timing_summary

# Optimize after Place
phys_opt_design -routing_opt

# Export design report
report_utilization -file ${reptd}/report_utilization_route.log

# Export design
write_verilog -force -mode funcsim -cell ${topmodule} ${rootd}/route/${topmodule}_route_funcsim_netlist.v
write_verilog -force -mode design  -cell ${topmodule} ${rootd}/route/${topmodule}_route_design_netlist.v
write_checkpoint -force ${rootd}/route/${topmodule}_route.dcp

exit 0
