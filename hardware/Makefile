TOP := FPGA_TOP_ML505
SRC := src
TEMPLATES := cfg

TARGETS = all synth xst map par timing bitgen impact report schematic schem ise

BUILDDIR := build/$(TOP)
MAKEFILE := $(BUILDDIR)/Makefile
MAKEARGS := TOP=$(TOP) SRC=../../$(SRC) TEMPLATES=../../$(TEMPLATES)

$(TARGETS): $(MAKEFILE)
	$(MAKE) $@ -C $(BUILDDIR) $(MAKEARGS)

$(MAKEFILE): cfg/Makefile
	mkdir -p build/$(TOP)
	cp $< $@

clean:
	rm -rf build

.PHONY := $(TARGETS) clean
