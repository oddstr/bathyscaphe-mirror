//:ThreadsList_p.h
#import "CMRThreadsList.h"

#import "AppDefaults.h"

#import "CMRTaskManager.h"
#import "CMRDocumentFileManager.h"
#import "CMRFavoritesManager.h"
#import "CMRTrashbox.h"
#import "BoardManager.h"
#import "CMRThreadAttributes.h"

#import <SGAppKit/SGAppKit.h>


#define APP_TLIST_LOCALIZABLE_FILE		@"ThreadsList"
#define APP_TLIST_NOT_FOUND_TITLE		@"Not Found"
#define APP_TLIST_NOT_FOUND_MSG_FMT		@"Not Found %@"

#define APP_TLIST_SERACH_RESULT_FMT		@"Search Thread Result"
#define APP_TLIST_SERACH_NOT_FOUND		@"Search Thread Not Found"

#define kBrowserDelThTitleKey	@"Browser Del Thread Title"
#define kBrowserDelThMsgKey		@"Browser Del Thread Message"
#define kDeleteFavTitleKey		@"Delete Fav Title"
#define kDeleteOnlyFavBtnKey	@"Delete Fav OK"
#define kDeleteFavAlsoFileBtnKey	@"Delete Fav And File"
#define kDeleteCancelBtnKey	@"Delete Cancel"
#define kDeleteFavMsgKey	@"Delete Fav Msg"
#define kDeleteOKBtnKey		@"Delete OK"


@interface CMRThreadsList(PrivateAccessor)
- (void) setBBSName : (NSString *) boardName;
@end

/*
@interface CMRThreadsList(DownLoadPrivate)
- (void) registerToNotificationCeterWithDownloader : (CMRDownloader *) downloader;
- (void) removeFromNotificationCeterWithDownloader : (CMRDownloader *) downloader;

- (void) downloaderFinishedNotified : (NSNotification *) notification;
- (void) donwnloader : (CMRDownloader  *) theDownloader
         didFinished : (NSMutableArray *) newList;
- (void) downloaderNotFound : (NSNotification *) notification;
@end
*/
/*
@interface CMRThreadsList(NotificationCenterSupport)
// added in LittleWish and later.
//- (void) syncFavIfNeededWithAttr : (NSMutableDictionary *) thread
//						 forPath : (NSString *) filePath;
@end
*/

@interface CMRThreadsList(CleanUp)
//- (void) trashDidPerformNotification : (NSNotification *) theNotification;
- (void) cleanUpItemsToBeRemoved : (NSArray *) files;
// Deprecated in ReinforceII and later. Use tableView:removeIndexSet:delFavIfNecessary: instead.
//- (BOOL) tableView : (NSTableView *) tableView
//	   removeItems : (NSArray	  *) rows
// delFavIfNecessary : (BOOL         ) flag;
- (BOOL) tableView : (NSTableView	*) tableView
	removeIndexSet : (NSIndexSet	*) indexSet
 delFavIfNecessary : (BOOL			 ) flag;
- (BOOL) tableView : (NSTableView	*) tableView
	   removeFiles : (NSArray		*) files
 delFavIfNecessary : (BOOL			 ) flag;
@end

/*
@interface CMRThreadsList(ReadThreadsList)
- (void) doLoadThreadsList : (CMRThreadLayout *) worker;
- (void) startUpdateThreadsList : (NSMutableArray *) aList
						 update : (BOOL            ) isUpdated
					 usesWorker : (BOOL            ) usesWorker;
@end
*/