# $Id: Makefile,v 1.2 2003/04/16 07:40:28 rok Exp rok $
CC = cc -framework Cocoa -g
CFLAGS = -Wall 
INSTALLDIR = /usr/local
MANSUFFIX = 1
FILES = pbdutil.m Makefile

pbdutil:

install: pbdutil
	install -c -m 755 pbdutil $(INSTALLDIR)/bin
#	install -c -m 644 pbdutil.$(MANSUFFIX) $(INSTALLDIR)/man/man$(MANSUFFIX)

tar:
	mkdir distfiles
	cp -p pbdutil.m Makefile pbdutil.1 distfiles/
	tar vcfz pbdutil.tar.gz distfiles
	rm -rf distfiles

