//
//  $Id: BSTitleRulerView.m,v 1.13 2007/01/07 17:04:23 masakih Exp $
//  BathyScaphe
//
//  Created by Tsutomu Sawada on 05/09/22.
//  Copyright 2005-2006 BathyScaphe Project. All rights reserved.
//

#import "BSTitleRulerView.h"

static NSString *const kTRViewBgImgBlueKey				= @"titleRulerBgAquaBlue";
static NSString *const kTRViewBgImgGraphiteKey			= @"titleRulerBgAquaGraphite";
static NSString *const kTitleRulerViewDefaultTitleKey	= @"titleRuler default title";
static NSString *const kTRViewBgImageNonActiveKey		= @"titleRulerBgNotActive";
//static NSString *const kTRViewInfoIconKey				= @"titleRulerInfoIcon";

static NSRect	bgImgRect;
static NSRect	bgImgNARect;

static NSImage	*m_bgImage;
static NSImage	*m_bgImageNonActive;
static NSColor	*m_titleTextColor;

#define	THICKNESS_FOR_TITLE	22.0
#define	THICKNESS_FOR_INFO	36.0
#define	TITLE_FONT_SIZE		12.0
#define	INFO_FONT_SIZE		13.0

@implementation BSTitleRulerView

#pragma mark Accessors

- (NSString *) titleStr
{
	return m_titleStr;
}

- (void) setTitleStr : (NSString *) aString
{
	[self setTitleStrWithoutNeedingDisplay: aString];
	[self setNeedsDisplay: YES];
}

- (void) setTitleStrWithoutNeedingDisplay: (NSString *) aString
{
	[aString retain];
	[m_titleStr release];
	m_titleStr = aString;
}

- (NSString *) infoStr
{
	return m_infoStr;
}

- (void) setInfoStr: (NSString *) aString
{
	[self setInfoStrWithoutNeedingDisplay: aString];
	[self setNeedsDisplay: YES];
}

- (void) setInfoStrWithoutNeedingDisplay: (NSString *) aString
{
	[aString retain];
	[m_infoStr release];
	m_infoStr = aString;
}

- (BSTitleRulerModeType) currentMode
{
	return _currentMode;
}

- (void) setCurrentMode: (BSTitleRulerModeType) newType
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
	
	[self setRuleThickness: newThickness];
}

+ (NSColor *) titleTextColor
{
	return m_titleTextColor;
}

+ (void) setTitleTextColor: (NSColor *) aColor
{
	m_titleTextColor = aColor;
}

#pragma mark Private Utilities

+ (void) registerBgImage: (NSImage *) anImage
{
	m_bgImage = anImage;
	
	NSSize	tmp_ = [m_bgImage size];
	bgImgRect = NSMakeRect(0, 0, tmp_.width, tmp_.height);
}

+ (void) registerBgImageNonActive : (NSImage *) anImage
{
	m_bgImageNonActive = anImage;
	
	NSSize	tmp_ = [m_bgImageNonActive size];
	bgImgNARect = NSMakeRect(0, 0, tmp_.width, tmp_.height);
}

+ (NSDictionary *) attrTemplateForTitle
{
	NSDictionary	*tmp;
	NSColor			*color_;
	NSShadow		*shadow_;

	color_ = [self titleTextColor];

	shadow_ = [[NSShadow alloc] init];
	[shadow_ setShadowOffset     : NSMakeSize(1.5, -1.5)];
	[shadow_ setShadowBlurRadius : 0.3];

	tmp = [NSDictionary dictionaryWithObjectsAndKeys :
				[NSFont boldSystemFontOfSize : TITLE_FONT_SIZE], NSFontAttributeName,
				color_, NSForegroundColorAttributeName,
				shadow_, NSShadowAttributeName,
				nil];

	[shadow_ release];

	return tmp;
}

+ (NSDictionary *) attrTemplateForInfo
{
	NSDictionary	*tmp;
	NSColor			*color_;

	color_ = [NSColor blackColor];

	tmp = [NSDictionary dictionaryWithObjectsAndKeys :
				[NSFont systemFontOfSize : INFO_FONT_SIZE], NSFontAttributeName,
				color_, NSForegroundColorAttributeName,
				nil];

	return tmp;
}

+ (NSColor *) infoBgColor
{
	return [NSColor colorWithCalibratedRed: 0.918 green: 0.847 blue: 0.714 alpha: 1.0];
}

- (NSAttributedString *) titleForDrawing
{
	return [[[NSAttributedString alloc] initWithString: [self titleStr] attributes: [[self class] attrTemplateForTitle]] autorelease];
}

- (NSAttributedString *) infoForDrawing
{
	return [[[NSAttributedString alloc] initWithString: [self infoStr] attributes: [[self class] attrTemplateForInfo]] autorelease];
}

+ (BOOL) isGraphiteNow
{
	if ([NSColor currentControlTint] == NSGraphiteControlTint)
		return YES;
		
	return NO;
}

#pragma mark Setup & Cleanup

