//
//  $Id: BSIPIHistoryManager.m,v 1.4.2.5 2006/11/27 16:16:15 tsawada2 Exp $
//  BathyScaphe
//
//  Created by Tsutomu Sawada on 06/01/12.
//  Copyright 2006 BathyScaphe Project. All rights reserved.
//

#import "BSIPIHistoryManager.h"
#import "BSIPIToken.h"
#import <CocoMonar/CMRSingletonObject.h>

@implementation BSIPIHistoryManager
APP_SINGLETON_FACTORY_METHOD_IMPLEMENTATION(sharedManager)	

- (void) dealloc
{
	[_historyBacket release];
	[_dlFolderPath release];
	[super dealloc];
}

- (NSMutableArray *) historyBacket
{
	if (_historyBacket == nil) {
		_historyBacket = [[NSMutableArray alloc] init];
	}
	return _historyBacket;
}

- (void) setHistoryBacket : (NSMutableArray *) aMutableArray
{
	[aMutableArray retain];
	[_historyBacket release];
	_historyBacket = aMutableArray;
}

- (NSString *) createDlFolder
{
	NSFileManager	*fm = [NSFileManager defaultManager];
	NSString		*tmpDir = NSTemporaryDirectory();
	NSString		*appName = [[NSBundle mainBundle] bundleIdentifier];
	NSString		*path_;

	BOOL created = NO;	
	do {
		NSString	*folderName = [NSString stringWithFormat: @"%@.%d", appName, [[NSDate date] timeIntervalSince1970]];
		path_ = [tmpDir stringByAppendingPathComponent: folderName];
		
		if (![fm fileExistsAtPath: path_] && [fm createDirectoryAtPath: path_ attributes: nil]) {
			created = YES;
		}
	} while(!created);
	
	return path_;
}

- (NSString *) dlFolderPath
{
	if (_dlFolderPath == nil) {
		_dlFolderPath = [[self createDlFolder] retain];
	}
	return _dlFolderPath;
}

- (void) flushCache
{
	[self setHistoryBacket: [NSMutableArray array]];
	
	[[NSFileManager defaultManager] removeFileAtPath: [self dlFolderPath] handler: nil];
	[_dlFolderPath release];
	_dlFolderPath = nil;
}

- (NSArray *) arrayOfURLs
{
	NSMutableArray *tmp = [self historyBacket];
	return ([tmp count] > 0) ? [tmp valueForKey: @"sourceURL"] : nil;
}

- (NSArray *) arrayOfPaths
{
	NSMutableArray *tmp = [self historyBacket];
	return ([tmp count] > 0) ? [tmp valueForKey : @"downloadedFilePath"] : nil;
}

#pragma mark Token Accessors
- (BSIPIToken *) searchCachedTokenBy: (NSArray *) array forKey: (id) key
{
	if (!array || !key) return nil;

	unsigned idx = [array indexOfObject: key];
	if (idx == NSNotFound) return nil;
	
	return [[self historyBacket] objectAtIndex: idx];
}

- (BOOL) isTokenCachedForURL: (NSURL *) anURL
{
	return ([self cachedTokenForURL: anURL] != nil);
}

- (BSIPIToken *) cachedTokenForURL: (NSURL *) anURL
{
	return [self searchCachedTokenBy: [self arrayOfURLs] forKey: anURL];
}

- (BSIPIToken *) cachedTokenAtIndex: (unsigned) index
{
	if (index == NSNotFound) return nil;
	return [[self historyBacket] objectAtIndex: index];
}

- (unsigned) cachedTokenIndexForURL: (NSURL *) anURL
{
	if (nil == [self arrayOfURLs]) {
		return NSNotFound;
	}
	return [[self arrayOfURLs] indexOfObject: anURL];
}

- (NSArray *) cachedTokensArrayAtIndexes: (NSIndexSet *) indexes
{
	if (indexes == nil) return nil;
	
	NSMutableArray *array = [NSMutableArray array];

	unsigned int	index;
	unsigned int	size = [indexes lastIndex]+1;
	NSRange			e = NSMakeRange(0, size);

	while ([indexes getIndexes: &index maxCount: 1 inIndexRange: &e] > 0)
	{
		[array addObject: [[self historyBacket] objectAtIndex: index]];
	}

	return array;
}

- (BOOL) cachedTokensArrayContainsNotNullObjectAtIndexes: (NSIndexSet *) indexes
{
	NSArray *tokenArray = [self cachedTokensArrayAtIndexes: indexes];
	
	if (tokenArray == nil) return NO;
	
	NSArray	*pathArray = [tokenArray valueForKey: @"downloadedFilePath"];
	NSEnumerator *iter_ = [pathArray objectEnumerator];
	NSString	*eachPath;
	
	while (eachPath = [iter_ nextObject]) {
		if (NO == [eachPath isEqual: [NSNull null]]) return YES;
	}
	
	return NO;
}

