# --------------------------------------------------
# Space Cubics OBC A1 (SC-OBC-A1)
# FPGA IO Configuration file (.xdc)
#  sc_obc_a1_fpga_io.tcl
#  Copyright © 2022 Space Cubics, LLC.
# --------------------------------------------------

# Config
set_property CFGBVS VCCO [current_design]
set_property CONFIG_VOLTAGE 3.3 [current_design]

# System Interface
set_property [get_ports SYSCLK1]              -dict { PACKAGE_PIN U22  IOSTANDARD LVCMOS33 }
set_property [get_ports SYSCLK1_EN]           -dict { PACKAGE_PIN V26  IOSTANDARD LVCMOS33 DRIVE 4}
set_property [get_ports SYSCLK2]              -dict { PACKAGE_PIN U21  IOSTANDARD LVCMOS33 }
set_property [get_ports SYSCLK2_EN]           -dict { PACKAGE_PIN W26  IOSTANDARD LVCMOS33 DRIVE 4}

# Debug Interface
set_property [get_ports CM3_NTRST]            -dict { PACKAGE_PIN U24  IOSTANDARD LVCMOS33 PULLUP TRUE}
set_property [get_ports CM3_TDI]              -dict { PACKAGE_PIN Y20  IOSTANDARD LVCMOS33 PULLUP TRUE}
set_property [get_ports CM3_TCK_SWCLK]        -dict { PACKAGE_PIN W21  IOSTANDARD LVCMOS33 PULLUP TRUE}
set_property [get_ports CM3_TMS_SWDIO]        -dict { PACKAGE_PIN Y21  IOSTANDARD LVCMOS33 DRIVE 4 PULLUP TRUE}
set_property [get_ports CM3_TDO_SWO]          -dict { PACKAGE_PIN W20  IOSTANDARD LVCMOS33 DRIVE 4 PULLUP TRUE}

