//: CMRTaskManager.m
/**
  * $Id: CMRTaskManager.m,v 1.6 2006/04/11 17:31:21 masakih Exp $
  * 
  * Copyright (c) 2001-2003, Takanori Ishikawa.  All rights reserved.
  * See the file LICENSE for copying permission.
  */

#import "CMRTaskManager_p.h"
#define DEFAULT_TASKPANEL_AUTOSAVE_NAME	@"BathyScaphe:TaskManager Panel AutoSave"

@implementation CMRTaskManager
APP_SINGLETON_FACTORY_METHOD_IMPLEMENTATION(defaultManager);

- (id) init
{
	if(self = [self initWithWindowNibName : APP_TASK_MANAGER_NIB_NAME]){
		// ...
	}
	return self;
}
- (void) dealloc
{
	[[NSNotificationCenter defaultCenter] removeObserver : self];
	
	[_notificationTimer invalidate];
	[_notificationTimer release];
	_notificationTimer = nil;
	
	[_tasksInProgress release];
	[_taskItemControllers release];
	[_controllerMapping release];
	[super dealloc];
}
- (void) awakeFromNib
{
	[(NSPanel*)[self window] setFloatingPanel : NO];
	[(NSPanel*)[self window] setBecomesKeyOnlyIfNeeded : YES];
	[(NSPanel*)[self window] setFrameAutosaveName : DEFAULT_TASKPANEL_AUTOSAVE_NAME];
}

// Window Management
- (void) windowDidLoad
{
	[self setupUIComponents];
}

// CMRTaskManager:
- (void) addTask : (id<CMRTask>) aTask
{
	CMRTaskItemController	*controller_;
	
	UTILAssertNotNilArgument(aTask, @"Task Object");
	if(NO == [self shouldRegisterTask : aTask])
		return;
	
	controller_ = [[CMRTaskItemController alloc] initWithTask : aTask];
	[self addTaskItemController : controller_];
	[controller_ release];
	
	[[self taskContainerView] reloadData];
	[self taskContainerViewScrollLastRowToVisible];
	
	// 
	// 通知を再度、ブロードキャストするために
	// 
	[self registerNotificationWithTask : aTask];
}

#pragma mark CMRTask protocol

- (NSString *) identifier
{
	return nil;
}
- (NSString *) title
{
	return nil;
}

- (NSString *) message
{
	return nil;
}

- (BOOL) isInProgress
{
	NSArray			*allTasks_;
	NSEnumerator	*iter_;
	id<CMRTask>		task_;
	
	allTasks_ = [self tasksInProgress];
	if(nil == allTasks_ || 0 == [allTasks_ count]) return NO;
	
	iter_ = [allTasks_ objectEnumerator];
	while(task_ = [iter_ nextObject]){
		UTILAssertConformsTo(
			[task_ class],
			@protocol(CMRTask));
		if([task_ isInProgress]) 
			return YES;
	}
	
	return NO;
}
// 全体の平均を返す。
- (double) amount
{
	double			amount_ = 0.0;
	NSArray			*allTasks_;
	NSEnumerator	*iter_;
	id<CMRTask>		task_;
	
	allTasks_ = [self tasksInProgress];
	
	if(nil == allTasks_ || 0 == [allTasks_ count]) goto error_amount;
	iter_ = [allTasks_ objectEnumerator];
	while(task_ = [iter_ nextObject]){
		double	other_;
		
		UTILAssertConformsTo(
			[task_ class],
			@protocol(CMRTask));
		if(NO == [task_ isInProgress])
			continue;
		other_ = [task_ amount];
		if(other_ < 0) continue;
		
		amount_ += other_;
	}
	if(0.0 == amount_) goto error_amount;
	
	return (double)(amount_/(double)[allTasks_ count]);
	
	error_amount:{
		return -1.0;
	}
}

#pragma mark IBActions

- (IBAction) showWindow : (id) sender
{
	// toggle-Action : すでにパネルが表示されているときは、パネルを閉じる
	if ([[self window] isVisible]) {
		[[self window] orderOut : sender];
	} else {
		[super showWindow : sender];
		[self taskContainerViewScrollLastRowToVisible];
	}
}
- (IBAction) cancel : (id) sender
{
	[[[self tasksInProgress] lastObject] cancel : sender];
}
- (IBAction) scrollLastRowToVisible : (id) sender
{
	[self taskContainerViewScrollLastRowToVisible];
}
@end


@implementation CMRTaskManager(ViewAccessor)
- (NSScrollView *) scrollView
{
	return [[self taskContainerView] enclosingScrollView];
}

- (SGContainerTableView *) taskContainerView
{
	return _taskContainerView;
}

- (void) taskContainerViewScrollLastRowToVisible
{
	[[self taskContainerView] 
		scrollRowToVisible : [[self taskItemControllers] count] -1];
}

- (void) setupTaskContainerView
{
	UTILAssertNotNil([self taskContainerView]);
	[[self taskContainerView] setDataSource : self];
}

- (void) setupUIComponents
{
	[self setupTaskContainerView];
}
@end


@implementation CMRTaskManager(SGContainerTableViewDataSource)
- (int) numberOfRowsInContainerTableView : (SGContainerTableView *) tbView
{
	int			cnt = [[self taskItemControllers] count];
	
	return cnt;
}
- (NSView *) containerTableView : (SGContainerTableView *) tbView
                      viewAtRow : (int                   ) rowIndex
{
	id			controller_;
	NSView		*view_;
	
	controller_ = [[self taskItemControllers] objectAtIndex : rowIndex];
	UTILAssertNotNil(controller_);
	view_ = [controller_ contentView];
	UTILAssertNotNil(view_);
	
	return view_;
}
@end
