//: NSImage-SGExtensions.h
/**
  * $Id: NSImage-SGExtensions.h,v 1.1.1.1.4.2 2006/09/01 13:46:57 masakih Exp $
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
/*!
 * @method      imageAppNamed:preferUserDirectory:
 * @abstract    ユーザのサポートディレクトリを優先的に探す
 * @discussion  
 * @param name  画像名
 * @result      画像
 */
+ (id) imageAppNamed : (NSString *) aName;
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
