/**
  * $Id: SGStringReader.m,v 1.1 2005/05/11 17:51:44 tsawada2 Exp $
  * 
  * SGStringReader.m
  *
  * Copyright (c) 2004, Takanori Ishikawa.
  * See the file LICENSE for copying permission.
  */
#import "SGStringReader.h"



@implementation SGStringReader
+ (id) readerWithString : (NSString *) aString
{ return [[self alloc] initWithString:aString]; }

- (id) init
{
	if (self = [super init]) {
		m_string = nil;
		m_pos = 0;
	}
	return self;
}
- (id) initWithString : (NSString *) aString
{
	if (self = [self init]) {
		m_string = [aString retain];
	}
	return self;
}
- (void) dealloc
{
	[m_string release];
	[super dealloc];
}
- (NSString *) string
{
	return m_string;
}

/* abstruct */
- (int) read : (unichar  *) aBuffer
      length : (unsigned  ) aLength
autualLength : (unsigned *) autualLength
{
	unsigned srcLength = [[self string] length];
	unsigned length    = aLength;
	
	if (m_pos >= srcLength) {
		goto RET_EOF;
	}
	if ((m_pos + length) > srcLength) {
		length -= ((m_pos + length) - srcLength);
	}
	
	[[self string] getCharacters : aBuffer
			range : NSMakeRange(m_pos, length)];
	m_pos += length;
	
	if (autualLength != NULL)
		*autualLength = length;
	
	return 0;
	
RET_EOF:
	if (autualLength != NULL) *autualLength = 0;
	return EOF;
}
@end
