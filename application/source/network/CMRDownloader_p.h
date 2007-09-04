//:CMRDownloader_p.h
#import "CMRDownloader.h"

#import <SGFoundation/SGFoundation.h>
#import <SGNetwork/SGHTTPDefines.h>
#import "CocoMonar_Prefix.h"

#import "CMRDocumentFileManager.h"
#import "CMRServerClock.h"
#import "CMXTextParser.h"
#import "CMRNetGrobalLock.h"



// simply check whether html data...
#define CHECK_HTML(bytes, len)		(nsr_strncasestr((const char*)(bytes), "<html", len) != NULL)

@interface CMRDownloader(PrivateAccessor)
- (void)setIdentifier:(id)anIdentifier;
- (void)setCurrentConnector:(NSURLConnection *)connection;
- (void) setupRequestHeaders : (NSMutableDictionary *) mdict;
- (NSURLConnection *)makeHTTPURLConnectionWithURL:(NSURL *)anURL;
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
#define APP_DOWNLOADER_FAIL_LOADING_FMT	@"Couldnt_Load_Data_Msg"


@interface CMRDownloader(Description)
- (NSString *) categoryDescription;
- (NSString *) simpleDescription;
- (NSString *) resourceName;
@end


@interface CMRDownloader(ResourceManagement)
- (void)cancelDownload;
- (void)cancelDownloadWithPostingNotificationName:(NSString *)name;
- (void)synchronizeServerClock:(NSHTTPURLResponse *)response;
@end


@interface CMRDownloader(CMRLocalizableStringsOwner)
- (NSString *)localizedErrorString;
- (NSString *)localizedSucceededString;
- (NSString *)localizedCanceledString;
- (NSString *)localizedUserCanceledString;
- (NSString *)localizedNotModifiedString;
- (NSString *)localizedDetectingDatOchiString;
- (NSString *)localizedNotLoaded;

- (NSString *)localizedDownloadString;
- (NSString *)localizedTitleFormat;
- (NSString *)localizedMessageFormat;
@end


@interface CMRDownloader(TaskNotification)
- (void) postTaskWillStartNotification;
- (void) postTaskDidFinishNotification;
@end
