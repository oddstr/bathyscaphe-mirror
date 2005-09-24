//: CMXPopUpWindowController+View.m
/**
  * $Id: CMXPopUpWindowController+View.m,v 1.5 2005/09/24 06:07:49 tsawada2 Exp $
  * 
  * Copyright (c) 2001-2003, Takanori Ishikawa.  All rights reserved.
  * See the file LICENSE for copying permission.
  */

#import "CMXPopUpWindowController_p.h"
#import "NSLayoutManager+CMXAdditions.h"
#import "CMRLayoutManager.h"
#import "CMRPopUpTemplateKeys.h"
#import "CMXPopUpWindowManager.h"
#import "AppDefaults.h"
#import "SGContextHelpPanel.h"
#import "CMRMessageAttributesTemplate.h"

#define POPUP_TEXTINSET			SGTemplateSize(kTextContainerInsetKey)
#define POPUP_SCAN_MAXLINE		40


@implementation CMXPopUpWindowController(ViewInitializer)
- (void) registerToNotificationCenter
{
	[[NSNotificationCenter defaultCenter]
		addObserver : self
		selector : @selector(threadViewMouseExitedNotification:)
		name : SGHTMLViewMouseExitedNotification
		object : [self textView]];
}
- (void) createUIComponents
{
	[self createHelpWindow];
	[self createScrollView];
	[self createHTMLTextView];
	[self registerToNotificationCenter];
}

- (void) createHelpWindow
{
	NSPanel			*panel_;
	id				tmp;

	panel_ = [[SGContextHelpPanel alloc]
	             initWithContentRect : DEFAULT_CONTENT_RECT
						   styleMask : 
			(NSBorderlessWindowMask | NSClosableWindowMask | NSMiniaturizableWindowMask)
						     backing : NSBackingStoreBuffered
							   defer : YES];

	[panel_ setOneShot : NO];

	tmp = SGTemplateResource(kPopUpIsFloatingPanelKey);
	UTILAssertKindOfClass(tmp, NSNumber);
	[panel_ setFloatingPanel : [tmp boolValue]];
	tmp = SGTemplateResource(kPopUpBecomesKeyOnlyIfNeededKey);
	UTILAssertKindOfClass(tmp, NSNumber);
	[panel_ setBecomesKeyOnlyIfNeeded : [tmp boolValue]];
	tmp = SGTemplateResource(kPopUpHasShadowKey);
	UTILAssertKindOfClass(tmp, NSNumber);
	[panel_ setHasShadow : [tmp boolValue]];
	
	[panel_ setDelegate : self];
	[self setWindow : panel_];
	
	[panel_ release];
}
- (void) createScrollView
{
	NSScrollView	*scrollview_;
	NSRect			vFrame_;
	id				tmp;
	
	UTILAssertNotNil([self window]);
	
	vFrame_ = [[[self window] contentView] frame];
	scrollview_ = [[NSScrollView alloc] initWithFrame : vFrame_];
	
	tmp = SGTemplateResource(kPopUpBorderTypeKey);
	UTILAssertKindOfClass(tmp, NSNumber);
	[scrollview_ setBorderType : [tmp intValue]];
	[scrollview_ setHasVerticalScroller : NO];
	[scrollview_ setHasHorizontalScroller : NO];
	
	[scrollview_ setAutoresizingMask : 
		(NSViewWidthSizable | NSViewHeightSizable)];
	[scrollview_ setAutoresizesSubviews : YES];
	
	[[[self window] contentView] addSubview : scrollview_];
	[scrollview_ release];
	
	[self setScrollView : scrollview_];
}

