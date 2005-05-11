//: SGUtilLogger.m
/**
  * $Id: SGUtilLogger.m,v 1.1.1.1 2005/05/11 17:51:45 tsawada2 Exp $
  * 
  * Copyright (c) 2001-2003, Takanori Ishikawa.  All rights reserved.
  * See the file LICENSE for copying permission.
  */

#import "SGUtilLogger.h"
#import "PrivateDefines.h"
#import <stdarg.h>
#import <limits.h>

#import "SGUtilLogRecord.h"
#import "SGUtilLogHandler.h"


// 共有インスタンスの名前
static NSString *SGLoggerSharedInstanceName(void);



SGUtilLogger *SGLogger(void)
{
	return [SGUtilLogger sharedInstance];
}

static NSMutableDictionary *instance_tbl(void)
{
	static NSMutableDictionary *kSGUtilLoggerInstanceTbl = nil;
	
	if(nil == kSGUtilLoggerInstanceTbl)
		kSGUtilLoggerInstanceTbl = 
			[[NSMutableDictionary alloc] init];
	
	return kSGUtilLoggerInstanceTbl;
}


@interface SGUtilLogger(Private)
- (void) setName : (NSString *) aName;
- (NSMutableArray *) handlers;
@end



@implementation SGUtilLogger
+ (SGUtilLogger *) sharedInstance
{
	return [self loggerNamed : SGLoggerSharedInstanceName()];
}
+ (SGUtilLogger *) loggerNamed : (NSString *) aName
{
	SGUtilLogger	*instance_;
	
	UTILAssertNotNilArgument(aName, @"Logger Name");
	
	instance_ = [instance_tbl() objectForKey : aName];
	if(nil == instance_){
		instance_ = [[[SGUtilLogger alloc] init] autorelease];
		[instance_ setName : aName];
		[instance_tbl() setObject:instance_ forKey:aName];
	}
	UTILAssertNotNil(instance_);
	
	return instance_;
}
+ (SGUtilLogger *) anonymousLogger;
{
	return [[[self alloc] init] autorelease];
}
- (id) init
{
	if(self = [super init]){
		[self handlers];
		[self setName : nil];
		[self setLevel : kSGLoggingLevelAll];
	}
	return self;
}
- (void) dealloc
{
	[_handlers release];
	[_name release];
	[super dealloc];
}
- (void) addHandler : (SGUtilLogHandler *) handler
{
	UTILAssertNotNilArgument(handler, @"Log Handler");
	
	[[self handlers] addObject : handler];
}
- (void) removeHandler : (SGUtilLogHandler *) handler
{
	if(nil == handler)
		return;
	
	[[self handlers] removeObject : handler];
}
- (NSString *) name
{
	return _name;
}
- (SGLoggingLevel) level
{
	return _level;
}
- (void) setLevel : (SGLoggingLevel) aLevel
{
	_level = aLevel;
}
- (void) logv : (SGLoggingLevel) aLevel
	   format : (NSString     *) format
	arguments : (va_list       ) args
{
	NSString		*msg_;
	SGUtilLogRecord	*record_;
	
	SGUtilLogHandler	*handler_;
	NSEnumerator		*iter_;
	
	if(0 == [[self handlers] count])
		return;
	
	if([self level] > aLevel)
		return;
	
	msg_ = [[NSString alloc] initWithFormat:format arguments:args];
	record_ = [SGUtilLogRecord logRecordWithLevel:aLevel message:msg_];
	[msg_ release];
	
	iter_ = [[self handlers] objectEnumerator];
	while(handler_ = [iter_ nextObject]){
		UTILAssertKindOfClass(handler_, SGUtilLogHandler);
		
		[handler_ publish : record_];
	}
}
@end



#define LOG_LEVEL_FORMAT(dlevel, dfmt)		\
	va_list		defined_vList;\
	\
	va_start(defined_vList, (dfmt));\
	[self logv:(dlevel) format:(dfmt) arguments:defined_vList];\
	va_end(defined_vList)\

@implementation SGUtilLogger(SGLoggingExtentions)
- (void) fine : (NSString *) format,...
{
	LOG_LEVEL_FORMAT(kSGLoggingLevelFine, format);
}
- (void) info : (NSString *) format,...;
{
	LOG_LEVEL_FORMAT(kSGLoggingLevelInfo, format);
}
- (void) warning : (NSString *) format,...;
{
	LOG_LEVEL_FORMAT(kSGLoggingLevelWarning, format);
}
- (void) severe : (NSString *) format,...;
{
	LOG_LEVEL_FORMAT(kSGLoggingLevelSevere   , format);
}
- (void) log : (SGLoggingLevel) aLevel
      format : (NSString     *) format,...
{
	LOG_LEVEL_FORMAT(aLevel, format);
}
@end
#undef LOG_LEVEL_FORMAT



@implementation SGUtilLogger(Private)
- (void) setName : (NSString *) aName
{
	id		tmp;
	
	tmp = _name;
	_name = [aName retain];
	[tmp release];
}
- (NSMutableArray *) handlers
{
	if(nil == _handlers)
		_handlers = [[NSMutableArray alloc] init];
	return _handlers;
}
@end



static NSString *SGLoggerSharedInstanceName(void)
{
	NSBundle	*bundle_;
	NSString	*identifier_;
	
	bundle_ = [NSBundle bundleForClass : [SGUtilLogger class]];
	UTILCAssertNotNil(bundle_);
	identifier_ = [bundle_ bundleIdentifier];
	UTILCAssertNotNil(identifier_);
	
	return [identifier_ stringByAppendingString : @".SGLoggerSharedInstance"];
}
