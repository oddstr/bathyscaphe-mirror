/**
 * $Id: CMRFiles.h,v 1.1.1.1 2005/05/11 17:51:19 tsawada2 Exp $
 * 
 * CMRFiles.h
 *
 * Copyright (c) 2004 Takanori Ishikawa, All rights reserved.
 * See the file LICENSE for copying permission.
 */

#define CMRUserBoardFile		@"board.plist"
#define CMRDefaultBoardFile		@"board_default.plist"
#define CMRCookiesFile			@"Cookies.plist"
#define CMRHistoryFile			@"History.plist"
#define CMRNoNamesFile			@"NoNames.plist"
#define CMRFavoritesFile		@"Favorites.plist"
#define CMRFavMemoFile			@"Favorites_Memo.plist"


/*!
 * @abstract    
 *
 * ~/Library/Application Support/CocoMonar/(XXX)
 * [CMRFileManager supportDirectoryWithName:]
 *
 * @defined    CMXLogsDirectory
 * @defined    CMXDocumentsDirectory
 * @defined    CMXResourcesDirectory
 * @defined    CMRBookmarksDirectory
 *
 * @discussion  Application Specific Files
 */

#define CMRLogsDirectory			@"Logs"
#define CMRDocumentsDirectory		@"Documents"
#define CMRResourcesDirectory		@"Resources"
#define CMRBookmarksDirectory		@"Bookmarks"
