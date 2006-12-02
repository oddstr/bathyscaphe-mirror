//
// BSSettingTxtDetector.m
// BathyScaphe
//
// Written by Tsutomu Sawada on 06/08/15.
// Copyright 2006 BathyScaphe Project. All rights reserved.
//

#import "BSSettingTxtDetector.h"
#import "UTILKit.h"
#import <SGNetwork/BSIPIDownload.h>
#import <CocoMonar/CMRAppTypes.h>


NSString *const BSSettingTxtDetectorDidFinishNotification = @"BSSTDDidFinishNotification";
NSString *const BSSettingTxtDetectorDidFailNotification = @"BSSTDDidFailNotification";

NSString *const kBSSTDBoardNameKey = @"boardName";
NSString *const kBSSTDNoNameValueKey = @"defaultNoName";
NSString *const kBSSTDBeLoginPolicyTypeValueKey = @"beLoginPolicyType";
NSString *const kBSSTDAllowsNanashiBoolValueKey = @"allowsNanashi";

@implementation BSSettingTxtDetector
- (id) initWithBoardName: (NSString *) boardName settingTxtURL: (NSURL *) anURL
{
    if (self = [super init]) {
        [self setBoardName: boardName];
        [self setSettingTxtURL: anURL];
    }

    return self;
}

- (void) dealloc
{
    [bsSTD_boardName release];
    [bsSTD_settingTxtURL release];
    [super dealloc];
}

- (NSString *) boardName
{
    return bsSTD_boardName;
}

- (void) setBoardName: (NSString *) newBoardName
{
    [newBoardName retain];
    [bsSTD_boardName release];
    bsSTD_boardName = newBoardName;
}

- (NSURL *) settingTxtURL
{
    return bsSTD_settingTxtURL;
}

- (void) setSettingTxtURL: (NSURL *) newURL
{
    [newURL retain];
    [bsSTD_settingTxtURL release];
    bsSTD_settingTxtURL = newURL;
}

- (void) startDownloadingSettingTxt
{
	BSIPIDownload	*newDownload_;
	NSString		*tmpDir_ = NSTemporaryDirectory();

	if(tmpDir_ == nil) {
		goto Err_Failed;
	}

	NSString        *suffix_ = [NSString stringWithFormat: @"BSSTD%d", [[NSDate date] timeIntervalSince1970]];
    tmpDir_ = [tmpDir_ stringByAppendingPathComponent: suffix_];

	if (NO == [[NSFileManager defaultManager] createDirectoryAtPath: tmpDir_ attributes: nil]) {
		goto Err_Failed;
	}

	newDownload_ = [[BSIPIDownload alloc] initWithURLIdentifier: [self settingTxtURL]
	                                                   delegate: self
	                                                destination: tmpDir_];
	if (!newDownload_) {
		goto Err_Failed;
	}
	
	return;

Err_Failed:
    UTILNotifyName(BSSettingTxtDetectorDidFailNotification);
}

- (void) detectNoNameAndBePolicyFromSettingTxtFile: (NSString *) filePath
{
    NSString *settingTxt;

    if (floor(NSFoundationVersionNumber) > NSFoundationVersionNumber10_3) {
        NSError	*error = nil;
        // This method is available in Mac OS X 10.4 and later.
        settingTxt = [NSString stringWithContentsOfFile: filePath
                                               encoding: NSShiftJISStringEncoding
                                                  error: &error];
	} else {
		NSData *settingTxtData = [NSData dataWithContentsOfFile: filePath];
        // This method is available in Mac OS X 10.0 and later.	
        settingTxt = [[[NSString alloc] initWithData: settingTxtData
                                            encoding: NSShiftJISStringEncoding] autorelease];
    }

    if (!settingTxt) {
        //NSLog(@"%@", [error description]);
        UTILNotifyName(BSSettingTxtDetectorDidFailNotification);
        return;
    }

	NSArray	*array_ = [settingTxt componentsSeparatedByString: @"\n"];
	NSEnumerator *iter_ = [array_ objectEnumerator];
	id	eachItem;
	NSString   *noNameValue = @"";
	BSBeLoginPolicyType    typeValue = BSBeLoginDecidedByUser;
	BOOL	nanashiOK = YES;
	
	while ((eachItem = [iter_ nextObject]) != nil) {
		NSArray *ary2;
		ary2 = [eachItem componentsSeparatedByString: @"="];
		if ([ary2 count] != 2) continue;
		
		if ([ary2 containsObject: @"BBS_NONAME_NAME"]) {
			noNameValue = [ary2 objectAtIndex: 1];
		} else if ([ary2 containsObject: @"BBS_BE_ID"]) {
            if (NO == [[ary2 objectAtIndex: 1] isEqualToString: @""]) {
				typeValue = BSBeLoginTriviallyNeeded;
            }
		} else if ([ary2 containsObject: @"NANASHI_CHECK"]) {
			if (NO == [[ary2 objectAtIndex: 1] isEqualToString: @""]) {
				nanashiOK = NO;
			}
			break;
		}
	}
	
	NSDictionary *returnDict;
	returnDict = [NSDictionary dictionaryWithObjectsAndKeys:
                    noNameValue, kBSSTDNoNameValueKey,
	               [NSNumber numberWithUnsignedInt: typeValue], kBSSTDBeLoginPolicyTypeValueKey,
				   [NSNumber numberWithBool: nanashiOK], kBSSTDAllowsNanashiBoolValueKey,
	               [self boardName], kBSSTDBoardNameKey,
	               NULL];

	// Delete downloaded SETTING.TXT (and its parent directory)
	[[NSFileManager defaultManager] removeFileAtPath: [filePath stringByDeletingLastPathComponent] handler: nil];

    UTILNotifyInfo(BSSettingTxtDetectorDidFinishNotification, returnDict);
}

#pragma mark BSIPIDownload delegate
- (void) bsIPIdownload: (BSIPIDownload *) aDownload willDownloadContentOfSize: (double) expectedLength
{
	;
}

- (void) bsIPIdownload: (BSIPIDownload *) aDownload didDownloadContentOfSize: (double) downloadedLength
{
	;
}

- (void) bsIPIdownloadDidFinish: (BSIPIDownload *) aDownload
{
	NSString *downloadedFilePath_;

	downloadedFilePath_ = [aDownload downloadedFilePath];

	[aDownload release];

	[self detectNoNameAndBePolicyFromSettingTxtFile: downloadedFilePath_];
}

- (BOOL) bsIPIdownload: (BSIPIDownload *) aDownload didRedirectToURL: (NSURL *) newURL
{
	return NO;
}

- (void) bsIPIdownload: (BSIPIDownload *) aDownload didAbortRedirectionToURL: (NSURL *) anURL
{
	NSLog(@"BSSTD - Redirection Aborted");
	[aDownload release];
	UTILNotifyName(BSSettingTxtDetectorDidFailNotification);
}

- (void) bsIPIdownload: (BSIPIDownload *) aDownload didFailWithError: (NSError *) aError
{
	NSLog(@"BSSTD - Download Error");
	[aDownload release];
	UTILNotifyName(BSSettingTxtDetectorDidFailNotification);
}
@end