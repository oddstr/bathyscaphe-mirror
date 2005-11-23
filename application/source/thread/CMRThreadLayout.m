//: CMRThreadLayout.m
/**
  * $Id: CMRThreadLayout.m,v 1.7 2005/11/23 13:44:07 tsawada2 Exp $
  * 
  * CMRThreadLayout.m
  *
  * @see CMRThreadMessage.h
  * @see CMRThreadMessageBuffer.h
  *
  * Copyright (c) 2003, Takanori Ishikawa.
  * See the file LICENSE for copying permission.
  */
#import "CMRThreadLayout_p.h"
#import "NSTextView+CMXAdditions.h"
#import "CMRMessageAttributesStyling.h"
#import "CMRMessageAttributesTemplate_p.h"
#import "CMRAttributedMessageComposer.h"

// for debugging only
#define UTIL_DEBUGGING		0
#import "UTILDebugging.h"



@implementation CMRThreadLayout
- (id) initWithTextView : (NSTextView *) aTextView
{
	UTILAssertKindOfClass(aTextView, CMRThreadView);
	if (self = [self init]) {
		[self setTextView : (CMRThreadView*)aTextView];
	}
	return self;
}
- (id) init
{
	if (self = [super init]) {
		_worker = [[CMXWorkerContext alloc] 
					initWithUsingDrawingThread : YES];
		_messagesLock = [[NSLock alloc] init];
		
		// initialize local buffers
		_messageRanges = [[SGBaseRangeArray alloc] init];
		_messageBuffer = [[CMRThreadMessageBuffer alloc] init];
		
		[[NSNotificationCenter defaultCenter] addObserver : self
			selector : @selector(threadMessageDidChangeAttribute:)
			name : CMRThreadMessageDidChangeAttributeNotification
			object : nil];
	}
	return self;
}

- (void) dealloc
{
	UTIL_DEBUG_METHOD;
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	// ���[�J�[�X���b�h�̏I��
	[_worker shutdown : self];
	[_worker autorelease];
	
	[_textView release];
	[_messagesLock release];
	[_messageRanges release];
	[_messageBuffer release];
	
	[super dealloc];
}

- (BOOL) isMessagesEdited { return _isMessagesEdited; }
- (void) setMessagesEdited : (BOOL) flag { _isMessagesEdited = flag; }

- (void) run
{
	[_worker run];
}
- (void) doDeleteAllMessages
{
	NSTextStorage		*contents_;
	unsigned			length_;
	
	contents_ = [self textStorage];
	
	// --------- Delete All Contents ---------
	length_ = [contents_ length];
	if (length_ > 0) {
		NSRange			contentRng_;
		
		contentRng_ = NSMakeRange(0, length_);
		[contents_ beginEditing];
		[contents_ deleteCharactersInRange: contentRng_];
		[contents_ endEditing];
	}
	
	// --------- Delete Message Ranges ---------
	[_messagesLock lock];
	[[self messageRanges] removeAll];
	[[self messageBuffer] removeAll];
	[_messagesLock unlock];
	
	[self setMessagesEdited : NO];
}


- (BOOL) isInProgress
{
	return  [_worker isInProgress];
}
- (void) clear
{
	[_worker removeAll : self];
	[self push : [[[CMRThreadClearTask alloc] init] autorelease]];
}
- (void) disposeLayoutContext
{
	UTIL_DEBUG_METHOD;
	
	[self clear];
	[_worker shutdown : self];
	
/*
	in the case of ThreadViewer: this method will be invoked when window closing,
	document removing, threadViewer closing. but that time, TextView may be
	activate, so we remove it's layout manager from contents.
*/	
	[[[self layoutManager] retain] autorelease];
	[[self textStorage] removeLayoutManager : [self layoutManager]];
	
	[self doDeleteAllMessages];
}


- (void) push : (id<CMRThreadLayoutTask>) aTask
{
	UTILAssertNotNilArgument(aTask, @"task");
	[(id)aTask setLayout : self];
	[_worker push : aTask];
}

@end



