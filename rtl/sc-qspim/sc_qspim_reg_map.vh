//-----------------------------------------------
// Module: sc_qspim_reg_map
//  Space Cubics Quad-SPI Master Register Map
//-----------------------------------------------
// Copyright © 2020 Space Cubics, LLC.
//-----------------------------------------------
// SPI Access Control Register
`define SPIACR           16'h0000
`define  SPISSCTL               0
`define  SPIIOMODE             16
// SPI TX Data Register
`define SPITDR           16'h0004
`define  SPITXDATA              0
// SPI RX Data Register
`define SPIRDR           16'h0008
`define  SPIRXDATA              0
// SPI Access Status Register
`define SPIASR           16'h000C
`define  SPIBUSY                0
// SPI FIFO Status Register
`define SPIFIFOSR        16'h0010
`define  RXFIFOCAP              0
`define  TXFIFOCAP             16
// SPI FIFO Reset Register
`define SPIFIFORR        16'h0014
`define  RXFIFORST              0
`define  TXFIFORST             16
// SPI Interrput Status Register
`define SPIISR           16'h0020
`define  SPICTRLDN              0
`define  RXFIFOUDF             16
`define  RXFIFOOVF             17
`define  RXFIFOOTH             18
`define  TXFIFOUDF             24
`define  TXFIFOOVF             25
`define  TXFIFOUTH             26
// SPI Interrupt Enable Register
`define SPIIER           16'h0024
`define  SPICTRLDNEMB           0
`define  RXFIFOUDFEMB          16
`define  RXFIFOOVFEMB          17
`define  RXFIFOOTHEMB          18
`define  TXFIFOUDFEMB          24
`define  TXFIFOOVFEMB          25
`define  TXFIFOUTHEMB          26
// SPI Clock Control Register
`define SPICCR           16'h0030
`define  SCKDIV                 0
`define  SCKPHA                16
`define  SCKPOL                20
// SPI Data Capture Mode Setting Register
`define SPIDCMSR         16'h0034
`define  DTCAPT                 0
// SPI FIFO Threshold Level Setting Register
`define SPIFTLSR         16'h0038
`define  RXFIFOOTHL             0
`define  TXFIFOUTHL            16
// IP Version Register
`define QSPIVER          16'hF000
`define  QSPIPATVER             0
`define  QSPIMINVER            16
`define  QSPIMAJVER            24
