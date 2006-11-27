//
//  BSIPIHistoryManager.h
//  BathyScaphe
//
//  Created by Tsutomu Sawada on 06/01/12.
//  Copyright 2006 BathyScaphe Project. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class BSIPIToken;

@interface BSIPIHistoryManager : NSObject {
	NSMutableArray	*_historyBacket;
	NSString		*_dlFolderPath;
}

+ (id) sharedManager;

- (NSMutableArray *) historyBacket;
- (void) setHistoryBacket : (NSMutableArray *) aMutableArray;

- (NSString *) dlFolderPath;

- (void) flushCache;

- (NSArray *) arrayOfURLs;
- (NSArray *) arrayOfPaths;

- (BOOL) isTokenCachedForURL: (NSURL *) anURL;
- (BSIPIToken *) cachedTokenForURL: (NSURL *) anURL;
- (BSIPIToken *) cachedTokenAtIndex: (unsigned) index;
- (unsigned) cachedTokenIndexForURL: (NSURL *) anURL;
- (NSArray *) cachedTokensArrayAtIndexes: (NSIndexSet *) indexes;

- (BOOL) cachedTokensArrayContainsNotNullObjectAtIndexes: (NSIndexSet *) indexes;
- (BOOL) cachedTokensArrayContainsDownloadingTokenAtIndexes: (NSIndexSet *) indexes;

- (void) openURLForTokenAtIndexes: (NSIndexSet *) indexes inBackground: (BOOL) inBg;
- (void) makeTokensCancelDownloadAtIndexes: (NSIndexSet *) indexes;

- (void) openCachedFileForTokenAtIndexesWithPreviewApp: (NSIndexSet *) indexes;
- (void) copyCachedFileForTokenAtIndexes: (NSIndexSet *) indexes intoFolder: (NSString *) folderPath;

- (BOOL) copyCachedFileForPath: (NSString *) cacheFilePath toPath: (NSString *) copiedFilePath;

- (void) saveCachedFileForTokenAtIndex: (unsigned) index savePanelAttachToWindow: (NSWindow *) aWindow;

- (void) addTokenForURL: (NSURL *) anURL;
- (void) addToken: (BSIPIToken *) aToken;
- (void) removeToken: (BSIPIToken *) aToken;
- (void) removeTokenAtIndexes: (NSIndexSet *) indexes;

- (BOOL) appendDataForTokenAtIndexes: (NSIndexSet *) indexes
						toPasteboard: (NSPasteboard *) pboard
			 withFilenamesPboardType: (BOOL) filenamesType;
@end
