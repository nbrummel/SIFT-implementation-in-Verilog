# TOP, SRC, TEMPLATES are passed in
SRCS := $(shell find $(SRC) -type f -name '*.v')
UCF := $(wildcard $(SRC)/$(TOP).ucf)

PART := xc5vlx110t-ff1136-1

default: all

#XST
XST_TMPDIR := xst/tmp
XST_PRJ := $(TOP).prj
XST_BATCH := $(TOP).xst
XST_OUT := $(TOP).ngc

$(XST_PRJ): $(SRCS) | $(XST_TMPDIR)
	for src in $(SRCS); do\
		echo "verilog work \"$$src\"";\
	done > $@

$(XST_TMPDIR):
	mkdir -p $@

$(XST_BATCH): $(TEMPLATES)/xst.batch $(XST_PRJ)
	sed "s/##TOPMODULE##/$(TOP)/g" < $< > $@

$(XST_OUT): $(XST_BATCH)
	xst -ifn $(TOP).xst -ofn $(TOP).syr

synth xst: $(XST_OUT)


#NGDBUILD
NGDBUILD_OUT := $(TOP).ngd
UCF_FLAG := $(if $(UCF),-uc $(UCF))
NGC_DIRS := $(shell find $(SRC) -type d -exec echo -n "-sd {} " \;)

$(NGDBUILD_OUT): $(XST_OUT) $(UCF)
	ngdbuild -dd _ngo $(NGC_DIRS) -nt timestamp $(UCF_FLAG) -p $(PART) $(XST_OUT) $@



#MAP
MAP_OUT := $(TOP)_map.ncd
MAP_OPTS := $(shell cat $(TEMPLATES)/map.opts | tr '\n' ' ')

$(MAP_OUT) : $(NGDBUILD_OUT)
	map $(MAP_OPTS) -p $(PART) -o $@ $< $(TOP).pcf

map: $(MAP_OUT)

#PAR
PAR_OUT := $(TOP).ncd

$(PAR_OUT): $(MAP_OUT)
	par -w -ol high -mt off $(MAP_OUT) $@ $(TOP).pcf

par: $(PAR_OUT)

#TRCE
TCRE_OUT := $(TOP).twr

$(TCRE_OUT): $(PAR_OUT)
	trce -v 3 -s 1 -n 10 -fastpaths -xml $(TOP).twx $< -o $(TCRE_OUT) $(TOP).pcf

timing: $(TCRE_OUT)

#BITGEN
BITFILE := $(TOP).bit

$(BITFILE): $(PAR_OUT)
	bitgen -w $< $@ $(TOP).pcf

bitgen: $(BITFILE)

#IMPACT
IMPACT_BATCH := impact.batch

$(IMPACT_BATCH): $(TEMPLATES)/impact.batch
	sed "s/##BITFILE##/$(BITFILE)/" < $< > $@

impact: $(BITGEN_BIT) $(IMPACT_BATCH)
	impact -batch $(IMPACT_BATCH)

#MISC
report:
	xreport $(TOP) &

schematic schem ise:
	ise &

all: $(BITFILE) timing

.PHONY = all synth xst map par timing bitgen impact report schematic schem ise clean
