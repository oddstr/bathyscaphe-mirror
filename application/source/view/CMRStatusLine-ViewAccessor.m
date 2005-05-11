//: CMRStatusLine-ViewAccessor.m
/**
  * $Id: CMRStatusLine-ViewAccessor.m,v 1.1.1.1 2005/05/11 17:51:08 tsawada2 Exp $
  * 
  * Copyright (c) 2001-2003, Takanori Ishikawa.  All rights reserved.
  * See the file LICENSE for copying permission.
  */

#import "CMRStatusLine_p.h"
//#import "CMRBookmarksButtonCell.h"


// progress
#define kProgressIndicatorDropShadowWidth    2
#define kStatusLineSubviewInset              NSMakeSize(6.0f, 5.0f)
#define kPbComponentsInsetWidth              4.0f

// toolbar
#define kForwardBackButtonInsetWidth 3
//#define kBookmarksButtonInsetWidth   3
#define kInfoTextFiledInsetWidth     1
#define kHistoryPopUpSpaceWidth      0


// <Not selected> menuItem
#define kNoSelectionItemTag        24
#define kNotSelectionLabelKey    @"No Selected Item"

static NSMenuItem *createNoSelectionMenuItem(void)
{
    NSString    *title_;
    NSMenuItem    *menuItem_;
    
    title_ = NSLocalizedString(kNotSelectionLabelKey, nil);
    menuItem_ = [[NSMenuItem alloc] initWithTitle : title_
                                             action : NULL
                                      keyEquivalent : @""];
    [menuItem_ setRepresentedObject : nil];
    [menuItem_ setTag : kNoSelectionItemTag];
    
    return menuItem_;
}

@implementation CMRStatusLine(View)
- (NSView *) statusLineView
{
    return _statusLineView;
}
- (NSView *) indicatorView
{
    return _indicatorView;
}
- (NSTextField *) statusTextField
{
    return _statusTextField;
}
- (NSProgressIndicator *) progressIndicator
{
    return _progressIndicator;
}
- (NSButton *) stopButton
{
    return _stopButton;
}

// 履歴
- (NSView *) toolbarView
{
    return _toolbarView;
}
//- (NSButton *) bookmarksButton
//{
//    return _bookmarksButton;
//}
- (NSPopUpButton *) boardHistoryPopUp
{
    return _boardHistoryPopUp;
}
- (NSPopUpButton *) threadHistoryPopUp
{
    return _threadHistoryPopUp;
}
- (NSMatrix *) forwardBackMatrix
{
    return _forwardBackMatrix;
}
- (NSMatrix *) toolbarItemMatrix
{
    return _toolbarItemMatrix;
}
- (NSButtonCell *) forwardButtonCell
{
    return [[self forwardBackMatrix] cellWithTag : 1];
}
- (NSButtonCell *) backButtonCell
{
    return [[self forwardBackMatrix] cellWithTag : 0];
}
- (NSTextField *) infoTextField
{
    return _infoTextField;
}


struct IndicatorBarDefaults {
    NSSize            size;
    NSControlSize    controlSize;
};

// NSProgressIndicator(Bar Style)デフォルトの幅 
static struct IndicatorBarDefaults kIndicatorBarDefaults;



