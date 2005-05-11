/**
  * $Id: CMRThreadMessageBuffer.m,v 1.1 2005/05/11 17:51:04 tsawada2 Exp $
  * 
  * CMRThreadMessageBuffer.m
  *
  * Copyright (c) 2003-2004 Takanori Ishikawa, All rights reserved.
  * See the file LICENSE for copying permission.
  */
#import "CMRThreadMessageBuffer.h"
#import "CMRThreadMessage.h"
#import "CMRThreadVisibleRange.h"
#import "CocoMonar_Prefix.h"


@implementation CMRThreadMessageBuffer
+ (id) buffer
{
	return [[[self alloc] init] autorelease];
}
- (void) dealloc
{
	[_messages release];
	[super dealloc];
}

// NSObject
- (NSString *) description
{
	NSMutableString		*s;
	CMRThreadMessage	*m;
	
	s = [NSMutableString string];
	[s appendFormat : @"<%@ %p>\n",
		[self className], self];
	
	m = [self firstMessage];
	[s appendFormat : @"  index: %u - ", m ? [m index] : 0];
	m = [self lastMessage];
	[s appendFormat : @"%u\n", m ? [m index] : 0];
	
	return s;
}

- (SGBaseCArrayWrapper *) messagesMutableArray
{
	if (nil == _messages)
		_messages = [[SGBaseCArrayWrapper alloc] init];
	
	return _messages;
}
- (NSArray *) messages
{
	return [self messagesMutableArray];
}
- (unsigned) count
{
	return [[self messages] count];
}
- (CMRThreadMessage *) messageAtIndex : (unsigned) anIndex
{
	if (nil == _messages || anIndex >= SGBaseCArrayWrapperCount(_messages))
		return nil;
	
	return SGBaseCArrayWrapperObjectAtIndex(_messages, anIndex);
}
- (unsigned) indexOfMessage : (id) aMessage
{
	return [[self messages] indexOfObjectIdenticalTo : aMessage];
}
- (unsigned) indexOfMessageWithIndex : (unsigned) aMessageIndex
{
	NSEnumerator		*iter_ = [[self messages] objectEnumerator];
	CMRThreadMessage	*message_;
	unsigned			idx = 0;
	
	if (NSNotFound == aMessageIndex) return NSNotFound;
	while (message_ = [iter_ nextObject]) {
		if (aMessageIndex == [message_ index])
			return idx;
		idx++;
	}
	return NSNotFound;
}
- (BOOL) hasMessage : (id) aMessage
{
	return ([self indexOfMessage:aMessage] != NSNotFound);
}
- (CMRThreadMessage *) firstMessage;
{
	return [[self messages] head];
}
- (CMRThreadMessage *) lastMessage;
{
	return [[self messages] lastObject];
}
- (void) addMessagesFromArray : (NSArray *) anArray
{
	NSEnumerator		*iter_ = [anArray objectEnumerator];
	CMRThreadMessage	*message_;
	
	while (message_ = [iter_ nextObject])
		[self addMessage : message_];
}
- (BOOL) canAppend : (CMRThreadMessageBuffer *) other
{
	CMRThreadMessage	*myLast_;
	CMRThreadMessage	*othersFirst_;
	
	if (nil == other)
		return NO;
	
	if (0 == [self count] || 0 == [other count])
		return YES;
	
	myLast_ = [self lastMessage];
	othersFirst_ = [other firstMessage];
	
	if (nil == myLast_) return (othersFirst_ != nil);
	if (nil == othersFirst_) return YES;
	
	return ([myLast_ index] +1 == [othersFirst_ index]);
}
- (BOOL) addMessagesFromBuffer : (CMRThreadMessageBuffer *) otherBuffer
{
	if (NO == [self canAppend : otherBuffer])
		return NO;
	
	if ([otherBuffer count] > 0)
		[self addMessagesFromArray : [otherBuffer messages]];
	
	return YES;
}
- (void) addMessage : (CMRThreadMessage *) aMessage
{
	[[self messagesMutableArray] addObject : aMessage];
}
- (void) replaceMessages : (NSArray *) aMessages
{
	[[self messagesMutableArray] removeAllObjects];
	[self addMessagesFromArray : aMessages];
}

- (void) replaceMessages : (NSArray *) aMessages
		 margeAttributes : (BOOL     ) marge
{
	NSMutableArray		*newArray_  = nil;
	NSEnumerator		*myIter_    = nil;
	NSEnumerator		*otherIter_ = nil;
	CMRThreadMessage	*message_;
	
	if (NO == marge) {
		[self replaceMessages : aMessages];
		return;
	}
	
	newArray_  = [[NSMutableArray alloc] init];
	myIter_    = [[self messages] objectEnumerator];
	otherIter_ = [aMessages objectEnumerator];
	
	
	while (message_ = [otherIter_ nextObject]) {
		CMRThreadMessage			*oldOne_ = [myIter_ nextObject];
		CMRThreadMessageAttributes	*attributes_;
		
		attributes_ = [message_ messageAttributes];
		[attributes_ addAttributes : [oldOne_ messageAttributes]];
		
		[message_ setMessageAttributes : attributes_];
		[newArray_ addObject : message_];
	}
	
	[self replaceMessages : newArray_];
	[newArray_ release];
}
- (void) removeAll
{
	[[self messagesMutableArray] removeAllObjects];
}
- (void) changeAllMessageAttributes : (BOOL  ) onOffFlag
							  flags : (UInt32) mask
{
	NSEnumerator		*iter_;
	CMRThreadMessage	*m;
	
	iter_ = [[self messages] objectEnumerator];
	while (m = [iter_ nextObject]) {
		[m setMessageAttributeFlag:mask on:onOffFlag];
	}
}


// CMRMessageComposer
- (void) composeThreadMessage : (CMRThreadMessage *) message
{
	[self addMessage : message];
}
- (id) getMessages
{
	return [self messages];
}
@end



@implementation CMRThreadMessageBuffer (TemporaryInvisible)
- (void) setTemporaryInvisible : (BOOL   ) invisible
					   inRange : (NSRange) aRange
{
	SGBaseCArrayWrapper		*array_;
	CMRThreadMessage		*message_;
	unsigned				i;
	
	array_ = _messages;
	if (NSMaxRange(aRange) > [array_ count]) {
		[NSException raise : NSRangeException
					format : @"Attempt to range%@ bounds=%u",
							NSStringFromRange(aRange),
							[array_ count]];
	}
	
	for (i = 0; i < aRange.length; i++) {
		message_ = SGBaseCArrayWrapperObjectAtIndex(array_, aRange.location +i);
		[message_ setTemporaryInvisible : invisible];
	}
}
- (void) synchronizeVisibleRange : (CMRThreadVisibleRange *) visibleRange;
{
	CMRThreadVisibleRange	*vr_ = visibleRange;
	unsigned				count_;
	BOOL					invisible_;
	
	if (nil == vr_) return;
	UTILAssertNotNil(vr_);
	
	count_ = [self count];
	invisible_ = [vr_ isEmpty] ? YES : NO;
	[self setTemporaryInvisible : invisible_ 
		inRange : NSMakeRange(0, count_)];
	
	if ([vr_ isEmpty] || [vr_ isShownAll]) return;
	if ([vr_ visibleLength] >= count_) return;
	
	count_ = count_ - [vr_ lastVisibleLength] - [vr_ firstVisibleLength];
	[self setTemporaryInvisible : YES 
		inRange : NSMakeRange([vr_ firstVisibleLength], count_)];
}
@end
