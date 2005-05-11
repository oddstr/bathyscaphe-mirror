/**
 * $Id: NSDate-SGExtensions.h,v 1.1.1.1 2005/05/11 17:51:44 tsawada2 Exp $
 * 
 * NSDate-SGExtensions.h
 *
 * Copyright (c) 2004 Takanori Ishikawa, All rights reserved.
 * See the file LICENSE for copying permission.
 */
#import <Foundation/Foundation.h>
#import <CoreServices/CoreServices.h>



@interface NSDate(SGExtensions)
+ (id) date1904;
+ (id) dateWithTimeIntervalSince1904 : (NSTimeInterval) seconds;
- (NSTimeInterval) timeIntervalSince1904;

//
// Working with utcDateTime
// 
// <CarbonCore/UTCUtils.h>
//
+ (id) dateWithUTCDateTime : (const UTCDateTime *) utcDateTime;
- (void) getUTCDateTime : (UTCDateTime *) utcDateTime;

// shortcut (NSOrderedDescending == [self compare : otherDate])
- (BOOL) isAfterDate : (NSDate *) otherDate;
// shortcut (NSOrderedAscending == [self compare : otherDate])
- (BOOL) isBeforeDate : (NSDate *) otherDate;

//
// Utilities for HTTP header
//
/**
  * same as:
  * descriptionWithCalendarFormat : format
  *  timeZone : [NSTimeZone timeZoneWithName : @"GMT"]
  *    locale : nil];
  * 
  * @param    format  Format
  * @return           description
  */
- (NSString *) descriptionWithCalendarFormatGMT : (NSString *) format;

/*!
 * @method        descriptionAsRFC1123
 * @abstract      Return the RFC 1123 format desctiption
 * @discussion    Return the RFC 1123 format desctiption
 * @result        RFC 1123 format desctiption
 */
- (NSString *) descriptionAsRFC1123;

/*!
 * @method        descriptionAsRFC1036
 * @abstract      Return the RFC 1036 format desctiption
 * @discussion    Return the RFC 1036 format desctiption
 * @result        RFC 1036 format desctiption
 */
- (NSString *) descriptionAsRFC1036;

/*!
 * @method        descriptionAsASCTime
 * @abstract      Return the ASCII asctime() format desctiption
 * @discussion    Return the ASCII asctime() format desctiption
 * @result        asctime() format desctiption
 */
- (NSString *) descriptionAsASCTime;
@end
