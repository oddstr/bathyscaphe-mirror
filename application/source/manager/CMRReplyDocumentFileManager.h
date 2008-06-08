//
//  CMRReplyDocumentFileManager.h
//  BathyScaphe
//
//  Updated by Tsutomu Sawada on 08/03/22.
//  Copyright 2005-2008 BathyScaphe Project. All rights reserved.
//  encoding="UTF-8"
//

#import <Foundation/Foundation.h>

@interface CMRReplyDocumentFileManager : NSObject {

}
+ (id)defaultManager;

+ (NSArray *)documentAttributeKeys;

- (BOOL)replyDocumentFileExistsAtPath:(NSString *)path;
- (BOOL)createDocumentFileIfNeededAtPath:(NSString *)filepath contentInfo:(NSDictionary *)contentInfo;

- (NSString *)replyDocumentFileExtention;
- (NSString *)replyDocumentDirectoryWithBoardName:(NSString *)boardName createIfNeeded:(BOOL)flag;
- (NSString *)replyDocumentFilepathWithLogPath:(NSString *)filepath createIfNeeded:(BOOL)flag;

- (NSArray *)replyDocumentFilesArrayWithLogsArray:(NSArray *)logfiles;
@end
