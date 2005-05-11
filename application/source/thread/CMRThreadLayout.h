//: CMRThreadLayout.h
/**
  * $Id: CMRThreadLayout.h,v 1.1.1.1 2005/05/11 17:51:07 tsawada2 Exp $
  * 
  * CMRThreadLayout.h
  *
  * Copyright (c) 2003, Takanori Ishikawa.
  * See the file LICENSE for copying permission.
  */
#import <Cocoa/Cocoa.h>
#import "CMRTask.h"
#import "CMXInternalMessaging.h"

@protocol CMRThreadLayoutTask;
@class SGBaseRangeArray;
@class CMRThreadView;
@class CMRThreadMessage;
@class CMRThreadMessageBuffer;



@interface CMRThreadLayout : NSObject
{
	@private
	CMRThreadView		*_textView;
	CMXWorkerContext	*_worker;

	NSLock					*_messagesLock;
	SGBaseRangeArray		*_messageRanges;
	CMRThreadMessageBuffer	*_messageBuffer;
	
	BOOL		_isMessagesEdited;
}
- (id) initWithTextView : (NSTextView *) aTextView;
- (void) run;

- (void) push : (id<CMRThreadLayoutTask>) aTask;

/*** Worker context ***/
- (BOOL) isInProgress;

// delete contents, properties
- (void) clear;
- (void) disposeLayoutContext;

- (BOOL) isMessagesEdited;
- (void) setMessagesEdited : (BOOL) flag;
@end



@interface CMRThreadLayout(MessageRange)
- (unsigned int) numberOfReadedMessages;
- (unsigned int) firstUnlaidMessageIndex;

/* [self numberOfReadedMessages] == [self firstUnlaidMessageIndex] */
- (BOOL) isCompleted;

- (NSRange) rangeAtMessageIndex : (unsigned int) index;

- (unsigned int) messageIndexForRange : (NSRange) aRange;
- (unsigned int) lastMessageIndexForRange : (NSRange) aRange;

- (NSAttributedString *) contentsAtIndex : (unsigned int) index;
- (NSAttributedString *) contentsForIndexRange : (NSRange) range;
- (NSAttributedString *) contentsForIndexRange : (NSRange) range
			 					 composingMask : (UInt32 ) composingMask
									   compose : (BOOL   ) doCompose
								attributesMask : (UInt32 ) attributesMask;

- (unsigned) numberOfMessagesPerOnTheFly;
- (void) ensureMessageToBeVisibleAtIndex : (unsigned) anIndex;
- (void) ensureMessageToBeVisibleAtIndex : (unsigned) anIndex
						  effectsLongest : (BOOL) longestFlag;


// 次／前のレス
- (unsigned int) nextMessageIndexOfIndex : (unsigned int) index
							   attribute : (UInt32      ) flags
								   value : (BOOL        ) attributeIsSet;
- (unsigned int) previousMessageIndexOfIndex : (unsigned int) index
								   attribute : (UInt32      ) flags
									   value : (BOOL        ) attributeIsSet;

// 移動可能なインデックス
- (unsigned) nextVisibleMessageIndex;
- (unsigned) previousVisibleMessageIndex;
- (unsigned int) nextVisibleMessageIndexOfIndex : (unsigned int) index;
- (unsigned int) previousVisibleMessageIndexOfIndex : (unsigned int) index;

// ブックマークされたレスの移動
- (unsigned) nextBookmarkIndex;
- (unsigned) previousBookmarkIndex;
- (unsigned int) nextBookmarkIndexOfIndex : (unsigned int) index;
- (unsigned int) previousBookmarkIndexOfIndex : (unsigned int) index;

- (void) drawViewBackgroundInRect : (NSRect) clipRect;
@end



@interface CMRThreadLayout(DocuemntVisibleRect)
- (unsigned int) messageIndexForDocuemntVisibleRect;
- (void) scrollMessageAtIndex : (unsigned) anIndex;
- (IBAction) scrollToLastUpdatedIndex : (id) sender;
@end



@interface CMRThreadLayout(Attachment)
/* Message Proxy */
- (void) fixEllipsisProxyAttachment;
- (void) insertEllipsisProxyAttachment:(NSMutableAttributedString*) aBuffer
 atIndex:(unsigned) charIndex fromIndex:(unsigned) fromIndex toIndex:(unsigned) toIndex;

/* lastUpdated Header */
- (NSDate *) lastUpdatedDateFromHeaderAttachment;
- (NSRange) firstLastUpdatedHeaderAttachmentRange;
- (NSDate *) lastUpdatedDateFromFirstHeaderAttachmentEffectiveRange : (NSRangePointer) effectiveRange;

- (void) appendLastUpdatedHeader;
- (void) clearLastUpdatedHeader;
@end



@interface CMRThreadLayout(Accessor)
- (SGInternalMessenger *) runLoopMessenger;

- (CMRThreadView *) textView;
- (void) setTextView : (CMRThreadView *) aTextView;

- (NSLayoutManager *) layoutManager;
- (NSTextContainer *) textContainer;
- (NSTextStorage *) textStorage;
- (NSScrollView *) scrollView;

- (CMRThreadMessage *) messageAtIndex : (unsigned) anIndex;
- (void) updateMessageAtIndex : (unsigned) anIndex;
- (void) changeAllMessageAttributes : (BOOL  ) onOffFlag
							  flags : (UInt32) mask;
- (unsigned) numberOfMessageAttributes : (UInt32) mask;

- (SGBaseRangeArray *) messageRanges;
- (void) addMessageRange : (NSRange) range;
- (void) slideMessageRanges : (int     ) changeInLength
			   fromLocation : (unsigned) fromLocation;

- (CMRThreadMessageBuffer *) messageBuffer;
- (NSEnumerator *) messageEnumerator;

- (void) addMessagesFromBuffer : (CMRThreadMessageBuffer *) otherBuffer;
@end
