/**
  * $Id: CMRThreadViewer-Link.m,v 1.26 2007/07/22 11:22:32 tsawada2 Exp $
  * 
  * CMRThreadViewer-Link.m
  *
  * Copyright (c) 2003, Takanori Ishikawa.
  * See the file LICENSE for copying permission.
  */
#import "CMRThreadViewer_p.h"
#import "CMRThreadLinkProcessor.h"
#import "CMRMessageAttributesTemplate.h"
#import "CMRThreadLayout.h"
#import "SGHTMLView.h"
#import "CMXPopUpWindowManager.h"
#import "CMXMenuHolder.h"
#import "CMRReplyMessenger.h"
#import "CMRMessageFilter.h"
#import "CMRSpamFilter.h"
#import "CMRThreadView.h"
//#import "CMRNetRequestQueue.h"

#import "DatabaseManager.h"

#import <SGAppKit/NSWorkspace-SGExtensions.h>


NSString *const CMRThreadViewerRunSpamFilterNotification = @"CMRThreadViewerRunSpamFilterNotification";

#define kBeProfileLinkTemplateKey	@"System - be2ch Profile URL"

// for debugging only
#define UTIL_DEBUGGING				0
#import "UTILDebugging.h"


@interface CMRThreadViewer (PopUpSupport)
- (NSAttributedString *) attributedStringWithLinkContext : (id) aLink;
- (BOOL) tryShowPopUpWindowWithLink : (id     ) aLink
                       locationHint : (NSPoint) loc;
- (BOOL) tryShowPopUpWindowSubstringWithRange : (NSRange		) subrange
								inTextStorage : (NSTextStorage *) storage
								 locationHint : (NSPoint		) loc;

- (BOOL) isMessageLink : (id                ) aLink
            rangeArray : (SGBaseRangeArray *) rangeBuffer;
- (BOOL) isStandardMessageLink : (id            ) aLink
                    indexRange : (NSRangePointer) messageRange;
@end


