# $Id:$
CC = cc -framework Cocoa -g
CFLAGS = -Wall -DDEBUG=1
INSTALLDIR = /usr/local
MANSUFFIX = 1

pbdutil:

install: pbdutil
	install -c -m 755 pbdutil $(INSTALLDIR)
	install -c -m 644 pbdutil.$(MANSUFFIX) $(INSTALLDIR)/man/man$(MANSUFFIX)

