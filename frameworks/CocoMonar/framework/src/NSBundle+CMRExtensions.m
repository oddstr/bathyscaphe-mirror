/**
  * $Id: NSBundle+CMRExtensions.m,v 1.1 2005/05/11 17:51:19 tsawada2 Exp $
  * 
  * NSBundle+CMRExtensions.m
  *
  * Copyright (c) 2003, Takanori Ishikawa.
  * See the file LICENSE for copying permission.
  */
#import "NSBundle+CMRExtensions.h"
#import "UTILKit.h"

#define kSupportDirectoryName		@"CocoMonar"



@implementation NSImage(CMRExtensions)
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



@implementation NSBundle(CMRExtensions)
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
