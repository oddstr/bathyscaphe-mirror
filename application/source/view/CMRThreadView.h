/**
  * $Id: CMRThreadView.h,v 1.3 2007/01/07 17:04:24 masakih Exp $
  * 
  * CMRThreadView.h
  *
  * Copyright (c) 2003-2004 Takanori Ishikawa, All rights reserved.
  * See the file LICENSE for copying permission.
  */
#import <Cocoa/Cocoa.h>
#import "SGHTMLView.h"

@class CMRThreadLayout;
@class CMRThreadSignature;
@class CMRThreadMessage;

@interface CMRThreadView : SGHTMLView
{
	@private
	unsigned		_lastCharIndex;		/* menuForEvent: */
	// ReinforceII
	BOOL			draggingHilited;
	NSTimeInterval	draggingTimer;
}
// delegate's layout
- (CMRThreadLayout *) threadLayout;

- (NSEnumerator *) indexEnumeratorWithIndexRange : (NSRange) anIndexRange;
- (NSArray *) indexArrayWithIndexRange : (NSRange) anIndexRange;
- (NSEnumerator *) selectedMessageIndexEnumerator;

+ (NSMenu *) messageMenu;
- (NSMenu *) messageMenuWithMessageIndex : (unsigned) aMessageIndex;
- (NSMenu *) messageMenuWithMessageIndexRange : (NSRange) anIndexRange;
@end



@interface NSObject(CMRThreadViewDelegate)
- (CMRThreadSignature *) threadSignatureForView : (CMRThreadView *) aView;
- (CMRThreadLayout *) threadLayoutForView : (CMRThreadView *) aView;
- (void) threadView : (CMRThreadView *) aView
	   messageReply : (NSRange        ) anIndexRange;
// Spam Filter
- (void) threadView : (CMRThreadView    *) aView
			   spam : (CMRThreadMessage *) aMessage
	messageRegister : (BOOL              ) registerFlag;

- (BOOL) threadView : (CMRThreadView *) aView
	   mouseClicked : (NSEvent       *) theEvent
	        atIndex : (unsigned       ) charIndex
	   messageIndex : (unsigned       ) aMessageIndex;

// Available in CometBlaster and later. but currently not used.
- (BOOL) threadView: (CMRThreadView *) aView
	 validateAction: (SEL) aSelector;

// ReinforceII Drag & Drop behavior util
- (void) setThreadContentWithThreadIdentifier : (id) aThreadIdentifier;
@end
