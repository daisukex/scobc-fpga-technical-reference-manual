# ---------------------------------------------------------------------------
# Xilinx SEM Controller
# Generate .xci script
#  Copyright © 2022 Space Cubics, LLC.
# ---------------------------------------------------------------------------

# Design parameter
MODULE      := sem_core
DEVICE      := xc7a200tfbg676-1

# Command variables
VIVADOTCL   := vivado -mode batch
RM          := rm -rf

# File Path variables
CF           = vivado_* vivado.jou vivado.log $(MODULE)_dir $(dir $(wildcard */*.xci)) *.xci

all: $(MODULE)/$(MODULE).xci

$(MODULE)/$(MODULE).xci: script/sem_core.tcl
	$(VIVADOTCL) -source script/sem_core.tcl -tclarg $(MODULE) $(DEVICE)
	$(RM) $(MODULE)_prj
	echo '*' > $(MODULE)/.gitignore

generate_target: $(MODULE)/$(MODULE).xci
	$(VIVADOTCL) -source script/generate_target.tcl -tclarg $(MODULE) $(DEVICE)

.PHONY: clean
clean:
	$(RM) $(CF)
