//-----------------------------------------------
// Space Cubics SC-OBC-A1
// SC-OBC-A1 Debug Controller Register Map
// Module: scobca1_dbg_reg_map
//-----------------------------------------------
// Copyright © 2022 Space Cubics, LLC.
//-----------------------------------------------

// SRAM_Axx Control Register
`define DBG_SRAM_A_CTRLR           16'h0000
`define  DBG_SRAM_A_GPIOMD                0
// SRAM1_CE_B Control Register
`define DBG_SRAM1_CEB_CTRLR        16'h0050
`define  DBG_SRAM1_CEB_GPIOMD             0
// SRAM1_OE_B Control Register
`define DBG_SRAM1_OEB_CTRLR        16'h0054
`define  DBG_SRAM1_OEB_GPIOMD             0
// SRAM1_WE_B Control Register
`define DBG_SRAM1_WEB_CTRLR        16'h0058
`define  DBG_SRAM1_WEB_GPIOMD             0
// SRAM1_BHE_B Control Register
`define DBG_SRAM1_BHEB_CTRLR       16'h005C
`define  DBG_SRAM1_BHEB_GPIOMD            0
// SRAM1_BLE_B Control Register
`define DBG_SRAM1_BLEB_CTRLR       16'h0060
`define  DBG_SRAM1_BLEB_GPIOMD            0
// SRAM2_CE_B Control Register
`define DBG_SRAM2_CEB_CTRLR        16'h0064
`define  DBG_SRAM2_CEB_GPIOMD             0
// SRAM2_OE_B Control Register
`define DBG_SRAM2_OEB_CTRLR        16'h0068
`define  DBG_SRAM2_OEB_GPIOMD             0
// SRAM2_WE_B Control Register
`define DBG_SRAM2_WEB_CTRLR        16'h006C
`define  DBG_SRAM2_WEB_GPIOMD             0
// SRAM2_BHE_B Control Register
`define DBG_SRAM2_BHEB_CTRLR       16'h0070
`define  DBG_SRAM2_BHEB_GPIOMD            0
// SRAM2_BLE_B Control Register
`define DBG_SRAM2_BLEB_CTRLR       16'h0074
`define  DBG_SRAM2_BLEB_GPIOMD            0
// SRAM I/F Monitor Register
`define DBG_SRAM_MONR              16'h0078
`define  DBG_SRAM_A_MON                  10
`define  DBG_SRAM1_CEB_MON                9
`define  DBG_SRAM1_OEB_MON                8
`define  DBG_SRAM1_WEB_MON                7
`define  DBG_SRAM1_BHEB_MON               6
`define  DBG_SRAM1_BLEB_MON               5
`define  DBG_SRAM2_CEB_MON                4
`define  DBG_SRAM2_OEB_MON                3
`define  DBG_SRAM2_WEB_MON                2
`define  DBG_SRAM2_BHEB_MON               1
`define  DBG_SRAM2_BLEB_MON               0

// CFG_MEM_CS_B Control Register
`define DBG_CFG_MEM_CSB_CTRLR      16'h0100
`define  DBG_CFG_MEM_CSB_GPIOMD           0
// CFG_MEM_IOx Control Register
`define DBG_CFG_MEM_IO_CTRLR       16'h0104
`define  DBG_CFG_MEM_IO_GPIOMD            0
// QSPI CFG_MEM I/F Monitor Register
`define DBG_CFG_MEM_MONR           16'h0114
`define  DBG_CFG_MEM_CSB_MON              4
`define  DBG_CFG_MEM_IO_MON               0

// DATA_MEM1_CS_B Control Register
`define DBG_DATA_MEM1_CSB_CTRLR    16'h0200
`define  DBG_DATA_MEM1_CSB_GPIOMD         0
// DATA_MEM1_IOx Control Register
`define DBG_DATA_MEM1_IO_CTRLR     16'h0204
`define  DBG_DATA_MEM1_IO_GPIOMD          0
// DATA_MEM2_CS_B Control Register
`define DBG_DATA_MEM2_CSB_CTRLR    16'h0214
`define  DBG_DATA_MEM2_CSB_GPIOMD         0
// DATA_MEM2_IOx Control Register
`define DBG_DATA_MEM2_IO_CTRLR     16'h0218
`define  DBG_DATA_MEM2_IO_GPIOMD          0
// QSPI DATA_MEM I/F Monitor Register
`define DBG_DATA_MEM_MONR          16'h0228
`define  DBG_DATA_MEM1_CSB_MON            9
`define  DBG_DATA_MEM1_IO_MON             5
`define  DBG_DATA_MEM2_CSB_MON            4
`define  DBG_DATA_MEM2_IO_MON             0

