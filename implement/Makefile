# ---------------------------------------------------------------------------
# Space Cubics OBC A1 (SC-OBC-A1)
# Generate FPGA bitstream file
#  Copyright © 2022 Space Cubics, LLC.
# ---------------------------------------------------------------------------
# FPGA TOP Module: sc_obc_a1_fpga
# Target Device  : Xilinx Artix-7 (XC7A200T-FBG676-1)
# ---------------------------------------------------------------------------

TOPMODULE            := sc_obc_a1_fpga
ITCM_INIT_FILE       :=
ifdef ITCM_INIT_FILE
	ITCM_INIT = on
else
	ITCM_INIT = off
endif

# Command variables
VIVADOTCL            := vivado -mode batch
CP                   := cp -rf
RM                   := rm -rf
MKDIR                := mkdir -p
ELF2MHEX             := ../vivado/tools/elf2mhex.bash

# File Path variables
IP_ROOT_DIR          := ../vivado/ip
CIP_DIR              := ip
CM3_SYNTH_DIR        := cm3
CM3_IP               := cortex_m3
CM3_RTL              := $(CM3_SYNTH_DIR)/AhbSToAxi_design.v
MAIN_AXI_CROSSBAR    := main_axi_crossbar
UDL_AXI_CROSSBAR     := udl_axi_crossbar
AXI_CROSSBAR_DIR     := $(CIP_DIR)/axi_crossbar
AXI_CROSSBAR_DCP      = $(DESIGN_DIR)/$(MAIN_AXI_CROSSBAR)/$(MAIN_AXI_CROSSBAR).dcp $(DESIGN_DIR)/$(UDL_AXI_CROSSBAR)/$(UDL_AXI_CROSSBAR).dcp

