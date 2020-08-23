/* pbdutil.m */
/* Utility to read/write Pasteboard */
/* written by rok (CHOI Kyong-Rok) */
/* (C) by CHOI Kyong-Rok */

#import <Cocoa/Cocoa.h>
#include <stdio.h>
#include <sys/types.h>
#include <sys/uio.h>
#include <unistd.h>

void init();
void usage();
void listTypes(NSPasteboard *pbd, int verboseLevel);
BOOL writeDataForType(NSPasteboard *pbd, char *typename);
BOOL readDataForType(NSPasteboard *pbd, char *typename);
BOOL readNthData(NSPasteboard *pbd, int n);
void pbdclear(NSPasteboard *pbd);
void pbdcount(NSPasteboard *pbd, int verboseLevel);

enum pbdmode {pbdutil, pbcopy, pbpaste};

NSDictionary *pbTypes;

int
main(int argc, char *argv[])
{
    @autoreleasepool{
    int verboseLevel = 0;
    char *typename = NULL;
    NSPasteboard *pbd = nil;
    enum {get, set, list, help, clear, count, getNth, none} what = none;
    enum pbdmode pbdmode = pbdutil;
    char sw;
    int nth;

    init();	// setup pbTypes etc.

    NSString *cmd = [[NSString stringWithUTF8String: argv[0]] lastPathComponent];

    if([cmd compare: @"pbcopy"] == NSOrderedSame){
	pbdmode = pbcopy;
    }else if([cmd compare: @"pbpaste"] == NSOrderedSame){
	pbdmode = pbpaste;
    }else{
	pbdmode = pbdutil;
    }

    if((pbdmode == pbcopy) || (pbdmode == pbpaste)){
	// pbcopy / pbpaste compatible mode
	switch(pbdmode){
	    case pbcopy:
		what = set;
		break;
	    case pbpaste:
		what = get;
		break;
	    case pbdutil:
	    default:
		// this must not happens
		break;
	}
	NSUserDefaults *args = [[NSUserDefaults alloc] init];
	if([args stringForKey: @"pboard"]){
	    pbd = [NSPasteboard pasteboardWithName:
		    [args stringForKey: @"pboard"]];
	}
	if([args stringForKey: @"Prefer"]){
	    typename = (char *)[[args stringForKey: @"Prefer"] UTF8String];
	}else{
	    typename = "text";
	}
    }else{
	while((sw = getopt(argc, argv, "vcChlw:r:R:n:o:")) != -1){
	    switch(sw){
		case 'h':		// show help
		    what = help;
		    break;
		case 'l':		// list available types and information
		    what = list;
		    break;
		case 'w':		// write to pasteboard
		    what = set;
		    typename = optarg;
		    break;
		case 'r':		// read from pasteboard
		    what = get;
		    typename = optarg;
		    break;
		case 'c':		// clear pasteboard
		    what = clear;
		    break;
		case 'C':		// count the types of contents
		    what = count;
		    break;
		case 'v':
		    verboseLevel += 1;
		    break;
		case 'R':		// read n-th data from pasteboard
		    what = getNth;
		    nth = atoi(optarg);
		    break;
		case 'n':
		    pbd = [NSPasteboard pasteboardWithName:
				[NSString stringWithUTF8String: optarg]];
		    break;
		default:
		    break;
	    }
	}
	argc -= optind;
	argv += optind;
    }

    if(pbd == nil)
	pbd  = [NSPasteboard generalPasteboard];

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
	case count:
	    pbdcount(pbd, verboseLevel);
	    break;
	case getNth:
	    readNthData(pbd, nth);
	    break;
	case list:		// Default Action
	default:
	    listTypes(pbd, verboseLevel);
	    break;
    }

    return 0;
    } // @autoreleasepool
}