// FRAM1_CS_B Control Register
`define DBG_FRAM1_CSB_CTRLR        16'h0300
`define  DBG_FRAM1_CSB_GPIOMD             0
// FRAM1_IOx Control Register
`define DBG_FRAM1_IO_CTRLR         16'h0304
`define  DBG_FRAM1_IO_GPIOMD              0
// FRAM2_CS_B Control Register
`define DBG_FRAM2_CSB_CTRLR        16'h0314
`define  DBG_FRAM2_CSB_GPIOMD             0
// FRAM2_IOx Control Register
`define DBG_FRAM2_IO_CTRLR         16'h0318
`define  DBG_FRAM2_IO_GPIOMD              0
// QSPI FRAM I/F Monitor Register
`define DBG_FRAM_MONR              16'h0328
`define  DBG_FRAM1_CSB_MON                9
`define  DBG_FRAM1_IO_MON                 5
`define  DBG_FRAM2_CSB_MON                4
`define  DBG_FRAM2_IO_MON                 0

// SYSCLK Monitor Register
`define DBG_SYSCLK_MONR            16'h0400
`define  DBG_SYSCLK2_STS                  1
`define  DBG_SYSCLK1_STS                  0

// CVM/TEMP Monitor Register
`define DBG_CVMTMP_MONR            16'h0500
`define  DBG_TMPALERT_MON                 2
`define  DBG_CVMWARNING_MON               1
`define  DBG_CVMCRITICAL_MON              0

// EXT_I2C_SCL Control Register
`define DBG_EXTI2C_SCL_CTLR        16'h0600
`define  DBG_EXTI2C_SCL_GPIOMD            0
// EXT_I2C_SDA Control Register
`define DBG_EXTI2C_SDA_CTLR        16'h0604
`define  DBG_EXTI2C_SDA_GPIOMD            0
// External I2C I/F Monitor Register
`define DBG_EXTI2C_MONR            16'h0608
`define  DBG_EXTI2C_SCL_MON               1
`define  DBG_EXTI2C_SDA_MON               0

// FPGA_BOOT Monitor Register
`define DBG_BOOT_MONR              16'h0700
`define  DBG_BOOTSHIFT_MON                0
// FPGA_WATCHDOG Control Register
`define DBG_WATCHDOG_CTRLR         16'h0704
`define  DBG_WATCHDOG_GPIOMD              0
// FPGA_PWR_CYCLE_REQ Control Register
`define DBG_PWR_CYCLE_REQ_CTRLR    16'h0708
`define  DBG_PWR_CYCLE_REQ_GPIOMD         0
// FPGA_RESERVE Control Register
`define DBG_RESERVE_CTRLR          16'h070C
`define  DBG_RESERVE_GPIOMD               0
// TRCH I/F Monitor Register
`define DBG_TRCH_MONR              16'h0710
`define  DBG_WATCHDOG_MON                 2
`define  DBG_PWR_CYCLE_REQ_MON            1
`define  DBG_RESERVE_MON                  0

// ULPI_CLOCK Monitor Register
`define DBG_ULPI_CLOCK_MONR        16'h0800
`define  DBG_ULPI_CLOCK_STS               0
// ULPI_RESET_B Control Register
`define DBG_ULPI_RESET_B_CTRLR     16'h0804
`define  DBG_ULPI_RESET_B_GPIOMD          0
// ULPI_CS Control Register
`define DBG_ULPI_CS_CTRLR          16'h0808
`define  DBG_ULPI_CS_GPIOMD               0
// ULPI I/F Monitor Register
`define DBG_ULPI_MONR              16'h080C
`define  DBG_ULPI_RESET_B_MON             1
`define  DBG_ULPI_CS_MON                  0

// FPGA Config I/F Monitor Register
`define DBG_FPGA_CFG_MONR          16'h0B00
`define  DBG_PUDCB_MON                    0

// UIO1_xx Control Register
`define DBG_UIO1_CTRLR             16'h0C00
`define  DBG_UIO1_GPIOMD                  0
// UIO1 I/F Monitor Register
`define DBG_UIO1_MONR              16'h0C40
`define  DBG_UIO1_MON                     0

// UIO2_xx Control Register
`define DBG_UIO2_CTRLR             16'h0D00
`define  DBG_UIO2_GPIOMD                  0
// UIO2 I/F Monitor Register
`define DBG_UIO2_MONR              16'h0D40
`define  DBG_UIO2_MON                     0

// UIO4_xx Control Register
`define DBG_UIO4_CTRLR             16'h0E00
`define  DBG_UIO4_GPIOMD                  0
// UIO4 I/F Monitor Register
`define DBG_UIO4_MONR              16'h0E18
`define  DBG_UIO4_MON                     0

// RSV_xx Control Register
`define DBG_RSV_CTRLR              16'h0F00
`define  DBG_RSV_GPIOMD                   0
// Reserve Monitor Register
`define DBG_RSV_MONR               16'h0F40
`define  DBG_RSV_MON                      0
