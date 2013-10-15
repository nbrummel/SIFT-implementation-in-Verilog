CASES := $(wildcard tests/*.do)
TESTINPUTS := $(wildcard tests/*.input)
TRANSCRIPT := $(patsubst tests/%.do,results/%.transcript,$(CASES))
DOFILES := $(patsubst tests/%.do,build/%.do,$(CASES))
TESTINPUTSBUILD := $(patsubst tests/%.input,build/%.input,$(TESTINPUTS))
SRCDIR := ../src
SRCS := $(shell find $(SRCDIR) -name '*.v' -type f)
INC := $(shell find $(SRCDIR) -type d -exec echo -n '+incdir+../'{} \;)
STATUS := build/.status
XILINX_LIBS := unisims_ver unimacro_ver xilinxcorelib_ver secureip
XILINX_LIB_INC := $(foreach lib,$(XILINX_LIBS),$(addprefix -L ,$(lib)))
XILINX_LIBS_MAP := $(wildcard /opt/Xilinx/14.1/ISE_DS/ISE/verilog/mti_se/10.1b_2/lin64/*)
all: $(TRANSCRIPT)

compile: $(STATUS)

$(STATUS): $(SRCS) | build/Makefile
	make -C build
	touch $@

build/Makefile:
	mkdir -p build
	(cd build; vlib work; vmap work work)
	(cd build; for file in $(XILINX_LIBS_MAP); do \
	vmap $$(basename $$file) $$file || exit 1; done)
	(cd build; \
	vlog +acc -vopt -source -nocovercells  \
	/opt/Xilinx/14.1/ISE_DS/ISE/verilog/src/glbl.v \
	|| exit 1)
	(cd build; for file in $(SRCS); do \
	vlog +acc -vopt -source -nocovercells $(INC) ../$$file || exit 1; done)
	(cd build; vmake > Makefile)

results:
	mkdir -p results

$(DOFILES) : build/%.do : tests/%.do
	mkdir -p build
	echo 'proc start {m} {vsim $(XILINX_LIB_INC) work.glbl $$m}' \
	| cat - $< > $@ 

$(TESTINPUTSBUILD) : build/% : tests/%
	cp $< $@
	
$(TRANSCRIPT) : results/%.transcript : build/%.do $(STATUS) $(TESTINPUTSBUILD) | results
	(cd build; \
	vsim < ../$< | tee ../$@)
	cp build/vsim.wlf $(patsubst %.transcript,%.wlf,$@)

clean:
	rm -rf results build

.PHONY := all clean compile
