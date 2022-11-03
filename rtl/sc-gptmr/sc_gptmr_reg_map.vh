//-----------------------------------------------
// Module: sc_gptmr_reg_map
//  Space Cubics General Purpose Timer Register Map
//-----------------------------------------------
// Copyright © 2022 Space Cubics, LLC.
//-----------------------------------------------
// Output Compare Channel Individual Register Address offset
`define GPTMR_CH_OFFSET  16'h0004

// Global Timer Register
`define GPTMR_GTR        16'h0000
`define  GPTMR_GTINT            4
`define  GPTMR_GTFLOAT          0

// Timer Enable Control Register
`define GPTMR_TECR       16'h0004
`define  GPTMR_HITEN            1
`define  GPTMR_SITEN            0

// Software Interrupt Timer Remaining Register
`define GPTMR_SITRR      16'h0008
`define  GPTMR_SITCNT           0

// Hardware Interrupt Timer Remaining Register
`define GPTMR_HITRR      16'h000C
`define  GPTMR_HITCNT           0

// Global Timer Interrupt Status Register
`define GPTMR_GTSR       16'h0010
`define  GPTMR_GTROVSTS        16
`define  GPTMR_GTOCFSTS         0

// Global Timer Interrupt Enable Register
`define GPTMR_GTER       16'h0014
`define  GPTMR_GTROVENB        16
`define  GPTMR_GTOCFENB         0

// Global Timer Output Compare Register
`define GPTMR_GTOCR      16'h0020
`define  GPTMR_GTCOMP           0

// Software Interrupt Timer Control Register
`define GPTMR_SITCR      16'h0100
`define  GPTMR_SITSWR           4
`define  GPTMR_SITRUNMD         1
`define  GPTMR_SITENBMD         0

// Software Interrupt Timer Prescaler Register
`define GPTMR_SITPR      16'h0104
`define  GPTMR_SITPSC           0

// Software Interrupt Timer Status Register
`define GPTMR_SITSR      16'h0108
`define  GPTMR_SITROVSTS       16
`define  GPTMR_SITOCFSTS        0

// Software Interrupt Timer Enable Register
`define GPTMR_SITER      16'h010C
`define  GPTMR_SITROVENB       16
`define  GPTMR_SITOCFENB        0

// Software Interrupt Timer Output Compare Register
`define GPTMR_SITOCR     16'h0110
`define  GPTMR_SITCOMP          0

// Hardware Interrupt Timer Control Register
`define GPTMR_HITCR      16'h0200
`define  GPTMR_HITOPMD         16
`define  GPTMR_HITSWR           4
`define  GPTMR_HITRUNMD         1
`define  GPTMR_HITENBMD         0

// Hardware Interrupt Timer Prescaler Register
`define GPTMR_HITPR      16'h0204
`define  GPTMR_HITPSC           0

// Hardware Interrupt Timer Output Compare Register
`define GPTMR_HITOCR     16'h0210
`define  GPTMR_HITCOMP          0

// General Purpose Timer IP Version Register
`define GPTMR_VER        16'hF000
`define  GPTMR_MAJVER          24
`define  GPTMR_MINVER          16
`define  GPTMR_PATVER           0
