//:CMRReplyDocumentFileManager.m
/**
  *
  * @see AppDefaults.h
  * @see CMRThreadAttributes.h
  *
  * @author Takanori Ishikawa
  * @author http://www15.big.or.jp/~takanori/
  * @version 1.0.0d1 (02/09/15  9:47:47 PM)
  *
  */
#import "CMRReplyDocumentFileManager.h"
#import "CocoMonar_Prefix.h"
#import "AppDefaults.h"
#import "CMRDocumentFileManager.h"

//#import "CMRDocumentController.h"
#import "CMRThreadAttributes.h"
#import "BoardManager.h"

#import <AppKit/NSDocumentController.h>

#define REPLY_MESSENGER_DOCUMENT_FOLDER_NAME	@"reply"


@implementation CMRReplyDocumentFileManager
APP_SINGLETON_FACTORY_METHOD_IMPLEMENTATION(defaultManager)
@end



@implementation CMRReplyDocumentFileManager(DocumentTypes)
+ (NSArray *) documentAttributeKeys
{
	return [NSArray arrayWithObjects :
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
- (BOOL) replyDocumentFileExistsAtPath : (NSString *) path
{
	BOOL	isDirectory_;
	
	if([[NSFileManager defaultManager] fileExistsAtPath : path
											isDirectory : &isDirectory_]){
		return (NO == isDirectory_);
	}
	return NO;
}
- (BOOL) createDocumentFileIfNeededAtPath : (NSString     *) filepath
                              contentInfo : (NSDictionary *) contentInfo
{
	NSArray				*requireKeys_;	// ���ނɋL�^���鑮���̃L�[
	NSEnumerator		*iter_;
	NSString			*key_;
	NSMutableDictionary	*fileContents_;
	
	UTILAssertNotNilArgument(filepath, @"filepath");
	UTILAssertNotNilArgument(contentInfo, @"contentInfo");
	if([self replyDocumentFileExistsAtPath : filepath])
		return YES;
	
	fileContents_ = [NSMutableDictionary dictionary];
	
	
	requireKeys_ = [NSArray arrayWithObjects :
		ThreadPlistBoardNameKey,
		CMRThreadTitleKey,
		nil];
	
	
	iter_ = [[[self class] documentAttributeKeys] objectEnumerator];
	while(key_ = [iter_ nextObject]){
		id				value_;
		
		if([requireKeys_ containsObject : key_]){
			value_ = [contentInfo objectForKey : key_];
			UTILAssertNotNil(value_);
		}else{
			value_ = @"";
		}
		[fileContents_ setObject : value_
						  forKey : key_];
	}
	{
		NSString		*datIdentifier_;
		
		datIdentifier_ = [CMRThreadAttributes identifierFromDictionary:contentInfo];
		[fileContents_ setNoneNil : datIdentifier_
						   forKey : ThreadPlistIdentifierKey];
	}
	BoardManager		*bm_;
	NSString			*board_;
	bm_ = [BoardManager defaultManager];
	board_ = [contentInfo objectForKey : ThreadPlistBoardNameKey];

	[fileContents_ setObject : [bm_ defaultKotehanForBoard : board_]//[CMRPref defaultReplyName]
					  forKey : ThreadPlistContentsNameKey];
	[fileContents_ setObject : [bm_ defaultMailForBoard : board_]//[CMRPref defaultReplyMailAddress]
					  forKey : ThreadPlistContentsMailKey];
	
	return [fileContents_ writeToFile:filepath atomically:YES];
}

- (NSString *) replyDocumentDirectoryWithBoardName : (NSString *) boardName
{
	NSString		*path_;
	
	[[CMRDocumentFileManager defaultManager] ensureDirectoryExistsWithBoardName : boardName];
	path_ = [[CMRDocumentFileManager defaultManager] directoryWithBoardName : boardName];
	UTILAssertNotNil(path_);
	path_ = [path_ stringByAppendingPathComponent : REPLY_MESSENGER_DOCUMENT_FOLDER_NAME];
	
	if(NO == [CMRPref createDirectoryAtPath : path_])
		return nil;
	
	return path_;
}
- (NSString *) replyDocumentFileExtention
{
	// TestaRossa
	return @"cmreply";//[[NSDocumentController sharedDocumentController]
						//	firstFileExtensionFromType : CMRReplyDocumentType];
}
- (NSString *) replyDocumentFilepathWithLogPath : (NSString *) filepath
{
	NSString		*path_;
	NSString		*boardName_;
	NSString		*datIdentifier_;
	
	boardName_ = [[CMRDocumentFileManager defaultManager] boardNameWithLogPath : filepath];
	path_ = [self replyDocumentDirectoryWithBoardName : boardName_];
	
	if(nil == path_) return nil;
	
	datIdentifier_ = [[CMRDocumentFileManager defaultManager]
						datIdentifierWithLogPath : filepath];
	path_ = [path_ stringByAppendingPathComponent : datIdentifier_];
	path_ = [path_ stringByAppendingPathExtension : 
						[self replyDocumentFileExtention]];
	
	return path_;
}

// ���O�t�@�C���p�X�̔z���n���ƁA����ɉ������t�@�C���i���݂���΁j�̃p�X��ǉ������z���Ԃ�
- (NSArray *) replyDocumentFilesArrayWithLogsArray : (NSArray *) logfiles
{
	NSEnumerator		*iter_;
	NSMutableArray		*pathArray_;
	NSString			*path_;
	
	iter_ = [logfiles objectEnumerator];
	pathArray_ = [NSMutableArray array];

	while ((path_ = [iter_ nextObject]) != nil) {
		NSString		*replyPath_;
		
		[pathArray_ addObject : path_];
		
		replyPath_ = [self replyDocumentFilepathWithLogPath : path_];
		if([self replyDocumentFileExistsAtPath : replyPath_])
			[pathArray_ addObject : replyPath_];
	}
	
	return pathArray_;
}
@end
