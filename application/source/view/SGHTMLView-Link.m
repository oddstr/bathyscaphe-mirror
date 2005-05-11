/**
  * $Id: SGHTMLView-Link.m,v 1.1.1.1 2005/05/11 17:51:08 tsawada2 Exp $
  * 
  * SGHTMLView-Link.m
  *
  * Copyright (c) 2003, Takanori Ishikawa.
  * See the file LICENSE for copying permission.
  */
#import "SGHTMLView_p.h"
#import "CMXPopUpWindowManager.h"
#import "CMRPopUpTemplateKeys.h"
#import "SGContextHelpPanel.h"
#import "CMRAttachmentCell.h"

// for debugging only
#define UTIL_DEBUGGING		0
#import "UTILDebugging.h"



@implementation SGHTMLView(Link)
- (NSMutableDictionary *) trackingRectTags
{
	if (nil == _trackingRectTags)
		_trackingRectTags = [[NSMutableDictionary alloc] init];
	return _trackingRectTags;
}
- (NSTrackingRectTag) visibleRectTag
{
	return _visibleRectTag;
}

- (void) resetCursorRectsImp
{
	[super resetCursorRects];
	
	[self resetTrackingVisibleRect];
	if (nil == [self window]) return;
	if (NO == [[self window] isPopUpWindow]) {
		NSScrollView		*scrollView_;
		
		scrollView_ = [self enclosingScrollView];
		if ([[CMXPopUpWindowManager defaultManager] isPopUpWindowVisible]) {
			[scrollView_ setDocumentCursor : nil];
			return;
		} else {
			[scrollView_ setDocumentCursor : [NSCursor IBeamCursor]];
		}
	}
	
	[self removeAllLinkTrackingRects];
	[self updateAnchoredRectsInBounds : [self visibleRect]
						 forAttribute : NSLinkAttributeName];
	[self updateAnchoredRectsInBounds : [self visibleRect]
						 forAttribute : NSAttachmentAttributeName];
	[self updateAnchoredRectsInBounds : [self visibleRect]
						 forAttribute : CMRMessageIndexAttributeName];
	UTIL_DEBUG_WRITE1(
		@"Link Rects Updated: count=%u",
		[[self userDataArray] count]);
}

/*** Event Handling ***/
- (void) responseMouseEvent : (NSEvent *) theEvent
			   mouseEntered : (BOOL     ) isEntered
{
	int			tag_ = [theEvent trackingNumber];
	NSRect		rect_;
	
	if ((isEntered ? NSMouseEntered : NSMouseExited) != [theEvent type])
		return;
	
	// View
	if ([self visibleRectTag] == tag_) {
		[self mouseEventInVisibleRect:theEvent entered:isEntered];
		return;
	}
	
	// Link
	rect_ = [self trackingRectForTag : tag_];
	if (NSEqualRects(NSZeroRect, rect_)) {
		return;
	}

	[self processMouseEvent : [theEvent userData]
		       trackingRect : rect_
		          withEvent : theEvent
		       mouseEntered : isEntered];
}

- (BOOL) shouldUpdateAnchoredRectsInBounds : (NSRect ) aBounds
{
	return !([[self textStorage] isEmpty] || [self inLiveResize]);
}
- (void) updateAnchoredRectsInBounds : (NSRect    ) aBounds
						forAttribute : (NSString *) attributeName
{
	NSTextStorage		*storage_	= [self textStorage];
	NSLayoutManager		*lm			= [self layoutManager];
	NSTextContainer		*container_	= [self textContainer];
	
	BOOL				isAttachment_;
	unsigned			toIndex_;
	unsigned			charIndex_;
	NSRange				glyphRange_;
	NSRange				charRange_;
	NSRange				linkRange_;
	id					v = nil;
	NSTrackingRectTag	tag_;
	
	
	if (NO == [self shouldUpdateAnchoredRectsInBounds:aBounds])
		return;
	
	isAttachment_ = [NSAttachmentAttributeName isEqualToString : attributeName];
	glyphRange_ = [lm glyphRangeForBoundingRectWithoutAdditionalLayout : aBounds 
								inTextContainer : container_];
	charRange_ = [lm characterRangeForGlyphRange : glyphRange_ 
								actualGlyphRange : NULL];
	charIndex_ = charRange_.location;
	toIndex_ = NSMaxRange(charRange_);
	if (0 == toIndex_) return;
	
	NSAssert2(
		toIndex_ <= [lm firstUnlaidCharacterIndex],
		@"\n"
		@"  ***WARNING*** update cursorRects in %@\n"
		@"    but layoutManager's firstUnlaidCharacterIndex = %u.\n"
		@"    It makes performance issues, or crash If your fate is bad...",
		NSStringFromRange(charRange_),
		[lm firstUnlaidCharacterIndex]);
	
	while (charIndex_ < toIndex_) {
		v = [storage_ attribute : attributeName
						atIndex : charIndex_
		  longestEffectiveRange : &linkRange_
						inRange : charRange_];
		
		do {
		if (v != nil) {
			NSRange			actualRange_;
			NSRectArray		rects_;
			unsigned		i, rectCount_;
			
			if (isAttachment_) {
				id		cell_;
				
				cell_ = [v attachmentCell];
				if (NO == [cell_ wantsToTrackMouseOver])
					break;
			}
			glyphRange_ = [lm glyphRangeForCharacterRange : linkRange_
									 actualCharacterRange : &actualRange_];
			
			linkRange_ = actualRange_;
			
			rects_ = [lm rectArrayForGlyphRange:glyphRange_
							withinSelectedGlyphRange:kNFRange
							inTextContainer:container_
							rectCount:&rectCount_];
			for (i = 0; i < rectCount_; i++) {
				tag_ = [self addLinkTrackingRect:rects_[i] link:v];
			}
		}
		} while (0);
		
		charIndex_ = NSMaxRange(linkRange_);
	}
}

