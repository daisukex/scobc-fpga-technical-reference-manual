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

// Clock Monitor Register
`define SYSMON_CLK_MONITOR 16'h0020
`define  UCLK2_STS               12
`define  UCLK1_STS               11
`define  ULPICLK_STS             10
`define  MAXICLK_STS              9
`define  SYSCLK_STS               8
`define  SM_OSC_CLKEN             0

// Hardware Status Register
`define SYSMON_HW_STATUS1  16'h0024
`define  HWARE_STATUS1            0
`define SYSMON_HW_STATUS2  16'h0028
`define  HWARE_STATUS2            0

// System Monitor Interrupt Status Register
`define SYSMON_INT_STATUS  16'h0030
`define  SEM_HTIMEOUT_INT        11
`define  SEM_HALTED_INT          10
`define  SEM_UNCORRECT_INT        9
`define  SEM_ECORRECT_INT         8
`define  UCLK2_STOP_INT           4
`define  UCLK1_STOP_INT           3
`define  ULPICLK_STOP_INT         2
`define  MAXICLK_STOP_INT         1
`define  SYSCLK_STOP_INT          0

// System Monitor Interrupt Enable Register
`define SYSMON_INT_ENABLE  16'h0034
`define  SEM_HTIMEOUT_ENB        11
`define  SEM_HALTED_ENB          10
`define  SEM_UNCORRECT_ENB        9
`define  SEM_ECORRECT_ENB         8
`define  UCLK2_STOP_ENB           4
`define  UCLK1_STOP_ENB           3
`define  ULPICLK_STOP_ENB         2
`define  MAXICLK_STOP_ENB         1
`define  SYSCLK_STOP_ENB          0

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

// Board Health Initialization Access Control Register
`define SYSMON_BHM_INICTLR           16'h2000
`define  SYSMON_BHM_INITREQ                16
`define  SYSMON_BHM_INITEN                  0

// Board Health Monitoring Access Control Register
`define SYSMON_BHM_MONCTLR           16'h2004
`define  SYSMON_BHM_MONIEN                  0

// Board Health Interrupt Status Register
`define SYSMON_BHM_ISR               16'h2010
`define  SYSMON_BHM_TEMPALERT              18
`define  SYSMON_BHM_CVMWARN                17
`define  SYSMON_BHM_CVMCRIT                16
`define  SYSMON_BHM_I2CERR                  8
`define  SYSMON_BHM_SWACCEND                1
`define  SYSMON_BHM_INITACCEND              0

// Board Health Interrupt Enable Register
`define SYSMON_BHM_IER               16'h2014
`define  SYSMON_BHM_TEMPALERTENB           18
`define  SYSMON_BHM_CVMWARNENB             17
`define  SYSMON_BHM_CVMCRITENB             16
`define  SYSMON_BHM_I2CERRENB               8
`define  SYSMON_BHM_SWACCENDENB             1
`define  SYSMON_BHM_INITACCENDENB           0

// Board Health VDD_1V0 Shunt Voltage Monitor Register
`define SYSMON_BHM_1V0SNTVR          16'h2020
`define  SYSMON_BHM_1V0SNTV_NUPD           31
`define  SYSMON_BHM_1V0SNTV                 0

// Board Health VDD_1V0 Bus Voltage Monitor Register
`define SYSMON_BHM_1V0BUSVR          16'h2024
`define  SYSMON_BHM_1V0BUSV_NUPD           31
`define  SYSMON_BHM_1V0BUSV                 0

// Board Health VDD_1V8 Shunt Voltage Monitor Register
`define SYSMON_BHM_1V8SNTVR          16'h2028
`define  SYSMON_BHM_1V8SNTV_NUPD           31
`define  SYSMON_BHM_1V8SNTV                 0

// Board Health VDD_1V8 Bus Voltage Monitor Register
`define SYSMON_BHM_1V8BUSVR          16'h202C
`define  SYSMON_BHM_1V8BUSV_NUPD           31
`define  SYSMON_BHM_1V8BUSV                 0

