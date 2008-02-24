//:CMRThreadLayout-MessageRange.m
/**
  *
  * @see SGBaseRangeArray.h
  * @see SGBaseRangeEnumerator.h
  *
  * @author Takanori Ishikawa
  * @author http://www15.big.or.jp/~takanori/
  * @version 1.0.0d1 (03/01/16  11:27:33 PM)
  *
  */
#import "CMRThreadLayout_p.h"
#import "CMRAttributedMessageComposer.h"
#import "AppDefaults.h"



@implementation CMRThreadLayout(MessageRange)
- (unsigned int) numberOfReadedMessages
{
	return [[self messageBuffer] count];
}
- (unsigned int) firstUnlaidMessageIndex
{
	return [[self messageRanges] count];
}
- (BOOL) isCompleted
{
	return [self numberOfReadedMessages] == [self firstUnlaidMessageIndex];
}

- (NSRange) rangeAtMessageIndex : (unsigned int) index
{
	return [[self messageRanges] rangeAtIndex : index];
}
- (unsigned int) messageIndexForRange : (NSRange) aRange
{
	unsigned				index_;
	SGBaseRangeEnumerator	*rangeIter_;
	
	index_ = 0;
	rangeIter_ = [[self messageRanges] enumerator];
	while ([rangeIter_ hasNext]) {
		NSRange		mesRng_;
		NSRange		intersection_;
		
		mesRng_ = [rangeIter_ next];
		intersection_ = NSIntersectionRange(mesRng_, aRange);
		if (intersection_.length != 0)
			return index_;
		
		index_++;
	}
	return NSNotFound;
}
- (unsigned int)lastMessageIndexForRangeSilverGull:(NSRange)aRange
{
	unsigned				index_;
//	SGBaseRangeEnumerator	*rangeIter_;
	
	index_ = [[self messageRanges] count] -1;
//	rangeIter_ = [[self messageRanges] reverseEnumerator];
//	while ([rangeIter_ hasNext] && index_ >= 0) {
		NSRange		mesRng_;
		NSRange		intersection_;
		
//		mesRng_ = [rangeIter_ next];
		mesRng_ = [[self messageRanges] last];
		intersection_ = NSIntersectionRange(mesRng_, aRange);
		if (NSMaxRange(intersection_) == NSMaxRange(mesRng_)) {
			return index_;
		}
//		if (intersection_.length != 0)
//			return index_;
		
//		index_--;
//	}
	return [self messageIndexForRange:aRange];
}
- (unsigned int) lastMessageIndexForRange : (NSRange) aRange
{
	unsigned				index_;
	SGBaseRangeEnumerator	*rangeIter_;
	
	index_ = [[self messageRanges] count] -1;
	rangeIter_ = [[self messageRanges] reverseEnumerator];
	while ([rangeIter_ hasNext] && index_ >= 0) {
		NSRange		mesRng_;
		NSRange		intersection_;
		
		mesRng_ = [rangeIter_ next];
		intersection_ = NSIntersectionRange(mesRng_, aRange);
		if (intersection_.length != 0)
			return index_;
		
		index_--;
	}
	return NSNotFound;
}
- (NSAttributedString *) contentsAtIndex : (unsigned int) index
{
//	NSRange		indexRange_;
	
//	indexRange_ = NSMakeRange(index, 1);
//	return [self contentsForIndexRange : indexRange_];
	return [self contentsForIndexes:[NSIndexSet indexSetWithIndex:index]];
}

