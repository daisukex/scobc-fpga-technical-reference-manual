//-----------------------------------------------
// Module: sysmon_map
//  System Monitor Register Map
//-----------------------------------------------
// Copyright © 2022 Space Cubics, LLC.
//-----------------------------------------------

// System Monitor Watchdog Control Register
`define SYSMON_WDOG_CTRL   16'h0000
`define  SM_WDOG_START            0
`define  SM_TRCH_WDOG_SE          4
`define  SM_SW_WDOG_RESET         8
`define  SM_HW_WDOG_RESET         9
`define  SM_SW_WDOG_TIME         16

// System Monitor Watchdog Service Register
`define SYSMON_WDOG_WSR    16'h0004
`define  SM_WDOG_WSR              0

// System Monitor Watchdog Interval Register
`define SYSMON_WDOG_SIVAL  16'h0010
`define  SM_WDOG_SIVAL            0
