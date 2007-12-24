//
//  $Id: BSIPIFullScreenController.m,v 1.14 2007/12/24 14:29:09 tsawada2 Exp $
//  BathyScaphe
//
//  Created by Tsutomu Sawada on 06/01/14.
//  Copyright 2006 BathyScaphe Project. All rights reserved.
//  encoding="UTF-8"
//

#import "BSIPIFullScreenController.h"
#import "BSIPIPathTransformer.h"
#import <Carbon/Carbon.h>
#import <ApplicationServices/ApplicationServices.h>
#import <CocoMonar/CMRSingletonObject.h>


@class BSIPIFullScreenWindow;

@interface NSObject(FullScreenDelegateMethodsStub)
- (void)saveImage:(id)sender;
- (float)fullScreenWheelAmount;
@end

@implementation BSIPIFullScreenController
static NSString *g_leftArrowKey;
static NSString *g_rightArrowKey;

APP_SINGLETON_FACTORY_METHOD_IMPLEMENTATION(sharedInstance)	

- (id)init
{
	if (self = [super init]) {
		id transformer = [[[BSIPIImageIgnoringDPITransformer alloc] init] autorelease];
		[NSValueTransformer setValueTransformer:transformer forName:@"BSIPIImageIgnoringDPITransformer"];

		g_leftArrowKey = [[NSString alloc] initWithFormat:@"%C", NSLeftArrowFunctionKey];
		g_rightArrowKey = [[NSString alloc] initWithFormat:@"%C", NSRightArrowFunctionKey];

		[NSBundle loadNibNamed:@"BSIPIFullScreen" owner:self];
	}
	return self;
}

- (void)awakeFromNib
{
	NSView	*contentView;

    _fullScreenWindow = [[BSIPIFullScreenWindow alloc] initWithContentRect:[[_baseWindow contentView] frame]
																 styleMask:NSBorderlessWindowMask
																   backing:[_baseWindow backingType]
																	 defer:NO];
    [_fullScreenWindow setDelegate:self];

	contentView = [[_baseWindow contentView] retain];
	[contentView removeFromSuperview];
	[_fullScreenWindow setContentView:contentView];
	[contentView release];
}

- (id)delegate
{
	return m_delegate;
}

- (void)setDelegate:(id)aDelegate
{
	m_delegate = aDelegate;
}

- (NSArrayController *)arrayController
{
	return m_cube;
}

- (void)setArrayController:(id)aController
{
	if (aController != m_cube) {
		m_cube = aController;
	}
}

- (void)dealloc
{
	m_delegate = nil;
	m_cube = nil;
	[super dealloc];
}

// NSValueTransformerNameBindingOption = @"NSValueTransformerName"
- (NSDictionary *)cachedBindingOptionDict
{
	static NSDictionary *imageTransformerDict = nil;
	if (!imageTransformerDict) {
		imageTransformerDict = [[NSDictionary alloc] initWithObjectsAndKeys:@"BSIPIImageIgnoringDPITransformer", @"NSValueTransformerName", NULL];
	}
	return imageTransformerDict;
}

- (NSDictionary *)cachedBindingOptDictForStatusField
{
	static NSDictionary *notNilTransformerDict = nil;
	if (!notNilTransformerDict) {
		notNilTransformerDict = [[NSDictionary alloc] initWithObjectsAndKeys:NSIsNotNilTransformerName, @"NSValueTransformerName", NULL];
	}
	return notNilTransformerDict;
}

- (NSDictionary *)cachedBindingOptDictForStatusMsg
{
	static NSDictionary *displayPatternDict = nil;
	if (!displayPatternDict) {
		NSString *key = @"%{value2}@\nCan't show image: %{value1}@";
		NSString *pattern = [[NSBundle bundleForClass:[self class]] localizedStringForKey:key value:key table:nil];
		
		displayPatternDict = [[NSDictionary alloc] initWithObjectsAndKeys:pattern, @"NSDisplayPattern", NULL];
	}
	return displayPatternDict;
}

- (void)startFullScreen
{
	[self startFullScreen:[NSScreen mainScreen]];
}

