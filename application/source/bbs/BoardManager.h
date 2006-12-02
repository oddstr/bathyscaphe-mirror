/**
 * $Id: BoardManager.h,v 1.13 2006/12/02 16:17:59 masakih Exp $
 * 
 * BoardManager.h
 *
 * Copyright (c) 2004 Takanori Ishikawa, All rights reserved.
 * See the file LICENSE for copying permission.
 */

#import <SGFoundation/SGFoundation.h>

@class SmartBoardList;
/*!
    @class		BoardManager
    @abstract   掲示板リストの dataSource 提供と、各掲示板の属性へのアクセスを一括して取り扱うマネージャ
    @discussion BoardManager は、掲示板リストの dataSource を提供します。また、各掲示板に関する
				種々の属性の読み書きをサポートします。掲示板はその名前で一意に識別されることに注意してください。
				BoardManager で掲示板の属性を読み書きする際、ほとんどのメソッドで掲示板の「名前」をキーに
				する必要があります。しかし、名前がわからないが、URL がわかっている場合は、boardNameForURL:
				メソッドで名前を得ることができます。
				BoardManager が（現在のところ）取り扱う掲示板の属性：
				・URL（板名の逆引き、URL 移転のサポートを含む）
				・デフォルト名無し
				・デフォルトコテハン
				・デフォルトメール欄
				・常に Be ログインして書き込むかどうか？
				・スレッド一覧でのソート基準カラムと、昇順／降順
*/

/*
typedef enum _BSBeLoginPolicyType {
	BSBeLoginTriviallyNeeded	= 0, // Be ログイン必須
	BSBeLoginTriviallyOFF		= 1, // Be ログインは無意味（2chではない掲示板など）
	BSBeLoginDecidedByUser		= 2, // Be ログインするかどうかはユーザの設定を参照する
	BSBeLoginNoAccountOFF		= 3  // 環境設定で Be アカウントが設定されていない
} BSBeLoginPolicyType;
*/
@interface BoardManager : NSObject
{
    @private
	SmartBoardList			*_defaultList;
	SmartBoardList			*_userList;
	NSMutableDictionary		*_noNameDict;	// NoNameManager を統合
}
+ (id) defaultManager;

- (SmartBoardList *) defaultList;
- (SmartBoardList *) userList;

// - (SmartBoardList *) filteredListWithString: (NSString *) keyword; // available in CometBlaster.

- (NSString *) defaultBoardListPath;
- (NSString *) userBoardListPath;
+ (NSString *) NNDFilepath; // (BoardProperties.plist)
+ (NSString *) oldNNDFilepath; // available in MeteorSweeper. (NoNames.plist)

- (NSURL *) URLForBoardName : (NSString *) boardName;
- (NSString *) boardNameForURL : (NSURL *) anURL;

- (void) updateURL : (NSURL    *) anURL
      forBoardName : (NSString *) aName;

/*!
 * @method        tryToDetectMovedBoard
 * @abstract      Detect moved BBS as possible.
 * @discussion    Detect moved BBS from HTML contents server has
 *                returned. It may be unexpected contents (expected
 *                index.html), but it can contain information about 
 *                new location of BBS.
 *
 * @param boardName BBS Name
 * @result          return YES, if BoardManager change old location.
 */
- (BOOL) tryToDetectMovedBoard : (NSString *) boardName;

/*!
 * @method        detectMovedBoardWithResponseHTML:
 * @abstract      Detect moved BBS as possible.
 * @discussion    Detect moved BBS from HTML contents server has
 *                returned. It may be unexpected contents (expected
 *                index.html), but it can contain information about 
 *                new location of BBS.
 *
 * @param aHTML     HTML contents, NSString
 * @param boardName BBS Name
 * @result          return YES, if BoardManager change old location.
 */
- (BOOL) detectMovedBoardWithResponseHTML : (NSString *) htmlContents
                                boardName : (NSString *) boardName;
@end

@interface BoardManager(BSAddition)
// CMRNoNameManager を統合
// NoNameManager はすべて CMRBBSSignature を引数にとっていたが、BoardManager への
// 統合に伴い、すべて NSString に変更したので注意。