+ (void) initialize
{
	if (self == [BSTitleRulerView class]) {
		[self registerBgImage: ([self isGraphiteNow] ? [NSImage imageAppNamed : kTRViewBgImgGraphiteKey]
													 : [NSImage imageAppNamed : kTRViewBgImgBlueKey])];
		[self registerBgImageNonActive: [NSImage imageAppNamed : kTRViewBgImageNonActiveKey]];

		// initialize text color
		[self setTitleTextColor: [NSColor whiteColor]];
	}
}
		
- (id) initWithScrollView: (NSScrollView *) aScrollView orientation: (NSRulerOrientation) orientation
{
	if (self = [super initWithScrollView : aScrollView orientation : NSHorizontalRuler]) {
		// Original NSRulerView Properties
		[self setMarkers : nil];
		[self setReservedThicknessForMarkers : 0.0];

		// Notifications
		[[NSNotificationCenter defaultCenter]
			 addObserver : self
				selector : @selector(userDidChangeSystemColors:)
					name : NSSystemColorsDidChangeNotification
				  object : nil];

		[[NSNotificationCenter defaultCenter]
			 addObserver : self
				selector : @selector(keyWindowDidChange:)
					name : NSWindowDidBecomeKeyNotification
				  object : [self window]];

		[[NSNotificationCenter defaultCenter]
			 addObserver : self
				selector : @selector(keyWindowDidChange:)
					name : NSWindowDidResignKeyNotification
				  object : [self window]];

		// BSTitleRulerView Properties
		[self setCurrentMode : BSTitleRulerShowTitleOnlyMode];
		[self setTitleStr : NSLocalizedString(kTitleRulerViewDefaultTitleKey, @"BathyScaphe")];
	}
	return self;
}

- (void) dealloc
{
	[[NSNotificationCenter defaultCenter]
	  removeObserver : self
	            name : NSSystemColorsDidChangeNotification
	          object : nil];
	[[NSNotificationCenter defaultCenter]
	  removeObserver : self
	            name : NSWindowDidBecomeKeyNotification
	          object : [self window]];

	[[NSNotificationCenter defaultCenter]
	  removeObserver : self
	            name : NSWindowDidResignKeyNotification
	          object : [self window]];

	[m_titleStr release];
	[m_infoStr release];

	[super dealloc];
}

#pragma mark Drawing

- (void) drawTitleBarInRect: (NSRect) aRect
{
	BOOL	isKeyWin_;
	NSImage	*img_;
	NSRect	img_Rect;

	isKeyWin_ = [[self window] isKeyWindow];
	img_ = isKeyWin_ ? m_bgImage : m_bgImageNonActive;
	img_Rect = isKeyWin_ ? bgImgRect : bgImgNARect;

	[img_ setFlipped: [self isFlipped]];

	[img_ drawInRect : aRect fromRect : img_Rect operation : NSCompositeCopy fraction : 1.0];
	[[self titleForDrawing] drawInRect : NSInsetRect(aRect, 5.0, 2.0)];
}

- (void) drawInfoBarInRect: (NSRect) aRect
{
	NSRect	iconRect;
	//NSImage	*icon_ = [NSImage imageAppNamed: kTRViewInfoIconKey];
	NSImage *icon_ = [[NSWorkspace sharedWorkspace] systemIconForType: kAlertNoteIcon];
	[icon_ setSize: NSMakeSize(32, 32)];
	[icon_ setFlipped: [self isFlipped]];
	[[[self class] infoBgColor] set];
	NSRectFill(aRect);	

	iconRect = NSMakeRect(NSMinX(aRect)+5.0, NSMinY(aRect)+2.0, 32, 32);

	[icon_ drawInRect: iconRect fromRect: NSMakeRect(0,0,32,32) operation: NSCompositeSourceOver fraction: 1.0];

	aRect = NSInsetRect(aRect, 5.0, 7.0);
	aRect.origin.x += 36.0;
	[[self infoForDrawing] drawInRect : NSInsetRect(aRect, 5.0, 2.0)];
}

- (void) drawRect : (NSRect) aRect
{
	switch ([self currentMode]) {
	case BSTitleRulerShowTitleOnlyMode:
		[self drawTitleBarInRect: aRect];
		break;
	case BSTitleRulerShowInfoOnlyMode:
		[self drawInfoBarInRect: aRect];
		break;
	case BSTitleRulerShowTitleAndInfoMode:
		{
			NSRect titleRect, infoRect;
			NSDivideRect(aRect, &infoRect, &titleRect, THICKNESS_FOR_INFO, NSMaxYEdge);
			[self drawTitleBarInRect: titleRect];
			[self drawInfoBarInRect: infoRect];
		}
		break;
	}
}

#pragma mark Notifications

- (void) userDidChangeSystemColors : (NSNotification *) theNotification
{
	[[self class] registerBgImage : ([[self class] isGraphiteNow] ? [NSImage imageAppNamed : kTRViewBgImgGraphiteKey]
																  : [NSImage imageAppNamed : kTRViewBgImgBlueKey])];

	[self setNeedsDisplay : YES];
}

- (void) keyWindowDidChange : (NSNotification *) theNotification
{
	[self setNeedsDisplay : YES];
}
@end