# SRAM Interface
set_property [get_ports {SRAM_A[0]}]          -dict { PACKAGE_PIN H26  IOSTANDARD LVCMOS33 DRIVE 4 SLEW FAST}
set_property [get_ports {SRAM_A[1]}]          -dict { PACKAGE_PIN G25  IOSTANDARD LVCMOS33 DRIVE 4 SLEW FAST}
set_property [get_ports {SRAM_A[2]}]          -dict { PACKAGE_PIN G26  IOSTANDARD LVCMOS33 DRIVE 4 SLEW FAST}
set_property [get_ports {SRAM_A[3]}]          -dict { PACKAGE_PIN G24  IOSTANDARD LVCMOS33 DRIVE 4 SLEW FAST}
set_property [get_ports {SRAM_A[4]}]          -dict { PACKAGE_PIN F24  IOSTANDARD LVCMOS33 DRIVE 4 SLEW FAST}
set_property [get_ports {SRAM_A[5]}]          -dict { PACKAGE_PIN F25  IOSTANDARD LVCMOS33 DRIVE 4 SLEW FAST}
set_property [get_ports {SRAM_A[6]}]          -dict { PACKAGE_PIN D25  IOSTANDARD LVCMOS33 DRIVE 4 SLEW FAST}
set_property [get_ports {SRAM_A[7]}]          -dict { PACKAGE_PIN D26  IOSTANDARD LVCMOS33 DRIVE 4 SLEW FAST}
set_property [get_ports {SRAM_A[8]}]          -dict { PACKAGE_PIN E26  IOSTANDARD LVCMOS33 DRIVE 4 SLEW FAST}
set_property [get_ports {SRAM_A[9]}]          -dict { PACKAGE_PIN E25  IOSTANDARD LVCMOS33 DRIVE 4 SLEW FAST}
set_property [get_ports {SRAM_A[10]}]         -dict { PACKAGE_PIN D24  IOSTANDARD LVCMOS33 DRIVE 4 SLEW FAST}
set_property [get_ports {SRAM_A[11]}]         -dict { PACKAGE_PIN C23  IOSTANDARD LVCMOS33 DRIVE 4 SLEW FAST}
set_property [get_ports {SRAM_A[12]}]         -dict { PACKAGE_PIN C24  IOSTANDARD LVCMOS33 DRIVE 4 SLEW FAST}
set_property [get_ports {SRAM_A[13]}]         -dict { PACKAGE_PIN B24  IOSTANDARD LVCMOS33 DRIVE 4 SLEW FAST}
set_property [get_ports {SRAM_A[14]}]         -dict { PACKAGE_PIN A25  IOSTANDARD LVCMOS33 DRIVE 4 SLEW FAST}
set_property [get_ports {SRAM_A[15]}]         -dict { PACKAGE_PIN B26  IOSTANDARD LVCMOS33 DRIVE 4 SLEW FAST}
set_property [get_ports {SRAM_A[16]}]         -dict { PACKAGE_PIN B25  IOSTANDARD LVCMOS33 DRIVE 4 SLEW FAST}
set_property [get_ports {SRAM_A[17]}]         -dict { PACKAGE_PIN C26  IOSTANDARD LVCMOS33 DRIVE 4 SLEW FAST}
set_property [get_ports {SRAM_A[18]}]         -dict { PACKAGE_PIN A23  IOSTANDARD LVCMOS33 DRIVE 4 SLEW FAST}
set_property [get_ports {SRAM_A[19]}]         -dict { PACKAGE_PIN A24  IOSTANDARD LVCMOS33 DRIVE 4 SLEW FAST}
set_property [get_ports SRAM1_CE_B]           -dict { PACKAGE_PIN J26  IOSTANDARD LVCMOS33 DRIVE 4 SLEW FAST}
set_property [get_ports SRAM1_OE_B]           -dict { PACKAGE_PIN J25  IOSTANDARD LVCMOS33 DRIVE 4 SLEW FAST}
set_property [get_ports SRAM1_WE_B]           -dict { PACKAGE_PIN J24  IOSTANDARD LVCMOS33 DRIVE 4 SLEW FAST}
set_property [get_ports SRAM1_BHE_B]          -dict { PACKAGE_PIN H23  IOSTANDARD LVCMOS33 DRIVE 4 SLEW FAST}
set_property [get_ports SRAM1_BLE_B]          -dict { PACKAGE_PIN H24  IOSTANDARD LVCMOS33 DRIVE 4 SLEW FAST}
set_property [get_ports SRAM1_ERR]            -dict { PACKAGE_PIN J23  IOSTANDARD LVCMOS33 }
set_property [get_ports {SRAM1_IO[0]}]        -dict { PACKAGE_PIN H19  IOSTANDARD LVCMOS33 DRIVE 4 SLEW FAST KEEPER TRUE}
set_property [get_ports {SRAM1_IO[1]}]        -dict { PACKAGE_PIN G21  IOSTANDARD LVCMOS33 DRIVE 4 SLEW FAST KEEPER TRUE}
set_property [get_ports {SRAM1_IO[2]}]        -dict { PACKAGE_PIN J19  IOSTANDARD LVCMOS33 DRIVE 4 SLEW FAST KEEPER TRUE}
set_property [get_ports {SRAM1_IO[3]}]        -dict { PACKAGE_PIN J18  IOSTANDARD LVCMOS33 DRIVE 4 SLEW FAST KEEPER TRUE}
set_property [get_ports {SRAM1_IO[4]}]        -dict { PACKAGE_PIN K17  IOSTANDARD LVCMOS33 DRIVE 4 SLEW FAST KEEPER TRUE}
set_property [get_ports {SRAM1_IO[5]}]        -dict { PACKAGE_PIN L17  IOSTANDARD LVCMOS33 DRIVE 4 SLEW FAST KEEPER TRUE}
set_property [get_ports {SRAM1_IO[6]}]        -dict { PACKAGE_PIN K15  IOSTANDARD LVCMOS33 DRIVE 4 SLEW FAST KEEPER TRUE}
set_property [get_ports {SRAM1_IO[7]}]        -dict { PACKAGE_PIN L14  IOSTANDARD LVCMOS33 DRIVE 4 SLEW FAST KEEPER TRUE}
set_property [get_ports {SRAM1_IO[8]}]        -dict { PACKAGE_PIN H18  IOSTANDARD LVCMOS33 DRIVE 4 SLEW FAST KEEPER TRUE}
set_property [get_ports {SRAM1_IO[9]}]        -dict { PACKAGE_PIN J20  IOSTANDARD LVCMOS33 DRIVE 4 SLEW FAST KEEPER TRUE}
set_property [get_ports {SRAM1_IO[10]}]       -dict { PACKAGE_PIN G22  IOSTANDARD LVCMOS33 DRIVE 4 SLEW FAST KEEPER TRUE}
set_property [get_ports {SRAM1_IO[11]}]       -dict { PACKAGE_PIN K20  IOSTANDARD LVCMOS33 DRIVE 4 SLEW FAST KEEPER TRUE}
set_property [get_ports {SRAM1_IO[12]}]       -dict { PACKAGE_PIN J16  IOSTANDARD LVCMOS33 DRIVE 4 SLEW FAST KEEPER TRUE}
set_property [get_ports {SRAM1_IO[13]}]       -dict { PACKAGE_PIN J15  IOSTANDARD LVCMOS33 DRIVE 4 SLEW FAST KEEPER TRUE}
set_property [get_ports {SRAM1_IO[14]}]       -dict { PACKAGE_PIN K16  IOSTANDARD LVCMOS33 DRIVE 4 SLEW FAST KEEPER TRUE}
set_property [get_ports {SRAM1_IO[15]}]       -dict { PACKAGE_PIN J14  IOSTANDARD LVCMOS33 DRIVE 4 SLEW FAST KEEPER TRUE}
set_property [get_ports SRAM2_CE_B]           -dict { PACKAGE_PIN A22  IOSTANDARD LVCMOS33 DRIVE 4 SLEW FAST}
set_property [get_ports SRAM2_OE_B]           -dict { PACKAGE_PIN B21  IOSTANDARD LVCMOS33 DRIVE 4 SLEW FAST}
set_property [get_ports SRAM2_WE_B]           -dict { PACKAGE_PIN B22  IOSTANDARD LVCMOS33 DRIVE 4 SLEW FAST}
set_property [get_ports SRAM2_BHE_B]          -dict { PACKAGE_PIN C22  IOSTANDARD LVCMOS33 DRIVE 4 SLEW FAST}
set_property [get_ports SRAM2_BLE_B]          -dict { PACKAGE_PIN C21  IOSTANDARD LVCMOS33 DRIVE 4 SLEW FAST}
set_property [get_ports SRAM2_ERR]            -dict { PACKAGE_PIN D21  IOSTANDARD LVCMOS33 }
set_property [get_ports {SRAM2_IO[0]}]        -dict { PACKAGE_PIN B17  IOSTANDARD LVCMOS33 DRIVE 4 SLEW FAST KEEPER TRUE}
set_property [get_ports {SRAM2_IO[1]}]        -dict { PACKAGE_PIN A19  IOSTANDARD LVCMOS33 DRIVE 4 SLEW FAST KEEPER TRUE}
set_property [get_ports {SRAM2_IO[2]}]        -dict { PACKAGE_PIN C17  IOSTANDARD LVCMOS33 DRIVE 4 SLEW FAST KEEPER TRUE}
set_property [get_ports {SRAM2_IO[3]}]        -dict { PACKAGE_PIN B20  IOSTANDARD LVCMOS33 DRIVE 4 SLEW FAST KEEPER TRUE}
set_property [get_ports {SRAM2_IO[4]}]        -dict { PACKAGE_PIN C19  IOSTANDARD LVCMOS33 DRIVE 4 SLEW FAST KEEPER TRUE}
set_property [get_ports {SRAM2_IO[5]}]        -dict { PACKAGE_PIN D20  IOSTANDARD LVCMOS33 DRIVE 4 SLEW FAST KEEPER TRUE}
set_property [get_ports {SRAM2_IO[6]}]        -dict { PACKAGE_PIN D16  IOSTANDARD LVCMOS33 DRIVE 4 SLEW FAST KEEPER TRUE}
set_property [get_ports {SRAM2_IO[7]}]        -dict { PACKAGE_PIN E16  IOSTANDARD LVCMOS33 DRIVE 4 SLEW FAST KEEPER TRUE}
set_property [get_ports {SRAM2_IO[8]}]        -dict { PACKAGE_PIN A17  IOSTANDARD LVCMOS33 DRIVE 4 SLEW FAST KEEPER TRUE}
set_property [get_ports {SRAM2_IO[9]}]        -dict { PACKAGE_PIN A20  IOSTANDARD LVCMOS33 DRIVE 4 SLEW FAST KEEPER TRUE}
set_property [get_ports {SRAM2_IO[10]}]       -dict { PACKAGE_PIN A18  IOSTANDARD LVCMOS33 DRIVE 4 SLEW FAST KEEPER TRUE}
set_property [get_ports {SRAM2_IO[11]}]       -dict { PACKAGE_PIN B19  IOSTANDARD LVCMOS33 DRIVE 4 SLEW FAST KEEPER TRUE}
set_property [get_ports {SRAM2_IO[12]}]       -dict { PACKAGE_PIN C18  IOSTANDARD LVCMOS33 DRIVE 4 SLEW FAST KEEPER TRUE}
set_property [get_ports {SRAM2_IO[13]}]       -dict { PACKAGE_PIN D18  IOSTANDARD LVCMOS33 DRIVE 4 SLEW FAST KEEPER TRUE}
set_property [get_ports {SRAM2_IO[14]}]       -dict { PACKAGE_PIN D19  IOSTANDARD LVCMOS33 DRIVE 4 SLEW FAST KEEPER TRUE}
set_property [get_ports {SRAM2_IO[15]}]       -dict { PACKAGE_PIN E17  IOSTANDARD LVCMOS33 DRIVE 4 SLEW FAST KEEPER TRUE}

