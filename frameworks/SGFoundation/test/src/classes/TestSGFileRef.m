//: TestSGFileRef.m
/**
  * $Id: TestSGFileRef.m,v 1.1.1.1 2005/05/11 17:51:46 tsawada2 Exp $
  * 
  * Copyright (c) 2001-2003, Takanori Ishikawa.  All rights reserved.
  * See the file LICENSE for copying permission.
  */

#import "TestSGFileRef.h"


@implementation TestSGFileRef
- (void) setUp
{
	;
}
- (void) tearDown
{
	;
}
- (void) test_homeDir_name
{
	SGFileRef	*fileRef_;
	NSString	*path_;
	
	path_ = NSHomeDirectory();
	
	fileRef_ = [SGFileRef fileRefWithPath : path_];
	[self assertNotNil : fileRef_
			   message : @"fileRefWithPath"];
	
	[self assert : [NSURL fileURLWithPath : path_]
		  equals : [fileRef_ fileURL]
		  message : @"fileURL"];
	
	[self assertString : [fileRef_ filepath]
			equals : path_
			message : @"path"];
	[self assertString : [fileRef_ filename]
			equals : [path_ lastPathComponent]
			message : @"filename"];
	[self assertString : [fileRef_ pathExtension]
			equals : [path_ pathExtension]
			message : @"pathExtension"];
	
}
- (void) test_homeDir_type
{
	SGFileRef	*fileRef_;
	NSString	*path_;
	
	path_ = NSHomeDirectory();
	
	fileRef_ = [SGFileRef fileRefWithPath : path_];
	[self assertNotNil : fileRef_
			   message : @"fileRefWithPath"];
	
	[self assertTrue : [fileRef_ isDirectory]];
	[self assertFalse : [fileRef_ isPackage]
			message : @"isPackage"];
}
@end
