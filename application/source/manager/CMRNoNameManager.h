/**
  * $Id: CMRNoNameManager.h,v 1.1.1.1 2005/05/11 17:51:05 tsawada2 Exp $
  * 
  * CMRNoNameManager.h
  *
  * Copyright (c) 2003, Takanori Ishikawa.
  * See the file LICENSE for copying permission.
  */

/*!
	@header CMRNoNameManager
	
	板の名無しさんの名前を管理するマネージャ
	SETTING.TXT を利用することもできるが、必ずしもすべての板に
	用意されてるわけではない（気がする）ので、
	・ユーザ入力
	・スレからの自動判別
	で補う
	
	1.0.9.7 以降ではより広範に、板ごとのプロパティの管理を担わせる
	・ブラウザのソート基準カラム（昇順、降順含む）
	・必要なら拡張も可能（板ごとのコテハン記憶、スレ一覧のフィルタ設定などが考えられる）
	
	名前が NoNameManager/NoName.plist のままなのは単に内部の互換性維持のため。
*/

#import <Foundation/Foundation.h>

@class	CMRBBSSignature;



@interface CMRNoNameManager : NSObject
{
	@private
	NSDictionary	*_noNameDict;
}
+ (id) defaultManager;


/* 名無しさんの名前 */
- (NSString *) defauoltNoNameForBoard : (CMRBBSSignature *) aBoard;
- (void) setDefaultNoName : (NSString        *) aName
			 	 forBoard : (CMRBBSSignature *) aBoard;
/* ソート基準カラム */
- (NSString *) sortColumnForBoard : (CMRBBSSignature *) aBoard;
- (void) setSortColumn : (NSString		  *) anIdentifier
			  forBoard : (CMRBBSSignature *) aBoard;
- (BOOL) sortColumnIsAscendingAtBoard : (CMRBBSSignature *) aBoard;
- (void) setSortColumnIsAscending : (BOOL			  ) TorF
						  atBoard : (CMRBBSSignature *) aBoard;

/*
	ユーザからの入力を受けつける。
	
	@param aBoard 掲示板
	@param presetValue:aValue テキストフィールドのデフォルト値
	@result キャンセル時には nil
*/
- (NSString *) askUserAboutDefaultNoNameForBoard : (CMRBBSSignature *) aBoard
									 presetValue : (NSString        *) aValue;
@end
