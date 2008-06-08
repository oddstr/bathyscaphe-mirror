//
//  BoardWarrior.m
//  BathyScaphe
//
//  Created by Tsutomu Sawada on 06/08/06.
//  Copyright 2006-2007 BathyScaphe Project. All rights reserved.
//  encoding="UTF-8"
//

#import "CMRTask.h"
#import "BoardWarrior.h"
#import "CocoMonar_Prefix.h"
#import "AppDefaults.h"
#import "BSDateFormatter.h"
#import "CMRTaskManager.h"
#import "BoardManager.h"
#import <SGAppKit/NSAppleScript-SGExtensions.h>
#import <Carbon/Carbon.h>

NSString *const kBoardWarriorErrorDomain	= @"BoardWarriorErrorDomain";

static NSString *const kBWLocalizedStringsTableName = @"BoardWarrior";

static NSString *const kBWLogFolderName	= @"Logs";
static NSString *const kBWLogFileName	= @"BathyScaphe BoardWarrior.log";

static NSString *const kBWTaskTitleKey			= @"BW_task title";
static NSString *const kBWTaskMsgKey			= @"BW_task message";
static NSString *const kBWTaskMsgFailedKey		= @"BW_task fail";
static NSString *const kBWTaskMsgFinishedKey	= @"BW_task finish";

@interface BoardWarrior(Private)
- (NSString *)bbsMenuPath;
- (void)setBbsMenuPath:(NSString *)filePath;
/*
- (double)expectedContentLength;
- (double)downloadedContentLength;
*/
- (NSData *)encodedLocalizedStringForKey:(NSString *)key format:(NSString *)format;
- (BOOL)writeLogsToFileWithUTF8Data:(NSData *)encodedData;
@end


@implementation BoardWarrior
APP_SINGLETON_FACTORY_METHOD_IMPLEMENTATION(warrior);

- (id)delegate
{
	return m_delegate;
}

- (void)setDelegate:(id)aDelegate
{
	m_delegate = aDelegate;
}

- (BOOL)syncBoardLists
{
	return [self syncBoardListsWithURL:[CMRPref BBSMenuURL]];
}

- (BOOL)syncBoardListsWithURL:(NSURL *)anURL
{
	BSURLDownload	*newDownload_;
	NSString		*tmpDir_ = NSTemporaryDirectory();

	if ([self isInProgress] || !tmpDir_) {
		return NO;
	}

	newDownload_ = [[BSURLDownload alloc] initWithURL:anURL delegate:self destination:tmpDir_];
	if (newDownload_) {
		NSData *logMsg;

		[self setMessage:[self localizedString:kBWTaskMsgKey]];
		[[CMRTaskManager defaultManager] addTask:self];
		UTILNotifyName(CMRTaskWillStartNotification);
		[self setIsInProgress:YES];
		m_currentDownload = newDownload_;

		logMsg = [self encodedLocalizedStringForKey:@"BW_start at date %@" format:[[NSDate date] description]];
		[self writeLogsToFileWithUTF8Data:logMsg];
	} else {
		return NO;
	}

	return YES;
}

- (NSString *)logFilePath
{
	NSString *logsPath = [[CMRFileManager defaultManager] userDomainLogsFolderPath];
	if (!logsPath) return nil;

	return [logsPath stringByAppendingPathComponent:kBWLogFileName];
}

#pragma mark Overrides
- (id)init
{
	if (self = [super init]) {
		NSString *lastSyncInfo;
		NSDate *lastDate = [CMRPref lastSyncDate];
		if (lastDate) {
			lastSyncInfo = [[BSDateFormatter sharedDateFormatter] stringForObjectValue:lastDate];
		} else {
			lastSyncInfo = [self localizedString:@"Never Synced"];
		}
		[self setMessage:lastSyncInfo];
	}
	return self;
}

- (void)dealloc
{
	[m_bbsMenuPath release];
	[m_progressMessage release];
	m_currentDownload = nil;
	m_delegate = nil;
	[super dealloc];
}

+ (NSString *)localizableStringsTableName
{
	return kBWLocalizedStringsTableName;
}

