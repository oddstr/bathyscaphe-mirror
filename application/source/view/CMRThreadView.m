//
//  CMRThreadView.m
//  BathyScaphe
//
//  Updated by Tsutomu Sawada on 07/09/07.
//  Copyright 2005-2007 BathyScaphe Project. All rights reserved.
//  encoding="UTF-8"
//

#import "CMRThreadView_p.h"
#import "CMXMenuHolder.h"
#import "AppDefaults.h"


static NSString *const kDefaultMenuNibName = @"CMRThreadMenu";
static NSString *const kMessageMenuNibName = @"CMXMessageMenu";

static NSString *mActionGetKeysForTag[] = {
	@"isLocalAboned",		// kLocalAboneTag
	@"isInvisibleAboned",	// kInvisibleAboneTag
	@"isAsciiArt",			// kAsciiArtTag
	@"hasBookmark",			// kBookmarkTag
	@"isSpam",				// kSpamTag
};


@implementation CMRThreadView
- (id)initWithFrame:(NSRect)aFrame textContainer:(NSTextContainer *)aTextContainer
{
	if (self = [super initWithFrame:aFrame textContainer:aTextContainer]) {
		m_lastCharIndex = NSNotFound;

		[self registerForDraggedTypes:[NSArray arrayWithObject:BSThreadItemsPboardType]];
		draggingHilited = NO;
		draggingTimer = 0.0;
	}
	return self;
}

- (void)dealloc
{
	NSUndoManager *undoManager = [[self window] undoManager];
	[undoManager removeAllActions];
	[super dealloc];
}

#pragma mark Drawing
// ライブリサイズ中のレイアウト再計算を抑制する
- (void)viewWillStartLiveResize
{
	[(BSLayoutManager *)[self layoutManager] setTextContainerInLiveResize:YES];
	[super viewWillStartLiveResize];
}

- (void)viewDidEndLiveResize
{
	[(BSLayoutManager *)[self layoutManager] setTextContainerInLiveResize:NO];
	[[self layoutManager] textContainerChangedGeometry:[self textContainer]];
	// Leopard では必要なさそう
	if (!(floor(NSAppKitVersionNumber) > NSAppKitVersionNumber10_4)) {
		[self setNeedsDisplay:YES];
	}
	[super viewDidEndLiveResize];
}
	
- (void)updateRuler
{
	// Ruler の更新をブロックする。
}

- (void)drawRect:(NSRect)rect
{
	[super drawRect:rect];

	if (draggingHilited) {
        [[NSColor selectedTextBackgroundColor] set];
        NSFrameRectWithWidth([self visibleRect], 3.0);
	}
}

- (NSRect)boundingRectForMessageAtIndex:(unsigned)index
{
	NSRange charRange = [[self threadLayout] rangeAtMessageIndex:index];
	return [self boundingRectForCharacterInRange:charRange];
}

#pragma mark Accessors
- (CMRThreadSignature *)threadSignature
{
	id delegate_ = [self delegate];
	if (!delegate_ || ![delegate_ respondsToSelector:@selector(threadSignatureForView:)]) return nil;
	
	return [delegate_ threadSignatureForView:self];
}

- (CMRThreadLayout *)threadLayout
{
	id		delegate_ = [self delegate];
	if (!delegate_ || ![delegate_ respondsToSelector:@selector(threadLayoutForView:)]) return nil;

	return [delegate_ threadLayoutForView:self];
}

- (unsigned int)previousMessageIndexOfCharIndex:(unsigned int)charIndex
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
		v = [storage_ attribute:CMRMessageIndexAttributeName
						atIndex:index_
		  longestEffectiveRange:&effectiveRange_
						inRange:range_];
		if (v) {
			return [v unsignedIntValue];
		}
		if (0 == effectiveRange_.location)
			break;
		
		index_ = effectiveRange_.location -1;
	}
	return NSNotFound;
}

