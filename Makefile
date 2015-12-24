PROG = dm
PREFIX ?= /usr
BINPREFIX  = $(PREFIX)/bin

all: ${PROG}

${PROG}: ${PROG}.sh
	@cp ${PROG}.sh ${PROG}

clean: ${PROG}
	@rm -f ${PROG}

install: ${PROG}
	@install -m755 dm $(BINPREFIX)/dm

uninstall:
	@rm -f $(BINPREFIX)/dm

