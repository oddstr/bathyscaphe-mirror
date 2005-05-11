//: SGUtilLogHandler.m
/**
  * $Id: SGUtilLogHandler.m,v 1.1.1.1 2005/05/11 17:51:45 tsawada2 Exp $
  * 
  * Copyright (c) 2001-2003, Takanori Ishikawa.  All rights reserved.
  * See the file LICENSE for copying permission.
  */

#import "SGUtilLogHandler.h"
#import "SGUtilLogRecord.h"
#import "SGUtilLogFormatter.h"
#import "UTILKit.h"


@implementation SGUtilLogHandler
+ (id) logHandler
{
	return [[[self alloc] init] autorelease];
}
- (id) init
{
	if(self = [super init]){
		[self setEncoding : NSShiftJISStringEncoding];
		[self setLevel : kSGLoggingLevelAll];
	}
	return self;
}
- (void) dealloc
{
	[_formatter release];
	[super dealloc];
}
- (void) close
{
	UTILAbstractMethodInvoked;
}
- (void) flush;
{
	UTILAbstractMethodInvoked;
}
- (void) publishMessage : (NSString *) aMessage
{
	UTILAbstractMethodInvoked;
}
- (void) publish : (SGUtilLogRecord *) aRecord
{
	NSString			*msg_;
	NSString			*head_;
	NSString			*tail_;
	SGUtilLogFormatter	*formatter_;
	
	if(NO == [self loggable : aRecord])
		return;
	
	formatter_ = [self logFormatter];
	msg_ = [formatter_ format : aRecord];
	
	head_ = [formatter_ header : self];
	tail_ = [formatter_ tail : self];
	if(head_ != nil)
		msg_ = [head_ stringByAppendingString : msg_];
	if(tail_ != nil)
		msg_ = [msg_ stringByAppendingString : tail_];
	
	[self publishMessage : msg_];
}

- (BOOL) loggable : (SGUtilLogRecord *) aRecord
{
	if(nil == aRecord || nil == [aRecord message])
		return NO;
	
	if([self level] > [aRecord level])
		return NO;
	
	return YES;
}
- (NSStringEncoding) encoding
{
	return _encoding;
}
- (void) setEncoding : (NSStringEncoding) anEncoding
{
	_encoding = anEncoding;
}
- (SGLoggingLevel) level
{
	return _level;
}
- (void) setLevel : (SGLoggingLevel) aLevel
{
	_level = aLevel;
}
- (SGUtilLogFormatter *) logFormatter
{
	return _formatter;
}
- (void) setLogFormatter : (SGUtilLogFormatter *) aFormatter
{
	id		tmp;
	
	tmp = _formatter;
	_formatter = [aFormatter retain];
	[tmp release];
}
@end
