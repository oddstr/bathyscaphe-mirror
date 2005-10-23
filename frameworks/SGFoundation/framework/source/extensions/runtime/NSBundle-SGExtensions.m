//: NSBundle-SGExtensions.m
/**
  * $Id: NSBundle-SGExtensions.m,v 1.2 2005/10/23 14:47:26 tsawada2 Exp $
  * 
  * Copyright (c) 2001-2003, Takanori Ishikawa.  All rights reserved.
  * See the file LICENSE for copying permission.
  */

#import "NSBundle-SGExtensions.h"
#import <AppKit/NSImage.h>



#define SHOULD_FIX_BAD_SEARCH_RESOURCE_BEHAVIOUR		YES


#define kCFBuncleExecutableKey		@"CFBundleExecutable"
#define kCFBuncleVersionKey		@"CFBundleVersion"
#define kCFBundleHelpBookKey	@"CFBundleHelpBookName"


@implementation NSBundle(SGExtentions)
+ (NSDictionary *) applicationInfoDictionary
{
	return [[self mainBundle] infoDictionary];
}

+ (NSDictionary *) localizedAppInfoDictionary
{
	return [[self mainBundle] localizedInfoDictionary];
}

+ (NSString *) applicationName
{
	return [[self applicationInfoDictionary] objectForKey : kCFBuncleExecutableKey];
}
+ (NSString *) applicationVersion
{
	return [[self applicationInfoDictionary] objectForKey : kCFBuncleVersionKey];
}
+ (NSString *) applicationHelpBookName
{
	return [[self localizedAppInfoDictionary] objectForKey : kCFBundleHelpBookKey];
}

- (NSString *) pathForResourceWithName : (NSString *) fileName
{
	return [self pathForResource : [fileName stringByDeletingPathExtension]
						  ofType : [fileName pathExtension]];
}
- (NSString *) pathForResourceWithName : (NSString *) fileName
                           inDirectory : (NSString *) dirName
{
	return [self pathForResource : [fileName stringByDeletingPathExtension]
						  ofType : [fileName pathExtension]
				     inDirectory : dirName];
}
@end
