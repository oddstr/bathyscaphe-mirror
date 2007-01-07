//
//  $Id: BSIPIFullScreenWindow.m,v 1.5 2007/01/07 17:04:24 masakih Exp $
//  BathyScaphe
//
//  Created by Tsutomu Sawada on 06/01/14.
//  Copyright 2006 BathyScaphe Project. All rights reserved.
//

#import "BSIPIFullScreenWindow.h"


@implementation BSIPIFullScreenWindow
- (id) initWithContentRect : (NSRect)contentRect
				 styleMask : (unsigned int) aStyle
				   backing : (NSBackingStoreType) bufferingType
					 defer : (BOOL) flag
{

    NSWindow* result = [super initWithContentRect :contentRect styleMask : NSBorderlessWindowMask backing : NSBackingStoreBuffered defer : NO];

    [result setBackgroundColor: [NSColor blackColor]];
	[result setOpaque:YES];

    [result setLevel: NSScreenSaverWindowLevel];

    [result setHasShadow:NO];
    
	{
		NSRect  screenFrame = [[NSScreen mainScreen] frame];
		[self setFrame:screenFrame display:YES];
    }
    
    return result;
}

- (BOOL) canBecomeKeyWindow
{
    return YES;
}

// command+なんちゃらのキーボードショートカットをブロックする（メニューバーのあるウインドウがフルスクリーンに
// なっているときのみ）
/*- (BOOL) performKeyEquivalent: (NSEvent *) theEvent
{
	NSScreen *screen_ = [self screen];
	if (!screen_) goto default_behavior;
	
	NSArray	*screens_ = [NSScreen screens];
	if (!screens_ || [screens_ count] == 0) goto default_behavior;

	if ((screen_ == [screens_ objectAtIndex: 0]) && ([theEvent modifierFlags] & NSCommandKeyMask > 0)) {
		return YES;
	}
	
default_behavior:
	return [super performKeyEquivalent: theEvent];
}*/

//  Ask our delegate if it wants to handle keystroke or mouse events before we route them.
- (void) sendEvent : (NSEvent *) theEvent
{
    //  Offer key-down events to the delegats
    if ([theEvent type] == NSKeyDown)
        if ([[self delegate] respondsToSelector : @selector(handlesKeyDown:inWindow:)])
            if ([[self delegate] handlesKeyDown : theEvent  inWindow : self])
                return;

    //  Offer mouse-down events (lefty or righty) to the delegate
   if ([theEvent type] == NSLeftMouseDown) {
        if ([[self delegate] respondsToSelector : @selector(handlesMouseDown:inWindow:)])
            if ([[self delegate] handlesMouseDown : theEvent  inWindow: self])
                /*return*/;
	}
    //  Delegate wasn't interested, so do the usual routing.
    [super sendEvent: theEvent];
}
@end
