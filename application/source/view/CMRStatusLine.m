/**
  * $Id: CMRStatusLine.m,v 1.1 2005/05/11 17:51:08 tsawada2 Exp $
  * 
  * CMRStatusLine.m
  *
  * Copyright (c) 2003, Takanori Ishikawa.
  * See the file LICENSE for copying permission.
  */
#import "CMRStatusLine_p.h"
#import "CMXTemplateResources.h"
#import "missing.h"



//////////////////////////////////////////////////////////////////////
////////////////////// [ 定数やマクロ置換 ] //////////////////////////
//////////////////////////////////////////////////////////////////////
#define kLoadNibName				@"CMRStatusView"
static NSString *const CMRStatusLineShownKey = @"Status Line Shown";



@implementation CMRStatusLine
- (void) setIdentifier : (NSString *) anIdentifier
{
	id tmp;
	
	tmp = _identifier;
	_identifier = [anIdentifier retain];
	[tmp release];
}

/*
- (id) init
{
	if(self = [super init]){
	}
	return self;
}
*/
- (id) initWithIdentifier : (NSString *) identifier
{
	if(self = [super init]){
		[self setIdentifier : identifier];
		if(NO == [NSBundle loadNibNamed : kLoadNibName
								  owner : self]){
			[self release];
			return nil;
		}
		[[CMRHistoryManager defaultManager] addClient : self];
		[self registerToNotificationCenter];
	}
	return self;
}

- (void) awakeFromNib
{
	// 停止ボタン
	[_stopButton retain];
	
	[self setupUIComponents];
	[self updateStatusLineWithTask : nil];
}
- (void) dealloc
{
	[self setWindow : nil];
	[self removeFromNotificationCenter];
	[[CMRHistoryManager defaultManager] removeClient : self];

	[_identifier release];
	
	// nib
	[_indicatorView release];
	[_toolbarView release];
	[_statusLineView release];
	
	// 停止ボタン
	[_stopButton release];
	
	[super dealloc];
}



- (int) state
{
	if([self currentSubview] == [self indicatorView])
		return CMRStatusLineInProgress;
	if([self currentSubview] == [self toolbarView])
		return CMRStatusLineToolbar;
	
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
	
	_Flags.delegateRespondsForward = 
		(_delegate && [_delegate respondsToSelector : @selector(statusLinePerformForward:)]) ? 1 : 0;
	_Flags.delegateRespondsBackward = 
		(_delegate && [_delegate respondsToSelector : @selector(statusLinePerformBackward:)]) ? 1 : 0;
	_Flags.delegateRespondsShouldForward = 
		(_delegate && [_delegate respondsToSelector : @selector(statusLineShouldPerformForward:)]) ? 1 : 0;
	_Flags.delegateRespondsShouldBackward = 
		(_delegate && [_delegate respondsToSelector : @selector(statusLineShouldPerformBackward:)]) ? 1 : 0;
	
}

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


- (BOOL) positionAtBottomFromDefaults
{
	return ([CMRPref statusLinePosition] != CMRStatusLineAtTop);
}
- (BOOL) positionAtBottom
{
	return NSEqualPoints([[self statusLineView] frame].origin, NSZeroPoint);
}
- (void) updateStatusLinePosition
{
	if([self positionAtBottom] == [self positionAtBottomFromDefaults])
		return;
	if(NO == [self isVisible])
		return;
	
	[self setVisible:NO animate:NO];
	[self setVisible:YES animate:NO];
}
- (void) changeWindowFrame : (NSWindow *) aWindow
                   animate : (BOOL      ) animateFlag
           statusLineShown : (BOOL      ) willBeShown
{
	NSRect		windowFrame_  = [aWindow frame];
	NSRect		lineFrame_    = [[self statusLineView] frame];
	BOOL		atBottom_;
	float		moveY_;
	
	atBottom_ = willBeShown 
					? [self positionAtBottomFromDefaults]
					: [self positionAtBottom];
	
	if(willBeShown){
		
		// ウィンドウの下側に表示する場合は
		// ウィンドウのリサイズ部分を避ける
		// resize indicatorのサイズが分からないので
		// NSScrollerの幅で代用
		lineFrame_.size.width = windowFrame_.size.width;
		if(atBottom_)
			lineFrame_.size.width -= [NSScroller scrollerWidth];
		
		lineFrame_.origin = NSZeroPoint;
		if(NO == [[aWindow contentView] isFlipped] && NO == atBottom_)
			lineFrame_.origin.y = [[aWindow contentView] frame].size.height;
		
		[[self statusLineView] setFrame : lineFrame_];
	}
	// ツールバー or タイトルバーとの「境界線」が重なって太くならないように、1ピクセル余分に出し入れする
	moveY_ = NSHeight(lineFrame_) * (willBeShown?1:-1) + (willBeShown?+1:(-1)) ;
	windowFrame_.size.height += moveY_;
	windowFrame_.origin.y -= moveY_;
	
	if(atBottom_){
		NSEnumerator	*iter_;
		NSView			*view_;
		
		iter_ = [[[[self window] contentView] subviews] objectEnumerator];
		while(view_ = [iter_ nextObject]){
			NSPoint		origin_;
			
			if(view_ == [self statusLineView]) continue;
			
			origin_ = [view_ frame].origin;
			origin_.y += moveY_;
			[view_ setFrameOrigin : origin_];
		}
	}
	[aWindow setFrame : windowFrame_ 
			  display : YES
			  animate : animateFlag
		  autoresizes : NO];
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

- (int) toolbarAlignment
{
	return [CMRPref statusLineToolbarAlignment];
}
- (void) setInfoText : (id) aText;
{
	[self setInfoTextFieldObjectValue : aText];
}



- (IBAction) cancel : (id) sender
{
	[[CMRTaskManager defaultManager] cancel : sender];
}
- (IBAction) toggleStatusLineShown : (id) sender
{
	[self setVisible:(NO == [self isVisible]) animate:YES];;
}
@end



@implementation CMRStatusLine(Autosave)
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
