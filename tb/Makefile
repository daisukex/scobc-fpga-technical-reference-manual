# ---------------------------------------------------------------------------
# Space Cubics OBC Core Simulation Environment
#  Copyright © 2022 Space Cubics, LLC.
# ---------------------------------------------------------------------------

# Simulation Settings
TESTCASE     := sample
WAVE         := on
WAVE_FORMAT  := wdb

# Command variables
VLOG         := xvlog
SVLOG        := xvlog -sv
ELAB         := xelab --timescale 1ps/1ps --debug all -L unisims_ver
SIM          := xsim
WVIEW        := xsim --gui --nolog
MKDIR        := mkdir -p
RM           := rm -rf
CP           := cp

# Path and File variables
#------------------------
# Xilinx Root
XIL_ROOT             := $(dir $(shell which xsim))..
IP_DIR_ROOT          := ../vivado/ip
CORTEX_M3_IP         := cortex_m3
CORTEX_M3_IP_DIR     := $(IP_DIR_ROOT)/$(CORTEX_M3_IP)
AXI_CROSSBAR_IP_DIR  := $(IP_DIR_ROOT)/axi_crossbar
MAIN_AXI_CROSSBAR_IP  = main_axi_crossbar
UDL_AXI_CROSSBAR_IP   = udl_axi_crossbar

# RTL Directory
DUT_ROOT_DIR         := ../rtl
DUT_DIR_LIST         := $(shell find $(DUT_ROOT_DIR) -type d)
MAIN_AXI_CROSSBAR_DIR:= $(AXI_CROSSBAR_IP_DIR)/$(MAIN_AXI_CROSSBAR_IP)/sim $(AXI_CROSSBAR_IP_DIR)/$(MAIN_AXI_CROSSBAR_IP)/hdl
UDL_AXI_CROSSBAR_DIR := $(AXI_CROSSBAR_IP_DIR)/$(UDL_AXI_CROSSBAR_IP)/sim

RTL_DIR_LIST         := $(DUT_DIR_LIST) $(MAIN_AXI_CROSSBAR_DIR) $(UDL_AXI_CROSSBAR_DIR) $(CORTEX_M3_DIR)
RTL_LIST             := $(foreach list, $(RTL_DIR_LIST), $(notdir $(wildcard $(list)/*.v)))
RTL_HEADER_LIST      := $(foreach list, $(RTL_DIR_LIST), $(notdir $(wildcard $(list)/*.vh)))

# Testbench Directory
TB_DIR               := ./bench
TB_DIR_LIST          := $(shell find $(TB_DIR) -type d)
TB_LIST              := $(foreach list, $(TB_DIR_LIST), $(notdir $(wildcard $(list)/*.v)))
AHBVIP_DIR           := ./bench/scvip_ahb_master
TC_DIR               := ./testcase
TC_FILE              := $(TC_DIR)/$(TESTCASE).sv

# Simulation Directory
SDB_DIR              := xsim.dir/work
LOG_DIR              := simlog
WAV_DIR              := wave

CF                   := $(LOG_DIR) $(WAV_DIR) sim_wave.tcl
CF                   += xsim* webtalk* xelab* xvlog* hs_err_* vivado_pid* $(TB_DIR)/glbl.sdb

vpath %.vh  $(RTL_DIR_LIST)
vpath %.v   $(RTL_DIR_LIST)
vpath %.v   $(TB_DIR_LIST)
vpath %.sdb $(SDB_DIR)

# ===========================================================================
# Simulation: sc_obc_core

PHONY = all
all: simulation

PHONY += sim_preparation
sim_preparation:
	$(MKDIR) $(LOG_DIR)
	echo '*' > $(LOG_DIR)/.gitignore
	$(MKDIR) $(SDB_DIR)
	echo '*' > $(SDB_DIR)/.gitignore

generate_ip:
	cd $(AXI_CROSSBAR_IP_DIR) && make generate_target MODULE=$(MAIN_AXI_CROSSBAR_IP)
	cd $(AXI_CROSSBAR_IP_DIR) && make generate_target MODULE=$(UDL_AXI_CROSSBAR_IP)
	cd $(CORTEX_M3_IP_DIR) && make

# Compile Design
PHONY += dut_compile
dut_compile: sim_preparation glbl.sdb $(RTL_LIST:.v=.sdb)

# Compile Testbench
PHONY += tb_compile
tb_compile: sim_preparation $(TB_LIST:.v=.sdb)

# Compile Testcase
PHONY += testcase_compile
testcase_compile: sim_preparation
	$(SVLOG) --log $(LOG_DIR)/$(TESTCASE)_compile.log -i $(AHBVIP_DIR) $(addprefix -i ,$(RTL_DIR_LIST)) $(TC_FILE)

# Elaborate design
PHONY += elaborate
elaborate: dut_compile tb_compile testcase_compile
	$(ELAB) $(XLIB) -s tb_top --log $(LOG_DIR)/$(TESTCASE)_elab.log tb_top glbl

# Run simulation
PHONY += simulation
simulation: elaborate
	$(MKDIR) $(WAV_DIR)
	echo '*' > $(WAV_DIR)/.gitignore
    ifeq ($(WAVE),on)
        ifeq ($(WAVE_FORMAT),vcd)
			echo "open_vcd $(WAV_DIR)/$(TESTCASE).vcd; log_vcd *; run -all; flush_vcd; close_vcd; exit" > sim_wave.tcl
        else
			echo "log_wave -r /; run -all; exit" > sim_wave.tcl
        endif
		$(SIM) --log $(LOG_DIR)/$(TESTCASE).log -wdb $(WAV_DIR)/$(TESTCASE).wdb -t sim_wave.tcl tb_top
    else
		$(SIM) --log $(LOG_DIR)/$(TESTCASE).log -R tb_top
    endif

glbl.v:
	$(CP) $(XIL_ROOT)/data/verilog/src/glbl.v $(TB_DIR)
	$(VLOG) --log $(LOG_DIR)/glbl_compile.log $(TB_DIR)/glbl.v

%.hex: %.elf
	$(MKROM) $< $@

%.sdb: %.v $(RTL_HEADER_LIST)
	$(VLOG) --log $(LOG_DIR)/$(basename $(<F))_compile.log $<

# ===========================================================================
# clean target
PHONY += clean
clean:
	$(RM) $(CF)

.PHONY: $(PHONY)