- (NSMutableDictionary *) noNameDict;

/* 名無しさんの名前 */
// Deprecated in MeteorSweeper.
//- (NSString *) defaultNoNameForBoard : (NSString *) boardName;
//- (void) setDefaultNoName : (NSString *) aName
//			 	 forBoard : (NSString *) boardName;

// Available in MeteorSweeper.
- (NSSet *) defaultNoNameSetForBoard: (NSString *) boardName;
- (void) setDefaultNoNameSet: (NSSet *) newSet forBoard: (NSString *) boardName;
- (void) addNoName: (NSString *) additionalNoName forBoard: (NSString *) boardName;
- (void) removeNoName: (NSString *) removingNoName forBoard: (NSString *) boardName;
- (void) exchangeNoName: (NSString *) oldName toNewValue: (NSString *) newName forBoard: (NSString *) boardName;
				 
/* ソート基準カラム */
- (NSString *) sortColumnForBoard : (NSString *) boardName;
- (void) setSortColumn : (NSString *) anIdentifier
			  forBoard : (NSString *) boardName;
- (BOOL) sortColumnIsAscendingAtBoard : (NSString *) boardName;
- (void) setSortColumnIsAscending : (BOOL	   ) isAscending
						  atBoard : (NSString *) boardName;
// 1.4 or 1.5 addition
- (NSArray *) sortDescriptorsForBoard : (NSString *) boardName;
- (void) setSortDescriptors : (NSArray *) sortDescriptors
				   forBoard : (NSString *) boardName;

// SledgeHammer Addition
- (BOOL) alwaysBeLoginAtBoard : (NSString *) boardName;
- (void) setAlwaysBeLogin : (BOOL	   ) alwaysLogin
				  atBoard : (NSString *) boardName;
- (NSString *) defaultKotehanForBoard : (NSString *) boardName;
- (void) setDefaultKotehan : (NSString *) aName
				  forBoard : (NSString *) boardName;
- (NSString *) defaultMailForBoard : (NSString *) boardName;
- (void) setDefaultMail : (NSString *) aString
			   forBoard : (NSString *) boardName;

// LittleWish Addition
/* 注意：1.1.x ではインタフェースのみ */
// available in BathyScaphe 1.2 and later.
- (BOOL) allThreadsShouldAAThreadAtBoard : (NSString *) boardName;
- (void) setAllThreadsShouldAAThread : (BOOL      ) shouldAAThread
							 atBoard : (NSString *) boardName;

// LittleWish Addtion : Read-only Properties
- (NSImage *) iconForBoard : (NSString *) boardName;
- (BSBeLoginPolicyType) typeOfBeLoginPolicyForBoard : (NSString *) boardName;

// MeteorSweeper Addition
- (void) setTypeOfBeLoginPolicy: (BSBeLoginPolicyType) aType forBoard: (NSString *) boardName;

/*
	ユーザからの入力を受けつける。
	
	@param aBoard 掲示板
	@param presetValue:aValue テキストフィールドのデフォルト値
	@result キャンセル時には nil
*/
- (NSString *) askUserAboutDefaultNoNameForBoard : (NSString *) boardName
									 presetValue : (NSString *) aValue;

// available in MeteorSweeper and later.
- (BOOL) needToDetectNoNameForBoard: (NSString *) boardName;
@end

// MeteorSweeper Addition
@interface BoardManager(SettingTxtDetector)
- (BOOL) startDownloadSettingTxtForBoard: (NSString *) boardName;
@end

@interface BoardManager(UserListEditorCore)
- (BOOL) addCategoryOfName: (NSString *) name;
- (BOOL) editBoardOfName: (NSString *) boardName newURLString: (NSString *) newURLString;
- (BOOL) editCategoryOfName: (NSString *) oldName newName: (NSString *) newName;
- (BOOL) removeBoardItems: (NSArray *) boardItemsForRemoval;
@end
///////////////////////////////////////////////////////////////
///////////////// [ N o t i f i c a t i o n ] /////////////////
///////////////////////////////////////////////////////////////

extern NSString *const CMRBBSManagerUserListDidChangeNotification;
extern NSString *const CMRBBSManagerDefaultListDidChangeNotification;
