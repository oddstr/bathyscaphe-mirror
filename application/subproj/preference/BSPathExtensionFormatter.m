//
//  BSPathExtensionFormatter.m
//  BathyScaphe
//
//  Created by Tsutomu Sawada on 07/11/23.
//  Copyright 2007 BathyScaphe Project. All rights reserved.
//  encoding="UTF-8"
//

#import "BSPathExtensionFormatter.h"


@implementation BSPathExtensionFormatter
- (NSString *)localizedStringForKey:(NSString *)key
{
	NSBundle *bundle = [NSBundle bundleForClass:[self class]];
	return [bundle localizedStringForKey:key value:key table:nil];
}

- (NSString *)stringForObjectValue:(id)anObject
{
	if (![anObject isKindOfClass:[NSString class]]) {
		return nil;
	}
	return anObject;
}

- (BOOL)getObjectValue:(id *)anObject forString:(NSString *)string errorDescription:(NSString **)error
{
	if (!string || [string isEqualToString:@""]) {
		if (error != NULL) *error = [self localizedStringForKey:@"Empty string."];
		return NO;
	}

	if ([string hasPrefix:@"."]) {
		if ([string length] == 1) {
			if (error != NULL) *error = [self localizedStringForKey:@"Invalid extension."];
			return NO;
		} else {
			*anObject = [[string substringFromIndex:1] lowercaseString];
			return YES;
		}
	}

	*anObject = [string lowercaseString];
	return YES;
}
@end
