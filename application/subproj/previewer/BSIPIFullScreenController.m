//
//  $Id: BSIPIFullScreenController.m,v 1.8 2007/01/07 17:04:24 masakih Exp $
//  BathyScaphe
//
//  Created by Tsutomu Sawada on 06/01/14.
//  Copyright 2006 BathyScaphe Project. All rights reserved.
//

#import "BSIPIFullScreenController.h"
#import "BSIPIPathTransformer.h"
#import <Carbon/Carbon.h>
#import <ApplicationServices/ApplicationServices.h>
#import <CocoMonar/CMRSingletonObject.h>


@class BSIPIFullScreenWindow;

@interface NSObject(FullScreenDelegateMethodsStub)
- (void) showPrevImage: (id) sender;
- (void) showNextImage: (id) sender;
- (void) saveImage: (id) sender;
- (void) deleteCachedImage: (id) sender;
@end

@implementation BSIPIFullScreenController
APP_SINGLETON_FACTORY_METHOD_IMPLEMENTATION(sharedInstance)	

- (id) init {
	self = [super init];
	if (self != nil) {
		id transformer = [[[BSIPIImageIgnoringDPITransformer alloc] init] autorelease];
		[NSValueTransformer setValueTransformer: transformer forName: @"BSIPIImageIgnoringDPITransformer"];

		[NSBundle loadNibNamed: @"BSIPIFullScreen" owner: self];
	}
	return self;
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

- (NSArrayController *) arrayController
{
	return m_cube;
}

- (void) setArrayController: (id) aController
{
	if (aController != m_cube) {
		m_cube = aController;
	}
}

- (void) dealloc
{
	m_delegate = nil;
	m_cube = nil;
	[super dealloc];
}

// NSValueTransformerNameBindingOption = @"NSValueTransformerName"
- (NSDictionary *) cachedBindingOptionDict
{
	static NSDictionary *dict_ = nil;
	if (dict_ == nil) {
		dict_ = [[NSDictionary alloc] initWithObjectsAndKeys: @"BSIPIImageIgnoringDPITransformer", @"NSValueTransformerName", NULL];
	}
	return dict_;
}

- (NSDictionary *) cachedBindingOptDictForStatusField
{
	static NSDictionary *dictTemplate3_ = nil;
	if (dictTemplate3_ == nil) {
		dictTemplate3_ = [[NSDictionary alloc] initWithObjectsAndKeys: NSIsNotNilTransformerName, @"NSValueTransformerName", NULL];
	}
	return dictTemplate3_;
}

- (NSDictionary *) cachedBindingOptDictForStatusMsg
{
	static NSDictionary *dictTemplate2_ = nil;
	if (dictTemplate2_ == nil) {
		NSBundle *selfBundle = [NSBundle bundleForClass: [self class]];
		NSString *key_ = @"%{value2}@\nCan't show image: %{value1}@";
		NSString *tmp_ = [selfBundle localizedStringForKey: key_ value: key_ table: nil];
		
		dictTemplate2_ = [[NSDictionary alloc] initWithObjectsAndKeys: tmp_, @"NSDisplayPattern", NULL];
	}
	return dictTemplate2_;
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

	[_imageView bind: @"value"
			toObject: [self arrayController]
		 withKeyPath: @"selection.downloadedFilePath"
			 options: [self cachedBindingOptionDict]];

	[_statusField bind: @"hidden"
			toObject: [self arrayController]
		 withKeyPath: @"selection.downloadedFilePath"
			 options: [self cachedBindingOptDictForStatusField]];

	[_statusField bind: @"displayPatternValue1"
			toObject: [self arrayController]
		 withKeyPath: @"selection.statusMessage"
			 options: [self cachedBindingOptDictForStatusMsg]];

	[_statusField bind: @"displayPatternValue2"
			toObject: [self arrayController]
		 withKeyPath: @"selection.sourceURL"
			 options: nil];

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
	[_imageView unbind: @"value"];
	[_statusField unbind: @"displayPatternValue2"];
	[_statusField unbind: @"displayPatternValue1"];
	[_statusField unbind: @"hidden"];

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
	
	if ([pressedKey isEqualToString: [NSString stringWithFormat: @"%C", NSLeftArrowFunctionKey]]) {
		if ([[self delegate] respondsToSelector: @selector(showPrevImage:)]) {
			[[self delegate] showPrevImage: window];
			return YES;
		}
	}
	
	if ([pressedKey isEqualToString: [NSString stringWithFormat: @"%C", NSRightArrowFunctionKey]]) {
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
