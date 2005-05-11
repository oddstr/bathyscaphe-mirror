/**
  * $Id: CMRThreadMessageBufferReader.m,v 1.1 2005/05/11 17:51:04 tsawada2 Exp $
  * 
  * CMRThreadMessageBufferReader.m
  *
  * Copyright (c) 2003-2004 Takanori Ishikawa, All rights reserved.
  * See the file LICENSE for copying permission.
  */
#import "CMRThreadMessageBufferReader.h"
#import "CMRThreadMessageBuffer.h"
#import "CocoMonar_Prefix.h"
#import "CMRMessageComposer.h"
#import "CMRThreadMessage.h"



@implementation CMRThreadMessageBufferReader
+ (Class) resourceClass 
{
	return [CMRThreadMessageBuffer class];
}
- (CMRThreadMessageBuffer *) messageBuffer
{
	return [self fileContents];
}
- (unsigned int) numberOfMessages
{
	return [[self messageBuffer] count];
}
- (BOOL) composeNextMessageWithComposer : (id<CMRMessageComposer>) composer
{
	CMRThreadMessage	*message_;
	unsigned			index_ = [self nextMessageIndex];
	
	if ([self numberOfMessages] <= index_)
		return NO;
	
	message_ = [[self messageBuffer] messageAtIndex : index_];
	[composer composeThreadMessage : message_];
	[self incrementNextMessageIndex];
	return YES;
}
@end
