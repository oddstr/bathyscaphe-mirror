//
//  BSTaskItemValueTransformer.m
//  BathyScaphe
//
//  Created by Tsutomu Sawada on 08/03/11.
//  Copyright 2008 BathyScaphe Project. All rights reserved.
//  encoding="UTF-8"
//

#import "BSTaskItemValueTransformer.h"


@implementation BSTaskItemValueTransformer
+ (Class)transformedValueClass
{
    return [NSNumber class];
}
 
+ (BOOL)allowsReverseTransformation
{
    return NO;
}
 
- (id)transformedValue:(id)beforeObject
{
    if (!beforeObject || ![beforeObject isKindOfClass:[NSNumber class]]) {
		return nil;
	}

	double value = [beforeObject doubleValue];
	BOOL	flag = (value == -1);
    return [NSNumber numberWithBool:flag];
}
@end
