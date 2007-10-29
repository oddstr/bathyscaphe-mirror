//
//  BoardWarrior.m
//  BathyScaphe
//
//  Created by Tsutomu Sawada on 06/08/06.
//  Copyright 2006 BathyScaphe Project. All rights reserved.
//

#import "BoardWarrior.h"
#import "CocoMonar_Prefix.h"
#import "AppDefaults.h"
//#import <SGNetwork/BSIPIDownload.h>
#import "CMRTaskManager.h"
#import <Carbon/Carbon.h>
#import <OgreKit/OgreKit.h>

NSString *const BoardWarriorWillStartDownloadNotification	= @"BoardWarriorWillStartDownloadNotification";
NSString *const BoardWarriorDidFinishDownloadNotification	= @"BoardWarriorDidFinishDownloadNotification";
NSString *const BoardWarriorDidFailDownloadNotification		= @"BoardWarriorDidFailDownloadNotification";
NSString *const BoardWarriorDidFailInitASNotification		= @"BoardWarriorDidFailInitASNotification";

NSString *const BoardWarriorWillStartCreateDefaultListTaskNotification	= @"BoardWarriorWillStartCreateDefaultListTaskNotification";
NSString *const BoardWarriorDidFailCreateDefaultListTaskNotification	= @"BoardWarriorDidFailCreateDefaultListTaskNotification";

NSString *const BoardWarriorWillStartSyncUserListTaskNotification	= @"BoardWarriorWillStartSyncUserListTaskNotification";
NSString *const BoardWarriorDidFailSyncUserListTaskNotification		= @"BoardWarriorDidFailSyncUserListTaskNotification";

NSString *const BoardWarriorDidFinishAllTaskNotification = @"BoardWarriorDidFinishAllTaskNotification";

NSString *const kBWInfoExpectedLengthKey	= @"ExpectedContentLength";
NSString *const kBWInfoErrorStringKey		= @"ErrorDescription";

static NSString *const kBWLocalizedStringsTableName = @"BoardWarrior";

static NSString *const kBWLogFolderName	= @"Logs";
static NSString *const kBWLogFileName	= @"BathyScaphe BoardWarrior.log";

static NSString *const kBWTaskTitleKey			= @"BW_task title";
static NSString *const kBWTaskMsgKey			= @"BW_task message";
static NSString *const kBWTaskMsgFailedKey		= @"BW_task fail";
static NSString *const kBWTaskMsgFinishedKey	= @"BW_task finish";

@implementation BoardWarrior
APP_SINGLETON_FACTORY_METHOD_IMPLEMENTATION(warrior);

- (void) dealloc
{
	[m_bbsMenuPath release];
	[m_progressMessage release];
	m_currentDownload = nil;
	[super dealloc];
}

+ (NSString *) localizableStringsTableName
{
	return kBWLocalizedStringsTableName;
}

#pragma mark CMRTask Protocol
- (BOOL) isInProgress
{
	return m_isInProgress;
}

- (id) identifier
{
	return @"BoardWarrior_warrior";
}

- (NSString *) title
{
	return [self localizedString: kBWTaskTitleKey];
}

- (NSString *) message
{
	return m_progressMessage;
}

- (double) amount
{
	return -1;
}

- (IBAction) cancel: (id) sender
{
	if (m_currentDownload != nil) {
		[m_currentDownload cancel];
	} else {
		NSBeep();
	}
}

#pragma mark Accessors
- (double) expectedContentLength
{
	return m_expectedContentLength;
}

- (double) downloadedContentLength
{
	return m_downloadedContentLength;
}

- (void) setMessage: (NSString *) progressMessage
{
	[progressMessage retain];
	[m_progressMessage release];
	m_progressMessage = progressMessage;
}

- (NSString *) bbsMenuPath
{
	return m_bbsMenuPath;
}

- (void) setBbsMenuPath: (NSString *) filePath
{
	[filePath retain];
	[m_bbsMenuPath release];
	m_bbsMenuPath = filePath;
}

#pragma mark Private Utilities
- (BOOL) doHandler: (NSString *) handlerName inScript: (NSAppleScript *) appleScript withParameters: (NSArray *) params error: (NSDictionary **) errPtr
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
}

- (NSData *) encodedLocalizedStringForKey: (NSString *) key format: (NSString *) format
{
	NSString *str = [self localizedString: key];
	
	return [[NSString stringWithFormat: str, format] dataUsingEncoding: NSUTF8StringEncoding];
}

