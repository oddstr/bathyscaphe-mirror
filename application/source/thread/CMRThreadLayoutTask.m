//
//  CMRThreadLayoutTask.m
//  BathyScaphe
//
//  Updated by Tsutomu Sawada on 08/03/11.
//  Copyright 2005-2008 BathyScaphe Project. All rights reserved.
//  encoding="UTF-8"
//

#import "CMRThreadLayoutTask.h"
#import "CocoMonar_Prefix.h"
#import "CMRTaskManager.h"

@implementation CMRThreadLayoutConcreateTask
+ (id)task
{
	return [[[self alloc] init] autorelease];
}

+ (id)taskWithIndentifier:(id)anIdentifier
{
	id  obj;
	
	obj = [self task];
	[obj setIdentifier:anIdentifier];
	return obj;
}

- (id)init
{
	if (self = [super init]) {
		[self setIsInProgress:NO];
		[self setAmount:-1];
	}
	return self;
}

- (void)dealloc
{
	[self setMessage:nil];
	[self setIdentifier:nil];
	[self setLayout:nil];
	[super dealloc];
}

- (CMRThreadLayout *)layout
{
	return _layout;
}

- (void)setLayout:(CMRThreadLayout *)aLayout
{
	[aLayout retain];
	[_layout release];
	_layout = aLayout;
}

- (id)identifier
{
	return _identifier;
}

- (void)setIdentifier:(id)anIdentifier
{
	[anIdentifier retain];
	[_identifier release];
	_identifier = anIdentifier;	
}

- (void)postInterruptedNotification
{
	[[NSNotificationCenter defaultCenter] postNotificationName:CMRThreadTaskInterruptedNotification object:self];
}

- (void)executeWithLayout:(CMRThreadLayout *)layout
{
/*	[CMRMainMessenger target : [CMRTaskManager defaultManager]
		performSelector : @selector(addTask:)
			 withObject : self
			 withResult : YES];
	// 2008-02-18 */
	[[CMRTaskManager defaultManager] performSelectorOnMainThread:@selector(addTask:) withObject:self waitUntilDone:YES];
/*	[CMRMainMessenger postNotificationName : CMRTaskWillStartNotification
									object : self];
	// 2008-02-18 */
	NSNotification *notification = [NSNotification notificationWithName:CMRTaskWillStartNotification object:self];
	[[NSNotificationCenter defaultCenter] performSelectorOnMainThread:@selector(postNotification:) withObject:notification waitUntilDone:NO];
	[self setIsInProgress:YES];

	@try{
		[self doExecuteWithLayout:layout];
	}
	@catch(NSException *localException) {
		NSString		*name_ = [localException name];
		if ([CMRThreadTaskInterruptedException isEqualToString:name_]) {
			[self finalizeWhenInterrupted];
			// 
			// 別スレッドで実行されても問題ないかは
			// 受け取り側の処理に依存
			// 
/*			[[NSNotificationCenter defaultCenter]
				postNotificationName : CMRThreadTaskInterruptedNotification
							  object : self];
			// 2008-02-18 */
			[self postInterruptedNotification];
		} else {
			NSLog(@"%@ - %@", name_, localException);
		}
		// 例外が発生した場合はもう一度投げる。
		@throw;
	}
	@finally {
//		[self setDidFinished : YES];
		[self setIsInProgress:NO];
		[self setMessage:[self localizedString:@"Did Finish"]];
/*		[CMRMainMessenger postNotificationName : CMRTaskDidFinishNotification
										object : self];
		// 2008-02-18 */
		notification = [NSNotification notificationWithName:CMRTaskDidFinishNotification object:self];
		[[NSNotificationCenter defaultCenter] performSelectorOnMainThread:@selector(postNotification:) withObject:notification waitUntilDone:NO];
	}
}

- (void)doExecuteWithLayout:(CMRThreadLayout *)layout
{
	// subclass should override
}

- (void)finalizeWhenInterrupted
{
	// subclass should call super
	[self setMessage:[self localizedString:@"Cancel"]];
}

- (BOOL)isInterrupted
{
	return _isInterrupted;
}

- (void)setIsInterrupted:(BOOL)anIsInterrupted
{
	_isInterrupted = anIsInterrupted;
//	[self setDidFinished : YES];
}
/**
  * @exception CMRThreadTaskInterruptedException
  *            [self isInterrupted] == YESなら例外を発生
  */
- (void)checkIsInterrupted
{
	if ([self isInterrupted]) {
		[NSException raise:CMRThreadTaskInterruptedException format:[self identifier]];
	}
}
/*- (BOOL) didFinished
{
	return _didFinished;
}
- (void) setDidFinished : (BOOL) aDidFinished
{
	_didFinished = aDidFinished;
}
*/

- (void)run
{
	[self executeWithLayout:[self layout]];
}

#pragma mark CMRTask
- (NSString *)title
{
	return @"";
}
/*- (NSString *) messageInProgress
{
	return @"";
}*/
- (NSString *)message
{
	/*	if([self isInProgress]) 
	 return [self messageInProgress];
	 
	 if([self isInterrupted])
	 return [self localizedString : @"Cancel"];
	 
	 return [self localizedString : @"Did Finish"];*/
	//	return m_statusMsg;
	NSString *result;
	@synchronized(self) {
		result = [[m_statusMsg retain] autorelease];
	}
	return result;
}

- (void)setMessage:(NSString *)msg
{
@synchronized(self) {
	[msg retain];
	[m_statusMsg release];
	m_statusMsg = msg;
}
}

- (BOOL)isInProgress
{
//	return (NO == [self isInterrupted] && NO == [self didFinished]);
	return _isInProgress;
}

- (void)setIsInProgress:(BOOL)isInProgress
{
	_isInProgress = isInProgress;
}

- (double)amount
{
	return m_amount;
}

- (void)setAmount:(double)doubleValue
{
	m_amount = doubleValue;
}

- (IBAction)cancel:(id)sender
{
	[self setIsInterrupted:YES];
}

#pragma mark Localized Strings
+ (NSString *)localizableStringsTableName
{
	return @"CMRTaskDescription";
}
@end


@implementation CMRThreadClearTask
- (void)dealloc
{
	[self setDelegate:nil];
	[super dealloc];
}

- (id)delegate
{
	return _delegate;
}

- (void)setDelegate:(id)aDelegate
{
	_delegate = aDelegate;
}

- (NSString *)identifier
{
	return nil;
}

- (void)doExecuteWithLayout:(CMRThreadLayout *)layout
{
/*	[CMRMainMessenger target : layout
			 performSelector : @selector(doDeleteAllMessages)
				  withResult : YES];
	// 2008-02-18 */
	[layout performSelectorOnMainThread:@selector(doDeleteAllMessages) withObject:nil waitUntilDone:YES];
	[[self delegate] performSelectorOnMainThread:@selector(threadClearTaskDidFinish:) withObject:self waitUntilDone:YES];
}
@end
