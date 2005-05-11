//: NSMenu+CMXAdditions.m
/**
  * $Id: NSMenu+CMXAdditions.m,v 1.1 2005/05/11 17:51:05 tsawada2 Exp $
  * 
  * Copyright (c) 2001-2003, Takanori Ishikawa.  All rights reserved.
  * See the file LICENSE for copying permission.
  */

#import "NSMenu+CMXAdditions.h"


@implementation NSMenu(CMXAdditions)
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
