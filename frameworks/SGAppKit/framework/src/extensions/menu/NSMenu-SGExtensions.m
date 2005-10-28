//: NSMenu-SGExtensions.m
/**
  * $Id: NSMenu-SGExtensions.m,v 1.2 2005/10/28 15:21:43 tsawada2 Exp $
  * 
  * Copyright (c) 2001-2003, Takanori Ishikawa.  All rights reserved.
  * See the file LICENSE for copying permission.
  */

#import "NSMenu-SGExtensions_p.h"


@implementation NSMenu(SGExtensions)
- (void) removeAllItems
{
	int		i, cnt;
	
	cnt = [self numberOfItems];
	for(i = (cnt -1); i >= 0; i--){
		[self removeItemAtIndex : i];
	}
}
- (NSMenuItem *) addItemWithTitle : (NSString *) title
{
	id	menuItem = [self addItemWithTitle : title
								   action : NULL
							keyEquivalent : @""];
	return menuItem;
}
- (void) addItemsWithTitles : (NSArray *) itemTitles
{
	NSEnumerator		*iter_;
	NSString			*title_;
	
	iter_ = [itemTitles objectEnumerator];
	while(title_ = [iter_ nextObject]){
		UTILAssertKindOfClass(title_, NSString);
		[self addItemWithTitle : title_];
	}
}

#pragma mark -

+ (void) popUpContextMenu : (NSMenu *) aMenu
			      forView : (NSView *) aView
				       at : (NSPoint ) location
{
	NSEvent		*cEvent_;
	NSEvent		*newEvent_;
	
	int			type_;
	int			clickCount_;
	float		pressure_;
	
	// 表示位置を調整するため、ダミーのイベントを生成する
	cEvent_ = [[aView window] currentEvent];
	type_   = [cEvent_ type];
	
	switch(type_){
	case NSLeftMouseDown : 
	case NSLeftMouseUp : 
	case NSRightMouseDown : 
	case NSRightMouseUp : 
	case NSMouseMoved : 
	case NSLeftMouseDragged : 
	case NSRightMouseDragged : 
	case NSMouseEntered : 
	case NSMouseExited : 
		clickCount_ = [cEvent_ clickCount];
		pressure_   = [cEvent_ pressure];
		break;
	default :
		type_       = NSLeftMouseDown;
		clickCount_ = 0;
		pressure_   = 0;
		break;
	}
	

	newEvent_ = [NSEvent mouseEventWithType : type_
						location : location
						modifierFlags : [cEvent_ modifierFlags]
						timestamp : [cEvent_ timestamp]
						windowNumber : [cEvent_ windowNumber]
						context : [cEvent_ context]
						eventNumber : [cEvent_ eventNumber] +1
						clickCount : clickCount_
						pressure : pressure_];
	
	[NSMenu popUpContextMenu : aMenu
				   withEvent : newEvent_
				     forView : aView];
}
@end
