# --------------------------------------------------
# Space Cubics OBC A1 (SC-OBC-A1)
# FPGA Timing file (.xdc)
#  sc_obc_a1_fpga_timing.tcl
#  Copyright © 2022 Space Cubics, LLC.
# --------------------------------------------------

set sysclk_period 41.666
set tclk_period   63.0

create_clock -name refclk1 -period $sysclk_period [get_ports SYSCLK1]
create_clock -name refclk2 -period $sysclk_period [get_ports SYSCLK2]
create_clock -name tclk    -period $tclk_period   [get_ports CM3_TCK_SWCLK]

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

set_case_analysis 1 [get_pins  sysctrl/clk_gen/scobca1_pll/pll2_adv/CLKINSEL]
set_case_analysis 1 [get_pins sysctrl/clk_gen/scobca1_outsel/clkmux96m/S0]
set_case_analysis 0 [get_pins sysctrl/clk_gen/scobca1_outsel/clkmux96m/S1]
set_case_analysis 0 [get_pins sysctrl/clk_gen/scobca1_outsel/clkmux48m/S0]
set_case_analysis 1 [get_pins sysctrl/clk_gen/scobca1_outsel/clkmux48m/S1]

set_clock_groups \
    -asynchronous \
    -group [get_clocks refclk1] \
    -group [get_clocks refclk2] \
    -group [get_clocks pllclk48m] \
    -group [get_clocks tclk] \
    -group [get_clocks user_clk1] \
    -group [get_clocks user_clk2] \
    -group [get_clocks ulpi_refclk]