- (void) setupProgressIndicatorStyle
{
#if MAC_OS_X_VERSION_MAX_ALLOWED >= MAC_OS_X_VERSION_10_2
    
    BOOL                        usesSpinningStyle_;
    
    if (NO == [CMRPref canUseSpinningStyle])
        return;

    usesSpinningStyle_ = [CMRPref statusLineUsesSpinningStyle];
    
    // 停止ボタン
    if (usesSpinningStyle_)
        [[self stopButton] removeFromSuperviewWithoutNeedingDisplay];
    else
        [[self indicatorView] addSubview : [self stopButton]];
    
    [[self progressIndicator] setStyle : usesSpinningStyle_
                ? NSProgressIndicatorSpinningStyle
                : NSProgressIndicatorBarStyle];
    
#endif

}
- (void) setupProgressViewFrame
{
    NSRect                    progFrame_;
    NSRect                    viewFrame_;
    NSRect                    statusFieldFrame_;
    float                    maxX_;
    float                    originY_;
    NSProgressIndicator        *indicator_ = [self progressIndicator];
    
    
    progFrame_ = [indicator_ frame];
    viewFrame_ = [[self indicatorView] frame];
    statusFieldFrame_ = [[self statusTextField] frame];
    
    
    // Progress Indicator: 幅
    if ([CMRPref statusLineUsesSpinningStyle]) {
        if ([indicator_ respondsToSelector : @selector(sizeToFit)]) {
            // maybe Spining Style
            [indicator_ sizeToFit];
            progFrame_ = [indicator_ frame];
        } else {
            NSLog(@"can't select spining style indicator. not support");
        }
    } else {
        // maybe Default(Bar) Style
        progFrame_.size = kIndicatorBarDefaults.size;
        [indicator_ setControlSize : kIndicatorBarDefaults.controlSize];
    }
    
    // Progress Indicator: 位置
    originY_  = NSHeight(viewFrame_);                // view
    originY_ -= NSHeight(progFrame_);                // progress indicator
    originY_ /= 2;
    
    maxX_ = NSWidth(viewFrame_);
    maxX_ -= kPbComponentsInsetWidth;
    
    progFrame_.origin.x = (maxX_ - NSWidth(progFrame_));
    progFrame_.origin.y = originY_ +1;
    
    // 停止ボタン
    if (NO == [CMRPref statusLineUsesSpinningStyle]) {
        NSRect        btnFrame_ = [[self stopButton] frame];
        
        btnFrame_.origin.x = maxX_ - NSWidth(btnFrame_);
        
        progFrame_.origin.x -= (NSWidth(btnFrame_) + kPbComponentsInsetWidth);
        
        [[self stopButton] setFrame : btnFrame_];
        
    }
    
    // textField: 幅
    statusFieldFrame_.size.width = progFrame_.origin.x - (kPbComponentsInsetWidth * 2);
    
    [indicator_ setFrame : progFrame_];
    [[self statusTextField] setFrame : statusFieldFrame_];
}

- (void) setupProgressIndicator
{
    static BOOL isFirst = YES;
    
    // Progress Indicator (Bar Style) のプロパティを記憶
    if (isFirst) {
        isFirst = NO;
        kIndicatorBarDefaults.size = [[self progressIndicator] frame].size;
        kIndicatorBarDefaults.controlSize = [[self progressIndicator] controlSize];
    }
    
    [self setupProgressIndicatorStyle];
    [self setupProgressViewFrame];
}

static float popUpButtonTitleSpaceWidthDirty(NSPopUpButton *aPopUp)
{
    NSString    *title_;
    float        width_;
    NSRect        bounds_ = NSMakeRect(0, 0, 500, 22);
    
    title_ = [[aPopUp selectedItem] title];
    [[aPopUp selectedItem] setTitle : @"A"];
    
    width_ = NSWidth([[aPopUp cell] drawingRectForBounds : bounds_]);
    width_ = width_ - NSWidth([[aPopUp cell] titleRectForBounds : bounds_]);
    
    [[aPopUp selectedItem] setTitle : title_];
    
    return width_;
}
- (float) displayWidthOfPopUpButton : (NSPopUpButton *) aPopUp
{
    static float spaceWidth_ = 0;
    
    if (0 == spaceWidth_)
        spaceWidth_ = popUpButtonTitleSpaceWidthDirty(aPopUp);
    
    return [[aPopUp cell] cellSize].width - spaceWidth_;
}

- (void) synchronizeSizeAndSelectedItemOfPopUpButton : (NSPopUpButton *) aPopUp
{
    NSRect            frameRect_;
    
    frameRect_ = [aPopUp frame];
    frameRect_.size.width = [self displayWidthOfPopUpButton : aPopUp];
    [aPopUp setFrameSize : frameRect_.size];
}


