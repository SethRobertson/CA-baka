prefix=/usr/local
bindir=${prefix}/sbin
mandir=${prefix}/share/man
man8dir=${mandir}/man8

PROG=CA-baka
MAN=$(PROG).8
TARGETS=$(PROG) $(MAN)

README: $(PROG)
	pod2text < $^ > $@

install: $(TARGETS)
	mkdir -p $(DESTDIR)$(man8dir) $(DESTDIR)$(bindir)
	install -m 444 $(MAN) $(DESTDIR)$(man8dir)
	if [ -d .git ]; then								\
	  VERSION=`./$(PROG) --version`;						\
	  sed "s/{UNTAGGED}/$${VERSION}/" $(PROG) > $(DESTDIR)$(bindir)/$(PROG);	\
	  chmod 755 $(DESTDIR)$(bindir)/$(PROG);					\
	else										\
	  install -m 755 $(PROG) $(DESTDIR)$(bindir)/;					\
	fi

$(MAN): $(PROG)
	pod2man < $^ > $@

clean:
	rm -f *~ $(MAN)