# Configuration QSPI Flash Interface
set_property [get_ports CFG_MEM_SEL]          -dict { PACKAGE_PIN AF19 IOSTANDARD LVCMOS33 DRIVE 4 SLEW FAST}
set_property [get_ports CFG_MEM_MON]          -dict { PACKAGE_PIN AF20 IOSTANDARD LVCMOS33 }
set_property [get_ports CFG_MEM_CS_B]         -dict { PACKAGE_PIN P18  IOSTANDARD LVCMOS33 DRIVE 4 SLEW FAST}
set_property [get_ports {CFG_MEM_IO[0]}]      -dict { PACKAGE_PIN R14  IOSTANDARD LVCMOS33 DRIVE 4 SLEW FAST KEEPER TRUE}
set_property [get_ports {CFG_MEM_IO[1]}]      -dict { PACKAGE_PIN R15  IOSTANDARD LVCMOS33 DRIVE 4 SLEW FAST KEEPER TRUE}
set_property [get_ports {CFG_MEM_IO[2]}]      -dict { PACKAGE_PIN P14  IOSTANDARD LVCMOS33 DRIVE 4 SLEW FAST KEEPER TRUE}
set_property [get_ports {CFG_MEM_IO[3]}]      -dict { PACKAGE_PIN N14  IOSTANDARD LVCMOS33 DRIVE 4 SLEW FAST KEEPER TRUE}