- (void) notifyCMRTaskDidFail
{
	[self setMessage: [self localizedString: kBWTaskMsgFailedKey]];
	m_isInProgress = NO;
	UTILNotifyName(CMRTaskDidFinishNotification);
}

- (NSArray *) parametersForHandler: (NSString *) handlerName
{
	NSBundle *bathyscaphe = [NSBundle mainBundle];
	NSString *logFolderPath_ = [[CMRFileManager defaultManager] dataRootDirectoryPath];

	if ([handlerName isEqualToString: @"make_default_list"]) {
		NSString *soraToolPath_ = [bathyscaphe pathForResource: @"sora" ofType: @"pl"];
		NSString *convertToolPath_ = [bathyscaphe pathForResource: @"SJIS2UTF8" ofType: @""];
		return [NSArray arrayWithObjects: soraToolPath_, convertToolPath_, logFolderPath_, [self bbsMenuPath], nil];
	} else {
		NSString *rosettaToolPath_ = [bathyscaphe pathForResource: @"rosetta" ofType: @"pl"];
		return [NSArray arrayWithObjects: rosettaToolPath_, logFolderPath_, [self bbsMenuPath], nil];
	}
}

- (void) doHandler: (NSString *) handlerName inScript: (NSAppleScript *) script
{
	NSDictionary *errors_ = [NSDictionary dictionary];
	NSArray *params_ = [self parametersForHandler: handlerName];

	if (![self doHandler: handlerName inScript: script withParameters: params_ error: &errors_]) {
		NSDictionary *info_ = [NSDictionary dictionaryWithObject: [errors_ objectForKey:NSAppleScriptErrorBriefMessage]
														  forKey: kBWInfoErrorStringKey];

		NSString *errDescription_ = [errors_ objectForKey:NSAppleScriptErrorMessage];
		[self writeLogsToFileWithUTF8Data: [self encodedLocalizedStringForKey: @"BW_sub_error %@" format: errDescription_]];

		[self notifyCMRTaskDidFail];

		UTILNotifyInfo(BoardWarriorDidFailCreateDefaultListTaskNotification, info_);
		return;
	}
	[self writeLogsToFileWithUTF8Data: [self encodedLocalizedStringForKey: @"BW_run %@" format: handlerName]];
}

- (NSURL *) fileURLWithResource: (NSString *) name ofType: (NSString *) extension
{
	NSBundle *bundle_ = [NSBundle mainBundle];
	NSString *path_ = [bundle_ pathForResource: name ofType: extension];
	if (!path_) return nil;
	
	return [NSURL fileURLWithPath: path_];
}

- (void) startAppleScriptTask
{
	/* まず NSAppleScript インスタンスを生成 */
	NSURL *url_ = [self fileURLWithResource: @"BoardWarrior" ofType: @"scpt"];
	if (!url_) {
		NSDictionary *hoge_ = [NSDictionary dictionaryWithObject: [self localizedString: @"BW_fail_init"]
														  forKey: kBWInfoErrorStringKey];
		[self writeLogsToFileWithUTF8Data: [self encodedLocalizedStringForKey: @"BW_fail_script1" format: @"BoardWarrior"]];

		[self notifyCMRTaskDidFail];

		UTILNotifyInfo(BoardWarriorDidFailInitASNotification, hoge_);
		return;
	}

	NSAppleScript *script_ = [[NSAppleScript alloc] initWithContentsOfURL: url_ error: NULL];
	if (!script_) {
		NSDictionary *hoge_ = [NSDictionary dictionaryWithObject: [self localizedString: @"BW_fail_init"]
														  forKey: kBWInfoErrorStringKey];
		[self writeLogsToFileWithUTF8Data: [self encodedLocalizedStringForKey: @"BW_fail_script2" format: @"BoardWarrior"]];

		[self notifyCMRTaskDidFail];

		UTILNotifyInfo(BoardWarriorDidFailInitASNotification, hoge_);
		return;
	}

	/* make_default_list */
	UTILNotifyName(BoardWarriorWillStartCreateDefaultListTaskNotification);
	[self doHandler: @"make_default_list" inScript: script_];

	/* update_user_list */
	UTILNotifyName(BoardWarriorWillStartSyncUserListTaskNotification);
	[self doHandler: @"update_user_list" inScript: script_];

	[script_ release];

	// delete bbsmenu.html
	[[NSFileManager defaultManager] removeFileAtPath: [self bbsMenuPath] handler: nil];
	[self setBbsMenuPath: nil];

	NSDate *date_ = [NSDate date];
	[CMRPref setLastSyncDate: date_];
	m_isInProgress = NO;
	[self writeLogsToFileWithUTF8Data: [self encodedLocalizedStringForKey: @"BW_finish at date %@" format: [date_ description]]];

	[self setMessage: [self localizedString: kBWTaskMsgFinishedKey]];
	UTILNotifyName(CMRTaskDidFinishNotification);

	UTILNotifyName(BoardWarriorDidFinishAllTaskNotification);
	[[CMRFileManager defaultManager] updateWatchedFiles]; 
}

