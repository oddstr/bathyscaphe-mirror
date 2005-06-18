/**
  * $Id: CMRStatusLine.m,v 1.2 2005/06/18 19:09:16 tsawada2 Exp $
  * 
  * CMRStatusLine.m
  *
  * Copyright (c) 2003, Takanori Ishikawa.
  * See the file LICENSE for copying permission.
  */
#import "CMRStatusLine_p.h"
#import "CMXTemplateResources.h"
#import "missing.h"

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
	float		moveY_;
	
	if(willBeShown){
		
		// ウィンドウの下側に表示する場合は
		// ウィンドウのリサイズ部分を避ける
		// resize indicatorのサイズが分からないので
		// NSScrollerの幅で代用
		lineFrame_.size.width = windowFrame_.size.width;
		lineFrame_.size.width -= [NSScroller scrollerWidth];
		
		lineFrame_.origin = NSZeroPoint;
		
		[[self statusLineView] setFrame : lineFrame_];
	}
	// ツールバー or タイトルバーとの「境界線」が重なって太くならないように、1ピクセル余分に出し入れする
	moveY_ = NSHeight(lineFrame_) * (willBeShown?1:-1) + (willBeShown?+1:(-1)) ;
	windowFrame_.size.height += moveY_;
	windowFrame_.origin.y -= moveY_;
	
	{
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

- (void) setInfoText : (id) aText;
{
	[self setInfoTextFieldObjectValue : aText];
}
- (void) setBrowserInfoText : (id) aText;
{
	[self setBrowserInfoTextFieldObjectValue : aText];
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
