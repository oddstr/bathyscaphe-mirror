/**
  * $Id: CMRStatusLine.m,v 1.5 2005/09/28 14:49:34 tsawada2 Exp $
  * 
  * CMRStatusLine.m
  *
  * Copyright (c) 2003, Takanori Ishikawa.
  * See the file LICENSE for copying permission.
  */
#import "CMRStatusLine_p.h"
#import "missing.h"
#import "RBSplitView.h"

#define kLoadNibName				@"CMRStatusView"

static NSString *const CMRStatusLineShownKey = @"Status Line Visibility";

@implementation CMRStatusLine
- (void) setIdentifier : (NSString *) anIdentifier
{
	id tmp;
	
	tmp = _identifier;
	_identifier = [anIdentifier retain];
	[tmp release];
}

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



- (int) state
{
	/* 未完成 */
	/* ひょっとしたらそのまま deprecated にするかも */
	return CMRStatusLineNone;
}

- (NSWindow *) window
{
	return _window;
}
- (NSString *) identifier
{
	return _identifier;
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
	[self setInfoTextFieldObjectValue : aText];
}
- (void) setBrowserInfoText : (id) aText;
{
	NSLog(@"Method setBrowserInfoText: was deprecated in LeafTicket and later.");
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
@end
