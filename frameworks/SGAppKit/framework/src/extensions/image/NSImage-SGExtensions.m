//: NSImage-SGExtensions.m
/**
  * $Id: NSImage-SGExtensions.m,v 1.3 2006/04/11 17:31:21 masakih Exp $
  * 
  * Copyright (c) 2001-2003, Takanori Ishikawa.  All rights reserved.
  * See the file LICENSE for copying permission.
  */

#import "NSImage-SGExtensions.h"
#import "SGAppKitFrameworkDefines.h"
#import <SGFoundation/NSBundle+AppSupport.h>
#define SHOULD_FIX_BAD_SEARCH_RESOURCE_BEHAVIOUR	YES


@implementation NSImage(SGExtensionDrawing)
- (void) drawSourceAtPoint : (NSPoint) aPoint;
{
	[self drawAtPoint : aPoint
			 fromRect : NSZeroRect
			operation : NSCompositeSourceOver
			 fraction : 1.0];
}
- (void) drawSourceInRect : (NSRect) aRect
{
	[self drawInRect : aRect
			fromRect : NSZeroRect
		   operation : NSCompositeSourceOver
			fraction : 1.0];
}
- (id) imageBySettingAlphaValue : (float) delta
{
	NSImage		*newImage_;
	
	newImage_ = [[NSImage allocWithZone : [self zone]]
						   initWithSize : [self size]];
	[newImage_ lockFocus];
	{
		[self drawAtPoint : NSZeroPoint
				 fromRect : NSZeroRect
				operation : NSCompositeSourceOver
				 fraction : delta];
	}
	[newImage_ unlockFocus];
	
	return [newImage_ autorelease];
}
@end



@implementation NSImage(SGExtensionsLoad)
+ (id) imageNamed : (NSString *) aName 
   loadFromBundle : (NSBundle *) aBundle
	  inDirectory : (NSString *) aDirectory
{
	NSImage		*image_;
	NSString	*filepath_;
	
	image_ = [self imageNamed : aName];
	if(image_ != nil) return image_;
	
	filepath_ = [aBundle searchPathForImageResource:aName ofType:[aName pathExtension] inDirectory:aDirectory];
	
	
	if(nil == filepath_) return nil;

	image_ = [[self alloc] initWithContentsOfFile : filepath_];
	[image_ setName : aName];
	
	// -[NSImage setName:]で登録する画像はreleaseしない
	return image_;
}
+ (id) imageNamed : (NSString *) aName 
   loadFromBundle : (NSBundle *) aBundle
{
	return [self imageNamed:aName loadFromBundle:aBundle inDirectory:nil];
}

// CocoMonar Framework : NSBundle+CMRExtensions.m から統合
+ (id) imageAppNamed : (NSString *) aName
{
	static NSMutableDictionary *userImageCache;
	NSImage				*image_;
	NSString			*filepath_;
	
	if(nil == aName) return nil;
	if(nil == userImageCache)
		userImageCache = [[NSMutableDictionary alloc] init];
	
	image_ = [userImageCache objectForKey : aName];
	if(image_ != nil) return image_;
	
	filepath_ = [[NSBundle applicationSpecificBundle] pathForImageResource : aName];
	if(filepath_ != nil)
		image_ = [[self alloc] initWithContentsOfFile : filepath_];
	
	if(nil == image_)
		image_ = [[self imageNamed : aName] retain];
	
	if(nil == image_)
		return nil;
	
	[userImageCache setObject:image_ forKey:aName];
	[image_ release];
	
	return image_;
}
@end



@implementation NSBundle(SGAppKitExtensions)
- (NSString *) searchPathForImageResource : (NSString *) aName 
								   ofType : (NSString *) aType
{
	return [self searchPathForImageResource:aName ofType:aType inDirectory:nil];
}
- (NSString *) searchPathForImageResource : (NSString *) aName 
								   ofType : (NSString *) aType
							  inDirectory : (NSString *) aDirectory
{
	if(nil == aDirectory || 0 == [aDirectory length])
		return [self pathForImageResource : aName];
	
	return [self searchPathForResource : aName 
								ofType : aType
						   inDirectory : aDirectory
							 fileTypes : [NSImage imageFileTypes]];
}
- (NSString *) searchPathForResource : (NSString *) aName 
							  ofType : (NSString *) aType
						 inDirectory : (NSString *) aDirectory
						   fileTypes : (NSArray  *) anyTypes
{
	NSString		*filepath_;
	NSString		*HFSFileType_;
	
	if(nil == aDirectory || 0 == [aDirectory length])
		filepath_ = [self pathForResource:aName ofType:aType];
	else
		filepath_ = [self pathForResource:aName ofType:aType inDirectory:aDirectory];
	
	if(nil == filepath_){
		// ofType:extensionに@""(or nil) を渡しても拡張子を無視して探してくれないようなので
		// + [NSImage imageFileTypes]の候補から探す。
		if((nil == aType || 0 == [aType length]) && SHOULD_FIX_BAD_SEARCH_RESOURCE_BEHAVIOUR){
			NSEnumerator		*iter_;
			NSString			*type_;
			
			iter_ = [anyTypes objectEnumerator];
			while(type_ = [iter_ nextObject]){
				if(nil == aDirectory || 0 == [aDirectory length])
					filepath_ = [self pathForResource:aName ofType:type_];
				else
					filepath_ = [self pathForResource:aName ofType:type_ inDirectory:aDirectory];
				
				if(filepath_ != nil) break;
			}
		}
		if(nil == filepath_) return nil;
	}
	
	if(nil == anyTypes || 0 == [anyTypes count])
		return filepath_;
	
	if([anyTypes containsObject : [filepath_ pathExtension]])
		return filepath_;
	
	HFSFileType_ = NSHFSTypeOfFile(filepath_);
	if([anyTypes containsObject : HFSFileType_])
		return filepath_;
	
	return nil;
}
@end
