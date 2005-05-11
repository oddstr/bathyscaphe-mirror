//: CMXPopUpWindowController.m
/**
  * $Id: CMXPopUpWindowController.m,v 1.1.1.1 2005/05/11 17:51:09 tsawada2 Exp $
  * 
  * Copyright (c) 2001-2003, Takanori Ishikawa.  All rights reserved.
  * See the file LICENSE for copying permission.
  */

#import "CMXPopUpWindowController_p.h"
#import "CMXPreferences.h"
#import "CMXTemplateResources.h"
#import "CMRPopUpTemplateKeys.h"
#import "CMXPopUpWindowManager.h"



@implementation CMXPopUpWindowController
- (void) removeFromNotificationCenter
{
	[[NSNotificationCenter defaultCenter]
		removeObserver : self
		name : SGHTMLViewMouseExitedNotification
		object : [self textView]];
}
- (id) init
{
	if(self = [super initWithWindow : nil]){
		_closable = YES;
	}
	return self;
}

- (void) dealloc
{
	[self removeFromNotificationCenter];
	[_object release];
	[_textStorage release];
	[super dealloc];
}

+ (float) popUpTrackingInsetWidth
{
	id		tmp;
	
	tmp = CMXTemplateResource(kPopUpTrackingInsetKey, nil);
	if(nil == tmp)
		return 5.0f;
	
	UTILAssertRespondsTo(tmp, @selector(doubleValue));
	return [tmp floatValue];
}

- (void) setContext : (NSAttributedString *) context
{
	if(nil == context || nil == [self textStorage]) return;
	
	[[self textStorage] setAttributedString : context];
	
	if([CMRPref isResPopUpTextDefaultColor]){
		NSRange contentRng_;
		
		// ポップアップ表示のテキストを標準の色で
		// 表示する場合は生成した書式つき文字列
		// のカラー属性を変更する。
		contentRng_ =NSMakeRange(0, [[self textStorage] length]);
		if(contentRng_.length != 0){
			NSColor *color_;		//標準のテキストカラー
			
			color_ = [CMRPref resPopUpDefaultTextColor];
			[[self textStorage] 
				   removeAttribute : NSForegroundColorAttributeName
						     range : contentRng_];
			[[self textStorage] 
				  addAttribute : NSForegroundColorAttributeName
						 value : color_
					     range : contentRng_];
		}
	}
	[self sizeToFit];
}
- (void) showPopUpWindowWithContext : (NSAttributedString *) context
                              owner : (id<CMXPopUpOwner>   ) owner
                       locationHint : (NSPoint             ) point
{
	NSRect		wframe_;
	
	UTILAssertNotNil([self window]);
	
	[self setContext : context];
	[self setOwner : owner];
	
	wframe_ = [[self window] frame];
	wframe_.origin = point;
	
	[[self window] setFrame : [self constrainWindowFrame : wframe_]
					display : YES];
	
	[self showWindow : self];
}
- (void) close
{
	id		ms = [self textStorage];
	
	[self setIsClosable : YES];
	[self setOwner : nil];
	[ms deleteCharactersInRange : [ms range]];
	[super close];
}
- (void) performClose
{
	[self close];
}
- (NSWindow *) ownerWindow
{
	return [[self owner] window];
}
- (id<CMXPopUpOwner>) owner;
{
	id		owner_;
	
	owner_ = [[self textView] delegate];
	if(nil == owner_) return nil;
	UTILAssertRespondsTo(owner_, @selector(window));
	
	return owner_;
}
- (void) setOwner : (id<CMXPopUpOwner>) anOwner
{
	[[self textView] setDelegate : anOwner];
}

- (id) object
{
	return _object;
}
- (void) setObject : (id) anObject
{
	id		tmp;
	
	tmp = _object;
	_object = [anObject copy];
	[tmp release];
}

- (BOOL) isClosable
{
	return _closable;
}
- (void) setIsClosable : (BOOL) TorF
{
	_closable = TorF;
}

