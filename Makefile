# $Id: Makefile,v 1.8 2018/05/01 08:02:51 rok Exp $
#CC = cc -framework Cocoa -g
#CC = cc -framework Cocoa -g -arch i386 -arch x86_64
#CC = cc -framework Cocoa -arch i386 -arch x86_64
#CC = cc -framework Cocoa 
CC = cc -framework Cocoa -arch x86_64 -arch arm64
CFLAGS = -Wall -fobjc-arc
INSTALLDIR = /usr/local
MANDIR=$(INSTALLDIR)/share/man
BINDIR=$(INSTALLDIR)/bin
MANSUFFIX = 1
FILES = pbdutil.m mkfw.m Makefile pbdutil.$(MANSUFFIX)
PROGRAMS = pbdutil mkfw

all: $(PROGRAMS)
pbdutil:
mkfw:

install: $(PROGRAMS)
	mkdir -p $(BINDIR)
	install -c -m 755 $(PROGRAMS) $(BINDIR)

install-man:
	mkdir -p $(MANDIR)/man$(MANSUFFIX)
	install -c -m 644 pbdutil.$(MANSUFFIX) $(MANDIR)/man$(MANSUFFIX)

install-compat:
	if [ -x $(BINDIR)/pbdutil ]; then \
		ln -s pbdutil $(BINDIR)/pbcopy; \
		ln -s pbdutil $(BINDIR)/pbpaste; \
		ln -s pbdutil $(BINDIR)/pbclear; \
	fi

tar:
	mkdir distfiles
	cp -p pbdutil.m mkfw.m Makefile pbdutil.1 distfiles/
	tar vcfz pbdutil.tar.gz distfiles
	rm -rf distfiles

clean:
	rm -f pbdutil.o mkfw.o *~ $(PROGRAMS)
	rm -rf *.dSYM
