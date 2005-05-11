/**
  * $Id: CMRThreadView.m,v 1.1 2005/05/11 17:51:08 tsawada2 Exp $
  * 
  * CMRThreadView.m
  *
  * Copyright (c) 2003-2004 Takanori Ishikawa, All rights reserved.
  * See the file LICENSE for copying permission.
  */
#import "CMRThreadView_p.h"
#import "CMXMenuHolder.h"

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

/*
2004-03-15 Takanori Ishikawa <takanori@gd5.so-net.ne.jp>
----------------------------------------
���X�ԍ��w��t�B�[���h�Ƀt�H�[�J�X�������ԂŃX�N���[�������
���̃t�H�[�J�X�E�����O����ʏ�ɃS�~�Ƃ��Ďc���Ă��܂��B
NSClipView �� NSViewBoundsDidChangeNotification ���󂯎����
������ View �S�̂� setKeyboardFocusRingNeedsDisplayInRect
���Ă��������A�p�t�H�[�}���X���҂����߂����őΉ�����B
----------------------------------------
*/
//
// contentViewBoudnsDidChange:
// invalidate focus ring in the bottom area of textView
//

#define FOCUS_RING_AREA_HEIGHT	5.0f
- (NSRect) adjustScroll : (NSRect) proposedVisibleRect
{
	// ----------------------------------------
	// Remove indexField's focus ring on textView
	// ----------------------------------------
	NSRect	focusRect = [self visibleRect];
	
	// Calc Focus-ring rect
	if ([self isFlipped]) {
		focusRect.origin.y += focusRect.size.height;
		focusRect.origin.y -= FOCUS_RING_AREA_HEIGHT;
	}
	focusRect.size.height = FOCUS_RING_AREA_HEIGHT;
	
	// Intersection Rect of Focus-ring rect and proposedVisibleRect
	focusRect = NSIntersectionRect(focusRect, proposedVisibleRect);
	
	if (NSHeight(focusRect) > 0)
		[self setKeyboardFocusRingNeedsDisplayInRect:focusRect];
	
	return proposedVisibleRect;
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
	// �R���e�L�X�g�E���j���[��\�������ꍇ�͕\���ʒu��
	// �C���f�b�N�X
	if (0 == selectedRange_.length) {
		selectedRange_.location = _lastCharIndex;
		selectedRange_.length = 1;
	}
	if (NSNotFound == selectedRange_.location ||
		NSMaxRange(selectedRange_) > [[self textStorage] length]) 
	{ return [[NSArray empty] objectEnumerator]; }
	
	// �I��͈͂̂ЂƂ܂��̃��X���܂�
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
	
	// �}�E�X�C�x���g��
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
	
	// �}�E�X�|�C���^���I�����ꂽ�e�L�X�g�́A���̑I��̈�ɓ����Ă���Ȃ�A�I���e�L�X�g�p�̃R���e�L�X�g���j���[��Ԃ��B
	//if(NSPointInRect (mouseLocation2_, [self boundingRectForCharacterInRange : [self selectedRange]]))
	//		return [[self class] defaultMenu];
	
	// �����łȂ���΁A�X�[�p�[�N���X�Ŕ��f���Ă��炤�isee SGHTMLView.m)�B
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
	// RepresentedObject�̐ݒ�
	[[self class] setupMenuItemInMenu : menu_
			representedObject : rep];
	
	// ��Ԃ̐ݒ�
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
	if (nil == v) {		// �I�����ꂽ���X
		
		// ���̂��Ɠ��e���ύX����邩������Ȃ�
		v = [self selectedMessageIndexEnumerator];
		v = [v allObjects];
		v = [v objectEnumerator];
	} else {
		UTILAssertRespondsTo(v, @selector(rangeValue));
		v = [self indexEnumeratorWithIndexRange : [v rangeValue]];
	}
	return v;
}

// �X�p���t�B���^�ւ̓o�^
- (void) messageRegister : (CMRThreadMessage *) aMessage
			registerFlag : (BOOL			  ) flag
{
	id		delegate_;
	
	delegate_ = [self delegate];
	if (nil == delegate_ || NO == [delegate_ respondsToSelector : @selector(threadView:spam:messageRegister:)])
		return;
	
	[delegate_ threadView:self spam:aMessage messageRegister:flag];
}


/* �X���R�s�[ */
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
	contents_ = [[self textStorage] attributedSubstringFromRange: range];
	NSLog(@"copy: %@ %d", NSStringFromRange(range), [contents_ length]);	
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


/* ���X */
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

/* �����̕ύX */
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
		/* ���o�[�W�����ł͕����̃u�b�N�}�[�N�͗��p���Ȃ� */
		[m setHasBookmark : ![m hasBookmark]];
		break;
	case kSpamTag:{
		BOOL	isSpam_ = (NO == [m isSpam]);
		// ���f���X���蓮�Őݒ肵���ꍇ��
		// �t�B���^�ɓo�^����
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
- (IBAction) changeMessageAttributes : (id) sender
{
	NSEnumerator	*mIndexEnum_;
	NSNumber		*mIndex;
	
	mIndexEnum_ = [self representedObjectWithSender : sender];
	while (mIndex = [mIndexEnum_ nextObject]) {
		UTILAssertRespondsTo(mIndex, @selector(unsignedIntValue));
		
		[self toggleMessageAttributesAtIndex : [mIndex unsignedIntValue]
								   senderTag : [sender tag]];
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

