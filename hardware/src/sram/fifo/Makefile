<<<<<<< HEAD
XCO_SRC = $(wildcard *.xco)
V_SRC := $(patsubst %.xco,%.v,$(XCO_SRC))

all: $(V_SRC)
=======
all: SRAM_WRITE_FIFO.v SRAM_READ_FIFO.v SRAM_DATA_FIFO.v
>>>>>>> 3f2d1fe029965e5f63a88006b56e02b5fc2c4137

%.v: %.xco
	coregen -p coregen.cgp -b $*.xco

clean:
	find . ! -name '*.xco' -a ! -name '*.coe' -a ! -name 'Makefile' -a ! -name '*.cgp' -a ! -name '*.cgc' -a ! -name '.gitignore' -delete
