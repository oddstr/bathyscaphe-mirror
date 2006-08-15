//: CMRTaskManager-Management.m
/**
  * $Id: CMRTaskManager-Management.m,v 1.1.1.1.4.1 2006/08/15 13:43:23 masakih Exp $
  * 
  * Copyright (c) 2001-2003, Takanori Ishikawa.  All rights reserved.
  * See the file LICENSE for copying permission.
  */

#import "CMRTaskManager_p.h"
#import "CMRTaskItemController_p.h"



// 進行状況の更新インターバル
static const NSTimeInterval		kNotifyTimeInterval = (12 / 60) * 2;



@implementation CMRTaskManager(TaskInProgress)
- (void) checkTasks
{
	int					i;
	NSMutableArray		*array_;
	
	//	
	// すでに終了したタスクがまだ残っていないか
	// 確認する。
	//
	
	array_ = [self tasksInProgress];
	for(i = 0; i < [array_ count]; i++){
		id<CMRTask>			task_;
		
		task_ = [array_ objectAtIndex : i];
		if([task_ isInProgress])
			continue;
		
		[self removeTask : task_];
		i--;
	}
}
- (void) taskWillProgressProcessing : (NSTimer *) aTimer
{
	NSEnumerator		*iter_;
	id<CMRTask>			task_;
	BOOL				shouldCheck_;
	
	shouldCheck_ = NO;
	
	// 
	// アクティブなタスクをそれぞれ通知する。
	// 
	iter_ = [[self tasksInProgress] objectEnumerator];
	while(task_ = [iter_ nextObject]){
		CMRTaskItemController	*controller_;
		
		if(NO == [task_ isInProgress]){
			shouldCheck_ = YES;
			continue;
		}
		
		controller_ = [self controllerForTask : task_];
		if(nil == [controller_ task]) 
			continue;
		
		[controller_ taskWillProgressProcessing : task_];
		[[NSNotificationCenter defaultCenter]
			postNotificationName : CMRTaskWillProgressNotification
						  object : task_];
	}
	
	if(shouldCheck_)
		[self checkTasks];
}
- (void) setTimerOnMainThread : (NSMutableArray *)container
{
	id t;
	
	t = [NSTimer scheduledTimerWithTimeInterval : kNotifyTimeInterval
										 target : self
									   selector : @selector(taskWillProgressProcessing:)
									   userInfo : nil
										repeats : YES];
	[container addObject:t];
}
- (void) addTaskInProgress : (id<CMRTask>) aTask
{
	CMRTaskItemController		*controller_;
	
	if(NO == [self shouldRegisterTask : aTask])
		return;
	
		
	[[self tasksInProgress] addObject : aTask];
	
	// アイテムに通知を渡す
	controller_ = [self controllerForTask : aTask];
	[controller_ taskWillStartProcessing : aTask];
	
	if(1 == [[self tasksInProgress] count]){
		NSTimer			*timer_;
		
		// タイマーを開始する。
		NSAssert(
			nil == _notificationTimer,
			@"Timer was already assigned");
		
		NSArray *container = [NSMutableArray arrayWithCapacity:1]; 
		[self performSelectorOnMainThread:@selector(setTimerOnMainThread:)
							   withObject:container
							waitUntilDone:YES];
		timer_ = [container objectAtIndex:0];
/*		
		timer_ = [NSTimer scheduledTimerWithTimeInterval : kNotifyTimeInterval
						target : self
						selector : @selector(taskWillProgressProcessing:)
						userInfo : nil
						repeats : YES];
*/		
		_notificationTimer = [timer_ retain];
	}
}
- (void) removeTask : (id<CMRTask>) aTask
{
	CMRTaskItemController		*controller_;
	
	if(NO == [self shouldRegisterTask : aTask])
		return;
	
	[[self tasksInProgress] removeObjectIdenticalTo : aTask];
	
	// アイテムに通知を渡す
	controller_ = [self controllerForTask : aTask];
	[controller_ taskDidFinishProcessing : aTask];
	
	// 対応表から削除
	[[self controllerMapping] removeObjectForKey : [aTask identifier]];
	if(0 == [[self tasksInProgress] count]){
		// タイマーを停止する。
		[_notificationTimer invalidate];
		[_notificationTimer release];
		_notificationTimer = nil;
	}
}
- (void) taskWillStartProcessing : (NSNotification *) aNotification
{
	id<CMRTask>			object_;
	
	UTILAssertNotificationName(
		aNotification,
		CMRTaskWillStartNotification);
	
	object_ = [aNotification object];
	UTILAssertConformsTo(object_, @protocol(CMRTask));
	[self addTaskInProgress : object_];
}
- (void) taskDidFinishProcessing : (NSNotification *) aNotification
{
	id<CMRTask>			object_;
	
	UTILAssertNotificationName(
		aNotification,
		CMRTaskDidFinishNotification);
	
	object_ = [aNotification object];
	UTILAssertConformsTo(object_, @protocol(CMRTask));
	
	[self removeFromNotificationWithTask : object_];
	[self removeTask : object_];
}

