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
- (void) executeWithLayout : (CMRThreadLayout *) layout
{
	NSException			*exception_ = nil;
	
	[CMRMainMessenger target : [CMRTaskManager defaultManager]
		performSelector : @selector(addTask:)
			 withObject : self
			 withResult : YES];
	[CMRMainMessenger postNotificationName : CMRTaskWillStartNotification
									object : self];
	
	NS_DURING
		
		[self doExecuteWithLayout : layout];
		
	NS_HANDLER
		NSString		*name_;
		
		name_ = [localException name];
		if([CMRThreadTaskInterruptedException isEqualToString : name_]){
			
			[self finalizeWhenInterrupted];
			// 
			// 別スレッドで実行されても問題ないかは
			// 受け取り側の処理に依存
			// 
			[[NSNotificationCenter defaultCenter]
				postNotificationName : CMRThreadTaskInterruptedNotification
							  object : self];
		}else{
			//
		}
		exception_ = [localException retain];
		
	NS_ENDHANDLER
	
	[self setDidFinished : YES];
	[CMRMainMessenger postNotificationName : CMRTaskDidFinishNotification
									object : self];

	// 
	// 例外が発生した場合はもう一度投げる。
	// 
	[[exception_ autorelease] raise];
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
	[self setDidFinished : YES];
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
- (BOOL) didFinished
{
	return _didFinished;
}
- (void) setDidFinished : (BOOL) aDidFinished
{
	_didFinished = aDidFinished;
}


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
	return (NO == [self isInterrupted] && NO == [self didFinished]);
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
- (NSString *) identifier
{
	return nil;
}
- (void) doExecuteWithLayout : (CMRThreadLayout *) layout
{
	[CMRMainMessenger target : layout
			 performSelector : @selector(doDeleteAllMessages)
				  withResult : YES];
}
@end
