# --------------------------------------------------
# Space Cubics OBC A1 (SC-OBC-A1)
#  Report Static Timing Analysis
#  report_sta.tcl
#  Copyright © 2022 Space Cubics, LLC.
# --------------------------------------------------

proc report_timing_all_clock { dir } {
    # System Clock
    report_timing \
        -from [get_clocks pllclk48m] -to [get_clocks pllclk48m] \
        -path_type full -max_paths 100 \
        -file ${dir}/report_timing_sysclk.log

    # Reference Clock
    report_timing \
        -from [get_clocks refclk1] -to [get_clocks refclk1] \
        -path_type full -max_paths 100 \
        -file ${dir}/report_timing_refclk.log

    report_timing \
        -from [get_clocks refclk2] -to [get_clocks refclk2] \
        -path_type full -max_paths 100 \
        -append -file ${dir}/report_timing_refclk.log

    report_timing \
        -from [get_clocks refclk] -to [get_clocks refclk] \
        -path_type full -max_paths 100 \
        -append -file ${dir}/report_timing_refclk.log

    # ULPI Reference Clock
    report_timing \
        -from [get_clocks ulpi_refclk] -to [get_clocks ulpi_refclk] \
        -path_type full -max_paths 100 \
        -file ${dir}/report_timing_ulpi_refclk.log

    # User Clock 1
    report_timing \
        -from [get_clocks user_clk1] -to [get_clocks user_clk1] \
        -path_type full -max_paths 100 \
        -file ${dir}/report_timing_user_clk1.log

    # User Clock 2
    report_timing \
        -from [get_clocks user_clk2] -to [get_clocks user_clk2] \
        -path_type full -max_paths 100 \
        -file ${dir}/report_timing_user_clk2.log

    # Test CLK
    report_timing \
        -from [get_clocks tclk] -to [get_clocks tclk] \
        -path_type full -max_paths 100 \
        -file ${dir}/report_timing_tclk.log

    # SRAM Interface
    report_timing \
        -from [get_clocks sram1_oe_b] -to [get_clocks pllclk48m] \
        -path_type full -max_paths 20 \
        -file ${dir}/report_timing_sram.log

    report_timing \
        -from [get_clocks pllclk48m] -to [get_clocks sram1_oe_b] \
        -path_type full -max_paths 20 \
        -append -file ${dir}/report_timing_sram.log

    report_timing \
        -from [get_clocks sram2_oe_b] -to [get_clocks pllclk48m] \
        -path_type full -max_paths 20 \
        -append -file ${dir}/report_timing_sram.log

    report_timing \
        -from [get_clocks pllclk48m] -to [get_clocks sram2_oe_b] \
        -path_type full -max_paths 20 \
        -append -file ${dir}/report_timing_sram.log

    report_timing \
        -from [get_clocks pllclk48m] -to [get_clocks sram1_we_b] \
        -path_type full -max_paths 20 \
        -append -file ${dir}/report_timing_sram.log

    report_timing \
        -from [get_clocks pllclk48m] -to [get_clocks sram2_we_b] \
        -path_type full -max_paths 20 \
        -append -file ${dir}/report_timing_sram.log

    # QSPI Flash (for Configuration)
    report_timing \
        -from [get_clocks cclk] -to [get_clocks pllclk48m] \
        -path_type full -max_paths 20 \
        -file ${dir}/report_timing_config_flash.log

    report_timing \
        -from [get_clocks pllclk48m] -to [get_clocks cclk] \
        -path_type full -max_paths 20 \
        -append -file ${dir}/report_timing_config_flash.log

    # QSPI Flash (for Data Store)
    report_timing \
        -from [get_clocks data_mem1_sck] -to [get_clocks pllclk48m] \
        -path_type full -max_paths 20 \
        -file ${dir}/report_timing_config_flash.log

    report_timing \
        -from [get_clocks pllclk48m] -to [get_clocks data_mem1_sck] \
        -path_type full -max_paths 20 \
        -append -file ${dir}/report_timing_data_flash.log

    report_timing \
        -from [get_clocks data_mem2_sck] -to [get_clocks pllclk48m] \
        -path_type full -max_paths 20 \
        -append -file ${dir}/report_timing_config_flash.log

    report_timing \
        -from [get_clocks pllclk48m] -to [get_clocks data_mem2_sck] \
        -path_type full -max_paths 20 \
        -append -file ${dir}/report_timing_data_flash.log

    # FRAM
    report_timing \
        -from [get_clocks fram1_sck] -to [get_clocks pllclk48m] \
        -path_type full -max_paths 20 \
        -file ${dir}/report_timing_fram.log

    report_timing \
        -from [get_clocks pllclk48m] -to [get_clocks fram1_sck] \
        -path_type full -max_paths 20 \
        -append -file ${dir}/report_timing_fram.log

    report_timing \
        -from [get_clocks fram2_sck] -to [get_clocks pllclk48m] \
        -path_type full -max_paths 20 \
        -append -file ${dir}/report_timing_fram.log

    report_timing \
        -from [get_clocks pllclk48m] -to [get_clocks fram2_sck] \
        -path_type full -max_paths 20 \
        -append -file ${dir}/report_timing_fram.log

    # FRAM
    report_timing \
        -from [get_clocks data_mem1_sck] -to [get_clocks pllclk48m] \
        -path_type full -max_paths 20 \
        -file ${dir}/report_timing_config_flash.log

    report_timing \
        -from [get_clocks pllclk48m] -to [get_clocks data_mem1_sck] \
        -path_type full -max_paths 20 \
        -append -file ${dir}/report_timing_data_flash.log
}
