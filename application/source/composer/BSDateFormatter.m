//
//  BSDateFormatter.m
//  BathyScaphe
//
//  Created by Tsutomu Sawada on 06/12/05.
//  Copyright 2006 BathyScaphe Project. All rights reserved.
//

#import "BSDateFormatter.h"
#import <CocoMonar/CMRSingletonObject.h>

static NSDate *AppGetBasicDataOfToday(void);

@implementation BSDateFormatter
static NSDate *cachedToday;
static NSDate *cachedYesterday;
static NSTimeInterval	cacheTimer;

APP_SINGLETON_FACTORY_METHOD_IMPLEMENTATION(sharedDateFormatter);

- (NSString *) niceStringFromDate: (NSDate *) date
{
	static CFDateFormatterRef	timFmtRef;
	static CFDateFormatterRef	dayFmtRef;
	NSString	*result_ = nil;
	NSString	*dayStr_ = nil;

	NSDate	*today_ = AppGetBasicDataOfToday();
	NSComparisonResult compareToday_ = [date compare: today_];

	if (compareToday_ != NSOrderedAscending) {
		dayStr_ = NSLocalizedString(@"Today", @"Today");
	} else {
		NSComparisonResult compareYesterday_ = [date compare: cachedYesterday];

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
				dayStr_ = [NSString stringWithString: (NSString *)dayStrRef];
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

	if (timStrRef == NULL)
		return nil;

	result_ = [NSString stringWithFormat: @"%@\t%@", dayStr_, (NSString *)timStrRef];

	CFRelease(timStrRef);
	
	return result_;
}

- (NSString *) stringForObjectValue: (id) anObject
{
	if (NO == [anObject isKindOfClass: [NSDate class]])
		return nil;
	
	return [self niceStringFromDate: anObject];
}

- (NSAttributedString *) attributedStringForObjectValue: (id) anObject withDefaultAttributes: (NSDictionary *) attributes
{
	NSString *stringValue = [self stringForObjectValue: anObject];
	if (stringValue == nil) return nil;
	
	return [[[NSAttributedString alloc] initWithString: stringValue attributes: attributes] autorelease];
}

- (BOOL) getObjectValue: (id *) anObject forString: (NSString *) string errorDescription: (NSString **) error
{
	*error = @"BSDateFormatter does not support reverse conversion.";
	return NO;
}

#pragma mark Will be deprecated in the Future
static NSCalendarDate *AppGetTodayCalendarDate(int *year, unsigned *month, unsigned *day)
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

static NSDate * AppGetBasicDataOfToday()
{
	if (cachedToday == nil || [[NSDate date] timeIntervalSinceDate: cachedToday] > cacheTimer) {
		int year_;
		unsigned int month_;
		unsigned int day_;
		NSTimeZone	*timeZone_ = [NSTimeZone localTimeZone];
		NSCalendarDate	*tomorrow_;
		
		if(cachedToday) {
			[cachedToday release]; cachedToday = nil;
		}
		if(cachedYesterday) {
			[cachedYesterday release]; cachedYesterday = nil;
		}

		AppGetTodayCalendarDate(&year_, &month_, &day_);
			
		cachedToday = [[NSCalendarDate alloc] initWithYear: year_ month: month_ day: day_ hour: 0 minute: 0 second: 0 timeZone: timeZone_];
		cachedYesterday = [[NSCalendarDate alloc] initWithYear: year_ month: month_ day: (day_-1) hour: 0 minute: 0 second: 0 timeZone: timeZone_];
		
		tomorrow_ = [[NSCalendarDate alloc] initWithYear: year_ month: month_ day: (day_+1) hour: 0 minute: 0 second: 0 timeZone: timeZone_];
		cacheTimer = [tomorrow_ timeIntervalSinceNow];
		[tomorrow_ release];
	}
	return cachedToday;
}
@end
