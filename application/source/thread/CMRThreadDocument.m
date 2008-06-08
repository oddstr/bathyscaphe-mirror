//
//  CMRThreadDocument.m
//  BathyScaphe
//
//  Updated by Tsutomu Sawada on 08/02/19.
//  Copyright 2005-2008 BathyScaphe Project. All rights reserved.
//  encoding="UTF-8"
//

#import "CMRThreadDocument.h"
#import "CMRAbstructThreadDocument_p.h"
#import "CMRThreadViewer_p.h"
#import "DatabaseManager.h"

@implementation CMRThreadDocument
- (id)initWithThreadViewer:(CMRThreadViewer *)viewer
{
	if (self = [self init]) {
		[self addWindowController:viewer];
	}
	return self;
}

#pragma mark -
- (NSString *)fileType
{
	return CMRThreadDocumentType;
}

- (NSURL *)fileURL
{
	NSString		*path = [[self threadAttributes] path];
	if (!path) return [super fileURL];

	return [NSURL fileURLWithPath:path];
}

- (void)makeWindowControllers
{
	CMRThreadViewer		*viewer_;
	
	viewer_ = [[CMRThreadViewer alloc] init];
	[self addWindowController:viewer_];
	[viewer_ setThreadContentWithFilePath:[[self fileURL] path] boardInfo:nil];
	[viewer_ release];
}

- (BOOL)copyFileURL:(NSURL *)absoluteURL toURL:(NSURL **)newURL error:(NSError **)outError
{
	// 2007-03-29 tsawada2<ben-sawa@td5.so-net.ne.jp>
	// ログフォルダ以外の場所にあるファイルを開くときは、
	// いったんログフォルダにコピーして、それを開くことにしてみる。
	NSDictionary *dict = [NSDictionary dictionaryWithContentsOfURL:absoluteURL];
	if (!dict) return NO;

	NSString *boardName, *datNumber;
	boardName = [dict objectForKey:ThreadPlistBoardNameKey];
	datNumber = [dict objectForKey:ThreadPlistIdentifierKey];
	if (!boardName || !datNumber) return NO;
	if ([datNumber intValue] < 1) return NO;
	NSURL *url = nil;
	BOOL result = [[CMRDocumentFileManager defaultManager] forceCopyLogFile:absoluteURL boardName:boardName datIdentifier:datNumber destination:&url];

	if (result) {
		[[DatabaseManager defaultManager] registerThreadFromFilePath:[url path]];
		if (newURL != NULL) *newURL = url;
		return YES;
	}

	return NO;
}

- (BOOL)readFromURL:(NSURL *)absoluteURL ofType:(NSString *)typeName error:(NSError **)outError
{
	if ([typeName isEqualToString:CMRThreadDocumentType]) {
		[self setFileType:CMRThreadDocumentType];

		if ([[CMRDocumentFileManager defaultManager] isInLogFolder:absoluteURL]) {
			return YES;
		} else {
			NSURL *newFileURL = nil;
			if ([self copyFileURL:absoluteURL toURL:&newFileURL error:outError]) {
				[self setFileURL:newFileURL];
				return YES;
			}
		}
	}
	return NO;
}

- (BOOL)writeToURL:(NSURL *)absoluteURL ofType:(NSString *)typeName error:(NSError **)outError
{
	if ([typeName isEqualToString:CMRThreadDocumentType]) {
		NSDictionary	*fileContents_;

		// ログ書類のフォーマットなら元のソースを読み込み、
		// 単に別の場所に保存する。
		fileContents_ = [NSDictionary dictionaryWithContentsOfURL:[self fileURL]];
		if (!fileContents_) return NO;

		return [fileContents_ writeToURL:absoluteURL atomically:YES];
	}

	return [super writeToURL:absoluteURL ofType:typeName error:outError];
}

#pragma mark -
+ (BOOL)showDocumentWithHistoryItem:(CMRThreadSignature *)historyItem
{
	NSDictionary	*info_;
	NSString		*path_ = [historyItem threadDocumentPath];
	
	info_ = [NSDictionary dictionaryWithObjectsAndKeys:[historyItem boardName], ThreadPlistBoardNameKey,
													   [historyItem identifier], ThreadPlistIdentifierKey, nil];
	return [self showDocumentWithContentOfFile:path_ contentInfo:info_];	
}

+ (BOOL)showDocumentWithContentOfFile:(NSString *)filepath contentInfo:(NSDictionary *)contentInfo
{
	CMRDocumentController	*docController = [CMRDocumentController sharedDocumentController];
	NSDocument				*document;
	CMRThreadViewer			*viewer;

	if (!filepath || !contentInfo) return NO;
	
	document = [docController documentAlreadyOpenForURL:[NSURL fileURLWithPath:filepath]];
	if (document) {
		[document showWindows];
		return YES;
	}

	viewer = [[CMRThreadViewer alloc] init];
	document = [[self alloc] initWithThreadViewer:viewer];
	[document setFileName:filepath];
	[docController addDocument:document];
	[viewer setThreadContentWithFilePath:filepath boardInfo:contentInfo];
	[viewer release];
	[document release];
	
	return YES;
}
@end
