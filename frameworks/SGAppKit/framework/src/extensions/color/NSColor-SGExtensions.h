//: NSColor-SGExtensions.h
/**
  * $Id: NSColor-SGExtensions.h,v 1.1 2005/05/11 17:51:26 tsawada2 Exp $
  * 
  * Copyright (c) 2001-2003, Takanori Ishikawa.
  * See the file LICENSE for copying permission.
  */

#import <Cocoa/Cocoa.h>



@interface NSColor(iTunesSkin)
// iTunesのテーブルの薄い水色
+ (NSColor *) iTunesStripedColor;
@end


// NSColor <--> NSString
extern NSString	*SGStringFromColor(NSColor *aColor);
extern NSColor	*SGColorFromString(NSString *aString);
