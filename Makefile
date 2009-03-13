# $Id: Makefile,v 1.5 2006/08/19 10:48:29 rok Exp rok $
#CC = cc -framework Cocoa -g
#CC = cc -framework Cocoa -g -arch i386 -arch ppc -isysroot /Developer/SDKs/MacOSX10.4u.sdk
CC = cc -framework Cocoa -g -arch i386 -arch ppc -isysroot /Developer/SDKs/MacOSX10.5.sdk
CFLAGS = -Wall 
INSTALLDIR = /usr/local
MANSUFFIX = 1
FILES = pbdutil.m mkfw.m Makefile pbdutil.1
PROGRAMS = pbdutil mkfw

all: $(PROGRAMS)
pbdutil:
mkfw:

install: pbdutil
	mkdir -p $(INSTALLDIR)/bin
	install -c -m 755 $(PROGRAMS) $(INSTALLDIR)/bin

install-man:
	mkdir -p $(INSTALLDIR)/man/man$(MANSUFFIX)
	install -c -m 644 pbdutil.$(MANSUFFIX) $(INSTALLDIR)/man/man$(MANSUFFIX)

tar:
	mkdir distfiles
	cp -p pbdutil.m mkfw.m Makefile pbdutil.1 distfiles/
	tar vcfz pbdutil.tar.gz distfiles
	rm -rf distfiles

clean:
	rm -f pbdutil.o mkfw.o *~ $(PROGRAMS)
