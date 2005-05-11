//: SGUtilLogFileHandler.m
/**
  * $Id: SGUtilLogFileHandler.m,v 1.1 2005/05/11 17:51:45 tsawada2 Exp $
  * 
  * Copyright (c) 2001-2003, Takanori Ishikawa.  All rights reserved.
  * See the file LICENSE for copying permission.
  */

#import "SGUtilLogFileHandler.h"
#import "SGUtilLogRecord.h"
#import "SGUtilLogFormatter.h"


@implementation SGUtilLogFileHandler
+ (id) logHandlerWithFileHandle : (NSFileHandle *) fhandle
{
	return [[[self alloc] initWithFileHandle : fhandle] autorelease];
}
- (id) initWithFileHandle : (NSFileHandle *) fhandle
{
	if(self = [super init]){
		[self setFileHandle : fhandle];
	}
	return self;
}
- (void) dealloc
{
	[_fileHandle release];
	[super dealloc];
}
- (void) close
{
	[[self fileHandle] closeFile];
}
- (void) flush
{
	[[self fileHandle] synchronizeFile];
}
- (void) publishMessage : (NSString *) message
{
	[[self fileHandle] writeData : 
		[message dataUsingEncoding : [self encoding]]];
}
- (NSFileHandle *) fileHandle
{
	return _fileHandle;
}
- (void) setFileHandle : (NSFileHandle *) aFileHandle
{
	id		tmp;
	
	tmp = _fileHandle;
	_fileHandle = [aFileHandle retain];
	[tmp release];
}
@end



@implementation SGUtilLogConsoleHandler : SGUtilLogFileHandler
- (void) close
{
}
- (void) flush
{
	fflush(stdout);
}
- (void) publishMessage : (NSString *) msg
{
	NSLog(@"%@", msg);
}
- (SGUtilLogFormatter *) logFormatter
{
	if(nil == _formatter)
		_formatter = [[SGUtilLogFormatter alloc] init];
	
	return _formatter;
}
- (NSFileHandle *) fileHandle
{
	return nil;
}
- (void) setFileHandle : (NSFileHandle *) aFileHandle
{
}
@end
