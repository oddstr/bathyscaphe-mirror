//
//  CMRThreadViewer-ViewAccessor.m
//  BathyScaphe
//
//  Updated by Tsutomu Sawada on 07/08/12.
//  Copyright 2005-2008 BathyScaphe Project. All rights reserved.
//  encoding="UTF-8"
//

#import "CMRThreadViewer_p.h"
#import "CMRThreadVisibleRange.h"

#import "CMRThreadView.h"
#import "CMRMainMenuManager.h"
#import "CMRMessageAttributesTemplate.h"
#import <SGAppKit/BSLayoutManager.h>
#import <SGAppKit/BSTitleRulerAppearance.h>
#import "CMRThreadFileLoadingTask.h"
#import "BSNavigationStatusLine.h"

// for debugging only
#define UTIL_DEBUGGING		0
#import "UTILDebugging.h"

@class CMRThreadViewerTbDelegate;

#define kComponentsLoadNibName	@"CMRThreadViewerComponents"
#define HTMLVIEW_CLASS			CMRThreadView

@implementation CMRThreadViewer(ViewAccessor)
- (NSScrollView *)scrollView
{
	return m_scrollView;
}

- (NSTextView *)textView
{
	return m_textView;
}

- (void)setTextView:(NSTextView *)aTextView
{
	m_textView = aTextView;
}

- (BSIndexingPopupper *)indexingPopupper
{
	return [(BSNavigationStatusLine *)[self statusLine] indexingPopupper];
}

- (CMRIndexingStepper *)indexingStepper
{
	return [(BSNavigationStatusLine *)[self statusLine] indexingStepper];
}

- (NSView *)navigationBar
{
	return m_navigationBar;
}
@end


@implementation CMRThreadViewer(UIComponents)
- (BOOL)loadComponents
{
	return [NSBundle loadNibNamed:kComponentsLoadNibName owner:self];
}

- (NSView *)containerView
{
	return m_containerView;
}

- (void)setupLoadedComponents
{
	NSString	*fs = [CMRPref windowDefaultFrameString];
	NSView		*containerView_;
	NSView		*contentView_ = [[self window] contentView];
	NSRect		vframe_;
	
	containerView_ = [self containerView];
	vframe_ = [m_windowContentView frame];
	
	[containerView_ retain];
	[containerView_ removeFromSuperviewWithoutNeedingDisplay];
	[containerView_ setFrame:vframe_];
	
	[contentView_ setAutoresizingMask:(NSViewWidthSizable|NSViewHeightSizable)];
	[contentView_ setAutoresizesSubviews:YES];
	
	// ダミーのNSViewと入れ替える
	[m_windowContentView retain];
	[contentView_ replaceSubview:m_windowContentView with:containerView_];
	[m_windowContentView release];
	m_windowContentView = nil;

	[containerView_ release];
	
	// 以前に保存しておいたウインドウの領域を
	// デフォルトのものとして使用する
	if (fs) [[self window] setFrameFromString:fs];
}
@end


@implementation CMRThreadViewer(ViewInitializer)
#pragma mark Contextual Menu Stuff
+ (NSMenu *)loadContextualMenuForTextView
{
	NSMenu	*menu_;

	NSMenu	*textViewMenu_;
	NSEnumerator *iter_;
	NSMenuItem	*item_;

	menu_ = [[CMRMainMenuManager defaultManager] threadContexualMenuTemplate];
	textViewMenu_ = [HTMLVIEW_CLASS messageMenu];

	[menu_ addItem:[NSMenuItem separatorItem]];

	iter_ = [[textViewMenu_ itemArray] objectEnumerator];
	while (item_ = [iter_ nextObject]) {
		item_ = [item_ copy];
		[menu_ addItem:item_];
		[item_ release];
	}
	
	return menu_;
}

#pragma mark Override super implementation
+ (Class)toolbarDelegateImpClass
{
	return [CMRThreadViewerTbDelegate class];
}

/*- (NSString *)statusLineFrameAutosaveName
{
	return APP_TVIEW_STATUSLINE_IDENTIFIER;
}*/

+ (Class) statusLineClass
{
	return [BSNavigationStatusLine class];
}

#pragma mark Title Ruler
+ (BOOL)shouldShowTitleRulerView
{
	return NO;
}

+ (BSTitleRulerModeType)rulerModeForInformDatOchi
{
	return BSTitleRulerShowInfoOnlyMode;
}

+ (NSString *)titleRulerAppearanceFilePath
{
	NSString *path;
	NSBundle *appSupport = [NSBundle applicationSpecificBundle];

	path = [appSupport pathForResource:@"BSTitleRulerAppearance" ofType:@"plist"];
	if (!path) {
		path = [[NSBundle mainBundle] pathForResource:@"BSTitleRulerAppearance" ofType:@"plist"];
	}
	return path;
}

- (void)setupTitleRulerWithScrollView:(NSScrollView *)scrollView_
{
	id ruler;
	NSString *path = [[self class] titleRulerAppearanceFilePath];
	UTILAssertNotNil(path);
	BSTitleRulerAppearance *foo = [NSKeyedUnarchiver unarchiveObjectWithFile:path];

	[[scrollView_ class] setRulerViewClass:[BSTitleRulerView class]];
	ruler = [[BSTitleRulerView alloc] initWithScrollView:scrollView_ appearance:foo];
	[ruler setTitleStr:NSLocalizedString(@"titleRuler default title", @"Startup Message")];

	[scrollView_ setHorizontalRulerView:ruler];

	[scrollView_ setHasHorizontalRuler:YES];
	[scrollView_ setRulersVisible:[[self class] shouldShowTitleRulerView]];
}

