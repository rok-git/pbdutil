/* pbdutil.m */
/* Utility to read/write Pasteboard */
/* written by rok (CHOI Kyong-Rok) */
/* (C) 2003 by CHOI Kyong-Rok */
/* $Id:$ */
#import <Cocoa/Cocoa.h>
#include <stdio.h>
#include <sys/types.h>
#include <sys/uio.h>
#include <unistd.h>

typedef enum {in, out} inout;
enum {get, set, list, help} what;
void init();
BOOL doOptions();
void usage();
void listTypes(NSPasteboard *pbs);
BOOL setDataForPasteboard(NSPasteboard *pbs, NSString *type);

NSDictionary *pbTypes;
int verboseLevel = 0;

int
main(int argc, char *argv[])
{
    NSString *type = nil;
    NSData *t;
    char sw;
    NSAutoreleasePool *arp = [[NSAutoreleasePool alloc] init];
    NSPasteboard *pbs = [NSPasteboard generalPasteboard];
    inout ioDir = out;
    char *typename;

    init();	// setup pbTypes etc.

    while((sw = getopt(argc, argv, "vchlw:r:")) != -1){
	switch(sw){
	    case 'h':		// show help
		what = help;
		break;
	    case 'l':		// list available types
		what = list;
		break;
	    case 'w':		// set data from stdin
		what = set;
		ioDir = in;
		typename = strdup(optarg);
		break;
	    case 'r':		// specify type
		what = get;
		ioDir = out;
		typename = strdup(optarg);
		break;
	    case 'v':
		verboseLevel += 1;
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
	case list:
	    listTypes(pbs);
	    break;
	case get:
	case set:
	    if((type = [pbTypes objectForKey:
		    [NSString stringWithCString: typename]]) == nil){
		usage();
	    }
	    if(type != nil){
		if(ioDir == out){	// put data in pasteboard to stdout
		    t = [pbs dataForType: type];
		    write(1, [t bytes], [t length]);
		}else{			// read data from stdin and store it in pasetebnoard
		    if(!setDataForPasteboard(pbs, type)){
			// error (do nothing)
		    };
		}
	    }
	    break;
	default:
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
    printf("Usage:	pbdutil [-r type|-w type|-l]\n");
    printf("	(supported types:");
    while((k = [ke nextObject]) != nil){
	printf(" %s", [k cString]);
    }
    printf(")\n");
    exit(1);
}

void
listTypes(NSPasteboard *pbs)
{
    NSString *t, *k;
    NSEnumerator *ke;
    NSArray *types = [pbs types];
    NSEnumerator *en = [types objectEnumerator];

    printf("Available type(s):");
    switch(verboseLevel){
	case 0:
	case 1:
	case 2:
	    while((t = [en nextObject]) != nil){
		ke = [pbTypes keyEnumerator];	// supported types
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
	    }
	    break;
	default:	// verboseLevel >= 3
	    // show more detail about available types
	    while((t = [en nextObject]) != nil){
		printf("\n\t%s (size: %d)", [[t description] cString],
			[[pbs dataForType: t] length]);
	    }
	    break;
    }
    printf("\n");
}

BOOL
setDataForPasteboard(NSPasteboard *pbs, NSString *type)
{
    NSMutableData *data = [NSMutableData dataWithLength: 0];
    char buffer[256];
    int l;

    while((l = read(0, buffer, 256)) > 0){
	[data appendBytes: buffer length: l];
    }
    if(l < 0){		// read error
	perror("Read error: ");
	return NO;
    }
    [pbs declareTypes: [NSArray arrayWithObject: type] owner: nil];
    [pbs setData: data forType: type];
    return YES;
}
