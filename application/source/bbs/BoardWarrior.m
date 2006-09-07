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
#import <SGNetwork/BSIPIDownload.h>
#import "CMRTaskManager.h"

NSString *const BoardWarriorWillStartDownloadNotification	= @"BoardWarriorWillStartDownloadNotification";
NSString *const BoardWarriorDidFinishDownloadNotification	= @"BoardWarriorDidFinishDownloadNotification";
NSString *const BoardWarriorDidFailDownloadNotification		= @"BoardWarriorDidFailDownloadNotification";

NSString *const BoardWarriorWillStartCreateDefaultListTaskNotification	= @"BoardWarriorWillStartCreateDefaultListTaskNotification";
NSString *const BoardWarriorDidFailCreateDefaultListTaskNotification	= @"BoardWarriorDidFailCreateDefaultListTaskNotification";

NSString *const BoardWarriorWillStartSyncUserListTaskNotification	= @"BoardWarriorWillStartSyncUserListTaskNotification";
NSString *const BoardWarriorDidFailSyncUserListTaskNotification		= @"BoardWarriorDidFailSyncUserListTaskNotification";

NSString *const BoardWarriorDidFinishAllTaskNotification = @"BoardWarriorDidFinishAllTaskNotification";

NSString *const kBWInfoExpectedLengthKey	= @"ExpectedContentLength";
NSString *const kBWInfoErrorStringKey		= @"ErrorDescription";

static NSString *const kBWLocalizedStringsTableName = @"BoardWarrior";

static NSString *const kBWTemplateSoraToolKey		= @"%%%SORA%%%";
static NSString *const kBWTemplateRosettaToolKey	= @"%%%ROSETTA%%%";
static NSString *const kBWTempmlateConvertToolKey	= @"%%%SJIS%%%";
static NSString *const kBWTemplateBBSMenuHTMLKey	= @"%%%HTML%%%";
static NSString *const kBWTemplateLogFolderPathKey	= @"%%%LOGFOLDER%%%";

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

#pragma mark Private Utilities
- (NSData *) encodedLocalizedStringForKey: (NSString *) key format: (NSString *) format
{
	NSString *str = [self localizedString: key];
	
	return [[NSString stringWithFormat: str, format] dataUsingEncoding: NSUTF8StringEncoding];
}

- (void) notifyCMRTaskDidFail
{
	[self setMessage: [self localizedString: kBWTaskMsgFailedKey]];
	UTILNotifyName(CMRTaskDidFinishNotification);
}

- (BOOL) replaceTemplateTags: (NSMutableString *) appleScript withHTMLPath: (NSString *) htmlPath
{
	NSBundle *bathyscaphe = [NSBundle mainBundle];
	NSString *soraToolPath_ = [bathyscaphe pathForResource: @"sora" ofType: @"pl"];
	NSString *rosettaToolPath_ = [bathyscaphe pathForResource: @"rosetta" ofType: @"pl"];
	NSString *convertToolPath_ = [bathyscaphe pathForResource: @"SJIS2UTF8" ofType: @""];
	NSString *logFolderPath_ = [[CMRFileManager defaultManager] dataRootDirectoryPath];
	
	if (!soraToolPath_ || !rosettaToolPath_ || !convertToolPath_ || !logFolderPath_) return NO;

	[appleScript replaceOccurrencesOfString: kBWTemplateSoraToolKey
								 withString: soraToolPath_
									options: NSLiteralSearch
									  range: NSMakeRange(0, [appleScript length])]; 

	[appleScript replaceOccurrencesOfString: kBWTemplateRosettaToolKey
								 withString: rosettaToolPath_
									options: NSLiteralSearch
									  range: NSMakeRange(0, [appleScript length])]; 

	[appleScript replaceOccurrencesOfString: kBWTemplateBBSMenuHTMLKey
								 withString: htmlPath
									options: NSLiteralSearch
									  range: NSMakeRange(0, [appleScript length])]; 

	[appleScript replaceOccurrencesOfString: kBWTempmlateConvertToolKey
								 withString: convertToolPath_
									options: NSLiteralSearch
									  range: NSMakeRange(0, [appleScript length])]; 

	[appleScript replaceOccurrencesOfString: kBWTemplateLogFolderPathKey
								 withString: logFolderPath_
									options: NSLiteralSearch
									  range: NSMakeRange(0, [appleScript length])];

	return YES;
}

- (NSURL *) fileURLWithResource: (NSString *) name ofType: (NSString *) extension
{
	NSBundle *bundle_ = [NSBundle mainBundle];
	NSString *path_ = [bundle_ pathForResource: name ofType: extension];
	if (!path_) return nil;
	
	return [NSURL fileURLWithPath: path_];
}

