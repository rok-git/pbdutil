/* pbdutil.m */
/* Utility to read/write Pasteboard */
/* written by rok (CHOI Kyong-Rok) */
/* (C) 2003 by CHOI Kyong-Rok */
/* $Id: pbdutil.m,v 1.11 2008/03/09 07:55:31 rok Exp $ */

#import <Cocoa/Cocoa.h>
#include <stdio.h>
#include <sys/types.h>
#include <sys/uio.h>
#include <unistd.h>

#define NORTFD

//typedef enum {in, out} inout;
void init();
void usage();
void listTypes(NSPasteboard *pbd, int verboseLevel);
BOOL writeDataForType(NSPasteboard *pbd, char *typename);
BOOL readDataForType(NSPasteboard *pbd, char *typename);
#ifndef NORTFD
BOOL readRTFD(NSPasteboard *pbd, char *path);
#endif
void pbdclear(NSPasteboard *pbd);
void pbdcount(NSPasteboard *pbd, int verboseLevel);

NSDictionary *pbTypes;

int
main(int argc, char *argv[])
{
    int verboseLevel = 0;
    char *typename = NULL;
    char *output = NULL;
    NSAutoreleasePool *arp = [[NSAutoreleasePool alloc] init];
    NSPasteboard *pbd = nil;
    enum {get, set, list, help, clear, count, getNth, none} what = none;
    char sw;

    init();	// setup pbTypes etc.

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
		typename = strdup(optarg);
		break;
	    case 'r':		// read from pasteboard
		what = get;
		typename = strdup(optarg);
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
		// *** NOT YET IMPLEMENTED ***
		what = getNth;
		break;
	    case 'n':
		pbd = [NSPasteboard pasteboardWithName:
			    [NSString stringWithCString: optarg]];
		break;
	    case 'o':
		output = strdup(optarg);
		break;
	    default:
		break;
	}
    }
    argc -= optind;
    argv += optind;

    if(pbd == nil)
	pbd  = [NSPasteboard generalPasteboard];

    switch(what){
	case help:
	    usage();
	    break;
	case get:
#ifndef NORTFD
	    if(!strcmp(typename, "rtfd")){
		if((output == NULL) || (readRTFD(pbd, output) != YES))
			usage();
	    }else{
#endif
		if(readDataForType(pbd, typename) != YES)
		    usage();	// TYPE typename not exists
#ifndef NORTFD
	    }
#endif
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
	case getNth:		// NOT YET IMPLREMENTED
	case list:		// Default Action
	default:
	    listTypes(pbd, verboseLevel);
	    break;
    }

    [arp release];
    if(typename)
	free(typename);
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
		NSURLPboardType,
		NSFilenamesPboardType,
		NSFontPboardType,
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
		@"url",
		@"path",
		@"font",
		nil]];
}

void usage()
{
    NSEnumerator *ke = [pbTypes keyEnumerator];
    NSString *k;
#ifndef NORTFD
    printf("Usage:	pbdutil [-n name] [-r type|-r rtfd -o FILE|-w type|-l[ -v[ -v[ -v]]]|-c]\n");
#else
    printf("Usage:	pbdutil [-n name] [-r type|-w type|-l[ -v[ -v[ -v]]]|-c]\n");
#endif
    printf("	(supported types:");
    while((k = [ke nextObject]) != nil){
	printf(" %s", [k UTF8String]);
    }
    printf(")\n");
    printf("	pbdutil -C\n");
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
			printf("\t%s", (char *)[k UTF8String]);
		    }else if(verboseLevel >= 1){
			printf("\n\t%s (%s)", (char *)[k UTF8String],
				[t UTF8String]);
		    }
		    if(verboseLevel >= 2){
			printf(" (size: %d bytes)",
			    [[pbd dataForType: t] length]);
		    }
		}
	    }
	}else{	// verboseLevel >= 3
	    printf("\n\t%s (size: %d)", [t UTF8String], [[pbd dataForType: t] length]);
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


#ifndef NORTFD
BOOL
readRTFD(NSPasteboard *pbd, char *path){
    NSString *type = [pbTypes objectForKey: @"rtfd"]; 
    NSData *t = [pbd dataForType: type];
    NSFileWrapper *fw = [[NSFileWrapper alloc] initWithSerializedRepresentation: t];
    [fw autorelease];
    return [fw writeToFile: [NSString stringWithCString: path]
	       atomically: YES
	       updateFilenames: YES];
}
#endif


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
    NSString *nm = [pbd name];
    if([nm isEqualToString: NSGeneralPboard]
	|| [nm isEqualToString: NSFontPboard]
	|| [nm isEqualToString: NSRulerPboard]
	|| [nm isEqualToString: NSFindPboard]
	|| [nm isEqualToString: NSDragPboard]){
	(void)[pbd declareTypes: nil owner: nil];
    }else{
#if DEBUG > 1
	NSLog(@"Clear Private Pasteboard: %s\n", [nm UTF8String]);
#endif
	(void)[pbd declareTypes: nil owner: nil];
	(void)[pbd releaseGlobally];
    }
    return;
}

void
pbdcount(NSPasteboard *pbd, int verboseLevel)
{
    printf("%d", [[pbd types] count]);
    if(verboseLevel > 0)
       printf(" types are available");	
    printf("\n");
}
