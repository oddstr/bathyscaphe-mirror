//
//  BSPopUpTitlebar.m
//  BathyScaphe "Twincam Angel"
//
//  Created by Tsutomu Sawada on 07/07/29.
//  Copyright 2007-2008 BathyScaphe Project. All rights reserved.
//  encoding="UTF-8"
//

#import "BSPopUpTitlebar.h"
#import <SGAppKit/NSBezierPath_AMShading.h>

@implementation BSPopUpTitlebar
#pragma mark Overrides - Init, dealloc, and properties
- (id)initWithFrame:(NSRect)frame
{
    if (self = [super initWithFrame:frame]) {
		m_closeButton = [NSWindow standardWindowButton:NSWindowCloseButton forStyleMask:NSUtilityWindowMask];
		if (m_closeButton) {
			[self addSubview:m_closeButton];
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
		[[self closeButton] setTarget:[newWindow windowController]];
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

- (NSDictionary *)titleTextAttributes
{
	static NSDictionary *cachedAttributes = nil;
	static NSDictionary *cachedAttributesDisabled = nil;
	if (!cachedAttributes) {
		NSArray *objects, *objectsDisabled;
		NSArray *keys;
		NSMutableParagraphStyle *style;
		NSFont	*font;

		style = [[[NSParagraphStyle defaultParagraphStyle] mutableCopy] autorelease];
		[style setLineBreakMode:NSLineBreakByTruncatingMiddle];

		font = [NSFont paletteFontOfSize:0];

		keys = [NSArray arrayWithObjects:NSFontAttributeName, NSForegroundColorAttributeName, NSParagraphStyleAttributeName, nil];

		objects = [[NSArray alloc] initWithObjects:font, [NSColor controlTextColor], style, nil];
		objectsDisabled = [[NSArray alloc] initWithObjects:font, [NSColor disabledControlTextColor], style, nil];
		
		cachedAttributes = [[NSDictionary alloc] initWithObjects:objects forKeys:keys];
		cachedAttributesDisabled = [[NSDictionary alloc] initWithObjects:objectsDisabled forKeys:keys];

		[objects release];
		[objectsDisabled release];
	}
	return [[self window] isKeyWindow] ? cachedAttributes : cachedAttributesDisabled;
}

- (void)drawRect:(NSRect)rect
{
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
	if ([self title]) {
		NSRect titleRect = NSMakeRect(rect.origin.x + 24, rect.origin.y, rect.size.width - 29, rect.size.height);
		[[self title] drawWithRect:titleRect options:NSStringDrawingUsesLineFragmentOrigin attributes:[self titleTextAttributes]];
	}
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
