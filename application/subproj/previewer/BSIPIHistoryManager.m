//
//  $Id: BSIPIHistoryManager.m,v 1.10 2008/03/07 15:13:43 tsawada2 Exp $
//  BathyScaphe
//
//  Created by Tsutomu Sawada on 06/01/12.
//  Copyright 2006 BathyScaphe Project. All rights reserved.
//

#import "BSIPIHistoryManager.h"
#import "BSIPIToken.h"
#import <SGAppKit/NSWorkspace-SGExtensions.h>
#import <CocoMonar/CMRSingletonObject.h>

@implementation BSIPIHistoryManager
APP_SINGLETON_FACTORY_METHOD_IMPLEMENTATION(sharedManager)	

- (void) dealloc
{
	[_historyBacket release];
	[_dlFolderPath release];
	[super dealloc];
}

#pragma mark Key-Value Observing
- (unsigned int)countOfTokensArray
{
	return [[self tokensArray] count];
}

- (id)objectInTokensArrayAtIndex:(unsigned int)index
{
	return [[self tokensArray] objectAtIndex:index];
}

- (void)insertObject:(id)anObject inTokensArrayAtIndex:(unsigned int)index
{
	[[self tokensArray] insertObject:anObject atIndex:index];
}

- (void)removeObjectFromTokensArrayAtIndex:(unsigned int)index
{
	NSMutableArray	*tokens = [self tokensArray];
	BSIPIToken *aToken = [tokens objectAtIndex:index];

	if ([aToken isDownloading]) {
		[aToken cancelDownload];
	}

	NSString *filePath = [aToken downloadedFilePath];
	if (filePath) {
		[[NSFileManager defaultManager] removeFileAtPath:filePath handler:nil];
	}

	[tokens removeObjectAtIndex:index];
}

- (void)replaceObjectInTokensArrayAtIndex:(unsigned int)index withObject:(id)anObject
{
	[[self tokensArray] replaceObjectAtIndex:index withObject:anObject];
}

- (NSMutableArray *)tokensArray
{
	if (_historyBacket == nil) {
		_historyBacket = [[NSMutableArray alloc] init];
	}
	return _historyBacket;
}

- (void)setTokensArray:(NSMutableArray *)newArray
{
	[newArray retain];
	[_historyBacket release];
	_historyBacket = newArray;
}

#pragma mark Utilities
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

- (void)flushCache
{
	[self setTokensArray:[NSMutableArray array]];
	
	[[NSFileManager defaultManager] removeFileAtPath:[self dlFolderPath] handler:nil];
	[_dlFolderPath release];
	_dlFolderPath = nil;
}

- (NSArray *) arrayOfURLs
{
	NSMutableArray *tmp = [self tokensArray];
	return ([tmp count] > 0) ? [tmp valueForKey: @"sourceURL"] : nil;
}

- (NSArray *) arrayOfPaths
{
	NSMutableArray *tmp = [self tokensArray];
	return ([tmp count] > 0) ? [tmp valueForKey : @"downloadedFilePath"] : nil;
}

#pragma mark Token Accessors
- (BSIPIToken *) searchCachedTokenBy: (NSArray *) array forKey: (id) key
{
	if (!array || !key) return nil;

	unsigned idx = [array indexOfObject: key];
	if (idx == NSNotFound) return nil;
	
	return [[self tokensArray] objectAtIndex: idx];
}

- (BOOL) isTokenCachedForURL: (NSURL *) anURL
{
	return ([self cachedTokenForURL: anURL] != nil);
}

- (BSIPIToken *) cachedTokenForURL: (NSURL *) anURL
{
	return [self searchCachedTokenBy: [self arrayOfURLs] forKey: anURL];
}
/*
- (BSIPIToken *) cachedTokenAtIndex: (unsigned) index
{
	if (index == NSNotFound) return nil;
	return [[self tokensArray] objectAtIndex: index];
}
*/
- (unsigned) cachedTokenIndexForURL: (NSURL *) anURL
{
	if (nil == [self arrayOfURLs]) {
		return NSNotFound;
	}
	return [[self arrayOfURLs] indexOfObject: anURL];
}

