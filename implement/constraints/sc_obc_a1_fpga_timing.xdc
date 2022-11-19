# --------------------------------------------------
# Space Cubics OBC A1 (SC-OBC-A1)
# FPGA Timing file (.xdc)
#  sc_obc_a1_fpga_timing.tcl
#  Copyright © 2022 Space Cubics, LLC.
# --------------------------------------------------

set sysclk_period 41.666
set tclk_period   66.6
set board_delay_min  0
set board_delay_max  0.5

create_clock -name refclk1 -period $sysclk_period [get_ports SYSCLK1]
create_clock -name refclk2 -period $sysclk_period [get_ports SYSCLK2]
create_clock -name tclk    -period $tclk_period   [get_ports CM3_TCK_SWCLK]

create_generated_clock -name refclk -source [get_pins sysctrl/clk_gen/refclk_sel/refclkmux/I0] \
                       -divide_by 1 -multiply_by 1 \
                       -add -master_clock [get_clocks refclk1] \
                       [get_pins sysctrl/clk_gen/refclk_sel/refclkmux/O]
create_generated_clock -name pllclk96m -source [get_pins sysctrl/clk_gen/scobca1_pll/pll2_adv/CLKIN1] \
                       -divide_by 10 -multiply_by 40 \
                       -add -master_clock [get_clocks refclk1] \
                       [get_pins sysctrl/clk_gen/scobca1_pll/pll2_adv/CLKOUT0]
create_generated_clock -name pllclk48m -source [get_pins sysctrl/clk_gen/scobca1_pll/pll2_adv/CLKIN1] \
                       -divide_by 20 -multiply_by 40 \
                       -add -master_clock [get_clocks refclk1] \
                       [get_pins sysctrl/clk_gen/scobca1_pll/pll2_adv/CLKOUT1]
create_generated_clock -name ulpi_refclk -source [get_pins sysctrl/clk_gen/scobca1_pll/pll2_adv/CLKIN1] \
                       -divide_by 50 -multiply_by 40 \
                       -add -master_clock [get_clocks refclk1] \
                       [get_pins sysctrl/clk_gen/scobca1_pll/pll2_adv/CLKOUT2]
create_generated_clock -name user_clk1 -source [get_pins sysctrl/clk_gen/scobca1_pll/pll2_adv/CLKIN1] \
                       -divide_by 100 -multiply_by 40 \
                       -add -master_clock [get_clocks refclk1] \
                       [get_pins sysctrl/clk_gen/scobca1_pll/pll2_adv/CLKOUT4]
create_generated_clock -name user_clk2 -source [get_pins sysctrl/clk_gen/scobca1_pll/pll2_adv/CLKIN1] \
                       -divide_by 100 -multiply_by 40 \
                       -add -master_clock [get_clocks refclk1] \
                       [get_pins sysctrl/clk_gen/scobca1_pll/pll2_adv/CLKOUT5]

# SRAM Interface test clock
create_generated_clock -name sram1_we_b -divide_by 2 -invert \
                       -master_clock [get_clocks pllclk48m] -source [get_pins sysctrl/clk_gen/scobca1_pll/pll2_adv/CLKOUT1] \
                       -add [get_ports SRAM1_WE_B]
set_multicycle_path 1 -setup -start -from [get_clocks pllclk48m] -to [get_clocks sram1_we_b]
set_multicycle_path 2 -hold  -start -from [get_clocks pllclk48m] -to [get_clocks sram1_we_b]

create_generated_clock -name sram2_we_b -divide_by 2 -invert \
                       -master_clock [get_clocks pllclk48m] -source [get_pins sysctrl/clk_gen/scobca1_pll/pll2_adv/CLKOUT1] \
                       -add [get_ports SRAM2_WE_B]
set_multicycle_path 1 -setup -start -from [get_clocks pllclk48m] -to [get_clocks sram2_we_b]
set_multicycle_path 2 -hold  -start -from [get_clocks pllclk48m] -to [get_clocks sram2_we_b]

create_generated_clock -name sram1_oe_b -divide_by 2 -invert \
                       -master_clock [get_clocks pllclk48m] -source [get_pins sysctrl/clk_gen/scobca1_pll/pll2_adv/CLKOUT1] \
                       -add [get_ports SRAM1_OE_B]
