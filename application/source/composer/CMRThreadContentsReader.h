/**
  * $Id: CMRThreadContentsReader.h,v 1.1.1.1 2005/05/11 17:51:04 tsawada2 Exp $
  * 
  * CMRThreadContentsReader.h
  *
  * Copyright (c) 2003, Takanori Ishikawa.
  * See the file LICENSE for copying permission.
  */
#import <Foundation/Foundation.h>
#import <CocoMonar/CocoMonar.h>

@class    CMRThreadVisibleRange;
@protocol CMRMessageComposer;



@interface CMRThreadContentsReader : CMRResourceFileReader
{
	@private
	unsigned int _nextMessageIndex;
}
/* subclass should do overriding */
- (unsigned int) numberOfMessages;
- (BOOL) composeNextMessageWithComposer : (id<CMRMessageComposer>) composer;

- (NSDictionary *) threadAttributes;
- (CMRThreadVisibleRange *) visibleRange;

/* index is 0-based */
- (unsigned int) nextMessageIndex;
- (void) setNextMessageIndex : (int) aNextMessageIndex;
- (void) incrementNextMessageIndex;
- (void) composeWithComposer : (id<CMRMessageComposer>) composer;
@end
