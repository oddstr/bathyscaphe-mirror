//
//  BoardManager.h
//  BathyScaphe
//
//  Updated by Tsutomu Sawada on 07/08/31.
//  Copyright 2005-2007 BathyScaphe Project. All rights reserved.
//  encoding="UTF-8"
//

#import <Foundation/Foundation.h>

@class SmartBoardList;

@interface BoardManager : NSObject
{
    @private
	SmartBoardList			*_defaultList;
	SmartBoardList			*_userList;

	NSMutableDictionary		*_noNameDict;
}
+ (id)defaultManager;

- (SmartBoardList *)defaultList;
- (SmartBoardList *)userList;

// Available in CometBlaster and later.
- (SmartBoardList *)filteredListWithString:(NSString *)keyword;

- (NSString *)defaultBoardListPath;
- (NSString *)userBoardListPath;

+ (NSString *)NNDFilepath; // BoardProperties.plist

// Available in MeteorSweeper and later.
+ (NSString *)oldNNDFilepath; // NoNames.plist

- (NSURL *)URLForBoardName:(NSString *)boardName;
- (NSString *)boardNameForURL:(NSURL *)anURL;

- (void)updateURL:(NSURL *)anURL forBoardName:(NSString *)aName;

/*!
 * @method        tryToDetectMovedBoard:
 * @abstract      Detect moved BBS as possible.
 * @discussion    Detect moved BBS from HTML contents server has
 *                returned. It may be unexpected contents (expected
 *                index.html), but it can contain information about 
 *                new location of BBS.
 *
 * @param boardName BBS Name
 * @result        Returns YES if BoardManager change old location.
 */
- (BOOL)tryToDetectMovedBoard:(NSString *)boardName;

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
 * @result          Returns YES if BoardManager change old location.
 */
- (BOOL)detectMovedBoardWithResponseHTML:(NSString *)htmlContents boardName:(NSString *)boardName;
@end

@interface BoardManager(BoardProperties)
- (NSMutableDictionary *)noNameDict;

// Available in Starlight Breaker and later.
- (void)passPropertiesOfBoardName:(NSString *)boardName toBoardName:(NSString *)newBoardName;

#pragma mark Nanashi-san
// Available in MeteorSweeper and later.
- (NSArray*)defaultNoNameArrayForBoard:(NSString *)boardName;
- (void)setDefaultNoNameArray:(NSArray *)array forBoard:(NSString *)boardName;
- (void)addNoName:(NSString *)additionalNoName forBoard:(NSString *)boardName;
- (void)removeNoName:(NSString *)removingNoName forBoard:(NSString *)boardName;
- (void)exchangeNoName:(NSString *)oldName toNewValue:(NSString *)newName forBoard:(NSString *)boardName;

/*!
    @method     askUserAboutDefaultNoNameForBoard:presetValue:
    @abstract   Shows input dialog for user to specify nanashisan.
    @discussion Shows input dialog, and User can directly enter the nanashisan.
				BoardManager will serve presetValue as assumed nanashisan.
	@result		Input string. If User canceled, returns nil.
*/
- (NSString *)askUserAboutDefaultNoNameForBoard:(NSString *)boardName presetValue:(NSString *)aValue;

// Available in MeteorSweeper and later.
- (BOOL)needToDetectNoNameForBoard:(NSString *)boardName;

// Available in ReinforceII and later.
- (BOOL)allowsNanashiAtBoard:(NSString *)boardName;
- (void)setAllowsNanashi:(BOOL)allows atBoard:(NSString *)boardName;

#pragma mark Sorting
- (NSString *)sortColumnForBoard:(NSString *)boardName;
- (void)setSortColumn:(NSString *)anIdentifier forBoard:(NSString *)boardName;
- (BOOL) sortColumnIsAscendingAtBoard:(NSString *)boardName;
- (void) setSortColumnIsAscending:(BOOL)isAscending atBoard:(NSString *) boardName;

// Available in Starlight Breaker and later.
- (NSArray *)sortDescriptorsForBoard:(NSString *)boardName;
- (void)setSortDescriptors:(NSArray *)sortDescriptors forBoard:(NSString *)boardName;

#pragma mark Replying
// Available in SledgeHammer and later.
- (BOOL)alwaysBeLoginAtBoard:(NSString *)boardName;
- (void) setAlwaysBeLogin:(BOOL)alwaysLogin atBoard:(NSString *)boardName;
- (NSString *)defaultKotehanForBoard:(NSString *)boardName;
- (void)setDefaultKotehan:(NSString *)aName forBoard:(NSString *)boardName;
- (NSString *) defaultMailForBoard:(NSString *)boardName;
- (void)setDefaultMail:(NSString *)aString forBoard:(NSString *)boardName;

// Available in LittleWish and later.
- (BSBeLoginPolicyType)typeOfBeLoginPolicyForBoard:(NSString *)boardName;

// Available in MeteorSweeper and later.
- (void)setTypeOfBeLoginPolicy:(BSBeLoginPolicyType)aType forBoard:(NSString *)boardName;

#pragma mark Other Board Properties
// Available in BathyScaphe 1.2 and later.
- (BOOL)allThreadsShouldAAThreadAtBoard:(NSString *)boardName;
- (void)setAllThreadsShouldAAThread:(BOOL)shouldAAThread atBoard:(NSString *)boardName;

// Available in LittleWish and later.
- (NSImage *)iconForBoard:(NSString *)boardName; // Read Only

// Available in Twincam Angel and later.
- (id)browserListColumnsForBoard:(NSString *)boardName;
- (void)setBrowserListColumns:(id)plist forBoard:(NSString *)boardName;
@end

// Available in MeteorSweeper and later.
@interface BoardManager(SettingTxtDetector)
- (BOOL)startDownloadSettingTxtForBoard:(NSString *)boardName;
@end

@interface BoardManager(UserListEditorCore)
- (BOOL)addCategoryOfName:(NSString *)name;
- (BOOL)editBoardItem:(id)item newURLString:(NSString *)newURLString;
- (BOOL)editBoardOfName:(NSString *)boardName newURLString:(NSString *)newURLString;
- (BOOL)editCategoryOfName:(NSString *)oldName newName:(NSString *)newName;
- (BOOL)removeBoardItems:(NSArray *)boardItemsForRemoval;
@end

extern NSString *const CMRBBSManagerUserListDidChangeNotification;
extern NSString *const CMRBBSManagerDefaultListDidChangeNotification;

// Available in ReinforceII and later.
extern NSString *const BoardManagerDidFinishDetectingSettingTxtNotification;
