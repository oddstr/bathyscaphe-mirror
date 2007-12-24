//
//  BSReplyControllerValueTransformer.m
//  BathyScaphe
//
//  Created by Tsutomu Sawada on 07/12/24.
//  Copyright 2007 BathyScaphe Project. All rights reserved.
//

#import "BSReplyControllerValueTransformer.h"
#import "CMRThreadMessage.h"

@implementation BSNotNilOrEmptyValueTransformer
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
	BOOL	tmp = NO;
	if (beforeObject) {
		if ([beforeObject respondsToSelector:@selector(isEqualToString:)]) {
			tmp = ![beforeObject isEqualToString:@""];
		} else {
			[NSException raise:NSInternalInconsistencyException
						format:@"Value (%@) does not respond to -isEqualToString:.", [beforeObject class]];
		}
	}

	return [NSNumber numberWithBool:tmp];
}
@end


@implementation BSNotContainsSAGEValueTransformer
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
	BOOL	tmp = YES;
	if (beforeObject) {
		if ([beforeObject isKindOfClass:[NSString class]]) {
			NSRange found = [(NSString *)beforeObject rangeOfString:CMRThreadMessage_SAGE_String options:NSLiteralSearch];
			tmp = (found.location == NSNotFound);
		} else {
			[NSException raise:NSInternalInconsistencyException
						format:@"Value (%@) is not NSString.", [beforeObject class]];
		}
	}

	return [NSNumber numberWithBool:tmp];
}
@end