# Data QSPI Flash Interface
set_property [get_ports DATA_MEM1_CS_B]       -dict { PACKAGE_PIN M25  IOSTANDARD LVCMOS33 DRIVE 4 SLEW FAST}
set_property [get_ports DATA_MEM1_SCK]        -dict { PACKAGE_PIN M26  IOSTANDARD LVCMOS33 DRIVE 4 SLEW FAST}
set_property [get_ports {DATA_MEM1_IO[0]}]    -dict { PACKAGE_PIN K26  IOSTANDARD LVCMOS33 DRIVE 4 SLEW FAST KEEPER TRUE}
set_property [get_ports {DATA_MEM1_IO[1]}]    -dict { PACKAGE_PIN L24  IOSTANDARD LVCMOS33 DRIVE 4 SLEW FAST KEEPER TRUE}
set_property [get_ports {DATA_MEM1_IO[2]}]    -dict { PACKAGE_PIN L25  IOSTANDARD LVCMOS33 DRIVE 4 SLEW FAST KEEPER TRUE}
set_property [get_ports {DATA_MEM1_IO[3]}]    -dict { PACKAGE_PIN K25  IOSTANDARD LVCMOS33 DRIVE 4 SLEW FAST KEEPER TRUE}
set_property [get_ports DATA_MEM2_CS_B]       -dict { PACKAGE_PIN P25  IOSTANDARD LVCMOS33 DRIVE 4 SLEW FAST}
set_property [get_ports DATA_MEM2_SCK]        -dict { PACKAGE_PIN N26  IOSTANDARD LVCMOS33 DRIVE 4 SLEW FAST}
set_property [get_ports {DATA_MEM2_IO[0]}]    -dict { PACKAGE_PIN T25  IOSTANDARD LVCMOS33 DRIVE 4 SLEW FAST KEEPER TRUE}
set_property [get_ports {DATA_MEM2_IO[1]}]    -dict { PACKAGE_PIN R26  IOSTANDARD LVCMOS33 DRIVE 4 SLEW FAST KEEPER TRUE}
set_property [get_ports {DATA_MEM2_IO[2]}]    -dict { PACKAGE_PIN R25  IOSTANDARD LVCMOS33 DRIVE 4 SLEW FAST KEEPER TRUE}
set_property [get_ports {DATA_MEM2_IO[3]}]    -dict { PACKAGE_PIN P26  IOSTANDARD LVCMOS33 DRIVE 4 SLEW FAST KEEPER TRUE}