RTL_ROOT_DIR         := ../rtl
RTL_DIR_LIST          = $(shell find $(RTL_ROOT_DIR) -type d)
RTL_LIST             := $(foreach list, $(RTL_DIR_LIST), $(wildcard $(list)/*.v)) $(CM3_RTL)

LOG_DIR              := log
DESIGN_DIR           := output
CONSTRAINTS_DIR      := constraints
BIT_DIR              := bitstream
GIT_DIR              := ../.git
ifeq ("$(wildcard $(GIT_DIR)/config)","")
	BUILD_INFO = 00000000
else
	BUILD_INFO = $(shell git rev-parse HEAD | cut -c 1-8)
endif

CF                   := $(CIP_DIR) $(DESIGN_DIR) $(LOG_DIR) $(BIT_DIR) rtl.list
CF                   += vivado* .Xil .hbs


PHONY := all
all: write_mcs

# Synthesis Cortex-M3
# ---------------------------------------------------------------------------
$(CIP_DIR)/$(CM3_IP)/script/$(CM3_IP)_genxci.tcl:
	$(CP) $(IP_ROOT_DIR) $(CIP_DIR)

$(CIP_DIR)/$(CM3_IP)/$(CM3_IP).xci: $(CIP_DIR)/$(CM3_IP)/script/$(CM3_IP)_genxci.tcl
	cd $(CIP_DIR)/$(CM3_IP) && make

$(CM3_SYNTH_DIR)/sc_cm3_wrapper.dcp $(CM3_SYNTH_DIR)/AhbSToAxi_design.v: $(RTL_ROOT_DIR)/sc-cm3-ss/sc_cm3_wrapper.v $(CIP_DIR)/cortex_m3/cortex_m3.xci
	cd $(CM3_SYNTH_DIR) && make

# Synthesis Xilinx IP (AXI Crossbar)
# ---------------------------------------------------------------------------
PHONY += synthesis_ip
synthesis_ip: $(AXI_CROSSBAR_DCP)

$(AXI_CROSSBAR_DIR)/$(MAIN_AXI_CROSSBAR)/$(MAIN_AXI_CROSSBAR).xci $(AXI_CROSSBAR_DIR)/$(UDL_AXI_CROSSBAR)/$(UDL_AXI_CROSSBAR).xci:
	cd $(AXI_CROSSBAR_DIR) && make MODULE=$(notdir $(basename $@))

$(DESIGN_DIR)/$(MAIN_AXI_CROSSBAR)/$(MAIN_AXI_CROSSBAR).dcp: $(AXI_CROSSBAR_DIR)/$(MAIN_AXI_CROSSBAR)/$(MAIN_AXI_CROSSBAR).xci
	$(MKDIR) -p $(LOG_DIR)
	$(VIVADOTCL) -source tcl/synthesis_ip.tcl -log $(LOG_DIR)/$(basename $(<F))_synthesis.log -tclargs $(<)
	echo '*' > $(LOG_DIR)/.gitignore
	echo '*' > $(DESIGN_DIR)/.gitignore

$(DESIGN_DIR)/$(UDL_AXI_CROSSBAR)/$(UDL_AXI_CROSSBAR).dcp: $(AXI_CROSSBAR_DIR)/$(UDL_AXI_CROSSBAR)/$(UDL_AXI_CROSSBAR).xci
	$(MKDIR) -p $(LOG_DIR)
	$(VIVADOTCL) -source tcl/synthesis_ip.tcl -log $(LOG_DIR)/$(basename $(<F))_synthesis.log -tclargs $(<)
	echo '*' > $(LOG_DIR)/.gitignore
	echo '*' > $(DESIGN_DIR)/.gitignore

# Synthesis TOP Module
# ---------------------------------------------------------------------------
PHONY += synthesis_top
synthesis_top: $(DESIGN_DIR)/synthesis/$(TOPMODULE)_synthesis.dcp

$(DESIGN_DIR)/synthesis/$(TOPMODULE)_synthesis.dcp: $(RTL_LIST) $(CM3_SYNTH_DIR)/sc_cm3_wrapper.dcp $(AXI_CROSSBAR_DCP) $(ITCM_INIT_FILE)
	@echo $(filter-out %sc_cm3_wrapper.v,${RTL_LIST}) > rtl.list
    ifdef ITCM_INIT_FILE
		$(ELF2MHEX) $(ITCM_INIT_FILE)
    endif
	$(VIVADOTCL) -source tcl/synthesis.tcl -log $(LOG_DIR)/$(TOPMODULE)_synthesis.log\
		-tclargs $(TOPMODULE) rtl.list $(ITCM_INIT) $(notdir $(ITCM_INIT_FILE:.elf=.hex)) $(BUILD_INFO) $(CM3_SYNTH_DIR)/sc_cm3_wrapper.dcp  $(AXI_CROSSBAR_DCP)

# Place and Route TOP Module
# ---------------------------------------------------------------------------
PHONY += place
place: $(DESIGN_DIR)/place/$(TOPMODULE)_place.dcp

$(DESIGN_DIR)/place/$(TOPMODULE)_place.dcp: $(DESIGN_DIR)/synthesis/$(TOPMODULE)_synthesis.dcp $(CONSTRAINTS_DIR)/$(TOPMODULE)_io.xdc
	$(VIVADOTCL) -source tcl/place.tcl -log $(LOG_DIR)/$(TOPMODULE)_place.log -tclargs $(TOPMODULE) $<

PHONY += route
route: $(DESIGN_DIR)/route/$(TOPMODULE)_route.dcp

$(DESIGN_DIR)/route/$(TOPMODULE)_route.dcp: $(DESIGN_DIR)/place/$(TOPMODULE)_place.dcp
	$(VIVADOTCL) -source tcl/route.tcl -log $(LOG_DIR)/$(TOPMODULE)_route.log -tclargs $(TOPMODULE) $<

# Generate Bitstream file
# ---------------------------------------------------------------------------
PHONY += write_mcs
write_mcs: $(BIT_DIR)/$(TOPMODULE).bit $(BIT_DIR)/$(TOPMODULE).mcs

$(BIT_DIR)/$(TOPMODULE).bit $(BIT_DIR)/$(TOPMODULE).mcs: $(DESIGN_DIR)/route/$(TOPMODULE)_route.dcp
	$(MKDIR) $(BIT_DIR)
	echo '*' > $(BIT_DIR)/.gitignore
	$(VIVADOTCL) -source tcl/gen_bitstream.tcl -log $(LOG_DIR)/$(TOPMODULE)_wbitstream.log -tclargs $(TOPMODULE) $<

# clean target
# ---------------------------------------------------------------------------
PHONY += clean
clean:
	cd $(CM3_SYNTH_DIR) && make clean
	$(RM) $(CF)

.PHONY: $(PHONY)
