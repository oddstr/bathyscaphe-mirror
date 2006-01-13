//
//  $Id: BSIPIFullScreenController.m,v 1.1 2006/01/13 23:47:59 tsawada2 Exp $
//  BathyScaphe
//
//  Created by Tsutomu Sawada on 06/01/14.
//  Copyright 2006 BathyScaphe Project. All rights reserved.
//

#import "BSIPIFullScreenController.h"
#import <Carbon/Carbon.h>

@class BSIPIFullScreenWindow;

@implementation BSIPIFullScreenController
+ (BSIPIFullScreenController *) sharedInstance
{
    static BSIPIFullScreenController	*sharedInstance = nil;

    if (sharedInstance == nil) {
        sharedInstance = [[self alloc] init];
        [NSBundle loadNibNamed: @"BSIPIFullScreen" owner: sharedInstance];
    }

    return sharedInstance;
}

- (void) awakeFromNib
{
    _fullScreenWindow = [[BSIPIFullScreenWindow alloc] initWithContentRect : [[_baseWindow contentView] frame]
																 styleMask : NSBorderlessWindowMask
																   backing : [_baseWindow backingType]
																	 defer : NO];
    [_fullScreenWindow setDelegate : self];

    {
        NSView		*content;

        content = [[_baseWindow contentView] retain];
        [content removeFromSuperview];
        [_fullScreenWindow setContentView: content];
        [content release];
    }
}

- (void) showPanelWithImage : (NSImage *) anImage;
{
	CGDisplayFadeReservationToken tokenPtr;

	// Carbon!
	SetSystemUIMode(kUIModeAllHidden, kUIOptionDisableProcessSwitch);
	
	// Quartz!
	CGAcquireDisplayFadeReservation(kCGMaxDisplayReservationInterval, &tokenPtr);
	CGDisplayFade(
		tokenPtr,
		1.2,                        // 1.2 seconds
		kCGDisplayBlendNormal,      // starting state
		kCGDisplayBlendSolidColor,  // ending state
		0.0, 0.0, 0.0,              // black
		TRUE                        // wait for completion
	);

	CGReleaseDisplayFadeReservation (tokenPtr);

    [_fullScreenWindow makeKeyAndOrderFront: nil];
	[_imageView setImage : anImage];
}

- (void) hidePanel
{
	CGDisplayFadeReservationToken tokenPtr;

	[_imageView setImage : nil];

	CGAcquireDisplayFadeReservation(kCGMaxDisplayReservationInterval, &tokenPtr);
	CGDisplayFade(
		tokenPtr,
		1.2,                        // 1.2 seconds
		kCGDisplayBlendNormal,      // starting state
		kCGDisplayBlendSolidColor,  // ending state
		0.0, 0.0, 0.0,              // black
		TRUE                        // wait for completion
	);

	CGReleaseDisplayFadeReservation (tokenPtr);

    [_fullScreenWindow orderOut: nil];

	SetSystemUIMode(kUIModeNormal, 0);

}

#pragma mark Delegates

- (BOOL) handlesKeyDown : (NSEvent *) keyDown inWindow : (NSWindow *) window
{
    //	Close the panel on any keystroke.
    //	We could also check for the Escape key by testing
    //		[[keyDown characters] isEqualToString: @"\033"]

    [self hidePanel];
    return YES;
}

- (BOOL) handlesMouseDown : (NSEvent *) mouseDown inWindow: (NSWindow *) window
{
    //	Close the panel on any click
    [self hidePanel];
    return YES;
}
@end