# FRAM Interface
set_property [get_ports FRAM1_CS_B]           -dict { PACKAGE_PIN R22  IOSTANDARD LVCMOS33 DRIVE 4 SLEW FAST}
set_property [get_ports FRAM1_SCK]            -dict { PACKAGE_PIN M22  IOSTANDARD LVCMOS33 DRIVE 4 SLEW FAST}
set_property [get_ports {FRAM1_IO[0]}]        -dict { PACKAGE_PIN P21  IOSTANDARD LVCMOS33 DRIVE 4 SLEW FAST KEEPER TRUE}
set_property [get_ports {FRAM1_IO[1]}]        -dict { PACKAGE_PIN P23  IOSTANDARD LVCMOS33 DRIVE 4 SLEW FAST KEEPER TRUE}
set_property [get_ports {FRAM1_IO[2]}]        -dict { PACKAGE_PIN N21  IOSTANDARD LVCMOS33 DRIVE 4 SLEW FAST KEEPER TRUE}
set_property [get_ports {FRAM1_IO[3]}]        -dict { PACKAGE_PIN P20  IOSTANDARD LVCMOS33 DRIVE 4 SLEW FAST KEEPER TRUE}
set_property [get_ports FRAM2_CS_B]           -dict { PACKAGE_PIN M20  IOSTANDARD LVCMOS33 DRIVE 4 SLEW FAST}
set_property [get_ports FRAM2_SCK]            -dict { PACKAGE_PIN R21  IOSTANDARD LVCMOS33 DRIVE 4 SLEW FAST}
set_property [get_ports {FRAM2_IO[0]}]        -dict { PACKAGE_PIN M21  IOSTANDARD LVCMOS33 DRIVE 4 SLEW FAST KEEPER TRUE}
set_property [get_ports {FRAM2_IO[1]}]        -dict { PACKAGE_PIN N22  IOSTANDARD LVCMOS33 DRIVE 4 SLEW FAST KEEPER TRUE}
set_property [get_ports {FRAM2_IO[2]}]        -dict { PACKAGE_PIN N23  IOSTANDARD LVCMOS33 DRIVE 4 SLEW FAST KEEPER TRUE}
set_property [get_ports {FRAM2_IO[3]}]        -dict { PACKAGE_PIN R23  IOSTANDARD LVCMOS33 DRIVE 4 SLEW FAST KEEPER TRUE}

# CAN Interface
set_property [get_ports FPGA_CAN_TX]          -dict { PACKAGE_PIN AD21 IOSTANDARD LVCMOS33 DRIVE 4}
set_property [get_ports FPGA_CAN_RX]          -dict { PACKAGE_PIN AE21 IOSTANDARD LVCMOS33}
set_property [get_ports FPGA_CAN_SLEEP_EN]    -dict { PACKAGE_PIN AE20 IOSTANDARD LVCMOS33 DRIVE 4}

