/**
  * $Id: CMRThreadPlistComposer.h,v 1.1.1.1.4.1 2006/02/27 17:31:49 masakih Exp $
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
	BOOL				_AAThread;
}
+ (id) composerWithThreadsArray : (NSMutableArray *) threads;
+ (id) composerWithThreadsArray : (NSMutableArray *) threads noteAAThread : (BOOL) isAAThread;
- (id) initWithThreadsArray : (NSMutableArray *) threads;
@end
