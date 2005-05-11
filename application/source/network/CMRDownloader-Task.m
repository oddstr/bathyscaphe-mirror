//:CMRDownloader-Task.m
/**
  *
  * 
  *
  * @author Takanori Ishikawa
  * @author http://www15.big.or.jp/~takanori/
  * @version 1.0.0d1 (02/08/14  1:20:25 PM)
  *
  */
#import "CMRDownloader_p.h"



@implementation CMRDownloader(CMRDownloader)
- (void) startLoadInBackground
{
	[self loadInBackground];
}

- (void) cancelDownload
{
	if(NSURLHandleLoadInProgress != [self downloadStatus])
		return;
	[[self currentConnector] cancelLoadInBackground];
}
- (BOOL) isCanceledLoadInBackground
{
	if(nil == [self currentConnector])
		return NO;
	return [[self currentConnector] isCanceledLoadInBackground];
}

- (BOOL) isDownloadInProgress
{
	return (NSURLHandleLoadInProgress == [self downloadStatus]);
}

- (NSURLHandleStatus) downloadStatus
{
	if(nil == [self currentConnector])
		return NSURLHandleNotLoaded;
	return [[self currentConnector] status];
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
	return [NSString stringWithFormat :
				[self localizedString : APP_DOWNLOADER_DOWNLOAD],
				[self resourceName]];
}

- (NSString *) amountString
{
	unsigned	contentLength_	= 0;
	unsigned	bytesLength_	= 0;
	
	UTILRequireCondition(
		[self isInProgress],
		error_amountString);
	
	contentLength_ = [[self currentConnector] readContentLength];
	UTILRequireCondition(
		(contentLength_ != NSNotFound), 
		error_amountString);
	
	bytesLength_ = [[self currentConnector] loadedBytesLength];
	UTILRequireCondition(
		(bytesLength_ != 0), 
		error_amountString);
	
	return [NSString stringWithFormat : 
						APP_DOWNLOADER_AMOUNT_FORMAT,
						(bytesLength_ / 1024),
						(contentLength_ / 1024)];
	
	error_amountString:{
		return @"";
	}
}
- (NSString *) localizedErrorString
{
	SGHTTPResponse	*res_;
	
	res_ = [[self currentConnector] response];
	return [NSString stringWithFormat:
				[self localizedString : APP_DOWNLOADER_ERROR],
				res_?[res_ statusLine]:@""];
}
- (NSString *) localizedCanceledString
{
	return [self localizedString : APP_DOWNLOADER_CANCEL];
}

- (NSString *) localizedSucceededString
{
	return [self localizedString : APP_DOWNLOADER_SUCCESS];
}
- (NSString *) localizedNotLoaded
{
	return [self localizedString : APP_DOWNLOADER_NOTLOADED];
}

- (NSString *) localizedTitleFormat
{
	return [self localizedString : APP_DOWNLOADER_TITLE];
}
- (NSString *) localizedMessageFormat
{
	return [self localizedString : APP_DOWNLOADER_MESSAGE];
}
+ (NSString *) localizableStringsTableName
{
	return APP_DOWNLOADER_TABLE_NAME;
}
@end



@implementation CMRDownloader(TaskNotification)
- (void) postTaskWillStartNotification
{
	NSNotificationCenter	*nc_;
	
	nc_ = [NSNotificationCenter defaultCenter];
	[nc_ postNotificationName : CMRTaskWillStartNotification
					   object : self];
}

- (void) postTaskDidFinishNotification
{
	NSNotificationCenter	*nc_;
	
	nc_ = [NSNotificationCenter defaultCenter];
	[nc_ postNotificationName : CMRTaskDidFinishNotification
					   object : self];
}
@end