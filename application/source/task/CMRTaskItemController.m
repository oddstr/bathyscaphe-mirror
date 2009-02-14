//
//  CMRTaskItemController.m
//  BathyScaphe
//
//  Updated by Tsutomu Sawada on 08/03/10.
//  Copyright 2005-2009 BathyScaphe Project. All rights reserved.
//  encoding="UTF-8"
//

#import "CMRTaskItemController.h"
#import "UTILKit.h"
#import "CMRTask.h"

#define APP_TASK_ITEM_CONTROLLER_NIB_NAME	@"CMRTaskItem"

@implementation CMRTaskItemController
- (id)initWithTask:(id<CMRTask>)aTask
{
	if (self = [self init]) {
		_task = [aTask retain];
	}
	return self;
}

- (id)init
{
	if (self = [super init]) {
		;
	}
	return self;
}

- (void)dealloc
{
	// nib top-level objects
	[[self taskController] setContent:nil];
	[m_taskController release];
	m_taskController = nil;
	[_contentView release];
	_contentView = nil;

	[_task release];
	_task = nil;

	[super dealloc];
}

- (IBAction)stop:(id)sender
{
	if ([[self task] isInProgress]) {
		[[self task] cancel:sender];
	}
}

- (id<CMRTask>)task
{
	return _task;
}

- (NSView *)contentView
{
	if (!_contentView) {
		if ([NSBundle loadNibNamed:APP_TASK_ITEM_CONTROLLER_NIB_NAME owner:self]) {
			[[self taskController] setContent:[self task]];
		} else {
			NSLog(@"%@ failed loadNibNamed:%@", NSStringFromClass([self class]), APP_TASK_ITEM_CONTROLLER_NIB_NAME);
		}
	}
	return _contentView;
}

- (NSObjectController *)taskController
{
	return m_taskController;
}
@end