@implementation CMRThreadLayout(Accessor)
- (CMRThreadView *) textView
{
	return _textView;
}
- (void) setTextView : (CMRThreadView *) aTextView
{
	id		tmp;
	
	tmp = _textView;
	_textView = [aTextView retain];
	[tmp release];
}
- (NSLayoutManager *) layoutManager
{
	return [[self textView] layoutManager];
}
- (NSTextContainer *) textContainer
{
	return [[self textView] textContainer];
}
- (NSTextStorage *) textStorage
{
	return [[self textView] textStorage];
}
- (NSScrollView *) scrollView
{
	return [[self textView] enclosingScrollView];
}

- (SGInternalMessenger *) runLoopMessenger
{
	return CMRMainMessenger;
}

- (CMRThreadMessage *) messageAtIndex : (unsigned) anIndex
{
	return [[self messageBuffer] messageAtIndex : anIndex];
}

- (void) threadMessageDidChangeAttribute : (NSNotification *) theNotification
{
	CMRThreadMessage	*m;
	unsigned			mIndex;
	
	UTILAssertNotificationName(
		theNotification,
		CMRThreadMessageDidChangeAttributeNotification);
	
	m = [theNotification object];
	if ((mIndex = [[self messageBuffer] indexOfMessage : m]) != NSNotFound) {
		[self updateMessageAtIndex : mIndex];
		// 2005-09-09 tsawada2 �l�q�����iTiger �`�旐��΍�j
		[[self scrollView] setNeedsDisplay: YES];
	}
}

- (void) wakeUpLayoutManagerWithRange : (NSRange) aRange
{
	NSRect			glyphRect_;
	NSRect			visibleRect_;
	NSPoint			newOrigin_;
	id				textView_;
	NSClipView		*clipview_;
	
	if (NSNotFound == aRange.location || 0 == aRange.length) {
		//In case of invisible abone, etc.
		//NSBeep();
		[[self textView] setNeedsDisplay : YES];
		return;
	}
	
	textView_ = [self textView];
	glyphRect_ = [textView_ boundingRectForCharacterInRange : aRange];
	if (NSEqualRects(NSZeroRect, glyphRect_)) return;
	
	
	clipview_ = [[self scrollView] contentView];
	newOrigin_ = [textView_ bounds].origin;
	newOrigin_.y = glyphRect_.origin.y;
	
	visibleRect_ = [clipview_ documentVisibleRect];
	visibleRect_.origin = newOrigin_;
	
	// LayoutManager �Ƀn�b�p��������B
	// ���ꂪ�����Ă���̂��ǂ����c�H�Ƃɂ����A�Ǐ�͊ɘa�����悤�����B
	[[textView_ layoutManager]
		glyphRangeForBoundingRect : visibleRect_
				  inTextContainer : [textView_ textContainer]];
	
}

- (void) updateMessageAtIndex : (unsigned) anIndex
{
	NSMutableAttributedString		*textBuffer_;
	CMRAttributedMessageComposer	*composer_;
	CMRThreadMessage				*m;
	NSRange							mesRange_;
	int								changeInLength_ = 0;
	
	if (NSNotFound == anIndex || [self firstUnlaidMessageIndex] <= anIndex)
		return;
	[_messagesLock lock];
	do {
		m = [[self messageBuffer] messageAtIndex : anIndex];
		mesRange_ = [[self messageRanges] rangeAtIndex : anIndex];
		// ��\���̃��X�͐������Ȃ�
		if (NO == [m isVisible]) {
			if (mesRange_.length != 0) {
				changeInLength_ = -(mesRange_.length);
				[[self textStorage] deleteCharactersInRange : mesRange_];
			}
			break;
		}
		
		composer_ = [[CMRAttributedMessageComposer alloc] init];
		textBuffer_ = [[NSMutableAttributedString alloc] init];
		
		[composer_ setComposingMask:CMRInvisibleMask compose:NO];
		[composer_ setContentsStorage : textBuffer_];
		
		[composer_ composeThreadMessage : m];
		changeInLength_ = [textBuffer_ length] - mesRange_.length;
		[[self textStorage] replaceCharactersInRange : mesRange_
								withAttributedString : textBuffer_];
		
		[textBuffer_ release];
		[composer_ release];
		textBuffer_ = nil;
		composer_ = nil;
	} while (0);
	[_messagesLock unlock];
	
	if (changeInLength_ != 0) {
		mesRange_.length += changeInLength_;
		[self slideMessageRanges : changeInLength_
					fromLocation : mesRange_.location +1];
		[[self messageRanges] setRange:mesRange_ atIndex:anIndex];
		//2005-09-20 Tiger �������΍�i��T��l�q�����j
	}
		[self wakeUpLayoutManagerWithRange : mesRange_]; // 2005-11-09 �����Ɉڂ��ichangeInLength_ == 0�̂Ƃ������s������AAA�w��΍�j
	[self setMessagesEdited : YES];
}
- (void) changeAllMessageAttributes : (BOOL  ) onOffFlag
							  flags : (UInt32) mask
{
	[[self messageBuffer] changeAllMessageAttributes:onOffFlag flags:mask];
}
- (unsigned) numberOfMessageAttributes : (UInt32) mask
{
	NSEnumerator		*iter_;
	CMRThreadMessage	*m;
	unsigned			count_ = 0;
	
	iter_ = [self messageEnumerator];
	while (m = [iter_ nextObject]) {
		if (mask & [m flags])
			count_++;
	}
	return count_;
}


