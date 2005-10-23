/**
  * $Id: CMRStatusLine.m,v 1.6 2005/10/23 09:15:39 tsawada2 Exp $
  * 
  * CMRStatusLine.m
  *
  * Copyright (c) 2003, Takanori Ishikawa.
  * See the file LICENSE for copying permission.
  */
#import "CMRStatusLine.h"

#import "CMRTask.h"
#import "CMRTaskManager.h"
#import "missing.h"
#import "RBSplitView.h"

#define kLoadNibName				@"CMRStatusView"

static NSString *const CMRStatusLineShownKey = @"Status Line Visibility";

@implementation CMRStatusLine
- (id) initWithIdentifier : (NSString *) identifier
{
	if(self = [super init]){
		[self setIdentifier : identifier];
		if(NO == [NSBundle loadNibNamed : kLoadNibName
								  owner : self]){
			[self release];
			return nil;
		}
		[self registerToNotificationCenter];
	}
	return self;
}

- (void) awakeFromNib
{
	[self setupUIComponents];
	[self updateStatusLineWithTask : nil];
}
- (void) dealloc
{
	[self setWindow : nil];
	[self removeFromNotificationCenter];

	[_identifier release];
	
	// nib
	[_statusLineView release];
	
	[super dealloc];
}

#pragma mark Accessor

- (NSView *) statusLineView
{
    return _statusLineView;
}
- (NSTextField *) statusTextField
{
    return _statusTextField;
}
- (NSProgressIndicator *) progressIndicator
{
    return _progressIndicator;
}

- (NSWindow *) window
{
	return _window;
}

- (NSString *) identifier
{
	return _identifier;
}
- (void) setIdentifier : (NSString *) anIdentifier
{
	id tmp;
	
	tmp = _identifier;
	_identifier = [anIdentifier retain];
	[tmp release];
}

- (id) delegate
{
	return _delegate;
}
- (void) setDelegate : (id) aDelegate
{
	_delegate = aDelegate;
}

#pragma mark Window

- (void) setWindow : (NSWindow *) aWindow
{
	[self setWindow : aWindow
			visible : [[self preferencesObject] 
						  boolForKey : [self statusLineShownUserDefaultsKey]
						defaultValue : YES]];
}
- (void) setWindow : (NSWindow *) aWindow
		   visible : (BOOL      ) shown
{
	_window = aWindow;
	if(nil == _window) return;
	
	[self setVisible:shown animate:NO];
}

- (void) changeWindowFrame : (NSWindow *) aWindow
                   animate : (BOOL      ) animateFlag
           statusLineShown : (BOOL      ) willBeShown
{
	NSRect		windowFrame_  = [aWindow frame];
	NSRect		lineFrame_    = [[self statusLineView] frame];
	float		statusBarHeight_;
	
	if(willBeShown){
		
		// ウィンドウの下側にステータスバーを配置するが、その際
		// ウィンドウのリサイズ部分を避ける
		// resize indicatorのサイズが分からないので
		// NSScrollerの幅で代用
		lineFrame_.size.width = windowFrame_.size.width;
		lineFrame_.size.width -= [NSScroller scrollerWidth];
		
		lineFrame_.origin = NSZeroPoint;
		
		[[self statusLineView] setFrame : lineFrame_];
	}

	// ビューの「境界線」が重なって太くならないように、1ピクセル余分に出し入れする
	statusBarHeight_ = NSHeight(lineFrame_)+1 ;
	
	{
		NSEnumerator	*iter_;
		NSView			*view_;
		
		iter_ = [[[[self window] contentView] subviews] objectEnumerator];
		while(view_ = [iter_ nextObject]){
			NSRect		newRect;

			if(view_ == [self statusLineView]) continue;
			
			if (willBeShown) {
				// 最下部に接して配置されているビューの height を縮めて下部に余白を作り、そこに
				// ステータスバーを押し込むと考える（ウインドウ自体のサイズは変えない）。
				if([view_ frame].origin.y <= 0) {

					float tmp_ = 0.0;
				
					if([view_ class] == [RBSplitView class]) {
						// RBSplitView のリサイズ時の不審な挙動対策。RBSplitView の frame を
						// 変更する前に、RBSplitSubview の dimension（幅）を記憶しておき、
						// frame 変更後にその dimension に再設定してやる。
						tmp_ = [[(RBSplitView *)view_ subviewWithIdentifier : @"boards"] dimension];
					}
					
					newRect = [view_ frame];
					newRect.origin.y += statusBarHeight_;
					newRect.size.height -= statusBarHeight_;
					[view_ setFrame : newRect];
					
					if([view_ class] == [RBSplitView class]) {
						[[(RBSplitView *)view_ subviewWithIdentifier : @"boards"] setDimension : tmp_];
					}
				}

			} else {
			
				// ステータスバーをよけて配置されていたビューの height を拡大して、最下部に接地させる。

				if([view_ frame].origin.y <= statusBarHeight_) {
					newRect = [view_ frame];
					newRect.origin.y -= statusBarHeight_;
					newRect.size.height += statusBarHeight_;
					[view_ setFrame : newRect];
				}
			}
		}
	}
	
	//[aWindow displayIfNeeded];	// 多分必要ない
}

