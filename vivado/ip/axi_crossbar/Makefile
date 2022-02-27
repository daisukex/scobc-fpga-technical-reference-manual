# ---------------------------------------------------------------------------
# Xilinx AXI Crossbar IP
# Generate .xci script
#  Copyright © 2022 Space Cubics, LLC.
# ---------------------------------------------------------------------------

# Design parameter
MODULE      := sample_axi_crossbar
DEVICE      := xc7a200tfbg676-1

# Command variables
VIVADOTCL   := vivado -mode batch
RM          := rm -rf

# File Path variables
CF           = vivado_* vivado.jou vivado.log $(MODULE)_dir $(dir $(wildcard */*.xci)) *.xci

all: $(MODULE).xci

%.xci: %.config
	$(VIVADOTCL) -source script/axi_crossbar_genxci.tcl -tclarg $* $(DEVICE)
	$(RM) $(MODULE)_prj
	echo '*' > $(MODULE)/.gitignore

generate_target: $(MODULE).xci
	$(VIVADOTCL) -source script/generate_target.tcl -tclarg $(MODULE) $(DEVICE)

.PHONY: clean
clean:
	$(RM) $(CF)
