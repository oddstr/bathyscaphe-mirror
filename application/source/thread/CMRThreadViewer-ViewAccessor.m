/**
  * $Id: CMRThreadViewer-ViewAccessor.m,v 1.6.2.1 2006/06/08 00:04:49 tsawada2 Exp $
  * 
  * CMRThreadViewer-ViewAccessor.m
  *
  * Copyright (c) 2003, Takanori Ishikawa.
  * See the file LICENSE for copying permission.
  */

#import "CMRThreadViewer_p.h"
#import "CMRThreadVisibleRange.h"
#import "CMRThreadViewerTbDelegate.h"
#import "CMRLayoutManager.h"
#import "CMRThreadView.h"
#import "CMRMainMenuManager.h"
#import "CMRMessageAttributesTemplate.h"

// for debugging only
#define UTIL_DEBUGGING		0
#import "UTILDebugging.h"



//////////////////////////////////////////////////////////////////////
////////////////////// [ 定数やマクロ置換 ] //////////////////////////
//////////////////////////////////////////////////////////////////////
#define kFirstVisibleNumbersPlist	@"firstVisibleNumbers.plist"
#define kLastVisibleNumbersPlist	@"lastVisibleNumbers.plist"

#define kComponentsLoadNibName	@"CMRThreadViewerComponents"
#define HTMLVIEW_CLASS			CMRThreadView



@implementation CMRThreadViewer(ViewAccessor)
- (CMXScrollView *) scrollView
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
- (NSPopUpButton *) firstVisibleRangePopUpButton
{
	return m_firstVisibleRangePopUpButton;
}
- (NSPopUpButton *) lastVisibleRangePopUpButton
{
	return m_lastVisibleRangePopUpButton;
}
- (CMRIndexingStepper *) indexingStepper
{
	if (nil == m_indexingStepper)
		m_indexingStepper = [[CMRIndexingStepper alloc] init];
	return m_indexingStepper;
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
	[m_windowContentView addSubview : containerView_];
	
	[containerView_ release];
	
	// 以前に保存しておいたウインドウの領域を
	// デフォルトのものとして使用する
	if (fs != nil) [[self window] setFrameFromString : fs];
}
@end



@implementation CMRThreadViewer(VisibleNumbersPopUpSetup)
+ (NSString *) visibleNumbersFilepathWithName : (NSString *) filename
{
	NSBundle	*bundles[] = {
			[NSBundle applicationSpecificBundle],
			[NSBundle mainBundle],
			nil};
	NSBundle	**p;
	NSString	*s = nil;
	
	for (p = bundles; *p != nil; p++)
		if ((s = [*p pathForResourceWithName : filename]) != nil)
			break;
	
	return s;
}

+ (NSArray *) visibleNumbersArrayWithName : (NSString *) filename
{
	NSMutableArray		*values;
	int					i;
	
	values = [NSMutableArray arrayWithContentsOfFile : 
				[self visibleNumbersFilepathWithName : filename]];
	if (nil == values) values = [NSMutableArray array];
	
	for (i = [values count] -1; i >= 0; i--) {
		id		v = [values objectAtIndex : i];
		
		if (NO == [v isKindOfClass : [NSNumber class]]) {
			[values removeObjectAtIndex : i];
			continue;
		}
		
		if ([v intValue] < 0) {
			[values replaceObjectAtIndex : i
			  withObject : [NSNumber numberWithUnsignedInt : CMRThreadShowAll]];
		}
	}
	return values;
}
+ (NSArray *) firstVisibleNumbersArray
{
	return [self visibleNumbersArrayWithName : kFirstVisibleNumbersPlist];
}
+ (NSArray *) lastVisibleNumbersArray
{
	return [self visibleNumbersArrayWithName : kLastVisibleNumbersPlist];
}