- (BOOL) isVisible
{
	return ([[self statusLineView] window] != nil);
}

- (void) setVisible : (BOOL) shown
            animate : (BOOL) isAnimate
{
	if(shown == [self isVisible]) return;
	
	if(NO == [self isVisible]){
		[[[self window] contentView] addSubview : [self statusLineView]];
	}else{
		[[self statusLineView] removeFromSuperviewWithoutNeedingDisplay];
	}
	[self changeWindowFrame : [self window]
					animate : isAnimate
			statusLineShown : [self isVisible]];
	
	// User Defaults
	[[NSUserDefaults standardUserDefaults] 
			setBool : [self isVisible]
			 forKey : [self statusLineShownUserDefaultsKey]];
}

- (void) setInfoText : (id) aText;
{
    id        v = aText;
    
    if (nil == v || NO == [v isKindOfClass : [NSAttributedString class]]) {
        [[self statusTextField] setObjectValue : nil == v ? @"" : v];
        return;
    }

    [[self statusTextField] setAttributedStringValue : v];
}

#pragma mark IBAction

- (IBAction) cancel : (id) sender
{
	[[CMRTaskManager defaultManager] cancel : sender];
}
- (IBAction) toggleStatusLineShown : (id) sender
{
	[self setVisible:(NO == [self isVisible]) animate:YES];
}

#pragma mark User Defaults

- (NSString *) userDefaultsKeyWithKey : (NSString *) key
{
	if(nil == key || nil == [self identifier])
		return key;
	
	return [NSString stringWithFormat :
						@"%@ %@",
						[self identifier],
						key];
}
- (NSString *) statusLineShownUserDefaultsKey
{
	return [self userDefaultsKeyWithKey : CMRStatusLineShownKey];
}
- (id) preferencesObject
{
	return [NSUserDefaults standardUserDefaults];
}

#pragma mark Other Actions

- (void) setupUIComponents
{
    unsigned    autoresizingMask_;

    autoresizingMask_ = NSViewMaxYMargin;
    autoresizingMask_ |= NSViewWidthSizable;
    [[self statusLineView] setAutoresizingMask : autoresizingMask_];
}

- (void) updateStatusLineWithTask : (id<CMRTask>) aTask;
{

    if (NO == [[CMRTaskManager defaultManager] isInProgress]) {
        [[self progressIndicator] stopAnimation : nil];
        [[self statusTextField] setStringValue : @""];
        
    } else {
        [[self progressIndicator] startAnimation : nil];
        [[self statusTextField] setStringValue : ([aTask message] ? [aTask message] : @"")];
    }
}
@end

#pragma mark -

@implementation CMRStatusLine(Notification)
- (void) registerToNotificationCenter
{
    [[NSNotificationCenter defaultCenter]
         addObserver : self
            selector : @selector(taskWillStartNotification:)
                name : CMRTaskWillStartNotification
              object : nil];
    [[NSNotificationCenter defaultCenter]
         addObserver : self
            selector : @selector(taskWillProgressNotification:)
                name : CMRTaskWillProgressNotification
              object : nil];
    [[NSNotificationCenter defaultCenter]
         addObserver : self
            selector : @selector(taskDidFinishNotification:)
                name : CMRTaskDidFinishNotification
              object : nil];
    
    [super registerToNotificationCenter];
}
- (void) removeFromNotificationCenter
{
    [[NSNotificationCenter defaultCenter]
      removeObserver : self
                name : CMRTaskWillStartNotification
              object : nil];
    [[NSNotificationCenter defaultCenter]
      removeObserver : self
                name : CMRTaskWillProgressNotification
              object : nil];
    [[NSNotificationCenter defaultCenter]
      removeObserver : self
                name : CMRTaskDidFinishNotification
              object : nil];

    [super removeFromNotificationCenter];
}


- (void) taskWillStartNotification : (NSNotification *) theNotification
{
    UTILAssertNotificationName(
        theNotification,
        CMRTaskWillStartNotification);

    [self updateStatusLineWithTask : [theNotification object]];
}
- (void) taskWillProgressNotification : (NSNotification *) theNotification
{
    UTILAssertNotificationName(
        theNotification,
        CMRTaskWillProgressNotification);
    
    [self updateStatusLineWithTask : [theNotification object]];
}

- (void) taskDidFinishNotification : (NSNotification *) theNotification
{
    UTILAssertNotificationName(
        theNotification,
        CMRTaskDidFinishNotification);
    UTILAssertConformsTo(
        [[theNotification object] class],
        @protocol(CMRTask));
    
    [self updateStatusLineWithTask : [theNotification object]];
}
@end