- (void)cleanUpTitleRuler:(NSTimer *)aTimer
{
	BSTitleRulerView *view_ = (BSTitleRulerView *)[[self scrollView] horizontalRulerView];

	[[self scrollView] setRulersVisible:[[self class] shouldShowTitleRulerView]];
	[view_ setCurrentMode:BSTitleRulerShowTitleOnlyMode];
}

#pragma mark NavigationBar
- (void)setupNavigationBar
{
	NSView *superView = [[self navigationBar] superview];
	NSRect curFrame = [[self navigationBar] frame];

	[[self indexingPopupper] setDelegate:self];
	[[self indexingStepper] setDelegate:self];

	[m_navigationBar retain];
	[superView replaceSubview:[self navigationBar] with:[[self statusLine] statusLineView]];
	[m_navigationBar release];
	m_navigationBar = [[self statusLine] statusLineView];
	[[self navigationBar] setFrame:curFrame];
	[[self statusLine] statusLineViewDidMoveToWindow];
}

#pragma mark Others
- (void)setupScrollView
{
	NSScrollView	*scrollView_ = [self scrollView];
	NSClipView		*contentView_;
		
	contentView_ = [scrollView_ contentView];
	[contentView_ setPostsBoundsChangedNotifications:YES];
		
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(contentViewBoundsDidChange:)
												 name:NSViewBoundsDidChangeNotification
											   object:contentView_];
	
	[scrollView_ setBorderType:NSNoBorder];
	[scrollView_ setHasHorizontalScroller:NO];
	[scrollView_ setHasVerticalScroller:YES];

	[self setupTitleRulerWithScrollView:scrollView_];
}

- (void)setupTextView
{
	NSLayoutManager		*layout;
	NSTextContainer		*container;
	NSTextView			*view;
	NSRect				cFrame;
	
	cFrame.origin = NSZeroPoint; 
	cFrame.size = [[self scrollView] contentSize];
	
	/* LayoutManager */
	layout = [[BSLayoutManager alloc] init];
	// Leopard Test...
//	[layout setAllowsNonContiguousLayout:YES];
	[[(CMRThreadDocument *)[self document] textStorage] addLayoutManager:layout];
	[layout release];
	
	/* TextContainer */
	container = [[NSTextContainer alloc] initWithContainerSize:NSMakeSize(NSWidth(cFrame), 1e7)];
	[layout addTextContainer:container];
	[container release];
	
	/* TextView */
	view = [[HTMLVIEW_CLASS alloc] initWithFrame:cFrame textContainer:container];

	[view setMinSize : NSMakeSize(0.0, NSHeight(cFrame))];
	[view setMaxSize : NSMakeSize(1e7, 1e7)];
	[view setVerticallyResizable:YES];
	[view setHorizontallyResizable:NO];
	[view setAutoresizingMask:NSViewWidthSizable];

	[container setWidthTracksTextView:YES];
	
	[view setEditable:NO];
	[view setSelectable:YES];
	[view setAllowsUndo:NO];
	[view setImportsGraphics:NO];
	[view setFieldEditor:NO];

	[view setMenu:[[self class] loadContextualMenuForTextView]];
	[view setDelegate:self];

	if ([view respondsToSelector:@selector(setDisplaysLinkToolTips:)]) {
		// Leopard
		[view setDisplaysLinkToolTips:NO];
	}

	[self setTextView:view];

	[self setupTextViewBackground];
	[self updateLayoutSettings];

	[[self scrollView] setDocumentView:view];

	[view release];
}

- (void)threadViewThemeDidChange:(NSNotification *)notification
{
	[self setupTextViewBackground];

	if ([self synchronize]) {
		[self setChangeThemeTaskIsInProgress:YES];
		[self loadFromContentsOfFile:[self path]];
		// linkTextAttributes は -loadFromContentsOfFile: の後、-threadComposingDidFinished: の中で -updateLayoutSettings を
		// 遅延実行して更新する。
	}
}

- (void)updateLayoutSettings
{
	[(BSLayoutManager *)[[self textView] layoutManager] setShouldAntialias:[CMRPref shouldThreadAntialias]];
	[[self textView] setLinkTextAttributes:[[CMRMessageAttributesTemplate sharedTemplate] attributesForAnchor]];
}

- (void)setupTextViewBackground
{
	NSColor		*color = [[CMRPref threadViewTheme] backgroundColor];

	// textView
	[[self textView] setDrawsBackground:YES];
	[[self textView] setBackgroundColor:color];
	// scrollView
	[[self scrollView] setDrawsBackground:YES];
	[[self scrollView] setBackgroundColor:color];
}

- (void)setupKeyLoops
{
	[[self textView] setNextKeyView:[[self indexingStepper] textField]];
	[[[self indexingStepper] textField] setNextKeyView:[self textView]];
	
	[[self window] setInitialFirstResponder:[self textView]];
	[[self window] makeFirstResponder:[self textView]];
}

- (void)setWindowFrameUsingCache
{
	NSRect		frame_;
	
	if (![self threadAttributes]) return;
	frame_ = [[self threadAttributes] windowFrame];
	
	// デフォルト
	if (NSEqualRects(NSZeroRect, frame_)) {
		return;
	}
	if (NSEqualRects(frame_, [[self window] frame])) {
		return;
	}
	[[self window] setFrame:frame_ display:YES];
	[self synchronizeWindowTitleWithDocumentName];
}
@end


@implementation CMRThreadViewer(NibOwner)
- (void)setupUIComponents
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