@implementation CMRThreadViewer (PopUpSupport)
- (NSAttributedString *) attributedStringWithLinkContext : (id) aLink
{
	static NSMutableAttributedString *kBuffer = nil;
	
	NSString		*address_;
	NSString		*logPath_ = nil;
	NSString		*boardName_ = nil;	// added in PrincessBride and later.
	NSURL			*boardURL_ = nil;	// added in PrincessBride and later.
	
	if (nil == aLink) return nil;
	if (nil == kBuffer)
		kBuffer = [[NSMutableAttributedString alloc] init];
	
	[kBuffer deleteCharactersInRange:[kBuffer range]];
	
	address_ = [[aLink stringValue] stringByDeletingURLScheme : @"mailto"];
	if (address_ != nil) {
		NSDictionary		*attributes_;
		
		attributes_ = [[CMRMessageAttributesTemplate sharedTemplate] attributesForText];
		[[kBuffer mutableString] appendString : address_];
		[kBuffer setAttributes:attributes_ range:[kBuffer range]]; 

	} else if ([CMRThreadLinkProcessor parseThreadLink : aLink
											 boardName : &boardName_
											  boardURL : &boardURL_
											  filepath : &logPath_]) {
		NSDictionary			*dict_;
		CMRThreadAttributes		*attr_;
		NSAttributedString		*template_;
		NSString				*title_;
		
		dict_ = [[[NSDictionary alloc] initWithContentsOfFile: logPath_] autorelease];
		if (!dict_) {
			// データベース上にあるか
			NSString		*threadID = [[logPath_ stringByDeletingPathExtension] lastPathComponent];

			NSString *threadTitle = [[DatabaseManager defaultManager] threadTitleFromBoardName:boardName_
																			  threadIdentifier:threadID];
			if(threadTitle) {
				title_ = [NSString stringWithFormat: @"%@ - %@",
												 threadTitle,
												 boardName_];
			} else {
				title_ = boardName_;
			}

			template_ = [[[NSAttributedString alloc] initWithString: title_] autorelease];
			if (!template_) goto ErrInvalidLink;

			[kBuffer setAttributedString: template_];

		} else {
			attr_ = [[[CMRThreadAttributes alloc] initWithDictionary: dict_] autorelease];
			title_ = [NSString stringWithFormat: @"%@ - %@", [attr_ threadTitle], boardName_];

			template_ = [[[NSAttributedString alloc] initWithString: title_] autorelease];
			if (!template_) goto ErrInvalidLink;
		
			[kBuffer setAttributedString: template_];
		}
	} else if ([CMRThreadLinkProcessor parseBoardLink: aLink boardName: &boardName_ boardURL: &boardURL_]) {
		[kBuffer setAttributedString: [[[NSAttributedString alloc] initWithString: boardName_] autorelease]];
	} else {
		SGBaseRangeArray		*indexRanges_;
		SGBaseRangeEnumerator	*iter_;
		NSRange					indexRng_;
		NSAttributedString		*message_;
		
		indexRanges_ = SGTemporaryRangeArray();
		if (NO == [self isMessageLink:aLink rangeArray:indexRanges_])
			goto ErrInvalidLink;
		
		
		iter_ = [indexRanges_ enumerator];
		while ([iter_ hasNext]) {	
			indexRng_ = [iter_ next];
			message_ = [[self threadLayout] contentsForIndexRange : indexRng_];
			if (nil == message_)
				continue;
			
			[kBuffer appendAttributedString : message_];
		}
		[indexRanges_ removeAll];
	}

	return kBuffer;

ErrInvalidLink:
	return nil;
}
- (BOOL) tryShowPopUpWindowWithLink : (id     ) aLink
                       locationHint : (NSPoint) loc
{
	NSPoint					location_ = loc;
	NSAttributedString		*context_;
		
	context_ = [self attributedStringWithLinkContext : aLink];
	if (nil == context_ || 0 == [context_ length])
		return NO;
	
	
	[CMRPopUpMgr showPopUpWindowWithContext : context_
								  forObject : aLink
									  owner : self
							   locationHint : location_];
	
	return YES;
}
- (BOOL) tryShowPopUpWindowSubstringWithRange : (NSRange		) subrange
								inTextStorage : (NSTextStorage *) storage
								 locationHint : (NSPoint		) loc
{
	NSString			*linkstr_;
	
	if (0 == subrange.length) return NO;
	if (nil == storage) return NO;
	if (NSMaxRange(subrange) >= [storage length]) return NO;
	
	linkstr_ = [storage string];
	linkstr_ = [linkstr_ substringWithRange : subrange];
	linkstr_ = CMRLocalResLinkWithString(linkstr_);
	
	return [self tryShowPopUpWindowWithLink : linkstr_
							   locationHint : loc];
}


- (BOOL) isStandardMessageLink : (id            ) aLink
                    indexRange : (NSRangePointer) messageRange
{
	NSURL			*link_;
	CMRHostHandler	*handler_;
	NSString		*bbs_;
	NSString		*key_;
	
	unsigned int	stIndex_;
	unsigned int	endIndex_;
	BOOL			showFirst_;
	NSRange			moveRange_;
	
	link_ = [NSURL URLWithLink : aLink];
	handler_ = [CMRHostHandler hostHandlerForURL : link_];
	if (nil == handler_) return NO;
	
	if (NO == [handler_ parseParametersWithReadURL : link_
									  bbs : &bbs_
									  key : &key_
									start : &stIndex_
									   to : &endIndex_
								showFirst : &showFirst_]) {
		return NO;
	}
	
	if (NSNotFound != stIndex_) {
		moveRange_.location = stIndex_ -1;
		moveRange_.length = (endIndex_ - stIndex_) +1;
	} else {
		moveRange_ = NSMakeRange(NSNotFound, 0);
		
		return NO;
	}
	
	// 同じ掲示板の同じスレッドならメッセージ移動処理
	if ([[self bbsIdentifier] isEqualToString : bbs_] && 
	   [[self datIdentifier] isEqualToString : key_]) {
		if (messageRange != NULL)
			*messageRange = moveRange_;
		
		return YES;
	}
	
	return NO;
}
- (BOOL) isMessageLink : (id                ) aLink
            rangeArray : (SGBaseRangeArray *) rangeBuffer
{
	NSRange         indexRange_;
	
	if (nil == aLink) return NO;

	[rangeBuffer removeAll];
	if ([CMRThreadLinkProcessor isMessageLinkUsingLocalScheme:aLink rangeArray:rangeBuffer]) {
		return YES;
	} else if ([self isStandardMessageLink:aLink indexRange:&indexRange_]) {
		[rangeBuffer append : indexRange_];
		
		return YES;
	}
	
	return NO;
}
@end

