XCO_SRC = $(wildcard *.xco)
V_SRC := $(patsubst %.xco,%.v,$(XCO_SRC))

all: $(V_SRC)

%.v: %.xco
	coregen -p coregen.cgp -b $*.xco

clean:
	find . ! -name '*.xco' -a ! -name '*.coe' -a ! -name 'Makefile' -a ! -name '*.cgp' -a ! -name '*.cgc' -a ! -name '.gitignore' -a ! -name '*.py' -a ! -name '*.jpg' -delete
