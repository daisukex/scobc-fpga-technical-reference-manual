# ---------------------------------------------------------------------------
# Space Cubics OBC A1 (SC-OBC-A1)
# Generate FPGA bitstream file
#  Copyright © 2022 Space Cubics, LLC.
# ---------------------------------------------------------------------------
# FPGA TOP Module: sc_obc_a1_fpga
# Target Device  : Xilinx Artix-7 (XC7A200T-FBG676-1)
# ---------------------------------------------------------------------------

# Command variables
VIVADOTCL            := vivado -mode batch
CP                   := cp -rf
RM                   := rm -rf
MKDIR                := mkdir -p

# File Path variables
IP_ROOT_DIR          := ../vivado/ip
CIP_DIR              := ip
CM3_SYNTH_DIR        := cm3
CM3_IP               := cortex_m3
MAIN_AXI_CROSSBAR    := main_axi_crossbar
UDL_AXI_CROSSBAR     := udl_axi_crossbar
AXI_CROSSBAR_DIR     := $(CIP_DIR)/axi_crossbar
AXI_CROSSBAR_DCP      = $(DESIGN_DIR)/$(MAIN_AXI_CROSSBAR)/$(MAIN_AXI_CROSSBAR).dcp $(DESIGN_DIR)/$(UDL_AXI_CROSSBAR)/$(UDL_AXI_CROSSBAR).dcp
LOG_DIR              := log
DESIGN_DIR           := output
CF                   := $(CIP_DIR) $(DESIGN_DIR) $(LOG_DIR)
CF                   += vivado* .Xil .hbs


PHONY := all
all: main_axi_crossbar.dcp udl_axi_crossbar.dcp

# Synthesis Cortex-M3
# ---------------------------------------------------------------------------
$(CIP_DIR)/$(CM3_IP)/script/$(CM3_IP)_genxci.tcl:
	$(CP) $(IP_ROOT_DIR) $(CIP_DIR)

$(CIP_DIR)/$(CM3_IP)/$(CM3_IP).xci: $(CIP_DIR)/$(CM3_IP)/script/$(CM3_IP)_genxci.tcl
	cd $(CIP_DIR)/$(CM3_IP) && make

$(CM3_SYNTH_DIR)/sc_cm3_wrapper.dcp $(CM3_SYNTH_DIR)/AhbSToAxi_design.v: $(CIP_DIR)/cortex_m3/cortex_m3.xci
	cd $(CM3_SYNTH_DIR) && make

# Synthesis Xilinx IP (AXI Crossbar)
# ---------------------------------------------------------------------------
PHONY += synthesis_ip
synthesis_ip: $(AXI_CROSSBAR_DCP)

$(AXI_CROSSBAR_DIR)/$(MAIN_AXI_CROSSBAR).xci $(AXI_CROSSBAR_DIR)/$(UDL_AXI_CROSSBAR).xci:
	cd $(AXI_CROSSBAR_DIR) && make MODULE=$(notdir $(basename $@))

$(DESIGN_DIR)/$(MAIN_AXI_CROSSBAR)/$(MAIN_AXI_CROSSBAR).dcp: $(AXI_CROSSBAR_DIR)/$(MAIN_AXI_CROSSBAR).xci
	$(MKDIR) -p $(LOG_DIR)
	$(VIVADOTCL) -source tcl/synthesis_axi_crossbar_ip.tcl -log $(LOG_DIR)/$(basename $(<F))_synthesis.log -tclargs $(<F)
	echo '*' > $(LOG_DIR)/.gitignore
	echo '*' > $(DESIGN_DIR)/.gitignore

$(DESIGN_DIR)/$(UDL_AXI_CROSSBAR)/$(UDL_AXI_CROSSBAR).dcp: $(AXI_CROSSBAR_DIR)/$(UDL_AXI_CROSSBAR).xci
	$(MKDIR) -p $(LOG_DIR)
	$(VIVADOTCL) -source tcl/synthesis_axi_crossbar_ip.tcl -log $(LOG_DIR)/$(basename $(<F))_synthesis.log -tclargs $(<F)
	echo '*' > $(LOG_DIR)/.gitignore
	echo '*' > $(DESIGN_DIR)/.gitignore

# clean target
# ---------------------------------------------------------------------------
PHONY += clean
clean:
	cd $(CM3_SYNTH_DIR) && make clean
	$(RM) $(CF)

.PHONY: $(PHONY)
