/**
 * $Id: NSDate-SGExtensions.m,v 1.1.1.1 2005/05/11 17:51:44 tsawada2 Exp $
 * 
 * NSDate-SGExtensions.m
 *
 * Copyright (c) 2004 Takanori Ishikawa, All rights reserved.
 * See the file LICENSE for copying permission.
 */

#import <SGFoundation/NSDate-SGExtensions.h>
#import <SGFoundation/PrivateDefines.h>


@implementation NSDate(SGExtensions)
+ (id) date1904
{
	static id st_date1904 = nil;
	
	if(nil == st_date1904){
		st_date1904 = [[NSDate alloc] initWithString : DATE_1904_JUN_1_FORMAT];
	}
	return st_date1904;
}

+ (id) dateWithTimeIntervalSince1904 : (NSTimeInterval) seconds
{
	return [[self date1904] addTimeInterval : seconds];
}

- (NSTimeInterval) timeIntervalSince1904
{
	return [self timeIntervalSinceDate : [[self class] date1904]];
}
//
// Working with utcDateTime
// 
// <CarbonCore/UTCUtils.h>
//
+ (id) dateWithUTCDateTime : (const UTCDateTime *) utcDateTime
{
    union {
        UTCDateTime local;
        UInt64 shifted;
    } time;
    time.local = *utcDateTime;
   
    return time.shifted 
            ? [self dateWithTimeIntervalSince1904:time.shifted/65536]
            : nil;
}
- (void) getUTCDateTime : (UTCDateTime *) utcDateTime
{
    union {
        UTCDateTime local;
        UInt64 shifted;
    } result;
    result.shifted = [self timeIntervalSince1904];
    if (utcDateTime != NULL) *utcDateTime = result.local;
}



- (BOOL) isAfterDate : (NSDate *) otherDate
{
	return (NSOrderedDescending == [self compare : otherDate]);
}
- (BOOL) isBeforeDate : (NSDate *) otherDate
{
	return (NSOrderedAscending == [self compare : otherDate]);
}


- (NSString *) descriptionWithCalendarFormatGMT : (NSString *) format
{
	return [self descriptionWithCalendarFormat : format
			timeZone : [NSTimeZone timeZoneWithName : @"GMT"]
			locale : nil];
}
- (NSString *) descriptionAsRFC1123
{
	return [self descriptionWithCalendarFormatGMT : RFC1123_CALENDAR_FORMAT];
}
- (NSString *) descriptionAsRFC1036
{
	return [self descriptionWithCalendarFormatGMT : RFC1036_CALENDAR_FORMAT];
}
- (NSString *) descriptionAsASCTime
{
	return [self descriptionWithCalendarFormatGMT : ASCTIME_CALENDAR_FORMAT];
}
@end