#pragma mark -

@implementation CMRThreadViewer (NSTextViewDelegate)
- (void) openMessagesWithIndexRange : (NSRange) indexRange
{
    if (indexRange.location == NSNotFound || 
        indexRange.length == 0) {
        return;
    }
    
    NSURL *boardUrl = [self boardURL];
    CMRHostHandler *handler = [CMRHostHandler hostHandlerForURL : boardUrl];
    NSURL *url = [handler readURLWithBoard : boardUrl
                    datName : [self datIdentifier]
                    start : indexRange.location +1
                    end : NSMaxRange(indexRange)
                    nofirst : YES];
    
    if (url != nil) {
        [[NSWorkspace sharedWorkspace] openURL : url inBackGround : [CMRPref openInBg]];
    }
}

#pragma mark Previewing Link via ImagePreviewer
// Added in Lemonade and later.
- (BOOL) previewLinkWithImageInspector : (id) aLink
{
	NSURL		*previewURL_;
	id			tmp;

	previewURL_ = [NSURL URLWithLink : aLink];
	tmp = [CMRPref sharedImagePreviewer];
	if (!tmp) return NO;
	return ([tmp validateLink : previewURL_] ? [tmp showImageWithURL : previewURL_]
											 : NO);
}

- (BOOL) tryPreviewLink : (id) aLink
{
	BOOL			noModifier_ = [CMRPref previewLinkWithNoModifierKey];
	NSEvent			*theEvent;
	unsigned int	flags_;
	
	theEvent = [[self window] currentEvent];
	UTILAssertNotNil(theEvent);
	
	flags_ = [theEvent modifierFlags];
	if (!(flags_ & NSAlternateKeyMask))
		return (noModifier_ ? [self previewLinkWithImageInspector : aLink]
							: NO);

	return (noModifier_ ? NO
						: [self previewLinkWithImageInspector : aLink]);
}
#pragma mark NSTextView Delegate
- (void) textView : (NSTextView              *) aTextView 
    clickedOnCell : (id <NSTextAttachmentCell>) cell
           inRect : (NSRect                   ) cellFrame
          atIndex : (unsigned                 ) charIndex
{
	if ([[self threadLayout] respondsToSelector : _cmd]) {
		[[self threadLayout] textView : aTextView
						clickedOnCell : cell
					           inRect : cellFrame
					          atIndex : charIndex];
	}
}