static inline NSEnumerator *indexEnumeratorWithIndexes(NSIndexSet *indexSet)
{
	unsigned int	size = [indexSet lastIndex]+1;
	unsigned int	arrayElement;
	NSRange			e = NSMakeRange(0, size);
	NSMutableArray *array = [NSMutableArray array];
	while ([indexSet getIndexes:&arrayElement maxCount:1 inIndexRange:&e] > 0) {
		[array addObject:[NSNumber numberWithUnsignedInt:arrayElement]];
	}
	return [array objectEnumerator];
}

- (NSIndexSet *)messageIndexesForRange:(NSRange)range_
{
	NSTextStorage	*storage_ = [self textStorage];	

	if (NSNotFound == range_.location || NSMaxRange(range_) > [storage_ length]) {
		return nil;
	}

	NSMutableIndexSet *indexSet = [NSMutableIndexSet indexSet];
	unsigned		charIndex_;
	id				v;
	NSRange			effectiveRange_;

	charIndex_ = range_.location;
	while (charIndex_ < NSMaxRange(range_)) {
		v = [storage_ attribute:CMRMessageIndexAttributeName
						atIndex:charIndex_
		  longestEffectiveRange:&effectiveRange_
						inRange:range_];
		if (v) {
			[indexSet addIndex:[v unsignedIntValue]];
		}
		charIndex_ = NSMaxRange(effectiveRange_);
	}

	unsigned prevMsgIdx = [self previousMessageIndexOfCharIndex:range_.location];
	if (prevMsgIdx != NSNotFound) {
		[indexSet addIndex:prevMsgIdx];
	}

	if ([indexSet count] == 0) {
		return nil;
	} else {
		return indexSet;
	}
}

- (NSIndexSet *)messageIndexesAtClickedPoint
{
	NSRange range_ = NSMakeRange(m_lastCharIndex, 1);
	return [self messageIndexesForRange:range_];
}

/*
 * Available in Twincam Angel.
 * 選択範囲にかかるレスの indexes (これは見かけのレス番号より1小さい値である) を NSIndexSet で返す。
 * 選択範囲がないときは、コンテクストメニューの表示位置にあるレスの index を。
 * このとき、非表示状態のレス index は含まれない。
 */
- (NSIndexSet *)selectedMessageIndexes
{
	NSRange			range_ = [self selectedRange];
	if (range_.length == 0) {
		range_.location = m_lastCharIndex;
		range_.length = 1;
	}
	return [self messageIndexesForRange:range_];
}

#pragma mark Contextual Menu
- (BOOL)mouseClicked:(NSEvent *)theEvent atIndex:(unsigned )charIndex
{
	NSRange	effectiveRange_;
	id		v;
	id		delegate_ = [self delegate];
	SEL		selector_ = @selector(threadView:mouseClicked:atIndex:messageIndex:);
	
	if ([super mouseClicked:theEvent atIndex:charIndex]) return YES;
	
	v = [[self textStorage] attribute:CMRMessageIndexAttributeName atIndex:charIndex effectiveRange:&effectiveRange_];
	if (!v) return NO;
	UTILAssertRespondsTo(v, @selector(unsignedIntValue));
	
	if (delegate_ && [delegate_ respondsToSelector:selector_]) {
		return [delegate_ threadView:self mouseClicked:theEvent atIndex:charIndex messageIndex:[v unsignedIntValue]];
	}
	return NO;
}

static inline void setupMenuItemsRepresentedObject(NSMenu *aMenu, id anObject) 
{
	NSEnumerator		*iter_;
	NSMenuItem			*item_;
	
	iter_ = [[aMenu itemArray] objectEnumerator];
	while (item_ = [iter_ nextObject]) {
		[item_ setRepresentedObject:anObject];
		[item_ setEnabled:YES];
		
		if ([item_ hasSubmenu]) {
			setupMenuItemsRepresentedObject([item_ submenu], anObject);
		}
	}
}

