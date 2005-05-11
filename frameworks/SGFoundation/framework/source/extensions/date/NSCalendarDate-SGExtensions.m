/**
 * $Id: NSCalendarDate-SGExtensions.m,v 1.1 2005/05/11 17:51:44 tsawada2 Exp $
 * 
 * NSCalendarDate-SGExtensions.m
 *
 * Copyright (c) 2004 Takanori Ishikawa, All rights reserved.
 * See the file LICENSE for copying permission.
 */

#import <SGFoundation/NSCalendarDate-SGExtensions.h>
#import <SGFoundation/PrivateDefines.h>
#import <Foundation/NSScanner.h>
#import <Foundation/NSString.h>
#import <Foundation/NSTimeZone.h>
#import <Foundation/NSCalendarDate.h>



@implementation NSCalendarDate(SGExtensions)
+ (id) dateWithHTTPTimeRepresentation : (NSString *) desc
{
	return [[[self alloc] initWithHTTPTimeRepresentation : desc] autorelease];
}
- (id) initWithHTTPTimeRepresentation : (NSString *) desc
{
	if(nil == desc || 0 == [desc length]){
		[self release];
		return nil;
	}
	
	self = [self initWithString : desc
				 calendarFormat : RFC1123_CALENDAR_FORMAT];
	if(nil == self){
		self = [[NSCalendarDate alloc] initWithString : desc
					calendarFormat : RFC1036_CALENDAR_FORMAT];
	}
	if(nil == self){
		self = [[NSCalendarDate alloc] initWithString : desc
					calendarFormat : ASCTIME_CALENDAR_FORMAT];
	}
	if(nil == self){
		NSScanner      *scanner_;
		NSTimeInterval  interval_;
		
		interval_ = 0.0;
		scanner_ = [NSScanner scannerWithString : desc];
		if(NO == [scanner_ scanDouble : &interval_])
			return nil;
		
		self = [[NSCalendarDate dateWithTimeIntervalSince1970 : interval_] retain];
	}
	return self;
}
@end