set_multicycle_path 1 -setup -start -from [get_clocks pllclk48m] -to [get_clocks sram1_oe_b]
set_multicycle_path 2 -hold  -start -from [get_clocks pllclk48m] -to [get_clocks sram1_oe_b]
set_multicycle_path 2 -hold  -end   -from [get_clocks sram1_oe_b] -to [get_clocks pllclk48m]

create_generated_clock -name sram2_oe_b -divide_by 2 -invert \
                       -master_clock [get_clocks pllclk48m] -source [get_pins sysctrl/clk_gen/scobca1_pll/pll2_adv/CLKOUT1] \
                       -add [get_ports SRAM2_OE_B]
set_multicycle_path 1 -setup -start -from [get_clocks pllclk48m] -to [get_clocks sram2_oe_b]
set_multicycle_path 2 -hold  -start -from [get_clocks pllclk48m] -to [get_clocks sram2_oe_b]
set_multicycle_path 2 -hold  -end   -from [get_clocks sram2_oe_b] -to [get_clocks pllclk48m]

# QSPI Flash (for Configuration Memory) test clock
create_generated_clock -name cclk -divide_by 2 -invert \
                       -master_clock [get_clocks pllclk48m] -source [get_pins sysctrl/clk_gen/scobca1_pll/pll2_adv/CLKOUT1] \
                       -add [get_pins startupe2/USRCCLKO]
set_clock_latency -min  0.5 [get_clocks cclk]
set_clock_latency -max  6.7 [get_clocks cclk]
set_multicycle_path 1 -setup -start -from [get_clocks pllclk48m] -to [get_clocks cclk]
set_multicycle_path 1 -hold  -start -from [get_clocks pllclk48m] -to [get_clocks cclk]
set_multicycle_path 1 -hold  -end   -from [get_clocks cclk] -to [get_clocks pllclk48m]

# QSPI Flash (for Data Store Memory) test clock
create_generated_clock -name data_mem1_sck -divide_by 2 -invert \
                       -master_clock pllclk48m -source [get_pins sysctrl/clk_gen/scobca1_pll/pll2_adv/CLKOUT1] \
                       -add [get_ports DATA_MEM1_SCK]
set_multicycle_path 1 -setup -start -from [get_clocks pllclk48m] -to [get_clocks data_mem1_sck]
set_multicycle_path 1 -hold  -start -from [get_clocks pllclk48m] -to [get_clocks data_mem1_sck]
set_multicycle_path 1 -hold  -end   -from [get_clocks data_mem1_sck] -to [get_clocks pllclk48m]

create_generated_clock -name data_mem2_sck -divide_by 2 -invert \
                       -master_clock pllclk48m -source [get_pins sysctrl/clk_gen/scobca1_pll/pll2_adv/CLKOUT1] \
                       -add [get_ports DATA_MEM2_SCK]
set_multicycle_path 1 -setup -start -from [get_clocks pllclk48m] -to [get_clocks data_mem2_sck]
set_multicycle_path 1 -hold  -start -from [get_clocks pllclk48m] -to [get_clocks data_mem2_sck]
set_multicycle_path 1 -hold  -end   -from [get_clocks data_mem2_sck] -to [get_clocks pllclk48m]

# FRAM test clock
create_generated_clock -name fram1_sck -divide_by 2 -invert \
                       -master_clock pllclk48m -source [get_pins sysctrl/clk_gen/scobca1_pll/pll2_adv/CLKOUT1] \
                       -add [get_ports FRAM1_SCK]
set_multicycle_path 1 -setup -start -from [get_clocks pllclk48m] -to [get_clocks fram1_sck]
set_multicycle_path 1 -hold  -start -from [get_clocks pllclk48m] -to [get_clocks fram1_sck]
set_multicycle_path 1 -hold  -end   -from [get_clocks fram1_sck] -to [get_clocks pllclk48m]

