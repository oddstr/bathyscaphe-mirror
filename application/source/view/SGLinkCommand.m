//:SGLinkCommand.m
#import "SGLinkCommand.h"
#import "CocoMonar_Prefix.h"
#import <SGAppKit/NSWorkspace-SGExtensions.h>
#import <SGNetwork/BSIPIDownload.h>
#import "AppDefaults.h"

#import "CMRTask.h"
#import "CMRTaskManager.h"

@implementation SGLinkCommand : SGFunctor
- (id) link
{
	id		obj_;
	
	obj_ = [self objectValue];
	UTILAssertNotNil(obj_);
	
	return obj_;
}
- (NSURL *) URLValue
{
	if([[self link] isKindOfClass : [NSURL class]]) return [self link];
	return [NSURL URLWithString : [self stringValue]];
}
- (NSString *) stringValue
{
	return [[self link] respondsToSelector : @selector(absoluteString)]
				? [[self link] absoluteString]
				: [[self link] description];
}
@end



@implementation SGCopyLinkCommand : SGLinkCommand
- (void) execute : (id) sender
{
	NSPasteboard	*pboard_;
	NSArray			*types_;
	
	pboard_ = [NSPasteboard generalPasteboard];
	if(nil == pboard_) return;
	types_ = [NSArray arrayWithObjects : 
				NSURLPboardType,
				NSStringPboardType,
				nil];
	
	[pboard_ declareTypes:types_ owner:nil];
	
	
	[[self URLValue] writeToPasteboard : pboard_];
	[pboard_ setString:[self stringValue] forType:NSStringPboardType];
}
@end



@implementation SGOpenLinkCommand : SGLinkCommand
- (void) execute : (id) sender
{
	[[NSWorkspace sharedWorkspace] openURL : [self URLValue] inBackGround : [CMRPref openInBg]];
}
@end

@implementation SGPreviewLinkCommand : SGLinkCommand
- (void) execute : (id) sender
{
	[[CMRPref sharedImagePreviewer] showImageWithURL : [self URLValue]];
}
@end

@implementation SGDownloadLinkCommand
- (id)initWithObject:(id)obj
{
	if (self = [super initWithObject:obj]) {
		m_expectLength = 0;
		m_downloadedLength = 0;
	}
	return self;
}

- (void)dealloc
{
	[self setMessage:nil];
	[self setCurrentDownload:nil];
	[super dealloc];
}

- (void)execute:(id)sender
{
	NSString *destination = [CMRPref linkDownloaderDestination];
	UTILAssertNotNil(destination);

	BSIPIDownload *download = [[BSIPIDownload alloc] initWithURLIdentifier:[self URLValue] delegate:self destination:destination];
	[self setCurrentDownload:download];
	[download release];

	[self setMessage:NSLocalizedStringFromTable(@"Downloading Message", @"CMRTaskDescription", @"")];
	[[CMRTaskManager defaultManager] addTask:self];
	UTILNotifyName(CMRTaskWillStartNotification);
}

- (void) bsIPIdownload: (BSIPIDownload *) aDownload willDownloadContentOfSize: (double) expectedLength
{
	m_expectLength = expectedLength;
}

- (void) bsIPIdownload: (BSIPIDownload *) aDownload didDownloadContentOfSize: (double) downloadedLength
{
	m_downloadedLength = downloadedLength;

	if (m_expectLength > 0) {
		NSString *template;
		double rate;
		if (m_expectLength > 1024*1024) {
			template = NSLocalizedStringFromTable(@"Downloading Message M", @"CMRTaskDescription", @"");
			rate = 1024*1024;
		} else {
			template = NSLocalizedStringFromTable(@"Downloading Message K", @"CMRTaskDescription", @"");
			rate = 1024;
		}
		[self setMessage:[NSString stringWithFormat:template, m_downloadedLength/rate, m_expectLength/rate]];
	}

	UTILNotifyName(CMRTaskWillProgressNotification);
}