# (Internal/External) I2C Interface
set_property [get_ports FPGA_INT_SCL]         -dict { PACKAGE_PIN AE23 IOSTANDARD LVCMOS33 DRIVE 4}
set_property [get_ports FPGA_INT_SDA]         -dict { PACKAGE_PIN AF23 IOSTANDARD LVCMOS33 DRIVE 4}
set_property [get_ports CVM_CRITICAL_B]       -dict { PACKAGE_PIN AF24 IOSTANDARD LVCMOS33 }
set_property [get_ports CVM_WARNING_B]        -dict { PACKAGE_PIN AF25 IOSTANDARD LVCMOS33 }
set_property [get_ports TEMP_ALERT_B]         -dict { PACKAGE_PIN AD23 IOSTANDARD LVCMOS33 }
set_property [get_ports FPGA_EXT_SCL]         -dict { PACKAGE_PIN AE22 IOSTANDARD LVCMOS33 DRIVE 4}
set_property [get_ports FPGA_EXT_SDA]         -dict { PACKAGE_PIN AF22 IOSTANDARD LVCMOS33 DRIVE 4}

# TRCH Interface
set_property [get_ports FPGA_BOOT0]           -dict { PACKAGE_PIN AD26 IOSTANDARD LVCMOS33 }
set_property [get_ports FPGA_BOOT1]           -dict { PACKAGE_PIN AD25 IOSTANDARD LVCMOS33 }
set_property [get_ports FPGA_WATCHDOG]        -dict { PACKAGE_PIN AE25 IOSTANDARD LVCMOS33 DRIVE 4}
set_property [get_ports FPGA_RESERVE]         -dict { PACKAGE_PIN AC16 IOSTANDARD LVCMOS33 }
set_property [get_ports FPGA_PWR_CYCLE_REQ]   -dict { PACKAGE_PIN AE18 IOSTANDARD LVCMOS33 DRIVE 4}

# ULPI Interface
set_property [get_ports ULPI_CS]              -dict { PACKAGE_PIN AB1  IOSTANDARD LVCMOS18 DRIVE 4}
set_property [get_ports ULPI_RESET_B]         -dict { PACKAGE_PIN AB2  IOSTANDARD LVCMOS18 DRIVE 4}
set_property [get_ports ULPI_CLOCK]           -dict { PACKAGE_PIN AA3  IOSTANDARD LVCMOS18 }
set_property [get_ports ULPI_DIR]             -dict { PACKAGE_PIN AF5  IOSTANDARD LVCMOS18 }
set_property [get_ports ULPI_NXT]             -dict { PACKAGE_PIN AF4  IOSTANDARD LVCMOS18 }
set_property [get_ports ULPI_STP]             -dict { PACKAGE_PIN AE5  IOSTANDARD LVCMOS18 DRIVE 4 SLEW FAST}
set_property [get_ports {ULPI_DATA[0]}]       -dict { PACKAGE_PIN AE3  IOSTANDARD LVCMOS18 DRIVE 4 SLEW FAST}
set_property [get_ports {ULPI_DATA[1]}]       -dict { PACKAGE_PIN AF3  IOSTANDARD LVCMOS18 DRIVE 4 SLEW FAST}
set_property [get_ports {ULPI_DATA[2]}]       -dict { PACKAGE_PIN AE2  IOSTANDARD LVCMOS18 DRIVE 4 SLEW FAST}
set_property [get_ports {ULPI_DATA[3]}]       -dict { PACKAGE_PIN AF2  IOSTANDARD LVCMOS18 DRIVE 4 SLEW FAST}
set_property [get_ports {ULPI_DATA[4]}]       -dict { PACKAGE_PIN AE1  IOSTANDARD LVCMOS18 DRIVE 4 SLEW FAST}
set_property [get_ports {ULPI_DATA[5]}]       -dict { PACKAGE_PIN AD1  IOSTANDARD LVCMOS18 DRIVE 4 SLEW FAST}
set_property [get_ports {ULPI_DATA[6]}]       -dict { PACKAGE_PIN AC2  IOSTANDARD LVCMOS18 DRIVE 4 SLEW FAST}
set_property [get_ports {ULPI_DATA[7]}]       -dict { PACKAGE_PIN AC1  IOSTANDARD LVCMOS18 DRIVE 4 SLEW FAST}
set_property [get_ports ULPI_REFCLK]          -dict { PACKAGE_PIN AF17 IOSTANDARD LVCMOS33 DRIVE 4 SLEW FAST}

