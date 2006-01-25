/**
  * $Id: NSBundle+AppSupport.m,v 1.2 2006/01/25 11:22:03 tsawada2 Exp $
  * 
  * NSBundle+AppSupport.m
  *
  * Copyright (c) 2003, Takanori Ishikawa.
  * See the file LICENSE for copying permission.
  */
#import "NSBundle+AppSupport.h"
#import <SGFoundation/SGFile+AppSupport.h>


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
