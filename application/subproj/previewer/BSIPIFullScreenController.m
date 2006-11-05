//
//  $Id: BSIPIFullScreenController.m,v 1.7 2006/11/05 13:15:07 tsawada2 Exp $
//  BathyScaphe
//
//  Created by Tsutomu Sawada on 06/01/14.
//  Copyright 2006 BathyScaphe Project. All rights reserved.
//

#import "BSIPIFullScreenController.h"
#import <Carbon/Carbon.h>

@class BSIPIFullScreenWindow;

@interface NSObject(FullScreenDelegateMethodsStub)
- (void) showPrevImage: (id) sender;
- (void) showNextImage: (id) sender;
- (void) saveImage: (id) sender;
- (void) deleteCachedImage: (id) sender;
@end

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

- (void) startFullScreen
{
	[self startFullScreen: [NSScreen mainScreen]];
}

- (void) startFullScreen: (NSScreen *) whichScreen
{
	CGDisplayFadeReservationToken	tokenPtr1, tokenPtr2;
	NSRect							curWinRect, curScreenRect;

	// if whichScreen is the screen which contains the menu bar, ...
	if (whichScreen == nil) return;
	NSArray *allScreens = [NSScreen screens];
	if ([allScreens count] == 0) return;
	
	if (whichScreen == [allScreens objectAtIndex: 0]) {
		SetSystemUIMode(kUIModeAllHidden, kUIOptionDisableProcessSwitch);
	} else {
		SetSystemUIMode(kUIModeContentHidden, kUIOptionDisableProcessSwitch);
	}

	// adjust fullScreenWindow frame
	curWinRect = [_fullScreenWindow frame];
	curScreenRect = [whichScreen frame];
	
	if (NO == NSEqualRects(curWinRect, curScreenRect)) {
		[_fullScreenWindow setFrame: curScreenRect display: YES];
	}

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

	[NSCursor setHiddenUntilMouseMoves : YES];
}

- (void) endFullScreen
{
	CGDisplayFadeReservationToken tokenPtr;

	[NSCursor setHiddenUntilMouseMoves : NO]; // 念のため

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

	if([[self delegate] respondsToSelector: @selector(fullScreenDidEnd:)])
		[[self delegate] fullScreenDidEnd: _fullScreenWindow];
}

#pragma mark Delegates

- (BOOL) handlesKeyDown : (NSEvent *) keyDown inWindow : (NSWindow *) window
{
    //	We could also check for the Escape key by testing
    //		[[keyDown characters] isEqualToString: @"\033"]
	NSString	*pressedKey = [keyDown charactersIgnoringModifiers];
	unsigned short	keyCode = [keyDown keyCode];
	
	if ([pressedKey isEqualToString: [NSString stringWithFormat: @"%C", 0xF702]]) {
		if ([[self delegate] respondsToSelector: @selector(showPrevImage:)]) {
			[[self delegate] showPrevImage: window];
			return YES;
		}
	}
	
	if ([pressedKey isEqualToString: [NSString stringWithFormat: @"%C", 0xF703]]) {
		if ([[self delegate] respondsToSelector: @selector(showNextImage:)]) {
			[[self delegate] showNextImage: window];
			return YES;
		}
	}
	
	if ([pressedKey isEqualToString: @"s"]) {
		if ([[self delegate] respondsToSelector: @selector(saveImage:)]) {
			[[self delegate] saveImage: window];
			return YES;
		}
	}
	
	if (keyCode == 51) { // delete key
		if ([[self delegate] respondsToSelector: @selector(deleteCachedImage:)]) {
			[[self delegate] deleteCachedImage: window];
			[self endFullScreen];
			return YES;
		}
	}
	
	[self endFullScreen];
	return YES;
}

- (BOOL) handlesMouseDown : (NSEvent *) mouseDown inWindow: (NSWindow *) window
{
    //	Close the panel on any click
    [self endFullScreen];
    return YES;
}
@end
