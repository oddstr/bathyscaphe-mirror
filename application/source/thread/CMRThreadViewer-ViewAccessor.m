/**
  * $Id: CMRThreadViewer-ViewAccessor.m,v 1.16 2007/02/11 17:13:48 tsawada2 Exp $
  * 
  * CMRThreadViewer-ViewAccessor.m
  *
  * Copyright (c) 2003, Takanori Ishikawa.
  * See the file LICENSE for copying permission.
  */

#import "CMRThreadViewer_p.h"
#import "CMRThreadVisibleRange.h"
#import "CMRThreadViewerTbDelegate.h"
#import "CMRThreadView.h"
#import "CMRMainMenuManager.h"
#import "CMRMessageAttributesTemplate.h"
#import <SGAppKit/BSLayoutManager.h>

// for debugging only
#define UTIL_DEBUGGING		0
#import "UTILDebugging.h"


#define kComponentsLoadNibName	@"CMRThreadViewerComponents"
#define HTMLVIEW_CLASS			CMRThreadView


@implementation CMRThreadViewer(ViewAccessor)
- (NSScrollView *) scrollView
{
	return m_scrollView;
}
- (NSTextView *) textView
{
	return m_textView;
}
- (void) setTextView : (NSTextView *) aTextView
{
	m_textView = aTextView;
}

- (BSIndexingPopupper *) indexingPopupper
{
	if (nil == m_indexingPopupper)
		m_indexingPopupper = [[BSIndexingPopupper alloc] init];
	return m_indexingPopupper;
}
- (CMRIndexingStepper *) indexingStepper
{
	if (nil == m_indexingStepper)
		m_indexingStepper = [[CMRIndexingStepper alloc] init];
	return m_indexingStepper;
}
- (NSView *) navigationBar
{
	return m_navigationBar;
}
@end



@implementation CMRThreadViewer(UIComponents)
- (BOOL) loadComponents
{
	return [NSBundle loadNibNamed : kComponentsLoadNibName
							owner : self];
}
- (NSView *) containerView
{
	return m_containerView;
}
- (void) setupLoadedComponents
{
	NSString	*fs = [CMRPref windowDefaultFrameString];
	NSView		*containerView_;
	NSRect		vframe_;
	
	containerView_ = [self containerView];
	vframe_ = [m_windowContentView frame];
	
	[containerView_ retain];
	[containerView_ removeFromSuperviewWithoutNeedingDisplay];
	[containerView_ setFrame : vframe_];
	
	[[[self window] contentView] setAutoresizingMask : 
			(NSViewWidthSizable | NSViewHeightSizable)];
	[[[self window] contentView] setAutoresizesSubviews : YES];
	
	// ダミーのNSViewと入れ替える
	[m_windowContentView retain];
	[[[self window] contentView] replaceSubview : m_windowContentView
										   with : containerView_];
	[m_windowContentView release];
	m_windowContentView = nil;
	
	[containerView_ release];
	
	// 以前に保存しておいたウインドウの領域を
	// デフォルトのものとして使用する
	if (fs != nil) [[self window] setFrameFromString : fs];
}
@end

@implementation CMRThreadViewer(ViewInitializer)

#pragma mark Contextual Menu Stuff
+ (NSMenu *) clearkeyEquivalentInMenu : (NSMenu *) aMenu
{
	NSEnumerator	*iter_;
	NSMenuItem		*item_;
	
	iter_ = [[aMenu itemArray] objectEnumerator];
	while (item_ = [iter_ nextObject]) {
		[item_ setKeyEquivalent : @""];
		[self clearkeyEquivalentInMenu : [item_ submenu]];
	}
	return aMenu;
}
+ (NSMenu *) loadContextualMenuForTextView
{
	NSMenu			*menu_;
	NSMenu			*threadMenu_;
	NSMenu			*textViewMenu_;
	NSEnumerator	*iter_;
	NSMenuItem		*item_;
	
	threadMenu_ = [[[CMRMainMenuManager defaultManager] threadMenuItem] submenu];
	textViewMenu_ = [HTMLVIEW_CLASS defaultMenu];
	UTILAssertNotNil(threadMenu_);
	
	//add "THREAD" menu to end of TextView's menu
	
	menu_ = [[NSMenu alloc] initWithTitle : @""];
	
	iter_ = [[textViewMenu_ itemArray] objectEnumerator];
	while (item_ = [iter_ nextObject]) {
		item_ = [item_ copy];
		[menu_ addItem : item_];
		[item_ release];
	}
	[menu_ addItem:[NSMenuItem separatorItem]];
	iter_ = [[threadMenu_ itemArray] objectEnumerator];
	while (item_ = [iter_ nextObject]) {
		item_ = [item_ copy];
		[menu_ addItem : item_];
		[item_ release];
	}
	
	//menu_ = [threadMenu_ copy];	
	[self clearkeyEquivalentInMenu : menu_];
	return [menu_ autorelease];
}


