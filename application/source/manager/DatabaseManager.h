//
//  DatabaseManager.h
//  BathyScaphe
//
//  Created by Hori,Masaki on 05/07/17.
//  Copyright 2005 BathyScaphe Project. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import <SQLiteDB.h>


@interface DatabaseManager : NSObject
+ (id) defaultManager;

+ (void) setupDatabase;

- (NSString *) databasePath;

- (SQLiteDB *) databaseForCurrentThread;

@end

@interface DatabaseManager (DatabaseAccess)

// return NSNotFound, if not registered.
- (unsigned) boardIDForURLString : (NSString *) urlString;
- (unsigned)boardIDForURLStringExceptingHistory:(NSString *)urlString; // Do not search BoardInfoHistoryTable.


	// return nil, if not registered.
- (NSString *) urlStringForBoardID : (unsigned) boardID;
	// return nil, if not registered.
- (NSArray *) boardIDsForName : (NSString *) name;
	// return nil, if not registered.
- (NSString *) nameForBoardID : (unsigned) boardID;

// raise DatabaseManagerCantFountKeyExseption.
- (id)valueForKey:(NSString *)key boardID:(unsigned)boardID threadID:(NSString *)threadID;
// - (void)setValue:(id)value forKey:(NSString *)key boardID:(unsigned)boardID threadID:(NSString *)threadID;

- (BOOL) registerBoardName : (NSString *) name URLString : (NSString *) urlString;

// Currently not available.
//- (BOOL) registerBoardNamesAndURLs : (NSArray *) array;

// Added by tsawada2.
- (BOOL)deleteBoardOfBoardID:(unsigned)boardID;

- (BOOL) moveBoardID : (unsigned) boardID
	     toURLString : (NSString *) urlString;
- (BOOL) renameBoardID : (unsigned) boardID
			    toName : (NSString *) name;

// Currently not available.
/*- (BOOL) registerThreadName : (NSString *) name 
		   threadIdentifier : (NSString *) identifier
			    intoBoardID : (unsigned) boardID;
- (BOOL) registerThreadNamesAndThreadIdentifiers : (NSArray *) array
								     intoBoardID : (unsigned) boardID;*/
// Added by tsawada2.
- (BOOL)isThreadIdentifierRegistered:(NSString *)identifier onBoardID:(unsigned)boardID;

- (BOOL) isFavoriteThreadIdentifier : (NSString *) identifier
						  onBoardID : (unsigned) boardID;
- (BOOL) appendFavoriteThreadIdentifier : (NSString *) identifier
							  onBoardID : (unsigned) boardID;
- (BOOL) removeFavoriteThreadIdentifier : (NSString *) identifier
							  onBoardID : (unsigned) boardID;

- (BOOL) registerThreadFromFilePath:(NSString *)filepath;


//
- (NSString *) threadTitleFromBoardName:(NSString *)boadName threadIdentifier:(NSString *)identifier;

- (void)setLastWriteDate:(NSDate *)writeDate atBoardID:(unsigned)boardID threadIdentifier:(NSString *)threadID;

// [Bug 10077] を強引に解消するための暫定的な実装 (by tsawada2)
- (BOOL) insertThreadID: (NSString *) datString
				  title: (NSString *) title
				  count: (NSNumber *) count
				   date: (id) date
				atBoard: (NSString *) boardName;

// キャッシュを放棄
- (BOOL) recache;
@end

@interface DatabaseManager (CreateTable)

- (BOOL) createFavoritesTable;
- (BOOL) createBoardInfoTable;
- (BOOL) createThreadInfoTable;
- (BOOL) createBoardInfoHistoryTable;
	// - (BOOL) createResponseTable;

- (BOOL) createTempThreadNumberTable;
- (BOOL) createVersionTable;

	/*
	 - (BOOL) createFavThraedInfoView;
	 */
- (BOOL) createBoardThreadInfoView;
@end

// スレッド一覧テーブルカラムのIDからデータベース上のテーブル名を取得。
NSString *tableNameForKey(NSString *key);



extern NSString *BoardInfoTableName;
extern		NSString *BoardIDColumn;
extern		NSString *BoardURLColumn;
extern		NSString *BoardNameColumn;
extern NSString *ThreadInfoTableName;
// extern		NSString *BoardIDColumn; same as BoardIDColumn in BoardInfoTableName.
extern		NSString *ThreadIDColumn;
extern		NSString *ThreadNameColumn;
extern		NSString *NumberOfAllColumn;
extern		NSString *NumberOfReadColumn;
extern		NSString *ModifiedDateColumn;
extern		NSString *ThreadStatusColumn;
extern		NSString *ThreadAboneTypeColumn;
extern		NSString *ThreadLabelColumn;
extern		NSString *LastWrittenDateColumn;
extern		NSString *IsDatOchiColumn;
extern		NSString *IsFavoriteColumn;
extern NSString *FavoritesTableName;
// extern		NSString *BoardIDColumn;
// extern		NSString *ThreadIDColumn;
extern NSString *BoardInfoHistoryTableName;
// extern		NSString *BoardIDColumn;
// extern		NSString *BoardNameColumn;
// extern		NSString *BoardURLColumn;

extern	NSString *VersionTableName;
extern		NSString *VersionColumn;

extern NSString *TempThreadNumberTableName;
// extern		NSString *BoardIDColumn;
// extern		NSString *ThreadIDColumn;
extern		NSString *TempThreadThreadNumberColumn;

/*
 extern NSString *FavThreadInfoViewName;
 */
extern NSString *BoardThreadInfoViewName;
extern		NSString *NumberOfDifferenceColumn;
extern		NSString *IsCachedColumn;
extern		NSString *IsUpdatedColumn;
extern		NSString *IsNewColumn;
extern		NSString *IsHeadModifiedColumn;

// Added by tsawada2 (2008-02-19)
extern NSString *const DatabaseDidFinishUpdateDownloadedOrDeletedThreadInfoNotification;
