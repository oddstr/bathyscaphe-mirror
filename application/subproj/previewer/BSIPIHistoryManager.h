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

- (NSString *) cachedFilePathForURL : (NSURL *) anURL;
@end

extern NSString *const kIPIHistoryItemURLKey;
extern NSString *const kIPIHistoryItemPathKey;