/**
 * $Id: BoardManager.h,v 1.1 2005/05/11 17:51:03 tsawada2 Exp $
 * 
 * BoardManager.h
 *
 * Copyright (c) 2004 Takanori Ishikawa, All rights reserved.
 * See the file LICENSE for copying permission.
 */

#import <SGFoundation/SGFoundation.h>



@class BoardList;

@interface BoardManager : NSObject
{
    @private
	BoardList			*_defaultList;
	BoardList			*_userList;
}
+ (id) defaultManager;

- (BoardList *) defaultList;
- (BoardList *) userList;

- (NSString *) defaultBoardListPath;
- (NSString *) userBoardListPath;

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


///////////////////////////////////////////////////////////////
///////////////// [ N o t i f i c a t i o n ] /////////////////
///////////////////////////////////////////////////////////////

extern NSString *const CMRBBSManagerUserListDidChangeNotification;
extern NSString *const CMRBBSManagerDefaultListDidChangeNotification;