- (BOOL) cachedTokensArrayContainsDownloadingTokenAtIndexes: (NSIndexSet *) indexes
{
	NSArray *tokenArray = [self cachedTokensArrayAtIndexes: indexes];
	
	if (tokenArray == nil) return NO;
	
	NSArray	*boolArray = [tokenArray valueForKey: @"isDownloading"];
	NSEnumerator *iter_ = [boolArray objectEnumerator];
	NSNumber	*eachStatus;
	
	while (eachStatus = [iter_ nextObject]) {
		if ([eachStatus boolValue]) return YES;
	}
	
	return NO;
}



#pragma mark URL Operations
- (void) openURLForTokenAtIndexes: (NSIndexSet *) indexes inBackground: (BOOL) inBg
{
	NSArray	*tokenArray = [self cachedTokensArrayAtIndexes: indexes];
	
	if (tokenArray != nil) {
		NSArray						*urlArray = [tokenArray valueForKey: @"sourceURL"];

		NSWorkspaceLaunchOptions	options = NSWorkspaceLaunchDefault;
		if (inBg) options |= NSWorkspaceLaunchWithoutActivation;

		[[NSWorkspace sharedWorkspace] openURLs: urlArray
						withAppBundleIdentifier: @"com.apple.Safari"
										options: options
				 additionalEventParamDescriptor: nil
							  launchIdentifiers: nil];
	}
}

- (void) makeTokensCancelDownloadAtIndexes: (NSIndexSet *) indexes
{
	NSArray	*tokenArray = [self cachedTokensArrayAtIndexes: indexes];
	
	if (tokenArray != nil) {
		[tokenArray makeObjectsPerformSelector: @selector(cancelDownload)];
	}
}

#pragma mark File Operations
- (NSArray *) convertFilePathArrayToURLArray: (NSArray *) pathArray
{
	NSMutableArray	*urlArray = [NSMutableArray array];
	NSEnumerator *iter_ = [pathArray objectEnumerator];
	NSString	*eachPath;
	
	while (eachPath = [iter_ nextObject]) {
		if ([eachPath isEqual: [NSNull null]]) continue;
		
		NSURL *url_ = (NSURL *)CFURLCreateWithFileSystemPath(kCFAllocatorDefault, (CFStringRef)eachPath, kCFURLPOSIXPathStyle, false);
		[urlArray addObject: url_];
		
		CFRelease((CFURLRef)url_);
	}
	
	return urlArray;
}

- (void) openCachedFileForTokenAtIndexesWithPreviewApp: (NSIndexSet *) indexes
{
	NSArray	*tokenArray = [self cachedTokensArrayAtIndexes: indexes];
	
	if (tokenArray != nil) {
		NSArray *pathArray_ = [tokenArray valueForKey: @"downloadedFilePath"];
		NSArray *fileURLArray_ = [self convertFilePathArrayToURLArray: pathArray_];

		if ([fileURLArray_ count] > 0) {
			[[NSWorkspace sharedWorkspace] openURLs: fileURLArray_
							withAppBundleIdentifier: @"com.apple.Preview"
											options: NSWorkspaceLaunchDefault
					 additionalEventParamDescriptor: nil
								  launchIdentifiers: nil];
		}
	}
}

- (void) copyCachedFileForTokenAtIndexes: (NSIndexSet *) indexes intoFolder: (NSString *) folderPath
{
	NSArray	*tokenArray = [self cachedTokensArrayAtIndexes: indexes];
	
	if (tokenArray != nil) {
		NSArray *pathArray = [tokenArray valueForKey: @"downloadedFilePath"];
		NSEnumerator *iter_ = [pathArray objectEnumerator];
		NSString	*eachPath;
		
		while (eachPath = [iter_ nextObject]) {
			if ([eachPath isEqual: [NSNull null]]) continue;
			[self copyCachedFileForPath: eachPath toPath: [folderPath stringByAppendingPathComponent: [eachPath lastPathComponent]]];
		}
	}
}

- (BOOL) copyCachedFileForPath: (NSString *) cacheFilePath toPath: (NSString *) copiedFilePath
{
	NSFileManager	*fm_ = [NSFileManager defaultManager];

	if (NO == [fm_ copyPath: cacheFilePath toPath: copiedFilePath handler: nil]) {
		NSBeep();
		NSLog(@"Could not save file: %@", [cacheFilePath lastPathComponent]);
		return NO;
	}
	return YES;
}

