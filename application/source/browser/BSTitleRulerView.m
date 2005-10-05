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

@implementation BSTitleRulerView

float	imgWidth, imgHeight;

#pragma mark Accessors
- (NSImage *) bgImage
{
	return m_bgImage;
}

- (NSString *) titleStr
{
	return m_titleStr;
}

#pragma mark Private

- (void) setBgImage : (NSImage *) anImage
{
	[anImage retain];
	[m_bgImage release];
	m_bgImage = anImage;

	imgWidth	= [m_bgImage size].width;
	imgHeight	= [m_bgImage size].height;

	// 意外と重要
	[m_bgImage setFlipped : [self isFlipped]];
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

- (id) initWithScrollView : (NSScrollView *) scrollView
{
	[self setTitleStr : NSLocalizedString(kTitleRulerViewDefaultTitleKey, @"BathyScaphe")];
	[self setBgImage : ([self isGraphiteNow] ? [NSImage imageAppNamed : kTRViewBgImgGraphiteKey]
											 : [NSImage imageAppNamed : kTRViewBgImgBlueKey])];

	[super initWithScrollView : scrollView orientation : NSHorizontalRuler];

	[self setMarkers : nil];
	[self setReservedThicknessForMarkers : 0.0];
	[self setRuleThickness : 22.0];

	[[NSNotificationCenter defaultCenter]
	     addObserver : self
	        selector : @selector(threadViewerDidChangeThread:)
	            name : CMRThreadViewerDidChangeThreadNotification
	          object : nil];

	[[NSNotificationCenter defaultCenter]
	     addObserver : self
	        selector : @selector(userDidChangeSystemColors:)
	            name : NSSystemColorsDidChangeNotification
	          object : nil];
  
	return self;
}

- (void) drawRect : (NSRect) aRect
{
	NSRect	rect_;

	// 完全に領域を塗りつぶすため、微調整
	rect_ = [self frame];
	rect_.origin.x -= 1.0;
	rect_.origin.y -= 1.0;

	// 背景を描く
	[[self bgImage] drawInRect : rect_ fromRect : NSMakeRect(0, 0, imgWidth, imgHeight) operation : NSCompositeCopy fraction : 1.0];
	// スレッドタイトルを描く
	[[self titleForDrawing] drawInRect : NSInsetRect(rect_, 5.0, 2.0)];
}

- (void) threadViewerDidChangeThread : (NSNotification *) theNotification
{
	// ブラウザのスレ表示領域が切り替わったときだけ、スレッドタイトルを更新する。
	// 全部の通知に反応してしまうと、別ウインドウでスレが切り替わった際にもスレッドタイトルが
	// （その別ウインドウのものに）変わってしまう！
	if ([[theNotification object] class] == [CMRBrowser class]) {
		NSString				*title_, *bName_;
		CMRThreadAttributes		*threadAttributes_;

		threadAttributes_ = [[theNotification object] threadAttributes];
		title_ = [threadAttributes_ threadTitle];
		bName_ = [threadAttributes_ boardName];
		if(nil == title_)
			title_ = @"Title is nil";
		if(nil == bName_)
			bName_ = @"Board name is nil";
		
		[self setTitleStr : [[NSString alloc] initWithFormat : @"%@ - %@", title_, bName_]];
		[self setNeedsDisplay : YES];	// 再描画させるのが大切
	}
}

- (void) userDidChangeSystemColors : (NSNotification *) theNotification
{
	[self setBgImage : ([self isGraphiteNow] ? [NSImage imageAppNamed : kTRViewBgImgGraphiteKey]
											 : [NSImage imageAppNamed : kTRViewBgImgBlueKey])];
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

	[m_titleStr release];
	[m_bgImage release];
	[super dealloc];
}
@end
