//: SGUtilLogRecord.m
/**
  * $Id: SGUtilLogRecord.m,v 1.1.1.1 2005/05/11 17:51:45 tsawada2 Exp $
  * 
  * Copyright (c) 2001-2003, Takanori Ishikawa.  All rights reserved.
  * See the file LICENSE for copying permission.
  */

#import "SGUtilLogRecord.h"


@implementation SGUtilLogRecord
+ (id) logRecordWithLevel : (SGLoggingLevel) aLevel
			      message : (NSString     *) msg
{
	return [[[self alloc] initWithLevel : aLevel
							    message : msg] autorelease];
}
- (id) initWithLevel : (SGLoggingLevel) aLevel
			 message : (NSString     *) msg
{
	if(self = [super init]){
		[self setLevel : aLevel];
		[self setMessage : msg];
		
		[self setDate : [NSCalendarDate date]];
		[self setThreadID : (unsigned long)[NSThread currentThread]];
	}
	return self;
}
- (void) dealloc
{
	[_message release];
	[_date release];
	[super dealloc];
}

- (id) copyWithZone : (NSZone *) aZone
{
	id		tmp;
	
	tmp = [[[self class] allocWithZone : aZone] 
			initWithLevel : [self level]
				  message : [self message]];
	[tmp setLoggerName : [self loggerName]];
	[tmp setDate : [self date]];
	[tmp setThreadID : [self threadID]];
	
	return tmp;
}

- (NSString *) message
{
	return _message;
}
- (SGLoggingLevel) level
{
	return _level;
}
- (NSString *) loggerName
{
	return loggerName;
}
- (NSCalendarDate *) date
{
	return _date;
}
- (unsigned long) threadID
{
	return _threadID;
}
- (void) setMessage : (NSString *) aMessage
{
	id		tmp;
	
	tmp = _message;
	_message = [aMessage retain];
	[tmp release];
}
- (void) setLevel : (SGLoggingLevel) aLevel
{
	_level = aLevel;
}
- (void) setLoggerName : (NSString *) aLoggerName
{
	id		tmp;
	
	tmp = loggerName;
	loggerName = [aLoggerName retain];
	[tmp release];
}
- (void) setDate : (NSCalendarDate *) aDate
{
	id		tmp;
	
	tmp = _date;
	_date = [aDate retain];
	[tmp release];
}
- (void) setThreadID : (unsigned long) aThreadID
{
	_threadID = aThreadID;
}

@end