/*- (BOOL) hasTemporaryInvisibleMessageInIndexRange : (NSRange) aRange
{
	CMRThreadMessage	*m;
	unsigned			i;
	
	for (i = 0; i < aRange.length; i++) {
		m = [[self messageBuffer] messageAtIndex : aRange.location + i];
		if ([m isTemporaryInvisible]) 
			return YES;
	}
	return NO;
}*/
/*- (NSRange) subrangeForIndexRange : (NSRange) aRange
{
	NSRange		startRng_;
	NSRange		endRng_;
	
	if (NSNotFound == aRange.location || 0 == aRange.length) return kNFRange;
	if ([self firstUnlaidMessageIndex] < NSMaxRange(aRange)) return kNFRange;
	
	startRng_ = [self rangeAtMessageIndex : aRange.location];
	if (aRange.length == 1) return startRng_;
	endRng_ = [self rangeAtMessageIndex : (NSMaxRange(aRange) -1)];
	if (NSNotFound == endRng_.location) return endRng_;
	
	return NSUnionRange(startRng_, endRng_);
}*/
/*
- (NSAttributedString *) attributedSubstringForIndexRange : (NSRange) aRange
{
	NSRange		subrange_ = [self subrangeForIndexRange : aRange];
	
	if (NSNotFound == subrange_.length || 0 == subrange_.length)
		return nil;
	
	return [[self textStorage] attributedSubstringFromRange : subrange_];
}
*/
- (NSAttributedString *) contentsForIndexes : (NSIndexSet *) indexes
			 					 composingMask : (UInt32 ) composingMask
									   compose : (BOOL   ) doCompose
								attributesMask : (UInt32 ) attributesMask
{

	CMRThreadMessage	*m;
//	unsigned			i;
	int				size = [indexes lastIndex]+1;
	NSMutableAttributedString		*textBuffer_;
	CMRAttributedMessageComposer	*composer_;
	
	if (!indexes || [indexes count] == 0) return nil;
	if ([self firstUnlaidMessageIndex] < size) return nil;

	unsigned int	idx;
	NSRange			e = NSMakeRange(0, size);

	composer_ = [[CMRAttributedMessageComposer alloc] init];
	textBuffer_ = [[NSMutableAttributedString alloc] init];
	
	[composer_ setAttributesMask : attributesMask];
	[composer_ setComposingMask:composingMask compose:doCompose];
	
	[composer_ setContentsStorage : textBuffer_];

	while ([indexes getIndexes:&idx maxCount:1 inIndexRange:&e] > 0) {
		m = [[self messageBuffer] messageAtIndex:idx];
		[composer_ composeThreadMessage:m];
	}
/*	
	for (i = 0; i < aRange.length; i++) {
		m = [[self messageBuffer] messageAtIndex : aRange.location + i];
		[composer_ composeThreadMessage : m];
	}*/
	[composer_ release];
	return [textBuffer_ autorelease];
}
/*
- (NSAttributedString *) contentsForIndexRange : (NSRange) aRange
			 					 composingMask : (UInt32 ) composingMask
									   compose : (BOOL   ) doCompose
								attributesMask : (UInt32 ) attributesMask
{

	CMRThreadMessage	*m;
	unsigned			i;
	NSMutableAttributedString		*textBuffer_;
	CMRAttributedMessageComposer	*composer_;
	
	if (NSNotFound == aRange.location || 0 == aRange.length) return nil;
	if ([self firstUnlaidMessageIndex] < NSMaxRange(aRange)) return nil;
	
	// すでに表示済み
//
//	if (NO == [self hasTemporaryInvisibleMessageInIndexRange : aRange])
//		return [self attributedSubstringForIndexRange : aRange];
//
	
	composer_ = [[CMRAttributedMessageComposer alloc] init];
	textBuffer_ = [[NSMutableAttributedString alloc] init];
	
	[composer_ setAttributesMask : attributesMask];
	[composer_ setComposingMask:composingMask compose:doCompose];
	
	[composer_ setContentsStorage : textBuffer_];
	
	for (i = 0; i < aRange.length; i++) {
		m = [[self messageBuffer] messageAtIndex : aRange.location + i];
		[composer_ composeThreadMessage : m];
	}
	[composer_ release];
	return [textBuffer_ autorelease];
}*/
/*
- (NSAttributedString *) contentsForIndexRange : (NSRange) aRange
								   targetIndex : (unsigned int ) messageIndex
			 					 composingMask : (UInt32 ) composingMask
									   compose : (BOOL   ) doCompose
								attributesMask : (UInt32 ) attributesMask
{
	CMRThreadMessage	*m;
	unsigned			i;
	NSMutableAttributedString		*textBuffer_;
	CMRAttributedMessageComposer	*composer_;
	
	if (NSNotFound == aRange.location || 0 == aRange.length) return nil;
	if ([self firstUnlaidMessageIndex] < NSMaxRange(aRange)) return nil;

	composer_ = [[CMRAttributedMessageComposer alloc] init];
	textBuffer_ = [[NSMutableAttributedString alloc] init];
	
	[composer_ setAttributesMask : attributesMask];
	[composer_ setComposingMask:composingMask compose:doCompose];
	[composer_ setComposingTargetIndex: messageIndex];
	[composer_ setContentsStorage : textBuffer_];
	
	for (i = 0; i < aRange.length; i++) {
		m = [[self messageBuffer] messageAtIndex : aRange.location + i];
		[composer_ composeThreadMessage : m];
	}
	[composer_ release];
	return [textBuffer_ autorelease];
}
*/
- (NSAttributedString *)contentsForTargetIndex:(unsigned int)messageIndex
								 composingMask:(UInt32)composingMask
									   compose:(BOOL)doCompose
								attributesMask:(UInt32)attributesMask
{
	CMRThreadMessage	*m;
	unsigned	limit = [self firstUnlaidMessageIndex];
	unsigned	i;
	NSMutableAttributedString		*textBuffer_;
	CMRAttributedMessageComposer	*composer_;
	
	if (limit == 0) return nil;

	composer_ = [[CMRAttributedMessageComposer alloc] init];
	textBuffer_ = [[NSMutableAttributedString alloc] init];
	
	[composer_ setAttributesMask:attributesMask];
	[composer_ setComposingMask:composingMask compose:doCompose];
	[composer_ setComposingTargetIndex: messageIndex];
	[composer_ setContentsStorage:textBuffer_];
	
	for (i = 0; i < limit; i++) {
		m = [[self messageBuffer] messageAtIndex:i];
		[composer_ composeThreadMessage:m];
	}
	[composer_ release];
	return [textBuffer_ autorelease];
}
/*
- (NSAttributedString *) contentsForIndexRange : (NSRange) aRange
{
	if (kSpamFilterInvisibleAbonedBehavior == [CMRPref spamFilterBehavior]) {
		return [self contentsForIndexRange : aRange
							 composingMask : CMRInvisibleAbonedMask
								   compose : NO
							attributesMask : CMRLocalAbonedMask];
	} else {
		return [self contentsForIndexRange : aRange
							 composingMask : CMRInvisibleAbonedMask
								   compose : NO
							attributesMask : (CMRLocalAbonedMask | CMRSpamMask)];
	}
}
*/
- (NSAttributedString *)contentsForIndexes:(NSIndexSet *)indexes
{
	if (kSpamFilterInvisibleAbonedBehavior == [CMRPref spamFilterBehavior]) {
		return [self contentsForIndexes : indexes
							 composingMask : CMRInvisibleAbonedMask
								   compose : NO
							attributesMask : CMRLocalAbonedMask];
	} else {
		return [self contentsForIndexes : indexes
							 composingMask : CMRInvisibleAbonedMask
								   compose : NO
							attributesMask : (CMRLocalAbonedMask | CMRSpamMask)];
	}
}