- (SGBaseRangeArray *) messageRanges
{
	return _messageRanges;
}
- (void) addMessageRange : (NSRange) range
{
	[_messagesLock lock];
	[[self messageRanges] append : range];
	[_messagesLock unlock];
}
- (void) slideMessageRanges : (int     ) changeInLength
			   fromLocation : (unsigned) fromLocation
{
	SGBaseRangeEnumerator	*iter_;
	unsigned				index_ = 0;
	NSRange					mesRange_;
	
	iter_ = [[self messageRanges] enumerator];
	while ([iter_ hasNext]) {
		mesRange_ = [iter_ next];
		
		if (mesRange_.location >= fromLocation) {
			mesRange_.location += changeInLength;
			// 
			// SGBaseRangeEnumerator�͑������ɗv�f��
			// �ύX���Ă����S�Ȃ��ƂɈˑ�
			// 
			[[self messageRanges] setRange:mesRange_ atIndex:index_];
		}
		index_++;
	}
}

- (CMRThreadMessageBuffer *) messageBuffer
{
	return _messageBuffer;
}
- (NSEnumerator *) messageEnumerator
{
	return [[[self messageBuffer] messages] objectEnumerator];
}
- (void) addMessagesFromBuffer : (CMRThreadMessageBuffer *) otherBuffer;
{
	NSEnumerator		*iter_;
	CMRThreadMessage	*m;
	
	if (nil == otherBuffer)
		return;
	
	[_messagesLock lock];
	[[self messageBuffer] addMessagesFromBuffer : otherBuffer];
	
	iter_ = [[otherBuffer messages] objectEnumerator];
	while (m = [iter_ nextObject]) {
		[m setPostsAttributeChangedNotifications : YES];
	}
	
	[_messagesLock unlock];
}
@end



@implementation CMRThreadLayout(DocuemntVisibleRect)
- (unsigned int) messageIndexForDocuemntVisibleRect
{
	NSRange visibleRange_;
	
	visibleRange_ = [[self textView] characterRangeForDocumentVisibleRect];
	
	// �e���X�̍Ō�ɂ͋�s���܂܂�邽�߁A�\������Ă���͈͂�
	// ���̂܂ܓn���ƌ����ڂƂ��ꗂ��C�ɂȂ�B
	// ����āA�ʒu�����s�ЂƂ����炷�B
	
	if (visibleRange_.length > 1) {
	  visibleRange_.location += 1;
	  visibleRange_.length -= 1;	//�͈̓`�F�b�N���Ȃ��ȕւ̂���
	}
	
	return [self messageIndexForRange : visibleRange_];
}

