/* mkfw.m */
/* Utility to make Wrapped Files out of data from stdin */
/* written by rok (CHOI Kyong-Rok) */
/* (C) 2007 by CHOI Kyong-Rok */
/* $Id: */

#import <Cocoa/Cocoa.h>
#include <stdio.h>
#include <sys/types.h>
#include <unistd.h>

#define BUFFSIZE 256

void
usage(char *n)
{
  printf("Usage: %s FILENAME\n", n);
  exit(1);
}

int
main(int argc, char *argv[])
{
  unsigned char buffer[BUFFSIZE];
  size_t len;
  int ret;
  
  if(argc != 2){
    usage(argv[0]);
  }

  NSAutoreleasePool *arp = [[NSAutoreleasePool alloc] init];
  NSMutableData *data = [[NSMutableData alloc] init];

  while((len = read(0, buffer, BUFFSIZE))){
    [data appendBytes: buffer length: len];
  }

  NSFileWrapper *fw = [[NSFileWrapper alloc] initWithSerializedRepresentation: data];

  ret = [fw writeToFile: [NSString stringWithCString: argv[1]]
	    atomically: YES
	    updateFilenames: YES];
  
  [fw release];
  [data release];
  [arp release];
  return ret;
}