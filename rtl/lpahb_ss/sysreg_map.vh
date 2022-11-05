//-----------------------------------------------
// Module: sysreg_map
//  System Register Map
//-----------------------------------------------
// Copyright © 2021 Space Cubics, LLC.
//-----------------------------------------------
// Configuration Memory Control Register
`define SYSREG_CODEMSEL        16'h0000
`define  SR_ITCMENPKC                16
`define  SR_ITCMEN                    0
// System Clock Control Register
`define SYSREG_SYSCLKCTL       16'h0004
`define  SR_CLKMODE                   0
// Configuration Memory Register
`define SYSREG_CFGMEMCTL       16'h0010
`define  SR_CFGBOOTMEM               12
`define  SR_CFGMEMSELMON              5
`define  SR_CFGMEMSEL                 4
`define  SR_CFGMEMOWNER               0
// Power Cycle Register
`define SYSREG_PWRCYCLE        16'h0020
`define  SR_PWECYCLEPKC              16
`define  SR_PWECYCLEREQ               0
// Scratch Pad 1 Register
`define SYSREG_SPAD1           16'h00F0
`define  SR_SPAD1                     0
// Scratch Pad 2 Register
`define SYSREG_SPAD2           16'h00F4
`define  SR_SPAD2                     0
// Scratch Pad 3 Register
`define SYSREG_SPAD3           16'h00F8
`define  SR_SPAD3                     0
// Scratch Pad 4 Register
`define SYSREG_SPAD4           16'h00FC
`define  SR_SPAD4                     0
// IP Version Register
`define SYSREG_VER             16'hF000
`define  SR_PATVER                    0
`define  SR_MINVER                   16
`define  SR_MAJVER                   24
// Git Hash Register
`define SYSREG_BUILDINFO       16'hFF00
`define  SR_BUILDINFO                 0
// FPGA eFuse DNA Register
`define SYSREG_FUSEDNA1        16'hFF10
`define  SR_DNA_LSB                   0
`define SYSREG_FUSEDNA2        16'hFF14
`define  SR_DNA_MSB                   0
// FPGA eFuse USER Register
`define SYSREG_FUSEUSR         16'hFF18
`define  SR_USER                      0
