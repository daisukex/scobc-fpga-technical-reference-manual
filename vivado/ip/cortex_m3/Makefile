# ---------------------------------------------------------------------------
# Cortex-M3 SubSystem
# Generate .xci script
#  Copyright © 2022 Space Cubics, LLC.
# ---------------------------------------------------------------------------

# Design parameter
MODULE      := cortex_m3
DEVICE      := xc7a200tfbg676-1

# Command variables
VIVADOTCL   := vivado -mode batch
RM          := rm -rf

# File Path variables
CF           = vivado_* vivado.jou vivado.log $(MODULE)_prj $(MODULE) *.xci

all: generate_target

%.xci:
	$(VIVADOTCL) -source script/$(MODULE)_genxci.tcl -tclarg $* $(DEVICE)
	$(RM) $(MODULE)_prj
	echo '*' > $(MODULE)/.gitignore

generate_target: $(MODULE).xci
	$(VIVADOTCL) -source script/generate_target.tcl -tclarg $(MODULE) $(DEVICE)

.PHONY: clean
clean:
	$(RM) $(CF)
