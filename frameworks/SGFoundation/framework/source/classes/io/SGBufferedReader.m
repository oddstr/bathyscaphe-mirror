/**
  * $Id: SGBufferedReader.m,v 1.1.1.1 2005/05/11 17:51:44 tsawada2 Exp $
  * 
  * SGBufferedReader.m
  *
  * Copyright (c) 2004, Takanori Ishikawa.
  * See the file LICENSE for copying permission.
  */
#import "SGBufferedReader.h"


/* tests malloc, realloc */
#define MEM_DEBUG    0


#if MEM_DEBUG
	#define kDEFAULT_INISIZE  1
	#define kTEXT_BUF_INILEN  1
	#define kTEXT_BUF_EXTLEN  1
#else
	#define kDEFAULT_INISIZE  256
	#define kTEXT_BUF_INILEN  248
	#define kTEXT_BUF_EXTLEN  64
#endif

/* working with text buffer */
/*
	the text buffer defined as:
	  uint16_t *m_txtBuf;
	
	I'd like to define buffer as only one pointer value,
	so it will be filled with data under following format:
	
	index  define           contents
	---------------------------------------------------------
	0 - 1  kTEXT_LEN_INDEX  buffer length (NOT include header length)
	2 - 3  kTEXT_NUM_INDEX  filled data, number of characters
	4 - 5  kTEXT_POS_INDEX  marker position (currently unused)
	6 - 7  (none)           reserved (currently unused)
	8 -    kTEXT_BUF_INDEX  actual buffer
*/
#define kTEXT_LEN_INDEX     0
#define kTEXT_NUM_INDEX     2
#define kTEXT_POS_INDEX     4
#define kTEXT_BUF_INDEX     8
// for 32bit purpose
#define kTEXT_LEN_INDEX32   0
#define kTEXT_NUM_INDEX32   1
#define kTEXT_POS_INDEX32   2

#define kTEXT_BUF_HEADLEN   8



@implementation SGBufferedReader
/***  PRIVATE ***/

#define TEXT_BUF32_AT(buf, idx)  (((uint32_t*)(buf))[(idx)])

- (uint16_t *) textBuffer
{
	if (NULL == m_txtBuf) {
		uint16_t  *buf;
		size_t    len = kTEXT_BUF_INILEN + kTEXT_BUF_HEADLEN;
		uint32_t  i32;
		
		NSAssert1(len > kTEXT_BUF_HEADLEN,
			@"buffer reqire at least %d length", kTEXT_BUF_HEADLEN);
		
		buf = malloc(len * sizeof(uint16_t));
		
		i32 = len - kTEXT_BUF_HEADLEN;
		TEXT_BUF32_AT(buf, kTEXT_LEN_INDEX32) = i32;
		TEXT_BUF32_AT(buf, kTEXT_NUM_INDEX32) = 0;
		TEXT_BUF32_AT(buf, kTEXT_POS_INDEX32) = 0;
		
		m_txtBuf = buf;
	}
	return m_txtBuf;
}
- (uint16_t *) textBufferEnough : (unsigned) extraLen
{
	uint16_t *buf = [self textBuffer];
	uint32_t len, n;
	size_t   minReq;
	
	NSAssert(buf != NULL, @"textBuffer must be not nil");
	len = TEXT_BUF32_AT(buf, kTEXT_LEN_INDEX32);
	NSAssert(len > 0, @"textBuffer len must be not 0");
	n = TEXT_BUF32_AT(buf, kTEXT_NUM_INDEX32);
	
	minReq = n + extraLen;
	if (minReq >= len) {  // more!
		uint16_t  *newp;
		size_t    len = kTEXT_BUF_INILEN + kTEXT_BUF_HEADLEN;
		uint32_t  i32;
		
		minReq += kTEXT_BUF_EXTLEN;
		minReq += kTEXT_BUF_HEADLEN;
		minReq += 8 - (minReq % 8);
		
#if MEM_DEBUG
		NSLog(
			@"textBuffer will be reallocated, "
			@"size: %u to %u", len, minReq);
#endif
		len = minReq;
		
		NSAssert1(len > kTEXT_BUF_HEADLEN,
			@"buffer reqire at least %d length", kTEXT_BUF_HEADLEN);
		
		newp = realloc(buf, len * sizeof(uint16_t));
		
		i32 = len - kTEXT_BUF_HEADLEN;
		TEXT_BUF32_AT(newp, kTEXT_LEN_INDEX32) = i32;
		
		m_txtBuf = newp;
		buf = [self textBuffer];
	}
	return buf;
}
- (void) setReader : (SGInputReader *) aReader
{
	[m_in autorelease];
	m_in = [aReader retain];
	
	m_pos = m_end = 0;
	if (m_txtBuf != NULL) {
		TEXT_BUF32_AT(m_txtBuf, kTEXT_NUM_INDEX32) = 0;
		TEXT_BUF32_AT(m_txtBuf, kTEXT_POS_INDEX32) = 0;
	}
	
	/* clear flags, scratch */
	m_nextc = 0;
	m_flags.hasNextC = 0;
	m_flags.nextEOF  = 0;
	m_flags.eof      = 0;
}
- (void) setUpWithReader : (SGInputReader *) aReader
			      length : (unsigned       ) aLength
{
	unsigned	len = aLength;
	
	if (0 == len) {
		len = kDEFAULT_INISIZE;
	}
	
	// force length to 8x
	NSAssert(len != 0, @"len must be not 0");
	len = len + (8 - (len % 8));

	m_buffer = malloc(sizeof(unichar) * len);
	m_length = len;
	
	[self setReader : aReader];
}
- (int) readPackNewline : (BOOL) shouldPack
{
	int c;
	
	if (m_flags.nextEOF) {
		return EOF;
	} else if (m_flags.hasNextC) {
		c = m_nextc;
		m_flags.hasNextC = 0;
		m_flags.nextEOF  = 0;
	} else {
		c = [super read];
	}
	
	if ('\r' == c && shouldPack) {
		int nextc = [super read];
		
		if (EOF == c) {
			m_flags.nextEOF  = 1;
			m_flags.hasNextC = 0;
		} else if (nextc != '\n') {
			/* store nextc */
			m_nextc = nextc;
			m_flags.hasNextC = 1;
			m_flags.nextEOF  = 0;
		}
		c = '\n';
	}
	
	m_flags.eof = (c == EOF);
	return c;
}