- (void) createHTMLTextView
{
	NSLayoutManager		*layoutManager_;
	NSTextContainer		*tcontainer_;
	NSTextView			*textView_;
	

	NSRect cFrame_;
	NSSize contentSize_;
	
	if ([self textView] != nil) return;
	
	contentSize_ = [[self scrollView] contentSize];
	cFrame_ = NSMakeRect(
				0.0f,
				0.0f,
				contentSize_.width,
				contentSize_.height);
	
	layoutManager_ = [[CMRLayoutManager alloc] init];
	[[self textStorage] addLayoutManager : layoutManager_];
	[layoutManager_ release];
	
	
	tcontainer_ = 
		[[NSTextContainer alloc] initWithContainerSize : 
			  NSMakeSize(contentSize_.width, 1e7)];
	[layoutManager_ addTextContainer : tcontainer_];
	[tcontainer_ release];
	
	
	textView_ = [[CMRThreadView alloc] 
					initWithFrame : cFrame_ 
					textContainer : tcontainer_];
	
	[textView_ setMinSize : NSMakeSize(0.0, contentSize_.height)];
	[textView_ setMaxSize : NSMakeSize(1e7, 1e7)];
	
	// リンク文字列の書式はここでセットしておく
	if ([CMRPref isResPopUpTextDefaultColor]) {
		if ([CMRPref hasMessageAnchorUnderline]) {
			[textView_ setLinkTextAttributes : [NSDictionary dictionaryWithObject : [NSNumber numberWithInt : NSUnderlineStyleSingle]
																		   forKey : NSUnderlineStyleAttributeName]];
		} else {
			[textView_ setLinkTextAttributes : [NSDictionary empty]];
		}
	} else {
		[textView_ setLinkTextAttributes : [[CMRMessageAttributesTemplate sharedTemplate] attributesForAnchor]];
	}
	[textView_ setTextContainerInset : POPUP_TEXTINSET];
	
	[textView_ setVerticallyResizable :YES];
	[textView_ setHorizontallyResizable : NO];
	[textView_ setAutoresizingMask : NSViewWidthSizable];
	
	[textView_ setEditable : NO];
	[textView_ setSelectable : YES];
	[textView_ setAllowsUndo : NO];
	[tcontainer_ setWidthTracksTextView : YES];
	
	[self setTextView : textView_];
	[textView_ setFieldEditor : NO];

	[[self scrollView] setDocumentView : textView_];
	[[self window] setInitialFirstResponder : textView_];
	[textView_ release];
	
}
@end



@implementation CMXPopUpWindowController(Resizing)
- (NSRect) constrainWindowFrame : (NSRect) windowFrame
{
	NSPoint		wTopLeft_;
	NSPoint		scTopLeft_;
	NSRect		newFrame_;
	NSRect		visibleScreen_;
	
	
	newFrame_ = windowFrame;
	
	visibleScreen_ = [[NSScreen mainScreen] visibleFrame];
	scTopLeft_ = visibleScreen_.origin;
	scTopLeft_.y = NSMaxY(visibleScreen_);
	
	wTopLeft_ = newFrame_.origin;
	wTopLeft_.y = NSMaxY(newFrame_);
	
	// x
	{
		float	screenX_;
		float	windowX_;
		
		screenX_ = NSMaxX(visibleScreen_);
		windowX_ = NSMaxX(newFrame_);
		if (windowX_ > screenX_)
			newFrame_.origin.x -= (windowX_ - screenX_);
		
		screenX_ = NSMinX(visibleScreen_);
		windowX_ = NSMinX(newFrame_);
		if (windowX_ < screenX_)
			newFrame_.origin.x += (windowX_ - screenX_);
	}
	// y
	if (wTopLeft_.y > scTopLeft_.y) {
		wTopLeft_.y = scTopLeft_.y;
		newFrame_.origin.y = (wTopLeft_.y - newFrame_.size.height);
	}else if (newFrame_.origin.y < visibleScreen_.origin.y) {
		newFrame_.origin.y = visibleScreen_.origin.y;
	}
	
	return newFrame_;
}

- (NSSize) maxSize
{
	NSSize		maxSize_;
	NSRect		visibleScreen_;
	id			tmp;
	double		maxWidthRate_;
	
	[NSApplication sharedApplication];
	visibleScreen_ = [[NSScreen mainScreen] visibleFrame];
	maxSize_ = visibleScreen_.size;
	
	tmp = SGTemplateResource(kPopUpMaxWidthRateKey);
	if (nil == tmp || NO == [tmp respondsToSelector : @selector(doubleValue)])
		maxWidthRate_ = 0.5;
	else
		maxWidthRate_ = [tmp doubleValue];
	
	if (maxWidthRate_ >= 1 || maxWidthRate_ <= 0)
		maxWidthRate_ = 0.5;
	
	maxSize_.width *= maxWidthRate_;
	
	return maxSize_;
}
- (NSRect) usedFullRectForTextContainer
{
	NSSize				newSize_;
	NSTextContainer		*container_ = [[self textView] textContainer];
	NSLayoutManager		*lm         = [container_ layoutManager];

	unsigned	nLines_  = 0;
	unsigned	nGlyphs_ = 0;
	unsigned	index_   = 0;
	NSRect		bodyRect_ = NSZeroRect;
	NSRect		usedRect_ = NSZeroRect;


	newSize_ = [[self textView] frame].size;
	newSize_.width = [self maxSize].width;
	[[self textView] setFrameSize : newSize_];
	
	
	// [Mac OS X 10.3]
	// - [NSLayoutManager usedRectForTextContainer:]
	// なぜか、複数行の場合、boundingRectを返す。
/*
	rect_ = [lm usedRectForTextContainer:container_];
*/
	
	bodyRect_ = [lm boundingRectForTextContainer : container_];
	nGlyphs_ = [lm numberOfGlyphs];
	
	// 最大 POPUP_SCAN_MAXLINE 行までスキャン
	while (index_ < nGlyphs_ && nLines_++ < POPUP_SCAN_MAXLINE) {
		NSRect		rect_;
		NSRange		efRange_;
		float		width_;
		
		rect_ = [lm lineFragmentUsedRectForGlyphAtIndex : index_
										 effectiveRange : &efRange_];
		// 左マージンを考慮
		width_ = NSMaxX(rect_);
		
		if (width_ > NSWidth(usedRect_))
			usedRect_.size.width = width_;
		
		index_ = NSMaxRange(efRange_);
	}
	
	usedRect_.size.height = NSHeight(bodyRect_);
	
	return usedRect_;
}

