/**
  * $Id: CMRThreadViewer-ViewAccessor.m,v 1.10 2006/06/24 16:23:38 tsawada2 Exp $
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


#define kComponentsLoadNibName	@"CMRThreadViewerComponents"
#define HTMLVIEW_CLASS			CMRThreadView


@implementation CMRThreadViewer(ViewAccessor)
//- (CMXScrollView *) scrollView
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
	
	// �_�~�[��NSView�Ɠ���ւ���
	[m_windowContentView retain];
	[[[self window] contentView] replaceSubview : m_windowContentView
										   with : containerView_];
	[m_windowContentView release];
	m_windowContentView = nil;
	[m_windowContentView addSubview : containerView_];
	
	[containerView_ release];
	
	// �ȑO�ɕۑ����Ă������E�C���h�E�̗̈��
	// �f�t�H���g�̂��̂Ƃ��Ďg�p����
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


/*- (void) setupStatusLine
{
	[super setupStatusLine];
}*/
#pragma mark Others
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
	//CMXScrollView	*scrollView_ = [self scrollView];
	NSScrollView	*scrollView_ = [self scrollView];
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
	[scrollView_ setHasHorizontalScroller : NO];//YES];
	[scrollView_ setHasVerticalScroller : YES];

	// Accessory View
	[[self indexingPopupper] setDelegate: self];
	[[self indexingStepper] setDelegate : self];
	/*
	[scrollView_ addAccessoryView: [[self indexingPopupper] contentView]
						alignment: CMXScrollViewHorizontalRight];
	[scrollView_ addAccessoryView : [[self indexingStepper] contentView] 
						alignment : CMXScrollViewHorizontalRight];
	*/
	[[self navigationBar] addSubview: [[self indexingStepper] contentView]];
	[[self navigationBar] addSubview: [[self indexingPopupper] contentView]];
	//[[[self indexingPopupper] contentView] setFrameOrigin: NSMakePoint(10,0)];
	//[[self navigationBar] addSubview: [[self statusLine] statusTextField]];
	{
		NSRect	idxStepperFrame, scrollViewFrame, idxPopupperFrame;
		NSPoint origin_;
		idxStepperFrame = [[[self indexingStepper] contentView] frame];
		scrollViewFrame = [[self navigationBar] frame];

		origin_ = scrollViewFrame.origin;
		origin_.x = NSMaxX(scrollViewFrame);
		
		origin_.x -= NSWidth(idxStepperFrame);
		origin_.x -= 15.0;
		
		idxStepperFrame.origin = origin_;
		[[[self indexingStepper] contentView] setFrame: idxStepperFrame];
		
		idxPopupperFrame = [[[self indexingPopupper] contentView] frame];
		
		origin_.x -= NSWidth(idxPopupperFrame);
		
		idxPopupperFrame.origin = NSMakePoint(origin_.x, origin_.y-1);
		[[[self indexingPopupper] contentView] setFrame: idxPopupperFrame];
		
		//[[[self statusLine] statusTextField] setFrame: NSInsetRect(scrollViewFrame, 4.0, 2.0)];
	}
	// Title Ruler
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
	// �����N������̏����́ANSTextView �������I�ɕt���Ă����B���̑��������������ŃZ�b�g���Ă����B
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
	// �w�i����
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
	
	// �f�t�H���g
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
	
	// ���[�h����Components�̔z�u
	[self setupLoadedComponents];
	[[self window] setPreservesContentDuringLiveResize: NO];
	[self setupScrollView];
	[self setupTextView];
	
	[self setupKeyLoops];
	[self updateIndexField];
}
@end