/*
- (void) drawViewBackgroundInRect : (NSRect) clipRect
{
	NSLayoutManager			*lm = [self layoutManager];
	NSTextContainer			*tc = [self textContainer];
	NSRange					drawRange_;
	SGBaseRangeEnumerator	*rangeIter_;
	unsigned				mIndex_;
	unsigned				drawMaxIndex_;
	
	drawRange_ = [lm glyphRangeForBoundingRect:clipRect inTextContainer:tc];
	drawRange_ = [lm characterRangeForGlyphRange:drawRange_ actualGlyphRange:NULL];
	
	mIndex_ = 0;
	drawMaxIndex_ = NSMaxRange(drawRange_);
	rangeIter_ = [[self messageRanges] enumerator];
	while ([rangeIter_ hasNext]) {
		NSRange		mesRng_;
		NSRect		boundingRect;
		NSRange		glyphRange;
		
		mesRng_ = [rangeIter_ next];
		if (0 == mesRng_.length || NSMaxRange(mesRng_) < drawRange_.location)
			continue;
		if (mesRng_.location >= drawMaxIndex_)
			break;
		
		glyphRange = [lm glyphRangeForCharacterRange:mesRng_ actualCharacterRange:NULL];
		boundingRect = [lm boundingRectForGlyphRange:glyphRange inTextContainer:tc];
		
		[[CMRPref messageFilteredColor] set];
		NSRectFill(boundingRect);
		
		mIndex_++;
	}
}
*/