#pragma mark CMRTask Protocol
- (BOOL)isInProgress
{
	return m_isInProgress;
}

- (void)setIsInProgress:(BOOL)flag
{
	m_isInProgress = flag;
}

- (id)identifier
{
	return @"BoardWarrior_task";
}

- (NSString *)title
{
	return [self localizedString:kBWTaskTitleKey];
}

- (NSString *)message
{
	return m_progressMessage;
}

- (void)setMessage:(NSString *)aMessage
{
	[aMessage retain];
	[m_progressMessage release];
	m_progressMessage = aMessage;
}

- (double)amount
{
	return -1;
}

- (IBAction)cancel:(id)sender
{
	// 当面、キャンセル不可。
	NSBeep();
}
@end


@implementation BoardWarrior(Private)
/*
- (double) expectedContentLength
{
	return m_expectedContentLength;
}

- (double) downloadedContentLength
{
	return m_downloadedContentLength;
}
*/
- (NSString *)bbsMenuPath
{
	return m_bbsMenuPath;
}

- (void)setBbsMenuPath:(NSString *)filePath
{
	[filePath retain];
	[m_bbsMenuPath release];
	m_bbsMenuPath = filePath;
}

/*- (BOOL)doHandler:(NSString *)handlerName inScript:(NSAppleScript *)appleScript withParameters:(NSArray *)params error:(NSDictionary **)errPtr
{
	int	i;
	NSAppleEventDescriptor* parameters = [NSAppleEventDescriptor listDescriptor];
	NSAppleEventDescriptor* eachParameter;
	for (i=0; i<[params count]; i++) {
		eachParameter = [NSAppleEventDescriptor descriptorWithString:[params objectAtIndex:i]];
		[parameters insertDescriptor:eachParameter atIndex:i+1];
	}

	// AppleEventターゲットを作成する
	ProcessSerialNumber psn = {0, kCurrentProcess};
	NSAppleEventDescriptor* target = [NSAppleEventDescriptor descriptorWithDescriptorType:typeProcessSerialNumber
																					bytes:&psn
																				   length:sizeof(ProcessSerialNumber)];

	NSAppleEventDescriptor* handler = [NSAppleEventDescriptor descriptorWithString:[handlerName lowercaseString]];

	// AppleScriptサブルーチンのイベントを作成する、
	// メソッド名とパラメータリストを設定する
	NSAppleEventDescriptor* event =
		[NSAppleEventDescriptor appleEventWithEventClass:kASAppleScriptSuite
												 eventID:kASSubroutineEvent
										targetDescriptor:target
												returnID:kAutoGenerateReturnID
										   transactionID:kAnyTransactionID];

	[event setParamDescriptor:handler forKeyword:keyASSubroutineName];
	[event setParamDescriptor:parameters forKeyword:keyDirectObject];

	// AppleScriptのイベントを呼び出す
	if (![appleScript executeAppleEvent:event error:errPtr]){
		// 'errors' からエラーを報告する
		return NO;
	}
	return YES;
}*/

- (NSData *)encodedLocalizedStringForKey:(NSString *)key format:(NSString *)format
{
	NSString *str = [self localizedString:key];

	return [[NSString stringWithFormat:str, format] dataUsingEncoding:NSUTF8StringEncoding];
}

- (BOOL)delegateRespondsToSelector:(SEL)selector
{
	id delegate = [self delegate];
	return (delegate && [delegate respondsToSelector:selector]);
}

- (void)notifyCMRTaskDidFail
{
	[self setMessage:[self localizedString:kBWTaskMsgFailedKey]];
	[self setIsInProgress:NO];
	UTILNotifyName(CMRTaskDidFinishNotification);
	NSBeep();
}