- (BOOL) textView : (NSTextView *) textView
    clickedOnLink : (id          ) aLink
          atIndex : (unsigned    ) charIndex
{
	NSString		*boardName_;
	NSURL			*boardURL_;
	NSString		*filepath_;
	NSString		*beParam_;

	// 同じスレッドのレスへのアンカー
    // 確実にレスへのアンカーである場合のみ配列を生成し
    // インデックスの範囲を求める。
    if ([self isMessageLink:aLink rangeArray:nil]) {
        SGBaseRangeArray *ranges = [SGBaseRangeArray array];
        
        [self isMessageLink:aLink rangeArray:ranges];
        
        int action = [CMRPref threadViewerLinkType];
        NSRange indexRange = [ranges head];
        if (indexRange.location != NSNotFound) {
            switch (action) {
            case ThreadViewerMoveToIndexLinkType:
                [self scrollMessageAtIndex : indexRange.location];
                break;
            case ThreadViewerOpenBrowserLinkType:
                [self openMessagesWithIndexRange : indexRange];
                break;
            case ThreadViewerResPopUpLinkType:
                /* Since it must be already popup-ed. */
                break;
            default:
                /* ignore */
                break;
            }
        }
        
        return YES;
	}
	
	
	// be Profile
	if ([CMRThreadLinkProcessor isBeProfileLinkUsingLocalScheme : aLink linkParam : &beParam_]) {
		NSString	*template_ = SGTemplateResource(kBeProfileLinkTemplateKey);
		NSString	*thURL_ = [[self threadURL] absoluteString];
		NSString	*tmpURL_ = [NSString stringWithFormat : template_, beParam_, thURL_];
		
		//NSLog(@"%@", tmpURL_);
		NSURL	*accessURL_ = [NSURL URLWithString : tmpURL_];
		
		return [[NSWorkspace sharedWorkspace] openURL : accessURL_ inBackGround : [CMRPref openInBg]];
	}
	// 2ch thread
	if ([CMRThreadLinkProcessor parseThreadLink : aLink
				boardName : &boardName_
				 boardURL : &boardURL_
				 filepath : &filepath_]) {
		CMRDocumentFileManager	*dm;
		NSDictionary			*contentInfo_;
		NSString				*datIdentifier_;
		
		dm = [CMRDocumentFileManager defaultManager];
		datIdentifier_ = [dm datIdentifierWithLogPath : filepath_];
		contentInfo_ = [NSDictionary dictionaryWithObjectsAndKeys : 
							[boardURL_ absoluteString],
							BoardPlistURLKey,
							boardName_, 
							ThreadPlistBoardNameKey,
							datIdentifier_, 
							ThreadPlistIdentifierKey,
							nil];

		[dm ensureDirectoryExistsWithBoardName:boardName_];
		return [CMRThreadDocument showDocumentWithContentOfFile : filepath_
													contentInfo : contentInfo_];
	}
	
	// 2ch (or other) BBS
	if ([CMRThreadLinkProcessor parseBoardLink: aLink boardName: &boardName_ boardURL: &boardURL_]) {
		[[NSApp delegate] showThreadsListForBoard: boardName_ selectThread: nil addToListIfNeeded: YES];
		
		return YES;
	}

	if ([self tryPreviewLink:aLink]) {
		return YES;
	}

    return [[NSWorkspace sharedWorkspace] openURL : [NSURL URLWithLink : aLink] inBackGround : [CMRPref openInBg]];
}

#pragma mark CMRThreadView delegate
- (CMRThreadSignature *) threadSignatureForView : (CMRThreadView *) aView
{
	return [[self threadAttributes] threadSignature];
}
- (CMRThreadLayout *) threadLayoutForView : (CMRThreadView *) aView
{
	return [self threadLayout];
}
- (void) threadView : (CMRThreadView *) aView
	   messageReply : (NSRange        ) anIndexRange
{
	CMRReplyMessenger	*messenger_;

	[self reply : aView];
	messenger_ = [self messenger : YES];
	[self addMessenger: messenger_]; // 2006-06-06 Patch posted at CocoMonar Thread
	[messenger_ append:@"" quote:NO replyTo:anIndexRange.location];
}

// Available in Starlight Breaker.
- (void) threadView: (CMRThreadView *) aView reverseAnchorPopUp: (unsigned int) targetIndex locationHint: (NSPoint) location_
{
	NSRange				indexRange_;
	NSAttributedString	*contents_;
	
	indexRange_ = NSMakeRange(targetIndex, [[self threadLayout] firstUnlaidMessageIndex] - targetIndex);
	if (0 == indexRange_.length)
		return;
	
	contents_ = [[self threadLayout] contentsForIndexRange: indexRange_
											   targetIndex: targetIndex
											 composingMask: CMRInvisibleAbonedMask
												   compose: NO
											attributesMask: (CMRLocalAbonedMask|CMRSpamMask)];
	if (nil == contents_ || 0 == [contents_ length]) {
		NSString *notFoundString = [NSString stringWithFormat: [self localizedString: @"GyakuSansyou Not Found"], targetIndex+1];
		contents_ = [[[NSAttributedString alloc] initWithString: notFoundString] autorelease];
	}

	[CMRPopUpMgr showPopUpWindowWithContext: contents_
								  forObject: [self threadIdentifier]
									  owner: self
							   locationHint: location_];
}

// CometBlaster Addition
/*
- (BOOL) threadView: (CMRThreadView *) aView
	 validateAction: (SEL) aSelector
{
	// 将来のために
}
*/

