/**
  * $Id: CMRThreadViewer-Link.m,v 1.7 2005/10/14 02:13:21 tsawada2 Exp $
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
#import "NSCharacterSet+CMXAdditions.h"
#import "CMXMenuHolder.h"
#import "CMRReplyMessenger.h"
#import "CMRThreadMessage.h"
#import "CMRThreadMessageBuffer.h"
#import "CMRMessageFilter.h"
#import "CMRSpamFilter.h"
#import "CMRThreadView.h"
#import "CMRDocumentFileManager.h"

#import <SGAppKit/NSWorkspace-SGExtensions.h>



#import "CMRNetRequestQueue.h"


NSString *const CMRThreadViewerRunSpamFilterNotification = @"CMRThreadViewerRunSpamFilterNotification";

// for debugging only
#define UTIL_DEBUGGING				0
#import "UTILDebugging.h"



/*
[feature: URL preview] by nmatz
application tries to open specific .html file if option key pressed.
when open this file, '%%%ClickedLink%%%' keyword in file will be replaced
to link acctually clicked.
*/
#define PREVIEW_SRC			@"PreviewSource"
#define PREVIEW_TYPE		@"html"
#define PREVIEW_DIR			@"Preview"
#define PREVIEW_ENC			NSShiftJISStringEncoding
#define PREVIEW_URL_KEY		@"%%%ClickedLink%%%"
#define PREVIEW_FILENAME	@"Preview.html"

/*** KeyValueTemplate ***/
/* lNumber(BOOL) Launch external program when preview link? */
#define PREVIEW_EXT_SRC		@"preview"
#define PREVIEW_EXT_TYPE	nil
#define PREVIEW_EXT_KEY		@"Thread - LaunchExternalProgramOnPreviewLink"

#define kBeProfileLinkTemplateKey	@"System - be2ch Profile URL"



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
		
		dict_ = [[[NSDictionary alloc] initWithContentsOfFile:logPath_] autorelease];
		if (!dict_) {
			// ThreadsList.plist があるか
			NSString		*plistPath_;
			plistPath_ = [[CMRDocumentFileManager defaultManager] threadsListPathWithBoardName : boardName_];

			if ([[NSFileManager defaultManager] isReadableFileAtPath:plistPath_] ) {
				// ThreadsList.plist がある
				NSArray	*threadsList_, *idArray_;
				int tIndex_ = 0;

				threadsList_ = [NSArray arrayWithContentsOfFile : plistPath_];
				// valueForKey: is available in Mac OS X 10.3 and later.
				idArray_ = [threadsList_ valueForKey : ThreadPlistIdentifierKey];
				tIndex_ = [idArray_ indexOfObject : [[logPath_ stringByDeletingPathExtension] lastPathComponent]];
				// ThreadsList.plist の中にスレタイがある場合はそれを使う
				if (tIndex_ != NSNotFound) {
					NSString *title_ = [[threadsList_ objectAtIndex : tIndex_] valueForKey : CMRThreadTitleKey];
					template_ = [[[NSAttributedString alloc] initWithString : title_] autorelease];
					if (!template_) goto ErrInvalidLink;

					[kBuffer setAttributedString : template_];
				} else {
					goto ErrInvalidLink;
				}
			} else {
				goto ErrInvalidLink;
			}
		} else {
			attr_ = [[[CMRThreadAttributes alloc] initWithDictionary:dict_] autorelease];
		
			// 暫定的に表示内容は「情報を表示」のものをそのまま借用してます。
			// ポップアップが大きすぎると言う苦情がくるかもしれません。 by masakih
		
			/* 2005-06-06 tsawada2 <ben-sawa@td5.so-net.ne.jp>
			   やはりポップアップが大きすぎる気がするので、表示内容をスレタイのみに限定してみる。
			*/
			template_ = [[[NSAttributedString alloc] initWithString : [attr_ threadTitle]] autorelease];
			if (!template_) goto ErrInvalidLink;
		
			[kBuffer setAttributedString : template_];
		}
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



@implementation CMRThreadViewer (NSTextViewDelegate)
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


- (BOOL) HTMLView : (SGHTMLView *) aView
	 mouseClicked : (NSEvent    *) theEvent
	      atIndex : (unsigned    ) charIndex
{
	return NO;
}



static NSString *previewSourceHTMLFilepath(NSString *resourceName, NSString *aType)
{
	NSBundle	*bundle_;
	NSString	*path_;
	
	bundle_ = [NSBundle applicationSpecificBundle];
	path_ = [bundle_ pathForResource:resourceName ofType:aType inDirectory:PREVIEW_DIR];
	if (path_) return path_;
	
	bundle_ = [NSBundle mainBundle];
	path_ = [bundle_ pathForResource:resourceName ofType:aType inDirectory:PREVIEW_DIR];
	
	return path_;
}

/*
 launch extern program using NSTask with argument (URL)
   by 1077693166/260
 */
