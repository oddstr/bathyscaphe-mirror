/**
  * $Id: SGBufferedReader.h,v 1.1.1.1 2005/05/11 17:51:44 tsawada2 Exp $
  * 
  * SGBufferedReader.h
  *
  * Copyright (c) 2004, Takanori Ishikawa.
  * See the file LICENSE for copying permission.
  */

#import <Foundation/Foundation.h>
#import <SGFoundation/SGInputReader.h>

#import <stdint.h>



@interface SGBufferedReader : SGInputReader
{
	@private
	SGInputReader	*m_in;
	unichar			*m_buffer;
	uint16_t		*m_txtBuf;	/* internal text buffer */
	unsigned		m_pos;
	unsigned		m_end;
	unsigned		m_length;
	/* scratch buffer for packNewline */
	unichar			m_nextc;
	struct {
		unsigned char packNewline :1;	/* flag: CR, CRLF --> LF */
		unsigned char hasNextC    :1;	/* m_nextc set? */
		unsigned char nextEOF     :1;	/* m_nextc is EOF? */
		unsigned char eof         :1;	/* EOF readed? */
		unsigned char reserved    :4;	/* RESERVED */
	} m_flags;
}
+ (id) readerWithReader : (SGInputReader *) aReader;
+ (id) readerWithReader : (SGInputReader *) aReader
                 length : (unsigned       ) aLength;
- (id) initWithReader : (SGInputReader *) aReader;
- (id) initWithReader : (SGInputReader *) aReader
               length : (unsigned       ) aLength;

/*!
 * @method     read
 * @discussion Read a character. 
 *
 * @result     The character read, as an integer in the
 *             range 0 to 65535  (0x00-0xffff), or EOF
 *             if the end of stream has been reached.
 *
 *             auto convert CRLF, CR to LF, if packNewline was YES.
 */
- (int) read;

/*!
 * @method     packNewline
 * @discussion pack CRLF, CR to LF
 *
 * @result     if YES, [SGBufferedReader read] method 
 *             convert CRLF, CR to LF
 */
- (BOOL) packNewline;
- (void) setPackNewline : (BOOL) flag;

/*!
 * @method     readLine
 * @abstruct   Read a line of text
 * @discussion Read a line of text. A line is considered to be
 *             terminated by any one  of a CR, CRLF, LF.
 * @return     line, nil if stream was terminated.
 */
- (NSString *) readLine;
/*!
 * @method     readLineNoCopy
 * @abstruct   Read a line of text, return temporary object.
 * @discussion Same as readLine, but this method doesn't copy
 *             contents of internal buffer. so returned object
 *             will be temporary.
 * @return     line, nil if stream was terminated.
 */
- (NSString *) readLineNoCopy;
/* 
  access current internal buffer. and returns it as NSString. 
  You should invoke this method after readLine family 
*/
- (NSString *) getLineNoCopy;

/*!
 * @method     readLineNoCopy:
 * @abstruct   Read a line of text, return temporary buffer.
 * @discussion Same as readLine, but this method doesn't copy
 *             contents of internal buffer. return pointer
 *             to internal buffer and its length.
 *
 *             NOTE:
 *             An SGBufferedReader object doesn't use this buffer for its own job, 
 *             so modification of buffer contents is safe.
 *
 * @return     line, NULL if stream was terminated.
 */
- (unichar *) readLineNoCopy : (unsigned *) bufferLength;
/* access current internal buffer. You should invoke this method after readLine family */
- (unichar *) getLineNoCopy : (unsigned *) bufferLength;
@end
