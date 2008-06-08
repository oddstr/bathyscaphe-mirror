//
//  CMRReplyDocumentFileManager.m
//  BathyScaphe
//
//  Updated by Tsutomu Sawada on 08/03/22.
//  Copyright 2005-2008 BathyScaphe Project. All rights reserved.
//  encoding="UTF-8"
//

#import "CMRReplyDocumentFileManager.h"
#import "CocoMonar_Prefix.h"
#import "CMRDocumentFileManager.h"
#import "CMRThreadAttributes.h"
#import "BoardManager.h"
//#import <AppKit/NSDocumentController.h>

#define REPLY_MESSENGER_DOCUMENT_FOLDER_NAME	@"reply"


@implementation CMRReplyDocumentFileManager
APP_SINGLETON_FACTORY_METHOD_IMPLEMENTATION(defaultManager)

+ (NSArray *)documentAttributeKeys
{
	return [NSArray arrayWithObjects:
		ThreadPlistBoardNameKey,
		CMRThreadTitleKey,
		ThreadPlistIdentifierKey,
		ThreadPlistContentsNameKey,
		ThreadPlistContentsMailKey,
		ThreadPlistContentsMessageKey,
		CMRThreadWindowFrameKey,
		CMRThreadModifiedDateKey,
		nil];
}

- (BOOL)replyDocumentFileExistsAtPath:(NSString *)path
{
	BOOL	isDir;
	
	if ([[NSFileManager defaultManager] fileExistsAtPath:path isDirectory:&isDir]) {
		return (!isDir);
	}
	return NO;
}

- (BOOL)createDocumentFileIfNeededAtPath:(NSString *)filepath contentInfo:(NSDictionary *)contentInfo
{
	NSArray				*requireKeys_;	// 書類に記録する属性のキー
	NSEnumerator		*iter_;
	NSString			*key_;
	NSString			*datIdentifier_;
	NSMutableDictionary	*fileContents_;
	
	UTILAssertNotNilArgument(filepath, @"filepath");
	UTILAssertNotNilArgument(contentInfo, @"contentInfo");

	if ([self replyDocumentFileExistsAtPath:filepath]) return YES;
	
	fileContents_ = [NSMutableDictionary dictionary];
		
	requireKeys_ = [NSArray arrayWithObjects:ThreadPlistBoardNameKey, CMRThreadTitleKey, nil];
	
	iter_ = [[[self class] documentAttributeKeys] objectEnumerator];
	while (key_ = [iter_ nextObject]) {
		id				value_;
		
		if ([requireKeys_ containsObject:key_]){
			value_ = [contentInfo objectForKey:key_];
			UTILAssertNotNil(value_);
		} else {
			value_ = @"";
		}
		[fileContents_ setObject:value_ forKey:key_];
	}
		
	datIdentifier_ = [CMRThreadAttributes identifierFromDictionary:contentInfo];
	[fileContents_ setNoneNil:datIdentifier_ forKey:ThreadPlistIdentifierKey];

	BoardManager		*bm_;
	NSString			*board_;
	bm_ = [BoardManager defaultManager];
	board_ = [contentInfo objectForKey:ThreadPlistBoardNameKey];

	[fileContents_ setObject:[bm_ defaultKotehanForBoard:board_] forKey:ThreadPlistContentsNameKey];
	[fileContents_ setObject:[bm_ defaultMailForBoard:board_] forKey:ThreadPlistContentsMailKey];
	
	return [fileContents_ writeToFile:filepath atomically:YES];
}

- (NSString *)replyDocumentDirectoryWithBoardName:(NSString *)boardName createIfNeeded:(BOOL)flag
{
	SGFileRef *logFolderRef = [[CMRDocumentFileManager defaultManager] ensureDirectoryExistsWithBoardName:boardName];
	SGFileRef *replyFolderRef = [logFolderRef fileRefWithChildName:REPLY_MESSENGER_DOCUMENT_FOLDER_NAME createDirectory:flag];
	return replyFolderRef ? [replyFolderRef filepath] : nil;
}

- (NSString *)replyDocumentFileExtention
{
	return @"cmreply";
//	[[NSDocumentController sharedDocumentController] firstFileExtensionFromType:CMRReplyDocumentType];
}

- (NSString *)replyDocumentFilepathWithLogPath:(NSString *)filepath createIfNeeded:(BOOL)flag
{
	NSString		*path_;
	NSString		*boardName_;
	NSString		*datIdentifier_;
	CMRDocumentFileManager	*docManager = [CMRDocumentFileManager defaultManager];
	
	boardName_ = [docManager boardNameWithLogPath:filepath];
	path_ = [self replyDocumentDirectoryWithBoardName:boardName_ createIfNeeded:flag];
	
	if (!path_) return nil; // flag が NO で、reply フォルダが存在しない場合など
	
	datIdentifier_ = [docManager datIdentifierWithLogPath:filepath];
	path_ = [path_ stringByAppendingPathComponent:datIdentifier_];
	path_ = [path_ stringByAppendingPathExtension:[self replyDocumentFileExtention]];

	return path_;
}
/*
- (NSURL *)replyDocumentURLWithLogURL:(NSURL *)absoluteURL
{
	if (!absoluteURL || ![absoluteURL isFileURL]) return nil;

	NSString *path = [absoluteURL path];
	NSString *replyPath = [self replyDocumentFilepathWithLogPath:path createIfNeeded:YES];
	if (!path) return nil;
	return [NSURL fileURLWithPath:path];
}
*/
// ログファイルパスの配列を渡すと、それに下書きファイル（存在すれば）のパスを追加した配列を返す
- (NSArray *)replyDocumentFilesArrayWithLogsArray:(NSArray *)logfiles
{
	NSEnumerator	*iter_;
	NSMutableArray	*pathArray_;
	NSString		*path_;
	NSString		*replyPath_;
	
	iter_ = [logfiles objectEnumerator];
	pathArray_ = [NSMutableArray arrayWithArray:logfiles];

	while (path_ = [iter_ nextObject]) {		
		replyPath_ = [self replyDocumentFilepathWithLogPath:path_ createIfNeeded:NO];
		if (replyPath_ && [self replyDocumentFileExistsAtPath:replyPath_]) {
			[pathArray_ addObject:replyPath_];
		}
	}
	
	return pathArray_;
}
@end
