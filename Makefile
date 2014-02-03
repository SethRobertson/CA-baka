prefix=/usr/local
bindir=${prefix}/sbin
mandir=${prefix}/share/man
man8dir=${mandir}/man8

PROG=CA-baka
MAN=$(PROG).8
TARGETS=$(PROG) $(MAN)

default: README test

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
	rm -rf *~ $(MAN) test-workdir

.PHONY: test test1 test2 default install clean



test: test1 test2

test1:
	rm -rf test-workdir
	./CA-baka --quiet --workdir test-workdir -C US --ST NY -L "New York" -O "Mythical NY Company" --newca ca.example.com ""
	./CA-baka --quiet --workdir test-workdir --newserver server.example.com
	./CA-baka --quiet --workdir test-workdir --verify test-workdir/archive/server.example.com/server.crt
	./CA-baka --quiet --workdir test-workdir --newclient client.example.com
	./CA-baka --quiet --workdir test-workdir --verify test-workdir/archive/client.example.com/client.crt
	./CA-baka --quiet --workdir test-workdir --newmail mail.example.com
	./CA-baka --quiet --workdir test-workdir --verify test-workdir/archive/mail.example.com/mail.crt
	./CA-baka --quiet --workdir test-workdir --newcoder coder.example.com
	./CA-baka --quiet --workdir test-workdir --verify test-workdir/archive/coder.example.com/coder.crt
	./CA-baka --quiet --workdir test-workdir --newserver server2.example.com --altnames URI:http://server2.example.com --altnames IP:127.0.0.1 --altnames DNS:server20-example-com
	./CA-baka --quiet --workdir test-workdir --verify test-workdir/archive/server2.example.com/server.crt
	./CA-baka --quiet --workdir test-workdir --newclient unwanted.example.com
	./CA-baka --quiet --workdir test-workdir --verify test-workdir/archive/unwanted.example.com/client.crt
	./CA-baka --quiet --workdir test-workdir --revoke unwanted.example.com
	@echo "Next command should generate errors"
	./CA-baka --quiet --workdir test-workdir --verify test-workdir/archive/unwanted.example.com-revoked-*/client.crt && exit 1 || exit 0
	@echo "Previous revoke test succeeded"
	rm -rf test-workdir

test2:
	rm -rf test-workdir
	@echo "Next command should generate errors"
	./CA-baka --quiet --workdir test-workdir -C US --ST NY -L "New York" -O "Mythical NY Company" --newca ca.example.com "" --newserver server.example.com "" --newclient client.example.com "" --newmail mail.example.com "" --newcoder coder.example.com "" --newclient unwanted.example.com "" && echo 1 || echo 0
	@echo "Previous bad-options test succeeded"
	./CA-baka --quiet --workdir test-workdir -C US --ST NY -L "New York" -O "Mythical NY Company" --newca ca.example.com "" --newserver server.example.com "" --newclient client.example.com "" --newmail mail.example.com "" --newcoder coder.example.com ""
	./CA-baka --quiet --workdir test-workdir --newclient unwanted.example.com
	./CA-baka --quiet --workdir test-workdir --verify test-workdir/archive/server.example.com/server.crt --verify test-workdir/archive/client.example.com/client.crt --verify test-workdir/archive/mail.example.com/mail.crt --verify test-workdir/archive/coder.example.com/coder.crt --verify test-workdir/archive/server2.example.com/server.crt --verify test-workdir/archive/unwanted.example.com/client.crt
	./CA-baka --quiet --workdir test-workdir --newserver server2.example.com --altnames URI:http://server2.example.com --altnames IP:127.0.0.1 --altnames DNS:server20-example-com
	@echo "Next command should generate errors"
	./CA-baka --quiet --workdir test-workdir --newserver server2.example.com --altnames URI:http://server2.example.com --altnames IP:127.0.0.1 --altnames DNS:server20-example-com --newclient client2.example.com && exit 1 || exit 0
	@echo "Previous bad-options test succeeded"
	./CA-baka --quiet --workdir test-workdir --revoke unwanted.example.com
	@echo "Next command should generate errors"
	./CA-baka --quiet --workdir test-workdir --verify test-workdir/archive/unwanted.example.com-revoked-*/client.crt && echo 1 || echo 0
	@echo "Previous revoke test succeeded"
	for f in test-workdir/archive/server.example.com/server.crt test-workdir/archive/client.example.com/client.crt test-workdir/archive/mail.example.com/mail.crt test-workdir/archive/coder.example.com/coder.crt; do ./CA-baka --quiet --workdir test-workdir --verify $$f; done
	rm -rf test-workdir
