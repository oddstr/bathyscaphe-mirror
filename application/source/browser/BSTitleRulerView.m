//
//  BSTitleRulerView.m
//  BathyScaphe
//
//  Created by Tsutomu Sawada on 05/09/22.
//  Copyright 2005 BathyScaphe Project. All rights reserved.
//

#import "BSTitleRulerView.h"
#import "CMRThreadAttributes.h"
#import "AppDefaults.h"

static NSString *const kTRViewBgImgBlueKey				= @"titleRulerBgAquaBlue";
static NSString *const kTRViewBgImgGraphiteKey			= @"titleRulerBgAquaGraphite";
static NSString *const kTitleRulerViewDefaultTitleKey	= @"titleRuler default title";
static NSString *const kTitleRulerViewNilTitleKey		= @"titleRuler nil title";
static NSString *const kTitleRulerViewNilBNameKey		= @"titleRuler nil boardName";

static NSString *const kTRViewBgImageNonActiveKey		= @"titleRulerBgNotActive";

@implementation BSTitleRulerView

//float	imgWidth, imgHeight;
//float	imgNAWidth, imgNAHeight; 
NSRect	bgImgRect;
NSRect	bgImgNARect;

#pragma mark Accessors
- (NSImage *) bgImage
{
	return m_bgImage;
}

- (NSString *) titleStr
{
	return m_titleStr;
}

- (NSImage *) bgImageNonActive
{
	return m_bgImageNonActive;
}

#pragma mark Private

- (void) setBgImage : (NSImage *) anImage
{
	[anImage retain];
	[m_bgImage release];
	m_bgImage = anImage;

	//imgWidth	= [m_bgImage size].width;
	//imgHeight	= [m_bgImage size].height;
	
	NSSize	tmp_ = [m_bgImage size];
	bgImgRect = NSMakeRect(0, 0, tmp_.width, tmp_.height);

	// 意外と重要
	[m_bgImage setFlipped : [self isFlipped]];
}

- (void) setBgImageNonActive : (NSImage *) anImage
{
	[anImage retain];
	[m_bgImageNonActive release];
	m_bgImageNonActive = anImage;
	
	//imgNAWidth	= [m_bgImageNonActive size].width;
	//imgNAHeight	= [m_bgImageNonActive size].height;
	
	NSSize	tmp_ = [m_bgImageNonActive size];
	bgImgNARect = NSMakeRect(0, 0, tmp_.width, tmp_.height);
	
	[m_bgImageNonActive setFlipped : [self isFlipped]];
}

- (void) setTitleStr : (NSString *) aString
{
	[aString retain];
	[m_titleStr release];
	m_titleStr = aString;
}

+ (NSDictionary *) attrTemplate
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

- (NSAttributedString *) titleForDrawing
{
	return [[[NSAttributedString alloc] initWithString : m_titleStr attributes : [[self class] attrTemplate]] autorelease];
}

- (BOOL) isGraphiteNow
{
	if ([NSColor currentControlTint] == NSGraphiteControlTint)
		return YES;
		
	return NO;
}

#pragma mark -

- (id) initWithScrollView : (NSScrollView *) scrollView ofBrowser : (CMRBrowser *) browser
{
	[self setTitleStr : NSLocalizedString(kTitleRulerViewDefaultTitleKey, @"BathyScaphe")];
	[self setBgImage : ([self isGraphiteNow] ? [NSImage imageAppNamed : kTRViewBgImgGraphiteKey]
											 : [NSImage imageAppNamed : kTRViewBgImgBlueKey])];
	
	[self setBgImageNonActive : [NSImage imageAppNamed : kTRViewBgImageNonActiveKey]];

	[super initWithScrollView : scrollView orientation : NSHorizontalRuler];

	[self setMarkers : nil];
	[self setReservedThicknessForMarkers : 0.0];
	[self setRuleThickness : 22.0];

	[[NSNotificationCenter defaultCenter]
	     addObserver : self
	        selector : @selector(threadViewerDidChangeThread:)
	            name : CMRThreadViewerDidChangeThreadNotification
	          object : browser]; // 通知の発信元が browser のもののみ観察する

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
  
	return self;
}

- (void) drawRect : (NSRect) aRect
{
	NSRect	rect_;
	BOOL	isKeyWin_;
	NSImage	*img_;
	NSRect	img_Rect;

	// 完全に領域を塗りつぶすため、微調整
	rect_ = [self frame];
	rect_.origin.x -= 1.0;
	rect_.origin.y -= 1.0;

	isKeyWin_ = [[self window] isKeyWindow];
	img_ = isKeyWin_ ? [self bgImage] : [self bgImageNonActive];
	img_Rect = isKeyWin_ ? bgImgRect : bgImgNARect;
	// 背景を描く
	[img_ drawInRect : rect_ fromRect : img_Rect operation : NSCompositeCopy fraction : 1.0];
	// スレッドタイトルを描く
	[[self titleForDrawing] drawInRect : NSInsetRect(rect_, 5.0, 2.0)];
}

- (void) threadViewerDidChangeThread : (NSNotification *) theNotification
{
	NSString				*title_, *bName_;
	CMRThreadAttributes		*threadAttributes_;

	threadAttributes_ = [[theNotification object] threadAttributes];
	title_ = [threadAttributes_ threadTitle];
	bName_ = [threadAttributes_ boardName];
	if(nil == title_)
		title_ = NSLocalizedString(kTitleRulerViewNilTitleKey, @"Title is nil");
	if(nil == bName_)
		bName_ = NSLocalizedString(kTitleRulerViewNilBNameKey, @"Board name is nil");
	[self setTitleStr : [[NSString alloc] initWithFormat : @"%@ - %@", title_, bName_]];
	[self setNeedsDisplay : YES];	// 再描画させるのが大切
}

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

- (void) dealloc
{
	[[NSNotificationCenter defaultCenter]
	  removeObserver : self
	            name : CMRThreadViewerDidChangeThreadNotification
	          object : nil];
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
	[m_bgImage release];
	[super dealloc];
}
@end