+ (NSMenu *)messageMenu
{
	static NSMenu *kMessageMenu = nil;
	
	if (!kMessageMenu) {
		kMessageMenu = [[CMXMenuHolder menuFromBundle:[NSBundle mainBundle] nibName:kMessageMenuNibName] copy];
	}
	return kMessageMenu;
}

+ (NSMenu *)defaultMenu
{
	static NSMenu *kDefaultMenu_ = nil;

	if (!kDefaultMenu_) {
		kDefaultMenu_ = [[CMXMenuHolder menuFromBundle:[NSBundle mainBundle] nibName:kDefaultMenuNibName] copy];
	}
	return kDefaultMenu_;
}

+ (NSMenuItem *)genericCopyItem
{
	static NSMenuItem *cachedItem = nil;
	if (!cachedItem) {
		NSString *title = NSLocalizedStringFromTable(@"Copy Contextual Menu Item", @"HTMLView", nil);
		cachedItem = [[NSMenuItem alloc] initWithTitle:title action:@selector(copy:) keyEquivalent:@""];
	}
	return cachedItem;
}

+ (NSMenu *)multipleLineSelectionWithinSingleMessageMenu
{
	static NSMenu *kCopyOnlyMenu = nil;
	if (!kCopyOnlyMenu) {
		kCopyOnlyMenu = [[NSMenu alloc] initWithTitle:@""];
		[kCopyOnlyMenu insertItem:[self genericCopyItem] atIndex:0];
	}
	return kCopyOnlyMenu;
}

- (BOOL)containsMultipleLinesInRange:(NSRange)range
{
	NSString *substring = [[self string] substringWithRange:range];
	return ([substring rangeOfString:@"\n" options:NSLiteralSearch].length != 0);
}

- (NSMenuItem *)openLinksMenuItemForRange:(NSRange)range
{
	NSArray *array = [self linksArrayForRange:range];
	if (!array) {
		return nil;
	} else {
		NSString *foo = [NSString stringWithFormat:NSLocalizedStringFromTable(@"Open %u Links", kLocalizableFile, @""), [array count]];
		NSMenuItem *newItem = [[NSMenuItem alloc] initWithTitle:foo action:@selector(openLinksInSelection:) keyEquivalent:@""];
		return [newItem autorelease];
	}
}

- (NSMenuItem *)previewLinksMenuItemForRange:(NSRange)range
{
	if (![[CMRPref sharedImagePreviewer] respondsToSelector:@selector(showImagesWithURLs:)]) {
		return nil;
	}

	NSArray *array = [self previewlinksArrayForRange:range];
	if (!array) {
		return nil;
	} else {
		NSString *foo = [NSString stringWithFormat:NSLocalizedStringFromTable(@"Preview %u Links", kLocalizableFile, @""), [array count]];
		NSMenuItem *newItem = [[NSMenuItem alloc] initWithTitle:foo action:@selector(previewLinksInSelection:) keyEquivalent:@""];
		return [newItem autorelease];
	}
}