#pragma mark On-the-fly loading
- (unsigned) numberOfMessagesPerOnTheFly
{
	id		v;
	
	v = SGTemplateResource(ENSURE_LENGTH_KEY);
	if (nil == v || NO == [v respondsToSelector : @selector(unsignedIntValue)])
		return 10;
	
	return [v unsignedIntValue];
}
- (void) ensureMessageToBeVisibleAtIndex : (unsigned) anIndex
{
	[self ensureMessageToBeVisibleAtIndex:anIndex effectsLongest:NO];
}
- (void) ensureMessageToBeVisibleAtIndex : (unsigned) anIndex
						  effectsLongest : (BOOL) longestFlag
{
	CMRThreadMessage	*m;
	unsigned			i, st, lst, cnt, max;
	NSMutableAttributedString		*textBuffer_;
	CMRAttributedMessageComposer	*composer_;
	unsigned			textLength_ = 0;
	NSRange				mesRange_;
	
	max = [self numberOfMessagesPerOnTheFly];
	cnt = [self firstUnlaidMessageIndex];
	if (NSNotFound == anIndex || cnt <= anIndex)
		return;
	
	m = [[self messageBuffer] messageAtIndex : anIndex];
	if (NO == [m isTemporaryInvisible]) return;
	
	// 範囲を求める（上方向）
	for (i = 0, st = anIndex; st >= 0; i++, st--) {
		m = [[self messageBuffer] messageAtIndex : st];
		if (NO == [m isTemporaryInvisible] || (NO == longestFlag && i >= max)) {
			st++;
			break;
		}
		
		if (0 == st) break;
	}
	// 範囲を求める（下方向）
	for (i = 0, lst = anIndex; lst < cnt; i++, lst++) {
		m = [[self messageBuffer] messageAtIndex : lst];
		if (NO == [m isTemporaryInvisible] || (NO == longestFlag && i >= max)) {
			lst--;
			break;
		}
		if (cnt-1 == lst) break;
	}
	
	composer_ = [[CMRAttributedMessageComposer alloc] init];
	textBuffer_ = [[NSMutableAttributedString alloc] init];
	[composer_ setContentsStorage : textBuffer_];
	
	[[self messageBuffer] setTemporaryInvisible : NO
							inRange : NSMakeRange(st, (lst - st +1))];
	
	mesRange_ = [[self messageRanges] rangeAtIndex : st];
	textLength_ = mesRange_.location;
	[_messagesLock lock];
	for (i = st; i <= lst; i++) {
		m = [[self messageBuffer] messageAtIndex : i];
		
		mesRange_ = NSMakeRange([textBuffer_ length], 0);
		[composer_ composeThreadMessage : m];
		mesRange_.length = [textBuffer_ length] - mesRange_.location;
		mesRange_.location += textLength_;
		
		[[self messageRanges] setRange:mesRange_ atIndex:i];
	}
	
	// オリジナルの範囲を補正
	textLength_ = [textBuffer_ length];
	for (i = lst +1; i < cnt; i++) {
		mesRange_ = [[self messageRanges] rangeAtIndex : i];
		mesRange_.location += textLength_;
		[[self messageRanges] setRange:mesRange_ atIndex:i];
	}
	[_messagesLock unlock];
	
	mesRange_ = [[self messageRanges] rangeAtIndex : st];
	[[self textStorage] beginEditing];
	[[self textStorage] insertAttributedString : textBuffer_
							atIndex : mesRange_.location];
	[self fixEllipsisProxyAttachment];
	[[self textStorage] endEditing];
	
#if 0
	UTILMethodLog;
	UTILDescUnsignedInt(st);
	UTILDescUnsignedInt(lst);
	UTILDescription([self messageRanges]);
#endif

	// 2005-09-09 tsawada2 <ben-sawa@td5.so-net.ne.jp>
	// Tiger で、オンザフライでレス展開したとき描画がしばしば乱れる問題を
	// これで回避…できるだろうか？しばらく様子見。
	[[self scrollView] setNeedsDisplay : YES];

	[textBuffer_ release];
	[composer_ release];
}

// 次／前のレス
- (unsigned int) nextMessageIndexOfIndex : (unsigned int) index
							   attribute : (UInt32      ) flags
								   value : (BOOL        ) attributeIsSet
{
	int					i, cnt;
	CMRThreadMessage	*m;
	
	if (NSNotFound == index)
		return NSNotFound;
		
	cnt = [self firstUnlaidMessageIndex];
	if (cnt <= index)
		return NSNotFound;
	for (i = index +1; i < cnt; i++) {
		m = [self messageAtIndex : i];
		if (attributeIsSet == (([m flags] & flags) != 0))
			return i;
	}
	
	return NSNotFound;
}

