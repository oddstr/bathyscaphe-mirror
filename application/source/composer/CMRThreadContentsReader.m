/**
  * $Id: CMRThreadContentsReader.m,v 1.1.1.1 2005/05/11 17:51:04 tsawada2 Exp $
  * 
  * CMRThreadContentsReader.m
  *
  * Copyright (c) 2003-2004 Takanori Ishikawa, All rights reserved.
  * See the file LICENSE for copying permission.
  */
#import "CMRThreadContentsReader.h"
#import "CocoMonar_Prefix.h"
#import "CMRMessageComposer.h"



@implementation CMRThreadContentsReader
- (id) init
{
	if (self = [super init]) {
		[self setNextMessageIndex : NSNotFound];
	}
	return self;
}

- (unsigned int) nextMessageIndex;
{
	return _nextMessageIndex;
}
- (void) setNextMessageIndex : (int) aNextMessageIndex
{
	_nextMessageIndex = aNextMessageIndex;
}
- (void) incrementNextMessageIndex
{
	++_nextMessageIndex;
}
- (void) composeWithComposer : (id<CMRMessageComposer>) composer
{
	while ([self composeNextMessageWithComposer : composer]) {
		;
	}
}


/* subclass should do overriding */
- (CMRThreadVisibleRange *) visibleRange { return nil; }
- (unsigned int) numberOfMessages { return 0; }

- (BOOL) composeNextMessageWithComposer : (id<CMRMessageComposer>) composer
{
	UTILAbstractMethodInvoked;
	return NO;
}
- (NSDictionary *) threadAttributes
{
	return [NSDictionary empty];
}
@end