- (NSMenu *)menuForEvent:(NSEvent *)theEvent
{
	NSPoint		mouseLocation_;
	BOOL		isMouseEvent_ = YES;
	NSRange		selectedTextRange = [self selectedRange];

	// マウスイベントか
NS_DURING
	[theEvent clickCount];
NS_HANDLER
	isMouseEvent_ = NO;
NS_ENDHANDLER
	
	m_lastCharIndex = NSNotFound;
	if (isMouseEvent_) {
		mouseLocation_ = [theEvent locationInWindow];
		mouseLocation_ = [[self window] convertBaseToScreen:mouseLocation_];
		m_lastCharIndex = [self characterIndexForPoint:mouseLocation_];
	}

	// マウスポインタが選択されたテキストの、その選択領域に入っているなら、選択テキスト用の（簡潔な）コンテキストメニューを返す。
	if (NSLocationInRange(m_lastCharIndex, selectedTextRange)) {
		NSIndexSet	*selectedIndexes = [self selectedMessageIndexes];
		NSMenu		*returningMenu;
		NSMenuItem	*openLinksItem;
		NSMenuItem	*foo;
		UTILAssertNotNil(selectedIndexes);

		if ([selectedIndexes count] == 1) {
			if ([self containsMultipleLinesInRange:selectedTextRange]) {
//				return [[self class] multipleLineSelectionWithinSingleMessageMenu];
				returningMenu = [[self class] multipleLineSelectionWithinSingleMessageMenu];
			} else {
//				return [[self class] defaultMenu];
				returningMenu = [[self class] defaultMenu];
			}
			if (openLinksItem = [self openLinksMenuItemForRange:selectedTextRange]) {
				returningMenu = [[returningMenu copy] autorelease];
				[returningMenu addItem:[NSMenuItem separatorItem]];
				[returningMenu addItem:openLinksItem];
				if (foo = [self previewLinksMenuItemForRange:selectedTextRange]) {
					[returningMenu addItem:foo];
				}
			}
			return returningMenu;
		} else {
			NSMenu *menu = [[self messageMenuWithMessageIndexes:selectedIndexes] copy];
			NSMenuItem *item = [[[self class] genericCopyItem] copy];
			[menu removeItemAtIndex:1];
			[menu removeItemAtIndex:0];
			[menu insertItem:item atIndex:0];
			[item release];
			if (openLinksItem = [self openLinksMenuItemForRange:selectedTextRange]) {
				[menu addItem:[NSMenuItem separatorItem]];
				[menu addItem:openLinksItem];
				if (foo = [self previewLinksMenuItemForRange:selectedTextRange]) {
					[menu addItem:foo];
				}
			}
			return [menu autorelease];
		}
	}

	// そうでなければ、スーパークラスで判断してもらう（see SGHTMLView.m)。
	return [super menuForEvent:theEvent];
}

- (NSMenu *)messageMenuWithMessageIndex:(unsigned)aMessageIndex
{
	return [self messageMenuWithMessageIndexes:[NSIndexSet indexSetWithIndex:aMessageIndex]];
}

- (NSMenu *)messageMenuWithMessageIndexes:(NSIndexSet *)indexes
{	
	NSMenu				*menu_ = [[self class] messageMenu];
	NSMenuItem			*item_;
	unsigned int	size = [indexes lastIndex]+1;
	NSEnumerator	*iter_;
	
	if (size > [[self threadLayout] numberOfReadedMessages]) return nil;
	
	// RepresentedObjectの設定
	setupMenuItemsRepresentedObject(menu_, indexes);
	
	// 状態の設定
	iter_ = [[menu_ itemArray] objectEnumerator];
	while (item_ = [iter_ nextObject]) {
		int				tag   = [item_ tag];
		
		if (tag < 0) continue;
		
		NSAssert1(
			UTILNumberOfCArray(mActionGetKeysForTag) > tag,
			@"[item tag] was invalid(%u)", tag);
		
		[self setUpMessageActionMenuItem:item_
							  forIndexes:indexes
					   withAttributeName:mActionGetKeysForTag[tag]];
	}
	
	return menu_;
}

#pragma mark Message Menu Action
- (NSIndexSet *)representedIndexesWithSender:(id)sender
{
	id	v = [sender representedObject];

	if (!v) {	// 選択されたレス、このあと内容が変更されるかもしれない
		v = [self selectedMessageIndexes];
	} else {	// 通常はこっち (representedObject はしっかりセットしておくべし)
		UTILAssertKindOfClass(v, NSIndexSet);
	}
	return v;
}

// スパムフィルタへの登録
- (void)messageRegister:(CMRThreadMessage *)aMessage registerFlag:(BOOL)flag
{
	id		delegate_ = [self delegate];
	if (!delegate_ || ![delegate_ respondsToSelector:@selector(threadView:spam:messageRegister:)]) return;
	
	[delegate_ threadView:self spam:aMessage messageRegister:flag];
}

