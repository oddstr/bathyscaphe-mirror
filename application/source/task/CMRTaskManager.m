//
//  CMRTaskManager.m
//  BathyScaphe
//
//  Updated by Tsutomu Sawada on 08/03/18.
//  Copyright 2005-2008 BathyScaphe Project. All rights reserved.
//  encoding="UTF-8"
//

#import "CMRTaskManager_p.h"
#import "BSTaskItemValueTransformer.h"

#define DEFAULT_TASKPANEL_AUTOSAVE_NAME		@"BathyScaphe:TaskManager Panel AutoSave"

@implementation CMRTaskManager
APP_SINGLETON_FACTORY_METHOD_IMPLEMENTATION(defaultManager);

- (id)init
{
	if (self = [self initWithWindowNibName:APP_TASK_MANAGER_NIB_NAME]) {
		id transformer = [[[BSTaskItemValueTransformer alloc] init] autorelease];
		[NSValueTransformer setValueTransformer:transformer forName:@"BSTaskItemValueTransformer"];
	}
	return self;
}

- (void)dealloc
{
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	
	[_tasksInProgress release];
	[_taskItemControllers release];
	[_controllerMapping release];

	// nib top-level object
	[_arrayController release];
	_arrayController = nil;

	[super dealloc];
}

- (void)awakeFromNib
{
	[(NSPanel*)[self window] setFloatingPanel:NO];
	[(NSPanel*)[self window] setBecomesKeyOnlyIfNeeded:YES];
	[[self window] setFrameAutosaveName:DEFAULT_TASKPANEL_AUTOSAVE_NAME];
}

- (void)windowDidLoad
{
	[self setupUIComponents];
}

- (void)addTask:(id<CMRTask>)aTask
{
	CMRTaskItemController	*controller_;
	
	UTILAssertNotNilArgument(aTask, @"Task Object");
	if (![self shouldRegisterTask:aTask]) return;
	
	controller_ = [[CMRTaskItemController alloc] initWithTask:aTask];
	[self addTaskItemController:controller_];
	[controller_ release];
	
	// 
	// 通知を再度、ブロードキャストするために
	// 
	[self registerNotificationWithTask : aTask];
}

#pragma mark CMRTask protocol
- (NSString *)identifier
{
	return nil;
}

- (NSString *)title
{
	return nil;
}

- (NSString *)message
{
	return nil;
}

- (BOOL)isInProgress
{
	return ([[self tasksInProgress] count] > 0);
}

- (double)amount
{
	return -1;
}

#pragma mark IBActions
- (IBAction)showWindow:(id)sender
{
	// toggle-Action : すでにパネルが表示されているときは、パネルを閉じる
	if (![self isWindowLoaded] || ![[self window] isVisible]) {
		[super showWindow:sender];
		[self taskContainerViewScrollLastRowToVisible];
	} else {
		[[self window] orderOut:sender];
	}
}

- (IBAction)cancel:(id)sender
{
	[[[self tasksInProgress] lastObject] cancel:sender];
}

- (IBAction)scrollLastRowToVisible:(id)sender
{
	[self taskContainerViewScrollLastRowToVisible];
}
@end


@implementation CMRTaskManager(ViewAccessor)
- (NSScrollView *)scrollView
{
	return [[self taskContainerView] enclosingScrollView];
}

- (SGContainerTableView *)taskContainerView
{
	return _taskContainerView;
}

- (NSArrayController *)tasksArrayController
{
	return _arrayController;
}

- (void)taskContainerViewScrollLastRowToVisible
{
	int count = [[self taskContainerView] numberOfRows];
	if (count > 0) {
		[[self taskContainerView] scrollRowToVisible:(count - 1)];
	}
}

- (void)setupTaskContainerView
{
	UTILAssertNotNil([self taskContainerView]);
	[[self taskContainerView] setDataSource:self];
}

- (void)setupUIComponents
{
	[self setupTaskContainerView];
}
@end


@implementation CMRTaskManager(SGContainerTableViewDataSource)
- (int)numberOfRowsInContainerTableView:(SGContainerTableView *)tbView
{
	return [[self taskItemControllers] count];
}

- (NSView *)containerTableView:(SGContainerTableView *)tbView viewAtRow:(int)rowIndex
{
	id			controller_;
	NSView		*view_;
	
	controller_ = [[self taskItemControllers] objectAtIndex:rowIndex];
	UTILAssertRespondsTo(controller_, @selector(contentView));
	view_ = [controller_ contentView];
	UTILAssertNotNil(view_);	
	return view_;
}
@end
