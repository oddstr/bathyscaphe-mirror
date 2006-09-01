//:NSDocumentController_CMRExtensions.m
/**
  *
  * 
  *
  * @author Takanori Ishikawa
  * @author http://www15.big.or.jp/~takanori/
  * @version 1.0.0d1 (02/09/15  10:55:57 PM)
  *
  */
#import "CMRDocumentController.h"
#import "CocoMonar_Prefix.h"
#import "CMRReplyDocumentFileManager.h"
#import "CMRBrowser.h"
// Deprecatd in TestaRossa and later, because of performance issue.
// this method was used in CMRDocumentFileManage.m and CMRReplyDocumentFileManager.m
/*@implementation NSDocumentController(CMRExtensions)
- (NSString *) firstFileExtensionFromType:(NSString *) documentTypeName
{
	NSArray		*fileExtensions_;
	
	fileExtensions_ = [self fileExtensionsFromType : documentTypeName];
	if(nil == fileExtensions_ || 0 == [fileExtensions_ count])
		return nil;
	
	return [fileExtensions_ objectAtIndex : 0];
}
@end*/

static int	numOfBrowsers = 0;
static BOOL shouldCascadeBrowser = NO;

@implementation CMRDocumentController
- (void) noteNewRecentDocumentURL : (NSURL *) aURL
{
	// block!
}

- (IBAction) newDocument: (id) sender
{
	NSLog(@"NN");
	shouldCascadeBrowser = (numOfBrowsers == 0) ? NO : YES;
	[super newDocument : sender];
}

- (void) addDocument: (NSDocument *) document
{
	[super addDocument : document];
	if ([[document fileType] isEqualToString: CMRBrowserDocumentType]) {
		numOfBrowsers++;
	}
}

- (void)removeDocument: (NSDocument *) document
{
	if ([[document fileType] isEqualToString: CMRBrowserDocumentType]) {
		numOfBrowsers--;
	}
	[super removeDocument : document];
}

+ (BOOL) shouldCascadeBrowserWindow
{
	return shouldCascadeBrowser;
}

+ (void) setShouldCascadeBrowserWindow: (BOOL) nextTime
{
	shouldCascadeBrowser = nextTime;
}
@end