- (void) setUpScrollers
{
	BOOL			flag_ = YES;
	NSScroller		*scroller_;
	
	if (NO == [self hasVerticalScroller])
		return;
	
	if ([self autohidesScrollers]) {
		float	contentHeight_;
		
		contentHeight_ = ([[self scrollView] contentSize]).height;
		flag_ = contentHeight_ < NSHeight([[self textView] frame]);
	}
	[[self scrollView] setHasVerticalScroller : flag_];
	
	if (NO == flag_)
		return;
	
	scroller_ = [[self scrollView] verticalScroller];
	if ([self verticalScrollerIsSmall]) {
		[scroller_ setControlSize : NSSmallControlSize];
	} else {
		[scroller_ setControlSize : NSRegularControlSize];
	}
}
- (void) sizeToFit
{
	NSScrollView		*scrollView_ = [self scrollView];
	NSTextView			*textView_   = [self textView];
	
	NSSize		textViewSize_;
	NSSize		scrollViewSize_;
	NSSize		maxSize_ = [self maxSize];
	NSRect		fixRect_;
	NSSize		textInset_  = [[self textView] textContainerInset];
	
	fixRect_ = [self usedFullRectForTextContainer];
	fixRect_.size.height += textInset_.height * 2;
	fixRect_.size.width += textInset_.width * 2;
	
	textViewSize_ = fixRect_.size;
	scrollViewSize_ = [scrollView_ frameSizeForContentSize : textViewSize_];
	if (scrollViewSize_.width > maxSize_.width) 
		scrollViewSize_.width = maxSize_.width;
	if (scrollViewSize_.height > maxSize_.height) 
		scrollViewSize_.height = maxSize_.height;
	
	//[textView_ setFrameSize : textViewSize_];
	[[self window] setContentSize : scrollViewSize_];
	
	// ScrollViewにtextViewを合わせて、再度レイアウト
	textViewSize_.width = [scrollView_ contentSize].width;
	[textView_ setFrameSize : textViewSize_];
	
	// Scroller
	[self setUpScrollers];
}
@end



@implementation CMXPopUpWindowController(Accessor)
+ (float) windowAlphaValue
{
	/*id	tmp = SGTemplateResource(kPopUpWindowAlphaKey);
	UTILAssertKindOfClass(tmp, NSNumber);
	return [tmp floatValue];*/
	return [CMRPref resPopUpBgAlphaValue];
}
- (void) setBackgroundColor : (NSColor *) aColor
{
	// window
	[[self window] setBackgroundColor : aColor];
	// scrollView
	[[self scrollView] setDrawsBackground : NO];
	[[self scrollView] setBackgroundColor : aColor];
	
	[[self textView] setDrawsBackground : NO];
	[[self textView] setBackgroundColor : aColor];
}
- (NSColor *) backgroundColor
{
	return [[self window] backgroundColor];
}
- (void) setIsSeeThrough : (BOOL) flag
{
	[[self window] setAlphaValue : 
		(flag ? [[self class] windowAlphaValue] : 1.0f)];
}
- (BOOL) isSeeThrough
{
	return ([[self class] windowAlphaValue] == [[self window] alphaValue]);
}
- (BOOL) autohidesScrollers
{
	return YES;
}
- (BOOL) hasVerticalScroller
{
	return YES;
}
- (BOOL) verticalScrollerIsSmall
{
	return [CMRPref popUpWindowVerticalScrollerIsSmall];
}
@end
