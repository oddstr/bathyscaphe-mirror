//
//  BSIPIHistoryManager.h
//  BathyScaphe
//
//  Created by Tsutomu Sawada on 06/01/12.
//  Copyright 2006 BathyScaphe Project. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface BSIPIHistoryManager : NSObject {
	NSMutableArray	*_historyBacket;
}

+ (id) sharedManager;

- (NSMutableArray *) historyBacket;
- (void) setHistoryBacket : (NSMutableArray *) aMutableArray;

- (NSArray *) arrayOfURLs;
- (NSArray *) arrayOfPaths;

- (unsigned) indexOfURL: (NSURL *) anURL;
- (unsigned) indexOfPath: (NSString *) aPath;

- (NSString *) cachedFilePathForURL : (NSURL *) anURL;
- (NSURL *) cachedURLForFilePath: (NSString *) aPath;

- (BOOL) addItemOfURL : (NSURL *) anURL andPath : (NSString *) aPath;
- (BOOL) removeItemOfURL: (NSURL *) anURL;

- (NSString *) cachedNextFilePathForURL: (NSURL *) currentURL;
- (NSString *) cachedPrevFilePathForURL: (NSURL *) currentURL;
- (NSString *) cachedFirstFilePath;
- (NSString *) cachedLastFilePath;

- (void) openCachedFileForURLWithPreviewApp: (NSURL *) anURL;
- (void) copyCachedFileForURL: (NSURL *) anURL intoFolder: (NSString *) folderPath;

- (BOOL) appendDataForURL: (NSURL *) source toPasteboard: (NSPasteboard *) pboard withFilenamesPboardType: (BOOL) filenamesType;
@end

extern NSString *const kIPIHistoryItemURLKey;
extern NSString *const kIPIHistoryItemPathKey;