- (BOOL) previewLinkWithExternalProgram : (id) aLink
{
	NSString	*path_;
	NSTask          *task_;
	
	path_ = previewSourceHTMLFilepath(PREVIEW_EXT_SRC, PREVIEW_EXT_TYPE);
	if (nil == path_) return NO;
	
	task_ = [[NSTask alloc] init];
	[task_ setLaunchPath : path_];
	[task_ setCurrentDirectoryPath : [path_ stringByDeletingLastPathComponent]];
	[task_ setArguments : [NSArray arrayWithObject : [aLink stringValue]]];
	[task_ launch];
	[task_ autorelease];
	return YES;
}
- (BOOL) previewLinkWithWebBrowser : (id) aLink
{
	NSString	*path_;
	NSData		*data_;
	NSString	*src_;
	NSURL		*previewURL_;
	
	path_ = previewSourceHTMLFilepath(PREVIEW_SRC, PREVIEW_TYPE);
	if (nil == path_) return NO;
	
	data_ = [NSData dataWithContentsOfFile : path_];
	src_ = [NSString stringWithData:data_ encoding:PREVIEW_ENC];
	if (nil == src_) return NO;
	
	// replace keyword to URL
	src_ = [src_ stringByReplaceCharacters : PREVIEW_URL_KEY
								  toString : [aLink stringValue]];
	
	path_ = [path_ stringByDeletingLastPathComponent];
	path_ = [path_ stringByAppendingPathComponent : PREVIEW_FILENAME];
	previewURL_ = [NSURL fileURLWithPath : path_];
	
	[src_ writeToFile:path_ atomically:YES];	
	
	return [[NSWorkspace sharedWorkspace] openURL : previewURL_ inBackGround : [CMRPref openInBg]];
}

// Added in Lemonade and later.
- (BOOL) previewLinkWithImageInspector : (id) aLink
{
	NSURL		*previewURL_;

	previewURL_ = [NSURL URLWithLink : aLink];
	return [[CMRPref sharedImagePreviewer] showImageWithURL : previewURL_];
}

- (BOOL) previewLink : (id) aLink
{
	/*return SGTemplateBool(PREVIEW_EXT_KEY) 
			? [self previewLinkWithExternalProgram : aLink]
			: [self previewLinkWithWebBrowser : aLink];*/
	id	tmp_;
	tmp_ = SGTemplateResource(PREVIEW_EXT_KEY);
	UTILAssertRespondsTo(tmp_, @selector(intValue));

	switch([tmp_ intValue]){
	case 0:
		return [self previewLinkWithWebBrowser : aLink];
		break;
	case 1:
		return [self previewLinkWithExternalProgram : aLink];
		break;
	case 2:
		return [self previewLinkWithImageInspector : aLink];
		break;
	default:
		return [self previewLinkWithWebBrowser : aLink];
		break;
	}

}

- (BOOL) tryPreviewLink : (id) aLink
{
	NSEvent			*theEvent;
	unsigned int	flags_;
	
	theEvent = [[self window] currentEvent];
	UTILAssertNotNil(theEvent);
	
	flags_ = [theEvent modifierFlags];
	if ( !(flags_ & NSAlternateKeyMask) )
		return NO;
	
	return [self previewLink : aLink];
}


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
	
	/*
	2004-02-29 Takanori Ishikawa <takanori@gd5.so-net.ne.jp>
	----------------------------------------
	[feature: URL preview] by nmatz
	application tries to open specific .html file if option key pressed.
	when open this file, '%%%ClickedLink%%%' keyword in file will be replaced
	to link acctually clicked.
	*/
	if ([self tryPreviewLink:aLink]) {
		return YES;
	}
    return [[NSWorkspace sharedWorkspace] openURL : [NSURL URLWithLink : aLink] inBackGround : [CMRPref openInBg]];
}

// CMRThreadView delegate
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
	[messenger_ append:@"" quote:NO replyTo:anIndexRange.location];
}


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
	NSMenu		*menu_;
	
	menu_ = [aView messageMenuWithMessageIndex : aMessageIndex];
	[[menu_ class] popUpContextMenu:menu_ withEvent:theEvent forView:aView];
	
	return YES;
}

// SGHTMLView delegate
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
	NSRange				selectedRange_;
	NSLayoutManager		*layoutManager_;
	NSRange				selectedGlyphRange_;
	NSRect				selection_;
	BOOL				isInside_;
	
	UTILRequireCondition((aView && theEvent), default_implementation);
	
	mouseLoc_ = (NSPeriodic == [theEvent type])
		? [[aView window] convertScreenToBase : [theEvent locationInWindow]]
		: [theEvent locationInWindow];
	mouseLoc_ = [aView convertPoint:mouseLoc_ fromView:nil];
	isInside_ = [aView mouse:mouseLoc_ inRect:[aView visibleRect]];
	
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
	return NO;
	
	default_implementation:
/*		[NSMenu popUpContextMenu : [aView menu]
					   withEvent : theEvent
						 forView : aView];
*/		return YES;
}
@end
