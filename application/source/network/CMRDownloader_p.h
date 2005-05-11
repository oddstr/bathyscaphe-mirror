//:CMRDownloader_p.h
#import "CMRDownloader.h"

#import <SGFoundation/SGFoundation.h>
#import <SGNetwork/SGNetwork.h>
#import "CocoMonar_Prefix.h"

#import "CMRDocumentFileManager.h"
#import "CMRServerClock.h"
#import "CMXTextParser.h"
#import "CMRNetGrobalLock.h"



// simply check whether html data...
#define CHECK_HTML(bytes, len)		(nsr_strncasestr((const char*)(bytes), "<html", len) != NULL)

@interface CMRDownloader(HTTPRequestHeader)
+ (NSMutableDictionary *) defaultRequestHeaders;
+ (NSString *) applicationUserAgent;
+ (NSString *) monazillaUserAgent;
@end



@interface CMRDownloader(PrivateAccessor)
- (void) setCurrentConnector : (SGHTTPConnector *) aCurrentConnector;
- (void) setupRequestHeaders : (NSMutableDictionary *) mdict;
- (SGHTTPConnector *) makeHTTPConnectorWithURL : (NSURL *) anURL;
- (NSURL *) resourceURLForWebBrowser;
@end



//:CMRDownloader-Task.m
#define APP_DOWNLOADER_TABLE_NAME		@"Downloader"
#define APP_DOWNLOADER_TITLE			@"Title"
#define APP_DOWNLOADER_MESSAGE			@"Message"
#define APP_DOWNLOADER_NOTLOADED		@"Not Loaded"
#define APP_DOWNLOADER_ERROR			@"Error"
#define APP_DOWNLOADER_CANCEL			@"Cancel"
#define APP_DOWNLOADER_SUCCESS			@"Success"
#define APP_DOWNLOADER_DOWNLOAD			@"Download"
#define APP_DOWNLOADER_AMOUNT_FORMAT	@"(%d/%d kb)"


#define APP_DOWNLOADER_FAIL_LOADING_STR	@"Couldnt_Load_Data"
#define APP_DOWNLOADER_FAIL_LOADING_FMT	@"Reason_Couldnt_Load_Data"


@interface CMRDownloader(Description)
- (NSString *) categoryDescription;
- (NSString *) simpleDescription;
- (NSString *) resourceName;
@end



@interface CMRDownloader(ResourceManagement)
- (BOOL) isFirstArrivalWithURLHandle : (NSURLHandle *) URLHandle
	  resourceDataDidBecomeAvailable : (NSData      *) newBytes;
- (BOOL) shouldCancelWithFirstArrivalData : (NSData *) newBytes;
- (void) cancelDownloadWithPostingNotificationName : (NSString *) name;

- (void) synchronizeServerClock : (SGHTTPConnector *) connector;
@end



@interface CMRDownloader(CMRLocalizableStringsOwner)
- (NSString *) amountString;
- (NSString *) localizedErrorString;
- (NSString *) localizedSucceededString;
- (NSString *) localizedCanceledString;
- (NSString *) localizedNotLoaded;

- (NSString *) localizedDownloadString;
- (NSString *) localizedTitleFormat;
- (NSString *) localizedMessageFormat;
@end



@interface CMRDownloader(TaskNotification)
- (void) postTaskWillStartNotification;
- (void) postTaskDidFinishNotification;
@end