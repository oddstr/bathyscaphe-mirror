/**
  * $Id: CMRThreadView.m,v 1.6 2005/09/24 06:07:49 tsawada2 Exp $
  * 
  * CMRThreadView.m
  *
  * Copyright (c) 2003-2004 Takanori Ishikawa, All rights reserved.
  * See the file LICENSE for copying permission.
  */
#import "CMRThreadView_p.h"
#import "CMXMenuHolder.h"
#import "AppDefaults.h"
#import "NSTextView+CMXAdditions.h"



#define kDefaultMenuNibName		@"CMRThreadMenu"

@interface CMRThreadView(Action)
- (BOOL) setUpMessageActionMenuItem : (NSMenuItem   *) theItem
					     forIndexes : (NSEnumerator *) anIndexEnum
				  withAttributeName : (NSString     *) aName;

- (IBAction) googleSearch : (id) sender;
@end



@interface CMRMessageIndexEnumerator : NSEnumerator
{
	@private
	NSAttributedString	*_textStorage;
	NSRange				_selectedRange;
	unsigned			_charIndex;
}
- (id) initWithAttributedString : (NSAttributedString *) aString
				  selectedRange : (NSRange             ) aSelectedRange;
@end


@implementation CMRMessageIndexEnumerator
- (id) initWithAttributedString : (NSAttributedString *) aString
				  selectedRange : (NSRange             ) aSelectedRange;
{
	if (self = [super init]) {
		_textStorage = [aString retain];
		_selectedRange = aSelectedRange;
		_charIndex = _selectedRange.location;
	}
	return self;
}
- (void) dealloc
{
	[_textStorage release];
	[super dealloc];
}
- (id) nextObject
{
	id				v;
	NSRange			effectiveRange_;
	
	if (NSMaxRange(_selectedRange) > [_textStorage length])
		return nil;
	
	while (_charIndex < NSMaxRange(_selectedRange)) {
		v = [_textStorage attribute : CMRMessageIndexAttributeName
						atIndex : _charIndex
		  longestEffectiveRange : &effectiveRange_
						inRange : _selectedRange];
		_charIndex = NSMaxRange(effectiveRange_);
		
		if (v != nil) {
			return v;
		}
	}
	return nil;
}
@end



@implementation CMRThreadView
- (id) initWithFrame : (NSRect) aFrame
{
	if (self = [super initWithFrame : aFrame]) {
		_lastCharIndex = NSNotFound;
	}
	return self;
}

- (void)updateRuler
{
	// Ruler の更新をブロックする。
}

- (CMRThreadSignature *) threadSignature
{
	id		delegate_;
	
	delegate_ = [self delegate];
	if (nil == delegate_ || NO == [delegate_ respondsToSelector : @selector(threadSignatureForView:)])
		return nil;
	
	return [delegate_ threadSignatureForView : self];
}
- (CMRThreadLayout *) threadLayout
{
	id		delegate_;
	
	delegate_ = [self delegate];
	if (nil == delegate_ || NO == [delegate_ respondsToSelector : @selector(threadLayoutForView:)])
		return nil;
	
	return [delegate_ threadLayoutForView : self];
}

