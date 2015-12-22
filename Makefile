PROG = dm
PREFIX ?= /usr
BINPREFIX  = $(PREFIX)/bin

all: ${PROG}

${PROG}: ${PROG}.sh
	@cp ${PROG}.sh ${PROG}

clean: ${PROG}
	@rm -f ${PROG}

install: ${PROG}
	@mkdir -p $(BINPREFIX)
	@cp -p dm $(BINPREFIX)
	@chmod 755 $(BINPREFIX)/dm

uninstall:
	@rm -f $(BINPREFIX)/dm

