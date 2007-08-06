//:SGLinkCommand.h
#import <Cocoa/Cocoa.h>
#import "SGFunctor.h"

@class BSIPIDownload;
@protocol CMRTask;

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
	BSIPIDownload *m_currentDownload;
	double m_expectLength;
	double m_downloadedLength;
	NSString *m_message;
}

- (BSIPIDownload *)currentDownload;
- (void)setCurrentDownload:(BSIPIDownload *)download;
- (void)setMessage:(NSString *)string;
@end