#pragma mark Override super implementation
+ (Class) toolbarDelegateImpClass
{
	return [CMRThreadViewerTbDelegate class];
}
- (NSString *) statusLineFrameAutosaveName
{
	return APP_TVIEW_STATUSLINE_IDENTIFIER;
}

#pragma mark Title Ruler
+ (BOOL) shouldShowTitleRulerView
{
	return NO;
}

+ (BSTitleRulerModeType) rulerModeForInformDatOchi
{
	return BSTitleRulerShowInfoOnlyMode;
}

- (void) setupTitleRulerWithScrollView: (NSScrollView *) scrollView_
{
	id ruler;

	[[scrollView_ class] setRulerViewClass : [BSTitleRulerView class]];
	ruler = [[BSTitleRulerView alloc] initWithScrollView : scrollView_ orientation : NSHorizontalRuler];
	[[ruler class] setTitleTextColor: ([CMRPref titleRulerViewTextUsesBlackColor] ? [NSColor blackColor] : [NSColor whiteColor])];

	[scrollView_ setHorizontalRulerView : ruler];

	[scrollView_ setHasHorizontalRuler : YES];
	[scrollView_ setRulersVisible : [[self class] shouldShowTitleRulerView]];
}

- (void) cleanUpTitleRuler: (NSTimer *) aTimer
{
	BSTitleRulerView *view_ = (BSTitleRulerView *)[[self scrollView] horizontalRulerView];

	[[self scrollView] setRulersVisible: [[self class] shouldShowTitleRulerView]];
	[view_ setCurrentMode: BSTitleRulerShowTitleOnlyMode];
}

#pragma mark NavigationBar
- (void) layoutNavigationBarComponents
{
	NSRect	idxStepperFrame, scrollViewFrame, idxPopupperFrame, statusBarFrame;
	NSPoint origin_;

	scrollViewFrame = [[self navigationBar] frame];
	idxStepperFrame = [[[self indexingStepper] contentView] frame];
	idxPopupperFrame = [[[self indexingPopupper] contentView] frame];
	statusBarFrame = [[[self statusLine] statusLineView] frame];
	origin_ = scrollViewFrame.origin;

	origin_.x = NSMaxX(scrollViewFrame);
	origin_.x -= NSWidth(idxStepperFrame);
	origin_.x -= 15.0;
	
	idxStepperFrame.origin = origin_;
	idxStepperFrame.origin.y += 1.0;
	[[[self indexingStepper] contentView] setFrame: idxStepperFrame];
	
	origin_.x -= NSWidth(idxPopupperFrame);
	idxPopupperFrame.origin = NSMakePoint(origin_.x, origin_.y);
	[[[self indexingPopupper] contentView] setFrame: idxPopupperFrame];

	// statusLineView の height はあらかじめ navigationBar の height と揃えられていると仮定している
	statusBarFrame.size.width = NSWidth(scrollViewFrame) - 15.0;
	statusBarFrame.origin = scrollViewFrame.origin;
	[[[self statusLine] statusLineView] setFrame: statusBarFrame];
}

- (void) setupNavigationBar
{
	[[self indexingPopupper] setDelegate: self];
	[[self indexingStepper] setDelegate : self];

	[[self navigationBar] addSubview: [[self indexingStepper] contentView]];
	[[self navigationBar] addSubview: [[self indexingPopupper] contentView]];
	
	[[self navigationBar] addSubview: [[self statusLine] statusLineView]];
	
	[self layoutNavigationBarComponents];
}

- (void) statusLineDidShowTheirViews: (CMRStatusLine *) statusLine
{
	if ([self statusLine] != statusLine) {
		NSLog(@"WARNING: statusLineDidShowTheirViews");
		return;
	}
	
	if ([self shouldShowContents]) {
		[[[self indexingStepper] contentView] setHidden: YES];
		[[[self indexingPopupper] contentView] setHidden: YES];
	}
	
	[[self navigationBar] setNeedsDisplayInRect: [[[self statusLine] statusLineView] frame]];
}

