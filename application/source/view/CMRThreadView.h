//
//  CMRThreadView.h
//  BathyScaphe
//
//  Updated by Tsutomu Sawada on 07/09/07.
//  Copyright 2005-2007 BathyScaphe Project. All rights reserved.
//  encoding="UTF-8"
//

#import <Cocoa/Cocoa.h>
#import "SGHTMLView.h"

@class CMRThreadLayout;
@class CMRThreadSignature;
@class CMRThreadMessage;

@interface CMRThreadView : SGHTMLView
{
	@private
	unsigned		m_lastCharIndex;		/* For -menuForEvent: */

	BOOL			draggingHilited;
	NSTimeInterval	draggingTimer;	
}

// delegate's layout
- (CMRThreadLayout *)threadLayout;

// Available in Twincam Angel and later.
- (NSIndexSet *)messageIndexesForRange:(NSRange)range_;
- (NSIndexSet *)messageIndexesAtClickedPoint;
- (NSIndexSet *)selectedMessageIndexes;

+ (NSMenu *)messageMenu;
- (NSMenu *)messageMenuWithMessageIndex:(unsigned)aMessageIndex;
- (NSMenu *)messageMenuWithMessageIndexes:(NSIndexSet *)indexes;
@end



@interface NSObject(CMRThreadViewDelegate)
- (CMRThreadSignature *)threadSignatureForView:(CMRThreadView *)aView;
- (CMRThreadLayout *)threadLayoutForView:(CMRThreadView *)aView;

// Message Reply
- (void)threadView:(CMRThreadView *)aView messageReply:(NSRange)anIndexRange;
// Gyakusansyou Popup
- (void)threadView:(CMRThreadView *)aView reverseAnchorPopUp:(unsigned int)targetIndex locationHint:(NSPoint)location_;
// Spam Filter
- (void)threadView:(CMRThreadView *)aView spam:(CMRThreadMessage *)aMessage messageRegister:(BOOL)registerFlag;

- (BOOL)threadView:(CMRThreadView *)aView mouseClicked:(NSEvent *)theEvent atIndex:(unsigned)charIndex messageIndex:(unsigned)aMessageIndex;

// ReinforceII Addition - Drag & Drop behavior util
- (void)setThreadContentWithThreadIdentifier:(id)aThreadIdentifier;
@end