- (unsigned int) previousMessageIndexOfIndex : (unsigned int) index
								   attribute : (UInt32      ) flags
									   value : (BOOL        ) attributeIsSet
{	int					i, cnt;
	CMRThreadMessage	*m;
	
	if (NSNotFound == index)
		return NSNotFound;
	
	if (0 == index)
		return NSNotFound;
	
	cnt = [self firstUnlaidMessageIndex];
	for (i = index -1; i >= 0; i--) {
		m = [self messageAtIndex : i];
		if (attributeIsSet == (([m flags] & flags) != 0))
			return i;
	}
	
	return NSNotFound;
}

- (unsigned int) messageIndexOfLaterDate: (NSDate *) baseDate attribute: (UInt32) flags value: (BOOL) attributeIsSet
{
	int					i, cnt;
	CMRThreadMessage	*m;
	id					msgDate;
	
	if (baseDate == nil)
		return NSNotFound;
		
	cnt = [self numberOfReadedMessages];

	for (i = 0; i < cnt; i++) {
		m = [self messageAtIndex: i];
		msgDate = [m date];
		if (!msgDate || NO == [msgDate isKindOfClass: [NSDate class]]) continue;

		if (([(NSDate *)msgDate compare: baseDate] != NSOrderedAscending) && (attributeIsSet == (([m flags] & flags) != 0))) {
//			NSLog(@"msgDate:\n%@\nbaseDate:\n%@\nindex: %i\n", [msgDate description], [baseDate description], i);
			return i;
		}
	}
	
	return NSNotFound;
}

#pragma mark Jumpable index
- (unsigned) nextVisibleMessageIndex
{
	return [self nextVisibleMessageIndexOfIndex : 
				[self firstMessageIndexForDocumentVisibleRect]];
}
- (unsigned) previousVisibleMessageIndex
{
	return [self previousVisibleMessageIndexOfIndex : 
				[self firstMessageIndexForDocumentVisibleRect]];
}

static UInt32 attributeMaskForVisibleMessageIndexDetection()
{
	if (kSpamFilterInvisibleAbonedBehavior == [CMRPref spamFilterBehavior]) {
		return (CMRInvisibleAbonedMask | CMRSpamMask);
	} else {
		return CMRInvisibleAbonedMask;
	}
}

- (unsigned int) nextVisibleMessageIndexOfIndex : (unsigned int) anIndex
{
	return [self nextMessageIndexOfIndex : anIndex 
							   attribute : attributeMaskForVisibleMessageIndexDetection()//CMRInvisibleAbonedMask
								   value : NO];
}
- (unsigned int) previousVisibleMessageIndexOfIndex : (unsigned int) anIndex
{
	return [self previousMessageIndexOfIndex : anIndex 
								   attribute : attributeMaskForVisibleMessageIndexDetection()//CMRInvisibleAbonedMask
									   value : NO];
}

#pragma mark Jumping to bookmarks
- (unsigned) nextBookmarkIndex
{
	return [self nextBookmarkIndexOfIndex : 
				[self firstMessageIndexForDocumentVisibleRect]];
}
- (unsigned) previousBookmarkIndex
{
	return [self previousBookmarkIndexOfIndex : 
				[self firstMessageIndexForDocumentVisibleRect]];
}
- (unsigned int) nextBookmarkIndexOfIndex : (unsigned int) anIndex
{
	return [self nextMessageIndexOfIndex : anIndex 
							   attribute : CMRBookmarkMask
								   value : YES];
}
- (unsigned int) previousBookmarkIndexOfIndex : (unsigned int) anIndex
{
	return [self previousMessageIndexOfIndex : anIndex 
								   attribute : CMRBookmarkMask
									   value : YES];
}

#pragma mark Jumping to Specific date's Message
- (unsigned int) messageIndexOfLaterDate: (NSDate *) baseDate
{
	return [self messageIndexOfLaterDate: baseDate attribute: attributeMaskForVisibleMessageIndexDetection() value: NO];
}
@end
