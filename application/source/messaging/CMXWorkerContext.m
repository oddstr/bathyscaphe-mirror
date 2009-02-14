//: CMXWorkerContext.m
/**
  * $Id: CMXWorkerContext.m,v 1.2 2009/02/14 18:46:15 tsawada2 Exp $
  * 
  * Copyright (c) 2001-2003, Takanori Ishikawa.  All rights reserved.
  * See the file LICENSE for copying permission.
  */

#import "CMXWorkerContext.h"
//#import "CMXInternalMessaging.h"
//#import "CMXInternalMessaging_p.h"

#import <AppKit/NSApplication.h>


// for debugging only
#define UTIL_DEBUGGING		0
#import "UTILDebugging.h"



NSString *const CMRThreadTaskInterruptedException    = @"CMRThreadTaskInterruptedException";
NSString *const CMRThreadTaskInterruptedNotification = @"CMRThreadTaskInterruptedNotification";

enum {
	kWorkQueueEmpty,
	kWorkQueueHasWork
};



@interface CMRDummyTask : NSObject<CMXRunnable>
+ (id) dummy;
@end



@implementation CMRDummyTask
+ (id) dummy
{
	return [[[self alloc] init] autorelease];
}
- (void) run{;}
- (void) cancel : (id) sender{;}
@end



@interface CMXWorkerContext(WorkManagement)
- (NSConditionLock *) queueLock;
- (NSLock *) workingLock;

- (id<SGBaseQueue>) workQueue;
- (id<CMXRunnable>) nextWork;

- (NSLock *) workLock;
- (id<CMXRunnable>) work;
- (void) setWork : (id<CMXRunnable>) aWork;
@end



@implementation CMXWorkerContext
- (id) initWithUsingDrawingThread : (BOOL) usesDrawingThread
{
	if (self = [self init]) {
		_usesDrawingThread = usesDrawingThread;
	}
	return self;
}
- (id) init
{
	
	if (self = [super init]) {
		int		condition_;
		
		//
		// 状態ロック
		//
		condition_ = ([[self workQueue] isEmpty])
						? kWorkQueueEmpty
						: kWorkQueueHasWork;
		_queueLock = [[NSConditionLock alloc] 
						initWithCondition : condition_];
		
		_workingLock = [[NSLock alloc] init];
		
		// 
		// 同期ロック
		//
		_workLock = [[NSLock alloc] init];
	}
	return self;
}

- (void) dealloc
{
	UTIL_DEBUG_WRITE2(@"- dealloc<%@ %p>", [self className], self);
	
	[self removeAll : nil];
	[self setWork : nil];
	
	[_workQueue release];
	[_workLock release];
	[_queueLock release];
	[_workingLock release];
	[_work release];
	
	[super dealloc];
}

- (BOOL) usesDrawingThread
{
	return _usesDrawingThread;
}

- (void) run
{
	UTIL_DEBUG_WRITE3(
		@"+ start new worker thread<%p> using +[%@ %@]", 
		self,
		NSStringFromClass([self usesDrawingThread]
							? [NSApplication class]
							: [NSThread class]),
		NSStringFromSelector([self usesDrawingThread]
							? @selector(detachDrawingThread:toTarget:withObject:)
							: @selector(detachNewThreadSelector:toTarget:withObject:)) );
	
	if ([self usesDrawingThread]) {
		[NSApplication detachDrawingThread : @selector(start:)
								  toTarget : self
							    withObject : nil];
	} else {
		[NSThread detachNewThreadSelector : @selector(start:)
								 toTarget : self
							   withObject : nil];
	}
}
- (void) start : (id) sender
{
	NSAutoreleasePool		*myPool_ = [[NSAutoreleasePool alloc] init];
	
	// --------- Setup Worker Thread ----------
	
	_toBeContinued = YES;
	
	// ----------------------------------------
	
	while (_toBeContinued) {
		
		id<CMXRunnable>			work_		= nil;
		NSException				*exception_	= nil;
		NSAutoreleasePool		*pool_		= [[NSAutoreleasePool alloc] init];
		
		UTIL_DEBUG_WRITE1(@"+ Wait for next task...<%p>", self);
		
		// 
		// 次のタスクが来るまで待機
		// 次のタスクが来た場合はすでに現在に
		// タスクとして - [self setWork:]されている。
		// 
		work_ = [self nextWork];
		NSAssert(
			[self work] != nil && [[self work] isEqual : work_],
			@"[self work] must be not nil, or equal to current.");
		
		
		UTIL_DEBUG_WRITE2(@"+  new task has arrived.\n\t worker=<%p> task=%@",
				self,
				work_);
		
		NS_DURING
			
			[self retain];
			[[self workingLock] lock];
			[work_ run];
			[self autorelease];
			
		NS_HANDLER
			
			exception_ = 
				[[localException name] isEqualToString :
							CMRThreadTaskInterruptedException]
					? nil
					: [[localException retain] autorelease];
			
		NS_ENDHANDLER
		
		// --------- Finish Work ---------
		UTIL_DEBUG_WRITE2(
			@"+  task has been finished.\n\t worker=<%p> task=%@",
			self, work_);
		
		[[self workingLock] unlock];
		[self setWork : nil];
		
		if (exception_ != nil) {
			NSLog(@"***EXCEPTION*** WorkerThread %@\n"
				  @"  exception<%@> = %@",
					[self description],
					[exception_ name],
					[exception_ description]);
			NSBeep();
			
			//
			// ここで投げても捕まえる
			// ハンドラはない。
			// 
			/* [exception_ raise]; */
		}
		
		[pool_ release];
		
	}	// loop end
	
	UTIL_DEBUG_WRITE1(@"+ See you.<%p>", self);
	// --------- Worker Thread Exit ----------
	
	[myPool_ release];
}
- (void) push : (id<CMXRunnable>) aWork
{
	if (nil == aWork) return;
	
	[[self queueLock] lock];
	[[self workQueue] put : aWork];
	[[self queueLock] unlockWithCondition : kWorkQueueHasWork];
}