- (NSString *) localizedVisibleStringWithFormat : (NSString *) format
								  visibleLength : (unsigned  ) visibleLength
{
	if (0 == visibleLength)
		return [self localizedString : APP_TVIEW_SHOW_NONE_LABEL_KEY];
	if (CMRThreadShowAll == visibleLength)
		return [self localizedString : APP_TVIEW_SHOW_ALL_LABEL_KEY];
	
	return [NSString stringWithFormat : 
							format,
							visibleLength];
}
- (NSString *) localizedFirstVisibleStringWithNumber : (NSNumber *) visibleNumber
{
	NSString			*format_;
	
	if (nil == visibleNumber) return nil;
	
	format_ = [self localizedString : APP_TVIEW_FIRST_VISIBLE_LABEL_KEY];
	return [self localizedVisibleStringWithFormat : format_
						visibleLength : [visibleNumber unsignedIntValue]];
}
- (NSString *) localizedLastVisibleStringWithNumber : (NSNumber *) visibleNumber
{
	NSString			*format_;
	
	if (nil == visibleNumber) return nil;
	
	format_ = [self localizedString : APP_TVIEW_LAST_VISIBLE_LABEL_KEY];
	return [self localizedVisibleStringWithFormat : format_
						visibleLength : [visibleNumber unsignedIntValue]];
}

- (void) setupVisibleRangePopUpButtonCell : (NSPopUpButtonCell *) aCell
{
	[aCell setControlSize : NSSmallControlSize];
	[aCell setArrowPosition : NSPopUpArrowAtBottom];
	[aCell setPullsDown : NO];
}
- (void) setupVisibleRangePopUpButton : (NSPopUpButton *) popUpBtn
{
	[popUpBtn setFont : 
		[NSFont systemFontOfSize : 
			[NSFont smallSystemFontSize]]];
	[popUpBtn setBezelStyle : NSShadowlessSquareBezelStyle];
	[popUpBtn setBordered : YES];

	[popUpBtn setTarget : nil];
	[popUpBtn setAction : NULL];
	
	
	[self setupVisibleRangePopUpButtonCell : [popUpBtn cell]];
}

- (NSMenuItem *) addItemWithVisibleRangePopUpButton : (NSPopUpButton *) popUpBtn
                           isFirstVisibles : (BOOL           ) isFirst
                          representedIndex : (NSNumber      *) aNum
{
    NSString   *title;
    NSMenuItem *item;
    
    if (isFirst)
      title = [self localizedFirstVisibleStringWithNumber : aNum];
    else
      title = [self localizedLastVisibleStringWithNumber : aNum];
    
    [popUpBtn addItemWithTitle : title];
    
    item = (NSMenuItem *)[popUpBtn lastItem];
    [item setRepresentedObject : aNum];
    [item setTarget : self];
    [item setAction : isFirst 	? 
        @selector(selectFirstVisibleRange:)
        : @selector(selectLastVisibleRange:)];
    return item;
}
- (void) setupVisibleRangePopUpButtonAttributes : (NSPopUpButton *) popUpBtn
								isFirstVisibles : (BOOL           ) isFirst
{
	NSArray			*visibleNumbers_;
	NSEnumerator	*iter_;
	NSNumber		*number_;
	
	[popUpBtn removeAllItems];
	visibleNumbers_ = isFirst 	? [[self class] firstVisibleNumbersArray]
								: [[self class] lastVisibleNumbersArray];
	iter_ = [visibleNumbers_ objectEnumerator];
	while (number_ = [iter_ nextObject]) {
        [self addItemWithVisibleRangePopUpButton : popUpBtn
            isFirstVisibles : isFirst
            representedIndex : number_];
    }
}
- (void) setupVisibleRangePopUp
{
	[self setupVisibleRangePopUpButton : [self firstVisibleRangePopUpButton]];
	[self setupVisibleRangePopUpButton : [self lastVisibleRangePopUpButton]];
	[self setupVisibleRangePopUpButtonAttributes : [self firstVisibleRangePopUpButton]
								 isFirstVisibles : YES];
	[self setupVisibleRangePopUpButtonAttributes : [self lastVisibleRangePopUpButton]
								 isFirstVisibles : NO];
}
@end



@implementation CMRThreadViewer(ViewInitializer)
// ----------------------------------------
// Contextual Menu Stuff
// ----------------------------------------
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



