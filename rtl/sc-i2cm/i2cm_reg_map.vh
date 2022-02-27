//-----------------------------------------------
// Module: i2cm_reg_map
//  I2C Master Controller Register Map
//-----------------------------------------------
// Copyright © 2021 Space Cubics, LLC.
//-----------------------------------------------
// I2C Master Enable Register
`define I2CM_ENR         16'h0000
`define  I2CM_EN                0
// I2C Master TX FIFO Register
`define I2CM_TXFIFOR     16'h0004
`define  I2CM_TXDATA            0
`define  I2CM_STOP              8
`define  I2CM_RESTART           9
// I2C Master RX FIFO Register
`define I2CM_RXFIFOR     16'h0008
`define  I2CM_RXDATA            0
// I2C Master Bus Status Register
`define I2CM_BSR         16'h000C
`define  I2CM_SELFBUSY          0
`define  I2CM_OTHERBUSY         1
// I2C Master Interrput Status Register
`define I2CM_ISR         16'h0010
`define  I2CM_COMP              0
`define  I2CM_ARBLST            1
`define  I2CM_TXFIFOUTH         4
`define  I2CM_RXFIFOOTH         5
`define  I2CM_ACKER             8
`define  I2CM_BITER             9
`define  I2CM_TXFIFOOVF        10
`define  I2CM_RXFIFOUDF        11
`define  I2CM_SCLTO            12
// I2C Master Interrupt Enable Register
`define I2CM_IER         16'h0014
`define  I2CM_COMPENB           0
`define  I2CM_ARBLSTENB         1
`define  I2CM_TXFIFOUTHENB      4
`define  I2CM_RXFIFOOTHENB      5
`define  I2CM_ACKERENB          8
`define  I2CM_BITERENB          9
`define  I2CM_TXFIFOOVFENB     10
`define  I2CM_RXFIFOUDFENB     11
`define  I2CM_SCLTOENB         12
// I2C Master FIFO Status Register
`define I2CM_FIFOSR      16'h0018
`define  I2CM_TXFIFOCAP         0
`define  I2CM_RXFIFOCAP        16
// I2C Master FIFO Reset Register
`define I2CM_FIFORR      16'h001C
`define  I2CM_TXFIFORST         0
`define  I2CM_RXFIFORST        16
// I2C Master FIFO Threshold Level Setting Register
`define I2CM_FTLSR       16'h0020
`define  I2CM_TXFIFOUTHL        0
`define  I2CM_RXFIFOOTHL       16
// I2C Master SCL Timeout Setting Register
`define I2CM_SCLTSR      16'h0024
`define  I2CM_SCLTOPROD         0
// I2C Master START Hold Timing Setting Register
`define I2CM_THDSTAR     16'h0030
`define  I2CM_THDSTA            0
// I2C Master STOP Setup Timing Setting Register
`define I2CM_TSUSTOR     16'h0034
`define  I2CM_TSUSTO            0
// I2C Master Repeated START Setup Timing Setting Register
`define I2CM_TSUSTAR     16'h0038
`define  I2CM_TSUSTA            0
// I2C Master Clock High Timing Setting Register
`define I2CM_THIGHR      16'h003C
`define  I2CM_THIGH             0
// I2C Master Data Hold Timing Setting Register
`define I2CM_THDDATR     16'h0040
`define  I2CM_THDDAT            0
// I2C Master Data Setup Timing Setting Register
`define I2CM_TSUDATR     16'h0044
`define  I2CM_TSUDAT            0
// I2C Master Bus Free Timing Setting Register
`define I2CM_TBUFR       16'h0048
`define  I2CM_TBUF              0
// I2C Master Bus Sampling Timing Setting Register
`define I2CM_TBSMPLR     16'h004C
`define  I2CM_SMPLDLY           0
// I2C Master Controller IP Version Register
`define I2CM_VER         16'hF000
`define  I2CM_PATVER            0
`define  I2CM_MINVER           16
`define  I2CM_MAJVER           24
