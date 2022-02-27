//-----------------------------------------------
// Module: sysreg_map
//  System Register Map
//-----------------------------------------------
// Copyright © 2021 Space Cubics, LLC.
//-----------------------------------------------
// Configuration Memory Control Register
`define SYSREG_CFGMEMCTL       16'h0000
`define  SYSREG_CFGMEMCTLPKC         16
`define  SYSREG_ITCMEN                0
// System Clock Control Register
`define SYSREG_SYSCLKCTL       16'h0004
`define  SYSREG_CLKMODE               0
// Scratch Pad 1 Register
`define SYSREG_SPAD1           16'h00F0
`define  SYSREG_SPAD1CTL              0
// Scratch Pad 2 Register
`define SYSREG_SPAD2           16'h00F4
`define  SYSREG_SPAD2CTL              0
// Scratch Pad 3 Register
`define SYSREG_SPAD3           16'h00F8
`define  SYSREG_SPAD3CTL              0
// Scratch Pad 4 Register
`define SYSREG_SPAD4           16'h00FC
`define  SYSREG_SPAD4CTL              0
// IP Version Register
`define SYSREG_VER             16'hF000
`define  SYSREG_PATVER                0
`define  SYSREG_MINVER               16
`define  SYSREG_MAJVER               24
