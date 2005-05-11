/**
  * $Id: CMRThreadPlistComposer.h,v 1.1 2005/05/11 17:51:04 tsawada2 Exp $
  * 
  * CMRThreadPlistComposer.h
  *
  * Copyright (c) 2003-2004 Takanori Ishikawa, All rights reserved.
  * See the file LICENSE for copying permission.
  */
#import <Foundation/Foundation.h>
#import "CMRMessageComposer.h"



@interface CMRThreadPlistComposer : CMRMessageComposer
{
	@private
	NSMutableDictionary	*m_thread;
	NSMutableArray		*m_threadsArray;
}
+ (id) composerWithThreadsArray : (NSMutableArray *) threads;
- (id) initWithThreadsArray : (NSMutableArray *) threads;
@end
