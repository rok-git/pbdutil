# $Id: Makefile,v 1.1 2003/04/10 13:18:05 rok Exp rok $
CC = cc -framework Cocoa -g
CFLAGS = -Wall -DDEBUG=1
INSTALLDIR = /usr/local
MANSUFFIX = 1
FILES = pbdutil.m Makefile

pbdutil:

install: pbdutil
	install -c -m 755 pbdutil $(INSTALLDIR)/bin
	install -c -m 644 pbdutil.$(MANSUFFIX) $(INSTALLDIR)/man/man$(MANSUFFIX)

tar:
	mkdir distfiles
	cp -p pbdutil.m Makefile distfiles/
	tar vcfz pbdutil.tar.gz distfiles
	rm -rf distfiles

