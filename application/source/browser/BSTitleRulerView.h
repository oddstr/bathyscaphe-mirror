//
//  $Id: BSTitleRulerView.h,v 1.4.2.1 2006/06/08 00:04:49 tsawada2 Exp $
//  BathyScaphe
//
//  Created by Tsutomu Sawada on 05/09/22.
//  Copyright 2005-2006 BathyScaphe Project. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <SGAppKit/SGAppKit.h>

typedef enum _BSTitleRulerModeType {
	BSTitleRulerShowTitleOnlyMode		= 0, // スレッドタイトルバーのみ
	BSTitleRulerShowInfoOnlyMode		= 1, // 「dat 落ちと判定されました。」のみ
	BSTitleRulerShowTitleAndInfoMode	= 2, // スレッドタイトルバー、その下に「dat 落ちと判定されました。」
} BSTitleRulerModeType;

@interface BSTitleRulerView : NSRulerView {
	@private
	NSString	*m_titleStr;
	NSString	*m_infoStr;
	NSImage		*m_bgImage;
	NSImage		*m_bgImageNonActive;
	NSColor		*m_textColor;

	BSTitleRulerModeType	_currentMode;
}

- (NSString *) titleStr;
- (void) setTitleStr : (NSString *) aString;
- (void) setTitleStrWithoutNeedingDisplay: (NSString *) aString;

- (NSString *) infoStr;
- (void) setInfoStr : (NSString *) aString;
- (void) setInfoStrWithoutNeedingDisplay: (NSString *) aString;

- (NSImage *) bgImage;
- (NSImage *) bgImageNonActive;

- (NSColor *) textColor;
- (void) setTextColor: (NSColor *) aColor;

- (BSTitleRulerModeType) currentMode;
- (void) setCurrentMode: (BSTitleRulerModeType) newType;
@end
