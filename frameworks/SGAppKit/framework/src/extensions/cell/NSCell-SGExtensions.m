//: NSCell-SGExtensions.m
/**
  * $Id: NSCell-SGExtensions.m,v 1.2 2007/02/08 00:20:26 tsawada2 Exp $
  * 
  * Copyright (c) 2001-2003, Takanori Ishikawa.  All rights reserved.
  * See the file LICENSE for copying permission.
  */

#import "NSCell-SGExtensions.h"

@implementation NSCell(SGExtensions)
- (void) setAttributesFromCell : (NSCell *) aCell
{
	if(nil == aCell) return;
	
	[self setAction : [aCell action]];
	[self setAlignment : [aCell alignment]];
	[self setAllowsEditingTextAttributes : [aCell allowsEditingTextAttributes]];
	[self setAllowsMixedState : [aCell allowsMixedState]];
	[self setBezeled : [aCell isBezeled]];
	[self setBordered : [aCell isBordered]];
	[self setContinuous : [aCell isContinuous]];
	[self setEditable : [aCell isEditable]];
	[self setEnabled : [aCell isEnabled]];
	[self setFocusRingType: [aCell focusRingType]];
	[self setFont : [aCell font]];
	[self setFormatter : [aCell formatter]];
	[self setImage : [aCell image]];
	[self setImportsGraphics : [aCell importsGraphics]];
	[self setMenu : [aCell menu]];
	[self setObjectValue : [aCell objectValue]];
	[self setRefusesFirstResponder : [aCell refusesFirstResponder]];
	[self setRepresentedObject : [aCell representedObject]];
	[self setScrollable : [aCell isScrollable]];
	[self setSelectable : [aCell isSelectable]];
	[self setSendsActionOnEndEditing : [aCell sendsActionOnEndEditing]];
	[self setShowsFirstResponder : [aCell showsFirstResponder]];
	[self setState : [aCell state]];
	[self setTag : [aCell tag]];
	[self setTarget : [aCell target]];
	[self setType : [aCell type]];
	[self setWraps : [aCell wraps]];
}
@end