void
init()
{
    pbTypes =
        @{
            @"text": NSPasteboardTypeString,
            @"txt": NSPasteboardTypeString,
            @"tiff": NSPasteboardTypeTIFF,
            @"pdf": NSPasteboardTypePDF,
            @"html": NSPasteboardTypeHTML,
            @"rtf": NSPasteboardTypeRTF,
            @"rtfd": NSPasteboardTypeRTFD,
            @"tab": NSPasteboardTypeTabularText,
            @"url": NSPasteboardTypeURL,
            @"path": NSPasteboardTypeFileURL,
            @"font": NSPasteboardTypeFont
        };
}

void usage()
{
    printf("Usage:	pbdutil [-n name] [-r type|-R index|-w type|-l[ -v[ -v[ -v]]]|-c]\n");
    printf("	(supported types:");
    // output order may be strange
    [pbTypes enumerateKeysAndObjectsUsingBlock:
        ^(NSString *k, NSString *obj, BOOL *stop){
            printf(" %s", [k UTF8String]);
        }
    ];
    printf(")\n");
    printf("	pbdutil -C\n");
    exit(1);
}

void
listTypes(NSPasteboard *pbd, int verboseLevel)
{
    NSString *t;
    NSArray *types = [pbd types];
    int i = 1;

    printf("Available type(s):");
    for(t in types){
	if(verboseLevel <= 2){
            [pbTypes enumerateKeysAndObjectsUsingBlock:^(NSString *key, NSString *value, BOOL *stop){
                if([t isEqualToString: value]){
		    if(verboseLevel <= 0){
			printf("\t%s", (char *)[key UTF8String]);
		    }else if(verboseLevel >= 1){
			printf("\n\t%s (%s)", (char *)[key UTF8String],
				[t UTF8String]);
			if(verboseLevel >= 2){
			    printf(" (size: %lu bytes)",
				(unsigned long)[[pbd dataForType: t] length]);
			}
		    }
                }
            }];
	}else{	// verboseLevel >= 3
		// list all types including non-supported types
	    printf("\n\t%2d: %s (size: %lu)", i++, [t UTF8String], (unsigned long)[[pbd dataForType: t] length]);
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
	    [NSString stringWithUTF8String: typename]]) != nil){
	NSData *t = [pbd dataForType: type];
	if(t != nil){	// t should not be nil
	    int l = [t length];
	    void *d = (void *)[t bytes];
	    int c = 0;
	    while(l > 0){
		c = write(1, d, l>256?256:l);
		if(c>=0){
		    d += c;
		    l -= c;
		}else{
		    // write(2) failed
		    exit(-1);
		}
	    }
	}
    }else{
	return NO;
    }
    return YES;
}

// write n-th data in Pasteboard to stdout
BOOL
readNthData(NSPasteboard *pbd, int n)
{
    NSArray *types = [pbd types];

    if((n < 1) || ([types count] < n)){
	return FALSE;
    }

    NSData *t = [pbd dataForType: [types objectAtIndex: n -1]];
    if(t != nil){	// t should not be nil
	int l = [t length];
	void *d = (void *)[t bytes];
	int c = 0;
	while(l > 0){
	    c = write(1, d, l>256?256:l);
	    if(c>=0){
		d += c;
		l -= c;
	    }else{
		// write(2) failed
		exit(-1);
	    }
	}
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
	    [NSString stringWithUTF8String: typename]]) != nil){
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
    NSString *nm = [pbd name];
    if([nm isEqualToString: NSPasteboardNameGeneral]
	|| [nm isEqualToString: NSPasteboardNameFont]
	|| [nm isEqualToString: NSPasteboardNameRuler]
	|| [nm isEqualToString: NSPasteboardNameFind]
	|| [nm isEqualToString: NSPasteboardNameDrag]){
	(void)[pbd clearContents];
    }else{
#if DEBUG > 1
	NSLog(@"Clear Private Pasteboard: %s\n", [nm UTF8String]);
#endif
	(void)[pbd clearContents];
	(void)[pbd releaseGlobally];
    }
    return;
}

void
pbdcount(NSPasteboard *pbd, int verboseLevel)
{
    printf("%lu", (unsigned long)[[pbd types] count]);
    if(verboseLevel > 0)
       printf(" types are available");	
    printf("\n");
}
