/**
  * $Id: CMRThreadMessageBuffer.h,v 1.1.1.1 2005/05/11 17:51:04 tsawada2 Exp $
  * 
  * CMRThreadMessageBuffer.h
  *
  * Copyright (c) 2003-2004 Takanori Ishikawa, All rights reserved.
  * See the file LICENSE for copying permission.
  */
#import <Foundation/Foundation.h>
#import "CMRMessageComposer.h"

@class CMRThreadMessage;
@class CMRThreadVisibleRange;
@class SGBaseCArrayWrapper;


@interface CMRThreadMessageBuffer : CMRMessageComposer
{
	@private
	SGBaseCArrayWrapper	*_messages;
}
+ (id) buffer;

// Querying the messages
- (NSArray *) messages;
- (unsigned) count;

- (unsigned) indexOfMessage : (id) aMessage;
- (unsigned) indexOfMessageWithIndex : (unsigned) aMessageIndex;
- (BOOL) hasMessage : (id) aMessage;

- (CMRThreadMessage *) firstMessage;
- (CMRThreadMessage *) lastMessage;
- (CMRThreadMessage *) messageAtIndex : (unsigned) anIndex;

/* returns NO, if index was not sequancial. */
- (BOOL) canAppend : (CMRThreadMessageBuffer *) other;
- (BOOL) addMessagesFromBuffer : (CMRThreadMessageBuffer *) aSource;

- (void) addMessage : (CMRThreadMessage *) aMessage;
- (void) replaceMessages : (NSArray *) aMessages;
- (void) replaceMessages : (NSArray *) aMessages
		 margeAttributes : (BOOL     ) marge;

- (void) removeAll;

- (void) changeAllMessageAttributes : (BOOL  ) onOffFlag
							  flags : (UInt32) mask;
@end



@interface CMRThreadMessageBuffer (TemporaryInvisible)
- (void) setTemporaryInvisible : (BOOL   ) invisible
					   inRange : (NSRange) aRange;
- (void) synchronizeVisibleRange : (CMRThreadVisibleRange *) visibleRange;
@end
