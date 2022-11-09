//-----------------------------------------------
// Space Cubics OBC A1 FPGA
//  Register Map and ISR Configuration file
//-----------------------------------------------
// Copyright © 2022 Space Cubics, LLC.
//-----------------------------------------------

`define CFG_QSPI_BASE 32'h4000_0000
`define DAT_QSPI_BASE 32'h4010_0000
`define FRM_QSPI_BASE 32'h4020_0000
`define CAN_BASE      32'h4040_0000
`define HRMEMREG_BASE 32'h4050_0000
`define SYSREG_BASE   32'h4F00_0000
`define UARTLITE_BASE 32'h4F01_0000
`define EXT_I2CM_BASE 32'h4F03_0000
`define SYS_MON_BASE  32'h4F04_0000
`define GPTMR_BASE    32'h4F05_0000
`define HRMEM_MR_BASE 32'h6000_0000

`define CM3_ISR_UARTLITE 0
`define CM3_ISR_HRMEM    1
`define CM3_ISR_CFG_QSPI 2
`define CM3_ISR_DAT_QSPI 3
`define CM3_ISR_FRM_QSPI 4
`define CM3_ISR_CAN      5
`define CM3_ISR_EXT_I2CM 7
`define CM3_ISR_SMON_HW  8
`define CM3_ISR_SMON_BHM 9
`define CM3_ISR_GTMR     10
`define CM3_ISR_SITMR    11
