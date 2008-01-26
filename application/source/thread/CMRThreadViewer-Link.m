//
//  CMRThreadViewer-Link.m
//  BathyScaphe
//
//  Updated by Tsutomu Sawada on 07/11/19.
//  Copyright 2005-2007 BathyScaphe Project. All rights reserved.
//  encoding="UTF-8"
//

#import "CMRThreadViewer_p.h"
#import "CMRThreadLinkProcessor.h"
#import "CMRMessageAttributesTemplate.h"
#import "CMRThreadLayout.h"
#import "SGHTMLView.h"
#import "CMXPopUpWindowManager.h"
#import "CMRReplyMessenger.h"
#import "CMRMessageFilter.h"
#import "CMRSpamFilter.h"
#import "CMRThreadView.h"
#import "SGLinkCommand.h"
#import "BSAsciiArtDetector.h"
#import "DatabaseManager.h"
#import "missing.h"
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

- (BOOL)isMessageLink:(id)aLink messageIndexes:(NSIndexSet **)indexesPtr;
- (NSIndexSet *)isStandardMessageLink:(id)aLink;
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
				title_ = [NSString stringWithFormat: @"%@ %C %@",
												 threadTitle, 0x2014,
												 boardName_];
			} else {
				title_ = boardName_;
			}

			template_ = [[[NSAttributedString alloc] initWithString: title_] autorelease];
			if (!template_) goto ErrInvalidLink;

			[kBuffer setAttributedString: template_];

		} else {
			attr_ = [[[CMRThreadAttributes alloc] initWithDictionary: dict_] autorelease];
			title_ = [NSString stringWithFormat: @"%@ %C %@", [attr_ threadTitle], 0x2014, boardName_];

			template_ = [[[NSAttributedString alloc] initWithString: title_] autorelease];
			if (!template_) goto ErrInvalidLink;
		
			[kBuffer setAttributedString: template_];
		}
	} else if ([CMRThreadLinkProcessor parseBoardLink: aLink boardName: &boardName_ boardURL: &boardURL_]) {
		[kBuffer setAttributedString: [[[NSAttributedString alloc] initWithString: boardName_] autorelease]];
	} else {
		NSIndexSet	*indexes;
		NSAttributedString		*message_;
		
		if (![self isMessageLink:aLink messageIndexes:&indexes]) goto ErrInvalidLink;
		message_ = [[self threadLayout] contentsForIndexes:indexes];
		if (message_) [kBuffer appendAttributedString:message_];
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

- (NSIndexSet *)isStandardMessageLink:(id)aLink
{
	NSURL			*link_;
	CMRHostHandler	*handler_;
	NSString		*bbs_;
	NSString		*key_;
	
	unsigned int	stIndex_;
	unsigned int	endIndex_;
	NSRange			moveRange_;
	
	link_ = [NSURL URLWithLink:aLink];
	handler_ = [CMRHostHandler hostHandlerForURL:link_];
	if (!handler_) return nil;
	
	if (![handler_ parseParametersWithReadURL:link_
										  bbs:&bbs_
										  key:&key_
										start:&stIndex_
										   to:&endIndex_
									showFirst:NULL]) {
		return nil;
	}
	
	if (NSNotFound != stIndex_) {
		moveRange_.location = stIndex_ -1;
		moveRange_.length = (endIndex_ - stIndex_) +1;
	} else {
		return nil;		
	}
	
	// 同じ掲示板の同じスレッドならメッセージ移動処理
	if ([[self bbsIdentifier] isEqualToString:bbs_] && [[self datIdentifier] isEqualToString:key_]) {
		return [NSIndexSet indexSetWithIndexesInRange:moveRange_];
	}
	
	return nil;
}

- (BOOL)isMessageLink:(id)aLink messageIndexes:(NSIndexSet **)indexesPtr
{
	NSIndexSet		*indexes;
	if (!aLink) return NO;

	if ([CMRThreadLinkProcessor isMessageLinkUsingLocalScheme:aLink messageIndexes:indexesPtr]) {
		return YES;
	} else if (indexes = [self isStandardMessageLink:aLink]) {
		if (indexesPtr != NULL) *indexesPtr = indexes;
		return YES;
	}

	return NO;
}
@end

#pragma mark -

@implementation CMRThreadViewer (NSTextViewDelegate)
- (void)openMessagesWithIndexes:(NSIndexSet *)indexes
{
	if (!indexes || [indexes count] == 0) {
        return;
    }

    NSURL *boardURL = [self boardURL];
    CMRHostHandler *handler = [CMRHostHandler hostHandlerForURL:[self boardURL]];
	NSURL *url = [handler readURLWithBoard:boardURL datName:[self datIdentifier] start:[indexes firstIndex]+1 end:[indexes lastIndex]+1 nofirst:YES];

    if (url) {
        [[NSWorkspace sharedWorkspace] openURL:url inBackground:[CMRPref openInBg]];
	}
}

#pragma mark Previewing (or Downloading) Link
static inline NSString *urlPathExtension(NSURL *url)
{
	CFStringRef extensionRef = CFURLCopyPathExtension((CFURLRef)url);
	if (!extensionRef) {
		return nil;
	}
	NSString *extension = [(NSString *)extensionRef lowercaseString];
	CFRelease(extensionRef);
	return extension;
}

- (BOOL)previewOrDownloadURL:(NSURL *)url
{
	NSArray		*extensions = [CMRPref linkDownloaderExtensionTypes];
	NSString	*linkExtension = urlPathExtension(url);

	if (linkExtension && [extensions containsObject:linkExtension]) {
		SGDownloadLinkCommand *dlCmd = [SGDownloadLinkCommand functorWithObject:[url absoluteString]];
		[dlCmd execute:self];
		return YES;
	}

	id<BSImagePreviewerProtocol>	previewer = [CMRPref sharedImagePreviewer];
	if (!previewer) return NO;
	return [previewer validateLink:url] ? [previewer showImageWithURL:url] :NO;
}

- (BOOL)handleExternalLink:(id)aLink forView:(NSView *)aView
{
	BOOL			shouldPreviewWithNoModifierKey = [CMRPref previewLinkWithNoModifierKey];
	BOOL			isOptionKeyPressed;
	BOOL			isFileURL;
	NSURL			*url = [NSURL URLWithLink:aLink];
	NSEvent			*theEvent;
	
	theEvent = [[aView window] currentEvent];
	UTILAssertNotNil(theEvent);

	isOptionKeyPressed = (([theEvent modifierFlags] & NSAlternateKeyMask) == NSAlternateKeyMask);
	isFileURL = [url isFileURL];

	if (shouldPreviewWithNoModifierKey) {
		if (!isOptionKeyPressed && !isFileURL) {
			if ([self previewOrDownloadURL:url]) return YES;
		}
	} else {
		if (isOptionKeyPressed && !isFileURL) {
			if ([self previewOrDownloadURL:url]) return YES;
		}
	}
	return [[NSWorkspace sharedWorkspace] openURL:url inBackground:[CMRPref openInBg]];
}

#pragma mark NSTextView Delegate
- (void)textView:(NSTextView *)aTextView clickedOnCell:(id <NSTextAttachmentCell>)cell inRect:(NSRect)cellFrame atIndex:(unsigned)charIndex
{
	if ([[self threadLayout] respondsToSelector:_cmd]) {
		[[self threadLayout] textView:aTextView clickedOnCell:cell inRect:cellFrame atIndex:charIndex];
	}
}

- (BOOL)textView:(NSTextView *)textView clickedOnLink:(id)aLink atIndex:(unsigned)charIndex
{
	NSString		*boardName_;
	NSURL			*boardURL_;
	NSString		*filepath_;
	NSString		*beParam_;
	NSIndexSet		*indexes;

	// 同じスレッドのレスへのアンカー
    if ([self isMessageLink:aLink messageIndexes:&indexes]) {
		int action = [CMRPref threadViewerLinkType];
		if ([indexes firstIndex] != NSNotFound) {
			switch (action) {
            case ThreadViewerMoveToIndexLinkType:
                [self scrollMessageAtIndex:[indexes firstIndex]];
                break;
            case ThreadViewerOpenBrowserLinkType:
				[self openMessagesWithIndexes:indexes];
                break;
            case ThreadViewerResPopUpLinkType:
                break;
            default:
                break;
            }
        }
        
        return YES;
	}

	// be Profile
	if ([CMRThreadLinkProcessor isBeProfileLinkUsingLocalScheme:aLink linkParam:&beParam_]) {
		NSString	*template_ = SGTemplateResource(kBeProfileLinkTemplateKey);
		NSString	*thURL_ = [[self threadURL] absoluteString];
		NSString	*tmpURL_ = [NSString stringWithFormat:template_, beParam_, thURL_];

		NSURL	*accessURL_ = [NSURL URLWithString:tmpURL_];
		
		return [[NSWorkspace sharedWorkspace] openURL:accessURL_ inBackground:[CMRPref openInBg]];
	}

	// 2ch thread
	if ([CMRThreadLinkProcessor parseThreadLink:aLink boardName:&boardName_ boardURL:&boardURL_ filepath:&filepath_]) {
		CMRDocumentFileManager	*dm;
		NSDictionary			*contentInfo_;
		NSString				*datIdentifier_;
		
		dm = [CMRDocumentFileManager defaultManager];
		datIdentifier_ = [dm datIdentifierWithLogPath:filepath_];
		contentInfo_ = [NSDictionary dictionaryWithObjectsAndKeys:
							[boardURL_ absoluteString], BoardPlistURLKey,
							boardName_, ThreadPlistBoardNameKey,
							datIdentifier_, ThreadPlistIdentifierKey,
							nil];

		[dm ensureDirectoryExistsWithBoardName:boardName_];
		return [CMRThreadDocument showDocumentWithContentOfFile:filepath_ contentInfo:contentInfo_];
	}
	
	// 2ch (or other) BBS
	if ([CMRThreadLinkProcessor parseBoardLink:aLink boardName:&boardName_ boardURL:&boardURL_]) {
		[[NSApp delegate] showThreadsListForBoard:boardName_ selectThread:nil addToListIfNeeded:YES];
		return YES;
	}

	// 外部リンクと判断
	return [self handleExternalLink:aLink forView:textView];
}

#pragma mark CMRThreadView delegate
- (CMRThreadSignature *)threadSignatureForView:(CMRThreadView *)aView
{
	return [[self threadAttributes] threadSignature];
}
- (CMRThreadLayout *)threadLayoutForView:(CMRThreadView *)aView
{
	return [self threadLayout];
}

- (void)threadView:(CMRThreadView *)aView messageReply:(NSRange)anIndexRange
{
	[self reply:aView];
	[[self replyMessenger] append:@"" quote:NO replyTo:anIndexRange.location];
}

// Available in Starlight Breaker.
- (void)threadView:(CMRThreadView *)aView reverseAnchorPopUp:(unsigned int)targetIndex locationHint:(NSPoint)location_
{
	NSAttributedString *contents_;
	contents_ = [[self threadLayout] contentsForTargetIndex:targetIndex
											 composingMask:CMRInvisibleAbonedMask
												   compose:NO
											attributesMask:(CMRLocalAbonedMask|CMRSpamMask)];
	if (!contents_ || [contents_ length] == 0) {
		NSString *notFoundString = [NSString stringWithFormat:[self localizedString: @"GyakuSansyou Not Found"], targetIndex+1];
		contents_ = [[[NSAttributedString alloc] initWithString:notFoundString] autorelease];
	}

	[CMRPopUpMgr showPopUpWindowWithContext:contents_
								  forObject:[self threadIdentifier]
									  owner:self
							   locationHint:location_];
}

// AA Filter
- (IBAction)runAsciiArtDetector:(id)sender
{
	CMRThreadLayout			*layout;
	CMRThreadSignature		*threadID;
	
	layout = [self threadLayout];
	threadID = [[self threadAttributes] threadSignature];
	if (!layout || !threadID) {
		return;
	}
	[[BSAsciiArtDetector sharedInstance] runDetectorWithMessages:[layout messageBuffer] with:threadID];
}

// Spam Filter
- (IBAction)runSpamFilter:(id)sender
{
	CMRThreadLayout			*layout;
	CMRThreadSignature		*threadID;
	
	layout = [self threadLayout];
	threadID = [[self threadAttributes] threadSignature];
	if (!layout || !threadID) {
		return;
	}
	[[CMRSpamFilter sharedInstance] runFilterWithMessages:[layout messageBuffer] with:threadID];
}

/* CMRThreadViewerRunSpamFilterNotification */
- (void)threadViewerRunSpamFilter:(NSNotification *)theNotification
{
	UTILAssertNotificationName(theNotification, CMRThreadViewerRunSpamFilterNotification);
	
	if ([theNotification object] != self) return;
	
	if ([CMRPref spamFilterEnabled]) {
		[self runSpamFilter:nil];
	}
}

- (void)postRunSpamFilterNotification
{
	NSNotification		*notification;
	
	notification = [NSNotification notificationWithName:CMRThreadViewerRunSpamFilterNotification object:self];
	[[NSNotificationQueue defaultQueue] enqueueNotification:notification postingStyle:NSPostWhenIdle coalesceMask:NSNotificationCoalescingOnSender forModes:nil];
}

- (void)threadView:(CMRThreadView *)aView spam:(CMRThreadMessage *)aMessage messageRegister:(BOOL)registerFlag
{
	CMRSpamFilter			*filter = [CMRSpamFilter sharedInstance];
	CMRThreadSignature		*threadID = [self threadSignatureForView:aView];
	
	if (!aMessage || !threadID) return;

	if (registerFlag) {
		[filter addSample:aMessage with:threadID];
		[self postRunSpamFilterNotification];	// 新しいサンプルを追加した場合のみ自動的に起動
	} else {
		[filter removeSample:aMessage with:threadID];
	}
}

- (BOOL)threadView:(CMRThreadView *)aView
	  mouseClicked:(NSEvent *)theEvent
		   atIndex:(unsigned)charIndex
	  messageIndex:(unsigned)aMessageIndex
{
	if ([theEvent modifierFlags] & NSAlternateKeyMask) {
		NSPoint	winLocation = [theEvent locationInWindow];
		NSPoint	screenLocation = [[aView window] convertBaseToScreen: winLocation]; 
		[self threadView:aView reverseAnchorPopUp:aMessageIndex locationHint:screenLocation];
	} else {
		NSMenu	*menu_ = [aView messageMenuWithMessageIndex:aMessageIndex];
		[NSMenu popUpContextMenu:menu_ withEvent:theEvent forView:aView];
	}
	return YES;
}

#pragma mark SGHTMLView delegate
- (NSArray *)HTMLViewFilteringLinkSchemes:(SGHTMLView *)aView
{
	// "cmonar:", "mailto:", "cmbe:" をフィルタ
	static NSArray *cachedLinkSchemes = nil;
	if (!cachedLinkSchemes) {
		cachedLinkSchemes = [[NSArray alloc] initWithObjects:CMRAttributeInnerLinkScheme, CMRAttributesBeProfileLinkScheme, @"mailto", nil];
	}
	return cachedLinkSchemes;
}

- (void)HTMLView:(SGHTMLView *)aView mouseEnteredInLink:(id)aLink inTrackingRect:(NSRect)aRect withEvent:(NSEvent *)anEvent
{
	NSPoint			location_;
	
	location_ = NSEqualRects(aRect, NSZeroRect) ? [anEvent locationInWindow] : aRect.origin;
	location_ = [aView convertPoint:location_ toView:nil];
	location_ = [[aView window] convertBaseToScreen:location_];
	location_.y -= 1.0f;

	[self tryShowPopUpWindowWithLink:aLink locationHint:location_];
}

- (void)HTMLView:(SGHTMLView *)aView mouseExitedFromLink:(id)aLink inTrackingRect:(NSRect)aRect withEvent:(NSEvent *)anEvent
{
	[CMRPopUpMgr performClosePopUpWindowForObject:aLink];
}

// continuous mouseDown
- (BOOL)HTMLView:(SGHTMLView *)aView shouldHandleContinuousMouseDown:(NSEvent *)theEvent
{
	NSRange		selectedRange_;
	id			v;
	unichar		c;
	NSPoint		mouseLocation_;

	// ID ポップアップ
	mouseLocation_ = [aView convertPoint:[theEvent locationInWindow] fromView:nil];

	v = [aView attribute:BSMessageIDAttributeName atPoint:mouseLocation_ effectiveRange:NULL];

	if (v) return YES;

	selectedRange_ = [aView selectedRange];
	if (0 == selectedRange_.length) return NO;

	// レス番号ではポップアップしない
	v = [[aView textStorage] attribute:CMRMessageIndexAttributeName 
							   atIndex:selectedRange_.location
						effectiveRange:NULL];
	if (v) return NO;
	
	c = [[aView string] characterAtIndex:selectedRange_.location];
	return [[NSCharacterSet numberCharacterSet_JP] characterIsMember:c];
}

- (BOOL)HTMLView:(SGHTMLView *)aView continuousMouseDown:(NSEvent *)theEvent
{
	NSPoint	mouseLoc_;
	BOOL	isInside_;
	id		value;
	
	UTILRequireCondition((aView && theEvent), default_implementation);

	mouseLoc_ = (NSPeriodic == [theEvent type])
		? [[aView window] convertScreenToBase:[theEvent locationInWindow]]
		: [theEvent locationInWindow];
	mouseLoc_ = [aView convertPoint:mouseLoc_ fromView:nil];
	isInside_ = [aView mouse:mouseLoc_ inRect:[aView visibleRect]];
	
	value = [aView attribute:BSMessageIDAttributeName atPoint:mouseLoc_ effectiveRange:NULL];

	if (value) {
		// ID PopUp
		[self extractMessagesWithIDString:(NSString *)value popUpLocation:[theEvent locationInWindow]];
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
			[layoutManager_ glyphRangeForCharacterRange:selectedRange_
								   actualCharacterRange:NULL];
		UTILRequireCondition(selectedGlyphRange_.length, default_implementation);
		selection_ = 
			[layoutManager_ boundingRectForGlyphRange:selectedGlyphRange_
									  inTextContainer:[aView textContainer]];
		isInside_ = [aView mouse:mouseLoc_ inRect:selection_];
		UTILRequireCondition(isInside_, default_implementation);

		mouseLoc_.y = [aView isFlipped] 
						? NSMinY(selection_)
						: NSMaxY(selection_);
		mouseLoc_ = [aView convertPoint:mouseLoc_ toView:nil];
		mouseLoc_ = [[aView window] convertBaseToScreen:mouseLoc_];

		// テキストのドラッグを許すように、ここでは常にNOを返す。
		[self tryShowPopUpWindowSubstringWithRange:selectedRange_
									 inTextStorage:[aView textStorage]
									  locationHint:mouseLoc_];
	}
	return NO;
	
default_implementation:
	return YES;
}
@end
