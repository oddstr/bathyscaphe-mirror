//:CMRReplyMessenger_p.h
#import "CMRReplyMessenger.h"

#import "CocoMonar_Prefix.h"

#import "AppDefaults.h"
#import "BoardManager.h"
#import "CMRReplyController.h"
#import "CMRReplyDocumentFileManager.h"

#import "CMRTaskManager.h"
#import "w2chConnect.h"
#import "CMRServerClock.h"

#import <SGNetwork/SGNetwork.h>

//Cookies
#import "Cookie.h"
#import "CookieManager.h"


#define    MESSENGER_REFERER_FORMAT		@"http://%@/%@/%@"
#define    MESSENGER_REFERER_INDEX_HTML	@"index.html"
#define    MESSENGER_SHITARABA_REFERER	@"www.shitaraba.com/bbs"

#define MESSENGER_TABLE_NAME					@"Messenger"
#define MESSENGER_SEND_MESSAGE					@"Send Message to %@..."
#define MESSENGER_END_POST						@"EndPost"
#define MESSENGER_ERROR_POST					@"ERROR Send Message"
#define REPLY_MESSENGER_WINDOW_TITLE_FORMAT		@"Window Title"
#define REPLY_MESSENGER_SUBMIT					@"submit"

#define kToolTipForNeededLogin	@"BeLoginOnNeededToolTip"
#define kToolTipForTrivialLoginOff	@"BeLoginOffTrivialToolTip"
#define kToolTipForCantLoginOn	@"BeLoginOffCantLoginToolTip"
#define kToolTipForLoginOn		@"BeLoginOnToolTip"
#define kToolTipForLoginOff		@"BeLoginOffToolTip"

#define kLabelForLoginOn		@"Be Login On"
#define kLabelForLoginOff		@"Be Login Off"

#define kImageForLoginOn		@"beEnabled"
#define kImageForLoginOff		@"beDisabled"


@interface CMRReplyMessenger(Private)
+ (NSURL *) targetURLWithBoardURL : (NSURL *) boardURL;
+ (NSString *) formItemBBSWithBoardURL : (NSURL *) boardURL;
+ (NSString *) formItemDirectoryWithBoardURL : (NSURL *) boardURL;
@end



@interface CMRReplyMessenger(SendMeesage)
- (NSDictionary *) formDictionary : (NSString *) message
                             name : (NSString *) name
                             mail : (NSString *) mail;
- (void) sendMessageWithContents : (NSString *) message
                            name : (NSString *) name
                            mail : (NSString *) mail;
- (NSString *) refererParameter;
- (void) receiveCookiesWithResponse : (NSDictionary *) headers;
@end



@interface CMRReplyMessenger(ConnectClient)
- (void) didFailPosting : (SGHTTPConnector *) connector;
- (void) didFinishPosting : (SGHTTPConnector *) connector;
@end



@interface CMRReplyMessenger(PrivateAccessor)
- (CMRReplyController *) replyControllerRespondsTo : (SEL) aSelector;

- (NSString *) threadTitle;

- (NSString *) formItemBBS;
- (NSString *) formItemKey;
// require for Jbbs_shita
- (NSString *) formItemDirectory;


- (id) boardIdentifier;
- (id) threadIdentifier;
@end
