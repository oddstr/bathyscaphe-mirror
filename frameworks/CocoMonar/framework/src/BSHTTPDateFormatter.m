//
//  BSHTTPDateFormatter.m
//  CMF
//
//  Created by Tsutomu Sawada on 08/03/22.
//  Copyright 2008 BathyScaphe Project. All rights reserved.
//  encoding="UTF-8"
//

#import "BSHTTPDateFormatter.h"
#import <CocoMonar/CMRSingletonObject.h>


@implementation BSHTTPDateFormatter
APP_SINGLETON_FACTORY_METHOD_IMPLEMENTATION(sharedHTTPDateFormatter);

- (void)setupDateStyle
{
	// HTTP format (i.e. RFC 822, updated by RFC 1123)
	[self setDateStyle:NSDateFormatterNoStyle];
	[self setTimeStyle:NSDateFormatterNoStyle];
	[self setShortWeekdaySymbols:[NSArray arrayWithObjects:@"Sun", @"Mon", @"Tue", @"Wed", @"Thu", @"Fri", @"Sat", nil]];
	[self setShortMonthSymbols:[NSArray arrayWithObjects:@"Jan", @"Feb", @"Mar", @"Apr", @"May", @"Jun",
														@"Jul", @"Aug", @"Sep", @"Oct", @"Nov", @"Dec", nil]];
	[self setDateFormat:@"EEE, dd MMM yyyy HH:mm:ss 'GMT'"];
	[self setTimeZone:[NSTimeZone timeZoneWithName:@"GMT"]];
}

- (id)init
{
	if (self = [super init]) {
		[self setFormatterBehavior:NSDateFormatterBehavior10_4]; // to make the intent clear
		[self setupDateStyle];
	}
	return self;
}
@end
