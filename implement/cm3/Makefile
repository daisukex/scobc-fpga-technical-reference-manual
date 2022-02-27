# ---------------------------------------------------------------------------
# Space Cubics ARM Cortex-M3 SubSystem
# sc_cm3_wrapper synthesis enviroment
#  Copyright © 2022 Space Cubics, LLC.
# ---------------------------------------------------------------------------

# Design parameter
IP            = cortex_m3

# Command variables
VIVADOTCL    := vivado -mode batch
RM           := rm -rf
MKDIR        := mkdir -p

# File Path variables
CM3_ROOT_DIR := ../vivado/ip/Arm_ipi_repository
RTL_DIR_LIST := ../../rtl/sc-cm3-ss
IP_DIR       := ../ip
LOG_DIR      := log
DESIGN_DIR   := output

vpath %.v    $(RTL_DIR_LIST)

# Clean File
CF           = $(DESIGN_DIR) $(LOG_DIR)
CF          += vivado* .Xil .hbs AhbSToAxi_design.v sc_cm3_wrapper.dcp

PHONY := all
all: sc_cm3_wrapper.dcp

# Export Cortex-M3 component
# ---------------------------------------------------------------------------
$(DESIGN_DIR)/$(IP)/CORTEXM3INTEGRATION_design.v: $(IP_DIR)/$(IP)/$(IP).xci
	$(MKDIR) $(LOG_DIR)
	echo '*' > $(LOG_DIR)/.gitignore
	$(MKDIR) $(DESIGN_DIR)
	echo '*' > $(DESIGN_DIR)/.gitignore
	$(VIVADOTCL) -source tcl/generate_cm3_components.tcl -log $(LOG_DIR)/generate_cm3_components.log

# Synthesis Cortex-M3 Wrapper
# ---------------------------------------------------------------------------
sc_cm3_wrapper.dcp: sc_cm3_wrapper.v $(DESIGN_DIR)/cortex_m3/CORTEXM3INTEGRATION_design.v
	$(VIVADOTCL) -source tcl/$(basename $(@F))_synthesis.tcl -log $(LOG_DIR)/$(basename $(@F))_synthesis.log -tclargs $^

# clean target
# ---------------------------------------------------------------------------
PHONY += clean
clean:
	$(RM) $(CF)

.PHONY: $(PHONY)