- (BOOL) isToolbarRightAlignment
{
    return ([self toolbarAlignment] != CMRStatusLineToolbarLeftAlignment);
}
- (void) setInfoTextFieldObjectValue : (id) anObject
{
    id        v = anObject;
    id        tmp;
    id        paraStyle_;
    int        alignment_;
    
    if (nil == v || NO == [v isKindOfClass : [NSAttributedString class]]) {
        [[self infoTextField] setObjectValue : nil == v ? @"" : v];
        return;
    }
    
    
    // 右寄せのツールバーではテキストの配置を変更
    alignment_ = [self isToolbarRightAlignment]
                        ? NSLeftTextAlignment
                        : NSRightTextAlignment;
    
    tmp = [v rulerAttributesInRange : [v range]];
    paraStyle_ = [tmp objectForKey : NSParagraphStyleAttributeName];
    if (nil == paraStyle_)
        paraStyle_ = [NSParagraphStyle defaultParagraphStyle];
    
    if ([paraStyle_ alignment] != alignment_) {
        paraStyle_ = [[paraStyle_ mutableCopy] autorelease];
        [paraStyle_ setAlignment : alignment_];
        
        tmp = SGTemporaryAttributedString();
        [tmp setAttributedString : v];
        [tmp addAttribute : NSParagraphStyleAttributeName
                    value : paraStyle_
                    range : [tmp range]];
        v = tmp;
    }
    
    [[self infoTextField] setAttributedStringValue : v];
}

- (void) layoutToolbarForwardBackMatrix : (BOOL) rightAlign
{
    NSView        *view_;
    NSPoint        origin_;
    
    view_ = [self forwardBackMatrix];
    origin_ = [view_ frame].origin;
    origin_.x = (NO == rightAlign)
                ? kForwardBackButtonInsetWidth
                : NSWidth([[view_ superview] frame]) - NSWidth([view_ frame]) - kForwardBackButtonInsetWidth;
    [view_ setFrameOrigin : origin_];
}
- (void) layoutToolbarHistoryPopUp : (BOOL) rightAlign
{
    NSPoint        origin_;
    float        diff_;
    NSView        *view_;
    
    // まず、ポップアップ同士を合わせる
    origin_ = [[self threadHistoryPopUp] frame].origin;
    origin_.x = NSMaxX([[self boardHistoryPopUp] frame]);
    origin_.x += kHistoryPopUpSpaceWidth;
    [[self threadHistoryPopUp] setFrameOrigin : origin_];
    
    // 次に片側のポップアップを端に寄せ、その差分でもう片方も移動
    view_ = (NO == rightAlign) ? [self boardHistoryPopUp] : [self threadHistoryPopUp];
    origin_ = [view_ frame].origin;
    if (NO == rightAlign) {
        origin_ = [view_ frame].origin;
        origin_.x = NSMaxX([[self forwardBackMatrix] frame]);
        origin_.x += kHistoryPopUpSpaceWidth;
    } else {
        origin_.x = NSMinX([[self forwardBackMatrix] frame]);
        origin_.x -= NSWidth([view_ frame]);
        origin_.x -= kHistoryPopUpSpaceWidth;
    }
    diff_ = origin_.x - NSMinX([view_ frame]);
    [view_ setFrameOrigin : origin_];
    
    view_ = rightAlign ? [self boardHistoryPopUp] : [self threadHistoryPopUp];
    origin_ = [view_ frame].origin;
    origin_.x += diff_;
    [view_ setFrameOrigin : origin_];
    
}

- (void) layoutToolbarInfoTextField : (BOOL) rightAlign
{
    NSView        *view_;
    NSRect        frame_;
    float        width_  = 0;
    float        margin_ = 0;
    
    view_ = [self infoTextField];
    frame_ = [view_ frame];

    width_  = NSWidth([[view_ superview] frame]);
    // 戻る／進むボタン
    width_ -= NSWidth([[self forwardBackMatrix] frame]);
    width_ -= kForwardBackButtonInsetWidth;
    // 履歴ポップアップ
    width_ -= NSWidth([[self threadHistoryPopUp] frame]);
    width_ -= NSWidth([[self boardHistoryPopUp] frame]);
    width_ -= kHistoryPopUpSpaceWidth;
    
    // 「ブックマーク」ボタン
/*
    margin_ = kBookmarksButtonInsetWidth;
    margin_ += NSWidth([[self bookmarksButton] frame]);
    
*/
    margin_ += kInfoTextFiledInsetWidth;
    width_ -= margin_;
    
    frame_.size.width = width_;
    frame_.origin.x = rightAlign
                ? margin_
                : NSWidth([[view_ superview] frame]) - width_ - margin_;
    
    [view_ setFrame : frame_];
}
//- (void) layoutToolbarBookmarksButton : (BOOL) rightAlign
//{
/*
    NSRect        frame_;
    float        x;
    
    frame_ = [[self bookmarksButton] frame];
    x = kBookmarksButtonInsetWidth;
    if (NO == rightAlign) {
        x = NSWidth([[[self bookmarksButton] superview] frame]) - x;
        x -= NSWidth(frame_);
    }
    frame_.origin.x = x;
    [[self bookmarksButton] setFrameOrigin : frame_.origin];
*/
//}