# User IO Interface
#set_property [get_ports UIO1_00]              -dict { PACKAGE_PIN R3   IOSTANDARD LVCMOS33 }
#set_property [get_ports UIO1_01]              -dict { PACKAGE_PIN P3   IOSTANDARD LVCMOS33 }
#set_property [get_ports UIO1_02]              -dict { PACKAGE_PIN P4   IOSTANDARD LVCMOS33 }
#set_property [get_ports UIO1_03]              -dict { PACKAGE_PIN N4   IOSTANDARD LVCMOS33 }
#set_property [get_ports UIO1_04]              -dict { PACKAGE_PIN M2   IOSTANDARD LVCMOS33 }
#set_property [get_ports UIO1_05]              -dict { PACKAGE_PIN L2   IOSTANDARD LVCMOS33 }
#set_property [get_ports UIO1_06]              -dict { PACKAGE_PIN H2   IOSTANDARD LVCMOS33 }
#set_property [get_ports UIO1_07]              -dict { PACKAGE_PIN H1   IOSTANDARD LVCMOS33 }
#set_property [get_ports UIO1_08]              -dict { PACKAGE_PIN K1   IOSTANDARD LVCMOS33 }
#set_property [get_ports UIO1_09]              -dict { PACKAGE_PIN J1   IOSTANDARD LVCMOS33 }
#set_property [get_ports UIO1_10]              -dict { PACKAGE_PIN N1   IOSTANDARD LVCMOS33 }
#set_property [get_ports UIO1_11]              -dict { PACKAGE_PIN M1   IOSTANDARD LVCMOS33 }
#set_property [get_ports UIO1_12]              -dict { PACKAGE_PIN U2   IOSTANDARD LVCMOS33 }
#set_property [get_ports UIO1_13]              -dict { PACKAGE_PIN U1   IOSTANDARD LVCMOS33 }
#set_property [get_ports UIO1_14]              -dict { PACKAGE_PIN K3   IOSTANDARD LVCMOS33 }
#set_property [get_ports UIO1_15]              -dict { PACKAGE_PIN J3   IOSTANDARD LVCMOS33 }
#set_property [get_ports UIO2_00]              -dict { PACKAGE_PIN E5   IOSTANDARD LVCMOS33 }
#set_property [get_ports UIO2_01]              -dict { PACKAGE_PIN D5   IOSTANDARD LVCMOS33 }
#set_property [get_ports UIO2_02]              -dict { PACKAGE_PIN G4   IOSTANDARD LVCMOS33 }
#set_property [get_ports UIO2_03]              -dict { PACKAGE_PIN F4   IOSTANDARD LVCMOS33 }
#set_property [get_ports UIO2_04]              -dict { PACKAGE_PIN D4   IOSTANDARD LVCMOS33 }
#set_property [get_ports UIO2_05]              -dict { PACKAGE_PIN C4   IOSTANDARD LVCMOS33 }
#set_property [get_ports UIO2_06]              -dict { PACKAGE_PIN C1   IOSTANDARD LVCMOS33 }
#set_property [get_ports UIO2_07]              -dict { PACKAGE_PIN B1   IOSTANDARD LVCMOS33 }
#set_property [get_ports UIO2_08]              -dict { PACKAGE_PIN E1   IOSTANDARD LVCMOS33 }
#set_property [get_ports UIO2_09]              -dict { PACKAGE_PIN D1   IOSTANDARD LVCMOS33 }
#set_property [get_ports UIO2_10]              -dict { PACKAGE_PIN G2   IOSTANDARD LVCMOS33 }
#set_property [get_ports UIO2_11]              -dict { PACKAGE_PIN G1   IOSTANDARD LVCMOS33 }
#set_property [get_ports UIO2_12]              -dict { PACKAGE_PIN A3   IOSTANDARD LVCMOS33 }
#set_property [get_ports UIO2_13]              -dict { PACKAGE_PIN A2   IOSTANDARD LVCMOS33 }
#set_property [get_ports UIO2_14]              -dict { PACKAGE_PIN B4   IOSTANDARD LVCMOS33 }
#set_property [get_ports UIO2_15]              -dict { PACKAGE_PIN A4   IOSTANDARD LVCMOS33 }
set_property [get_ports UIO4]                 -dict { PACKAGE_PIN AB16 IOSTANDARD LVCMOS33 DRIVE 4}