// Board Health VDD_3V3 Shunt Voltage Monitor Register
`define SYSMON_BHM_3V3SNTVR          16'h2030
`define  SYSMON_BHM_3V3SNTV_NUPD           31
`define  SYSMON_BHM_3V3SNTV                 0

// Board Health VDD_3V3 Bus Voltage Monitor Register
`define SYSMON_BHM_3V3BUSVR          16'h2034
`define  SYSMON_BHM_3V3BUSV_NUPD           31
`define  SYSMON_BHM_3V3BUSV                 0

// Board Health VDD_3V3_SYS_A Shunt Voltage Monitor Register
`define SYSMON_BHM_3V3SYSASNTVR      16'h2038
`define  SYSMON_BHM_3V3SYSASNTV_NUPD       31
`define  SYSMON_BHM_3V3SYSASNTV             0

// Board Health VDD_3V3_SYS_A Bus Voltage Monitor Register
`define SYSMON_BHM_3V3SYSABUSVR      16'h203C
`define  SYSMON_BHM_3V3SYSABUSV_NUPD       31
`define  SYSMON_BHM_3V3SYSABUSV             0

// Board Health VDD_3V3_SYS_B Shunt Voltage Monitor Register
`define SYSMON_BHM_3V3SYSBSNTVR      16'h2040
`define  SYSMON_BHM_3V3SYSBSNTV_NUPD       31
`define  SYSMON_BHM_3V3SYSBSNTV             0

// Board Health VDD_3V3_SYS_B Bus Voltage Monitor Register
`define SYSMON_BHM_3V3SYSBBUSVR      16'h2044
`define  SYSMON_BHM_3V3SYSBBUSV_NUPD       31
`define  SYSMON_BHM_3V3SYSBBUSV             0

// Board Health VDD_3V3_IO Shunt Voltage Monitor Register
`define SYSMON_BHM_3V3IOSNTVR        16'h2048
`define  SYSMON_BHM_3V3IOSNTV_NUPD         31
`define  SYSMON_BHM_3V3IOSNTV               0

// Board Health VDD_3V3_IO Bus Voltage Monitor Register
`define SYSMON_BHM_3V3IOBUSVR        16'h204C
`define  SYSMON_BHM_3V3IOBUSV_NUPD         31
`define  SYSMON_BHM_3V3IOBUSV               0

// Board Health Temperature1 Monitor Register
`define SYSMON_BHM_TEMP1R            16'h2050
`define  SYSMON_BHM_TEMP1_NUPD             31
`define  SYSMON_BHM_TEMP1                   0

// Board Health Temperature2 Monitor Register
`define SYSMON_BHM_TEMP2R            16'h2054
`define  SYSMON_BHM_TEMP2_NUPD             31
`define  SYSMON_BHM_TEMP2                   0

// Board Health Temperature3 Monitor Register
`define SYSMON_BHM_TEMP3R            16'h2058
`define  SYSMON_BHM_TEMP3_NUPD             31
`define  SYSMON_BHM_TEMP3                   0

// Board Health Software Access Control Register
`define SYSMON_BHM_SWCTLR            16'h2060
`define  SYSMON_BHM_SWACCREQ               24
`define  SYSMON_BHM_SWDEVSEL               16
`define  SYSMON_BHM_SWREGADR                8
`define  SYSMON_BHM_SWRWSEL                 0

// Board Health Software Access Write Data Register
`define SYSMON_BHM_SWWDTR            16'h2064
`define  SYSMON_BHM_SWWRDATA                0

// Board Health Software Access Read Data Register
`define SYSMON_BHM_SWRDTR            16'h2068
`define  SYSMON_BHM_SWRDDATA                0

// Board Health I2C Prescale Setting Register
`define SYSMON_BHM_I2CPSCR           16'h2080
`define  SYSMON_BHM_CLKPSC                  0

// Board Health I2C Access Count Setting Register
`define SYSMON_BHM_I2CACCCNTR        16'h2084
`define  SYSMON_BHM_I2CACCCNT               0

// Board Health Access Status Register
`define SYSMON_BHM_ASR               16'h20C0
`define  SYSMON_BHM_BUSY                    0