- (NSScrollView *) scrollView
{
	return _scrollView;
}
- (NSTextView *) textView
{
	return _textView;
}
- (NSTextStorage *) textStorage
{
	if(nil == _textStorage){
		_textStorage = [[NSTextStorage alloc] init];
	}
	return _textStorage;
}

- (NSWindow *) window
{
	if(nil == [super window]){
		[self createUIComponents];
	}
	return [super window];
}

- (BOOL) canPopUpWindow
{
	return (NO == [[self window] isVisible]);
}
- (BOOL) mouseInWindowFrameInset : (float) anInset
{
	NSPoint		mouseLocation_;
	NSView		*view_;
	
	mouseLocation_ = [[self window] mouseLocationOutsideOfEventStream];
	view_ = [[self window] contentView];
	return [view_ mouse:mouseLocation_ inRect:NSInsetRect([view_ frame], anInset, anInset)];
}
@end



@implementation CMXPopUpWindowController(Private)
- (void) setScrollView : (NSScrollView *) aScrollView
{
	_scrollView = aScrollView;
}
- (void) setTextView : (NSTextView *) aTextView
{
	_textView = aTextView;
}
- (void) setTextStorage : (NSTextStorage *) aTextStorage
{
	id		tmp;
	
	tmp = _textStorage;
	_textStorage = [aTextStorage retain];
	[tmp release];
}

- (void) showWindow : (id) sender
{
	[super showWindow : sender];
	[[self window] makeFirstResponder : [self textView]];
	[[self textView] resetCursorRects];
}

// Popup Lock
/* 2005-02-18 tsawada2<ben-sawa@td5.so-net.ne.jp>
	ポップアップウインドウが key window になっているときに、英字の L キーを押すと
	ポップアップが「ロック」され、マウスが離れても閉じなくなる。もう一度 L キーを押すとすぐにポップアップは消える。
	ロック状態のときは、それを示すためにポップアップの背景色とテキストカラーが変更される。
	問題点：
	1.ポップアップをロックしているときに背後のウインドウをスクロールさせたり移動すると、他のポップアップを正しい位置に
	  表示できなくなる。
	2.インタフェースがスマートでないかも。
*/
- (void) keyUp : (NSEvent *) theEvent
{
	NSString *str_ = [theEvent charactersIgnoringModifiers];
	
	if ( [str_ isEqualToString : @"l"]) {
		BOOL	temp_;
		NSRange contentRng_;

		temp_ = [self isClosable] ? NO : YES;
		contentRng_ =NSMakeRange(0, [[self textStorage] length]);

		[self setIsClosable : temp_];
	
		if ([self isClosable]) {
			//NSLog(@"Popup unlocked");
			/*[self setBackgroundColor : [CMRPref resPopUpBackgroundColor]];

			[[self textStorage] 
				   removeAttribute : NSForegroundColorAttributeName
						     range : contentRng_];
			[[self textStorage] 
				  addAttribute : NSForegroundColorAttributeName
						 value : [CMRPref resPopUpDefaultTextColor]
					     range : contentRng_];*/
			[self close];
		} else {
			//NSLog(@"Popup locked");
			[self setBackgroundColor : [NSColor windowBackgroundColor]];

			[[self textStorage] 
				   removeAttribute : NSForegroundColorAttributeName
						     range : contentRng_];
			[[self textStorage] 
				  addAttribute : NSForegroundColorAttributeName
						 value : [NSColor textColor]
					     range : contentRng_];
		}
	}
	[super keyUp : theEvent];
}

- (void) threadViewMouseExitedNotification : (NSNotification *) notification
{
	UTILAssertNotificationName(
		notification,
		SGHTMLViewMouseExitedNotification);
	UTILAssertNotificationObject(
		notification,
		[self textView]);
	
	if((NO == [self mouseInWindowFrameInset : [[self class] popUpTrackingInsetWidth]]) && [self isClosable])
		[self performClose];
	
}
@end
