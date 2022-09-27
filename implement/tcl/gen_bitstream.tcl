# --------------------------------------------------
# Space Cubics OBC A1 (SC-OBC-A1)
# sc_obc_a1_fpga Generate bitstream script
#  gen_bitstream.tcl
#  Copyright © 2022 Space Cubics, LLC.
# --------------------------------------------------

source tcl/set_environment.tcl
source tcl/set_device.tcl
source tcl/write_mmi.tcl

# check argument
if {${argc} < 2} {
    puts "Not enough arguments."
    puts " vivado -mode tcl -source (script) -tclargs (TOP Module) (Route Design Check Point)"
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

# Read Checkpoint
read_checkpoint ${dcpfile}
link_design -name ${topmodule} -part ${xil_part} -top ${topmodule}

# Read xdc file
read_xdc ${xdcd}/${topmodule}_bit.xdc

write_mmi obc_core/cm3_ss/itcm/mem_reg ${bitd}/itcm.mmi ${xil_part}

# Write bitstream
write_bitstream -force ${bitd}/${topmodule}.bit
write_cfgmem -force -format MCS -interface SPIx4 -size 16 -loadbit "up 0x0 ${bitd}/${topmodule}.bit" -file ${bitd}/${topmodule}.mcs

exit 0
