/* pbdutil.m */
/* Utility to read/write Pasteboard */
/* written by rok (CHOI Kyong-Rok) */
/* (C) 2003 by CHOI Kyong-Rok */
/* $Id: pbdutil.m,v 1.4 2003/07/23 03:04:36 rok Exp rok $ */

#import <Cocoa/Cocoa.h>
#include <stdio.h>
#include <sys/types.h>
#include <sys/uio.h>
#include <unistd.h>

//typedef enum {in, out} inout;
void init();
void usage();
void listTypes(NSPasteboard *pbd, int verboseLevel);
BOOL writeDataForType(NSPasteboard *pbd, char *typename);
BOOL readDataForType(NSPasteboard *pbd, char *typename);
void pbdclear(NSPasteboard *pbd);

NSDictionary *pbTypes;

int
main(int argc, char *argv[])
{
    int verboseLevel = 0;
    char *typename;
    NSAutoreleasePool *arp = [[NSAutoreleasePool alloc] init];
    NSPasteboard *pbd = [NSPasteboard generalPasteboard];
    enum {get, set, list, help, clear, none} what = none;
    char sw;

    init();	// setup pbTypes etc.

    while((sw = getopt(argc, argv, "vchlw:r:R:")) != -1){
	switch(sw){
	    case 'h':		// show help
		what = help;
		break;
	    case 'l':		// list available types and information
		what = list;
		break;
	    case 'w':		// write to pasteboard
		what = set;
		typename = strdup(optarg);
		break;
	    case 'r':		// read from pasteboard
		what = get;
		typename = strdup(optarg);
		break;
	    case 'c':		// clear pasteboard
		what = clear;
		break;
	    case 'v':
		verboseLevel += 1;
		break;
	    case 'R':		// read every data from pasteboard
		// *** NOT YET IMPLEMENTED ***
		break;
	    default:
		break;
	}
    }
    argc -= optind;
    argv += optind;

    switch(what){
	case help:
	    usage();
	    break;
	case get:
	    if(readDataForType(pbd, typename) != YES)
		usage();	// TYPE typename not exists
	    break;
	case set:
	    if(writeDataForType(pbd, typename) != YES)
		usage();	// TYPE typename not exists
	    break;
	case clear:
	    pbdclear(pbd);
	    break;
	case list:
	default:
	    listTypes(pbd, verboseLevel);
	    break;
    }

    [arp release];
    return 0;
}

void
init()
{
    pbTypes = [NSDictionary
	dictionaryWithObjects:
	    [NSArray arrayWithObjects: 
		NSStringPboardType,
		NSTIFFPboardType,
		NSPDFPboardType,
		NSPICTPboardType,
		NSHTMLPboardType,
		NSRTFPboardType,
		NSRTFDPboardType,
		NSTabularTextPboardType,
		nil]
	forKeys:
	    [NSArray arrayWithObjects:
		@"text",
		@"tiff",
		@"pdf",
		@"pict",
		@"html",
		@"rtf",
		@"rtfd",
		@"tab",
		nil]];
}

void usage()
{
    NSEnumerator *ke = [pbTypes keyEnumerator];
    NSString *k;
    printf("Usage:	pbdutil [-r type|-w type|-l[ -v[ -v[ -v]]]|-c]\n");
    printf("	(supported types:");
    while((k = [ke nextObject]) != nil){
	printf(" %s", [k cString]);
    }
    printf(")\n");
    exit(1);
}

void
listTypes(NSPasteboard *pbd, int verboseLevel)
{
    NSString *t, *k;
    NSEnumerator *ke;
    NSArray *types = [pbd types];
    NSEnumerator *en = [types objectEnumerator];

    printf("Available type(s):");
    while((t = [en nextObject]) != nil){
	ke = [pbTypes keyEnumerator];	// supported types
	if(verboseLevel <= 2){
	    while((k = [ke nextObject]) != nil){
		if([(NSString *)t isEqualToString: (NSString *)[pbTypes objectForKey: k]]){
		    if(verboseLevel <= 0){
			printf("\t%s", (char *)[k cString]);
		    }else if(verboseLevel >= 1){
			printf("\n\t%s (%s)", (char *)[k cString],
				[[t description] cString]);
		    }
		    if(verboseLevel >= 2){
			printf(" (size: %d bytes)",
			    [[pbd dataForType: t] length]);
		    }
		}
	    }
	}else{	// verboseLevel >= 3
	    printf("\n\t%s (size: %d)", [[t description] cString],
		    [[pbd dataForType: t] length]);
	}
    }
    printf("\n");
}

// write data in Pasteboard to stdout
BOOL
readDataForType(NSPasteboard *pbd, char *typename)
{
    NSString *type;

    if((type = [pbTypes objectForKey:
	    [NSString stringWithCString: typename]]) != nil){
	NSData *t = [pbd dataForType: type];
	if(t != nil){	// t should not be nil
	    int l = [t length];
	    void *d = (void *)[t bytes];
	    while(l >= 0){
		write(1, d, l>256?256:l);
		d += 256;
		l -= 256;
	    }
	}
    }else{
	return NO;
    }
    return YES;
}

// read data from stdin and write to Pasteboard
BOOL
writeDataForType(NSPasteboard *pbd, char *typename)
{
    int l;
    char buffer[256];
    NSString *type;
    NSMutableData *data = [NSMutableData dataWithLength: 0];
#if DEBUG > 1
    int readCount = 0;
#endif

    if((type = [pbTypes objectForKey:
	    [NSString stringWithCString: typename]]) != nil){
	while((l = read(0, buffer, 256)) > 0){
	    [data appendBytes: buffer length: l];
#if DEBUG > 1
	    readCount += l;
#endif
	}
	if(l < 0){		// read error
	    perror("Read error: ");
	    return NO;
	}
#if DEBUG > 1
	fprintf(stderr, "%d bytes read.\n", 
#endif
	[pbd declareTypes: [NSArray arrayWithObject: type] owner: nil];
	[pbd setData: data forType: type];
    }else{
    	return NO;
    }

    return YES;
}


void
pbdclear(NSPasteboard *pbd)
{
    (void)[pbd declareTypes: nil owner: nil];
    return;
}
