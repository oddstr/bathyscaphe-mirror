//
//  BSPopUpTitlebar.m
//  BathyScaphe "Twincam Angel"
//
//  Created by Tsutomu Sawada on 07/07/29.
//  Copyright 2007 BathyScaphe Project. All rights reserved.
//

#import "BSPopUpTitlebar.h"
#import <SGAppKit/NSBezierPath_AMShading.h>
//#import <Carbon/Carbon.h>

@implementation BSPopUpTitlebar
#pragma mark Overrides - Init, dealloc, and properties
- (id)initWithFrame:(NSRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code here.
		m_closeButton = [NSWindow standardWindowButton:NSWindowCloseButton forStyleMask:NSUtilityWindowMask];
		if (m_closeButton) {
			[self addSubview:m_closeButton];
			[m_closeButton setTarget:[[self window] windowController]];
			[m_closeButton setFrameOrigin:NSMakePoint(5,1)];
		}
		m_isPressed = NO;
	}
    return self;
}

- (void)dealloc
{
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	[self setTitleWithoutNeedingDisplay:nil];
	[super dealloc];
}

- (BOOL)acceptsFirstMouse:(NSEvent *)theEvent
{
	return YES;
}

- (BOOL)isOpaque
{
	return YES;
}

- (BOOL)mouseDownCanMoveWindow
{
	return YES;
}

- (BOOL)needsPanelToBecomeKey
{
	return YES;
}

- (void)viewWillMoveToWindow:(NSWindow *)newWindow
{
	if (newWindow) {
		NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
		[nc addObserver:self selector:@selector(windowOrderChanged:) name:NSWindowDidBecomeKeyNotification object:newWindow];
		[nc addObserver:self selector:@selector(windowOrderChanged:) name:NSWindowDidResignKeyNotification object:newWindow];
	}
}

#pragma mark Drawing
- (NSColor *)gradientStartColor
{
	static NSColor *cachedStartColor = nil;
	static NSColor *cachedStartColorPressed = nil;
	if (!cachedStartColor) {
		cachedStartColor = [[NSColor colorWithCalibratedRed:0.75 green:0.75 blue:0.75 alpha:1.0] retain];
		cachedStartColorPressed = [[NSColor colorWithCalibratedRed:0.60 green:0.60 blue:0.60 alpha:1.0] retain];
	}
	return m_isPressed ? cachedStartColorPressed : cachedStartColor;
}

- (NSColor *)gradientEndColor
{
	static NSColor *cachedEndColor = nil;
	static NSColor *cachedEndColorPressed = nil;
	if (!cachedEndColor) {
		cachedEndColor = [[NSColor colorWithCalibratedRed:0.90 green:0.90 blue:0.90 alpha:1.0] retain];
		cachedEndColorPressed = [[NSColor colorWithCalibratedRed:0.75 green:0.75 blue:0.75 alpha:1.0] retain];
	}
	return m_isPressed ? cachedEndColorPressed : cachedEndColor;
}
/*
- (NSString *)titleStringWithTruncatingIfNeededOfWidth:(float)width font:(ThemeFontID)fontID
{
	NSMutableString *tmp;
	OSStatus err;

	tmp= [[self title] mutableCopy];
	if (!tmp) return nil;

	err = TruncateThemeText((CFMutableStringRef)tmp, fontID, kThemeStateActive, width, truncMiddle, NULL);
	if (err != noErr) {
		NSLog(@"TruncateThemeText failed with error %d", err);
	}
	return [tmp autorelease];
}

- (NSDictionary *)titleTextAttributes
{
	return nil; // Unimplemented yet.
}
*/
- (void)drawRect:(NSRect)rect {
    // Drawing code here.
	NSRect lineRect;

	lineRect = NSMakeRect(rect.origin.x, rect.origin.y, rect.size.width, 1.0);
	rect.origin.y += 1.0;
	rect.size.height -= 1.0;
	if ([[self window] isKeyWindow]) {
		[[NSBezierPath bezierPathWithRect:rect] linearGradientFillWithStartColor:[self gradientStartColor] endColor:[self gradientEndColor]];
	} else {
		[[NSColor windowBackgroundColor] set];
		NSRectFill(rect);
	}
/*	if ([self title]) {
		float width = [self bounds].size.width - 48;
		NSString *str = [self titleStringWithTruncatingIfNeededOfWidth:width font:kThemeUtilityWindowTitleFont];
		[str drawAtPoint:NSMakePoint(24,1) withAttributes:[self titleTextAttributes]];
	}*/
	[[NSColor windowFrameColor] set];
	NSRectFill(lineRect);
}

- (void)mouseDown:(NSEvent *)theEvent
{
	m_isPressed = YES;
	[self setNeedsDisplay:YES];
}

- (void)mouseUp:(NSEvent *)theEvent
{
	m_isPressed = NO;
	[self setNeedsDisplay:YES];
}

#pragma mark Accesssors
- (NSString *)title
{
	return m_titleString;
}

- (void)setTitle:(NSString *)titleString
{
	[self setTitleWithoutNeedingDisplay:titleString];
	[self setNeedsDisplay:YES];
}

- (void)setTitleWithoutNeedingDisplay:(NSString *)titleString
{
	[titleString retain];
	[m_titleString release];
	m_titleString = titleString;
}

- (NSButton *)closeButton
{
	return m_closeButton;
}

#pragma mark Notification
- (void)windowOrderChanged:(NSNotification *)aNotification
{
	[self setNeedsDisplay:YES];
}
@end
