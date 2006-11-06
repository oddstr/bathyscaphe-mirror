/**
  * $Id: CMRThreadComposingTask.m,v 1.2.4.1 2006/11/06 13:24:45 tsawada2 Exp $
  * 
  * CMRThreadComposingTask.m
  *
  * Copyright (c) 2003, Takanori Ishikawa.
  * See the file LICENSE for copying permission.
  */
#import "CMRThreadComposingTask_p.h"
#import "CMRThreadMessageBuffer.h"
#import "CMRThreadMessage.h"
#import "CMRAttributedMessageComposer.h"
#import "CMRThreadContentsReader.h"


#define DEBUG_COMPOSING_TIME	0
#define MARKED_RANGE_LENGTH		5

NSString *const CMRThreadComposingDidFinishNotification = @"CMRThreadComposingDidFinishNotification";
NSString *const CMRThreadComposingCallbackNotification = @"CMRThreadComposingCallbackNotification";



@implementation CMRThreadComposingTask
+ (id) taskWithThreadReader : (CMRThreadContentsReader *) aReader
{
	return [[[self alloc] initWithThreadReader : aReader] autorelease];
}
- (id) init
{
	if (self = [super init]) 
		[self setCallbackIndex : NSNotFound];
	
	return self;
}
- (id) initWithThreadReader : (CMRThreadContentsReader *) aReader
{
	if (self = [self init]) 
		[self setReader : aReader];
	
	return self;
}
- (void) dealloc
{
	[_threadTitle release];
	[_reader release];
	_delegate = nil;
//	[_delegate release];
	[super dealloc];
}

// CMRTask:
- (NSString *) threadTitle
{
	return (_threadTitle != nil) 
		? _threadTitle
		: [[[self reader] threadAttributes] objectForKey : CMRThreadTitleKey];
}

- (void) setThreadTitle : (NSString *) aThreadTitle
{
	id		tmp;
	
	tmp = _threadTitle;
	_threadTitle = [aThreadTitle retain];
	[tmp release];
}
- (NSString *) titleFormat
{
	return [self localizedString : @"%@ Converting..."];
}
- (NSString *) title
{
	return (nil == [self titleFormat]) ? [self threadTitle]
			: [NSString stringWithFormat : 
				[self titleFormat],
				[self threadTitle]];
}
- (NSString *) messageFormat;
{
	return [self localizedString : @"Now Converting..."];
}
- (NSString *) messageInProgress;
{
	return (nil == [self messageFormat])
			? [self title]
			: [NSString stringWithFormat : 
					[self messageFormat], [self threadTitle]];
}

- (double) amount
{
	return (0 == _didComposedCount || 0 == _willComposeLength)
			? -1
			: (double)_didComposedCount / _willComposeLength * 100.0;
}
- (unsigned int) callbackIndex
{
	return _callbackIndex;
}
- (void) setCallbackIndex : (unsigned int) aCallbackIndex
{
	_callbackIndex = aCallbackIndex;
}

- (void) postCallbackIndexNotification
{
	[self checkIsInterrupted];
	if ([self callbackIndex] != NSNotFound) {
		[CMRMainMessenger postNotificationName : 
					CMRThreadComposingCallbackNotification
							object : self];
		[self setCallbackIndex : NSNotFound];
	}
	[self checkIsInterrupted];
}
// 追加して、バッファを消去
- (void) performsAppendingTextFromBuffer : (NSMutableAttributedString *) aTextBuffer
{
	[self checkIsInterrupted];
	if (aTextBuffer && [aTextBuffer length]) {
		
		[aTextBuffer fixAttributesInRange : [aTextBuffer range]];
		[CMRMainMessenger target : [[self layout] textStorage]
				 performSelector : @selector(appendAttributedString:)
					  withObject : aTextBuffer
					  withResult : YES];
		[aTextBuffer deleteCharactersInRange : [aTextBuffer range]];
	}
	[self checkIsInterrupted];
}

- (void) synchronizeTemporaryInvisible : (CMRThreadMessageBuffer *) aBuffer
{
	NSRange		markedRange_   = kNFRange;
	unsigned	index_ = [self callbackIndex];
	
	[aBuffer synchronizeVisibleRange : [[self reader] visibleRange]];
	index_ = [aBuffer indexOfMessageWithIndex : index_];
	if (NSNotFound == index_) return;
	
	if (NO == [[aBuffer messageAtIndex : index_] isTemporaryInvisible])
		return;
	
	markedRange_.location = index_;
	markedRange_.location = (markedRange_.location > MARKED_RANGE_LENGTH)
			? markedRange_.location - MARKED_RANGE_LENGTH
			: 0;
	markedRange_.length = MARKED_RANGE_LENGTH *2;
	markedRange_ = NSIntersectionRange(markedRange_, NSMakeRange(0, [aBuffer count]));
	
	[aBuffer setTemporaryInvisible:NO inRange:markedRange_];
	
#if 0
	UTILMethodLog;
	UTILDescUnsignedInt(index_);
	UTILDescRange(markedRange_);
#endif
}

