//
//  $Id: BSIPIPathTransformer.m,v 1.2 2007/01/07 17:04:24 masakih Exp $
//  BathyScaphe
//
//  Created by Tsutomu Sawada on 06/07/10.
//  Copyright 2006 BathyScaphe Project. All rights reserved.
//

#import "BSIPIPathTransformer.h"


@implementation BSIPIPathTransformer
+ (Class) transformedValueClass
{
    return [NSString class];
}
 
+ (BOOL) allowsReverseTransformation
{
    return NO;
}
 
- (id) transformedValue: (id) beforeObject
{
    if (beforeObject == nil) return nil;
	
	if ([beforeObject isKindOfClass: [NSURL class]]) {
		beforeObject = [beforeObject absoluteString];
	}

    return [beforeObject lastPathComponent];
}
@end

@implementation BSIPIImageIgnoringDPITransformer
+ (Class) transformedValueClass
{
	return [NSImage class];
}

+ (BOOL) allowsReverseTransformation
{
	return NO;
}

- (id) transformedValue: (id) beforeObject
{
	if (beforeObject == nil || NO == [beforeObject isKindOfClass: [NSString class]]) {
		return nil;
	}

	NSImage *image_ = [[NSImage alloc] initWithContentsOfFile: beforeObject];
	if (image_ == nil) return nil;

	float wi, he;
	NSImageRep	*tmp_ = [image_ bestRepresentationForDevice: nil];
	
	wi = [tmp_ pixelsWide];
	he = [tmp_ pixelsHigh];
	
	// ignore DPI
	[tmp_ setSize: NSMakeSize(wi, he)];
	return [image_ autorelease];
}
@end
