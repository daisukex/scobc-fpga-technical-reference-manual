//-----------------------------------------------
// Module: sc_hrmem_reg_map
//  Space Cubics High Reliability Memory Register Map
//-----------------------------------------------
// Copyright © 2022 Space Cubics, LLC.
//-----------------------------------------------
// ECC Error Collect Enable Register
`define ECCCOLENR        16'h0000
`define  ECCCOLEN               0
// Memory Scrubing Enable Register
`define MEMSCRBENR       16'h0004
`define  MEMSCRBEN              0
// Memory Scrubing Control Register
`define MEMSCRCTRLR      16'h0008
`define  MEMSCRCYC              0
`define  COLFSRDSTPB           16
// ECC 1bit Error Interrupt Register
`define ECC1ERRINTR      16'h0010
`define  E1ERRINT               0
// ECC 2bit Error Interrupt Register
`define ECC2ERRINTR      16'h0014
`define  E2ERRINT               0
// ECC Correct Data Discard Register
`define ECCCDISINTR      16'h0018
`define  ECDISINT               0
// HRMEM Interrupt Enable Register
`define HRMINTENR        16'h001C
`define  E1ERRINTENB            0
`define  E2ERRINTENB            1
`define  ECDISINTENB            2
// ECC Error Count Register
`define ECCERRCNTR       16'h0020
`define  E1ERRCNT               0
`define  E2ERRCNT              16
// ECC Correct Data Discard Count Register
`define ECDISCNTR        16'h0024
`define  ECDISCNT               0
// Error Count Clear Register
`define ERRCNTCLRR       16'h0028
`define  ECNTCLR                0
// AXI ECC 1bit Error Status Register
`define AXIECC1ERRR      16'h0040
`define  AXIE1ERR               0
// AXI ECC 2bit Error Status Register
`define AXIECC2ERRR      16'h0044
`define  AXIE2ERR               0
// ATRD ECC 1bit Error Status Register
`define ATRDECC1ERRR     16'h0048
`define  ATRDE1ERR              0
// ATRD ECC 2bit Error Status Register
`define ATRDECC2ERRR     16'h004C
`define  ATRDE2ERR              0
// AXI ECC Error Count Register
`define AXIECCERRCNTR    16'h0050
`define  AXIE1ERRCNT            0
`define  AXIE2ERRCNT           16
// ATRD ECC Error Count Register
`define ATRDECCERRCNTR   16'h0054
`define  ATRDE1ERRCNT           0
`define  ATRDE2ERRCNT          16
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