- (unsigned int) previousMessageIndexOfCharIndex : (unsigned int) charIndex
{
	NSTextStorage	*storage_ = [self textStorage];
	NSRange			range_;
	NSRange			effectiveRange_;
	unsigned		index_;
	id				v;
	
	if (NSNotFound == charIndex || charIndex >= [storage_ length])
		return NSNotFound;
	
	index_ = charIndex;
	while (index_ >= 0) {
		range_ = NSMakeRange(0, index_ +1);
		v = [storage_ attribute : CMRMessageIndexAttributeName
						atIndex : index_
		  longestEffectiveRange : &effectiveRange_
						inRange : range_];
		if (v != nil) {
			return [v unsignedIntValue];
		}
		if (0 == effectiveRange_.location)
			break;
		
		index_ = effectiveRange_.location -1;
	}
	return NSNotFound;
}
- (unsigned int) previousMessageStartIndexOfCharIndex : (unsigned int) charIndex
{
	NSTextStorage	*storage_ = [self textStorage];
	NSRange			range_;
	NSRange			effectiveRange_;
	unsigned		index_;
	id				v;
	
	if (NSNotFound == charIndex || charIndex >= [storage_ length])
		return NSNotFound;
	
	index_ = charIndex;
	while (index_ >= 0) {
		range_ = NSMakeRange(0, index_ +1);
		v = [storage_ attribute : CMRMessageIndexAttributeName
						atIndex : index_
		  longestEffectiveRange : &effectiveRange_
						inRange : range_];
		if (v != nil) {
			return effectiveRange_.location;
		}
		if (0 == effectiveRange_.location)
			break;
		
		index_ = effectiveRange_.location -1;
	}
	return NSNotFound;
}
- (NSRange) selectedMessageIndexRange
{
	NSRange			range_ = [self selectedRange];
	NSTextStorage	*storage_ = [self textStorage];
	
	id				v;
	unsigned		charIndex_;
	NSRange			effectiveRange_;
	NSRange			indexRange_;
	
	if (0 == range_.length) {
		range_.location = _lastCharIndex;
		range_.length = 1;
	}
	if (NSNotFound == range_.location || NSMaxRange(range_) > [storage_ length])
		goto NOT_FOUND;
	
	indexRange_ = kNFRange;
	charIndex_ = range_.location;
	while (charIndex_ < NSMaxRange(range_)) {
		v = [storage_ attribute : CMRMessageIndexAttributeName
						atIndex : charIndex_
		  longestEffectiveRange : &effectiveRange_
						inRange : range_];
		if (v != nil) {
			if (NSNotFound == indexRange_.location) {
				indexRange_.location = [v unsignedIntValue];
			}
			indexRange_.length = [v unsignedIntValue];
		}
		charIndex_ = NSMaxRange(effectiveRange_);
	}
	indexRange_.location = 
		[self previousMessageIndexOfCharIndex : range_.location];
	
	if (NSNotFound == indexRange_.location) {
		goto NOT_FOUND;
	}
	
	if (0 == indexRange_.length)
		indexRange_.length = 1;
	else
		indexRange_.length = (indexRange_.length - indexRange_.location) +1;
	
	return indexRange_;

NOT_FOUND:
	return kNFRange;
}

- (NSEnumerator *) selectedMessageIndexEnumerator
{
	NSEnumerator	*enum_;
	NSRange			selectedRange_;
	unsigned		prevCharIndex_;
	
	selectedRange_ = [self selectedRange];
	// コンテキスト・メニューを表示した場合は表示位置の
	// インデックス
	if (0 == selectedRange_.length) {
		selectedRange_.location = _lastCharIndex;
		selectedRange_.length = 1;
	}
	if (NSNotFound == selectedRange_.location ||
		NSMaxRange(selectedRange_) > [[self textStorage] length]) 
	{ return [[NSArray empty] objectEnumerator]; }
	
	// 選択範囲のひとつまえのレスも含む
	prevCharIndex_ = [self previousMessageStartIndexOfCharIndex : selectedRange_.location];
	if (prevCharIndex_ != NSNotFound)
		selectedRange_.location = prevCharIndex_;
	
	enum_ = [[CMRMessageIndexEnumerator alloc]
				initWithAttributedString : [self textStorage]
						   selectedRange : selectedRange_];
	
	return [enum_ autorelease];
}

// Event Handling
- (BOOL) mouseClicked : (NSEvent *) theEvent
			  atIndex : (unsigned ) charIndex
{
	NSRange	effectiveRange_;
	id		v;
	id		delegate_ = [self delegate];
	SEL		selector_ = @selector(threadView:mouseClicked:atIndex:messageIndex:);
	
	if ([super mouseClicked:theEvent atIndex:charIndex]) 
		return YES;
	
	v = [[self textStorage] attribute : CMRMessageIndexAttributeName 
						atIndex : charIndex
						effectiveRange : &effectiveRange_];
	if (nil == v) return NO;
	UTILAssertRespondsTo(v, @selector(unsignedIntValue));
	
	if (delegate_ && [delegate_ respondsToSelector : selector_]) {
		return [delegate_ threadView:self mouseClicked:theEvent atIndex:charIndex messageIndex:[v unsignedIntValue]];
	}
	return NO;
}

// Menu

#define kMessageMenuNibName		@"CMXMessageMenu"
#define kMessageActionMenuTag	-1

#define kLocalAboneTag			0
#define kInvisibleAboneTag		1
#define kAsciiArtTag			2
#define kBookmarkTag			3
#define kSpamTag				4

