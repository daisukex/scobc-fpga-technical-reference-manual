# ---------------------------------------------------------------------------
# Space Cubics OBC A1 (SC-OBC-A1)
# Generate FPGA bitstream file
#  Copyright © 2022 Space Cubics, LLC.
# ---------------------------------------------------------------------------
# FPGA TOP Module: sc_obc_a1_fpga
# Target Device  : Xilinx Artix-7 (XC7A200T-FBG676-1)
# ---------------------------------------------------------------------------

# Command variables
CP              := cp -rf
RM              := rm -rf

# File Path variables
IP_ROOT_DIR     := ../vivado/ip
CIP_DIR         := ip
CM3_SYNTH_DIR   := cm3
CM3_IP          := cortex_m3

CF              := $(CIP_DIR)

PHONY := all
all: cm3/sc_cm3_wrapper.dcp

# Synthesis Cortex-M3
# ---------------------------------------------------------------------------
$(CIP_DIR)/$(CM3_IP)/script/$(CM3_IP)_genxci.tcl:
	$(CP) $(IP_ROOT_DIR) $(CIP_DIR)

$(CIP_DIR)/$(CM3_IP)/$(CM3_IP).xci: $(CIP_DIR)/$(CM3_IP)/script/$(CM3_IP)_genxci.tcl
	cd $(CIP_DIR)/$(CM3_IP) && make

$(CM3_SYNTH_DIR)/sc_cm3_wrapper.dcp $(CM3_SYNTH_DIR)/AhbSToAxi_design.v: $(CIP_DIR)/cortex_m3/cortex_m3.xci
	cd $(CM3_SYNTH_DIR) && make

# clean target
# ---------------------------------------------------------------------------
PHONY += clean
clean:
	cd $(CM3_SYNTH_DIR) && make clean
	$(RM) $(CF)

.PHONY: $(PHONY)
