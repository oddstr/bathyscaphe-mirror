//
//  BSIPIHistoryManager.h
//  BathyScaphe Preview Inspector 2.5
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

// For Key-Value Observing
- (unsigned int)countOfTokensArray;
- (id)objectInTokensArrayAtIndex:(unsigned int)index;
- (void)insertObject:(id)anObject inTokensArrayAtIndex:(unsigned int)index;
- (void)removeObjectFromTokensArrayAtIndex:(unsigned int)index;
- (void)replaceObjectInTokensArrayAtIndex:(unsigned int)index withObject:(id)anObject;

- (NSMutableArray *)tokensArray;
- (void)setTokensArray:(NSMutableArray *)newArray;


- (NSString *) dlFolderPath;

- (void) flushCache;

- (NSArray *) arrayOfURLs;
- (NSArray *) arrayOfPaths;

- (BOOL) isTokenCachedForURL: (NSURL *) anURL;
- (BSIPIToken *) cachedTokenForURL: (NSURL *) anURL;
//- (BSIPIToken *) cachedTokenAtIndex: (unsigned) index;
- (unsigned) cachedTokenIndexForURL: (NSURL *) anURL;
- (NSArray *) cachedTokensArrayAtIndexes: (NSIndexSet *) indexes;

- (BOOL) cachedTokensArrayContainsNotNullObjectAtIndexes: (NSIndexSet *) indexes;
- (BOOL) cachedTokensArrayContainsDownloadingTokenAtIndexes: (NSIndexSet *) indexes;
- (BOOL)cachedTokensArrayContainsFailedTokenAtIndexes:(NSIndexSet *)indexes; // Available in 2.6.1 and later.

- (void) openURLForTokenAtIndexes: (NSIndexSet *) indexes inBackground: (BOOL) inBg;
- (void) makeTokensCancelDownloadAtIndexes: (NSIndexSet *) indexes;
- (void)makeTokensRetryDownloadAtIndexes:(NSIndexSet *)indexes; // Available in 2.6.1 and later.

- (void) openCachedFileForTokenAtIndexesWithPreviewApp: (NSIndexSet *) indexes;
- (void) copyCachedFileForTokenAtIndexes: (NSIndexSet *) indexes intoFolder: (NSString *) folderPath;

- (BOOL) copyCachedFileForPath: (NSString *) cacheFilePath toPath: (NSString *) copiedFilePath;

- (void) saveCachedFileForTokenAtIndex: (unsigned) index savePanelAttachToWindow: (NSWindow *) aWindow;

- (BOOL) appendDataForTokenAtIndexes: (NSIndexSet *) indexes
						toPasteboard: (NSPasteboard *) pboard
			 withFilenamesPboardType: (BOOL) filenamesType;
@end
