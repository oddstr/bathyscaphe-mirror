/**
  * $Id: SGFile+AppSupport.m,v 1.2 2005/11/25 20:21:24 tsawada2 Exp $
  * 
  * SGFile+AppSupport.m
  *
  * Copyright (c) 2003, Takanori Ishikawa.
  * See the file LICENSE for copying permission.
  */
#import "SGFile+AppSupport.h"
#import <SGFoundation/NSBundle-SGExtensions.h>

#import "UTILKit.h"



@implementation SGFileRef(SGApplicationSupport)
// ~/Library/Application Support
+ (SGFileRef *) applicationSupportFolderRef
{
	SGFileRef	*f;

	f = [self searchDirectoryInDomain : kUserDomain
						   folderType : kApplicationSupportFolderType
						   willCreate : YES];
	if(nil == f){
		NSLog(@"%@ Can't locate special folder <Application Support>",
			UTIL_HANDLE_FAILURE_IN_METHOD);
	}
	return f;
}
// ~/Library/Application Support/(ExecutableName)
+ (SGFileRef *) applicationSpecificFolderRef
{
	static SGFileRef	*supportDirRef_;
	
	if(nil == supportDirRef_){
		SGFileRef	*f;
		NSString	*executableName_;
		
		executableName_ = [NSBundle applicationName];
		if(nil == executableName_){
			NSLog(@"%@ No Executable.", UTIL_HANDLE_FAILURE_IN_METHOD);
			
			return nil;
		}
		
		f = [self applicationSupportFolderRef];
		if(nil == f) return nil;
		
		
		f = [f fileRefWithChildName:executableName_ createDirectory:YES];
		
		f =  [f fileRefResolvingLinkIfNeeded];

		if(nil == f || NO == [f isDirectory]) {
			NSLog(@"%@ Can't locate special folder <Application Support/%@>",
					executableName_,
					UTIL_HANDLE_FAILURE_IN_METHOD);
			return nil;
		}
		
		supportDirRef_ = [f retain];
	}
	return supportDirRef_;
}
@end
