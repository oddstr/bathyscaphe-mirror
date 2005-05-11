/**
  * $Id: TestSGBufferedReader.m,v 1.1 2005/05/11 17:51:46 tsawada2 Exp $
  * 
  * TestSGBufferedReader.m
  *
  * Copyright (c) 2004, Takanori Ishikawa.
  * See the file LICENSE for copying permission.
  */
#import "TestSGBufferedReader.h"
#import <SGFoundation/SGFoundation.h>
#import "UTILKit.h"


@implementation TestSGBufferedReader
- (void) testInit
{
	SGStringReader		*srd;
	SGBufferedReader	*bufrd;
	
	srd = [[SGStringReader alloc] initWithString : @"test"];
	bufrd = [[SGBufferedReader alloc] initWithReader : srd];
	
	[self assertNotNil:bufrd];
	[self assertFalse:[bufrd packNewline]];
}
- (void) testRead
{
	SGStringReader 		*srd;
	SGBufferedReader	*bufrd;
	NSString *s = @"test";
	int i;
	
	srd = [SGStringReader readerWithString : s];
	bufrd = [SGBufferedReader readerWithReader : srd];
	for (i = 0; i < [s length]; i++) {
		[self assertInt:[bufrd read] equals:[s characterAtIndex:i]];
	}
	[self assertInt:[bufrd read] equals:EOF];
}
- (void) testReadNewline
{
	SGStringReader 		*srd;
	SGBufferedReader	*bufrd;
	NSString *s = @"\n\r\n\r\r\n";
	int c;
	
	srd = [SGStringReader readerWithString : s];
	bufrd = [SGBufferedReader readerWithReader : srd];
	[bufrd setPackNewline : YES];
	while ((c = [bufrd read]) != EOF) {
		[self assertInt:c equals:'\n'];
	}
}
- (void) testReadLength
{
#define BUFLEN 5

	SGStringReader *srd;
	SGBufferedReader	*bufrd;
	NSString *s = @"This is a test, string, string, string...";
	int i, ret;
	unsigned len;
	unichar buf[BUFLEN];
	int cidx = 0;
	
	
	srd = [SGStringReader readerWithString : s];
	bufrd = [SGBufferedReader readerWithReader:srd length:3];
	
	while ((ret = [bufrd read:buf length:BUFLEN autualLength:&len]) != EOF) {
		[self assertInt:ret equals:0];
		[self assertFalse:(len==0)];
		for (i = 0; i < len; i++) {
			[self assertInt:buf[i] 
				equals:[s characterAtIndex:cidx]
				format:@"expected:%c but:%d", 
					[s characterAtIndex:cidx],
					buf[i]];
			cidx++;
		}
	}
	[self assertInt:[bufrd read:buf length:4 autualLength:&len]
		  equals:EOF];
	[self assertInt:len equals:0];
}
- (void) testReadLine
{
	SGStringReader	 *srd;
	SGBufferedReader *bufrd;
	NSString *s = @"line1\nline2\rline3\r\nline4";
	int i = 1;
	NSString *line;
	
	srd = [SGStringReader readerWithString : s];
	bufrd = [SGBufferedReader readerWithReader:srd length:3];
	
	while (line = [bufrd readLine]) {
		[self assertString:line
		equals:[NSString stringWithFormat:@"line%d",i]];
		i++;
	}
	[self assertInt:i equals:5];
}
- (void) testReadLineNoCopy
{
	SGStringReader	 *srd;
	SGBufferedReader *bufrd;
	NSString *s = @"line";
	NSString *line;
	
	srd = [SGStringReader readerWithString : s];
	bufrd = [SGBufferedReader readerWithReader:srd length:3];
	
    line = [bufrd readLine];
    [self assertString : line
          equals : @"line"];
    [self assertNotNil : [bufrd getLineNoCopy]];
    
}
@end
