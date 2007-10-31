//
//  BSTitleRulerView.m
//  SGAppKit (BathyScaphe)
//
//  Created by Tsutomu Sawada on 05/09/22.
//  Copyright 2005-2007 BathyScaphe Project. All rights reserved.
//  encoding="UTF-8"
//

#import "BSTitleRulerView.h"
#import <SGAppKit/NSWorkspace-SGExtensions.h>
#import <SGAppKit/BSTitleRulerAppearance.h>
#import <SGAppKit/NSBezierPath_AMShading.h>

#define	THICKNESS_FOR_TITLE	22.0
#define	THICKNESS_FOR_INFO	36.0
#define	TITLE_FONT_SIZE		12.0
#define	INFO_FONT_SIZE		13.0

@implementation BSTitleRulerView

#pragma mark Accessors
- (BSTitleRulerAppearance *)appearance
{
	return m_appearance;
}

- (void)setAppearance:(BSTitleRulerAppearance *)appearance
{
	[appearance retain];
	[m_appearance release];
	m_appearance = appearance;
}

- (NSString *)titleStr
{
	return m_titleStr;
}

- (void)setTitleStr:(NSString *)aString
{
	[self setTitleStrWithoutNeedingDisplay:aString];
	[self setNeedsDisplay:YES];
}

- (void)setTitleStrWithoutNeedingDisplay:(NSString *)aString
{
	[aString retain];
	[m_titleStr release];
	m_titleStr = aString;
}

- (NSString *)infoStr
{
	return m_infoStr;
}

- (void)setInfoStr:(NSString *)aString
{
	[self setInfoStrWithoutNeedingDisplay:aString];
	[self setNeedsDisplay:YES];
}

- (void)setInfoStrWithoutNeedingDisplay:(NSString *)aString
{
	[aString retain];
	[m_infoStr release];
	m_infoStr = aString;
}

- (NSString *)pathStr
{
	return m_pathStr;
}

- (void)setPathStr:(NSString *)aString
{
	[aString retain];
	[m_pathStr release];
	m_pathStr = aString;
}

- (BSTitleRulerModeType)currentMode
{
	return _currentMode;
}

- (void)setCurrentMode:(BSTitleRulerModeType)newType
{
	float newThickness;
	_currentMode = newType;

	switch(newType) {
	case BSTitleRulerShowTitleOnlyMode:
		newThickness = THICKNESS_FOR_TITLE;
		break;
	case BSTitleRulerShowInfoOnlyMode:
		newThickness = THICKNESS_FOR_INFO;
		break;
	case BSTitleRulerShowTitleAndInfoMode:
		newThickness = (THICKNESS_FOR_TITLE + THICKNESS_FOR_INFO);
		break;
	default:
		newThickness = THICKNESS_FOR_TITLE;
		break;
	}
	
	[self setRuleThickness:newThickness];
}

#pragma mark Private Utilities
- (NSDictionary *)attrTemplateForTitle
{
	static NSDictionary	*tmp = nil;
	if (!tmp) {
		NSColor			*color_;

		color_ = [[self appearance] textColor];

		tmp = [[NSDictionary alloc] initWithObjectsAndKeys:
					[NSFont boldSystemFontOfSize:TITLE_FONT_SIZE], NSFontAttributeName,
					color_, NSForegroundColorAttributeName,
					nil];
	}
	return tmp;
}

- (NSDictionary *)attrTemplateForInfo
{
	static NSDictionary	*tmp2 = nil;
	if (!tmp2) {
		NSColor			*color_;

		color_ = [[self appearance] infoColor];

		tmp2 = [[NSDictionary alloc] initWithObjectsAndKeys:
					[NSFont systemFontOfSize:INFO_FONT_SIZE], NSFontAttributeName,
					color_, NSForegroundColorAttributeName,
					nil];
	}
	return tmp2;
}

- (NSAttributedString *)titleForDrawing
{
	return [[[NSAttributedString alloc] initWithString:[self titleStr] attributes:[self attrTemplateForTitle]] autorelease];
}

- (NSAttributedString *)infoForDrawing
{
	return [[[NSAttributedString alloc] initWithString:[self infoStr] attributes:[self attrTemplateForInfo]] autorelease];
}

- (NSArray *)activeColors
{
	BSTitleRulerAppearance *appearance = [self appearance];
	return ([NSColor currentControlTint] == NSGraphiteControlTint) ? [appearance activeGraphiteColors] : [appearance activeBlueColors];
}

#pragma mark Setup & Cleanup
- (id)initWithScrollView:(NSScrollView *)aScrollView appearance:(BSTitleRulerAppearance *)appearance
{
	if (self = [super initWithScrollView:aScrollView orientation:NSHorizontalRuler]) {
		NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
		// Original NSRulerView Properties
		[self setMarkers:nil];
		[self setReservedThicknessForMarkers:0.0];

		// Notifications
		[nc addObserver:self
			   selector:@selector(mainWinOrSystemColorsDidChange:)
				   name:NSSystemColorsDidChangeNotification
				 object:nil];

		[nc addObserver:self
			   selector:@selector(mainWinOrSystemColorsDidChange:)
				   name:NSWindowDidBecomeMainNotification
				 object:[self window]];

		[nc addObserver:self
			   selector:@selector(mainWinOrSystemColorsDidChange:)
				   name:NSWindowDidResignMainNotification
				 object:[self window]];

		// BSTitleRulerView Properties
		[self setCurrentMode:BSTitleRulerShowTitleOnlyMode];
		[self setAppearance:appearance];
	}
	return self;
}

