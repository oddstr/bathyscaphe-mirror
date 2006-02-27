/**
  * $Id: SGInputReader.h,v 1.1.1.1.4.1 2006/02/27 17:31:50 masakih Exp $
  * 
  * SGInputReader.h
  *
  * Copyright (c) 2004, Takanori Ishikawa.
  * See the file LICENSE for copying permission.
  */

#import <Foundation/Foundation.h>
#import <SGFoundation/SGFoundationBase.h>



@interface SGInputReader : NSObject//SGBaseObject
/*!
 * @method     read
 * @discussion Read a character.
 *
 * @result     The character read, as an integer in the
 *             range 0 to 65535  (0x00-0xffff), or EOF
 *             if the end of stream has been reached.
 */
- (int) read;

/* abstruct method */
/*!
 * @method     read:length:autualLength:
 * @discussion Read characters into an buffer.
 *
 * @param aBuffer      unicode character buffer
 * @param length       length of buffer.
 * @param autualLength actual length readed.
 * @result             0, or EOF if the end of stream has been reached.
 */
- (int) read : (unichar  *) aBuffer
      length : (unsigned  ) aLength
autualLength : (unsigned *) autualLength;
@end
