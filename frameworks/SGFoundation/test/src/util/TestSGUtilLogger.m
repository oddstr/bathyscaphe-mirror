//: TestSGUtilLogger.m
/**
  * $Id: TestSGUtilLogger.m,v 1.1 2005/05/11 17:51:46 tsawada2 Exp $
  * 
  * Copyright (c) 2001-2003, Takanori Ishikawa.  All rights reserved.
  * See the file LICENSE for copying permission.
  */

#import "TestSGUtilLogger.h"


@implementation TestSGUtilLogger
- (void) setUp
{
	;
}
- (void) tearDown
{
	;
}
- (void) test_sharedInstance
{
	[self assert : [SGUtilLogger sharedInstance]
		  equals : SGLogger()
		 message : @"shared instance"];
	[self assertNotNil : [SGUtilLogger sharedInstance]];
	[self assertNotNil : SGLogger()];
}
- (void) test_loggerNamed
{
	NSString		*name_ = @"foo.bar.hoge";
	SGUtilLogger	*logger_;
	
	logger_ = [SGUtilLogger loggerNamed : name_];
	[self assert : logger_
		  equals : [SGUtilLogger loggerNamed : name_]
		 message : @"loggerNamed"];
	[self assertNotNil : logger_];
	[self assertString : [logger_ name]
				equals : name_];

}
@end
