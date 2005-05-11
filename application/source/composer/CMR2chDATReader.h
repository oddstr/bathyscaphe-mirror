/**
  * $Id: CMR2chDATReader.h,v 1.1.1.1 2005/05/11 17:51:04 tsawada2 Exp $
  * 
  * CMR2chDATReader.h
  *
  * Copyright (c) 2003, Takanori Ishikawa.
  * See the file LICENSE for copying permission.
  */
#import <Foundation/Foundation.h>
#import "CMRThreadContentsReader.h"



@interface CMR2chDATReader : CMRThreadContentsReader
{
	@private
	NSString		*_title;
	NSArray			*_lineArray;
	NSEnumerator	*_lineEnumerator;
}
- (NSString *) threadTitle;
- (NSDate *) firstMessageDate;
- (NSDate *) lastMessageDate;
@end