create_generated_clock -name fram2_sck -divide_by 2 -invert \
                       -master_clock pllclk48m -source [get_pins sysctrl/clk_gen/scobca1_pll/pll2_adv/CLKOUT1] \
                       -add [get_ports FRAM2_SCK]
set_multicycle_path 1 -setup -start -from [get_clocks pllclk48m] -to [get_clocks fram2_sck]
set_multicycle_path 1 -hold  -start -from [get_clocks pllclk48m] -to [get_clocks fram2_sck]
set_multicycle_path 1 -hold  -end   -from [get_clocks fram2_sck] -to [get_clocks pllclk48m]

set_case_analysis 1 [get_pins  sysctrl/clk_gen/scobca1_pll/pll2_adv/CLKINSEL]
set_case_analysis 1 [get_pins sysctrl/clk_gen/scobca1_outsel/clkmux96m/S0]
set_case_analysis 0 [get_pins sysctrl/clk_gen/scobca1_outsel/clkmux96m/S1]
set_case_analysis 0 [get_pins sysctrl/clk_gen/scobca1_outsel/clkmux48m/S0]
set_case_analysis 1 [get_pins sysctrl/clk_gen/scobca1_outsel/clkmux48m/S1]

set_clock_groups \
    -asynchronous \
    -group [get_clocks refclk1] \
    -group [get_clocks refclk2] \
    -group [get_clocks refclk] \
    -group [get_clocks pllclk48m] \
    -group [get_clocks tclk] \
    -group [get_clocks user_clk1] \
    -group [get_clocks user_clk2] \
    -group [get_clocks ulpi_refclk]

# TRCH Interface
set_false_path -from [get_ports FPGA_BOOT0] -to [get_clocks pllclk48m]
set_false_path -from [get_ports FPGA_BOOT1] -to [get_clocks pllclk48m]
set_false_path -from [get_clocks pllclk48m] -to [get_ports FPGA_WATCHDOG]
set_false_path -from [get_clocks pllclk48m] -to [get_ports FPGA_PWR_CYCLE_REQ]

# SRAM Interface
set sram_sig_delay_max 20
set sram_delay_max     10
set sram_delay_min      3
set sram_out_max        6
set sram_out_min        1
set sram_addr_setup     7
set sram_addr_hold      0
set sram_data_setup     5
set sram_data_hold      0
set sram_en_setup       7
set sram_en_hold        0
set sram_be_setup       7
set sram_be_hold        0
set sram_oe_setup       0
set sram_oe_hold        5

## SRAM Write
set_max_delay -from [get_clocks pllclk48m] -to [get_ports SRAM1_WE_B] ${sram_sig_delay_max}
set_output_delay -clock [get_clocks sram1_we_b] -max ${sram_addr_setup}         [get_ports {SRAM_A[*]}]
set_output_delay -clock [get_clocks sram1_we_b] -min [expr - ${sram_addr_hold}] [get_ports {SRAM_A[*]}]
set_output_delay -clock [get_clocks sram2_we_b] -max ${sram_addr_setup}         [get_ports {SRAM_A[*]}]
set_output_delay -clock [get_clocks sram2_we_b] -min [expr - ${sram_addr_hold}] [get_ports {SRAM_A[*]}]
set_output_delay -clock [get_clocks sram1_we_b] -max ${sram_be_setup}           [get_ports {SRAM1_CE_B}]
set_output_delay -clock [get_clocks sram1_we_b] -min [expr - ${sram_be_hold}]   [get_ports {SRAM1_CE_B}]
set_output_delay -clock [get_clocks sram2_we_b] -max ${sram_be_setup}           [get_ports {SRAM2_CE_B}]
set_output_delay -clock [get_clocks sram2_we_b] -min [expr - ${sram_be_hold}]   [get_ports {SRAM2_CE_B}]
set_output_delay -clock [get_clocks sram1_we_b] -max ${sram_be_setup}           [get_ports {SRAM1_B*E_B}]
set_output_delay -clock [get_clocks sram1_we_b] -min [expr - ${sram_be_hold}]   [get_ports {SRAM1_B*E_B}]
set_output_delay -clock [get_clocks sram2_we_b] -max ${sram_be_setup}           [get_ports {SRAM2_B*E_B}]
set_output_delay -clock [get_clocks sram2_we_b] -min [expr - ${sram_be_hold}]   [get_ports {SRAM2_B*E_B}]
set_output_delay -clock [get_clocks sram1_we_b] -max ${sram_data_setup}         [get_ports {SRAM1_IO[*]}]
set_output_delay -clock [get_clocks sram1_we_b] -min [expr - ${sram_data_hold}] [get_ports {SRAM1_IO[*]}]
set_output_delay -clock [get_clocks sram2_we_b] -max ${sram_data_setup}         [get_ports {SRAM2_IO[*]}]
set_output_delay -clock [get_clocks sram2_we_b] -min [expr - ${sram_data_hold}] [get_ports {SRAM2_IO[*]}]