// @see googleSearch:
#define kPropertyListGoogleQueryKey		@"Thread - GoogleQuery"
#define kGoogleQueryValiableKey			@"%%%Query%%%"
+ (void) setupMenuItemInMenu : (NSMenu *) aMenu
		   representedObject : (id      ) anObject
{
	NSEnumerator		*iter_;
	NSMenuItem			*item_;
	
	iter_ = [[aMenu itemArray] objectEnumerator];
	while (item_ = [iter_ nextObject]) {
		[item_ setRepresentedObject : anObject];
		[item_ setEnabled : YES];
		
		if ([item_ hasSubmenu]) {
			[self setupMenuItemInMenu : [item_ submenu]
					representedObject : anObject];
		}
	}
}
+ (NSMenu *) messageMenu
{
	static NSMenu *kMessageMenu = nil;
	
	if(nil == kMessageMenu){
		kMessageMenu = 
			[[CMXMenuHolder menuFromBundle : [NSBundle mainBundle] 
								   nibName : kMessageMenuNibName] copy];
	}
	return kMessageMenu;
}
+ (NSMenu *) defaultMenu
{
	static NSMenu *kDefaultMenu_ = nil;
	
	if(nil == kDefaultMenu_){
		NSMenuItem		*item_;
		NSMenu			*submenu_;
		
		kDefaultMenu_ = 
			[[CMXMenuHolder menuFromBundle : [NSBundle mainBundle] 
								   nibName : kDefaultMenuNibName] copy];
		
		item_ = (NSMenuItem*)[kDefaultMenu_ itemWithTag : kMessageActionMenuTag];
		submenu_ = [[self messageMenu] copy];
		
		[self setupMenuItemInMenu:submenu_ representedObject:nil];
		[submenu_ setAutoenablesItems : YES];
		
		[item_ setSubmenu : submenu_];
		[submenu_ release];
	}
	return kDefaultMenu_;
}
- (NSMenu *) menuForEvent : (NSEvent *) theEvent
{
	NSPoint		mouseLocation_;//,mouseLocation2_;
	BOOL		isMouseEvent_ = YES;
	
	// マウスイベントか
NS_DURING
	[theEvent clickCount];
NS_HANDLER
	isMouseEvent_ = NO;
NS_ENDHANDLER
	
	_lastCharIndex = NSNotFound;
	if (isMouseEvent_) {
		//mouseLocation2_ = [self convertPoint : [theEvent locationInWindow]
		//					   fromView : nil];
		mouseLocation_ = [theEvent locationInWindow];
		mouseLocation_ = [[self window] convertBaseToScreen : mouseLocation_];
		_lastCharIndex = [self characterIndexForPoint : mouseLocation_];
	}
	
	// マウスポインタが選択されたテキストの、その選択領域に入っているなら、選択テキスト用のコンテキストメニューを返す。
	//if(NSPointInRect (mouseLocation2_, [self boundingRectForCharacterInRange : [self selectedRange]]))
	//		return [[self class] defaultMenu];
	
	// そうでなければ、スーパークラスで判断してもらう（see SGHTMLView.m)。
	return [super menuForEvent : theEvent];
}

- (NSMenu *) messageMenuWithMessageIndex : (unsigned) aMessageIndex
{
	return [self messageMenuWithMessageIndexRange : NSMakeRange(aMessageIndex, 1)];
}


static NSString *mActionGetKeysForTag[] = {
	@"isLocalAboned",		// kLocalAboneTag
	@"isInvisibleAboned",	// kInvisibleAboneTag
	@"isAsciiArt",			// kAsciiArtTag
	@"hasBookmark",			// kBookmarkTag
	@"isSpam",				// kSpamTag
};
- (NSMenu *) messageMenuWithMessageIndexRange : (NSRange) anIndexRange
{
	
	CMRThreadLayout		*L = [self threadLayout];
	NSArray				*indexes_;
	NSEnumerator		*iter_;
	NSMenu				*menu_ = [[self class] messageMenu];
	NSMenuItem			*item_;
	CMRThreadMessage	*m;
	id					rep;
	
	if (NSMaxRange(anIndexRange) > [L numberOfReadedMessages])
		return nil;
	
	m = [L messageAtIndex : anIndexRange.location];
	anIndexRange.location = [m index];
	
	rep = [NSValue valueWithRange : anIndexRange];
	// RepresentedObjectの設定
	[[self class] setupMenuItemInMenu : menu_
			representedObject : rep];
	
	// 状態の設定
	indexes_ = [self indexArrayWithIndexRange : anIndexRange];
	iter_ = [[menu_ itemArray] objectEnumerator];
	while (item_ = [iter_ nextObject]) {
		int				tag   = [item_ tag];
		
		if (tag < 0) continue;
		
		NSAssert1(
			UTILNumberOfCArray(mActionGetKeysForTag) > tag,
			@"[item tag] was invalid(%u)", tag);
		
		[self setUpMessageActionMenuItem : item_
							  forIndexes : [indexes_ objectEnumerator]
					   withAttributeName : mActionGetKeysForTag[tag]];
	}
	
	return menu_;
}

