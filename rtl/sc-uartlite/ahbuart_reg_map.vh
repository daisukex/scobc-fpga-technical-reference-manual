//-----------------------------------------------
// Module: ahbuart_reg_map
//  AHB UART Lite Register Map
//-----------------------------------------------
// Copyright © 2020 Space Cubics, LLC.
//-----------------------------------------------
// Rx FIFO Register
`define AHBURXFIFOR      16'h0000
`define  AHBUUARTRXDATA         0
// Tx FIFO Register
`define AHBUTXFIFOR      16'h0004
`define  AHBUUARTTXDATA         0
// Status Register
`define AHBUSTATR        16'h0008
`define  AHBURXFIFOVAL          0
`define  AHBURXFIFOFULL         1
`define  AHBUTXFIFOEMP          2
`define  AHBUTXFIFOFULL         3
`define  AHBUINTENAMON          4
`define  AHBUOVERRUNERR         5
`define  AHBUFRAMEERR           6
`define  AHBUPRTYERR            7
// Control Register
`define AHBUCTRLR        16'h000C
`define  AHBUTXFIFORST          0
`define  AHBURXFIFORST          1
`define  AHBUINTENACTL          4
// UART Baudrate Setting Register
`define AHBUUBRSR        16'h0010
`define  AHBUUDIVSET            0
// IP Version Register
`define AHBUVER          16'hF000
`define  AHBUPATVER             0
`define  AHBUMINVER            16
`define  AHBUMAJVER            24
