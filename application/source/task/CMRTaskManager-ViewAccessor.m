//: CMRTaskManager-ViewAccessor.m
/**
  * $Id: CMRTaskManager-ViewAccessor.m,v 1.2 2005/07/04 17:22:17 tsawada2 Exp $
  * 
  * Copyright (c) 2001-2003, Takanori Ishikawa.  All rights reserved.
  * See the file LICENSE for copying permission.
  */

#import "CMRTaskManager_p.h"

@implementation CMRTaskManager(ViewAccessor)
- (NSScrollView *) scrollView
{
	return [[self taskContainerView] enclosingScrollView];
}
/* Accessor for _taskContainerView */
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
- (void) validateNibSettings
{
}
- (void) setupUIComponents
{
	[self validateNibSettings];
	[self setupTaskContainerView];
}
@end