- (void) scrollMessageWithRange : (NSRange) aRange
{
	NSRect			glyphRect_;
	NSRect			visibleRect_;
	NSPoint			newOrigin_;
	NSClipView		*clipview_;
	
	if (NSNotFound == aRange.location || 0 == aRange.length) {
		NSBeep();
		return;
	}
	
	glyphRect_ = [[self textView] boundingRectForCharacterInRange : aRange];
	if (NSEqualRects(NSZeroRect, glyphRect_)) return;
	
	
	clipview_ = [[self scrollView] contentView];
	newOrigin_ = [[self textView] bounds].origin;
	newOrigin_.y = glyphRect_.origin.y;
	
	visibleRect_ = [clipview_ documentVisibleRect];
	visibleRect_.origin = newOrigin_;
	
	// �\���\��̈�(visibleRect_)��Glyph���܂����C�A�E�g����Ă��Ȃ���΁A
	// �����A���C�A�E�g������B
	[[[self textView] layoutManager]
		glyphRangeForBoundingRect : visibleRect_
				  inTextContainer : [[self textView] textContainer]];
	
	// ----------------------------------------
	// Simulate user scroll
	// ----------------------------------------
	visibleRect_ = [[clipview_ documentView] adjustScroll : visibleRect_];
	[clipview_ scrollToPoint : visibleRect_.origin];
	[[self scrollView] reflectScrolledClipView : clipview_];
	
	[[self textView] setSelectedRange : NSMakeRange(aRange.location, 0)];
}
- (IBAction) scrollToLastUpdatedIndex : (id) sender
{
	[self scrollMessageWithRange : [self firstLastUpdatedHeaderAttachmentRange]];
}
- (void) scrollMessageAtIndex : (unsigned) anIndex
{
	UTIL_DEBUG_WRITE2(@"scrollMessageAtIndex:%u firstUnlaidMessageIndex:%u",
		anIndex, [self firstUnlaidMessageIndex]);
	
	if (NSNotFound == anIndex || [self firstUnlaidMessageIndex] <= anIndex)
		return;
	
	[self ensureMessageToBeVisibleAtIndex : anIndex];
	[self scrollMessageWithRange : 
		[[self messageRanges] rangeAtIndex : anIndex]];
}

- (void) dummyScroll : (id) sender
{
	NSClipView	*clipview_;

	clipview_ = [[self scrollView] contentView];
	[clipview_ scrollToPoint : NSMakePoint(0, 0.01)];
}

@end