## SRAM Read
set_max_delay -from [get_clocks pllclk48m] -to [get_ports SRAM1_OE_B] ${sram_sig_delay_max}
set_output_delay -clock [get_clocks sram1_oe_b] -max ${sram_oe_setup}           [get_ports {SRAM_A[*]}]
set_output_delay -clock [get_clocks sram1_oe_b] -min [expr - ${sram_oe_hold}]   [get_ports {SRAM_A[*]}]
set_output_delay -clock [get_clocks sram2_oe_b] -max ${sram_oe_setup}           [get_ports {SRAM_A[*]}]
set_output_delay -clock [get_clocks sram2_oe_b] -min [expr - ${sram_oe_hold}]   [get_ports {SRAM_A[*]}]
set_output_delay -clock [get_clocks sram1_oe_b] -max ${sram_oe_setup}           [get_ports {SRAM1_CE_B}]
set_output_delay -clock [get_clocks sram1_oe_b] -min [expr - ${sram_oe_hold}]   [get_ports {SRAM1_CE_B}]
set_output_delay -clock [get_clocks sram2_oe_b] -max ${sram_oe_setup}           [get_ports {SRAM2_CE_B}]
set_output_delay -clock [get_clocks sram2_oe_b] -min [expr - ${sram_oe_hold}]   [get_ports {SRAM2_CE_B}]
set_output_delay -clock [get_clocks sram1_oe_b] -max ${sram_oe_setup}           [get_ports {SRAM1_B*E_B}]
set_output_delay -clock [get_clocks sram1_oe_b] -min [expr - ${sram_oe_hold}]   [get_ports {SRAM1_B*E_B}]
set_output_delay -clock [get_clocks sram2_oe_b] -max ${sram_oe_setup}           [get_ports {SRAM2_B*E_B}]
set_output_delay -clock [get_clocks sram2_oe_b] -min [expr - ${sram_oe_hold}]   [get_ports {SRAM2_B*E_B}]
set_input_delay  -clock [get_clocks sram1_oe_b] -clock_fall -max [expr ${board_delay_max} * 2 + ${sram_delay_max}] [get_ports {SRAM1_IO[*]}]
set_input_delay  -clock [get_clocks sram1_oe_b] -clock_fall -min [expr ${board_delay_min} * 2 + ${sram_delay_min}] [get_ports {SRAM1_IO[*]}]
set_input_delay  -clock [get_clocks sram1_oe_b] -clock_fall -max [expr ${board_delay_max} * 2 + ${sram_delay_max}] [get_ports SRAM1_ERR]
set_input_delay  -clock [get_clocks sram1_oe_b] -clock_fall -min [expr ${board_delay_min} * 2 + ${sram_delay_min}] [get_ports SRAM1_ERR]
set_input_delay  -clock [get_clocks sram2_oe_b] -clock_fall -max [expr ${board_delay_max} * 2 + ${sram_delay_max}] [get_ports {SRAM2_IO[*]}]
set_input_delay  -clock [get_clocks sram2_oe_b] -clock_fall -min [expr ${board_delay_min} * 2 + ${sram_delay_min}] [get_ports {SRAM2_IO[*]}]
set_input_delay  -clock [get_clocks sram2_oe_b] -clock_fall -max [expr ${board_delay_max} * 2 + ${sram_delay_max}] [get_ports SRAM2_ERR]
set_input_delay  -clock [get_clocks sram2_oe_b] -clock_fall -min [expr ${board_delay_min} * 2 + ${sram_delay_min}] [get_ports SRAM2_ERR]

