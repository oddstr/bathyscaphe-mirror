//: NSToolbar-SGExtensions.m
/**
  * $Id: NSToolbar-SGExtensions.m,v 1.1.1.1.8.1 2006/11/11 19:03:08 tsawada2 Exp $
  * 
  * Copyright (c) 2001-2003, Takanori Ishikawa.  All rights reserved.
  * See the file LICENSE for copying permission.
  */

#import "NSToolbar-SGExtensions.h"


/*
@implementation NSToolbar(UnsupportedAccessor)
- (BOOL) allowsUserCustomizationByDragging
{
	return (BOOL)_tbFlags.clickAndDragPerformsCustomization;
}
- (void) setAllowsUserCustomizationByDragging : (BOOL) flag
{
	_tbFlags.clickAndDragPerformsCustomization = flag ? 1 : 0;
}

- (BOOL) showsContextMenu
{
	return (0 == _tbFlags.showsNoContextMenu);
}
- (void) setShowsContextMenu : (BOOL) flag
{
	_tbFlags.showsNoContextMenu = flag ? 0 : 1;
}

- (unsigned int) firstMoveableItemIndex
{
	return (unsigned int)_tbFlags.firstMoveableItemIndex;
}
- (void) setFirstMoveableItemIndex : (unsigned int) anIndex
{
	_tbFlags.firstMoveableItemIndex = (unsigned int) anIndex & 0x3F;
}
@end



static const NSSize kRegularControlIconSize	= {width:32, height:32};
static const NSSize kSmallControlIconSize	= {width:24, height:24};



@implementation NSToolbar(SGExtensions1109)
+ (NSSize) iconSizeWithSizeMode : (NSToolbarSizeMode) mode
{
	switch(mode){
	case NSToolbarSizeModeDefault:
		return kRegularControlIconSize;
		break;
	case NSToolbarSizeModeRegular:
		return kRegularControlIconSize;
		break;
	case NSToolbarSizeModeSmall:
		return kSmallControlIconSize;
		break;
	default:
		return kRegularControlIconSize;
		break;
	}
	return kRegularControlIconSize;
}
@end
*/


@implementation NSToolbarItem(SGExtensions)
- (NSString *) title
{
	return [self label];
}
- (void) setTitle : (NSString *) aTitle
{
	[self setLabel : aTitle];
}
@end

