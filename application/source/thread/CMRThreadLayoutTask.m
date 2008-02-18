//:CMRThreadLayoutTask.m
/**
  *
  * @see CMRThreadLayout.h
  *
  * @author Takanori Ishikawa
  * @author http://www15.big.or.jp/~takanori/
  * @version 1.0.0d1 (03/01/19  9:38:50 AM)
  *
  */
#import "CMRThreadLayoutTask.h"
#import "CMXInternalMessaging.h"
#import "CMRTaskManager.h"



@implementation CMRThreadLayoutConcreateTask
+ (id) task
{
	return [[[self alloc] init] autorelease];
}
+ (id) taskWithIndentifier : (id) anIdentifier
{
	id  obj;
	
	obj = [self task];
	[obj setIdentifier : anIdentifier];
	return obj;
}
- (void) dealloc
{
	[_identifier release];
	[_layout release];
	[super dealloc];
}
- (CMRThreadLayout *) layout
{
	return _layout;
}
- (void) setLayout : (CMRThreadLayout *) aLayout
{
	id		tmp;
	
	tmp = _layout;
	_layout = [aLayout retain];
	[tmp release];
}
- (id) identifier
{
	return _identifier;
}
- (void) setIdentifier : (id) anIdentifier
{
	id		tmp;
	
	tmp = _identifier;
	_identifier = [anIdentifier retain];
	[tmp release];
}

- (void)postInterruptedNotification
{
	[[NSNotificationCenter defaultCenter] postNotificationName:CMRThreadTaskInterruptedNotification object:self];
}

- (void) executeWithLayout : (CMRThreadLayout *) layout
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
		NSString		*name_;
		
		name_ = [localException name];
		if([CMRThreadTaskInterruptedException isEqualToString : name_]){
			
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
		}else{
			NSLog(@"%@ - %@", name_, localException);
		}
		// 例外が発生した場合はもう一度投げる。
		@throw;
	}
	@finally {
//		[self setDidFinished : YES];
		[self setIsInProgress:NO];
/*		[CMRMainMessenger postNotificationName : CMRTaskDidFinishNotification
										object : self];
		// 2008-02-18 */
		notification = [NSNotification notificationWithName:CMRTaskDidFinishNotification object:self];
		[[NSNotificationCenter defaultCenter] performSelectorOnMainThread:@selector(postNotification:) withObject:notification waitUntilDone:NO];
	}
}
- (void) doExecuteWithLayout : (CMRThreadLayout *) layout
{
	// subclass...
}
- (void) finalizeWhenInterrupted
{
	// subclass...
}


- (BOOL) isInterrupted
{
	return _isInterrupted;
}
- (void) setIsInterrupted : (BOOL) anIsInterrupted
{
	_isInterrupted = anIsInterrupted;
//	[self setDidFinished : YES];
}
/**
  * @exception CMRThreadTaskInterruptedException
  *            [self isInterrupted] == YESなら例外を発生
  */
- (void) checkIsInterrupted
{
	if([self isInterrupted]){
		[NSException raise : CMRThreadTaskInterruptedException
					format : [self identifier]];
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

- (void) run
{
	[self executeWithLayout : [self layout]];
}

// CMRTask
- (NSString *) title
{
	return @"";
}
- (NSString *) messageInProgress
{
	return @"";
}
- (NSString *) message
{
	if([self isInProgress]) 
		return [self messageInProgress];
	
	if([self isInterrupted])
		return [self localizedString : @"Cancel"];
	
	return [self localizedString : @"Did Finish"];
}

- (BOOL) isInProgress
{
//	return (NO == [self isInterrupted] && NO == [self didFinished]);
	return _isInProgress;
}

- (void)setIsInProgress:(BOOL)isInProgress
{
	_isInProgress = isInProgress;
}

- (double) amount
{
	return -1;
}
- (IBAction) cancel : (id) sender
{
	[self setIsInterrupted : YES];
}

+ (NSString *) localizableStringsTableName
{
	return @"CMRTaskDescription";
}
@end


@implementation CMRThreadClearTask
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
}
@end
