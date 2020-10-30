SHELL    = /bin/sh

prefix                                  = /usr/local
exec_prefix                             = $(prefix)
bindir                                  = $(exec_prefix)/bin
datarootdir                             = $(prefix)/share
datadir                                 = $(datarootdir)
docdir                                  = $(datarootdir)/doc/bootiso
htmldir                                 = $(docdir)
mandir                                  = $(datarootdir)/man

zsh_completions_dir                     = $(datadir)/zsh/site-functions
bash_completions_dir                    = $(datadir)/bash-completion/completions

.PHONY: build install uninstall

all: install

build:

install:
	install -D     bootiso                            '$(DESTDIR)$(bindir)/bootiso'
	install -Dm644 extra/man/bootiso.1                '$(DESTDIR)$(mandir)/man1/bootiso.1'
	install -Dm644 extra/completions/completions.zsh  '$(DESTDIR)$(zsh_completions_dir)/_bootiso'
	install -Dm644 extra/completions/completions.bash '$(DESTDIR)$(bash_completions_dir)/bootiso'

uninstall:
	$(RM) '$(DESTDIR)$(bindir)/bootiso'
	$(RM) '$(DESTDIR)$(mandir)/man1/bootiso.1'
	$(RM) '$(DESTDIR)$(zsh_completions_dir)/_bootiso'
	$(RM) '$(DESTDIR)$(bash_completions_dir)/bootiso'