/*** Message Menu Action ***/
- (NSEnumerator *) indexEnumeratorWithIndexRange : (NSRange) anIndexRange
{
	return [[self indexArrayWithIndexRange : anIndexRange] objectEnumerator];
}
- (NSArray *) indexArrayWithIndexRange : (NSRange) anIndexRange
{
	NSMutableArray		*ary;
	unsigned			i;
	
	ary = [NSMutableArray array];
	for (i = anIndexRange.location; i < NSMaxRange(anIndexRange); i++) {
		[ary addObject : [NSNumber numberWithUnsignedInt : i]];
	}
	return ary;
}
- (NSEnumerator *) representedObjectWithSender : (id) sender
{
	id		v;
	
	v = [sender representedObject];
	if (nil == v) {		// 選択されたレス
		
		// このあと内容が変更されるかもしれない
		v = [self selectedMessageIndexEnumerator];
		v = [v allObjects];
		v = [v objectEnumerator];
	} else {
		UTILAssertRespondsTo(v, @selector(rangeValue));
		v = [self indexEnumeratorWithIndexRange : [v rangeValue]];
	}
	return v;
}

// スパムフィルタへの登録
- (void) messageRegister : (CMRThreadMessage *) aMessage
			registerFlag : (BOOL			  ) flag
{
	id		delegate_;
	
	delegate_ = [self delegate];
	if (nil == delegate_ || NO == [delegate_ respondsToSelector : @selector(threadView:spam:messageRegister:)])
		return;
	
	[delegate_ threadView:self spam:aMessage messageRegister:flag];
}


/* スレコピー */
- (IBAction) messageCopy : (id) sender
{
	NSPasteboard			*pboard_ = [NSPasteboard generalPasteboard];
	NSArray					*types_;
	NSEnumerator			*mIndexEnum_;
	NSNumber				*mIndex;
	CMRThreadLayout			*L = [self threadLayout];
	NSMutableAttributedString	*contents_;
	
	if (nil == L) return;
	
	contents_ = [[NSMutableAttributedString alloc] init];
	mIndexEnum_ = [self representedObjectWithSender : sender];
	while (mIndex = [mIndexEnum_ nextObject]) {
		NSAttributedString		*m;
		NSRange					range_;
		
		UTILAssertRespondsTo(mIndex, @selector(unsignedIntValue));
		range_ = NSMakeRange([mIndex unsignedIntValue], 1);
		
		m = [L contentsForIndexRange : range_
	 					 composingMask : CMRInvisibleMask
							   compose : NO
						attributesMask : (CMRLocalAbonedMask | CMRSpamMask)];
		if(nil == m)
			continue;
		[contents_ appendAttributedString : m];
	}
	
#if PATCH && 1
	types_ = [NSArray arrayWithObjects : 
		NSRTFPboardType,
		NSStringPboardType,
		nil];
#else
	types_ = [NSArray arrayWithObjects : 
		NSRTFPboardType,
		NSRTFDPboardType,
		NSStringPboardType,
		nil];
#endif
#if 0 // debug
	{
		NSString *t_str;
		t_str = [self string];
		
		NSLog (@"%d, %d", [t_str length], [[t_str componentsSeparatedByString: @"\n"] count]);
	}
#endif
	
	[pboard_ declareTypes : types_
				    owner : nil];

	[contents_ writeToPasteboard : pboard_];
	[contents_ release];
}