# QSPI Flash (for Data Store Memory) Interface
set nor_flash_setup      2
set nor_flash_hold       3
set nor_flash_delay_max  7
set nor_flash_delay_min  0

## Configuration Memory
set_false_path   -from [get_clocks pllclk48m]  -to [get_ports CFG_MEM_SEL]
set_false_path   -from [get_ports CFG_MEM_MON] -to [get_clocks pllclk48m]
set_output_delay -clock [get_clocks cclk]  -max ${nor_flash_setup}         [get_ports CFG_MEM_CS_B]
set_output_delay -clock [get_clocks cclk]  -min [expr - ${nor_flash_hold}] [get_ports CFG_MEM_CS_B]
set_output_delay -clock [get_clocks cclk]  -max ${nor_flash_setup}         [get_ports {CFG_MEM_IO[*]}]
set_output_delay -clock [get_clocks cclk]  -min [expr - ${nor_flash_hold}] [get_ports {CFG_MEM_IO[*]}]
set_input_delay  -clock [get_clocks cclk]  -clock_fall -max [expr ${board_delay_max} * 2 + ${nor_flash_delay_max}] [get_ports {CFG_MEM_IO[*]}]
set_input_delay  -clock [get_clocks cclk]  -clock_fall -min [expr ${board_delay_min} * 2 + ${nor_flash_delay_min}] [get_ports {CFG_MEM_IO[*]}]

## Data Store Memory 1
set_output_delay -clock [get_clocks data_mem1_sck] -max ${nor_flash_setup}         [get_ports DATA_MEM1_CS_B]
set_output_delay -clock [get_clocks data_mem1_sck] -min [expr - ${nor_flash_hold}] [get_ports DATA_MEM1_CS_B]
set_output_delay -clock [get_clocks data_mem1_sck] -max ${nor_flash_setup}         [get_ports {DATA_MEM1_IO[*]}]
set_output_delay -clock [get_clocks data_mem1_sck] -min [expr - ${nor_flash_hold}] [get_ports {DATA_MEM1_IO[*]}]
set_input_delay  -clock [get_clocks data_mem1_sck] -clock_fall -max [expr ${board_delay_max} * 2 + ${nor_flash_delay_max}] [get_ports {DATA_MEM1_IO[*]}]
set_input_delay  -clock [get_clocks data_mem1_sck] -clock_fall -min [expr ${board_delay_min} * 2 + ${nor_flash_delay_min}] [get_ports {DATA_MEM1_IO[*]}]

## Data Store Memory 2
set_output_delay -clock [get_clocks data_mem2_sck] -max ${nor_flash_setup}         [get_ports DATA_MEM2_CS_B]
set_output_delay -clock [get_clocks data_mem2_sck] -min [expr - ${nor_flash_hold}] [get_ports DATA_MEM2_CS_B]
set_output_delay -clock [get_clocks data_mem2_sck] -max ${nor_flash_setup}         [get_ports {DATA_MEM2_IO[*]}]
set_output_delay -clock [get_clocks data_mem2_sck] -min [expr - ${nor_flash_hold}] [get_ports {DATA_MEM2_IO[*]}]
set_input_delay  -clock [get_clocks data_mem2_sck] -clock_fall -max [expr ${board_delay_max} * 2 + ${nor_flash_delay_max}] [get_ports {DATA_MEM2_IO[*]}]
set_input_delay  -clock [get_clocks data_mem2_sck] -clock_fall -min [expr ${board_delay_min} * 2 + ${nor_flash_delay_min}] [get_ports {DATA_MEM2_IO[*]}]

# FRAM Interface
set fram_setup      2
set fram_hold       3
set fram_delay_max  7
set fram_delay_min  0