@implementation CMRThreadLayout(Attachment)
/* Message Proxy */
- (void) removeEllipsisProxyAttachments
{
	NSTextStorage		*text_ = [self textStorage];
	NSRange				inRange_;
	NSRange				proxyRange_;
	id					value_ = nil;
	
	inRange_ = [text_ range];
	while (inRange_.length != 0) {
		value_ = [text_ attribute : CMRMessageProxyAttributeName
						  atIndex : inRange_.location
			longestEffectiveRange : &proxyRange_
						  inRange : inRange_];
		
/*
		UTILDescription(value_);
		UTILDescRange(inRange_);
		UTILDescRange(proxyRange_);
*/
		inRange_.location = NSMaxRange(proxyRange_);
		if (value_ != nil) {
			[self slideMessageRanges : -(proxyRange_.length)
						fromLocation : inRange_.location];
			[text_ deleteCharactersInRange : proxyRange_];
			inRange_.location = proxyRange_.location;
		}
		
		inRange_.length = [text_ length] - inRange_.location;
	}
}
- (void) insertEllipsisProxyAttachment:(NSMutableAttributedString*) aBuffer atIndex:(unsigned) charIndex fromIndex:(unsigned) fromIndex toIndex:(unsigned) toIndex
{
	id	templateMgr = [CMRMessageAttributesTemplate sharedTemplate];
	NSMutableAttributedString *tmp = SGTemporaryAttributedString();
	
	NSTextAttachment	*proxy_;
	NSRange				mRange;
	id					rep;
	
	NSAssert2(
		fromIndex <= toIndex,
		@"fromIndex(%u) <= toIndex(%u)",
		fromIndex, toIndex);
	
	/* ellipsisProxyAttachment */
	proxy_ = [templateMgr ellipsisProxyAttachment];
	UTILAssertNotNil(proxy_);
	mRange = NSMakeRange(fromIndex, toIndex - fromIndex +1);
	rep = [NSValue valueWithRange : mRange];
	[(NSCell*)[proxy_ attachmentCell] setRepresentedObject : rep];
	
	[tmp appendAttributedString : 
		[NSAttributedString attributedStringWithAttachment : proxy_]];
	
	/* ellipsisUpProxyAttachment */
	proxy_ = [templateMgr ellipsisUpProxyAttachment];
	UTILAssertNotNil(proxy_);
	
	// ������̏ꍇ�� location = NSNotFound
	mRange = NSMakeRange(NSNotFound, toIndex);
	rep = [NSValue valueWithRange : mRange];
	[(NSCell*)[proxy_ attachmentCell] setRepresentedObject : rep];
	[tmp appendAttributedString : 
		[NSAttributedString attributedStringWithAttachment : proxy_]];
	
	/* ellipsisDownProxyAttachment */
	proxy_ = [templateMgr ellipsisDownProxyAttachment];
	UTILAssertNotNil(proxy_);
	// �������̏ꍇ�� length = NSNotFound
	mRange = NSMakeRange(fromIndex, NSNotFound);
	rep = [NSValue valueWithRange : mRange];
	[(NSCell*)[proxy_ attachmentCell] setRepresentedObject : rep];
	[tmp appendAttributedString : 
		[NSAttributedString attributedStringWithAttachment : proxy_]];
	
	// ���s
	[tmp appendString : @"\n"
	   withAttributes : [NSDictionary empty]];
	   
	// �㉺�̗]���iSledgeHammer and Later�j
	[tmp addAttributes : [NSDictionary dictionaryWithObject : 
								[templateMgr indexParagraphStyleWithSpacingBefore : [CMRPref msgIdxSpacingBefore]
																  andSpacingAfter : 0.0]
													 forKey : NSParagraphStyleAttributeName]
						range : NSMakeRange(0,[tmp length])];
	
	// �}��
	[aBuffer beginEditing];
	{
		mRange.location = [aBuffer length];
		if (charIndex == [aBuffer length]) {
			[aBuffer appendAttributedString:tmp];
		} else {
			[aBuffer insertAttributedString:tmp atIndex:charIndex];
		}
		mRange.length = [aBuffer length] - mRange.location;
		mRange.location = charIndex;
		[aBuffer addAttribute : CMRMessageProxyAttributeName
						value : @"Ellipsis"
						range : mRange];
	}
	[aBuffer endEditing];
	[tmp deleteCharactersInRange:[tmp range]];
}
- (void) insertEllipsisProxyAttachmentFrom:(unsigned) fromIndex toIndex:(unsigned) toIndex
{
	unsigned			charIndex;
	int					changeInLength_;
	
	charIndex = ([[self messageRanges] rangeAtIndex : fromIndex]).location;
	changeInLength_ = [[self textStorage] length];
	[self insertEllipsisProxyAttachment:[self textStorage] atIndex:charIndex fromIndex:fromIndex toIndex:toIndex];
	changeInLength_ = [[self textStorage] length] - changeInLength_;
	
	[self slideMessageRanges : changeInLength_
				fromLocation : charIndex];
}
- (void) fixEllipsisProxyAttachment 
{
	CMRThreadMessage	*m;
	int					i, cnt;
	unsigned			startIndex = NSNotFound;
	
	[self removeEllipsisProxyAttachments];
	cnt = [self numberOfReadedMessages];
	
	for (i = 0; i <= cnt; i++) {
		m = (i < cnt) ? [[self messageBuffer] messageAtIndex : i] : nil;
		if (m && [m isTemporaryInvisible]) {
			if (NSNotFound == startIndex) {
				startIndex = i;
			}
			continue;
		}
		
		if (startIndex != NSNotFound)
			[self insertEllipsisProxyAttachmentFrom:startIndex toIndex:i-1];
		
		startIndex = NSNotFound;
	}
}
- (void) textView : (NSTextView              *) aTextView 
    clickedOnCell : (id <NSTextAttachmentCell>) cell
           inRect : (NSRect                   ) cellFrame
          atIndex : (unsigned                 ) charIndex
{
	id			v;
	NSRange		mIndexRange;
	
	UTIL_DEBUG_WRITE1(@"Layout:textView:clickedOnCell at(%u)", charIndex);
	if (NO == [cell respondsToSelector : @selector(representedObject)]) 
		return;
	
	UTIL_DEBUG_WRITE(@"  EllipsisCell");
	v = [(NSCell*)cell representedObject];
	if (nil == v) return;
	UTIL_DEBUG_WRITE(@"  cell has representedObject");
	
	UTILAssertRespondsTo(v, @selector(rangeValue));
	mIndexRange = [v rangeValue];
	UTIL_DEBUG_WRITE1(@"  mIndexRange = %@", NSStringFromRange(mIndexRange));
	
	if (NSNotFound == mIndexRange.location) {
		// �����
		UTIL_DEBUG_WRITE(@"  Show Ellipsis Up");
		[self scrollMessageAtIndex : mIndexRange.length];
	} else if (NSNotFound == mIndexRange.length) {
		// ������
		UTIL_DEBUG_WRITE(@"  Show Ellipsis Down");
		[self ensureMessageToBeVisibleAtIndex : mIndexRange.location];
	} else {
		// ���ׂ�
		UTIL_DEBUG_WRITE(@"  Show All Ellipsis");
		[self ensureMessageToBeVisibleAtIndex : mIndexRange.location
							   effectsLongest : YES];
	}
}

