/**
  * $Id: NSBundle+AppSupport.m,v 1.1 2005/05/11 17:51:45 tsawada2 Exp $
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
@end