- (void) saveCachedFileForTokenAtIndex: (unsigned) index savePanelAttachToWindow: (NSWindow *) aWindow
{
	BSIPIToken	*aToken = [self cachedTokenAtIndex: index];
	if (aToken == nil) return;
	NSString	*filePath_ = [aToken downloadedFilePath];
	if (filePath_ == nil) return;

	NSString	*extension_ = [filePath_ pathExtension];

	NSSavePanel *sP = [NSSavePanel savePanel];
	[sP setRequiredFileType: ([extension_ isEqualToString: @""] ? nil : extension_)];
	[sP setAllowsOtherFileTypes: YES];
	[sP setCanCreateDirectories: YES];
	[sP setCanSelectHiddenExtension: YES];

	[sP beginSheetForDirectory : nil
						  file : [filePath_ lastPathComponent]
				modalForWindow : aWindow
				 modalDelegate : self
				didEndSelector : @selector(savePanelDidEnd:returnCode:contextInfo:)
				   contextInfo : filePath_];
}

- (void) savePanelDidEnd: (NSSavePanel *) sheet returnCode: (int) returnCode contextInfo: (void *) contextInfo
{
	if (returnCode == NSOKButton) {
		NSString *savePath = [sheet filename];
		if ([self copyCachedFileForPath: (NSString *)contextInfo toPath: savePath]) {
			NSDictionary *tmpDict;
			tmpDict = [NSDictionary dictionaryWithObject: [NSNumber numberWithBool: [sheet isExtensionHidden]]
												  forKey: NSFileExtensionHidden];

			[[NSFileManager defaultManager] changeFileAttributes: tmpDict atPath: savePath];
		}
	}
}

#pragma mark Add / Remove Token
- (void) addTokenForURL: (NSURL *) anURL
{
	if (anURL == nil) return;
	BSIPIToken	*token = [[BSIPIToken alloc] initWithURL: anURL destination: [self dlFolderPath]];
	[[self historyBacket] addObject: token];
	[token release];
}

- (void) addToken: (BSIPIToken *) aToken
{
	[[self historyBacket] addObject: aToken];
}

- (void) removeToken: (BSIPIToken *) aToken
{
	NSString *filePath = [aToken downloadedFilePath];
	if (filePath != nil) {
		[[NSFileManager defaultManager] removeFileAtPath: filePath handler: nil];
	}
	[[self historyBacket] removeObject: aToken];
}

- (void) removeTokenAtIndexes: (NSIndexSet *) indexes
{
	NSArray	*tokenArray = [self cachedTokensArrayAtIndexes: indexes];
	
	if (tokenArray != nil) {
		NSArray *pathArray = [tokenArray valueForKey: @"downloadedFilePath"];
		NSEnumerator *iter_ = [pathArray objectEnumerator];
		NSString	*eachPath;
		
		while (eachPath = [iter_ nextObject]) {
			if ([eachPath isEqual: [NSNull null]]) continue;
			[[NSFileManager defaultManager] removeFileAtPath: eachPath handler: nil];
		}
	}

	unsigned int bufferSize;
	unsigned int *buffer;
	unsigned int count;

	bufferSize = [indexes count];
	buffer = malloc(sizeof(unsigned int) * bufferSize);

	if (buffer == NULL) return;

	count = [indexes getIndexes: buffer maxCount: bufferSize inIndexRange: nil];

	[[self historyBacket] removeObjectsFromIndices: buffer numIndices: count];

	free(buffer);
}

#pragma mark NSTableDataSource
- (BOOL) appendDataForTokenAtIndexes: (NSIndexSet *) indexes
						toPasteboard: (NSPasteboard *) pboard
			 withFilenamesPboardType: (BOOL) filenamesType
{
	NSLog(@"Sorry...");
	return NO;
}
/*
- (BOOL) appendDataForURL: (NSURL *) source toPasteboard: (NSPasteboard *) pboard withFilenamesPboardType: (BOOL) filenamesType
{
	if (!source) return NO;
	
	NSString *fPath_ = [self cachedFilePathForURL: source];
	if(!fPath_ && filenamesType) return NO;
	
	if (filenamesType) {
		[pboard declareTypes: [NSArray arrayWithObjects: NSFilenamesPboardType, NSURLPboardType, nil] owner: nil];
		[pboard setPropertyList: [NSArray arrayWithObject: fPath_] forType: NSFilenamesPboardType];
	} else {
		[pboard declareTypes: [NSArray arrayWithObjects: NSURLPboardType, NSStringPboardType, nil] owner: nil];
		[pboard setString: [source absoluteString] forType: NSStringPboardType];
	}
	
	[source writeToPasteboard: pboard];
	return YES;
}

- (BOOL) tableView: (NSTableView *) aTableView writeRowsWithIndexes: (NSIndexSet *) rowIndexes toPasteboard: (NSPasteboard*) pboard
{
	// とりあえず一つだけ
	unsigned int rowIndex = [rowIndexes firstIndex];
	NSURL		*fileURL_ = [[self arrayOfURLs] objectAtIndex: rowIndex];

	return [self appendDataForURL: fileURL_ toPasteboard: pboard withFilenamesPboardType: YES];
}
*/
@end
