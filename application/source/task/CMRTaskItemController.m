//
//  CMRTaskItemController.m
//  BathyScaphe
//
//  Updated by Tsutomu Sawada on 08/03/10.
//  Copyright 2005-2008 BathyScaphe Project. All rights reserved.
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
		[self setTask:aTask];
	}
	return self;
}

- (id)init
{
	if (self = [super init]) {
		if (![NSBundle loadNibNamed:APP_TASK_ITEM_CONTROLLER_NIB_NAME owner:self]) {
			NSLog(@"%@ failed loadNibNamed:%@", NSStringFromClass([self class]), APP_TASK_ITEM_CONTROLLER_NIB_NAME);
			[self autorelease];
		}
	}
	return self;
}

- (void)dealloc
{
	[self setTask:nil];

	// nib top-level object
	[_contentView release];
	_contentView = nil;

	[super dealloc];
}

- (IBAction)stop:(id)sender
{
	if ([[self task] isInProgress]) [[self task] cancel:sender];
}

- (id<CMRTask>)task
{
	return _task;
}

- (void)setTask:(id<CMRTask>)aTask
{
	[aTask retain];
	[_task release];
	_task = aTask;
}

- (NSView *)contentView
{
	return _contentView;
}

- (NSProgressIndicator *)indicator
{
	return _indicator;
}
@end