// Spam Filter
- (IBAction) runSpamFilter : (id) sender
{
	CMRThreadLayout			*L;
	CMRThreadSignature		*threadID;
	
	L = [self threadLayout];
	threadID = [[self threadAttributes] threadSignature];
	if (nil == L || nil == threadID) 
		return;
	
	[[CMRSpamFilter sharedInstance]
		runFilterWithMessages : [L messageBuffer]
						 with : threadID];
}

/* CMRThreadViewerRunSpamFilterNotification */
- (void) threadViewerRunSpamFilter : (NSNotification *) theNotification
{
	UTILAssertNotificationName(
		theNotification,
		CMRThreadViewerRunSpamFilterNotification);
	
	if ([theNotification object] != self)
		return;
	
	if (NO == [CMRPref spamFilterEnabled])
		return;
	
	[self runSpamFilter : nil];
}
- (void) postRunSpamFilterNotification
{
	NSNotification		*notification_;
	
	notification_ = 
		[NSNotification notificationWithName : 
			CMRThreadViewerRunSpamFilterNotification
						object : self];
	[[NSNotificationQueue defaultQueue]
			enqueueNotification : notification_
			postingStyle : NSPostWhenIdle
			coalesceMask : NSNotificationCoalescingOnSender
			forModes : nil];
}
- (void) threadView : (CMRThreadView    *) aView
			   spam : (CMRThreadMessage *) aMessage
	messageRegister : (BOOL              ) registerFlag
{
	CMRSpamFilter			*filter_  = [CMRSpamFilter sharedInstance];
	CMRThreadLayout			*L		  = [self threadLayout];
	CMRThreadSignature		*threadID = [self threadSignatureForView : aView];
	
	if (nil == aMessage || nil == L || nil == threadID) return;
	
	if (registerFlag) {
		[filter_ addSample : aMessage
					  with : threadID];
		
		// 新しいサンプルを追加した場合のみ自動的に起動
		[self postRunSpamFilterNotification];
	} else {
		[filter_ removeSample : aMessage
						 with : threadID];
	}
	
/*
	本文の語句もチェックしていた場合、
	ここで実行していると、せっかく解除したレスが
	ふたたび迷惑レスに設定されてしまう可能性がある。
*/
	// [self postRunSpamFilterNotification];
}


- (BOOL) threadView : (CMRThreadView *) aView
	   mouseClicked : (NSEvent       *) theEvent
	        atIndex : (unsigned       ) charIndex
	   messageIndex : (unsigned       ) aMessageIndex
{
	if ([theEvent modifierFlags] & NSAlternateKeyMask) {
		NSPoint	winLocation = [theEvent locationInWindow];
		NSPoint	screenLocation = [[aView window] convertBaseToScreen: winLocation]; 
		[self threadView: aView reverseAnchorPopUp: aMessageIndex locationHint: screenLocation];
	} else {
	NSMenu		*menu_;
	
	menu_ = [aView messageMenuWithMessageIndex : aMessageIndex];
	[[menu_ class] popUpContextMenu:menu_ withEvent:theEvent forView:aView];
	}
	return YES;
}

#pragma mark SGHTMLView delegate
- (NSArray *) HTMLViewFilteringLinkSchemes : (SGHTMLView *) aView
{
	// "cmonar:", "mailto:"は無視
	// "cmbe:"も無視
	return [NSArray arrayWithObjects:
						CMRAttributeInnerLinkScheme,
						CMRAttributesBeProfileLinkScheme,
						@"mailto",
						nil];
}

- (BOOL) HTMLView : (SGHTMLView *) aView
	 mouseClicked : (NSEvent    *) theEvent
	      atIndex : (unsigned    ) charIndex
{
	return NO;
}

- (void)    HTMLView : (SGHTMLView *) aView
  mouseEnteredInLink : (id          ) aLink
      inTrackingRect : (NSRect      ) aRect
           withEvent : (NSEvent    *) anEvent
{
	NSPoint			location_;
	
	location_ = NSEqualRects(aRect, NSZeroRect)
			? [anEvent locationInWindow]
			: aRect.origin;
	location_ = [aView convertPoint:location_ toView:nil];
	location_ = [[aView window] convertBaseToScreen : location_];
	location_.y -= 1.0f;
	[self tryShowPopUpWindowWithLink : aLink
						locationHint : location_];
}