- (NSArray *)parametersForHandler:(NSString *)handlerName
{
	NSBundle *bathyscaphe = [NSBundle mainBundle];
	NSString *logFolderPath_ = [[CMRFileManager defaultManager] dataRootDirectoryPath];

	if ([handlerName isEqualToString:@"make_default_list"]) {
		NSString *soraToolPath_ = [bathyscaphe pathForResource:@"sora" ofType:@"pl"];
		NSString *convertToolPath_ = [bathyscaphe pathForResource:@"SJIS2UTF8" ofType:@""];
		return [NSArray arrayWithObjects:soraToolPath_, convertToolPath_, logFolderPath_, [self bbsMenuPath], nil];
	} else {
		NSString *rosettaToolPath_ = [bathyscaphe pathForResource:@"rosetta" ofType:@"pl"];
		return [NSArray arrayWithObjects:rosettaToolPath_, logFolderPath_, [self bbsMenuPath], nil];
	}
}

- (BOOL)doHandler:(NSString *)handlerName inScript:(NSAppleScript *)script
{
	NSDictionary *errors_ = [NSDictionary dictionary];
	NSArray *params_ = [self parametersForHandler:handlerName];

//	if (![self doHandler:handlerName inScript:script withParameters:params_ error:&errors_]) {
	if (![script doHandler:handlerName withParameters:params_ error:&errors_]) {
		NSString *errDescription_ = [errors_ objectForKey:NSAppleScriptErrorMessage];
		[self writeLogsToFileWithUTF8Data:[self encodedLocalizedStringForKey:@"BW_sub_error %@" format:errDescription_]];

		[self notifyCMRTaskDidFail];

		if ([self delegateRespondsToSelector:@selector(warrior:didFailSync:)] && errDescription_) {
			NSDictionary *userInfo = [NSDictionary dictionaryWithObject:errDescription_ forKey:NSLocalizedDescriptionKey];
			NSError *error = [NSError errorWithDomain:kBoardWarriorErrorDomain code:BWDidFailExecuteAppleScriptHandler userInfo:userInfo];
			[[self delegate] warrior:self didFailSync:error];
		}
		return NO;
	}

	[self writeLogsToFileWithUTF8Data:[self encodedLocalizedStringForKey:@"BW_run %@" format:handlerName]];
	return YES;
}

- (NSURL *)fileURLWithResource:(NSString *)name ofType:(NSString *)extension
{
	NSBundle *bundle_ = [NSBundle mainBundle];
	NSString *path_ = [bundle_ pathForResource:name ofType:extension];
	if (!path_) return nil;
	
	return [NSURL fileURLWithPath:path_];
}

- (void)startAppleScriptTask
{
	BoardManager *bm = [BoardManager defaultManager];

	/* まず NSAppleScript インスタンスを生成 */
	NSURL *url_ = [self fileURLWithResource:@"BoardWarrior" ofType:@"scpt"];
	if (!url_) {
		[self writeLogsToFileWithUTF8Data:[self encodedLocalizedStringForKey:@"BW_fail_script1" format:@"BoardWarrior"]];

		[self notifyCMRTaskDidFail];

		if ([self delegateRespondsToSelector:@selector(warrior:didFailSync:)]) {
			NSDictionary *userInfo = [NSDictionary dictionaryWithObject:[self localizedString:@"BW_fail_init"] forKey:NSLocalizedDescriptionKey];
			NSError *error = [NSError errorWithDomain:kBoardWarriorErrorDomain code:BWDidFailInitializeAppleScript userInfo:userInfo];
			[[self delegate] warrior:self didFailSync:error];
		}
		return;
	}

	NSAppleScript *script_ = [[NSAppleScript alloc] initWithContentsOfURL:url_ error:NULL];
	if (!script_) {
		[self writeLogsToFileWithUTF8Data:[self encodedLocalizedStringForKey:@"BW_fail_script2" format:@"BoardWarrior"]];

		[self notifyCMRTaskDidFail];

		if ([self delegateRespondsToSelector:@selector(warrior:didFailSync:)]) {
			NSDictionary *userInfo = [NSDictionary dictionaryWithObject:[self localizedString:@"BW_fail_init"] forKey:NSLocalizedDescriptionKey];
			NSError *error = [NSError errorWithDomain:kBoardWarriorErrorDomain code:BWDidFailInitializeAppleScript userInfo:userInfo];
			[[self delegate] warrior:self didFailSync:error];
		}
		return;
	}

	/* make_default_list */
	if (![self doHandler:@"make_default_list" inScript:script_]) {
		[script_ release];
		// delete bbsmenu.html
		[[NSFileManager defaultManager] removeFileAtPath:[self bbsMenuPath] handler:nil];
		[self setBbsMenuPath:nil];
		return;
	}

	/* update_user_list */
	BOOL success = [self doHandler:@"update_user_list" inScript:script_];

	[script_ release];

	// delete bbsmenu.html
	[[NSFileManager defaultManager] removeFileAtPath:[self bbsMenuPath] handler:nil];
	[self setBbsMenuPath:nil];

	if (!success) return;

	NSDate *date_ = [NSDate date];
	[CMRPref setLastSyncDate:date_];
	[self setIsInProgress:NO];
	[self writeLogsToFileWithUTF8Data:[self encodedLocalizedStringForKey:@"BW_finish at date %@" format:[date_ description]]];

	[self setMessage:[self localizedString:kBWTaskMsgFinishedKey]];
	UTILNotifyName(CMRTaskDidFinishNotification);
	[self setMessage:[[BSDateFormatter sharedDateFormatter] stringForObjectValue:date_]];

	SystemSoundPlay(22); // Disc Burned

	if ([self delegateRespondsToSelector:@selector(warriorDidFinishSyncing:)]) {
		[[self delegate] warriorDidFinishSyncing:self];
	}
//	[[CMRFileManager defaultManager] updateWatchedFiles];
	[[bm defaultList] reloadBoardFile:[bm defaultBoardListPath]];
	[[bm userList] reloadBoardFile:[bm userBoardListPath]];
}