- (void) statusLineDidHideTheirViews: (CMRStatusLine *) statusLine
{
	if ([self statusLine] != statusLine || [[self threadLayout] isInProgress]) {
//		NSLog(@"WARNING: statusLineDidHideTheirViews");
		return;
	}
	
	if ([self shouldShowContents]) {
		[[[self indexingStepper] contentView] setHidden: NO];
		[[[self indexingPopupper] contentView] setHidden: NO];
	}
	
	[[self navigationBar] setNeedsDisplayInRect: [[[self statusLine] statusLineView] frame]];
}


#pragma mark Others
- (void) setupScrollView
{
	NSScrollView	*scrollView_ = [self scrollView];
	
	{
		NSNotificationCenter	*center_;
		NSClipView				*contentView_;
		
		contentView_ = [scrollView_ contentView];
		[contentView_ setPostsBoundsChangedNotifications : YES];
		
		center_ = [NSNotificationCenter defaultCenter];
		[center_ addObserver : self
					selector : @selector(contentViewBoundsDidChange:)
						name : NSViewBoundsDidChangeNotification
					  object : contentView_];
	}
	
	[scrollView_ setBorderType : NSNoBorder];//NSBezelBorder];
	[scrollView_ setHasHorizontalScroller : NO];
	[scrollView_ setHasVerticalScroller : YES];

	[self setupTitleRulerWithScrollView: scrollView_];
}

- (void) setupTextView
{
	NSLayoutManager		*layout;
	NSTextContainer		*container;
	NSTextView			*view;
	NSRect				cFrame;
	
	cFrame.origin = NSZeroPoint; 
	cFrame.size = [[self scrollView] contentSize];
	
	/* LayoutManager */
	layout = [[BSLayoutManager alloc] init];
	[[self threadContent] addLayoutManager : layout];
	[layout release];
	
	/* TextContainer */
	container = [[NSTextContainer alloc] initWithContainerSize : NSMakeSize(NSWidth(cFrame), 1e7)];
	[layout addTextContainer : container];
	[container release];
	
	/* TextView */
	view = [[HTMLVIEW_CLASS alloc] initWithFrame : cFrame textContainer : container];

	[view setMinSize : NSMakeSize(0.0, NSHeight(cFrame))];
	[view setMaxSize : NSMakeSize(1e7, 1e7)];
	[view setVerticallyResizable :YES];
	[view setHorizontallyResizable : NO];
	[view setAutoresizingMask : NSViewWidthSizable];
	
	[container setWidthTracksTextView : YES];
	
	[view setEditable : NO];
	[view setSelectable : YES];
	[view setAllowsUndo : NO];
	[view setImportsGraphics : NO];
	[view setFieldEditor : NO];

	[view setMenu : [[self class] loadContextualMenuForTextView]];
	[view setDelegate : self];
	
	[self setTextView : view];

	[self updateLayoutSettings];

	[[self scrollView] setDocumentView : view];
	
	[view release];
}
- (void) updateLayoutSettings
{
	[(BSLayoutManager *)[[self textView] layoutManager] setShouldAntialias: [CMRPref shouldThreadAntialias]];
	[[self textView] setLinkTextAttributes : [[CMRMessageAttributesTemplate sharedTemplate] attributesForAnchor]];
	[self setupTextViewBackground];
}

- (void) setupTextViewBackground
{
	NSColor		*color;
	BOOL		draws;
	
	color = [CMRPref threadViewerBackgroundColor];
	draws = [CMRPref threadViewerDrawsBackground];

	// textView
	[[self textView] setDrawsBackground : draws];
	[[self textView] setBackgroundColor : color];
	// scrollView
	[[self scrollView] setDrawsBackground : draws];
	[[self scrollView] setBackgroundColor : color];
}

- (void) setupKeyLoops
{
	[[self textView] setNextKeyView : [[self indexingStepper] textField]];
	[[[self indexingStepper] textField] setNextKeyView : [self textView]];
	
	[[self window] setInitialFirstResponder : [self textView]];
	[[self window] makeFirstResponder : [self textView]];
}

- (void) setWindowFrameUsingCache
{
	NSRect		frame_;
	
	if (nil == [self threadAttributes]) return;
	frame_ = [[self threadAttributes] windowFrame];
	
	// デフォルト
	if (NSEqualRects(NSZeroRect, frame_)) {
		return;
	}
	[[self window] setFrame : frame_
					display : YES];
}
@end



@implementation CMRThreadViewer (NibOwner)
- (void) setupUIComponents
{
	[super setupUIComponents];
	
	// ロードしたComponentsの配置
	[self setupLoadedComponents];

	[self setupNavigationBar];

	[self setupScrollView];
	[self setupTextView];
	
	[self setupKeyLoops];
	[self updateIndexField];
}
@end
