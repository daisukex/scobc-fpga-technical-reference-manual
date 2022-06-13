//-----------------------------------------------
// Module: sysmon_map
//  System Monitor Register Map
//-----------------------------------------------
// Copyright © 2022 Space Cubics, LLC.
//-----------------------------------------------

// System Monitor Watchdog Control Register
`define SYSMON_WDOG_CTRL   16'h0000
`define  SM_SW_WDOG_TIME         16
`define  SM_WDOG_WSR              0

// System Monitor Watchdog Interval Register
`define SYSMON_WDOG_SIVAL  16'h0010
`define  SM_WDOG_SIVAL            0

// XADC Access Register Field
`define SYSMON_XADC_BASE   16'h1000
