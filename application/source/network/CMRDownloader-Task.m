//
//  CMRDownloader-Task.m
//  BathyScaphe "Twincam Angel"
//
//  Updated by Tsutomu Sawada on 07/07/22.
//  Copyright 2007 BathyScaphe Project. All rights reserved.
//

#import "CMRDownloader_p.h"


@implementation CMRDownloader(CMRDownloader)
- (void) startLoadInBackground
{
	[self loadInBackground];
}

- (void) cancelDownload
{
	if (![self isDownloadInProgress]) return;
	[[self currentConnector] cancel];
}

- (BOOL) isDownloadInProgress
{
	return m_isInProgress;
}
- (void)setIsDownloadInProgress:(BOOL)inProgress
{
	m_isInProgress = inProgress;
}
@end


@implementation CMRDownloader(Description)
- (NSString *) categoryDescription
{
	return [[CMRDocumentFileManager defaultManager] boardNameWithLogPath : [self filePathToWrite]];
}
- (NSString *) simpleDescription
{
	return [self localizedDownloadString];
}
- (NSString *) resourceName
{
	UTILAbstractMethodInvoked;
	return nil;
}
@end


@implementation CMRDownloader(CMRLocalizableStringsOwner)
- (NSString *) localizedDownloadString
{
	return [NSString stringWithFormat:[self localizedString:APP_DOWNLOADER_DOWNLOAD], [self resourceName]];
}

- (NSString *) localizedErrorString
{
	return [self localizedString:APP_DOWNLOADER_ERROR];
}
- (NSString *) localizedCanceledString
{
	return [self localizedString:APP_DOWNLOADER_CANCEL];
}

- (NSString *) localizedSucceededString
{
	return [self localizedString:APP_DOWNLOADER_SUCCESS];
}
- (NSString *) localizedNotLoaded
{
	return [self localizedString:APP_DOWNLOADER_NOTLOADED];
}

- (NSString *) localizedTitleFormat
{
	return [self localizedString:APP_DOWNLOADER_TITLE];
}
- (NSString *) localizedMessageFormat
{
	return [self localizedString:APP_DOWNLOADER_MESSAGE];
}
+ (NSString *) localizableStringsTableName
{
	return APP_DOWNLOADER_TABLE_NAME;
}
@end


@implementation CMRDownloader(TaskNotification)
- (void) postTaskWillStartNotification
{
	[[NSNotificationCenter defaultCenter] postNotificationName:CMRTaskWillStartNotification object:self];
}

- (void) postTaskDidFinishNotification
{
	[[NSNotificationCenter defaultCenter] postNotificationName:CMRTaskDidFinishNotification object:self];
}
@end