#if PATCH
- (void)copy:(id)sender
{
#if 1
	NSMutableAttributedString	*contents_;
	NSArray					*types_;
	NSPasteboard *pboard_ = [NSPasteboard generalPasteboard];
	NSRange range;

	range = [self selectedRange];

	types_ = [NSArray arrayWithObjects:NSRTFPboardType, nil];
	
	[pboard_ declareTypes:types_ owner:nil];
	contents_ = (NSMutableAttributedString *)[[self textStorage] attributedSubstringFromRange:range];
	//NSLog(@"copy: %@ %d", NSStringFromRange(range), [contents_ length]);	
	[contents_ writeToPasteboard:pboard_];
#elif 1
	NSLog(@"copy: call [super copy]");
	[super copy:sender];
#else
	NSLog(@"copy: call messageCopy:");
	[self messageCopy:sender];
#endif
}
#endif

/* 属性の変更 */
- (CMRThreadMessage *)toggleMessageAttributesAtIndex:(unsigned)anIndex senderTag:(int)aSenderTag
{
	CMRThreadLayout		*layout = [self threadLayout];
	CMRThreadMessage	*m;
	NSUndoManager		*um = [[self window] undoManager];
	if (!layout || anIndex >= [layout numberOfReadedMessages]) return nil;
	
	m = [layout messageAtIndex:anIndex];
	
	switch (aSenderTag) {
	case kLocalAboneTag:
		[m setLocalAboned:![m isLocalAboned] undoManager:um];
		break;
	case kInvisibleAboneTag:
		[m setInvisibleAboned:![m isInvisibleAboned] undoManager:um];
		break;
	case kAsciiArtTag:
		[m setAsciiArt:![m isAsciiArt] undoManager:um];
		break;
	case kBookmarkTag:
		/* 現バージョンでは複数のブックマークは利用しない */
		[m setHasBookmark:![m hasBookmark] undoManager:um];
		break;
	case kSpamTag:{
		BOOL	isSpam_ = (NO == [m isSpam]);
		// 迷惑レスを手動で設定した場合は
		// フィルタに登録する
		[self messageRegister:m registerFlag:isSpam_];
		[m setSpam:isSpam_ undoManager:um];
		break;
	}
	default :
		UTILUnknownSwitchCase(aSenderTag);
		break;
	}
	return m;
}
@end


@implementation CMRThreadView(Action)
- (IBAction)openLinksInSelection:(id)sender
{
	NSArray *URLs = [self linksArrayForRange:[self selectedRange]];
	[[NSWorkspace sharedWorkspace] openURLs:URLs inBackground:[CMRPref openInBg]];
}

- (IBAction)previewLinksInSelection:(id)sender
{
	NSArray *URLs = [self previewlinksArrayForRange:[self selectedRange]];
	[[CMRPref sharedImagePreviewer] showImagesWithURLs:URLs];
}

/* レスのコピー */
- (IBAction)messageCopy:(id)sender
{
	NSPasteboard		*pboard_ = [NSPasteboard generalPasteboard];
	NSArray				*types;
	CMRThreadLayout		*layout = [self threadLayout];
	NSAttributedString	*contents;
	NSIndexSet			*indexes;
	id					rep;
	
	if (!layout) return;

	rep = [sender representedObject];
	if (rep && [rep isKindOfClass:[NSIndexSet class]]) {
		indexes = rep;
	} else {
		indexes = [self selectedMessageIndexes];
	}

	contents = [layout contentsForIndexes:indexes composingMask:CMRInvisibleAbonedMask compose:NO attributesMask:(CMRLocalAbonedMask|CMRSpamMask)];
	if (!contents) return; 
	
#if PATCH && 1
	types = [NSArray arrayWithObjects:NSRTFPboardType, NSStringPboardType, nil];
#else
	types = [NSArray arrayWithObjects:NSRTFPboardType, NSRTFDPboardType, NSStringPboardType, nil];
#endif
#if 0 // debug
	{
		NSString *t_str;
		t_str = [self string];
		
		NSLog (@"%d, %d", [t_str length], [[t_str componentsSeparatedByString:@"\n"] count]);
	}
#endif
	
	[pboard_ declareTypes:types owner:nil];

	[contents writeToPasteboard:pboard_];
}

