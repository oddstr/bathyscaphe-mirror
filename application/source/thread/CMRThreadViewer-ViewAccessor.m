/**
  * $Id: CMRThreadViewer-ViewAccessor.m,v 1.21 2007/03/30 17:51:35 tsawada2 Exp $
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
#import "CMRThreadFileLoadingTask.h"
// for debugging only
#define UTIL_DEBUGGING		0
#import "UTILDebugging.h"


#define kComponentsLoadNibName	@"CMRThreadViewerComponents"
#define HTMLVIEW_CLASS			CMRThreadView

static void *kThreadViewThemeBgColorContext = @"BabyRose";
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
	NSView	*popupperView, *stepperView, *statusLineView;
	NSRect	idxStepperFrame, scrollViewFrame, idxPopupperFrame, statusBarFrame;
	NSPoint origin_;

	popupperView = [[self indexingPopupper] contentView];
	stepperView = [[self indexingStepper] contentView];
	statusLineView = [[self statusLine] statusLineView];

	scrollViewFrame = [[self navigationBar] frame];
	idxStepperFrame = [stepperView frame];
	idxPopupperFrame = [popupperView frame];
	statusBarFrame = [statusLineView frame];

	origin_ = scrollViewFrame.origin;

	statusBarFrame.origin = origin_;
	statusBarFrame.size.width = NSWidth(scrollViewFrame) - 15.0;
	[statusLineView setFrame: statusBarFrame];

	idxPopupperFrame.origin = origin_;
	idxPopupperFrame.size.width = statusBarFrame.size.width - NSWidth(idxStepperFrame);
	[popupperView setFrame: idxPopupperFrame];

	origin_.x += NSWidth(idxPopupperFrame);
	origin_.y += 1.0;
	[stepperView setFrameOrigin: origin_];
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
	
//	[[self navigationBar] setNeedsDisplayInRect: [[[self statusLine] statusLineView] frame]];
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
	[view setLinkTextAttributes : [[CMRMessageAttributesTemplate sharedTemplate] attributesForAnchor]];
	[self setupTextViewBackground];
	[CMRPref addObserver: self
			  forKeyPath: @"threadViewTheme.backgroundColor"
				 options: NSKeyValueObservingOptionNew
				 context: kThreadViewThemeBgColorContext];

	[[self scrollView] setDocumentView : view];
	
	[view release];
}

- (void) observeValueForKeyPath: (NSString *) keyPath ofObject: (id) object change: (NSDictionary *) change context: (void *) context
{
	if (context == kThreadViewThemeBgColorContext && object == CMRPref && [keyPath isEqualToString: @"threadViewTheme.backgroundColor"]) {
		NSColor *color = [change objectForKey: NSKeyValueChangeNewKey];
		if (!color) {
			NSLog(@"Warning! -[observeValueForKeyPath:ofObject:change:context:] color is nil.");
			return;
		}

		[[self textView] setBackgroundColor : color];
		[[self scrollView] setBackgroundColor : color];

		{
			id<CMRThreadLayoutTask>		task;
			if ([self synchronize]) {
			task = [[CMRThreadFileLoadingTask alloc] initWithFilepath : [self path]];
			[[self threadLayout] doDeleteAllMessages];
			[[NSNotificationCenter defaultCenter] addObserver: self
													 selector: @selector(threadFileLoadingTaskDidLoadFile:)
														 name: CMRThreadFileLoadingTaskDidLoadAttributesNotification
													   object: task];
			[[NSNotificationCenter defaultCenter] addObserver: self
													 selector: @selector(changeThemeTaskDidFinish:)
														 name: CMRThreadComposingDidFinishNotification
													   object: task];
			[[self threadLayout] push : task];
			[task release];
			}
		}
	}
}

- (void) changeThemeTaskDidFinish: (NSNotification *) aNotification
{
	[self updateIndexField];
	[self setInvalidate : NO];
	[self scrollToLastReadedIndex : self];
	[[self window] invalidateCursorRectsForView : [[[self threadLayout] scrollView] contentView]];
	[[NSNotificationCenter defaultCenter] removeObserver: self
													name: CMRThreadComposingDidFinishNotification
												  object: [aNotification object]];
	[[self textView] performSelector: @selector(setLinkTextAttributes:)
						  withObject: [[CMRMessageAttributesTemplate sharedTemplate] attributesForAnchor]
						  afterDelay: 0.3];
}

- (void) updateLayoutSettings
{
	[(BSLayoutManager *)[[self textView] layoutManager] setShouldAntialias: [CMRPref shouldThreadAntialias]];
//	[[self textView] setLinkTextAttributes : [[CMRMessageAttributesTemplate sharedTemplate] attributesForAnchor]];
//	[self setupTextViewBackground];
}

- (void) setupTextViewBackground
{
	NSColor		*color;
//	BOOL		draws;
	
	color = [CMRPref threadViewerBackgroundColor];
//	draws = [CMRPref threadViewerDrawsBackground];

	// textView
	[[self textView] setDrawsBackground : YES];//draws];
	[[self textView] setBackgroundColor : color];
	// scrollView
	[[self scrollView] setDrawsBackground : YES];//draws];
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
