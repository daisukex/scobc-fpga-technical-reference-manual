# --------------------------------------------------
# Space Cubics OBC A1 (SC-OBC-A1)
# FPGA IO Configuration file (.xdc)
#  sc_obc_a1_fpga_io.tcl
#  Copyright © 2022 Space Cubics, LLC.
# --------------------------------------------------

# Config
set_property CFGBVS VCCO [current_design];
set_property CONFIG_VOLTAGE 3.3 [current_design];

# System Interface
set_property [get_ports SYSCLK1]              -dict { PACKAGE_PIN U22  IOSTANDARD LVCMOS33 };
set_property [get_ports SYSCLK1_EN]           -dict { PACKAGE_PIN V26  IOSTANDARD LVCMOS33 };
set_property [get_ports SYSCLK2]              -dict { PACKAGE_PIN U21  IOSTANDARD LVCMOS33 };
set_property [get_ports SYSCLK2_EN]           -dict { PACKAGE_PIN W26  IOSTANDARD LVCMOS33 };
set_property [get_ports CDRST_B]              -dict { PACKAGE_PIN AF18 IOSTANDARD LVCMOS33 };
set_property [get_ports CFG_DONE]             -dict { PACKAGE_PIN AE18 IOSTANDARD LVCMOS33 };

# Debug Interface
set_property [get_ports CM3_NTRST]            -dict { PACKAGE_PIN U24  IOSTANDARD LVCMOS33 };
set_property [get_ports CM3_TDI]              -dict { PACKAGE_PIN Y20  IOSTANDARD LVCMOS33 };
set_property [get_ports CM3_TCK_SWCLK]        -dict { PACKAGE_PIN W21  IOSTANDARD LVCMOS33 };
set_property [get_ports CM3_TMS_SWDIO]        -dict { PACKAGE_PIN Y21  IOSTANDARD LVCMOS33 };
set_property [get_ports CM3_TDO_SWO]          -dict { PACKAGE_PIN W20  IOSTANDARD LVCMOS33 };

# Configuration QSPI Flash Interface
set_property [get_ports CFG_MEM_SEL]          -dict { PACKAGE_PIN AF19 IOSTANDARD LVCMOS33 };
set_property [get_ports CFG_MEM_MON]          -dict { PACKAGE_PIN AF20 IOSTANDARD LVCMOS33 };
set_property [get_ports CFG_MEM_SCK]          -dict { PACKAGE_PIN P16  IOSTANDARD LVCMOS33 };
set_property [get_ports CFG_MEM_CS_B]         -dict { PACKAGE_PIN P18  IOSTANDARD LVCMOS33 };
set_property [get_ports {CFG_MEM_IO[0]}]      -dict { PACKAGE_PIN R14  IOSTANDARD LVCMOS33 };
set_property [get_ports {CFG_MEM_IO[1]}]      -dict { PACKAGE_PIN R15  IOSTANDARD LVCMOS33 };
set_property [get_ports {CFG_MEM_IO[2]}]      -dict { PACKAGE_PIN P14  IOSTANDARD LVCMOS33 };
set_property [get_ports {CFG_MEM_IO[3]}]      -dict { PACKAGE_PIN N14  IOSTANDARD LVCMOS33 };

# Data QSPI Flash Interface
set_property [get_ports DATA_MEM1_CS_B]       -dict { PACKAGE_PIN M25  IOSTANDARD LVCMOS33 };
set_property [get_ports DATA_MEM1_SCK]        -dict { PACKAGE_PIN M26  IOSTANDARD LVCMOS33 };
set_property [get_ports {DATA_MEM1_IO[0]}]    -dict { PACKAGE_PIN K26  IOSTANDARD LVCMOS33 };
set_property [get_ports {DATA_MEM1_IO[1]}]    -dict { PACKAGE_PIN L24  IOSTANDARD LVCMOS33 };
set_property [get_ports {DATA_MEM1_IO[2]}]    -dict { PACKAGE_PIN L25  IOSTANDARD LVCMOS33 };
set_property [get_ports {DATA_MEM1_IO[3]}]    -dict { PACKAGE_PIN K25  IOSTANDARD LVCMOS33 };
set_property [get_ports DATA_MEM2_CS_B]       -dict { PACKAGE_PIN P25  IOSTANDARD LVCMOS33 };
set_property [get_ports DATA_MEM2_SCK]        -dict { PACKAGE_PIN N26  IOSTANDARD LVCMOS33 };
set_property [get_ports {DATA_MEM2_IO[0]}]    -dict { PACKAGE_PIN T25  IOSTANDARD LVCMOS33 };
set_property [get_ports {DATA_MEM2_IO[1]}]    -dict { PACKAGE_PIN R26  IOSTANDARD LVCMOS33 };
set_property [get_ports {DATA_MEM2_IO[2]}]    -dict { PACKAGE_PIN R25  IOSTANDARD LVCMOS33 };
set_property [get_ports {DATA_MEM2_IO[3]}]    -dict { PACKAGE_PIN P26  IOSTANDARD LVCMOS33 };

