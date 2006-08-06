//
//  BoardWarrior.m
//  BathyScaphe
//
//  Created by Tsutomu Sawada on 06/08/06.
//  Copyright 2006 BathyScaphe Project. All rights reserved.
//

#import "BoardWarrior.h"
#import "CocoMonar_Prefix.h"
#import "BSIPIDownload.h"
#import "AppDefaults.h"

NSString *const BoardWarriorWillStartDownloadNotification =	@"BoardWarriorWillStartDownloadNotification";
NSString *const BoardWarriorDidFinishDownloadNotification =	@"BoardWarriorDidFinishDownloadNotification";
NSString *const BoardWarriorDidFailDownloadNotification = @"BoardWarriorDidFailDownloadNotification";

NSString *const BoardWarriorWillStartCreateDefaultListTaskNotification = @"BoardWarriorWillStartCreateDefaultListTaskNotification";
NSString *const BoardWarriorDidFailCreateDefaultListTaskNotification = @"BoardWarriorDidFailCreateDefaultListTaskNotification";

NSString *const BoardWarriorWillStartSyncUserListTaskNotification = @"BoardWarriorWillStartSyncUserListTaskNotification";
NSString *const BoardWarriorDidFailSyncUserListTaskNotification = @"BoardWarriorDidFailSyncUserListTaskNotification";

NSString *const BoardWarriorDidFinishAllTaskNotification =	@"BoardWarriorDidFinishAllTaskNotification";

NSString *const kBWInfoExpectedLengthKey = @"ExpectedContentLength";
NSString *const kBWInfoErrorStringKey = @"ErrorDescription";

static NSString *const kBWTemplateSoraToolKey = @"%%%SORA%%%";
static NSString *const kBWTemplateRosettaToolKey = @"%%%ROSETTA%%%";
static NSString *const kBWTempmlateConvertToolKey = @"%%%SJIS%%%";
static NSString *const kBWTemplateBBSMenuHTMLKey = @"%%%HTML%%%";
static NSString *const kBWTemplateLogFolderPathKey = @"%%%LOGFOLDER%%%";

@implementation BoardWarrior
APP_SINGLETON_FACTORY_METHOD_IMPLEMENTATION(warrior);

#pragma mark Accessors
- (BOOL) isInProgress
{
	return m_isInProgress;
}

- (double) expectedContentLength
{
	return m_expectedContentLength;
}

- (double) downloadedContentLength
{
	return m_downloadedContentLength;
}

#pragma mark -
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
		m_isInProgress = YES;
	} else {
		return NO;
	}
	
	return YES;
}

- (void) startPerlTaskWithBBSMenu: (NSString *) htmlPath
{
	UTILNotifyName(BoardWarriorWillStartCreateDefaultListTaskNotification);
	NSString *errMsg = [self startKaleidoStage: @"himeko" withHTMLPath: htmlPath];

	if (errMsg) {
		NSDictionary *info_ = [NSDictionary dictionaryWithObject: errMsg forKey: kBWInfoErrorStringKey];
		UTILNotifyInfo(BoardWarriorDidFailCreateDefaultListTaskNotification, info_);
		return;
	}
	
	UTILNotifyName(BoardWarriorWillStartSyncUserListTaskNotification);
	NSString *errMsg2 = [self startKaleidoStage: @"na-na" withHTMLPath: htmlPath];
	
	if (errMsg2) {
		NSDictionary *info_ = [NSDictionary dictionaryWithObject: errMsg2 forKey: kBWInfoErrorStringKey];
		UTILNotifyInfo(BoardWarriorDidFailSyncUserListTaskNotification, info_);
		return;
	}

	// delete bbsmenu.html
	[[NSFileManager defaultManager] removeFileAtPath: htmlPath handler: nil];

	[CMRPref setLastSyncDate: [NSDate date]];
	m_isInProgress = NO;

	UTILNotifyName(BoardWarriorDidFinishAllTaskNotification);	
}

#pragma mark BSIPIDownload Delegate
- (void) bsIPIdownload: (BSIPIDownload *) aDownload willDownloadContentOfSize: (double) expectedLength
{
	NSDictionary *info_ = [NSDictionary dictionaryWithObject: [NSNumber numberWithDouble: expectedLength] forKey: kBWInfoExpectedLengthKey];
	m_expectedContentLength = expectedLength;
	UTILNotifyInfo(BoardWarriorWillStartDownloadNotification, info_);
}

- (void) bsIPIdownload: (BSIPIDownload *) aDownload didDownloadContentOfSize: (double) downloadedLength
{
	m_downloadedContentLength = downloadedLength;
}

- (void) bsIPIdownloadDidFinish: (BSIPIDownload *) aDownload
{
	NSString *downloadedFilePath_ = [aDownload downloadedFilePath];
	UTILNotifyName(BoardWarriorDidFinishDownloadNotification);

	[aDownload release];

	[self startPerlTaskWithBBSMenu: downloadedFilePath_];
}

- (void) bsIPIdownload: (BSIPIDownload *) aDownload didFailWithError: (NSError *) aError
{
	NSLog(@"%@",[aError description]);

	[aDownload release];
	m_isInProgress = NO;

	NSDictionary *info_ = [NSDictionary dictionaryWithObject: @"Some error occurred when downloading BBSMenu." forKey: kBWInfoErrorStringKey];
	UTILNotifyInfo(BoardWarriorDidFailDownloadNotification, info_);
}

#pragma mark -
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

- (NSString *) startKaleidoStage: (NSString *) scriptName withHTMLPath: (NSString *) htmlPath
{
	NSDictionary *errInfo = nil;
	NSDictionary *errInfo2 = nil;
	NSAppleEventDescriptor *scriptResult;
	
	NSMutableString *hoge_;
	
	NSURL *url_ = [self fileURLWithResource: scriptName ofType: @"scpt"];
	if (!url_) {
		return [NSString stringWithFormat: @"Script file %@.scpt not found.", scriptName];
	}

	NSAppleScript *script_ = [[NSAppleScript alloc] initWithContentsOfURL: url_ error: &errInfo];

	if (errInfo) {
		return [errInfo objectForKey: NSAppleScriptErrorBriefMessage];
	}

	hoge_ = [[script_ source] mutableCopy];
	[script_ release];

	if (NO == [self replaceTemplateTags: hoge_ withHTMLPath: htmlPath]) {
		return @"Can't replace template tags."; 
	}

	NSAppleScript *newScript_ = [[NSAppleScript alloc] initWithSource: hoge_];
	scriptResult = [newScript_ executeAndReturnError: &errInfo2];
	
	if (nil != errInfo2) {
		return [errInfo2 objectForKey: NSAppleScriptErrorBriefMessage];
	}

	if ([scriptResult descriptorType]) {
        NSLog(@"script %@.scpt executed sucessfully.", scriptName);
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
@end
