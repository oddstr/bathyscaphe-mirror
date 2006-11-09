#import <Cocoa/Cocoa.h>


#import "CocoMonar_Prefix.h"
#import "CMXInternalMessaging.h"
#import "RBSplitView.h"
#import "CookieManager.h"
#import "CMRHistoryManager.h"
#import "CMRFavoritesManager.h"
#import "CMRMainMenuManager.h"
#import "BoardManager.h"
#import "CMRNetGrobalLock.h"
#import "DatabaseManager.h"
#import "CMRTrashbox.h"

/* for Debugging */
SGUtilLogger *CMRLogger = nil;

//BOOL shouldCascadeBrowser = YES;

void CMXServicesInit(void)
{
    static BOOL isInvoked = NO;
    NSAutoreleasePool    *pool_;
    unsigned int         seed_;
    
    
    if (isInvoked) return;
    isInvoked = YES;
    
    pool_ = [[NSAutoreleasePool alloc] init];

	[RBSplitView class];

    seed_ = (unsigned int)[[NSDate date] timeIntervalSince1970];
    srand(seed_);
    
    // Managers
    [CMRFileManager defaultManager];
    [CMRMainMenuManager defaultManager];
	[CMRTrashbox trash]; // 2006-06-29: FavoritesManager ����ɗp�ӂł��Ă���K�v������I
    //[BoardManager defaultManager];
	//[CMRFavoritesManager defaultManager];
    [CMRNetGrobalLock sharedInstance];

	[DatabaseManager defaultManager];
	[DatabaseManager setupDatabase];
    
    // Inter-thread messaging
    CMRMainThread = [NSThread currentThread];
    CMRMainRunLoop = [NSRunLoop currentRunLoop];
    CMRMainMessenger = [SGInternalMessenger currentMessenger];    
    
    [pool_ release];
}



void CMRApplicationReset(id sender)
{
    int			code;
	NSButton	*cancel_;
	NSButton	*reset_;
	NSAlert		*alert_;
	
	alert_ = [[NSAlert alloc] init];
	[alert_ setDelegate : sender];
	[alert_	setAlertStyle : NSCriticalAlertStyle];
	[alert_	setMessageText : NSLocalizedString(@"Reset:Title", nil)];
	[alert_ setInformativeText : NSLocalizedString(@"Reset:Message", nil)];
	[alert_ setShowsHelp : YES];
	[alert_ setHelpAnchor : NSLocalizedString(@"Reset:HelpAnchor", @"bs_app_reset_alert")];
	reset_ = [alert_ addButtonWithTitle : NSLocalizedString(@"Reset:Reset", nil)];
	[reset_ setKeyEquivalent : @""]; // �����Ă����Ə���� return �����蓖�Ă��Ă��܂��B�܂��Anil �͎w��s�B
	cancel_ = [alert_ addButtonWithTitle : NSLocalizedString(@"Reset:Cancel", nil)];
	[cancel_ setKeyEquivalent : @"\r"];

	code = [alert_ runModal];
	if (NSAlertSecondButtonReturn == code) goto ENDING;
    
    [[NSNotificationCenter defaultCenter] 
        postNotificationName : CMRApplicationWillResetNotification
        object : nil];
    
    [[CookieManager defaultManager] removeAllCookies];
	[[NSURLCache sharedURLCache] removeAllCachedResponses];
    [[CMRHistoryManager  defaultManager] removeAllItems];
    [[NSNotificationCenter defaultCenter] 
        postNotificationName : CMRApplicationDidResetNotification
        object : nil];
ENDING:
	[alert_ release];
}

int main(int argc, const char *argv[])
{
    CMXServicesInit();
    return NSApplicationMain(argc, argv);
}