/* レスに返信 */
- (IBAction)messageReply:(id)sender
{
	id				delegate_ = [self delegate];
	if (!delegate_ || ![delegate_ respondsToSelector:@selector(threadView:messageReply:)]) return;

	NSIndexSet		*mIndexes;
	NSRange			range_;
	
	mIndexes = [self representedIndexesWithSender:sender];
	if (!mIndexes) return;
	
	range_ = NSMakeRange([mIndexes firstIndex], 1);
	[delegate_ threadView:self messageReply:range_];
}

- (NSPoint)pointForIndex:(unsigned int)messageIndex
{
	NSRange	range = [[self threadLayout] rangeAtMessageIndex:messageIndex];
	NSRect	rect = [self boundingRectForCharacterInRange:range];
	NSPoint	point = NSMakePoint(NSMidX(rect), NSMidY(rect));
	point = [self convertPoint:point toView:nil];
	point = [[self window] convertBaseToScreen:point];
	return point;
}

static BOOL shouldPoof(int state, int actionType)
{
	if (state == NSOnState) return NO;
	if (![CMRPref showsPoofAnimationOnInvisibleAbone]) return NO;

	if (actionType == kInvisibleAboneTag) return YES;
	if (actionType == kSpamTag && [CMRPref spamFilterBehavior] == kSpamFilterInvisibleAbonedBehavior) return YES;

	return NO;
}

- (IBAction)changeMessageAttributes:(id)sender
{
	NSEnumerator	*mIndexEnum_;
	NSNumber		*mIndex;
	unsigned int	firstIndex;
	int				actionType = [sender tag];
	NSIndexSet		*mIndexes = [self representedIndexesWithSender:sender];

	if (!mIndexes) return;
//	mIndexEnum_ = [self representedIndexEnumeratorWithSender:sender];
	firstIndex = [mIndexes firstIndex];
	mIndexEnum_ = indexEnumeratorWithIndexes(mIndexes);

	if (shouldPoof([sender state], actionType)) {
		NSShowAnimationEffect(NSAnimationEffectDisappearingItemDefault, [self pointForIndex:firstIndex], NSMakeSize(128,128), nil, NULL, nil);
	}

	while (mIndex = [mIndexEnum_ nextObject]) {
		[self toggleMessageAttributesAtIndex:[mIndex unsignedIntValue] senderTag:actionType];
	}
}

- (IBAction)messageGyakuSansyouPopUp:(id)sender
{
	id				delegate_ = [self delegate];
	if (!delegate_ || ![delegate_ respondsToSelector:@selector(threadView:reverseAnchorPopUp:locationHint:)]) return;

	NSIndexSet		*mIndexes;
	mIndexes = [self representedIndexesWithSender:sender];
	if (!mIndexes) return;

	unsigned int mIndexNum = [mIndexes firstIndex];
	NSRect  rect_ = [self boundingRectForMessageAtIndex:mIndexNum];
	NSPoint	point_ = NSMakePoint(NSMinX(rect_), NSMinY(rect_));

	point_ = [self convertPoint:point_ toView:nil];
	point_ = [[self window] convertBaseToScreen:point_];
	
	[delegate_ threadView:self reverseAnchorPopUp:mIndexNum locationHint:point_];
}

#pragma mark Google, Wikipedia
- (NSString *)selectedSubstringWithURLEncoded
{
	NSString *string;
	NSString *encodedString;

	string = [[self string] substringWithRange:[self selectedRange]];
	encodedString = [string stringByURLEncodingUsingEncoding:NSUTF8StringEncoding];

	if (!encodedString || [encodedString isEqualToString:@""]) return nil;
	return encodedString;
}