// Override super implementation
+ (Class) toolbarDelegateImpClass
{
	return [CMRThreadViewerTbDelegate class];
}
- (NSString *) statusLineFrameAutosaveName
{
	return APP_TVIEW_STATUSLINE_IDENTIFIER;
}


/*- (void) setupStatusLine
{
	[super setupStatusLine];
}*/

+ (BOOL) shouldShowTitleRulerView
{
	return NO;
}

+ (BSTitleRulerModeType) rulerModeForInformDatOchi
{
	return BSTitleRulerShowInfoOnlyMode;
}

- (void) setupScrollView
{
	CMXScrollView	*scrollView_ = [self scrollView];
	id ruler;
	
	{
		NSNotificationCenter	*center_;
		NSClipView				*contentView_;
		
		contentView_ = [scrollView_ contentView];
		[contentView_ setPostsBoundsChangedNotifications : YES];
		
		center_ = [NSNotificationCenter defaultCenter];
		[center_ addObserver : self
					selector : @selector(contentViewBoudnsDidChange:)
						name : NSViewBoundsDidChangeNotification
					  object : contentView_];
	}
	
	[scrollView_ setBorderType : NSBezelBorder];
	[scrollView_ setHasHorizontalScroller : YES];
	[scrollView_ setHasVerticalScroller : YES];

	// Accessory View
	[self setupVisibleRangePopUp];
	[[self indexingStepper] setDelegate : self];
	
	[scrollView_ addAccessoryView : [self firstVisibleRangePopUpButton]
						alignment : CMXScrollViewHorizontalRight];
	[scrollView_ addAccessoryView : [self lastVisibleRangePopUpButton]
						alignment : CMXScrollViewHorizontalRight];
	[scrollView_ addAccessoryView : [[self indexingStepper] contentView] 
						alignment : CMXScrollViewHorizontalRight];

	// Title Ruler
	[[scrollView_ class] setRulerViewClass : [BSTitleRulerView class]];
	ruler = [[BSTitleRulerView alloc] initWithScrollView : scrollView_ orientation : NSHorizontalRuler];

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

- (void) setupTextView
{
	NSLayoutManager	*layout;
	NSTextContainer	*container;
	NSTextView		*view;
	NSRect			cFrame;
	
	cFrame.origin = NSZeroPoint; 
	cFrame.size = [[self scrollView] contentSize];
	
	/* LayoutManager */
	layout = [[CMRLayoutManager alloc] init];
	[[self threadContent] addLayoutManager : layout];
	[layout release];
	
	/* TextContainer */
	container = [[NSTextContainer alloc] initWithContainerSize : 
					NSMakeSize(NSWidth(cFrame), 1e7)];
	[layout addTextContainer : container];
	[container release];
	
	/* TextView */
	view = [[HTMLVIEW_CLASS alloc] initWithFrame : cFrame 
								textContainer : container];
	
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

	// 2005-09-08 tsawada2 <ben-sawa@td5.so-net.ne.jp>
	// リンク文字列の書式は、NSTextView が自動的に付けてくれる。その属性辞書をここでセットしておく。
	[view setLinkTextAttributes : [[CMRMessageAttributesTemplate sharedTemplate] attributesForAnchor]];
	
	[view setFont : [CMRPref threadsViewFont]];
	[view setMenu : [[self class] loadContextualMenuForTextView]];
	[view setDelegate : self];
	
	[self setTextView : view];
	[self setupTextViewBackground];
	[[self scrollView] setDocumentView : view];
	
	[view release];
}
- (void) updateLayoutSettings
{
/*
	2004-03-06 Takanori Ishikawa <takanori@gd5.so-net.ne.jp>
	----------------------------------------
	Since [NSTextView setFont:] causes textStorage's font changing,
	I moved this code to.
*/
#if 0
	[[self textView] setFont : [CMRPref threadsViewFont]];
#endif
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
	// 背景透過
	//[[self window] setOpaque : NO];

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

	[self setupScrollView];
	[self setupTextView];
	
	[self setupKeyLoops];
	[self updateIndexField];
}
@end