- (id) delegate
{
	return _delegate;
}
- (void) setDelegate : (id) aDelegate
{
	//[aDelegate retain];
	//[_delegate release];

	_delegate = aDelegate;
}
- (BOOL) delegate_willCompleteMessages : (CMRThreadMessageBuffer *) aMessageBuffer
{
	id		delegate_ = [self delegate];
	
	if (delegate_ && [delegate_ respondsToSelector:@selector(threadComposingTask:willCompleteMessages:)])
	{
		return [delegate_ threadComposingTask:self willCompleteMessages:aMessageBuffer];
	}
	
	return YES;
}
- (void) doExecuteWithLayoutImp : (CMRThreadLayout *) theLayout
{
	CMRThreadMessageBuffer			*buffer_;
	CMRThreadContentsReader			*reader_;
	NSMutableAttributedString		*textBuffer_;
	CMRAttributedMessageComposer	*composer_;
	NSEnumerator					*iter_;
	CMRThreadMessage				*m;
	
	unsigned int	ellipsisIndex = NSNotFound;
	unsigned int	nMessages_ = [theLayout numberOfReadedMessages];
	NSTextStorage	*textStorage_ = [theLayout textStorage];
	unsigned		textLength_ = [textStorage_ length];
	NSRange			mesRange_;
	
	buffer_ = [[CMRThreadMessageBuffer alloc] init];
	reader_ = [[self reader] retain];
	UTILAssertNotNil(reader_);
	
	// compose message chain
	[reader_ composeWithComposer : buffer_];
	if (0 == nMessages_)
		[self synchronizeTemporaryInvisible : buffer_];
	
	// Delegate
	if (NO == [self delegate_willCompleteMessages : buffer_]) {
		[reader_ release];
		[buffer_ release];
		
		// cancel: raise exception.
		[self setIsInterrupted : YES];
		[self checkIsInterrupted];
	}
	
	[theLayout addMessagesFromBuffer : buffer_];
	
	// compose text storage
	composer_ = [[CMRAttributedMessageComposer alloc] init];
	textBuffer_ = [[NSMutableAttributedString alloc] init];
	[composer_ setContentsStorage : textBuffer_];
	
	iter_ = [[buffer_ messages] objectEnumerator];
	_didComposedCount = 0;
	while (m = [iter_ nextObject]) {
		_didComposedCount++;
		
		/* 省略されたレス */
		if ([m isTemporaryInvisible]) {
			if (NSNotFound == ellipsisIndex) {
				ellipsisIndex = [m index];
			}
		} else {
			if (ellipsisIndex != NSNotFound) {
				[theLayout insertEllipsisProxyAttachment:textBuffer_ 
					atIndex:[textBuffer_ length]
					fromIndex:ellipsisIndex toIndex:[m index]-1];
			}
			ellipsisIndex = NSNotFound;
		}
		
		mesRange_ = NSMakeRange([textBuffer_ length], 0);
		[composer_ composeThreadMessage : m];
		mesRange_.length = [textBuffer_ length] - mesRange_.location;
		/* 範囲を補正、 addMessageRange: は直列化されている */
		mesRange_.location += textLength_;
		[theLayout addMessageRange : mesRange_];
		/* 一定のレス数毎にレイアウト */
		if (0 == (_didComposedCount % NMESSAGES_PER_LAYOUT)) {
			[self performsAppendingTextFromBuffer : textBuffer_];
			textLength_ = [textStorage_ length];
			// コールバック
//			if ([m index] >= [self callbackIndex])
//				[self postCallbackIndexNotification];
		}
	}
	
	if (ellipsisIndex != NSNotFound) {
		[theLayout insertEllipsisProxyAttachment:textBuffer_ 
			atIndex:[textBuffer_ length]
			fromIndex:ellipsisIndex toIndex:[[buffer_ lastMessage] index]];
	}
	[self performsAppendingTextFromBuffer : textBuffer_];
//	[self postCallbackIndexNotification];
	
	
	[CMRMainMessenger postNotificationName : CMRThreadComposingDidFinishNotification
									object : self];
	[textBuffer_ release];
	[composer_ release];
	[reader_ release];
	[buffer_ release];
}

- (void) doExecuteWithLayout : (CMRThreadLayout *) theLayout
{
#if DEBUG_COMPOSING_TIME
	NSDate			*before;
	NSTimeInterval	elapsed;
	before = [NSDate date];
#endif
	
	[self doExecuteWithLayoutImp : theLayout];

#if DEBUG_COMPOSING_TIME
	elapsed = [[NSDate date] timeIntervalSinceDate : before];
	NSLog(@"used %.2f seconds", elapsed);
#endif
}

- (CMRThreadContentsReader *) reader
{
	return _reader;
}
- (void) setReader : (CMRThreadContentsReader *) aReader
{
	id		tmp;
	
	tmp = _reader;
	_reader = [aReader retain];
	[tmp release];
}
@end