- (void)openURLWithQueryTemplateForKey:(NSString *)key
{
	NSString *string;
	id	query;
	NSMutableString *urlBase;

	string = [self selectedSubstringWithURLEncoded];
	if (!string) return;

	query = SGTemplateResource(key);
	UTILAssertNotNil(query);

	urlBase = [NSMutableString stringWithString:query];
	[urlBase replaceCharacters:kQueryValiableKey toString:string];

	[[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:urlBase]];
}

- (IBAction)openWithWikipedia:(id)sender
{
	[self openURLWithQueryTemplateForKey:kPropertyListWikipediaQueryKey];
}

- (IBAction)googleSearch:(id)sender
{
	[self openURLWithQueryTemplateForKey:kPropertyListGoogleQueryKey];
}

#pragma mark Menu Validation
- (BOOL)setUpMessageActionMenuItem:(NSMenuItem *)theItem forIndexes:(NSIndexSet *)indexSet withAttributeName:(NSString *)aName
{
	NSEnumerator		*anIndexEnum = indexEnumeratorWithIndexes(indexSet);
	CMRThreadLayout		*L = [self threadLayout];
	CMRThreadMessage	*m;
	id					v     = nil;
	id					prev  = nil;
	int					state = NSOffState;
	NSNumber			*mIndex;

	while (mIndex = [anIndexEnum nextObject]) {
		m = [L messageAtIndex:[mIndex unsignedIntValue]];
		v = [m valueForKey:aName];
		UTILAssertRespondsTo(v, @selector(boolValue));
		
		if (prev && ([prev boolValue] != [v boolValue])) {
			state = NSMixedState;
			break;
		}

		state = [v boolValue] ? NSOnState : NSOffState;
		prev = v;
	}
	if (!prev) return NO;

	[theItem setState:state];
	return YES;
}

- (BOOL)validateMenuItem:(NSMenuItem *)theItem
{
	SEL				action_ = [theItem action];
	
	if (action_ == @selector(googleSearch:) || action_ == @selector(openWithWikipedia:)) {
		return ([self selectedRange].length > 0);
	}

	NSIndexSet		*indexSet = [self messageIndexesAtClickedPoint];
	[theItem setRepresentedObject:indexSet];

	if (action_ == @selector(messageReply:) || action_ == @selector(messageGyakuSansyouPopUp:) || action_ == @selector(messageCopy:)) {
		return (indexSet != nil);
	}

	if (action_ == @selector(changeMessageAttributes:)) {
		int		tag   = [theItem tag];
		NSAssert1(UTILNumberOfCArray(mActionGetKeysForTag) > tag, @"[item tag] was invalid(%u)", tag);
		
		return [self setUpMessageActionMenuItem:theItem forIndexes:indexSet withAttributeName:mActionGetKeysForTag[tag]];
	}

	return [super validateMenuItem:theItem];
}
@end

// サービスメニュー経由でテキストを渡す場合のクラッシュを解決
// 341@CocoMonar 24(25)th thread の修正をベースに
// さらに独自の味付け
@implementation CMRThreadView(NSServicesRequests)
- (BOOL)writeSelectionToPasteboard:(NSPasteboard *)pboard types:(NSArray *)types
{
	NSAttributedString	*contents_;

	// 元々渡される types には NSRTFDPboardType が含まれる。しかしこれが受け渡し時に問題を引き起こすようだ
	NSArray *newTypes = [NSArray arrayWithObjects:NSRTFPboardType, NSStringPboardType, nil]; // NSRTFDPboardType を含まない別の array にすり替える
	[pboard declareTypes:newTypes owner:nil];

	contents_ = [[self textStorage] attributedSubstringFromRange:[self selectedRange]];

	[contents_ writeToPasteboard:pboard];
	return YES;
}
@end
