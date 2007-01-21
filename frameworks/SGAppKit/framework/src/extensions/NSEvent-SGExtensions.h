//
//  NSEvent-SGExtensions.h
//  SGAppKit
//
//  Created by Tsutomu Sawada on 07/01/21.
//  Copyright 2007 BathyScaphe Project. All rights reserved.
//

#import <Cocoa/Cocoa.h>

// From http://hetima.com/pblog/article.php?id=48

@interface NSEvent(StarlightBreakerAddition)
+ (unsigned int) currentCarbonModifierFlags;
@end