#if PATCH
- (void)copy: (id)sender {
#if 1
	NSMutableAttributedString	*contents_;
	NSArray					*types_;
	NSPasteboard *pboard_ = [NSPasteboard generalPasteboard];
	NSRange range;

	range = [self selectedRange];

	types_ = [NSArray arrayWithObjects : 
		NSRTFPboardType,
		nil];
	
	[pboard_ declareTypes: types_ owner: nil];
	contents_ = (NSMutableAttributedString *)[[self textStorage] attributedSubstringFromRange: range];
	//NSLog(@"copy: %@ %d", NSStringFromRange(range), [contents_ length]);	
	[contents_ writeToPasteboard : pboard_];
#elif 1
	NSLog(@"copy: call [super copy]");
	[super copy : sender];
#else
	NSLog(@"copy: call messageCopy:");
	[self messageCopy : sender];
#endif
}
#endif


/* レス */
- (IBAction) messageReply : (id) sender
{
	id				delegate_;
	NSEnumerator	*mIndexEnum_;
	NSNumber		*mIndex;
	NSRange			range_;
	
	mIndexEnum_ = [self representedObjectWithSender : sender];
	mIndex = [mIndexEnum_ nextObject];
	if (nil == mIndex) return;
	
	delegate_ = [self delegate];
	if (nil == delegate_ || NO == [delegate_ respondsToSelector : @selector(threadView:messageReply:)])
		return;
	
	range_ = NSMakeRange([mIndex unsignedIntValue], 1);
	[delegate_ threadView:self messageReply:range_];
}

/* 属性の変更 */
- (CMRThreadMessage *) toggleMessageAttributesAtIndex : (unsigned) anIndex
											senderTag : (int     ) aSenderTag
{
	CMRThreadLayout		*L = [self threadLayout];
	CMRThreadMessage	*m;
	
	if (nil == L || anIndex >= [L numberOfReadedMessages])
		return nil;
	
	m = [L messageAtIndex : anIndex];
	
	switch (aSenderTag) {
	case kLocalAboneTag:
		[m setLocalAboned : ![m isLocalAboned]];
		break;
	case kInvisibleAboneTag:
		[m setInvisibleAboned : ![m isInvisibleAboned]];
		break;
	case kAsciiArtTag:
		[m setAsciiArt : ![m isAsciiArt]];
		break;
	case kBookmarkTag:
		/* 現バージョンでは複数のブックマークは利用しない */
		[m setHasBookmark : ![m hasBookmark]];
		break;
	case kSpamTag:{
		BOOL	isSpam_ = (NO == [m isSpam]);
		// 迷惑レスを手動で設定した場合は
		// フィルタに登録する
		[self messageRegister:m registerFlag:isSpam_];
		[m setSpam : isSpam_];
		break;
	}
	default :
		UTILUnknownSwitchCase(aSenderTag);
		break;
	}
	return m;
}

static void showPoofAnimationForInvisibleAbone(CMRThreadView *tView, unsigned int messageIndex)
{		
	// クリックされたレスの番号から座標を計算（煩雑！）
	// 1.レス番号 mIndex から、このレスの NSRange を取得
	NSRange	range_ = [[[tView threadLayout] messageRanges] rangeAtIndex : messageIndex];
	// 2.この NSRange の領域を取得（NSTextView+CMXAddition.m）
	NSRect	rect_ = [tView boundingRectForCharacterInRange : range_];
	// 3.領域の隅っこの値から NSPoint を作る
	NSPoint	point_ = NSMakePoint(NSMinX(rect_), NSMinY(rect_));
	// 4.NSPoint をスクリーンベースに変換
	point_ = [tView convertPoint : point_ toView : nil];
	point_ = [[tView window] convertBaseToScreen : point_];
	// 5.この関数で poof を発生させる。Tiger でテキストビューの文字がにじむことがある。おそらくバグ（他のアプリでも見られる）。
	NSShowAnimationEffect(NSAnimationEffectDisappearingItemDefault, point_, NSZeroSize, nil, nil, nil);
}