- (void) layoutToolbarUIComponents
{
    BOOL        rightAlign_ = [self isToolbarRightAlignment];
    
    [self synchronizeSizeAndSelectedItemOfPopUpButton : [self boardHistoryPopUp]];
    [self synchronizeSizeAndSelectedItemOfPopUpButton : [self threadHistoryPopUp]];
    
    [self layoutToolbarForwardBackMatrix : rightAlign_];
    [self layoutToolbarHistoryPopUp : rightAlign_];
    [self layoutToolbarInfoTextField : rightAlign_];
//    [self layoutToolbarBookmarksButton : rightAlign_];
}
- (void) historyPopUpSizeToFit;
{
    [self layoutToolbarUIComponents];
    [[self toolbarView] setNeedsDisplay : YES];
}


- (void) selectNotSelectionPopUpItem : (NSPopUpButton *) aPopUp
{
    NSMenuItem            *menuItem_;
    
    menuItem_ = (NSMenuItem*)[[aPopUp menu] itemWithTag : kNoSelectionItemTag];
    if (nil == menuItem_) {
        menuItem_ = createNoSelectionMenuItem();
        [[aPopUp menu] insertItem:menuItem_ atIndex:0];
        [menuItem_ release];
        
        menuItem_ = (NSMenuItem*)[[aPopUp menu] itemWithTag : kNoSelectionItemTag];
        UTILAssertNotNil(menuItem_);
    }
    [aPopUp selectItem : menuItem_];
}
- (void) removeNotSelectionPopUpItem : (NSPopUpButton *) aPopUp
{
    int                    index_;
    
    index_ = [[aPopUp menu] indexOfItemWithTag : kNoSelectionItemTag];
    if (index_ < 0) return;
    
    [aPopUp removeItemAtIndex : index_];
}

- (void) setupHistoryPopUpButton : (NSPopUpButton *) aPopUp
{
    NSPopUpButtonCell *cell_ = [aPopUp cell];
    BOOL atTop = ([CMRPref statusLinePosition] == CMRStatusLineAtTop);
    
    [aPopUp setBezelStyle : NSShadowlessSquareBezelStyle];
    [aPopUp setBordered : NO];
    [aPopUp setPreferredEdge : atTop ? NSMinYEdge : NSMaxYEdge];
    
    [cell_ setControlSize : NSSmallControlSize];
    [cell_ setArrowPosition : NSPopUpArrowAtBottom];
    
    [aPopUp setAutoenablesItems : NO];
    
     [self synchronizeHistoryItemsWithManager];
}
- (void) updateToolbarUIComponents
{
    BOOL        isRightAlignment_ = [self isToolbarRightAlignment];
    unsigned    autoresizingMask_;
    
    [self setupHistoryPopUpButton : [self boardHistoryPopUp]];
    [self setupHistoryPopUpButton : [self threadHistoryPopUp]];
    
    autoresizingMask_ = isRightAlignment_
                            ? NSViewMinXMargin
                            : NSViewMaxXMargin;
    // ボタン類
    [[self forwardBackMatrix] setAutoresizingMask : autoresizingMask_];
    [[self boardHistoryPopUp] setAutoresizingMask : autoresizingMask_];
    [[self threadHistoryPopUp] setAutoresizingMask : autoresizingMask_];
    
    // テキスト行
    autoresizingMask_ = NSViewWidthSizable; 
    [[self infoTextField] setAutoresizingMask : autoresizingMask_];
    [[self infoTextField] setAlignment : 
        isRightAlignment_ ? NSLeftTextAlignment : NSRightTextAlignment];
    
    // ブックマーク・ボタン
/*
    autoresizingMask_ = isRightAlignment_
                            ? NSViewMaxXMargin
                            : NSViewMinXMargin;
    [[self bookmarksButton] setAutoresizingMask : autoresizingMask_];
*/
    [self layoutToolbarUIComponents];
}


