//
//  BSDateFormatter.m
//  BathyScaphe
//
//  Created by Tsutomu Sawada on 06/12/05.
//  Copyright 2006-2008 BathyScaphe Project. All rights reserved.
//  encoding="UTF-8"
//

#import "BSDateFormatter.h"
#import <CocoMonar/CMRSingletonObject.h>

static NSDate *AppGetBasicDataOfToday(void);

@implementation BSDateFormatter
static NSDate *cachedToday;
static NSDate *cachedYesterday;
static NSTimeInterval	cacheTimer;

APP_SINGLETON_FACTORY_METHOD_IMPLEMENTATION(sharedDateFormatter);

- (NSString *)niceStringFromDate:(NSDate *)date useTab:(BOOL)flag
{
	static CFDateFormatterRef	timFmtRef;
	static CFDateFormatterRef	dayFmtRef;
	NSString	*result_ = nil;
	NSString	*dayStr_ = nil;
	NSString	*format;

	NSDate	*today_ = AppGetBasicDataOfToday();
	NSComparisonResult compareToday_ = [date compare:today_];

	if (compareToday_ != NSOrderedAscending) {
		dayStr_ = NSLocalizedString(@"Today", @"Today");
	} else {
		NSComparisonResult compareYesterday_ = [date compare:cachedYesterday];

		if (compareYesterday_ != NSOrderedAscending) {
			dayStr_ = NSLocalizedString(@"Yesterday", @"Yesterday");
		} else {
			CFStringRef			dayStrRef;

			if (dayFmtRef == NULL) {
				CFLocaleRef	localeRef = CFLocaleCopyCurrent();
				dayFmtRef = CFDateFormatterCreate(kCFAllocatorDefault, localeRef, kCFDateFormatterShortStyle, kCFDateFormatterNoStyle);
				CFRelease(localeRef);
			}

			dayStrRef = CFDateFormatterCreateStringWithDate(kCFAllocatorDefault, dayFmtRef, (CFDateRef)date);

			if (dayStrRef != NULL) {
				dayStr_ = [NSString stringWithString:(NSString *)dayStrRef];
				CFRelease(dayStrRef);
			}
		}
	}

	if (timFmtRef == NULL) {
		CFLocaleRef	localeRef2 = CFLocaleCopyCurrent();
		timFmtRef = CFDateFormatterCreate(kCFAllocatorDefault, localeRef2, kCFDateFormatterNoStyle, kCFDateFormatterShortStyle);
		CFRelease(localeRef2);
	}

	CFStringRef			timStrRef = CFDateFormatterCreateStringWithDate(kCFAllocatorDefault, timFmtRef, (CFDateRef)date);

	if (timStrRef == NULL) {
		return nil;
	}
	format = flag ? @"%@\t%@" : @"%@ %@";
	result_ = [NSString stringWithFormat:format, dayStr_, (NSString *)timStrRef];

	CFRelease(timStrRef);
	
	return result_;
}

- (NSString *)stringForObjectValue:(id)anObject
{
	if (![anObject isKindOfClass:[NSDate class]]) {
		return nil;
	}
	return [self niceStringFromDate:anObject useTab:NO];
}

- (NSAttributedString *)attributedStringForObjectValue:(id)anObject withDefaultAttributes:(NSDictionary *)attributes
{
	if (![anObject isKindOfClass:[NSDate class]]) {
		return nil;
	}
	NSString *stringValue = [self niceStringFromDate:anObject useTab:YES];
	if (!stringValue) return nil;

	return [[[NSAttributedString alloc] initWithString:stringValue attributes:attributes] autorelease];
}

- (BOOL)getObjectValue:(id *)anObject forString:(NSString *)string errorDescription:(NSString **)error
{
	*error = @"BSDateFormatter does not support reverse conversion.";
	return NO;
}

- (NSDate *)baseDateOfToday
{
	return AppGetBasicDataOfToday();
}

#pragma mark Date Calculation
/*static NSCalendarDate *AppGetTodayCalendarDate(int *year, unsigned *month, unsigned *day)
{
	NSCalendarDate *today_;
	int year_;
	unsigned int month_;
	unsigned int day_;

	today_ = [NSCalendarDate date];
	year_  = [today_ yearOfCommonEra];
	month_ = [today_ monthOfYear];
	day_   = [today_ dayOfMonth];
	
	if(year  != NULL) *year  = year_;
	if(month != NULL) *month = month_;
	if(day   != NULL) *day   = day_;
	
	return today_;
}
*/
static NSDate *AppGetBasicDataOfToday()
{
	if (!cachedToday || [[NSDate date] timeIntervalSinceDate:cachedToday] > cacheTimer) {
/*		int year_;
		unsigned int month_;
		unsigned int day_;
		NSTimeZone	*timeZone_ = [NSTimeZone localTimeZone];*/
		NSDate	*tomorrow_;
		
		if (cachedToday) {
			[cachedToday release];
			cachedToday = nil;
		}
		if (cachedYesterday) {
			[cachedYesterday release];
			cachedYesterday = nil;
		}
/*
		AppGetTodayCalendarDate(&year_, &month_, &day_);
			
		cachedToday = [[NSCalendarDate alloc] initWithYear: year_ month: month_ day: day_ hour: 0 minute: 0 second: 0 timeZone: timeZone_];
		cachedYesterday = [[NSCalendarDate alloc] initWithYear: year_ month: month_ day: (day_-1) hour: 0 minute: 0 second: 0 timeZone: timeZone_];
		
		tomorrow_ = [[NSCalendarDate alloc] initWithYear: year_ month: month_ day: (day_+1) hour: 0 minute: 0 second: 0 timeZone: timeZone_];
		cacheTimer = [tomorrow_ timeIntervalSinceNow];
		[tomorrow_ release];*/
		NSCalendar *calendar = [NSCalendar currentCalendar];
		NSDateComponents *components = [calendar components:(NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit) fromDate:[NSDate date]];
		[components setHour:0];
		[components setMinute:0];
		[components setSecond:0];
		cachedToday = [[calendar dateFromComponents:components] retain];

		cachedYesterday = [[cachedToday addTimeInterval:(-60*60*24)] retain];
		tomorrow_ = [cachedToday addTimeInterval:(60*60*24)];
		cacheTimer = [tomorrow_ timeIntervalSinceNow];
	}
	return cachedToday;
}
@end


@implementation BSStringFromDateTransformer
+ (Class)transformedValueClass
{
    return [NSString class];
}
 
+ (BOOL)allowsReverseTransformation
{
    return NO;
}
 
- (id)transformedValue:(id)beforeObject
{
	NSString	*stringValue = nil;

	if (beforeObject) {
		if ([beforeObject isKindOfClass:[NSDate class]]) {
			stringValue = [[BSDateFormatter sharedDateFormatter] niceStringFromDate:beforeObject useTab:NO];
		} else {
			[NSException raise:NSInternalInconsistencyException
						format:@"Value (%@) is not an instance of NSDate.", [beforeObject class]];
		}
	}

	return stringValue;
}
@end
