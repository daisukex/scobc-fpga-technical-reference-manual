//-----------------------------------------------
// Module: sc_can_reg_map
//  Space Cubics CAN Controller Register Map
//-----------------------------------------------
// Copyright © 2021 Space Cubics, LLC.
//-----------------------------------------------
// CAN Enable Register
`define CAN_ENR          16'h0000
`define  CAN_EN                 0
// CAN Time Quantum Prescaler Register
`define CAN_TQPR         16'h0008
`define  CAN_TQPSET             0
// CAN Bit Timing Setting Register
`define CAN_BTSR         16'h000C
`define  CAN_TS1                0
`define  CAN_TS2                4
`define  CAN_SJW                7
// CAN Error Count Register
`define CAN_ECNTR        16'h0010
`define  CAN_TXECNT             0
`define  CAN_RXECNT             8
// CAN Status Register
`define CAN_STSR         16'h0018
`define  CAN_BBUSY              0
`define  CAN_EWRN               1
`define  CAN_ESTS               2
`define  CAN_TXFNEP             4
`define  CAN_TXHBFL             5
`define  CAN_TXFFL              6
`define  CAN_RXFFL              7
// CAN Interrput Status Register
`define CAN_ISR          16'h0020
`define  CAN_TRNSDN             0
`define  CAN_ARBLST             1
`define  CAN_TXHBOVF            2
`define  CAN_TXFOVF             3
`define  CAN_RCVDN              4
`define  CAN_RXFVAL             5
`define  CAN_RXFUDF             6
`define  CAN_RXFOVF             7
`define  CAN_CRCER              8
`define  CAN_FMER               9
`define  CAN_STFER             10
`define  CAN_BITER             11
`define  CAN_ACKER             12
`define  CAN_BUSOFF            13
// CAN Interrupt Enable Register
`define CAN_IER          16'h0024
`define  CAN_TRNSDNENB          0
`define  CAN_ARBLSTENB          1
`define  CAN_TXHBOVFENB         2
`define  CAN_TXFOVFENB          3
`define  CAN_RCVDNENB           4
`define  CAN_RXFVALENB          5
`define  CAN_RXFUDFENB          6
`define  CAN_RXFOVFENB          7
`define  CAN_CRCERENB           8
`define  CAN_FMERENB            9
`define  CAN_STFERENB          10
`define  CAN_BITERENB          11
`define  CAN_ACKERENB          12
`define  CAN_BUSOFFENB         13
// CAN TX Message Register1
`define CAN_TMR1         16'h0030
`define  CAN_TXERTR             0
`define  CAN_TXID2              1
`define  CAN_TXIDE             19
`define  CAN_TXSRTR            20
`define  CAN_TXID1             21
// CAN TX Message Register2
`define CAN_TMR2         16'h0034
`define  CAN_TXDLC              0
// CAN TX Message Register3
`define CAN_TMR3         16'h0038
`define  CAN_TXDB3              0
`define  CAN_TXDB2              8
`define  CAN_TXDB1             16
`define  CAN_TXDB0             24
// CAN TX Message Register4
`define CAN_TMR4         16'h003C
`define  CAN_TXDB7              0
`define  CAN_TXDB6              8
`define  CAN_TXDB5             16
`define  CAN_TXDB4             24
// CAN TX High Priority Message Register1
`define CAN_THPMR1       16'h0040
`define  CAN_TXHPERTR           0
`define  CAN_TXHPID2            1
`define  CAN_TXHPIDE           19
`define  CAN_TXHPSRTR          20
`define  CAN_TXHPID1           21
// CAN TX High Priority Message Register2
`define CAN_THPMR2       16'h0044
`define  CAN_TXHPDLC            0
// CAN TX High Priority Message Register3
`define CAN_THPMR3       16'h0048
`define  CAN_TXHPDB3            0
`define  CAN_TXHPDB2            8
`define  CAN_TXHPDB1           16
`define  CAN_TXHPDB0           24
// CAN TX High Priority Message Register4
`define CAN_THPMR4       16'h004C
`define  CAN_TXHPDB7            0
`define  CAN_TXHPDB6            8
`define  CAN_TXHPDB5           16
`define  CAN_TXHPDB4           24
// CAN RX Message Register1
`define CAN_RMR1         16'h0050
`define  CAN_RXERTR             0
`define  CAN_RXID2              1
`define  CAN_RXIDE             19
`define  CAN_RXSRTR            20
`define  CAN_RXID1             21
// CAN RX Message Register2
`define CAN_RMR2         16'h0054
`define  CAN_RXDLC              0
// CAN RX Message Register3
`define CAN_RMR3         16'h0058
`define  CAN_RXDB3              0
`define  CAN_RXDB2              8
`define  CAN_RXDB1             16
`define  CAN_RXDB0             24
// CAN RX Message Register4
`define CAN_RMR4         16'h005C
`define  CAN_RXDB7              0
`define  CAN_RXDB6              8
`define  CAN_RXDB5             16
`define  CAN_RXDB4             24
// CAN Acceptance Filter Enable Register
`define CAN_AFER         16'h0060
`define  CAN_UAF1               0
`define  CAN_UAF2               1
`define  CAN_UAF3               2
`define  CAN_UAF4               3
// CAN Acceptance Filter ID Mask Register1
`define CAN_AFIMR1       16'h0070
`define  CAN_ERTRAFM1           0
`define  CAN_ID2AFM1            1
`define  CAN_IDEAFM1           19
`define  CAN_SRTRAFM1          20
`define  CAN_ID1AFM1           21
// CAN Acceptance Filter ID Value Register1
`define CAN_AFIVR1       16'h0074
`define  CAN_ERTRAFV1           0
`define  CAN_ID2AFV1            1
`define  CAN_IDEAFV1           19
`define  CAN_SRTRAFV1          20
`define  CAN_ID1AFV1           21
// CAN Acceptance Filter ID Mask Register2
`define CAN_AFIMR2       16'h0090
`define  CAN_ERTRAFM2           0
`define  CAN_ID2AFM2            1
`define  CAN_IDEAFM2           19
`define  CAN_SRTRAFM2          20
`define  CAN_ID1AFM2           21
// CAN Acceptance Filter ID Value Register2
`define CAN_AFIVR2       16'h0094
`define  CAN_ERTRAFV2           0
`define  CAN_ID2AFV2            1
`define  CAN_IDEAFV2           19
`define  CAN_SRTRAFV2          20
`define  CAN_ID1AFV2           21
// CAN Acceptance Filter ID Mask Register3
`define CAN_AFIMR3       16'h00B0
`define  CAN_ERTRAFM3           0
`define  CAN_ID2AFM3            1
`define  CAN_IDEAFM3           19
`define  CAN_SRTRAFM3          20
`define  CAN_ID1AFM3           21
// CAN Acceptance Filter ID Value Register3
`define CAN_AFIVR3       16'h00B4
`define  CAN_ERTRAFV3           0
`define  CAN_ID2AFV3            1
`define  CAN_IDEAFV3           19
`define  CAN_SRTRAFV3          20
`define  CAN_ID1AFV3           21
// CAN Acceptance Filter ID Mask Register4
`define CAN_AFIMR4       16'h00D0
`define  CAN_ERTRAFM4           0
`define  CAN_ID2AFM4            1
`define  CAN_IDEAFM4           19
`define  CAN_SRTRAFM4          20
`define  CAN_ID1AFM4           21
// CAN Acceptance Filter ID Value Register4
`define CAN_AFIVR4       16'h00D4
`define  CAN_ERTRAFV4           0
`define  CAN_ID2AFV4            1
`define  CAN_IDEAFV4           19
`define  CAN_SRTRAFV4          20
`define  CAN_ID1AFV4           21
// CAN FIFO and Buffer Reset Register
`define CAN_FIFORR       16'h00F0
`define  CAN_RXFIFORST          0
`define  CAN_TXFIFORST         16
`define  CAN_TXHPBRST          17
// CAN Self Test Mode Control Register
`define CAN_STMCR        16'h0100
`define  CAN_STM                0
// CAN PHY Sleep Mode Control Register
`define CAN_PSLMCR       16'h0200
`define  CAN_PSLM               0
// CAN IP Version Register
`define CAN_VER          16'hF000
`define  CAN_PATVER             0
`define  CAN_MINVER            16
`define  CAN_MAJVER            24