- (void) setupToolbarUIComponents
{
/*
    NSButtonCell    *cell_;
    NSButton        *button_;
    
    // 「ブックマーク」ボタン
    button_ = [self bookmarksButton];
    cell_ = [[CMRBookmarksButtonCell alloc] initTextCell : @""];
    
    [cell_ setImagePosition : [[button_ cell] imagePosition]];
    [cell_ setBezelStyle : [[button_ cell] bezelStyle]];
    
    [button_ setCell : cell_];
    [button_ setBordered : NO];
    
    // Action/Target
    [button_ setTarget : nil];
    [button_ setAction : kShowBookmarksPaneSelector];
    
*/
    [self updateToolbarUIComponents];
}
- (void) setupStatusLineView
{
    unsigned    autoresizingMask_;

    autoresizingMask_ = ([CMRPref statusLinePosition] != CMRStatusLineAtTop)
                            ? NSViewMaxYMargin
                            : NSViewMinYMargin;
    autoresizingMask_ |= NSViewWidthSizable;
    [[self statusLineView] setAutoresizingMask : autoresizingMask_];
}
- (void) setupUIComponents
{
    [self setupStatusLineView];
    [self setupProgressIndicator];
    [self setupToolbarUIComponents];
    
    [self addSubviewIntoStatusLineView : [self toolbarView]];
}
@end



@implementation CMRStatusLine(StatusLineView)
- (NSView *) currentSubview
{
    NSArray        *subviews_;
    
    subviews_ = [[self statusLineView] subviews];
    return [subviews_ lastObject];
}
- (void) removeSubviewsFromStatusLineView
{

    NSEnumerator    *iter_;
    NSView            *view_;
    
    iter_ = [[[self statusLineView] subviews] objectEnumerator];
    while (view_ = [iter_ nextObject]) {
        UTILAssertKindOfClass(view_, NSView);
        
        [view_ removeFromSuperview];
    }

}
- (void) addSubviewIntoStatusLineView : (NSView *) subview
{
    NSRect        frame_;
    
    UTILAssertNotNilArgument(subview, @"sub view");
    [self removeSubviewsFromStatusLineView];
    if ([subview superview] != nil)
        [subview removeFromSuperview];
    
    frame_ = [[self statusLineView] frame];
    frame_.origin = NSZeroPoint;
    [subview setFrame : frame_];
    
    [[self statusLineView] addSubview : subview];
}
@end



@implementation CMRStatusLine(ViewController)
+ (NSSize) subviewInset
{
    return kStatusLineSubviewInset;
}
- (void) removeUnnecessaryProgressViews
{
    NSProgressIndicator        *indicator_;
    
    indicator_ = [self progressIndicator];
    if ([self state] != CMRStatusLineInProgress)
        return;
    
    [indicator_ stopAnimation : self];
    [indicator_ setIndeterminate : NO];
    [indicator_ setDoubleValue : 0];
    
    [self addSubviewIntoStatusLineView : [self toolbarView]];
}

- (void) addViewsIfNeeded
{
    if (CMRStatusLineInProgress == [self state])
        return;
    
    [self addSubviewIntoStatusLineView : [self indicatorView]];
}

- (void) updateStatusLineWithTask : (id<CMRTask>) aTask;
{

    if (NO == [[CMRTaskManager defaultManager] isInProgress]) {
        [self removeUnnecessaryProgressViews];
        
    } else {
        double        amount_;
        
        [self addViewsIfNeeded];
        amount_ = [[CMRTaskManager defaultManager] amount];
        [[self progressIndicator] setIndeterminate : (-1.0 == amount_)];
        [[self progressIndicator] setDoubleValue : (-1.0 == amount_) ? 0.0 : amount_];
        
        [[self statusTextField] setStringValue : [aTask message] 
                                                    ? [aTask message] 
                                                    : @""];
    }
}
@end