- (BOOL) isInProgress
{
	BOOL	isInProgress_ = YES;
	
	if ([[self workQueue] isEmpty]) {
		[[self queueLock] lock];
		if ([[self workQueue] isEmpty]) {
			if ([[self workingLock] tryLock]) {
				[[self workingLock] unlock];
				isInProgress_ = NO;
			}
		}
		[[self queueLock] unlock];
	}
	
	return isInProgress_;
}



- (void) cancel : (id) sender
{
	if (NO == _toBeContinued)
		return;
	
	UTIL_DEBUG_METHOD;
	UTIL_DEBUG_WRITE1(@"  Cancel %@", [self work]);
	[[self work] cancel : sender];
	
/*
	Since active work uses port connection to 
	internal messaging (worker thread --> main thread),
	thread blocking causes dead lock.
*/	
#if 0
	[[self workingLock] lock];
	[[self workingLock] unlock];
#endif
}
- (void) shutdown : (id) sender
{
	if (NO == _toBeContinued)
		return;
	
	UTIL_DEBUG_METHOD;
	_toBeContinued = NO;
	[self removeAll : sender];
	[self push : [CMRDummyTask dummy]];
}

- (void) removeAll : (id) sender
{
	UTIL_DEBUG_METHOD;
	[[self queueLock] lock];
	while ([[self workQueue] take]) {
		;
	}
	[self cancel : sender];
	NSAssert([[self workQueue] isEmpty], @"workQueue must be empty");
	[[self queueLock] unlockWithCondition : kWorkQueueEmpty];
}
@end



@implementation CMXWorkerContext(WorkManagement)
- (NSConditionLock *) queueLock
{
	UTILAssertNotNil(_queueLock);
	return _queueLock;
}
- (NSLock *) workingLock
{
	UTILAssertNotNil(_workingLock);
	return _workingLock;
}

- (id<SGBaseQueue>) workQueue
{
	if (nil == _workQueue)
//		_workQueue = [[SGBaseQueue alloc] init];
		_workQueue = [[SGBaseThreadSafeQueue alloc] init];
	
	return _workQueue;
}

- (id<CMXRunnable>) nextWork
{
	id		work_;
	int		condition_;
	
	// タスクがなければ追加されるまで休眠状態に入る。
	[[self queueLock] lockWhenCondition : kWorkQueueHasWork];
	
	while ([[self workQueue] isEmpty]) {
	
		// 常に正しい条件でスレッドが起こされる
		// とは限らないので、本当に条件を満たしているか
		// ここでチェックする。
		[[self queueLock] unlockWithCondition : kWorkQueueEmpty];
		[[self queueLock] lockWhenCondition : kWorkQueueHasWork];
	}
	
	work_ = [[self workQueue] take];
	[work_ retain];
	
	// このメソッドは待機ループからしか呼び出されないので
	// すでに前のタスクは終了している。
	// ここで現在のタスクに設定。
	[self setWork : work_];
	
	condition_ = [[self workQueue] isEmpty]
						? kWorkQueueEmpty
						: kWorkQueueHasWork;
	
	[[self queueLock] unlockWithCondition : condition_];
	
	return [work_ autorelease];
}

- (NSLock *) workLock
{
	UTILAssertNotNil(_workLock);
	return _workLock;
}
- (id<CMXRunnable>) work
{
	id		current_;
	
	[[self workLock] lock];
	current_ = _work;
	[current_ retain];
	[[self workLock] unlock];
	
	return [current_ autorelease];
}
- (void) setWork : (id<CMXRunnable>) aWork
{
	id		tmp;
	
	[[self workLock] lock];
	tmp = _work;
	_work = [aWork retain];
	[[self workLock] unlock];
	
	[tmp release];
}
@end
