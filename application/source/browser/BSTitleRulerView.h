//
//  BSTitleRulerView.h
//  SGAppKit (BathyScaphe)
//
//  Created by Tsutomu Sawada on 05/09/22.
//  Copyright 2005-2007 BathyScaphe Project. All rights reserved.
//  encoding="UTF-8"
//

#import <Cocoa/Cocoa.h>

@class BSTitleRulerAppearance;

typedef enum _BSTitleRulerModeType {
	BSTitleRulerShowTitleOnlyMode		= 0, // スレッドタイトルバーのみ
	BSTitleRulerShowInfoOnlyMode		= 1, // 「dat 落ちと判定されました。」のみ
	BSTitleRulerShowTitleAndInfoMode	= 2, // スレッドタイトルバー、その下に「dat 落ちと判定されました。」
} BSTitleRulerModeType;

@interface BSTitleRulerView : NSRulerView {
	@private
	BSTitleRulerAppearance *m_appearance;

	NSString	*m_titleStr;
	NSString	*m_infoStr;
	NSString	*m_pathStr;

	BSTitleRulerModeType	_currentMode;
}

// Designated initializer. Available in Twincam Angel/SGAppKit 1.7.1 and later.
- (id)initWithScrollView:(NSScrollView *)aScrollView appearance:(BSTitleRulerAppearance *)appearance;

- (BSTitleRulerAppearance *)appearance;
- (void)setAppearance:(BSTitleRulerAppearance *)appearance;

- (NSString *)titleStr;
- (void)setTitleStr:(NSString *)aString;
- (void)setTitleStrWithoutNeedingDisplay:(NSString *)aString;

- (NSString *)infoStr;
- (void)setInfoStr:(NSString *)aString;
- (void)setInfoStrWithoutNeedingDisplay:(NSString *)aString;

- (NSString *)pathStr;
- (void)setPathStr:(NSString *)aString;

- (BSTitleRulerModeType)currentMode;
- (void)setCurrentMode:(BSTitleRulerModeType)newType;
@end
