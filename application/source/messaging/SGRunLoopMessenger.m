//: SGRunLoopMessenger.m
/**
  * $Id: SGRunLoopMessenger.m,v 1.1.1.1 2005/05/11 17:51:05 tsawada2 Exp $
  * 
  * Copyright (c) 2001-2003, Takanori Ishikawa.  All rights reserved.
  * See the file LICENSE for copying permission.
  */

#import "SGRunLoopMessenger.h"
#import "SGInternalMessenger_p.h"

static NSString *const kSGRunLoopMessengerInstanceKey = @"SGRunLoopMessengerInstanceAlreadyExists";


/*!
 * @function      sendPortMessageData
 * @abstract      指定したポートにデータを送信する。
 * @discussion    指定したポートにデータを送信する。
 *
 * @param  aData  送信データ
 * @param  aPort  送信ポート
 */
static BOOL sendPortMessageData(NSData *aData, NSPort *aPort)
{
	NSPortMessage		*portMessage_;
	BOOL				succeed_;
	
	UTILCAssertNotNil(aData);
	UTILCAssertNotNil(aPort);
	
	
	portMessage_ = [[NSPortMessage alloc] initWithSendPort : aPort
						receivePort : nil
						components : [NSArray arrayWithObject : aData]];
	
	succeed_ = [portMessage_ sendBeforeDate : [NSDate distantFuture]];
	[portMessage_ release];
	
	return succeed_;
}


@interface SGRunLoopMessenger (Private)
- (void) setSendPort : (NSPort *) aSendPort;
- (void) invalidateSendPort;
- (void) initializeSendPortWithRunLoop : (NSRunLoop *) aRunLoop;
- (void) registerNotificationObservers;
- (void) removeFromNotificationObservers;
@end




@implementation SGRunLoopMessenger
+ (id) currentMessenger
{
	id		instance_;
	
	instance_ = [[[NSThread currentThread] threadDictionary] 
						objectForKey : kSGRunLoopMessengerInstanceKey];
	
	if(nil == instance_)
		instance_ = [[self alloc] init];
	
	return instance_;
}
- (id) init
{
	NSMutableDictionary		*tdict_;
	id						instance_;
	
	tdict_ = [[NSThread currentThread] threadDictionary];
	instance_ = [tdict_ objectForKey : kSGRunLoopMessengerInstanceKey];
	if(instance_ != nil){
		[self release];
		return [instance_ retain];
	}
	
	if(self = [super init]){
		[self initializeSendPortWithRunLoop : [NSRunLoop currentRunLoop]];
		[tdict_ setObject : self
				   forKey : kSGRunLoopMessengerInstanceKey];
		[self registerNotificationObservers];
	}
	return self;
}

- (void) dealloc
{
	[self removeFromNotificationObservers];
	[self invalidateSendPort];
	[super dealloc];
}
- (NSPort *) sendPort
{
	UTILAssertNotNil(_sendPort);
	return _sendPort;
}

- (void) invalidate : (NSThread *) thread
{
	[[self retain] autorelease];
	[[thread threadDictionary] removeObjectForKey : kSGRunLoopMessengerInstanceKey];
	[self removeFromNotificationObservers];
	
	[self invalidateSendPort];
}
- (void) threadWillExit : (NSNotification *) notification
{
	NSThread		*thread = [notification object];
	id				registered_;
	
	registered_ = [[thread threadDictionary] 
						objectForKey : kSGRunLoopMessengerInstanceKey];
	if(registered_ == self )
		[self invalidate : thread];
	
}
- (void) portDidBecomeInvalid : (NSNotification *) notification
{
	if([notification object] == [self sendPort])
		[self invalidate : [NSThread currentThread]];
}

