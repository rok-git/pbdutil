/* pbdutil.m */
/* Utility to read/write Pasteboard */
/* written by rok (CHOI Kyong-Rok) */
/* (C) 2003 by CHOI Kyong-Rok */
/* $Id: pbdutil.m,v 1.2 2003/04/16 07:39:54 rok Exp rok $ */

#import <Cocoa/Cocoa.h>
#include <stdio.h>
#include <sys/types.h>
#include <sys/uio.h>
#include <unistd.h>

//typedef enum {in, out} inout;
void init();
void usage();
void listTypes(NSPasteboard *pbs, int verboseLevel);
BOOL writeDataForType(NSPasteboard *pbs, char *typename);
BOOL readDataForType(NSPasteboard *pbs, char *typename);

NSDictionary *pbTypes;

int
main(int argc, char *argv[])
{
    int verboseLevel = 0;
    char *typename;
    NSAutoreleasePool *arp = [[NSAutoreleasePool alloc] init];
    NSPasteboard *pbs = [NSPasteboard generalPasteboard];
    enum {get, set, list, help, none} what = none;
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
	    if(readDataForType(pbs, typename) != YES)
		usage();	// TYPE typename not exists
	    break;
	case set:
	    if(writeDataForType(pbs, typename) != YES)
		usage();	// TYPE typename not exists
	    break;
	case list:
	default:
	    listTypes(pbs, verboseLevel);
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
		@"tab",
		nil]];
}

void usage()
{
    NSEnumerator *ke = [pbTypes keyEnumerator];
    NSString *k;
    printf("Usage:	pbdutil [-r type|-w type|-l[ -v[ -v[ -v]]]]\n");
    printf("	(supported types:");
    while((k = [ke nextObject]) != nil){
	printf(" %s", [k cString]);
    }
    printf(")\n");
    exit(1);
}

void
listTypes(NSPasteboard *pbs, int verboseLevel)
{
    NSString *t, *k;
    NSEnumerator *ke;
    NSArray *types = [pbs types];
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
			    [[pbs dataForType: t] length]);
		    }
		}
	    }
	}else{	// verboseLevel >= 3
	    printf("\n\t%s (size: %d)", [[t description] cString],
		    [[pbs dataForType: t] length]);
	}
    }
    printf("\n");
}

BOOL
readDataForType(NSPasteboard *pbs, char *typename)
{
    NSString *type;

    if((type = [pbTypes objectForKey:
	    [NSString stringWithCString: typename]]) != nil){
	NSData *t = [pbs dataForType: type];
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

BOOL
writeDataForType(NSPasteboard *pbs, char *typename)
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
	[pbs declareTypes: [NSArray arrayWithObject: type] owner: nil];
	[pbs setData: data forType: type];
    }else{
    	return NO;
    }

    return YES;
}