- (void)dealloc
{
	NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];

	[nc removeObserver:self
				  name:NSSystemColorsDidChangeNotification
				object:nil];

	[nc removeObserver:self
				  name:NSWindowDidBecomeMainNotification
				object:[self window]];

	[nc removeObserver:self
				  name:NSWindowDidResignMainNotification
				object:[self window]];

	[m_titleStr release];
	[m_infoStr release];
	[m_pathStr release];
	[m_appearance release];

	[super dealloc];
}

#pragma mark Drawing
- (void)drawTitleBarInRect:(NSRect)aRect
{
	NSArray	*colors_;
	NSColor *gradientStartColor, *gradientEndColor;

	BSTitleRulerAppearance	*appearance = [self appearance];

	colors_ = [[self window] isMainWindow] ? [self activeColors] : [appearance inactiveColors];
	
	gradientStartColor = [colors_ objectAtIndex:0];
	gradientEndColor = [colors_ objectAtIndex:1];

	[[NSBezierPath bezierPathWithRect:aRect] linearGradientFillWithStartColor:gradientStartColor endColor:gradientEndColor];

	if ([appearance drawsCarvedText]) {
		// このへん、暫定的
		NSMutableAttributedString *foo = [[self titleForDrawing] mutableCopy];
		NSRange	range = NSMakeRange(0,[foo length]);
		[foo removeAttribute:NSForegroundColorAttributeName range:range];
		[foo addAttributes:[NSDictionary dictionaryWithObject:[NSColor grayColor] forKey:NSForegroundColorAttributeName] range:range];
		[foo drawInRect:NSInsetRect(aRect, 5.0, 3.0)];
		[foo release];
	}

	[[self titleForDrawing] drawInRect:NSInsetRect(aRect, 5.0, 2.0)];
}

- (BOOL)isOpaque
{
	return YES;
}

- (void)drawInfoBarInRect:(NSRect)aRect
{
	NSRect	iconRect;
	NSImage *icon_ = [[NSWorkspace sharedWorkspace] systemIconForType:kAlertNoteIcon];
	[icon_ setSize:NSMakeSize(32, 32)];
	[icon_ setFlipped:[self isFlipped]];

	[[[self appearance] infoBackgroundColor] set];
	NSRectFill(aRect);	

	iconRect = NSMakeRect(NSMinX(aRect)+5.0, NSMinY(aRect)+2.0, 32, 32);

	[icon_ drawInRect:iconRect fromRect:NSMakeRect(0,0,32,32) operation:NSCompositeSourceOver fraction:1.0];

	aRect = NSInsetRect(aRect, 5.0, 7.0);
	aRect.origin.x += 36.0;
	[[self infoForDrawing] drawInRect:NSInsetRect(aRect, 5.0, 2.0)];
}

- (void)drawRect:(NSRect)aRect
{
	switch ([self currentMode]) {
	case BSTitleRulerShowTitleOnlyMode:
		[self drawTitleBarInRect:aRect];
		break;
	case BSTitleRulerShowInfoOnlyMode:
		[self drawInfoBarInRect:aRect];
		break;
	case BSTitleRulerShowTitleAndInfoMode:
		{
			NSRect titleRect, infoRect;
			NSDivideRect(aRect, &infoRect, &titleRect, THICKNESS_FOR_INFO, NSMaxYEdge);
			[self drawTitleBarInRect:titleRect];
			[self drawInfoBarInRect:infoRect];
		}
		break;
	}
}

#pragma mark Path Popup Menu Support
- (IBAction)revealPathComponent:(id)sender
{
	NSString *path = [sender representedObject];
	if (path) [[NSWorkspace sharedWorkspace] selectFile:path inFileViewerRootedAtPath:[path stringByDeletingLastPathComponent]];
}

static NSMenu *createPathMenu(NSString *fullPath)
{
	NSFileManager	*fm = [NSFileManager defaultManager];
	NSWorkspace		*ws = [NSWorkspace sharedWorkspace];
	NSMenu			*menu = [[NSMenu alloc] initWithTitle:@"Path"];
	NSMenuItem		*menuItem;
	NSImage			*img;
	NSSize			size16 = NSMakeSize(16,16);
	SEL				mySel = @selector(revealPathComponent:);

	menuItem = [[NSMenuItem alloc] initWithTitle:[fm displayNameAtPath:fullPath] action:mySel keyEquivalent:@""];
	img = [ws iconForFile:fullPath];
	[img setSize:size16];
	[menuItem setImage:img];
	[menu addItem:menuItem];
	[menuItem release];

	NSString *bar = fullPath;
	NSString *foo;

	while (![bar isEqualToString:@"/"]) {
		foo = [bar stringByDeletingLastPathComponent];
		menuItem = [[NSMenuItem alloc] initWithTitle:[fm displayNameAtPath:foo] action:mySel keyEquivalent:@""];
		img = [ws iconForFile:foo];
		[img setSize:size16];
		[menuItem setRepresentedObject:bar];
		[menuItem setImage:img];
		[menu addItem:menuItem];
		[menuItem release];
		bar = foo;
	}
	return [menu autorelease];
}

- (void)mouseDown:(NSEvent *)theEvent
{
	unsigned int flag = [theEvent modifierFlags];
	if ([self pathStr] && (flag & NSCommandKeyMask)) {
		[NSMenu popUpContextMenu:createPathMenu([self pathStr]) withEvent:theEvent forView:self];
	}
}

- (NSMenu *)menuForEvent:(NSEvent *)theEvent
{
	if ([self pathStr]) {
		return createPathMenu([self pathStr]);
	}
	return [super menuForEvent:theEvent];
}

#pragma mark Notifications
- (void)mainWinOrSystemColorsDidChange:(NSNotification *)theNotification
{
	[self setNeedsDisplay:YES];
}
@end
