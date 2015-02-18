PREFIX    ?= /usr/local
BINPREFIX  = $(PREFIX)/bin

all: dm

install:
	mkdir -p $(BINPREFIX)
	cp -p dm $(BINPREFIX)
	chmod 755 $(BINPREFIX)/dm

uninstall:
	rm $(BINPREFIX)/dm