## FRAM 1
set_output_delay -clock [get_clocks fram1_sck] -max ${fram_setup}         [get_ports FRAM1_CS_B]
set_output_delay -clock [get_clocks fram1_sck] -min [expr - ${fram_hold}] [get_ports FRAM1_CS_B]
set_output_delay -clock [get_clocks fram1_sck] -max ${fram_setup}         [get_ports {FRAM1_IO[*]}]
set_output_delay -clock [get_clocks fram1_sck] -min [expr - ${fram_hold}] [get_ports {FRAM1_IO[*]}]
set_input_delay  -clock [get_clocks fram1_sck] -clock_fall -max [expr ${board_delay_max} * 2 + ${fram_delay_max}] [get_ports {FRAM1_IO[*]}]
set_input_delay  -clock [get_clocks fram1_sck] -clock_fall -min [expr ${board_delay_min} * 2 + ${fram_delay_min}] [get_ports {FRAM1_IO[*]}]

## FRAM 2
set_output_delay -clock [get_clocks fram2_sck] -max ${fram_setup}         [get_ports FRAM2_CS_B]
set_output_delay -clock [get_clocks fram2_sck] -min [expr - ${fram_hold}] [get_ports FRAM2_CS_B]
set_output_delay -clock [get_clocks fram2_sck] -max ${fram_setup}         [get_ports {FRAM2_IO[*]}]
set_output_delay -clock [get_clocks fram2_sck] -min [expr - ${fram_hold}] [get_ports {FRAM2_IO[*]}]
set_input_delay  -clock [get_clocks fram2_sck] -clock_fall -max [expr ${board_delay_max} * 2 + ${fram_delay_max}] [get_ports {FRAM2_IO[*]}]
set_input_delay  -clock [get_clocks fram2_sck] -clock_fall -min [expr ${board_delay_min} * 2 + ${fram_delay_min}] [get_ports {FRAM2_IO[*]}]

# CAN Interface
set can_delay_max [expr ${sysclk_period} / 2]
set_output_delay -clock [get_clocks refclk] -max [expr ${sysclk_period} - ${can_delay_max}] [get_ports FPGA_CAN_TX]
set_output_delay -clock [get_clocks refclk] -max [expr ${sysclk_period} - ${can_delay_max}] [get_ports FPGA_CAN_SLEEP_EN]
set_input_delay  -clock [get_clocks refclk] -max [expr ${sysclk_period} - ${can_delay_max}] [get_ports FPGA_CAN_RX]

# Test Interface
set swjdp_delay   5
set swjdp_setup  10
set swjdp_hold   10
set_input_delay  -clock [get_clocks tclk] -clock_fall -max ${swjdp_delay}                              [get_ports CM3_TMS_SWDIO]
set_input_delay  -clock [get_clocks tclk] -clock_fall -min [expr - ${swjdp_delay}]                     [get_ports CM3_TMS_SWDIO]
set_output_delay -clock [get_clocks tclk]             -max [expr ${swjdp_setup} + ${board_delay_max}]  [get_ports CM3_TMS_SWDIO]
set_output_delay -clock [get_clocks tclk]             -min [expr - ${swjdp_hold} + ${board_delay_min}] [get_ports CM3_TMS_SWDIO]
set_input_delay  -clock [get_clocks tclk] -clock_fall -max ${swjdp_delay}                              [get_ports CM3_TDI]
set_input_delay  -clock [get_clocks tclk] -clock_fall -min [expr - ${swjdp_delay}]                     [get_ports CM3_TDI]
set_input_delay  -clock [get_clocks tclk] -clock_fall -max ${swjdp_delay}                              [get_ports CM3_NTRST]
set_input_delay  -clock [get_clocks tclk] -clock_fall -min [expr - ${swjdp_delay}]                     [get_ports CM3_NTRST]
set_output_delay -clock [get_clocks tclk]             -max [expr ${swjdp_setup} + ${board_delay_max}]  [get_ports CM3_TDO_SWO]
set_output_delay -clock [get_clocks tclk]             -min [expr - ${swjdp_hold} + ${board_delay_min}] [get_ports CM3_TDO_SWO]

set_max_delay -from [get_clocks pllclk48m] -to [get_clocks tclk]      [expr (${sysclk_period} / 40 * 20 * 2) -2]
set_max_delay -from [get_clocks tclk]      -to [get_clocks pllclk48m] [expr (${sysclk_period} / 40 * 20 * 2) -2]
