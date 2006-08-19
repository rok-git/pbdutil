# $Id: Makefile,v 1.4 2005/01/09 01:03:46 rok Exp rok $
#CC = cc -framework Cocoa -g
CC = cc -framework Cocoa -g -arch i386 -arch ppc -isysroot /Developer/SDKs/MacOSX10.4u.sdk
CFLAGS = -Wall 
INSTALLDIR = /usr/local
MANSUFFIX = 1
FILES = pbdutil.m Makefile

pbdutil:

install: pbdutil
	install -c -m 755 pbdutil $(INSTALLDIR)/bin

install-man:
	mkdir -p $(INSTALLDIR)/man/man$(MANSUFFIX)
	install -c -m 644 pbdutil.$(MANSUFFIX) $(INSTALLDIR)/man/man$(MANSUFFIX)

tar:
	mkdir distfiles
	cp -p pbdutil.m Makefile pbdutil.1 distfiles/
	tar vcfz pbdutil.tar.gz distfiles
	rm -rf distfiles

clean:
	rm pbdutil.o
