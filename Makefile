NAME     = bootiso
COMMAND  = bootiso
MANDIR   = extra/man

PREFIX   ?= /usr/local

.PHONY: install, uninstall

default: install

install:
	@install -D bootiso $(DESTDIR)$(PREFIX)/bin/bootiso &&\
	 install -Dm644 $(MANDIR)/bootiso.1 $(DESTDIR)$(PREFIX)/share/man/man1/bootiso.1 &&\
	 echo "[OK] $(NAME) installed."

uninstall:
	@rm $(DESTDIR)$(PREFIX)/bin/bootiso $(DESTDIR)$(PREFIX)/share/man/man1/bootiso.1 &&\
	echo "[OK] $(NAME) uninstalled."
