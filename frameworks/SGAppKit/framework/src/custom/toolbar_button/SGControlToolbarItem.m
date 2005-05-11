//: SGControlToolbarItem.m
/**
  * $Id: SGControlToolbarItem.m,v 1.1.1.1 2005/05/11 17:51:26 tsawada2 Exp $
  * 
  * Copyright (c) 2001-2003, Takanori Ishikawa.  All rights reserved.
  * See the file LICENSE for copying permission.
  */

#import "SGControlToolbarItem.h"
#import "SGAppKitFrameworkDefines.h"


@implementation SGControlToolbarItem
- (void) validate
{
	NSControl		*control_;
	id				target_;
	BOOL			isEnabled_;
	
	control_ = (NSControl *)[self view];
	UTILRequireCondition(control_, call_super);
	UTILRequireCondition(
		[control_ isKindOfClass : [NSControl class]],
		call_super);
	
	target_ = [control_ target];
	if(nil == target_)
		target_ = [NSApp targetForAction : [control_ action]];
	
	UTILRequireCondition(target_, call_super);
	UTILRequireCondition(
		[target_ respondsToSelector : @selector(validateToolbarItem:)],
		call_super);
	
	isEnabled_ = [target_ validateToolbarItem : self];
	[self setEnabled : isEnabled_];
	[[self menuFormRepresentation] setEnabled : isEnabled_];
	
	return;
	
	call_super:
		[super validate];
}
@end