- (NSArray *) cachedTokensArrayAtIndexes: (NSIndexSet *) indexes
{
/*	if (indexes == nil) return nil;
	
	NSMutableArray *array = [NSMutableArray array];

	unsigned int	index;
	unsigned int	size = [indexes lastIndex]+1;
	NSRange			e = NSMakeRange(0, size);

	while ([indexes getIndexes: &index maxCount: 1 inIndexRange: &e] > 0)
	{
		[array addObject: [[self tokensArray] objectAtIndex: index]];
	}

	return array;*/
	if (!indexes) return nil;
	return [[self tokensArray] objectsAtIndexes:indexes];
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

- (BOOL)cachedTokensArrayContainsFailedTokenAtIndexes:(NSIndexSet *)indexes
{
	NSArray *tokenArray = [self cachedTokensArrayAtIndexes:indexes];
	if (!tokenArray) return NO;

	NSEnumerator	*iter_ = [tokenArray objectEnumerator];
	BSIPIToken		*eachToken;

	while (eachToken = [iter_ nextObject]) {
		if (![eachToken isDownloading] && ![eachToken isFileExists]) return YES;
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
						withAppBundleIdentifier: [[NSWorkspace sharedWorkspace] bundleIdentifierForDefaultWebBrowser]
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

- (void)makeTokensRetryDownloadAtIndexes:(NSIndexSet *)indexes
{
	NSArray *tokenArray = [self cachedTokensArrayAtIndexes:indexes];

	if (tokenArray) {
		[tokenArray makeObjectsPerformSelector:@selector(retryDownload:) withObject:[self dlFolderPath]];
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
	if (index == NSNotFound) return;
//	BSIPIToken	*aToken = [self cachedTokenAtIndex: index];
//	if (aToken == nil) return;
	BSIPIToken	*aToken = [self objectInTokensArrayAtIndex:index];
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

#pragma mark NSTableDataSource
- (NSArray *)arrayForDeclaringTypes
{
	static NSArray *array_ = nil;
	if (!array_) {
		array_ = [[NSArray alloc] initWithObjects:NSURLPboardType, NSStringPboardType, nil];
	}

	return array_;
}

- (NSArray *)arrayForAddingTypes
{
	static NSArray	*additionalArray_ = nil;
	if (!additionalArray_) {
		additionalArray_ = [[NSArray alloc] initWithObjects:NSFilenamesPboardType, nil];
	}

	return additionalArray_;
}

- (BOOL) appendDataForTokenAtIndexes: (NSIndexSet *) indexes
						toPasteboard: (NSPasteboard *) pboard
			 withFilenamesPboardType: (BOOL) filenamesType
{
	NSArray		*tokens_ = [self cachedTokensArrayAtIndexes: indexes];
	NSArray		*urlArray_ = [tokens_ valueForKey: @"sourceURL"];
	NSString	*joinedURLString_ = [[urlArray_ valueForKey: @"absoluteString"] componentsJoinedByString: @"\n"];
	
//	NSURL		*url_ = [[self cachedTokenAtIndex: [indexes firstIndex]] sourceURL];
	NSURL		*url_ = [[self objectInTokensArrayAtIndex:[indexes firstIndex]] sourceURL];

	[pboard declareTypes: [self arrayForDeclaringTypes] owner: nil];

	if (filenamesType) {
		NSMutableArray *pathAry_ = [[tokens_ valueForKey: @"downloadedFilePath"] mutableCopy];
		[pathAry_ removeObjectIdenticalTo: [NSNull null]];
		if ([pathAry_ count] > 0) {
			[pboard addTypes: [self arrayForAddingTypes] owner: nil];
			[pboard setPropertyList: pathAry_ forType: NSFilenamesPboardType];
		}
		[pathAry_ release];
	}
	[pboard setString: joinedURLString_ forType: NSStringPboardType];
	[url_ writeToPasteboard: pboard];
	return YES;
}

- (BOOL) tableView: (NSTableView *) aTableView writeRowsWithIndexes: (NSIndexSet *) rowIndexes toPasteboard: (NSPasteboard*) pboard
{
	return [self appendDataForTokenAtIndexes: rowIndexes toPasteboard: pboard withFilenamesPboardType: YES];
}
@end
