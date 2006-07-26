//
//  $Id: BSIPIFullScreenController.m,v 1.5 2006/07/26 16:28:25 tsawada2 Exp $
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

- (id) delegate
{
	return m_delegate;
}
- (void) setDelegate: (id) aDelegate
{
	m_delegate = aDelegate;
}

- (void) dealloc
{
	m_delegate = nil;
	[super dealloc];
}
/*- (void) _showPanelWithPath : (NSString *) aPath
{
	NSImage	*tmp0_ = [[NSImage alloc] initWithContentsOfFile : aPath];

	NSImageRep		*rep_ = [[tmp0_ representations] objectAtIndex : 0];
	//NSSize	viewSize = [_imageView bounds].size;
	//NSSize	imageSize = [anImage size];
	//float	dX, dY;
	[rep_ setSize : NSMakeSize([rep_ pixelsWide], [rep_ pixelsHigh])];

	dX = viewSize.width / imgX;
	dY = viewSize.height / imgY;
	
	if (dX <= 1.0 && dY <= 1.0) {
		return anImage;
	}
	float	dT = (dX > dY) ? dY : dX;
	
	[Rep_ setSize : NSMakeSize(imgX*dT, imgY*dT)];
	[self showPanelWithImage : tmp0_];
}*/
- (void) setImage: (NSImage *) anImage
{
	[_imageView setImage: anImage];
}

//- (void) showPanelWithImage : (NSImage *) anImage;
- (void) startFullScreen
{
	CGDisplayFadeReservationToken tokenPtr1, tokenPtr2;

	// Carbon!
	SetSystemUIMode(kUIModeAllHidden, kUIOptionDisableProcessSwitch);

	// Quartz!
	if (kCGErrorSuccess == CGAcquireDisplayFadeReservation(kCGMaxDisplayReservationInterval, &tokenPtr1)) {
		CGDisplayFade(
			tokenPtr1,
			0.8,							// フェードにかける秒数：0.8
			kCGDisplayBlendNormal,			// 開始状態
			kCGDisplayBlendSolidColor,			// 終了状態
			0.0, 0.0, 0.0,					// R, G, B：真っ黒
			FALSE							// 完了を待つか：待たない
		);

		CGReleaseDisplayFadeReservation (tokenPtr1);
	}

    [_fullScreenWindow makeKeyAndOrderFront: nil];
	
	if (kCGErrorSuccess == CGAcquireDisplayFadeReservation(kCGMaxDisplayReservationInterval, &tokenPtr2)) {
		CGDisplayFade(
			tokenPtr2,
			0.5,							// 0.5 seconds
			kCGDisplayBlendSolidColor,      // 開始状態
			kCGDisplayBlendNormal,			// 終了状態
			0.0, 0.0, 0.0,					// R, G, B：真っ黒
			FALSE							// 完了を待つか：待たない
		);

		CGReleaseDisplayFadeReservation (tokenPtr2);
	}
	//[_imageView setImage : anImage];
	[NSCursor setHiddenUntilMouseMoves : YES];
}

- (void) endFullScreen
{
	CGDisplayFadeReservationToken tokenPtr;

	[NSCursor setHiddenUntilMouseMoves : NO]; // 念のため
	//[_imageView setImage : nil];

	if (kCGErrorSuccess == CGAcquireDisplayFadeReservation(kCGMaxDisplayReservationInterval, &tokenPtr)) {
		CGDisplayFade(
			tokenPtr,
			0.8,							// 0.8 seconds
			kCGDisplayBlendSolidColor,      // starting state
			kCGDisplayBlendNormal,			// ending state
			0.0, 0.0, 0.0,					// black
			FALSE							// don't wait for completion
		);

		CGReleaseDisplayFadeReservation (tokenPtr);
	}
    [_fullScreenWindow orderOut: nil];

	SetSystemUIMode(kUIModeNormal, 0);
}

#pragma mark Delegates

- (BOOL) handlesKeyDown : (NSEvent *) keyDown inWindow : (NSWindow *) window
{
    //	Close the panel on any keystroke.
    //	We could also check for the Escape key by testing
    //		[[keyDown characters] isEqualToString: @"\033"]
	/*if([[keyDown charactersIgnoringModifiers] isEqualToString : [NSString stringWithFormat : @"%C", 0xF702]]) {
		if ([[self delegate] respondsToSelector: @selector(showPrevImage:)])
			[[self delegate] showPrevImage: nil];
	} else if([[keyDown charactersIgnoringModifiers] isEqualToString : [NSString stringWithFormat : @"%C", 0xF703]]) {
		if ([[self delegate] respondsToSelector: @selector(showNextImage:)])
			[[self delegate] showNextImage: nil];
	} else {*/
		[self endFullScreen];
	//}
    return YES;
}

- (BOOL) handlesMouseDown : (NSEvent *) mouseDown inWindow: (NSWindow *) window
{
    //	Close the panel on any click
    [self endFullScreen];
    return YES;
}

- (void) windowDidOrderOut: (NSWindow *) window
{
	if([[self delegate] respondsToSelector: @selector(fullScreenDidEnd:)])
		[[self delegate] fullScreenDidEnd: window];
}
@end
