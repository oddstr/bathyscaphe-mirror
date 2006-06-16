//
//  $Id: BSTitleRulerView.h,v 1.4.2.2 2006/06/16 00:33:11 tsawada2 Exp $
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

	BSTitleRulerModeType	_currentMode;
}

- (NSString *) titleStr;
- (void) setTitleStr : (NSString *) aString;
- (void) setTitleStrWithoutNeedingDisplay: (NSString *) aString;

- (NSString *) infoStr;
- (void) setInfoStr : (NSString *) aString;
- (void) setInfoStrWithoutNeedingDisplay: (NSString *) aString;

+ (void) setTitleTextColor: (NSColor *) aColor;

- (BSTitleRulerModeType) currentMode;
- (void) setCurrentMode: (BSTitleRulerModeType) newType;
@end
