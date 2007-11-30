//: NSBundle-SGExtensions.m
/**
  * $Id: NSBundle-SGExtensions.m,v 1.4 2007/11/30 01:01:17 tsawada2 Exp $
  * 
  * Copyright (c) 2001-2003, Takanori Ishikawa.  All rights reserved.
  * See the file LICENSE for copying permission.
  */

#import "NSBundle-SGExtensions.h"
#import "SGFile+AppSupport.h"
#import <SGFoundation/SGFileRef.h>


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


@implementation NSBundle(SGApplicationSupport)
// ~/Library/Application Support/(ExecutableName)
+ (NSBundle *) applicationSpecificBundle
{
	SGFileRef		*reference_;
	
	reference_ = [SGFileRef applicationSpecificFolderRef];
	return [NSBundle bundleWithPath : [reference_ filepath]];
}

// Merged from CMF
+ (NSDictionary *) mergedDictionaryWithName : (NSString *) filename
{
	NSString	*filepath_;
	id			dict_ = nil;
	
	filepath_ = [[NSBundle mainBundle] pathForResourceWithName : filename];
	if(filepath_ != nil)
		dict_ = [NSMutableDictionary dictionaryWithContentsOfFile : filepath_];
	
	filepath_ = [[NSBundle applicationSpecificBundle] pathForResourceWithName : filename];
	UTILRequireCondition(filepath_, ReturnCopiedDictionary);
	
	if(nil == dict_){
		dict_ = [NSMutableDictionary dictionaryWithContentsOfFile : filepath_];
	}else{
		id		tmp;
		
		tmp = [NSDictionary dictionaryWithContentsOfFile : filepath_];
		UTILRequireCondition(tmp, ReturnCopiedDictionary);
		[dict_ addEntriesFromDictionary : tmp];
	}
	
ReturnCopiedDictionary:
	return [[dict_ copy] autorelease];
}
@end
