/* mkfw.m */
/* Utility to make Wrapped Files out of data from stdin */
/* written by rok (CHOI Kyong-Rok) */
/* (C) 2007 by CHOI Kyong-Rok */
/* $Id: mkfw.m,v 1.4 2010/05/16 02:42:03 rok Exp rok $ */

#import <Cocoa/Cocoa.h>
#include <stdio.h>
#include <sys/types.h>
#include <unistd.h>

#define BUFFSIZE 256

NSAutoreleasePool *arp;

void
initialize()
{
    arp = [[NSAutoreleasePool alloc] init];
}

void
finalize()
{
    [arp release];
}

void
usage(char *n)
{
  printf("Usage: %s FILENAME\n", n);
  finalize();
  exit(1);
}

int
main(int argc, char *argv[])
{
  unsigned char buffer[BUFFSIZE];
  size_t len;
  int ret;
  NSError *err;

  initialize();
  
  if(argc != 2){
    usage(argv[0]);
  }

  NSMutableData *data = [[NSMutableData alloc] init];

  while((len = read(0, buffer, BUFFSIZE))){
    [data appendBytes: buffer length: len];
  }

  NSFileWrapper *fw = [[NSFileWrapper alloc] initWithSerializedRepresentation: data];

  ret = [fw writeToURL: 
	    [NSURL fileURLWithPath: [NSString stringWithUTF8String: argv[1]] isDirectory: NO] 
	    options: NSFileWrapperWritingAtomic | NSFileWrapperWritingWithNameUpdating
	    originalContentsURL: nil
	    error: &err]; 
  [fw release];
  [data release];

  finalize();
  return ret;
}
