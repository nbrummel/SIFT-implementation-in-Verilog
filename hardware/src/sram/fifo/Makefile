all: SRAM_WRITE_FIFO.v SRAM_READ_FIFO.v SRAM_DATA_FIFO.v

%.v: %.xco
	coregen -p coregen.cgp -b $*.xco

clean:
	find . ! -name '*.xco' -a ! -name '*.coe' -a ! -name 'Makefile' -a ! -name '*.cgp' -a ! -name '*.cgc' -a ! -name '.gitignore' -delete