#pragma mark Public Methods
- (BOOL) syncBoardLists
{
	return [self syncBoardListsWithURL: [CMRPref BBSMenuURL]];
}

- (BOOL) syncBoardListsWithURL: (NSURL *) anURL
{
	BSURLDownload	*newDownload_;
	NSString		*tmpDir_ = NSTemporaryDirectory();

	if ([self isInProgress] || tmpDir_ == nil) {
		return NO;
	}

	newDownload_ = [[BSURLDownload alloc] initWithURL: anURL delegate: self destination: tmpDir_];
	if (newDownload_) {
		NSData *logMsg;

		[self setMessage: [self localizedString: kBWTaskMsgKey]];
		[[CMRTaskManager defaultManager] addTask: self];
		UTILNotifyName(CMRTaskWillStartNotification);
		m_isInProgress = YES;
		m_currentDownload = newDownload_;

		logMsg = [self encodedLocalizedStringForKey: @"BW_start at date %@" format: [[NSDate date] description]];
		[self writeLogsToFileWithUTF8Data: logMsg];
	} else {
		return NO;
	}
	
	return YES;
}

- (BOOL) writeLogsToFileWithUTF8Data: (NSData *) encodedData
{
	if (!encodedData) return NO;

	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES);
	BOOL	isDir;

	if ([paths count] == 1) {
		NSFileManager *fileManager = [NSFileManager defaultManager];
		NSString *logsPath = [[paths objectAtIndex: 0] stringByAppendingPathComponent: kBWLogFolderName];
		NSString *logFilePath = [logsPath stringByAppendingPathComponent: kBWLogFileName];
 
		if ([fileManager fileExistsAtPath: logsPath isDirectory: &isDir] && isDir) {
			NSFileHandle *fileHandle = [NSFileHandle fileHandleForWritingAtPath: logFilePath];
			
			if (fileHandle) {
				[fileHandle seekToEndOfFile];
				[fileHandle writeData: encodedData];
				[fileHandle closeFile];
				return YES;
			} else {
				return [fileManager createFileAtPath: logFilePath contents: encodedData attributes: nil];
			}
		}
	}
	
	return NO;
}

#pragma mark BSIPIDownload Delegate
- (void)bsURLDownload: (BSURLDownload *)aDownload willDownloadContentOfSize:(double)expectedLength
{
	NSDictionary *info_ = [NSDictionary dictionaryWithObject: [NSNumber numberWithDouble: expectedLength] forKey: kBWInfoExpectedLengthKey];
	m_expectedContentLength = expectedLength;

	[self writeLogsToFileWithUTF8Data: [self encodedLocalizedStringForKey: @"BW_download from %@"
																   format: [[aDownload URL] absoluteString]]];	
	UTILNotifyInfo(BoardWarriorWillStartDownloadNotification, info_);
}

- (void)bsURLDownload:(BSURLDownload *)aDownload didDownloadContentOfSize:(double)downloadedLength
{
	m_downloadedContentLength = downloadedLength;
}

- (void)bsURLDownloadDidFinish:(BSURLDownload *)aDownload
{
	[self setBbsMenuPath: [aDownload downloadedFilePath]];
	[self writeLogsToFileWithUTF8Data: [[self localizedString: @"BW_download finish"] dataUsingEncoding: NSUTF8StringEncoding]];
	UTILNotifyName(BoardWarriorDidFinishDownloadNotification);

	[aDownload release];
	m_currentDownload = nil;
	[self startAppleScriptTask];
}

- (void)bsURLDownload:(BSURLDownload *)aDownload didFailWithError:(NSError *)aError
{
	[self writeLogsToFileWithUTF8Data: [self encodedLocalizedStringForKey: @"BW_download fail %@" format: [aError description]]];

	[aDownload release];
	m_currentDownload = nil;
	m_isInProgress = NO;

	[self notifyCMRTaskDidFail];

	NSDictionary *info_ = [NSDictionary dictionaryWithObject: @"Some error occurred while downloading BBSMenu." forKey: kBWInfoErrorStringKey];
	UTILNotifyInfo(BoardWarriorDidFailDownloadNotification, info_);
}
@end
