//: SGToolbarIconItemButton.m
/**
  * $Id: SGToolbarIconItemButton.m,v 1.1.1.1 2005/05/11 17:51:26 tsawada2 Exp $
  * 
  * Copyright (c) 2001-2003, Takanori Ishikawa.  All rights reserved.
  * See the file LICENSE for copying permission.
  */

#import "SGToolbarIconItemButton_p.h"
#import "SGFixImageButtonCell.h"
#import "NSToolbar-SGExtensions.h"
#import "NSControl-SGExtensions.h"



//////////////////////////////////////////////////////////////////////
////////////////////// [ 定数やマクロ置換 ] //////////////////////////
//////////////////////////////////////////////////////////////////////
static const NSSize kMenuItemImageSize = {width:16, height:16};

@implementation SGToolbarIconItemButton
+ (Class) cellClass
{
	return [SGFixImageButtonCell class];
}
- (void) setCell : (NSCell *) aCell
{
	NSButtonCell	*cell_;
	
	[super setCell : aCell];
	cell_ = (NSButtonCell*)aCell;
	if(NO == [cell_ isKindOfClass : [NSButtonCell class]])
		return;
	[cell_ setHighlightsBy : NSNoCellMask];
	[cell_ setImagePosition : NSImageOnly];
	[cell_ setBordered : NO];
}
- (BOOL) isBordered
{
	return NO;
}
- (NSCellImagePosition) imagePosition
{
	return NSImageOnly;
}

- (void) setFrameSize : (NSSize) aSize
{
	if(NSSmallControlSize == [self controlSize])
		aSize = [NSToolbar iconSizeWithSizeMode : NSToolbarSizeModeSmall];
	else
		aSize = [NSToolbar iconSizeWithSizeMode : NSToolbarSizeModeRegular];
	[super setFrameSize : aSize];
}
- (void) setFrame : (NSRect) aFrame
{
	if(NSSmallControlSize == [self controlSize])
		aFrame.size = [NSToolbar iconSizeWithSizeMode : NSToolbarSizeModeSmall];
	else
		aFrame.size = [NSToolbar iconSizeWithSizeMode : NSToolbarSizeModeRegular];
	
	[super setFrame : aFrame];
}
@end



@implementation SGToolbarIconItemButton(SGExtension)
- (void) attachToolbarItem : (NSToolbarItem *) anItem
{
	NSMenuItem		*menuItem_;
	NSImage			*menuImage_;
	
	[self retain];
	[self removeFromSuperviewWithoutNeedingDisplay];
	
	[anItem setView : self];
	if([anItem view] != nil){
		[anItem setMinSize : [NSToolbar iconSizeWithSizeMode : NSToolbarSizeModeSmall]];
		[anItem setMaxSize : [NSToolbar iconSizeWithSizeMode : NSToolbarSizeModeRegular]];
	}
	[self release];
	
	menuItem_ = [[NSMenuItem alloc]
					initWithTitle : [anItem label]
						   action : [anItem action]
					keyEquivalent : @""];
	menuImage_ = [[self image] copyWithZone : [menuItem_ zone]];
	[menuImage_ setSize : kMenuItemImageSize];
	
	[menuItem_ setTarget : [anItem target]];
	[menuItem_ setImage : menuImage_];
	[anItem setMenuFormRepresentation : menuItem_];
	[menuImage_ release];
}
@end