- (void) addc : (uint16_t) c
{
	uint16_t *buf = [self textBufferEnough : 1];
	uint32_t len, n;
	
	NSAssert(buf != NULL, @"textBuffer must be not nil");
	len = TEXT_BUF32_AT(buf, kTEXT_LEN_INDEX32);
	NSAssert(len > 0, @"textBuffer len must be not 0");
	n = TEXT_BUF32_AT(buf, kTEXT_NUM_INDEX32);
	
	(buf + kTEXT_BUF_INDEX)[n++] = c;
	TEXT_BUF32_AT(buf, kTEXT_NUM_INDEX32) = n;
}
- (uint16_t *) getbuf : (uint32_t *) bufferLength
{
	uint16_t	*p = [self textBuffer];
	uint32_t	n = TEXT_BUF32_AT(p, kTEXT_NUM_INDEX32);
	
	if (bufferLength != NULL) *bufferLength = n;
	return p + kTEXT_BUF_INDEX;
}
- (NSString *) gets : (BOOL) shouldCopy
{
	uint16_t	*p;
	uint32_t	n;
	
	p = [self getbuf : &n];
	NSAssert(p != NULL, @"getbuf must not return NULL");
	
	if (0 == n) {
		return @"";
	}
	return shouldCopy ? [NSString stringWithCharacters:p length:n]
			: [[[NSString alloc] initWithCharactersNoCopy : p
					length:n freeWhenDone:NO] autorelease];
}
- (BOOL) nextLine
{
	int c;
	
	if (m_flags.eof) {
		return NO;
	}
	
	TEXT_BUF32_AT([self textBuffer], kTEXT_NUM_INDEX32) = 0;
	while ((c = [self readPackNewline:YES]) != EOF) {
		if (c == '\n') {
			break;
		}
		[self addc : (unichar)c];
	}
	
	return YES;
}



/***  PUBLIC ***/
+ (id) readerWithReader : (SGInputReader *) aReader
{ return [[[self alloc] initWithReader:aReader] autorelease]; }
+ (id) readerWithReader : (SGInputReader *) aReader
                 length : (unsigned       ) aLength
{ return [[[self alloc] initWithReader:aReader length:aLength] autorelease]; }

- (id) init
{
	if (self = [super init]) {
		m_in = nil;
		m_buffer = m_txtBuf = NULL;
		m_pos = m_end = m_length = 0;
		[self setPackNewline : NO];
	}
	return self;
}
- (id) initWithReader : (SGInputReader *) aReader
{
	return [self initWithReader:aReader length:kDEFAULT_INISIZE];
}
- (id) initWithReader : (SGInputReader *) aReader
			   length : (unsigned       ) aLength
{
	if (self = [self init]) {
		[self setUpWithReader:aReader length:aLength];
	}
	return self;
}
- (void) dealloc
  {
	[m_in release];
	free(m_buffer);
	free(m_txtBuf);
	[super dealloc];
}

- (BOOL) packNewline
{
	return m_flags.packNewline != 0;
}
- (void) setPackNewline : (BOOL) flag
{
	m_flags.packNewline = (flag != NO);
}

- (int) read
{
	return [self readPackNewline : [self packNewline]];
}

- (int) read : (unichar  *) aBuffer
      length : (unsigned  ) aLength
autualLength : (unsigned *) autualLength
{
	unsigned len;
	
	if (nil == m_in) {
		goto RET_EOF;
	}
	if (m_end == m_pos) {
		int      ret;
		
		ret = [m_in read : m_buffer
				  length : m_length
			autualLength : &len];
		if (EOF == ret) {
			goto RET_EOF;
		}
		m_pos = 0;
		m_end = len;
	}
	
	len = aLength;
	if (len > (m_end - m_pos)) {
		len = (m_end - m_pos);
	}
	
	if (1 == len) {
		*aBuffer = m_buffer[m_pos++];
	} else {
		memcpy(aBuffer, m_buffer + m_pos , len * sizeof(unichar));
		m_pos += len;
	}
	if (autualLength != NULL) *autualLength = len;
	return 0;

RET_EOF:
	if (autualLength != NULL) *autualLength = 0;
	return EOF;
}

- (NSString *) readLine
{
	return [self nextLine] ? [self gets : YES] : nil;
}
- (NSString *) readLineNoCopy
{
	return [self nextLine] ? [self gets : NO] : nil;
}
- (NSString *) getLineNoCopy
{
	return (NULL == m_txtBuf) ? nil : [self gets : NO];
}
- (unichar *) readLineNoCopy : (unsigned *) bufferLength
{
	return [self nextLine] ? (unichar *)[self getbuf : (uint32_t*)bufferLength] : NULL;
}
- (unichar *) getLineNoCopy : (unsigned *) bufferLength
{
	return (NULL == m_txtBuf) ? NULL : (unichar *)[self getbuf : (uint32_t*)bufferLength];
}

@end