- (void)startFullScreen:(NSScreen *)whichScreen
{
	CGDisplayFadeReservationToken	tokenPtr1, tokenPtr2;
	NSRect							curWinRect, curScreenRect;

	// if whichScreen is the screen which contains the menu bar, ...
	if (!whichScreen) return;
	NSArray *allScreens = [NSScreen screens];
	if ([allScreens count] == 0) return;
	
	if (whichScreen == [allScreens objectAtIndex:0]) {
		SetSystemUIMode(kUIModeAllHidden, kUIOptionDisableProcessSwitch);
	} else {
		SetSystemUIMode(kUIModeContentHidden, kUIOptionDisableProcessSwitch);
	}

	// adjust fullScreenWindow frame
	curWinRect = [_fullScreenWindow frame];
	curScreenRect = [whichScreen frame];
	
	if (!NSEqualRects(curWinRect, curScreenRect)) {
		[_fullScreenWindow setFrame:curScreenRect display:YES];
	}
	
	[_fullScreenWindow setBackgroundColor:windowBackgroundColor];

	// Quartz!
	if (kCGErrorSuccess == CGAcquireDisplayFadeReservation(kCGMaxDisplayReservationInterval, &tokenPtr1)) {
		CGDisplayFade(
			tokenPtr1,
			0.8,							// フェードにかける秒数：0.8
			kCGDisplayBlendNormal,			// 開始状態
			kCGDisplayBlendSolidColor,		// 終了状態
			0.0, 0.0, 0.0,					// R, G, B：真っ黒
			FALSE							// 完了を待つか：待たない
		);

		CGReleaseDisplayFadeReservation(tokenPtr1);
	}

	[_imageView bind:@"value"
			toObject:[self arrayController]
		 withKeyPath:@"selection.downloadedFilePath"
			 options:[self cachedBindingOptionDict]];

	[_statusField bind:@"hidden"
			  toObject:[self arrayController]
		   withKeyPath:@"selection.downloadedFilePath"
			   options:[self cachedBindingOptDictForStatusField]];

	[_statusField bind:@"displayPatternValue1"
			  toObject:[self arrayController]
		   withKeyPath:@"selection.statusMessage"
			   options:[self cachedBindingOptDictForStatusMsg]];

	[_statusField bind:@"displayPatternValue2"
			  toObject:[self arrayController]
		   withKeyPath:@"selection.sourceURL"
			   options:nil];

    [_fullScreenWindow makeKeyAndOrderFront:nil];
	
	if (kCGErrorSuccess == CGAcquireDisplayFadeReservation(kCGMaxDisplayReservationInterval, &tokenPtr2)) {
		CGDisplayFade(
			tokenPtr2,
			0.5,							// 0.5 seconds
			kCGDisplayBlendSolidColor,      // 開始状態
			kCGDisplayBlendNormal,			// 終了状態
			0.0, 0.0, 0.0,					// R, G, B：真っ黒
			FALSE							// 完了を待つか：待たない
		);

		CGReleaseDisplayFadeReservation(tokenPtr2);
	}

	[NSCursor setHiddenUntilMouseMoves:YES];
}

- (void)endFullScreen
{
	CGDisplayFadeReservationToken tokenPtr;

	[NSCursor setHiddenUntilMouseMoves:NO]; // 念のため

	if (kCGErrorSuccess == CGAcquireDisplayFadeReservation(kCGMaxDisplayReservationInterval, &tokenPtr)) {
		CGDisplayFade(
			tokenPtr,
			0.8,							// 0.8 seconds
			kCGDisplayBlendSolidColor,      // starting state
			kCGDisplayBlendNormal,			// ending state
			0.0, 0.0, 0.0,					// black
			FALSE							// don't wait for completion
		);

		CGReleaseDisplayFadeReservation(tokenPtr);
	}
    [_fullScreenWindow orderOut:nil];
	[_imageView unbind:@"value"];
	[_statusField unbind:@"displayPatternValue2"];
	[_statusField unbind:@"displayPatternValue1"];
	[_statusField unbind:@"hidden"];

	SetSystemUIMode(kUIModeNormal, 0);

	[NSObject cancelPreviousPerformRequestsWithTarget:self];
	[m_noMoreField setHidden:YES];

	if ([[self delegate] respondsToSelector:@selector(fullScreenDidEnd:)]) {
		[[self delegate] fullScreenDidEnd:_fullScreenWindow];
	}
}

