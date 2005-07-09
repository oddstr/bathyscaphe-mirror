#import <Cocoa/Cocoa.h>


#import "CocoMonar_Prefix.h"
#import <SGAppKit/SGAppKit.h>
#import "CMXInternalMessaging.h"
#import "RBSplitView.h"

#import "CookieManager.h"
#import "CMRHistoryManager.h"
#import "CMRNoNameManager.h"
#import "CMRFavoritesManager.h"
#import "CMRMainMenuManager.h"
#import "BoardManager.h"
#import "CMRNetGrobalLock.h"



/* for Debugging */
SGUtilLogger *CMRLogger = nil;



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
    [CMRNoNameManager defaultManager];
    [CMRMainMenuManager defaultManager];
    [BoardManager defaultManager];
	[CMRFavoritesManager defaultManager];
    [CMRNetGrobalLock sharedInstance];
    
    // Custom views
    SGAppKitFrameworkInit();
    
    // Inter-thread messaging
    CMRMainThread = [NSThread currentThread];
    CMRMainRunLoop = [NSRunLoop currentRunLoop];
    CMRMainMessenger = [SGInternalMessenger currentMessenger];    
    
    [pool_ release];
}



void CMRApplicationReset()
{
    int code;
    
    code = NSRunAlertPanel(
                NSLocalizedString(@"Reset:Title", nil),
                NSLocalizedString(@"Reset:Message", nil),
                NSLocalizedString(@"Reset:Cancel", nil),
                NSLocalizedString(@"Reset:Reset", nil),
                nil);
    if(NSOKButton == code) return;
    
    [[NSNotificationCenter defaultCenter] 
        postNotificationName : CMRApplicationWillResetNotification
        object : nil];
    
    [[CookieManager defaultManager] removeAllCookies];
    [[SGTemplatesManager sharedInstance] resetAllResources];
    [[CMRHistoryManager  defaultManager] removeAllItems];
    [[NSNotificationCenter defaultCenter] 
        postNotificationName : CMRApplicationDidResetNotification
        object : nil];
}

int main(int argc, const char *argv[])
{
    CMXServicesInit();
    return NSApplicationMain(argc, argv);
}