- (BOOL)createLogFileIfNeededAtPath:(NSString *)filePath
{
	BOOL	isDir;
	NSFileManager *fm = [NSFileManager defaultManager];
	if ([fm fileExistsAtPath:filePath isDirectory:&isDir] && !isDir) {
		return YES;
	} else {
		return [fm createFileAtPath:filePath contents:[NSData data] attributes:nil];
	}
}

- (BOOL)writeLogsToFileWithUTF8Data:(NSData *)encodedData
{
	if (!encodedData) return NO;
	NSString *logFilePath = [self logFilePath];

	if (logFilePath && [self createLogFileIfNeededAtPath:logFilePath]) {
		NSFileHandle *fileHandle = [NSFileHandle fileHandleForWritingAtPath:logFilePath];
		
		[fileHandle seekToEndOfFile];
		[fileHandle writeData:encodedData];
		[fileHandle closeFile];
		return YES;
	}
	
	return NO;
}

#pragma mark BSIPIDownload Delegate
- (void)bsURLDownload:(BSURLDownload *)aDownload willDownloadContentOfSize:(double)expectedLength
{
/*
	m_expectedContentLength = expectedLength;
*/
	[self writeLogsToFileWithUTF8Data:[self encodedLocalizedStringForKey:@"BW_download from %@"
																  format:[[aDownload URL] absoluteString]]];	
}
/*
- (void)bsURLDownload:(BSURLDownload *)aDownload didDownloadContentOfSize:(double)downloadedLength
{
	m_downloadedContentLength = downloadedLength;
}
*/
- (void)bsURLDownloadDidFinish:(BSURLDownload *)aDownload
{
	[self setBbsMenuPath:[aDownload downloadedFilePath]];
	[self writeLogsToFileWithUTF8Data:[[self localizedString:@"BW_download finish"] dataUsingEncoding:NSUTF8StringEncoding]];

	[aDownload release];
	m_currentDownload = nil;
	[self startAppleScriptTask];
}

- (void)bsURLDownload:(BSURLDownload *)aDownload didFailWithError:(NSError *)aError
{
	[self writeLogsToFileWithUTF8Data:[self encodedLocalizedStringForKey:@"BW_download fail %@" format:[aError description]]];

	[self notifyCMRTaskDidFail];

	if ([self delegateRespondsToSelector:@selector(warrior:didFailSync:)]) {
		[[self delegate] warrior:self didFailSync:aError];
	}

	[aDownload release];
	m_currentDownload = nil;
}
@end
