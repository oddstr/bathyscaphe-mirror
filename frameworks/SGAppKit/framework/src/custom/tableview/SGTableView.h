//: SGTableView.h
/**
  * $Id: SGTableView.h,v 1.1 2005/05/11 17:51:26 tsawada2 Exp $
  * 
  * Copyright (c) 2001-2003, Takanori Ishikawa.  All rights reserved.
  * See the file LICENSE for copying permission.
  */

#import <Cocoa/Cocoa.h>



@interface SGTableView : NSTableView
{
	@private
	NSFont		*_font;
	NSColor		*_stripedColor;
	BOOL		_drawsStriped;
	
	BOOL		_showsToolTipForRow;
}
@end
