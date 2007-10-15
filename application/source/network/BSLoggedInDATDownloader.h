//
//  BSLoggedInDATDownloader.h
//  BathyScaphe
//
//  Created by Tsutomu Sawada on 07/10/15.
//  Copyright 2007 BathyScaphe Project. All rights reserved.
//  encoding="UTF-8"
//

#import <Foundation/Foundation.h>
#import "CMRDATDownloader.h"

@interface BSLoggedInDATDownloader : CMRDATDownloader {
	NSString *m_sessionID;
}

+ (id)downloaderWithIdentifier:(CMRThreadSignature *)signature threadTitle:(NSString *)aTitle;

- (BOOL)updateSessionID;
- (NSString *)sessionID;
@end
