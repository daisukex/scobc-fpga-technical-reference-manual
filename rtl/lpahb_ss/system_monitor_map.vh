//-----------------------------------------------
// Module: sysmon_map
//  System Monitor Register Map
//-----------------------------------------------
// Copyright © 2022 Space Cubics, LLC.
//-----------------------------------------------

// System Monitor Watchdog Control Register
`define SYSMON_WDOG_CTRL   16'h0000
`define  SM_SW_WDOG_MODE         24
`define  SM_SW_WDOG_TIME         16
`define  SM_WDOG_WSR              0

// System Monitor Watchdog Interval Register
`define SYSMON_WDOG_SIVAL  16'h0010
`define  SM_WDOG_SIVAL            0

// System Monitor Interrupt Status Register
`define SYSMON_INT_STATUS  16'h0030
`define  SEM_HTIMEOUT_INT        11
`define  SEM_HALTED_INT          10
`define  SEM_UNCORRECT_INT        9
`define  SEM_ECORRECT_INT         8

// System Monitor Interrupt Enable Register
`define SYSMON_INT_ENABLE  16'h0034
`define  SEM_HTIMEOUT_ENB        11
`define  SEM_HALTED_ENB          10
`define  SEM_UNCORRECT_ENB        9
`define  SEM_ECORRECT_ENB         8

// SEM Controller State Register
`define SYSMON_SEM_STATE   16'h0040
`define  SEM_PRE_INJECT          20
`define  SEM_PRE_CLASSIFIC       19
`define  SEM_PRE_CORRECT         18
`define  SEM_PRE_OBSERVE         17
`define  SEM_PRE_INIT            16
`define  SEM_CUR_INJECT           4
`define  SEM_CUR_CLASSIFIC        3
`define  SEM_CUR_CORRECT          2
`define  SEM_CUR_OBSERVE          1
`define  SEM_CUR_INIT             0

// SEM Error Correction Count Register
`define SYSMON_SEM_ECCOUNT 16'h0044
`define  SEM_CCOUNT               0

// SEM Heartbeat Timeout Register
`define SYSMON_SEM_HTIMEOUT 16'h0048
`define  SEM_HTIMEOUT              0

// SEM Error Injection Command Register
`define SYSMON_SEM_EINJECT1 16'h0050
`define  SEM_EINJECT1              0
`define SYSMON_SEM_EINJECT2 16'h0054
`define  SEM_EINJECT2              0

// XADC Access Register Field
`define SYSMON_XADC_BASE   16'h1000
