//
//  NSEvent-SGExtensions.m
//  SGAppKit
//
//  Created by Tsutomu Sawada on 07/01/21.
//  Copyright 2007 BathyScaphe Project. All rights reserved.
//

#import "NSEvent-SGExtensions.h"
#import <Carbon/Carbon.h>

@implementation NSEvent(StarlightBreakerAddition)
+ (unsigned int) currentCarbonModifierFlags
{
    unsigned int    cocoaModFlag = 0;
    UInt32 carbonModFlag = GetCurrentEventKeyModifiers();
    if (carbonModFlag & cmdKey)     cocoaModFlag |= NSCommandKeyMask;
    if (carbonModFlag & optionKey)  cocoaModFlag |= NSAlternateKeyMask;
    if (carbonModFlag & shiftKey)   cocoaModFlag |= NSShiftKeyMask;
    if (carbonModFlag & controlKey) cocoaModFlag |= NSControlKeyMask;
    return cocoaModFlag;
}
@end