- (void)     HTMLView : (SGHTMLView *) aView
  mouseExitedFromLink : (id          ) aLink
       inTrackingRect : (NSRect      ) aRect
            withEvent : (NSEvent    *) anEvent
{
	[CMRPopUpMgr performClosePopUpWindowForObject : aLink];
}

// continuous mouseDown
- (BOOL)				 HTMLView : (SGHTMLView *) aView 
  shouldHandleContinuousMouseDown : (NSEvent	*) theEvent
{
	NSRange		selectedRange_;
	id			v;
	unichar		c;
	NSPoint		mouseLocation_;

	// ID ポップアップ
	mouseLocation_ = [aView convertPoint : [theEvent locationInWindow]
								fromView : nil];

	v = [aView attribute : BSMessageIDAttributeName
				 atPoint : mouseLocation_
		  effectiveRange : NULL];

	if (v != nil) return YES;

	selectedRange_ = [aView selectedRange];
	if (0 == selectedRange_.length) return NO;

	// レス番号ではポップアップしない
	v = [[aView textStorage] attribute : CMRMessageIndexAttributeName 
							   atIndex : selectedRange_.location
						effectiveRange : NULL];
	if (v != nil) return NO;
	
	c = [[aView string] characterAtIndex : selectedRange_.location];
	return [[NSCharacterSet numberCharacterSet_JP] characterIsMember : c];
}

- (BOOL)     HTMLView : (SGHTMLView *) aView 
  continuousMouseDown : (NSEvent    *) theEvent
{
	NSPoint				mouseLoc_;
	BOOL				isInside_;
	id					v;
	
	UTILRequireCondition((aView && theEvent), default_implementation);

	mouseLoc_ = (NSPeriodic == [theEvent type])
		? [[aView window] convertScreenToBase : [theEvent locationInWindow]]
		: [theEvent locationInWindow];
	mouseLoc_ = [aView convertPoint:mouseLoc_ fromView:nil];
	isInside_ = [aView mouse:mouseLoc_ inRect:[aView visibleRect]];
	
	v = [aView attribute : BSMessageIDAttributeName
				 atPoint : mouseLoc_
		  effectiveRange : NULL];

	if (v != nil) {
		// ID PopUp
		[self extractMessagesWithIDString: (NSString *)v popUpLocation: [theEvent locationInWindow]];
	} else {
		NSRange				selectedRange_;
		NSLayoutManager		*layoutManager_;
		NSRange				selectedGlyphRange_;
		NSRect				selection_;

		selectedRange_ = [aView selectedRange];
		UTILRequireCondition(selectedRange_.length, default_implementation);
		
		layoutManager_ = [aView layoutManager];
		UTILRequireCondition(layoutManager_, default_implementation);
		
		selectedGlyphRange_ = 
			[layoutManager_ glyphRangeForCharacterRange : selectedRange_
								   actualCharacterRange : NULL];
		UTILRequireCondition(selectedGlyphRange_.length, default_implementation);
		selection_ = 
			[layoutManager_ boundingRectForGlyphRange : selectedGlyphRange_
									  inTextContainer : [aView textContainer]];
		isInside_ = [aView mouse:mouseLoc_ inRect:selection_];
		UTILRequireCondition(isInside_, default_implementation);

		mouseLoc_.y = [aView isFlipped] 
						? NSMinY(selection_)
						: NSMaxY(selection_);
		mouseLoc_ = [aView convertPoint:mouseLoc_ toView:nil];
		mouseLoc_ = [[aView window] convertBaseToScreen : mouseLoc_];

		// テキストのドラッグを許すように、ここでは常にNOを返す。
		[self tryShowPopUpWindowSubstringWithRange : selectedRange_
									 inTextStorage : [aView textStorage]
									  locationHint : mouseLoc_];
	}
	return NO;
	
default_implementation:
	/*[NSMenu popUpContextMenu : [aView menu]
					   withEvent : theEvent
						 forView : aView];*/
	return YES;
}
@end
