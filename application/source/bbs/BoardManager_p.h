//:BoardManager_p.h
#import "BoardManager.h"
#import "AppDefaults.h"
#import "CocoMonar_Prefix.h"
#import "SmartBoardList.h"

#import <AppKit/NSApplication.h>



@interface BoardManager(Notification)
- (void) boardListDidChange : (NSNotification *) notification;
- (BOOL) saveListsIfNeed;
@end