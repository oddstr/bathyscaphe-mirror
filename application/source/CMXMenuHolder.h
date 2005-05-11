//: CMXMenuHolder.h
/**
  * $Id: CMXMenuHolder.h,v 1.1 2005/05/11 17:51:03 tsawada2 Exp $
  * 
  * Copyright (c) 2001-2003, Takanori Ishikawa.
  * See the file LICENSE for copying permission.
  */

#import <Cocoa/Cocoa.h>


@interface CMXMenuHolder : NSObject
{
	IBOutlet NSMenu		*_menu;
}
+ (NSMenu *) menuFromBundle : (NSBundle *) bundle
			        nibName : (NSString *) nibName;
- (id) initWithBundle : (NSBundle *) bundle
			  nibName : (NSString *) nibName;
- (NSMenu *) menu;
@end
