//:SGLinkCommand.h
#import <Cocoa/Cocoa.h>
#import "SGFunctor.h"
#import "CMRTask.h"

@class BSURLDownload;

@interface SGLinkCommand : SGFunctor
- (id) link;
- (NSURL *) URLValue;
- (NSString *) stringValue;
@end



@interface SGCopyLinkCommand : SGLinkCommand
@end



@interface SGOpenLinkCommand : SGLinkCommand
@end

// added in Lemonade and later.
@interface SGPreviewLinkCommand : SGLinkCommand
@end

// Available in Twincam Angel and later.
@interface SGDownloadLinkCommand : SGLinkCommand<CMRTask>
{
	BSURLDownload *m_currentDownload;
	double m_expectLength;
	double m_downloadedLength;
	NSString *m_message;
	double m_amount;
}

- (BSURLDownload *)currentDownload;
- (void)setCurrentDownload:(BSURLDownload *)download;
@end