# FRAM Interface
set_property [get_ports FRAM1_CS_B]           -dict { PACKAGE_PIN R22  IOSTANDARD LVCMOS33 };
set_property [get_ports FRAM1_SCK]            -dict { PACKAGE_PIN M22  IOSTANDARD LVCMOS33 };
set_property [get_ports {FRAM1_IO[0]}]        -dict { PACKAGE_PIN P21  IOSTANDARD LVCMOS33 };
set_property [get_ports {FRAM1_IO[1]}]        -dict { PACKAGE_PIN P23  IOSTANDARD LVCMOS33 };
set_property [get_ports {FRAM1_IO[2]}]        -dict { PACKAGE_PIN N21  IOSTANDARD LVCMOS33 };
set_property [get_ports {FRAM1_IO[3]}]        -dict { PACKAGE_PIN P20  IOSTANDARD LVCMOS33 };
set_property [get_ports FRAM2_CS_B]           -dict { PACKAGE_PIN M20  IOSTANDARD LVCMOS33 };
set_property [get_ports FRAM2_SCK]            -dict { PACKAGE_PIN R21  IOSTANDARD LVCMOS33 };
set_property [get_ports {FRAM2_IO[0]}]        -dict { PACKAGE_PIN M21  IOSTANDARD LVCMOS33 };
set_property [get_ports {FRAM2_IO[1]}]        -dict { PACKAGE_PIN N22  IOSTANDARD LVCMOS33 };
set_property [get_ports {FRAM2_IO[2]}]        -dict { PACKAGE_PIN N23  IOSTANDARD LVCMOS33 };
set_property [get_ports {FRAM2_IO[3]}]        -dict { PACKAGE_PIN R23  IOSTANDARD LVCMOS33 };

# CAN Interface
set_property [get_ports FPGA_CAN_TX]          -dict { PACKAGE_PIN AD21 IOSTANDARD LVCMOS33 }
set_property [get_ports FPGA_CAN_RX]          -dict { PACKAGE_PIN AE21 IOSTANDARD LVCMOS33 }
set_property [get_ports FPGA_CAN_SLEEP_EN]    -dict { PACKAGE_PIN AE20 IOSTANDARD LVCMOS33 }

# (Internal/External) I2C Interface
set_property [get_ports FPGA_INT_SCL]         -dict { PACKAGE_PIN AE23 IOSTANDARD LVCMOS33 }
set_property [get_ports FPGA_INT_SDA]         -dict { PACKAGE_PIN AF23 IOSTANDARD LVCMOS33 }
set_property [get_ports CVM_CRITICAL_B]       -dict { PACKAGE_PIN AF24 IOSTANDARD LVCMOS33 }
set_property [get_ports CVM_WARNING_B]        -dict { PACKAGE_PIN AF25 IOSTANDARD LVCMOS33 }
set_property [get_ports TEMP_ALERT_B]         -dict { PACKAGE_PIN AD23 IOSTANDARD LVCMOS33 }
set_property [get_ports FPGA_EXT_SCL]         -dict { PACKAGE_PIN AE22 IOSTANDARD LVCMOS33 }
set_property [get_ports FPGA_EXT_SDA]         -dict { PACKAGE_PIN AF22 IOSTANDARD LVCMOS33 }

# TRCH Interface
set_property [get_ports FPGA_BOOT0]           -dict { PACKAGE_PIN AD26 IOSTANDARD LVCMOS33 }
set_property [get_ports FPGA_BOOT1]           -dict { PACKAGE_PIN AD25 IOSTANDARD LVCMOS33 }
set_property [get_ports FPGA_WATCHDOG]        -dict { PACKAGE_PIN AE25 IOSTANDARD LVCMOS33 }
set_property [get_ports FPGA_RESERVE]         -dict { PACKAGE_PIN AC16 IOSTANDARD LVCMOS33 }

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
set_property [get_ports UIO4]                 -dict { PACKAGE_PIN AB16 IOSTANDARD LVCMOS33 }
