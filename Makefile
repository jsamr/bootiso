NAME     = bootiso
COMMAND  = bootiso

PREFIX   ?= /usr/local

.PHONY: install, uninstall

default: install

install:
	@install -D bootiso "$(DESTDIR)$(PREFIX)/bin/bootiso" &&\
	 install -Dm644 extra/man/bootiso.1 "$(DESTDIR)$(PREFIX)/share/man/man1/bootiso.1" &&\
	 install -Dm644 extra/completions/completions.bash "$(DESTDIR)$(PREFIX)/share/bash-completion/completions/bootiso" &&\
	 echo "[OK] $(NAME) installed."

uninstall:
	@rm "$(DESTDIR)$(PREFIX)/bin/bootiso" "$(DESTDIR)$(PREFIX)/share/man/man1/bootiso.1" "$(DESTDIR)$(PREFIX)/share/bash-completion/completions/bootiso" &&\
	echo "[OK] $(NAME) uninstalled."