- (void) bsIPIdownloadDidFinish: (BSIPIDownload *) aDownload
{
	NSString *template;
	double rate;

	NSString *ext = [[[self stringValue] componentsSeparatedByString:@"."] lastObject];
	unsigned hoge = [[CMRPref linkDownloaderExtensionTypes] indexOfObject:ext];
	if (hoge != NSNotFound) {
		BOOL hage = [[[CMRPref linkDownloaderAutoopenTypes] objectAtIndex:hoge] boolValue];
		if (hage) {
			[[NSWorkspace sharedWorkspace] openFile:[aDownload downloadedFilePath]];
		}
	}

	[self setCurrentDownload:nil];

	if (m_downloadedLength > 1024*1024) {
		template = NSLocalizedStringFromTable(@"Download Finished M", @"CMRTaskDescription", @"");
		rate = 1024*1024;
	} else {
		template = NSLocalizedStringFromTable(@"Download Finished K", @"CMRTaskDescription", @"");
		rate = 1024;
	}

	[self setMessage:[NSString stringWithFormat:template, m_downloadedLength/rate]];
	UTILNotifyName(CMRTaskDidFinishNotification);
}

- (BOOL) bsIPIdownload: (BSIPIDownload *) aDownload didRedirectToURL: (NSURL *) newURL
{
	NSAlert *alert = [[[NSAlert alloc] init] autorelease];
	NSString *message;
	message = [NSString stringWithFormat:NSLocalizedStringFromTable(@"RedirectionAlertMessage", @"HTMLView", @""), [newURL absoluteString]];
	[alert setAlertStyle:NSCriticalAlertStyle];
	[alert setMessageText:NSLocalizedStringFromTable(@"RedirectionAlertTitle", @"HTMLView", @"")];
	[alert setInformativeText:message];
	[alert addButtonWithTitle:NSLocalizedStringFromTable(@"RedirectionAlertCancelBtn", @"HTMLView", @"")];
	[alert addButtonWithTitle:NSLocalizedStringFromTable(@"RedirectionAlertContinueBtn", @"HTMLView", @"")];
	if ([alert runModal] == NSAlertSecondButtonReturn) {
		return YES;
	}
	return NO;
}

- (void) bsIPIdownload: (BSIPIDownload *) aDownload didAbortRedirectionToURL: (NSURL *) anURL
{
	[self cancel:nil];
}

- (void) bsIPIdownload: (BSIPIDownload *) aDownload didFailWithError: (NSError *) aError
{
	[self cancel:nil];

	NSAlert *alert = [[[NSAlert alloc] init] autorelease];
	[alert setAlertStyle:NSWarningAlertStyle];
	[alert setMessageText:NSLocalizedStringFromTable(@"FailDownloadAlertTitle", @"HTMLView", @"")];
	[alert setInformativeText:[aError localizedDescription]];
	[alert runModal];
}

#pragma mark Accessors
- (BSIPIDownload *)currentDownload
{
	return m_currentDownload;
}

- (void)setCurrentDownload:(BSIPIDownload *)download
{
	[download retain];
	[m_currentDownload release];
	m_currentDownload = download;
}

- (void)setMessage:(NSString *)string
{
	[string retain];
	[m_message release];
	m_message = string;
}

#pragma mark CMRTask
- (id)identifier
{
	return [self stringValue];
}

- (NSString *)title
{
	NSString *linkFileName = [[[self stringValue] componentsSeparatedByString:@"/"] lastObject];
	return [NSString stringWithFormat:NSLocalizedStringFromTable(@"Downloading Link", @"CMRTaskDescription", @""), linkFileName];
}

- (NSString *)message
{
	return m_message;
}

- (BOOL)isInProgress
{
	return ([self currentDownload] != nil);
}

- (double)amount
{
	if (m_expectLength == 0) return -1;
	double hoge = m_downloadedLength/m_expectLength*100.0;
	if (hoge >= 0 && hoge <= 100.0) return hoge;
	return -1;
}

- (IBAction)cancel:(id)sender
{
	NSString *toBeRemoved;
	[[self currentDownload] cancel];

	toBeRemoved = [[self currentDownload] downloadedFilePath];
	if (toBeRemoved && [[NSFileManager defaultManager] fileExistsAtPath:toBeRemoved]) {
		[[NSFileManager defaultManager] removeFileAtPath:toBeRemoved handler:nil];
	}

	[self setCurrentDownload:nil];
	[self setMessage:NSLocalizedStringFromTable(@"Cancel", @"CMRTaskDescription", @"")];
	UTILNotifyName(CMRTaskDidFinishNotification);
}
@end
