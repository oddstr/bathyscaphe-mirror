//: NSCell-SGExtensions.m
/**
  * $Id: NSCell-SGExtensions.m,v 1.1.1.1 2005/05/11 17:51:26 tsawada2 Exp $
  * 
  * Copyright (c) 2001-2003, Takanori Ishikawa.  All rights reserved.
  * See the file LICENSE for copying permission.
  */

#import "NSCell-SGExtensions_p.h"



@implementation NSCell(SGExtensions)
- (void) setAttributesFromCell : (NSCell *) aCell
{
	if(nil == aCell) return;
	
	[self setType : [aCell type]];
	[self setState : [aCell state]];
	[self setTarget : [aCell target]];
	[self setAction : [aCell action]];
	[self setTag : [aCell tag]];
	[self setEnabled : [aCell isEnabled]];
	[self setContinuous : [aCell isContinuous]];
	[self setEditable : [aCell isEditable]];
	[self setSelectable : [aCell isSelectable]];
	[self setBordered : [aCell isBordered]];
	[self setBezeled : [aCell isBezeled]];
	[self setScrollable : [aCell isScrollable]];
	[self setAlignment : [aCell alignment]];
	[self setWraps : [aCell wraps]];
	[self setFont : [aCell font]];
	[self setEntryType : [aCell entryType]];
	[self setFormatter : [aCell formatter]];
	[self setObjectValue : [aCell objectValue]];
	[self setImage : [aCell image]];
	[self setRepresentedObject : [aCell representedObject]];
	[self setMenu : [aCell menu]];
	[self setSendsActionOnEndEditing : [aCell sendsActionOnEndEditing]];
	[self setRefusesFirstResponder : [aCell refusesFirstResponder]];
	[self setShowsFirstResponder : [aCell showsFirstResponder]];
	[self setMnemonicLocation : [aCell mnemonicLocation]];
	[self setAllowsEditingTextAttributes : [aCell allowsEditingTextAttributes]];
	[self setImportsGraphics : [aCell importsGraphics]];
	[self setAllowsMixedState : [aCell allowsMixedState]];
}
@end