/*** Tracking Rects Management ***/
- (NSMutableArray *) userDataArray
{
	if (nil == _userDataArray)
		_userDataArray = [[NSMutableArray alloc] init];
	
	return _userDataArray;
}

- (void) resetTrackingVisibleRect
{
	NSTrackingRectTag   tag;
	
	if ([self visibleRectTag] != 0) {
		[self removeTrackingRect : [self visibleRectTag]];
	}
	tag = [self addTrackingRect : [self visibleRect]
							 owner : self
						  userData : NULL
					  assumeInside : NO];
	_visibleRectTag = tag;
}

- (NSTrackingRectTag) addLinkTrackingRect : (NSRect) aRect
                                     link : (id    ) aLink;
{
	NSTrackingRectTag	trackingRectTag_;
	id					rectObject_;
	id					trackingRectTagValue_;
	
	trackingRectTag_ = 
			[super addTrackingRect : aRect
							 owner : self
						  userData : aLink
					  assumeInside : NO];
	[[self userDataArray] addObject : aLink];
	
	[self addCursorRect:aRect cursor:[NSCursor pointingHandCursor]];
	[[NSCursor pointingHandCursor] setOnMouseEntered : YES];
	
	rectObject_ = [NSValue valueWithRect : aRect];
	trackingRectTagValue_ = [NSNumber numberWithInt : trackingRectTag_];
	[[self trackingRectTags] setObject : rectObject_
								forKey : trackingRectTagValue_];
	
	return trackingRectTag_;
}

- (void) removeAllLinkTrackingRects;
{
	NSEnumerator	*iter_;
	NSNumber		*tag_;
	
	iter_ = [[[self trackingRectTags] allKeys] objectEnumerator];
	while (tag_ = [iter_ nextObject]) {
		UTILAssertRespondsTo(tag_, @selector(intValue));
		[self removeTrackingRect : [tag_ intValue]];
	}
	[[self trackingRectTags] removeAllObjects];
	[[self userDataArray] removeAllObjects];
}

- (NSRect) trackingRectForTag : (NSTrackingRectTag) aTag
{
	NSValue		*v;
	
	if (aTag == [self visibleRectTag])
		return [self visibleRect];
	
	v = [[self trackingRectTags] objectForKey : [NSNumber numberWithInt : aTag]];
	return v ? [v rectValue] : NSZeroRect;
}
@end



@implementation SGHTMLView(DelegateSupport)
- (void) processMouseEvent : (id       ) userData
              trackingRect : (NSRect   ) aRect
                 withEvent : (NSEvent *) anEvent
              mouseEntered : (BOOL     ) flag
{
	id		delegate_;
	SEL		performSelector_;
	
	
	if ([userData isKindOfClass : [NSTextAttachment class]]) {
		id		cell_ = [userData attachmentCell];
		
		// TextAttachement
		if (NO == [cell_ wantsToTrackMouseForEvent:anEvent inRect:aRect ofView:self atCharacterIndex:NSNotFound])
			return;
		
		[cell_ trackMouse:anEvent inRect:aRect ofView:self atCharacterIndex:NSNotFound untilMouseUp:NO];
		return;
	} else if ([userData isKindOfClass : [NSNumber class]]) {
		// Message Index
		UTIL_DEBUG_WRITE1(@"Link is NSNumber:%u",
			[userData unsignedIntValue]);
		
		return;
	}

	delegate_ = [self delegate];
	if(nil == delegate_) return;
	
	performSelector_ = flag 
		? @selector(HTMLView:mouseEnteredInLink:inTrackingRect:withEvent:)
		: @selector(HTMLView:mouseExitedFromLink:inTrackingRect:withEvent:);
	if(NO == [delegate_ respondsToSelector : performSelector_])
		return;
	
	if(flag){
		[delegate_ HTMLView:self mouseEnteredInLink:userData
					inTrackingRect:aRect withEvent:anEvent];
	}else{
		[delegate_ HTMLView:self mouseExitedFromLink:userData
					inTrackingRect:aRect withEvent:anEvent];
	}
}
- (void) mouseEventInVisibleRect : (NSEvent *) anEvent
						 entered : (BOOL     ) isMouseEntered
{
	SEL		performSelector_;
	
	UTILNotifyName(isMouseEntered 
			? SGHTMLViewMouseEnteredNotification
			: SGHTMLViewMouseExitedNotification);
	
	if(nil == [self delegate]) return;
	performSelector_ = 
		isMouseEntered 
			? @selector(HTMLView:mouseEntered:)
			: @selector(HTMLView:mouseExited:);
	if(NO == [[self delegate] respondsToSelector : performSelector_])
		return;
	
	if(isMouseEntered)
		[[self delegate] HTMLView:self mouseEntered : anEvent];
	else
		[[self delegate] HTMLView:self mouseExited : anEvent];
}
- (BOOL) shouldHandleContinuousMouseDown : (NSEvent *) theEvent
{
	if(nil == [self delegate] ||
		NO == [[self delegate] respondsToSelector : @selector(HTMLView:shouldHandleContinuousMouseDown:)])
		return NO;
	
	return [[self delegate] HTMLView:self shouldHandleContinuousMouseDown:theEvent];
}
- (BOOL) handleContinuousMouseDown : (NSEvent *) theEvent
{
	if(nil == [self delegate] ||
		NO == [[self delegate] respondsToSelector : @selector(HTMLView:continuousMouseDown:)])
		return NO;
	
	return [[self delegate] HTMLView:self continuousMouseDown:theEvent];
}
@end
