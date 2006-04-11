//
//  DatabaseManager.h
//  BathyScaphe
//
//  Created by Hori,Masaki on 05/07/17.
//  Copyright 2005 __MyCompanyName__. All rights reserved.
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
	// return nil, if not registered.
- (NSString *) urlStringForBoardID : (unsigned) boardID;
	// return nil, if not registered.
- (NSArray *) boardIDsForName : (NSString *) name;
	// return nil, if not registered.
- (NSString *) nameForBoardID : (unsigned) boardID;

- (BOOL) registerBoardName : (NSString *) name URLString : (NSString *) urlString;
- (BOOL) registerBoardNamesAndURLs : (NSArray *) array;

- (BOOL) moveBoardID : (unsigned) boardID
	     toURLString : (NSString *) urlString;
- (BOOL) renameBoardID : (unsigned) boardID
			    toName : (NSString *) name;


- (BOOL) registerThreadName : (NSString *) name 
		   threadIdentifier : (NSString *) identifier
			    intoBoardID : (unsigned) boardID;
- (BOOL) registerThreadNamesAndThreadIdentifiers : (NSArray *) array
								     intoBoardID : (unsigned) boardID;

- (BOOL) isFavoriteThreadIdentifier : (NSString *) identifier
						  onBoardID : (unsigned) boardID;
- (BOOL) appendFavoriteThreadIdentifier : (NSString *) identifier
							  onBoardID : (unsigned) boardID;
- (BOOL) removeFavoriteThreadIdentifier : (NSString *) identifier
							  onBoardID : (unsigned) boardID;

@end

@interface DatabaseManager (CreateTable)

- (BOOL) createFavoritesTable;
- (BOOL) createBoardInfoTable;
- (BOOL) createThreadInfoTable;
- (BOOL) createBoardInfoHistoryTable;
	// - (BOOL) createResponseTable;

- (BOOL) createTempThreadNumberTable;

	/*
	 - (BOOL) createFavThraedInfoView;
	 */
- (BOOL) createBoardThreadInfoView;
@end



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
extern NSString *FavoritesTableName;
// extern		NSString *BoardIDColumn;
// extern		NSString *ThreadIDColumn;
extern NSString *BoardInfoHistoryTableName;
// extern		NSString *BoardIDColumn;
// extern		NSString *BoardNameColumn;
// extern		NSString *BoardURLColumn;
//extern NSString *ResponseTableName;
//// extern		NSString *BoardIDColumn;
//// extern		NSString *ThreadIDColumn;
//extern		NSString *NumberColumn;
//extern		NSString *MailColumn;
//extern		NSString *DateColumn;
//extern		NSString *IDColumn;
//extern		NSString *HostColumn;
//extern		NSString *BEColumn;
//extern		NSString *ContentsColumn;
//extern		NSString *ResAboneTypeColumn;
//extern		NSString *ResLabelColumn;

extern NSString *TempThreadNumberTableName;
// extern		NSString *BoardIDColumn;
// extern		NSString *ThreadIDColumn;
extern		NSString *TempThreadThreadNumberColumn;

/*
 extern NSString *FavThreadInfoViewName;
 */
extern NSString *BoardThreadInfoViewName;
extern		NSString *NumberOfDifferenceColumn;

