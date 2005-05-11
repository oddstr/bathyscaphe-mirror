//: NSImage-SGExtensions.h
/**
  * $Id: NSImage-SGExtensions.h,v 1.1 2005/05/11 17:51:26 tsawada2 Exp $
  * 
  * Copyright (c) 2001-2003, Takanori Ishikawa.  All rights reserved.
  * See the file LICENSE for copying permission.
  */

#import <Cocoa/Cocoa.h>



@interface NSImage(SGExtensionDrawing)
- (void) drawSourceAtPoint : (NSPoint) aPoint;
- (void) drawSourceInRect : (NSRect) aPoint;
- (id) imageBySettingAlphaValue : (float) delta;
@end



@interface NSImage(SGExtensionsLoad)
+ (id) imageNamed : (NSString *) aName 
   loadFromBundle : (NSBundle *) aBundle
	  inDirectory : (NSString *) aDirectory;
+ (id) imageNamed : (NSString *) aName 
   loadFromBundle : (NSBundle *) aBundle;
@end



@interface NSBundle(SGAppKitExtensions)
- (NSString *) searchPathForImageResource : (NSString *) aName 
								   ofType : (NSString *) aType;
- (NSString *) searchPathForImageResource : (NSString *) aName 
								   ofType : (NSString *) aType
							  inDirectory : (NSString *) aDirectory;
- (NSString *) searchPathForResource : (NSString *) aName 
							  ofType : (NSString *) aType
						 inDirectory : (NSString *) aDirectory
						   fileTypes : (NSArray  *) anyTypes;
@end