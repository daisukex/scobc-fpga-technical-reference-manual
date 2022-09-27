# --------------------------------------------------
# Write Memory Map Infomation script for Xilinx Vivado
#  write_mmi.tcl
#  Copyright © 2022 Space Cubics, LLC.
# --------------------------------------------------

proc writestring { mmi str sw} {
    if {$sw == 1} {
        set fid [open $mmi a]
    } else {
        set fid [open $mmi w]
    }
    puts $fid "$str"
    close $fid
}

proc write_mmi_header { mmi inst } {
    writestring $mmi "<?xml version=\"1.0\" encoding=\"UTF-8\"?>" 0
    writestring $mmi "<MemInfo Version=\"1\" Minor=\"0\">" 1
    writestring $mmi "  <Processor Endianness=\"Little\" InstPath=\"${inst}\">" 1
}

proc write_mmi_footer { mmi device } {
    writestring $mmi "  </Processor>" 1
    writestring $mmi "  <Config>" 1
    writestring $mmi "    <Option Name=\"Part\" Val=\"$device\"/>" 1
    writestring $mmi "  </Config>" 1
    writestring $mmi "</MemInfo>" 1
}

proc write_mmi { inst mmi device } {

    # Analysis of memory configuration
    set meminst [lsort [get_cells ${inst}*]]
    set memcount [llength $meminst]
    for {set i 0} {$i < ${memcount}} {incr i} {
        set mem [lindex $meminst $i]
        set memlist($i,inst) $mem
        set memlist($i,loc) [lindex [split [get_property LOC [get_cells $mem]] "_"] 1]
        set memlist($i,lsb) [get_property ram_slice_begin [get_cells $mem]]
        set memlist($i,msb) [get_property ram_slice_end [get_cells $mem]]
        set memlist($i,ads) [get_property ram_addr_begin [get_cells $mem]]
        set memlist($i,ade) [get_property ram_addr_end [get_cells $mem]]
        set memlist($i,btw) [expr $memlist($i,msb) - $memlist($i,lsb) + 1]
    }
    set totalbyte [expr $memcount * ($memlist(0,ade) + 1) - 1]

    # Check memory configuration
    set bw $memlist(0,btw)
    for {set i 0} {$i < ${memcount}} {incr i} {
        if {$bw != $memlist($i,btw)} {
            puts "RAMB36 bit size not match"
            return -code error "Incorrect memory configuration. All memory bit widths must be equal."
        }
    }
    if {$bw != 1 & $bw != 2 & $bw != 4 & $bw != 8 & $bw != 16 & $bw != 32} {
        return -code error "Invalid memory bit width. Bit widths of 1, 2, 4, 8, 16 and 32 are supported."
    }

    # Write .mmi header
    write_mmi_header $mmi $inst
    writestring $mmi "    <AddressSpace Name=\"itcm_raddr\" Begin=\"0\" End=\"$totalbyte\">" 1
    writestring $mmi "      <BusBlock>" 1

    # Write memory block (8, 16, 32 bit)
    if {$bw == 8 | $bw == 16 | $bw == 32} {
        for {set i 0} {$i < 32} {set i [expr $i + $bw]} {
            for {set j 0} {$j < ${memcount}} {incr j} {
                if {$memlist($j,lsb) == $i} {
                    writestring $mmi "        <BitLane MemType=\"RAMB32\" Placement=\"$memlist($j,loc)\">" 1
                    writestring $mmi "          <DataWidth MSB=\"$memlist($j,msb)\" LSB=\"$memlist($j,lsb)\"/>" 1
                    writestring $mmi "          <AddressRange Begin=\"$memlist($j,ads)\" End=\"$memlist($j,ade)\"/>" 1
                    writestring $mmi "          <Parity ON=\"false\" NumBits=\"0\"/>" 1
                    writestring $mmi "        </BitLane>" 1
                }
            }
        }
    # Write memory block (1, 2, 4 bit)
    } else {
        for {set b 1} {$b <= 4} {incr b} {
            for {set i 0} {$i < 8} {set i [expr $i + $bw]} {
                set bt [expr ($b*8-1)-$i]
                for {set j 0} {$j < ${memcount}} {incr j} {
                    if {$memlist($j,msb) == $bt} {
                        writestring $mmi "        <BitLane MemType=\"RAMB32\" Placement=\"$memlist($j,loc)\">" 1
                        writestring $mmi "          <DataWidth MSB=\"$memlist($j,msb)\" LSB=\"$memlist($j,lsb)\"/>" 1
                        writestring $mmi "          <AddressRange Begin=\"$memlist($j,ads)\" End=\"$memlist($j,ade)\"/>" 1
                        writestring $mmi "          <Parity ON=\"false\" NumBits=\"0\"/>" 1
                        writestring $mmi "        </BitLane>" 1
                    }
                }
            }
        }
    }

    # Write .mmi footer
    writestring $mmi "      </BusBlock>" 1
    writestring $mmi "    </AddressSpace>" 1
    write_mmi_footer $mmi $device
}
