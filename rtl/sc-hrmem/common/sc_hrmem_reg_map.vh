//-----------------------------------------------
// Module: sc_hrmem_reg_map
//  Space Cubics High Reliability Memory Register Map
//-----------------------------------------------
// Copyright © 2022 Space Cubics, LLC.
//-----------------------------------------------
// ECC Error Collect Enable Register
`define ECCCOLENR        16'h0000
`define  ECCCOLEN               0
// Memory Scrubing Control Register
`define MEMSCRCTRLR      16'h0008
`define  MEMSCRBEN              0
`define  COLFSRDSTPB            8
`define  MEMSCRCYC             16
// HRMEM Interrupt Status Register
`define HRMINTSTR        16'h0010
`define  E1ERRINT               0
`define  E2ERRINT               1
`define  ECDISINT               8
`define  AXIE1ERR              16
`define  ATRDE1ERR             17
`define  AXIE2ERR              20
`define  ATRDE2ERR             21
// HRMEM Interrupt Enable Register
`define HRMINTENR        16'h0014
`define  E1ERRINTENB            0
`define  E2ERRINTENB            1
`define  ECDISINTENB            8
// 1Bit ECC Error Count Register
`define ECC1ERRCNTR      16'h0020
`define  AXIE1ERRCNT            0
`define  ATRDE1ERRCNT          16
// 2Bit ECC Error Count Register
`define ECC2ERRCNTR      16'h0024
`define  AXIE2ERRCNT            0
`define  ATRDE2ERRCNT          16
// ECC Correct Data Discard Count Register
`define ECDISCNTR        16'h0028
`define  ECDISCNT               0
// Error Count Clear Register
`define ERRCNTCLRR       16'h002C
`define  ECNTCLR                0
// ECC Error Address Monitor Register
`define ECCERRADMR       16'h0030
`define  ECCERRADR              0
// ECC Error Occurrence factor Insert Register
`define ECCERRINSR       16'h0060
`define  E1ERRINS               0
`define  E2ERRINS               1
// Prefetch Mode Control Register
`define PFEMDCTLR        16'h0070
`define  PFMDCTL                0
// Special Prefetch Enable Register
`define SPEPFENR         16'h0074
`define  SPPFENB                0
// Prefetch Buffer Flush Register
`define PFBUFFLUSHR      16'h007C
`define  PFBFLUSH               0
// Special Prefetch Address Setting Register
`define SPEPFADRSETR     16'h0080
`define  SPPFADR                0
// IP Version Register
`define HRMEMVER         16'hF000
`define  HRMEMPATVER            0
`define  HRMEMMINVER           16
`define  HRMEMMAJVER           24
