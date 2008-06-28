//
//  BSIkioiNumberFormatter.m
//  BathyScaphe
//
//  Created by Tsutomu Sawada on 08/06/28.
//  Copyright 2008 BathyScaphe Project. All rights reserved.
//  encoding="UTF-8"
//

#import "BSIkioiNumberFormatter.h"
#import <CocoMonar/CMRSingletonObject.h>


@implementation BSIkioiNumberFormatter
APP_SINGLETON_FACTORY_METHOD_IMPLEMENTATION(sharedIkioiNumberFormatter);

- (void)setupNumberStyle
{
	[self setNumberStyle:NSNumberFormatterDecimalStyle];
}

- (id)init
{
	if (self = [super init]) {
		[self setFormatterBehavior:NSDateFormatterBehavior10_4]; // to make the intent clear
		[self setupNumberStyle];
	}
	return self;
}
@end