// 
// 送信
// 
- (void) invokeMessage : (NSInvocation *) anInvocation
            withResult : (BOOL          ) aResultFlag
{
	struct message_t	*message_;
	NSData				*data_;
	
	UTILAssertNotNilArgument(anInvocation, @"Invocation");
	
	message_ = SGBaseZoneMalloc(NULL, sizeof(struct message_t));
	NSAssert(message_, @"can't allocate memory.");
	
	// 送信が終わるまで保持しておく
	// 受信側が解放
	message_->invocation = [anInvocation retain];
	
	
	message_->resultLock = aResultFlag 
					? [[NSConditionLock alloc] initWithCondition : kNotReturnYet]
					: nil;
	
	/*data_ = (NSData*)CFDataCreateWithBytesNoCopy(
				kCFAllocatorDefault,
				(const UInt8 *)message_,
				sizeof(struct message_t),
				kCFAllocatorNull);
	[data_ autorelease];*/
	data_ = [NSData dataWithBytesNoCopy : message_
								 length : sizeof(struct message_t)
						   freeWhenDone : NO];

	[anInvocation retainArguments];
	if( NO == sendPortMessageData(data_, [self sendPort]) ){
		[NSException raise : SGInternalMessengerSendException
					format : @"An error occured trying to send the message"];
		return;
	}
	
	
	if(aResultFlag)
	{
		[message_->resultLock lockWhenCondition : kValueReturned];
		[message_->resultLock unlock];
		[message_->resultLock release];
		message_->resultLock = nil;
	}
	
	SGBaseZoneFree(NULL, message_, sizeof(struct message_t));
}

//
// NSPort Delegate 
//
// 受信
- (void) handlePortMessage : (NSPortMessage *) aPortMessage
{
	struct message_t	* message_;
	NSData				* data_;
	
	data_ = [[aPortMessage components] lastObject];
	message_ = (struct message_t*)[data_ bytes];
	
	[message_->invocation invoke];
	if(message_->resultLock)
	{
		[message_->resultLock lock];
		[message_->resultLock unlockWithCondition : kValueReturned];
	}
	[message_->invocation release];
}
@end



@implementation SGRunLoopMessenger (Private)
- (void) setSendPort : (NSPort *) aSendPort
{
	id		tmp;
	
	tmp = _sendPort;
	_sendPort = [aSendPort retain];
	[tmp release];
}
- (void) invalidateSendPort
{
	if(nil == _sendPort)
		return;
	
	[[self sendPort] removeFromRunLoop : [NSRunLoop currentRunLoop] 
					           forMode : NSDefaultRunLoopMode];
	[self setSendPort : nil];
}
- (void) initializeSendPortWithRunLoop : (NSRunLoop *) aRunLoop
{
	NSPort		*port_;
	
	UTILAssertNotNilArgument(aRunLoop, @"RunLoop");
	
	[self invalidateSendPort];
	if(nil == aRunLoop) return;
	
	port_ = [NSPort port];
	[self setSendPort : port_];
	
	[[self sendPort] setDelegate : self];
	[[self sendPort] scheduleInRunLoop : aRunLoop
					           forMode : NSDefaultRunLoopMode];
	
}

- (void) registerNotificationObservers
{
	NSNotificationCenter		*center_;
	
	center_ = [NSNotificationCenter defaultCenter];
	
	[center_ addObserver : self
				selector : @selector(threadWillExit:)
					name : NSThreadWillExitNotification
				  object : nil];
	[center_ addObserver : self
				selector : @selector(portDidBecomeInvalid:)
					name : NSPortDidBecomeInvalidNotification
				  object : [self sendPort]];
}
- (void) removeFromNotificationObservers
{
	NSNotificationCenter		*center_;
	
	center_ = [NSNotificationCenter defaultCenter];
	
	[center_ removeObserver : self
					   name : NSThreadWillExitNotification
				     object : nil];
	[center_ removeObserver : self
					   name : NSPortDidBecomeInvalidNotification
				     object : [self sendPort]];
	[center_ removeObserver : self];
}
@end
