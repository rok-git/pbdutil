# $Id: Makefile,v 1.3 2005/01/08 15:04:01 rok Exp rok $
CC = cc -framework Cocoa -g
CFLAGS = -Wall 
INSTALLDIR = /usr/local
MANSUFFIX = 1
FILES = pbdutil.m Makefile

pbdutil:

install: pbdutil
	install -c -m 755 pbdutil $(INSTALLDIR)/bin

install-man:
	install -c -m 644 pbdutil.$(MANSUFFIX) $(INSTALLDIR)/man/man$(MANSUFFIX)
tar:
	mkdir distfiles
	cp -p pbdutil.m Makefile pbdutil.1 distfiles/
	tar vcfz pbdutil.tar.gz distfiles
	rm -rf distfiles