/* lastUpdated Header */
- (NSDate *) lastUpdatedDateFromHeaderAttachment
{
	return [self lastUpdatedDateFromFirstHeaderAttachmentEffectiveRange : NULL]; 
}
- (NSRange) firstLastUpdatedHeaderAttachmentRange
{
	NSRange		effectiveRange_;
	
	[self lastUpdatedDateFromFirstHeaderAttachmentEffectiveRange : &effectiveRange_];
	return effectiveRange_;
}
- (NSDate *) lastUpdatedDateFromFirstHeaderAttachmentEffectiveRange : (NSRangePointer) effectiveRange
{
	NSTextStorage		*content_    = [self textStorage];
	unsigned			charIndex_;
	unsigned			toIndex_;
	NSRange				charRng_;
	NSRange				range_;
	id					value_ = nil;
	
	charRng_ = NSMakeRange(0, [content_ length]);
	charIndex_ = charRng_.location;
	toIndex_   = NSMaxRange(charRng_);
	
	while (charIndex_ < toIndex_) {
		value_ = [content_ attribute : CMRMessageLastUpdatedHeaderAttributeName
							 atIndex : charIndex_
			   longestEffectiveRange : &range_
							 inRange : charRng_];
		if (value_ != nil) {
			if (effectiveRange != NULL) *effectiveRange = range_;
			
			if (NO == [value_ isKindOfClass : [NSDate class]]) return nil;
			return (NSDate *)value_;
		}
		charIndex_ = NSMaxRange(range_);
	}
	if (effectiveRange != NULL) *effectiveRange = NSMakeRange(NSNotFound, 0);
	return nil;
}

- (void) appendLastUpdatedHeader
{
	NSAttributedString	*header_;
	NSRange				range_;
	id					templateMgr = [CMRMessageAttributesTemplate sharedTemplate];
	NSTextStorage		*tS_ = [self textStorage];
	
	header_ = [templateMgr lastUpdatedHeaderAttachment];
	if (nil == header_) 
		return;

	[tS_ beginEditing];
	range_.location = [tS_ length];
	[tS_ appendAttributedString : header_];
	range_.length = [tS_ length] - range_.location;
	
	// ���݂̓��t�𑮐��Ƃ��Ēǉ�
	[tS_ addAttribute : CMRMessageLastUpdatedHeaderAttributeName
				value : [NSDate date]
				range : range_];
	[tS_ endEditing];
}
- (void) clearLastUpdatedHeader
{
	NSRange		headerRange_;
	NSTextStorage		*tS_ = [self textStorage];
	
	headerRange_ = [self firstLastUpdatedHeaderAttachmentRange];
	if (NSNotFound == headerRange_.location) return;

	[self slideMessageRanges : -(headerRange_.length)
				fromLocation : NSMaxRange(headerRange_)];
	
	[tS_ beginEditing];
	[tS_ deleteCharactersInRange : headerRange_];
	[tS_ endEditing];
}
@end
