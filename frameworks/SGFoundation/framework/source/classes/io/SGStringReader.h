/**
  * $Id: SGStringReader.h,v 1.1.1.1 2005/05/11 17:51:44 tsawada2 Exp $
  * 
  * SGStringReader.h
  *
  * Copyright (c) 2004, Takanori Ishikawa.
  * See the file LICENSE for copying permission.
  */

#import <Foundation/Foundation.h>
#import <SGFoundation/SGInputReader.h>



@interface SGStringReader : SGInputReader
{
	@private
	NSString	*m_string;
	unsigned	m_pos;
}
+ (id) readerWithString : (NSString *) aString;

- (id) initWithString : (NSString *) aString;
- (NSString *) string;
@end
