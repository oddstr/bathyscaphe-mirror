//
//  CMRThreadLinkProcessor.h
//  BathyScaphe
//
//  Updated by Tsutomu Sawada on 07/11/19.
//  Copyright 2005-2007 BathyScaphe Project. All rights reserved.
//  encoding="UTF-8"
//

#import <Cocoa/Cocoa.h>

@interface CMRThreadLinkProcessor : NSObject
+ (BOOL)parseThreadLink:(id)aLink boardName:(NSString **)pBoardName boardURL:(NSURL **)pBoardURL filepath:(NSString **)pFilepath;
+ (BOOL)parseBoardLink:(id)aLink boardName:(NSString **)pBoardName boardURL:(NSURL **)pBoardURL;

+ (BOOL)isMessageLinkUsingLocalScheme:(id)aLink messageIndexes:(NSIndexSet **)indexSetPtr;
+ (BOOL)isBeProfileLinkUsingLocalScheme:(id)aLink linkParam:(NSString **)aParam;
@end