- (BOOL)fullScreenShowPrevImage:(NSWindow *)window
{
	NSArrayController *controller = [self arrayController];
	[NSObject cancelPreviousPerformRequestsWithTarget:self];
	if ([controller canSelectPrevious]) {
		[m_noMoreField setHidden:YES];
		[controller selectPrevious:window];
	} else {
		NSString *msg = [[NSBundle bundleForClass:[self class]] localizedStringForKey:@"No Prev Image" value:@"Localized String Not Found" table:nil];
		[m_noMoreField setStringValue:msg];
		[m_noMoreField setHidden:NO];
		[self performSelector:@selector(restoreNoMoreField) withObject:nil afterDelay:3.0];
	}
	return YES;
}

- (BOOL)fullScreenShowNextImage:(NSWindow *)window
{
	NSArrayController *controller = [self arrayController];
	[NSObject cancelPreviousPerformRequestsWithTarget:self];
	if ([controller canSelectNext]) {
		[m_noMoreField setHidden:YES];
		[controller selectNext:window];
	} else {
		NSString *msg = [[NSBundle bundleForClass:[self class]] localizedStringForKey:@"No Next Image" value:@"Localized String Not Found" table:nil];
		[m_noMoreField setStringValue:msg];
		[m_noMoreField setHidden:NO];
		[self performSelector:@selector(restoreNoMoreField) withObject:nil afterDelay:3.0];
	}
	return YES;
}

- (BOOL)fullScreenSaveImage:(NSWindow *)window
{
	if ([[self delegate] respondsToSelector:@selector(saveImage:)]) {
		SystemSoundPlay(1);
		[[self delegate] saveImage:window];

		[NSObject cancelPreviousPerformRequestsWithTarget:self];
		NSString *msg = [[NSBundle bundleForClass:[self class]] localizedStringForKey:@"Image Saved" value:@"Localized String Not Found" table:nil];
		[m_noMoreField setStringValue:msg];
		[m_noMoreField setHidden:NO];
		[self performSelector:@selector(restoreNoMoreField) withObject:nil afterDelay:3.0];
		return YES;
	}
	return NO;
}

- (void)restoreNoMoreField
{
	[m_noMoreField setHidden:YES];
}

#pragma mark Delegates
- (BOOL)handlesKeyDown:(NSEvent *)keyDown inWindow:(NSWindow *)window
{
    //	We could also check for the Escape key by testing
    //		[[keyDown characters] isEqualToString: @"\033"]
	NSString	*pressedKey = [keyDown charactersIgnoringModifiers];
	unsigned short	keyCode = [keyDown keyCode];
	
	if ([pressedKey isEqualToString:g_leftArrowKey]) {
		return [self fullScreenShowPrevImage:window];
	}
	
	if ([pressedKey isEqualToString:g_rightArrowKey]) {
		return [self fullScreenShowNextImage:window];
	}
	
	if ([pressedKey isEqualToString:@"s"]) {
		return [self fullScreenSaveImage:window];
	}
	
	if (keyCode == 51) { // delete key
		SystemSoundPlay(15);
		[[self arrayController] remove:window];
		[self endFullScreen];
		return YES;
	}

	[self endFullScreen];
	return YES;
}

- (BOOL)handlesMouseDown:(NSEvent *)mouseDown inWindow:(NSWindow *)window
{
    //	Close the panel on any click
    [self endFullScreen];
    return YES;
}

- (BOOL)handlesScrollWheel:(NSEvent *)scrollWheel inWindow:(NSWindow *)window
{
	float dY = [scrollWheel deltaY];
	float threshold = [[self delegate] fullScreenWheelAmount];

	if (dY < -1*threshold) { // 下回転で次のイメージへ
		return [self fullScreenShowNextImage:window];
	}

	if (dY > threshold) { // 上回転で前のイメージへ
		return [self fullScreenShowPrevImage:window];
	}

	return YES;
}
@end
