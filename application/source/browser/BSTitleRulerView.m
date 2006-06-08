//
//  $Id: BSTitleRulerView.m,v 1.10.2.1 2006/06/08 00:04:49 tsawada2 Exp $
//  BathyScaphe
//
//  Created by Tsutomu Sawada on 05/09/22.
//  Copyright 2005-2006 BathyScaphe Project. All rights reserved.
//

#import "BSTitleRulerView.h"
#import "AppDefaults.h"

static NSString *const kTRViewBgImgBlueKey				= @"titleRulerBgAquaBlue";
static NSString *const kTRViewBgImgGraphiteKey			= @"titleRulerBgAquaGraphite";
static NSString *const kTitleRulerViewDefaultTitleKey	= @"titleRuler default title";
static NSString *const kTRViewBgImageNonActiveKey		= @"titleRulerBgNotActive";
static NSString *const kTRViewInfoIconKey				= @"titleRulerInfoIcon";

NSRect	bgImgRect;
NSRect	bgImgNARect;

@implementation BSTitleRulerView

#pragma mark Accessors

- (NSImage *) bgImage
{
	return m_bgImage;
}

- (NSImage *) bgImageNonActive
{
	return m_bgImageNonActive;
}

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

- (NSColor *) textColor
{
	return m_textColor;
}

- (void) setTextColor: (NSColor *) aColor
{
	[aColor retain];
	[m_textColor release];
	m_textColor = aColor;
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
		newThickness = 22.0;
		break;
	case BSTitleRulerShowInfoOnlyMode:
		newThickness = 36.0;
		break;
	case BSTitleRulerShowTitleAndInfoMode:
		newThickness = 58.0;
		break;
	default:
		newThickness = 22.0;
		break;
	}
	
	[self setRuleThickness: newThickness];
}

#pragma mark Private Utilities

- (void) setBgImage : (NSImage *) anImage
{
	[anImage retain];
	[m_bgImage release];
	m_bgImage = anImage;
	
	NSSize	tmp_ = [m_bgImage size];
	bgImgRect = NSMakeRect(0, 0, tmp_.width, tmp_.height);

	[m_bgImage setFlipped : [self isFlipped]];
}

- (void) setBgImageNonActive : (NSImage *) anImage
{
	[anImage retain];
	[m_bgImageNonActive release];
	m_bgImageNonActive = anImage;
	
	NSSize	tmp_ = [m_bgImageNonActive size];
	bgImgNARect = NSMakeRect(0, 0, tmp_.width, tmp_.height);
	
	[m_bgImageNonActive setFlipped : [self isFlipped]];
}

+ (NSDictionary *) attrTemplateForTitle
{
	NSDictionary	*tmp;
	NSColor			*color_;
	NSShadow		*shadow_;

	color_ = ([CMRPref titleRulerViewTextUsesBlackColor] ? [NSColor blackColor] : [NSColor whiteColor]);

	shadow_ = [[NSShadow alloc] init];
	[shadow_ setShadowOffset     : NSMakeSize(1.5, -1.5)];
	[shadow_ setShadowBlurRadius : 0.3];

	tmp = [NSDictionary dictionaryWithObjectsAndKeys :
				[NSFont boldSystemFontOfSize : 12.0], NSFontAttributeName,
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
				[NSFont systemFontOfSize : 13.0], NSFontAttributeName,
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

- (BOOL) isGraphiteNow
{
	if ([NSColor currentControlTint] == NSGraphiteControlTint)
		return YES;
		
	return NO;
}

#pragma mark Setup & Cleanup

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

		// BSTitleRulerView Settings
		[self setBgImage : ([self isGraphiteNow] ? [NSImage imageAppNamed : kTRViewBgImgGraphiteKey]
												 : [NSImage imageAppNamed : kTRViewBgImgBlueKey])];
		
		[self setBgImageNonActive : [NSImage imageAppNamed : kTRViewBgImageNonActiveKey]];
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
	[m_bgImage release];
	[m_bgImageNonActive release];
	[m_textColor release];
	[super dealloc];
}

#pragma mark Drawing

- (void) drawTitleBarInRect: (NSRect) aRect
{
	BOOL	isKeyWin_;
	NSImage	*img_;
	NSRect	img_Rect;

	isKeyWin_ = [[self window] isKeyWindow];
	img_ = isKeyWin_ ? [self bgImage] : [self bgImageNonActive];
	img_Rect = isKeyWin_ ? bgImgRect : bgImgNARect;

	[img_ drawInRect : aRect fromRect : img_Rect operation : NSCompositeCopy fraction : 1.0];
	[[self titleForDrawing] drawInRect : NSInsetRect(aRect, 5.0, 2.0)];
}

- (void) drawInfoBarInRect: (NSRect) aRect
{
	NSRect	iconRect;
	NSImage	*icon_ = [NSImage imageAppNamed: kTRViewInfoIconKey];
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
	NSRect	rect_;

	// 完全に領域を塗りつぶすため、微調整
	rect_ = [self frame];
	rect_.origin.x -= 1.0;
	rect_.origin.y -= 1.0;

	switch ([self currentMode]) {
	case BSTitleRulerShowTitleOnlyMode:
		[self drawTitleBarInRect: rect_];
		break;
	case BSTitleRulerShowInfoOnlyMode:
		[self drawInfoBarInRect: rect_];
		break;
	case BSTitleRulerShowTitleAndInfoMode:
		{
			NSRect titleRect, infoRect;
			NSDivideRect(rect_, &infoRect, &titleRect, 36.0, NSMaxYEdge);
			[self drawTitleBarInRect: titleRect];
			[self drawInfoBarInRect: infoRect];
		}
		break;
	}
}

#pragma mark Notifications

- (void) userDidChangeSystemColors : (NSNotification *) theNotification
{
	[self setBgImage : ([self isGraphiteNow] ? [NSImage imageAppNamed : kTRViewBgImgGraphiteKey]
											 : [NSImage imageAppNamed : kTRViewBgImgBlueKey])];
	[self setNeedsDisplay : YES];
}

- (void) keyWindowDidChange : (NSNotification *) theNotification
{
	[self setNeedsDisplay : YES];
}
@end
