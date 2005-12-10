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



@implementation CMRDocumentController : NSDocumentController
- (void) noteNewRecentDocumentURL : (NSURL *) aURL
{
	/*NSString		*pathExtension_;
	NSString		*replyDocExtension_;
	
	pathExtension_ = [[aURL path] pathExtension];
	replyDocExtension_ = 
		[[CMRReplyDocumentFileManager defaultManager]
								replyDocumentFileExtention];
	if([replyDocExtension_ isEqualToString : pathExtension_])
		return;
	
	[super noteNewRecentDocumentURL : aURL];*/
}
@end