- (void) startPerlTaskWithBBSMenu: (NSString *) htmlPath
{
	UTILNotifyName(BoardWarriorWillStartCreateDefaultListTaskNotification);
	NSString *errMsg = [self startKaleidoStage: @"himeko" withHTMLPath: htmlPath];

	if (errMsg) {
		NSDictionary *info_ = [NSDictionary dictionaryWithObject: errMsg forKey: kBWInfoErrorStringKey];
		[self writeLogsToFileWithUTF8Data: [errMsg dataUsingEncoding: NSUTF8StringEncoding]];

		[self notifyCMRTaskDidFail];
		
		UTILNotifyInfo(BoardWarriorDidFailCreateDefaultListTaskNotification, info_);
		return;
	}
	
	UTILNotifyName(BoardWarriorWillStartSyncUserListTaskNotification);
	NSString *errMsg2 = [self startKaleidoStage: @"na-na" withHTMLPath: htmlPath];
	
	if (errMsg2) {
		NSDictionary *info_ = [NSDictionary dictionaryWithObject: errMsg2 forKey: kBWInfoErrorStringKey];
		[self writeLogsToFileWithUTF8Data: [errMsg2 dataUsingEncoding: NSUTF8StringEncoding]];

		[self notifyCMRTaskDidFail];

		UTILNotifyInfo(BoardWarriorDidFailSyncUserListTaskNotification, info_);
		return;
	}

	// delete bbsmenu.html
	[[NSFileManager defaultManager] removeFileAtPath: htmlPath handler: nil];

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
	BSIPIDownload	*newDownload_;
	NSString		*tmpDir_ = NSTemporaryDirectory();

	if([self isInProgress] || tmpDir_ == nil) {
		return NO;
	}

	newDownload_ = [[BSIPIDownload alloc] initWithURLIdentifier: anURL delegate: self destination: tmpDir_];
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

- (NSString *) startKaleidoStage: (NSString *) scriptName withHTMLPath: (NSString *) htmlPath
{
	NSDictionary *errInfo = nil;
	NSDictionary *errInfo2 = nil;
	NSAppleEventDescriptor *scriptResult;
	
	NSMutableString *hoge_;
	
	NSURL *url_ = [self fileURLWithResource: scriptName ofType: @"scpt"];
	if (!url_) {
		return [NSString stringWithFormat: [self localizedString: @"BW_fail_script1"], scriptName];
	}

	NSAppleScript *script_ = [[NSAppleScript alloc] initWithContentsOfURL: url_ error: &errInfo];

	if (errInfo) {
		return [errInfo objectForKey: NSAppleScriptErrorBriefMessage];
	}

	hoge_ = [[script_ source] mutableCopy];
	[script_ release];

	if (NO == [self replaceTemplateTags: hoge_ withHTMLPath: htmlPath]) {
		return [self localizedString: @"BW_fail_script2"]; 
	}

	NSAppleScript *newScript_ = [[NSAppleScript alloc] initWithSource: hoge_];
	scriptResult = [newScript_ executeAndReturnError: &errInfo2];
	
	if (nil != errInfo2) {
		return [errInfo2 objectForKey: NSAppleScriptErrorBriefMessage];
	}

	if ([scriptResult descriptorType]) {
        //NSLog(@"script %@.scpt executed successfully.", scriptName);
		[self writeLogsToFileWithUTF8Data: [self encodedLocalizedStringForKey: @"BW_run %@" format: scriptName]];
        /*if (kAENullEvent!=[scriptResult descriptorType]) {
			NSLog(@"%@",[scriptResult stringValue]);
        } else {
            NSLog(@"AppleScript has no result.");
        }*/
    }

	[hoge_ release];
	[newScript_ release];
	return nil;
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
- (void) bsIPIdownload: (BSIPIDownload *) aDownload willDownloadContentOfSize: (double) expectedLength
{
	NSDictionary *info_ = [NSDictionary dictionaryWithObject: [NSNumber numberWithDouble: expectedLength] forKey: kBWInfoExpectedLengthKey];
	m_expectedContentLength = expectedLength;

	[self writeLogsToFileWithUTF8Data: [self encodedLocalizedStringForKey: @"BW_download from %@"
																   format: [[aDownload URLIdentifier] absoluteString]]];	
	UTILNotifyInfo(BoardWarriorWillStartDownloadNotification, info_);
}

- (void) bsIPIdownload: (BSIPIDownload *) aDownload didDownloadContentOfSize: (double) downloadedLength
{
	m_downloadedContentLength = downloadedLength;
}

- (void) bsIPIdownloadDidFinish: (BSIPIDownload *) aDownload
{
	NSString *downloadedFilePath_ = [aDownload downloadedFilePath];
	[self writeLogsToFileWithUTF8Data: [[self localizedString: @"BW_download finish"] dataUsingEncoding: NSUTF8StringEncoding]];
	UTILNotifyName(BoardWarriorDidFinishDownloadNotification);

	[aDownload release];
	m_currentDownload = nil;

	[self startPerlTaskWithBBSMenu: downloadedFilePath_];
}

- (void) bsIPIdownload: (BSIPIDownload *) aDownload didFailWithError: (NSError *) aError
{
	//NSLog(@"%@",[aError description]);
	[self writeLogsToFileWithUTF8Data: [self encodedLocalizedStringForKey: @"BW_download fail %@" format: [aError description]]];

	[aDownload release];
	m_currentDownload = nil;
	m_isInProgress = NO;

	[self notifyCMRTaskDidFail];

	NSDictionary *info_ = [NSDictionary dictionaryWithObject: @"Some error occurred while downloading BBSMenu." forKey: kBWInfoErrorStringKey];
	UTILNotifyInfo(BoardWarriorDidFailDownloadNotification, info_);
}
@end
