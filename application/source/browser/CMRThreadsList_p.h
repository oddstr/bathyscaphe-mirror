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
