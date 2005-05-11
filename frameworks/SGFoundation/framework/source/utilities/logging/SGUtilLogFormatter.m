//: SGUtilLogFormatter.m
/**
  * $Id: SGUtilLogFormatter.m,v 1.1.1.1 2005/05/11 17:51:45 tsawada2 Exp $
  * 
  * Copyright (c) 2001-2003, Takanori Ishikawa.  All rights reserved.
  * See the file LICENSE for copying permission.
  */

#import "SGUtilLogFormatter.h"
#import <SGFoundation/SGUtilLogHandler.h>
#import <SGFoundation/SGUtilLogRecord.h>

#import <SGFoundation/NSBundle-SGExtensions.h>
#import "UTILKit.h"


@implementation SGUtilLogFormatter
- (NSString *) format : (SGUtilLogRecord *) record
{
	return [record message];
}
- (NSString *) header : (SGUtilLogHandler *) handler
{
	return nil;
}
- (NSString *) tail : (SGUtilLogHandler *) handler
{
	return nil;
}
@end



@implementation SGUtilNSLogLikeFormatter
- (NSString *) format : (SGUtilLogRecord *) record
{
	return [NSString stringWithFormat : @"[%@ %@]%@\n",
				[NSBundle applicationName],
				[record date],
				[record message]];
}
@end
