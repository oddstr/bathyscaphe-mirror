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

static NSString *const kTitleRulerViewBgImageKey		= @"titleRulerBackground";
static NSString *const kTitleRulerViewDefaultTitleKey	= @"titleRuler default title";

@implementation BSTitleRulerView

float	imgWidth, imgHeight;

#pragma mark Private
+ (NSDictionary *) attrTemplate
{
	NSDictionary	*tmp;
	NSColor			*color_;
	NSShadow		*shadow_;

	color_ = ([CMRPref isTitleRulerViewTextUsesBlackColor] ? [NSColor blackColor] : [NSColor whiteColor]);

	shadow_ = [[NSShadow alloc] init];
	[shadow_ setShadowOffset     : NSMakeSize(2.0, -2.0)];
	[shadow_ setShadowBlurRadius : 0.5];

	tmp = [NSDictionary dictionaryWithObjectsAndKeys :
				[NSFont boldSystemFontOfSize : 13.0], NSFontAttributeName,
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

#pragma mark -
- (id) initWithScrollView : (NSScrollView *) scrollView
{
	m_scrollView	= scrollView;
	m_titleStr		= [NSLocalizedString(kTitleRulerViewDefaultTitleKey, @"BathyScaphe") retain];
	m_bgImage		= [NSImage imageAppNamed : kTitleRulerViewBgImageKey];

	imgWidth	= [m_bgImage size].width;
	imgHeight	= [m_bgImage size].height;

	[super initWithScrollView : m_scrollView orientation : NSHorizontalRuler];

	[self setMarkers : nil];
	[self setReservedThicknessForMarkers : 0.0];
	[self setRuleThickness : 24.0];

	[[NSNotificationCenter defaultCenter]
	     addObserver : self
	        selector : @selector(threadViewerDidChangeThread:)
	            name : CMRThreadViewerDidChangeThreadNotification
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

	// 意外と重要
	[m_bgImage setFlipped : [self isFlipped]];

	[self lockFocus];
	// 背景を描く
	[m_bgImage drawInRect : rect_ fromRect : NSMakeRect(0, 0, imgWidth, imgHeight) operation : NSCompositeCopy fraction : 1.0];
	// スレッドタイトルを描く
	[[self titleForDrawing] drawInRect : NSInsetRect(rect_, 5.0, 2.0)];
	[self unlockFocus];
}

- (void) threadViewerDidChangeThread : (NSNotification *) theNotification
{
	// ブラウザのスレ表示領域が切り替わったときだけ、スレッドタイトルを更新する。
	// 全部の通知に反応してしまうと、別ウインドウでスレが切り替わった際にもスレッドタイトルが
	// （その別ウインドウのものに）変わってしまう！
	if ([[theNotification object] class] == [CMRBrowser class]) {
		NSString				*title_, *bName_;
		CMRThreadAttributes		*threadAttributes_;
		id	tmp;

		threadAttributes_ = [[theNotification object] threadAttributes];
		title_ = [threadAttributes_ threadTitle];
		bName_ = [threadAttributes_ boardName];
		if(nil == title_)
			title_ = @"Title is nil";
		if(nil == bName_)
			bName_ = @"Board name is nil";
		
		tmp = m_titleStr;
		m_titleStr = [[NSString alloc] initWithFormat : @"%@ - %@", title_, bName_];
		[tmp release];

		[self setNeedsDisplay:YES];	// 再描画させるのが大切
	}
}

- (void) dealloc
{
	[[NSNotificationCenter defaultCenter]
	  removeObserver : self
	            name : CMRThreadViewerDidChangeThreadNotification
	          object : nil];

	[m_titleStr release];
	[m_bgImage release];
	[super dealloc];
}
@end
