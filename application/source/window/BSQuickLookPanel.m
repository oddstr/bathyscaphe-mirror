//
//  BSQuickLookPanel.m
//  BathyScaphe
//
//  Created by Tsutomu Sawada on 08/02/02.
//  Copyright 2008 BathyScaphe Project. All rights reserved.
//  encoding="UTF-8"
//

#import "BSQuickLookPanel.h"


@implementation BSQuickLookPanel
- (void)sendEvent:(NSEvent *)theEvent
{
	NSEventType	type_ = [theEvent type];
    //  Offer key-down events to the delegate
    if (type_ == NSKeyDown) {
		NSString	*pressedKey = [theEvent charactersIgnoringModifiers];

        if ([pressedKey isEqualToString:@" "]) {
			[self performClose:nil];
			return;
		}
	}
	[super sendEvent:theEvent];
}
@end
