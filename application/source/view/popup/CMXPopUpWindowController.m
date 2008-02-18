//
//  CMXPopUpWindowController.m
//  BathyScaphe
//
//  Updated by Tsutomu Sawada on 07/10/23.
//  Copyright 2005-2007 BathyScaphe Project. All rights reserved.
//  encoding="UTF-8"
//

#import "CMXPopUpWindowController_p.h"
#import <CoreServices/CoreServices.h>

@interface NSObject(CMXPopUpWindowOwner)
+ (NSMenu *)loadContextualMenuForTextView;
@end

@implementation CMXPopUpWindowController
- (void)removeFromNotificationCenter
{
	[[NSNotificationCenter defaultCenter] removeObserver:self name:SGHTMLViewMouseExitedNotification object:[self textView]];
}

- (id)init
{
	if (self = [super initWithWindow:nil]) {
		[self setClosable:YES];
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

+ (float)popUpTrackingInsetWidth
{
	id		tmp;
	
	tmp = SGTemplateResource(kPopUpTrackingInsetKey);
	if (!tmp || ![tmp respondsToSelector:@selector(floatValue)]) {
		return 5.0f;
	}

	return [tmp floatValue];
}

+ (float)popUpMaxWidthRate
{
	id			tmp;
	float		maxWidthRate_;

	tmp = SGTemplateResource(kPopUpMaxWidthRateKey);
	if (!tmp || ![tmp respondsToSelector:@selector(floatValue)]) {
		return 0.5f;
	} else {
		maxWidthRate_ = [tmp floatValue];
	}
	
	if (maxWidthRate_ >= 1 || maxWidthRate_ <= 0) {
		maxWidthRate_ = 0.5f;
	}
	
	return maxWidthRate_;
}

- (void)changeContextColorIfNeeded
{
	// ポップアップ表示のテキストを標準の色で
	// 表示する場合は生成した書式つき文字列
	// のカラー属性を変更する。
	NSTextStorage *storage_ = [self textStorage];
	BSThreadViewTheme *theme_ = [self theme];

	if(storage_ && ([storage_ length] > 0) && [theme_ popupUsesAlternateTextColor]) {
		NSRange contentRange = [storage_ range];
		
		NSColor *color_ = [theme_ popupAlternateTextColor];
		
		[storage_ removeAttribute:NSForegroundColorAttributeName range:contentRange];
		[storage_ addAttribute:NSForegroundColorAttributeName value:color_ range:contentRange];
	}
}

- (void)changeContextColorForLockedPopUp
{
	NSTextStorage *storage_ = [self textStorage];
	NSRange contentRng_ = [storage_ range];

	[storage_ removeAttribute:NSForegroundColorAttributeName range:contentRng_];
	[storage_ addAttribute:NSForegroundColorAttributeName value:[NSColor textColor] range:contentRng_];
}

- (void)setContext:(NSAttributedString *)context
{
	if(!context || ![self textStorage]) return;
	
	[[self textStorage] setAttributedString:context];
	[self changeContextColorIfNeeded];
}

- (void)showPopUpWindowWithContext:(NSAttributedString *)context owner:(id)owner locationHint:(NSPoint)point
{
	NSRect		wframe_;

	UTILAssertNotNil([self window]);

	[self updateLinkTextAttributes];
	[self updateAntiAlias];
	
	[self setOwner:owner];
	[self setContext:context];
	[self sizeToFit];

	wframe_ = [[self window] frame];
	wframe_.origin = point;
	
	[[self window] setFrame:[self constrainWindowFrame:wframe_] display:YES];
	[self showWindow:self];
}

- (void)close
{
	NSTextStorage *storage = [self textStorage];
	
	[self setClosable:YES];
	[self setOwner:nil];
	[storage deleteCharactersInRange:[storage range]];
	[super close];
}

- (void)performClose
{
	if ([self isClosable]) {
		[self close];
	} else {
		[self restoreLockedPopUp];
	}
}

- (void)myPerformClose:(id)sender
{
	// Call from BSPopUpTitlebar's close button.
	[self restoreLockedPopUp:NO];
}

- (BOOL)canPopUpWindow
{
	return (NO == [[self window] isVisible]);
}
- (BOOL)mouseInWindowFrameInset:(float)anInset
{
	NSPoint		mouseLocation_;
	NSView		*view_;
	
	mouseLocation_ = [[self window] mouseLocationOutsideOfEventStream];
	view_ = [[self window] contentView];
	return [view_ mouse:mouseLocation_ inRect:NSInsetRect([view_ frame], anInset, anInset)];
}

#pragma mark Accessors
- (NSWindow *)ownerWindow
{
	return [[self owner] window];
}

- (id)owner
{
	id		owner_;
	
	owner_ = [[self textView] delegate];
	if(!owner_) return nil;
	UTILAssertRespondsTo(owner_, @selector(window));
	
	return owner_;
}

- (void)setOwner:(id)anOwner
{
	[[self textView] setDelegate:anOwner];

	if ([[anOwner class] respondsToSelector:@selector(loadContextualMenuForTextView)]) {
		[[self textView] setMenu:[[anOwner class] loadContextualMenuForTextView]];
	}
}

- (id)object
{
	return _object;
}

- (void)setObject:(id)anObject
{
	id		tmp;
	
	tmp = _object;
	_object = [anObject copy];
	[tmp release];
}

- (BOOL)isClosable
{
	return m_closable;
}

- (void)setClosable:(BOOL)isClosable
{
	m_closable = isClosable;
}

- (NSScrollView *)scrollView
{
	return _scrollView;
}
- (NSTextView *)textView
{
	return _textView;
}
- (NSTextStorage *)textStorage
{
	if (!_textStorage) {
		_textStorage = [[NSTextStorage alloc] init];
	}
	return _textStorage;
}

- (BSPopUpTitlebar *)titlebar
{
	return m_titlebar;
}

- (NSWindow *)window
{
	if (![super window]) {
		[self createUIComponents];
	}
	return [super window];
}
@end


@implementation CMXPopUpWindowController(Private)
- (void)setScrollView:(NSScrollView *)aScrollView
{
	_scrollView = aScrollView;
}

- (void)setTextView:(NSTextView *)aTextView
{
	_textView = aTextView;
}

- (void)setTextStorage:(NSTextStorage *)aTextStorage
{
	[aTextStorage retain];
	[_textStorage release];
	_textStorage = aTextStorage;
}

- (void)setTitlebar:(BSPopUpTitlebar *)aTitlebar
{
	m_titlebar = aTitlebar;
}

- (void)showWindow:(id)sender
{
	[super showWindow:sender];
	[[self window] makeFirstResponder:[self textView]];

	// NOTE: -[NSWindow invalidateCursorRectsForView:] では効果が十分ではない
	[[self textView] resetCursorRects];
}

#pragma mark Popup Locking
- (void)restoreLockedPopUp:(BOOL)shouldPoof
{
	NSRect frame_;
	NSPoint poofLocation;
	frame_ = [[self window] frame];
	poofLocation = NSMakePoint(NSMidX(frame_), NSMidY(frame_));

	[[self window] setMovableByWindowBackground:NO];
	[[self titlebar] setHidden:YES];

	[self updateBGColor];

	[self close];
	if (shouldPoof) NSShowAnimationEffect(NSAnimationEffectDisappearingItemDefault, poofLocation, NSMakeSize(128,128), nil, NULL, nil);
}

- (void)restoreLockedPopUp
{
	[self restoreLockedPopUp:YES];
}

- (void)setupLockedPopUp
{
	NSSize scrollViewSize;
	NSRect windowFrame;
//	NSPoint windowOrigin;

	SystemSoundPlay(0);

	scrollViewSize = [[self scrollView] frame].size;
	windowFrame = [[self window] frame];
//	windowOrigin = windowFrame.origin;

	if (windowFrame.size.height + TITLEBAR_HEIGHT < [self maxSize].height) {
		windowFrame.size.height += TITLEBAR_HEIGHT;
//		windowOrigin.y -= TITLEBAR_HEIGHT;
		windowFrame.origin.y -= TITLEBAR_HEIGHT;
		[[self window] setFrame:windowFrame display:YES];
//		[[self window] setFrameOrigin:windowOrigin];
		[[self scrollView] setFrameOrigin:NSMakePoint(0,0)];
	} else {
		scrollViewSize.height -= TITLEBAR_HEIGHT;
		[[self scrollView] setFrameSize:scrollViewSize];
	}
	
	[[self window] setBackgroundColor:[NSColor windowBackgroundColor]];
	[self changeContextColorForLockedPopUp];

	[[self titlebar] setHidden:NO];
	[[self window] setMovableByWindowBackground:YES];
	
	[[self scrollView] setNeedsDisplay:YES];
}

- (void)togglePopupLock
{
	[self setClosable:(NO == [self isClosable])];

	if ([self isClosable]) {
		[self restoreLockedPopUp];
	} else {
		[self setupLockedPopUp];
	}
}

#pragma mark Event Handling
- (void)keyUp:(NSEvent *)theEvent
{
	NSString *str_ = [theEvent charactersIgnoringModifiers];
	
	if ([str_ isEqualToString : @"l"]) {
		[self togglePopupLock];
	} else if (![self isClosable] && [str_ isEqualToString:@"\033"]) {
		[self togglePopupLock];
	}
	[super keyUp:theEvent];
}

- (void)otherMouseDown:(NSEvent *)theEvent
{
	[self togglePopupLock];
	[super otherMouseDown:theEvent];
}

#pragma mark Notification
- (void)threadViewMouseExited:(NSNotification *)notification
{
	UTILAssertNotificationName(notification, SGHTMLViewMouseExitedNotification);
	UTILAssertNotificationObject(notification, [self textView]);
	
	if(![self mouseInWindowFrameInset:[[self class] popUpTrackingInsetWidth]] && [self isClosable]) {
		[self performClose];
	}
}
@end
