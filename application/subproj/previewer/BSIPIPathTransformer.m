//
//  $Id: BSIPIPathTransformer.m,v 1.1 2006/07/26 16:28:25 tsawada2 Exp $
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
