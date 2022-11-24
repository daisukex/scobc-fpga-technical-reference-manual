# --------------------------------------------------
# Space Cubics OBC A1 (SC-OBC-A1)
# Floorplan script
#  floorplan.tcl
#  Copyright © 2022 Space Cubics, LLC.
# --------------------------------------------------

# System Controller
create_pblock pb_sysctrl
add_cells_to_pblock pb_sysctrl [get_cells sysctrl/clk_gen/refclk_sel]
add_cells_to_pblock pb_sysctrl [get_cells sysctrl/clk_gen/scobca1_state]
resize_pblock -add {SLICE_X0Y95:SLICE_X41Y99 RAMB36_X0Y19:RAMB36_X1Y19 DSP48_X0Y38:DSP48_X1Y39} pb_sysctrl

# Cortex-M3 place area
create_pblock pb_cm3
add_cells_to_pblock pb_cm3 [get_cells obc_core/cm3_ss]
resize_pblock -add {SLICE_X42Y100:SLICE_X61Y189  RAMB36_X2Y20:RAMB36_X2Y37 DSP48_X2Y40:DSP48_X2Y75 \
                    SLICE_X62Y75:SLICE_X125Y199  RAMB36_X3Y15:RAMB36_X6Y39 DSP48_X3Y30:DSP48_X6Y79} pb_cm3

# HRMEM place area
create_pblock pb_hrmem
add_cells_to_pblock pb_hrmem [get_cells obc_core/hrmem_sram]
resize_pblock -add {SLICE_X0Y150:SLICE_X7Y184 \
                    SLICE_X0Y185:SLICE_X41Y249  RAMB36_X0Y37:RAMB36_X1Y49 DSP48_X0Y74:DSP48_X1Y99 \
                    SLICE_X42Y190:SLICE_X51Y249 RAMB36_X2Y38:RAMB36_X2Y49 DSP48_X2Y76:DSP48_X2Y99 \
                    SLICE_X52Y190:SLICE_X61Y199} pb_hrmem

# QSPI Controller place area
create_pblock pb_flash
add_cells_to_pblock pb_flash [get_cells obc_core/main_axi/qspim_flash_cfg]
add_cells_to_pblock pb_flash [get_cells obc_core/main_axi/qspim_flash_data]
add_cells_to_pblock pb_flash [get_cells obc_core/main_axi/qspim_fram_data]
resize_pblock -add {SLICE_X0Y100:SLICE_X23Y149 RAMB36_X0Y20:RAMB36_X1Y29 DSP48_X0Y40:DSP48_X1Y59} pb_flash

# CAN place area
create_pblock pb_can
add_cells_to_pblock pb_can [get_cells obc_core/main_axi/can]
resize_pblock -add {SLICE_X0Y30:SLICE_X41Y94 RAMB36_X0Y6:RAMB36_X1Y18 DSP48_X0Y12:DSP48_X1Y37} pb_can

# Low Performance bus place area
create_pblock pb_lpahb
add_cells_to_pblock pb_lpahb [get_cells obc_core/lpahb]
remove_cells_from_pblock pb_lpahb [get_cells obc_core/lpahb/system_monitor]
resize_pblock -add {SLICE_X0Y0:SLICE_X51Y29 RAMB36_X0Y0:RAMB36_X2Y5 DSP48_X0Y0:DSP48_X2Y11} pb_lpahb

# SEM Controller
create_pblock pb_sem
add_cells_to_pblock pb_sem [get_cells obc_core/lpahb/system_monitor/sem_controller]
resize_pblock -add {SLICE_X8Y150:SLICE_X23Y184 RAMB36_X0Y30:RAMB36_X1Y36 DSP48_X0Y60:DSP48_X1Y73} pb_sem

# UDL
create_pblock pb_udl
add_cells_to_pblock pb_udl [get_cells udl_axi]
resize_pblock -add {SLICE_X126Y100:SLICE_X163Y149 RAMB36_X7Y20:RAMB36_X8Y29 DSP48_X7Y40:DSP48_X8Y59 \
                    SLICE_X126Y150:SLICE_X163Y199 RAMB36_X7Y30:RAMB36_X8Y39 DSP48_X7Y60:DSP48_X8Y79\
                    SLICE_X114Y200:SLICE_X163Y249 RAMB36_X7Y40:RAMB36_X8Y49 DSP48_X7Y80:DSP48_X8Y99} pb_udl