- (IBAction) changeMessageAttributes : (id) sender
{
	NSEnumerator	*mIndexEnum_;
	NSNumber		*mIndex;
	int				actionType = [sender tag];
	
	mIndexEnum_ = [self representedObjectWithSender : sender];

	if (([sender state] == NSOnState) || ![CMRPref showsPoofAnimationOnInvisibleAbone]) {
		while (mIndex = [mIndexEnum_ nextObject]) {
			UTILAssertRespondsTo(mIndex, @selector(unsignedIntValue));

			[self toggleMessageAttributesAtIndex : [mIndex unsignedIntValue]
									   senderTag : actionType];
		}

	} else {

		BOOL	poofDone = NO;

		while (mIndex = [mIndexEnum_ nextObject]) {
			UTILAssertRespondsTo(mIndex, @selector(unsignedIntValue));

			[self toggleMessageAttributesAtIndex : [mIndex unsignedIntValue]
									   senderTag : actionType];

			switch(actionType) {
			case kInvisibleAboneTag:
				if (!poofDone) {
					showPoofAnimationForInvisibleAbone(self, [mIndex unsignedIntValue]);
					poofDone = YES; // 一個 poof 雲を発生させたら、もうやらない
				}
				break;
			case kSpamTag:
				if (([CMRPref spamFilterBehavior] == kSpamFilterInvisibleAbonedBehavior) && (!poofDone)) {
					showPoofAnimationForInvisibleAbone(self, [mIndex unsignedIntValue]);
					poofDone = YES; // 一個 poof 雲を発生させたら、もうやらない
				}
				break;
			default:
				break;
			}

		}
	}
}
@end



@implementation CMRThreadView(Action)
- (IBAction) googleSearch : (id) sender;
{
	NSRange			selectedRange_ = [self selectedRange];
	NSString		*string_;
	id				query_;
	NSMutableString	*tmp;
	
	string_ = [[self string] substringWithRange : selectedRange_];
	string_ = [string_ stringByURLEncodingUsingEncoding : NSUTF8StringEncoding];
	if (nil == string_ || [string_ isEmpty])
		return;
	
	query_ = SGTemplateResource(kPropertyListGoogleQueryKey);
	UTILAssertNotNil(query_);
	
	tmp = SGTemporaryString();
	[tmp setString : query_];
	[tmp replaceCharacters:kGoogleQueryValiableKey toString:string_];
	if (nil == tmp || [tmp isEmpty])
		return;
	
	query_ = [NSURL URLWithString : tmp];
	
	[[NSWorkspace sharedWorkspace] openURL : query_];
	[tmp deleteCharactersInRange : [tmp range]];
}
- (BOOL) setUpMessageActionMenuItem : (NSMenuItem   *) theItem
					     forIndexes : (NSEnumerator *) anIndexEnum
				  withAttributeName : (NSString     *) aName
{
	CMRThreadLayout		*L = [self threadLayout];
	CMRThreadMessage	*m;
	id					v     = nil;
	id					prev  = nil;
	int					state = NSOffState;
	NSNumber			*mIndex;
	
	while (mIndex = [anIndexEnum nextObject]) {
		m = [L messageAtIndex : [mIndex unsignedIntValue]];
		v = [m valueForKey : aName];
		UTILAssertRespondsTo(v, @selector(boolValue));
		
		if (prev != nil) {
			if ([prev boolValue] != [v boolValue]) {
				state = NSMixedState;
				break;
			}
		}
		state = [v boolValue] ? NSOnState : NSOffState;
		prev = v;
	}
	if (nil == prev) return NO;
	
	[theItem setState : state];
	return YES;
}

- (BOOL) validateMenuItem : (NSMenuItem *) theItem
{
	SEL				action_ = [theItem action];
	NSEnumerator	*indexEnum_ = [self selectedMessageIndexEnumerator];
	
	if (@selector(googleSearch:) == action_)
		return ([self selectedRange]).length != 0;
	
	if (@selector(messageCopy:) == action_)
		return ([indexEnum_ nextObject] != nil);
	if (@selector(messageReply:) == action_)
		return ([indexEnum_ nextObject] != nil);
	
	if (@selector(changeMessageAttributes:) == action_) {
		int		tag   = [theItem tag];
		
		if (tag < 0) return NO;
		
		NSAssert1(
			UTILNumberOfCArray(mActionGetKeysForTag) > tag,
			@"[item tag] was invalid(%u)", tag);
		
		return [self setUpMessageActionMenuItem : theItem
								     forIndexes : indexEnum_
					 		  withAttributeName : mActionGetKeysForTag[tag]];
	}
	return [super validateMenuItem : theItem];
}
@end

