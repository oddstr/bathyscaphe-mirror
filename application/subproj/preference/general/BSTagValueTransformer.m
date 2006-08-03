//
//  BSTagValueTransformer.m
//  BathyScaphe
//
//  Created by Tsutomu Sawada on 06/08/03.
//  Copyright 2006 BathyScaphe Project. All rights reserved.
//

#import "BSTagValueTransformer.h"


@implementation BSTagValueTransformer
+ (Class) transformedValueClass
{
    return [NSNumber class];
}
 
+ (BOOL) allowsReverseTransformation
{
    return YES;
}
 
- (id) transformedValue: (id) beforeObject
{
	int tmp = 0;
	if (beforeObject != nil) {
		if ([beforeObject respondsToSelector: @selector(intValue)]) {
			tmp = [beforeObject intValue];
		} else {
				[NSException raise: NSInternalInconsistencyException
							format: @"Value (%@) does not respond to -intValue.",
				[beforeObject class]];
		}

		if (tmp == NSNotFound) tmp = -1;
	}

	return [NSNumber numberWithInt: tmp];
}

- (id) reverseTransformedValue: (id) value;
{
	int returnValue = 0;
    if (value != nil) {
		if ([value respondsToSelector: @selector(intValue)]) {
			returnValue = [value intValue];
		} else {
			[NSException raise: NSInternalInconsistencyException
						format: @"Value (%@) does not respond to -intValue.",
			[value class]];
		}

		if (returnValue == -1) returnValue = NSNotFound;
	}

    return [NSNumber numberWithInt: returnValue];
}
@end
