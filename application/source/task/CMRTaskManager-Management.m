//
//  CMRTaskManager-Management.m
//  BathyScaphe
//
//  Updated by Tsutomu Sawada on 08/03/18.
//  Copyright 2005-2008 BathyScaphe Project. All rights reserved.
//  encoding="UTF-8"
//

#import "CMRTaskManager_p.h"

@implementation CMRTaskManager(TaskInProgress)
- (void)addTaskInProgress:(id<CMRTask>)aTask
{
	CMRTaskItemController		*controller_;
	
	controller_ = [self controllerForTask:aTask];
	if (!controller_) return;
	[[self tasksInProgress] addObject:aTask];	
}

- (void)removeTask:(id<CMRTask>)aTask
{
	CMRTaskItemController		*controller_;

	controller_ = [self controllerForTask:aTask];
	if (!controller_) return;

	[[self tasksInProgress] removeObject:aTask];
	
	// 対応表から削除
	[[self controllerMapping] removeObjectForKey:[aTask identifier]];

	[[self taskItemControllers] removeObject:controller_];
	[[self taskContainerView] reloadData];
}

- (void)taskWillStartProcessing:(NSNotification *)aNotification
{
	id<CMRTask>			object_;
	
	UTILAssertNotificationName(
		aNotification,
		CMRTaskWillStartNotification);
	
	object_ = [aNotification object];
	UTILAssertConformsTo(object_, @protocol(CMRTask));
	[self addTaskInProgress:object_];
}

- (void)taskDidFinishProcessing:(NSNotification *)aNotification
{
	id<CMRTask>			object_;
	
	UTILAssertNotificationName(
		aNotification,
		CMRTaskDidFinishNotification);
	
	object_ = [aNotification object];
	UTILAssertConformsTo(object_, @protocol(CMRTask));
	
	[self removeFromNotificationWithTask:object_];
	[self removeTask:object_];
}

- (void)registerNotificationWithTask:(id<CMRTask>)aTask
{
	NSNotificationCenter		*center_;
	
	UTILAssertNotNilArgument(aTask, @"Task");
	
	center_ = [NSNotificationCenter defaultCenter];
	[center_ addObserver:self
				selector:@selector(taskWillStartProcessing:)
				    name:CMRTaskWillStartNotification
			      object:aTask];
	[center_ addObserver:self
				selector:@selector(taskDidFinishProcessing:)
				    name:CMRTaskDidFinishNotification
			      object:aTask];
}

- (void)removeFromNotificationWithTask:(id<CMRTask>)aTask
{
	NSNotificationCenter		*center_;
	
	UTILAssertNotNilArgument(aTask, @"Task");
	
	center_ = [NSNotificationCenter defaultCenter];
	[center_ removeObserver:self name:CMRTaskWillStartNotification object:aTask];
	[center_ removeObserver:self name:CMRTaskDidFinishNotification object:aTask];
}

- (BOOL)shouldRegisterTask:(id<CMRTask>)aTask
{
	return ([aTask identifier] != nil);
}
@end


@implementation CMRTaskManager(TaskItemManagement)
- (CMRTaskItemController *)controllerForTask:(id<CMRTask>)aTask
{
	if (![aTask identifier]) return nil;
	
	return [[self controllerMapping] objectForKey:[aTask identifier]];
}

- (NSMutableArray *)taskItemControllers
{
	if (!_taskItemControllers) {
		_taskItemControllers = [[NSMutableArray alloc] init];
	}
	return _taskItemControllers;
}

- (NSMutableDictionary *)controllerMapping
{
	if (!_controllerMapping) {
		_controllerMapping = [[NSMutableDictionary alloc] init];
	}
	return _controllerMapping;
}

- (NSMutableArray *)tasksInProgress
{
	if (!_tasksInProgress) {
		_tasksInProgress = [[NSMutableArray alloc] init];
	}
	return _tasksInProgress;
}

- (void)addTaskItemController:(CMRTaskItemController *)newController
{
	id<CMRTask>		task_;
	
	UTILAssertNotNilArgument(newController, @"Controller");
	
	task_ = [newController task];
	UTILAssertNotNilArgument(task_, @"Task");
	UTILAssertNotNilArgument([task_ identifier], @"identifier");
	
	[[self taskItemControllers] addObject:newController];
	// 
	// タスクとコントローラの対応をここで記録し、
	// タスクが終わり次第削除する。
	// 
	[[self controllerMapping] setObject:newController forKey:[task_ identifier]];

	[[self taskContainerView] reloadData];
}
@end