- (void) registerNotificationWithTask : (id<CMRTask>) aTask
{
	NSNotificationCenter		*center_;
	
	UTILAssertNotNilArgument(aTask, @"Task");
	
	center_ = [NSNotificationCenter defaultCenter];
	[center_ addObserver : self
				selector : @selector(taskWillStartProcessing:)
				    name : CMRTaskWillStartNotification
			      object : aTask];
	[center_ addObserver : self
				selector : @selector(taskDidFinishProcessing:)
				    name : CMRTaskDidFinishNotification
			      object : aTask];
}
- (void) removeFromNotificationWithTask : (id<CMRTask>) aTask
{
	NSNotificationCenter		*center_;
	
	UTILAssertNotNilArgument(aTask, @"Task");
	
	center_ = [NSNotificationCenter defaultCenter];
	[center_ removeObserver : self
				    name : CMRTaskWillStartNotification
			      object : aTask];
	[center_ removeObserver : self
				    name : CMRTaskDidFinishNotification
			      object : aTask];
}
- (BOOL) shouldRegisterTask : (id<CMRTask>) aTask
{
	return ([aTask identifier] != nil);
}
@end



@implementation CMRTaskManager(TaskItemManagement)
- (CMRTaskItemController *) controllerForTask : (id<CMRTask>) aTask
{
	if(nil == [aTask identifier]) return nil;
	
	return [[self controllerMapping] objectForKey : [aTask identifier]];
}
- (NSMutableArray *) taskItemControllers
{
	if(nil == _taskItemControllers)
		_taskItemControllers = [[NSMutableArray alloc] init];
	
	return _taskItemControllers;
}
- (NSMutableDictionary *) controllerMapping
{
	if(nil == _controllerMapping)
		_controllerMapping = [[NSMutableDictionary alloc] init];
	
	return _controllerMapping;
}
- (NSMutableArray *) tasksInProgress
{
	if(nil == _tasksInProgress)
		_tasksInProgress = [[NSMutableArray alloc] init];
	
	return _tasksInProgress;
}

- (void) addTaskItemController : (CMRTaskItemController *) newController;
{
	id<CMRTask>		task_;
	
	UTILAssertNotNilArgument(newController, @"Controller");
	
	task_ = [newController task];
	UTILAssertNotNilArgument(task_, @"Task");
	UTILAssertNotNilArgument([task_ identifier], @"identifier");
	
	[[self taskItemControllers] addObject : newController];
	// 
	// タスクとコントローラの対応をここで記録し、
	// タスクが終わり次第削除する。
	// 
	[[self controllerMapping] 
		setObject : newController
		   forKey : [task_ identifier]];
	
	[self removeFinishedControllersIfNeeded];
}

- (unsigned) capacity
{
	return APP_TASK_MANAGER_DEFAULT_CAPACITY;
}

- (void) removeFinishedControllersIfNeeded
{
	unsigned i;
	
	for(i = 0; i < [[self taskItemControllers] count]; i++){
		CMRTaskItemController	*controller_;
		
		if([[self taskItemControllers] count] <= [self capacity]) break;
		
		controller_ = [[self taskItemControllers] objectAtIndex : i];
		UTILAssertKindOfClass(controller_, CMRTaskItemController);
		if(nil == [controller_ task] || NO == [[controller_ task] isInProgress]){
			[[self taskItemControllers] removeObjectAtIndex : i];
			i--;
		}
	}
}
@end
