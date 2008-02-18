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

- (NSString *)fileName
{
	NSString		*fileName_ = [[self threadAttributes] path];
	return fileName_ ? fileName_ : [super fileName];
}

- (void)makeWindowControllers
{
	CMRThreadViewer		*viewer_;
	
	viewer_ = [[CMRThreadViewer alloc] init];
	[self addWindowController:viewer_];
	[viewer_ setThreadContentWithFilePath:[self fileName] boardInfo:nil];
	[viewer_ release];
}

- (BOOL)copyFileIfNeeded:(NSString *)filepath toPath:(NSString **)newpath
{
	// 2007-03-29 tsawada2<ben-sawa@td5.so-net.ne.jp>
	// ログフォルダ以外の場所にあるファイルを開くときは、
	// いったんログフォルダにコピーして、それを開くことにしてみる。
	NSString *folderPath = [[filepath stringByDeletingLastPathComponent] stringByDeletingLastPathComponent];
	NSString *logFolderPath = [[CMRFileManager defaultManager] dataRootDirectoryPath];

	if ([folderPath isEqualToString:logFolderPath]) {
		// No need to copy
		if (newpath != NULL) *newpath = filepath;
		return YES;
	}

	NSDictionary	*fileContents_;
	NSString		*boardName;
	NSString		*datNumber;
	NSFileManager *fm = [NSFileManager defaultManager];

	fileContents_ = [NSDictionary dictionaryWithContentsOfFile:filepath];
	if (!fileContents_) return NO;
	boardName = [fileContents_ objectForKey:ThreadPlistBoardNameKey];
	if (!boardName) return NO;
	datNumber = [fileContents_ objectForKey:ThreadPlistIdentifierKey];
	if (!datNumber || [datNumber intValue] < 1) return NO;

	NSString *fileName = [filepath lastPathComponent];
	NSString *newLocationFolder = [logFolderPath stringByAppendingPathComponent:boardName];
	NSString *newLocationFile = [newLocationFolder stringByAppendingPathComponent:datNumber];
	newLocationFile = [newLocationFile stringByAppendingPathExtension:@"thread"];

	if ([fm fileExistsAtPath:newLocationFile]) {
		NSAlert *alert = [[[NSAlert alloc] init] autorelease];
		[alert setAlertStyle:NSCriticalAlertStyle];
		[alert setMessageText:[NSString stringWithFormat:NSLocalizedString(@"CantCopyErrMsg", @""), fileName]];
		[alert setInformativeText:NSLocalizedString(@"CantCopyBecauseAlreadyExists", @"")];
		[alert addButtonWithTitle:NSLocalizedString(@"Cancel", @"")];
		[alert addButtonWithTitle:NSLocalizedString(@"Proceed", @"")];
		if ([alert runModal] == NSAlertSecondButtonReturn) {
			[fm removeFileAtPath:newLocationFile handler:nil];
		} else {
			return NO;
		}
	}

	if ([fm copyPath:filepath toPath:newLocationFile handler:nil]) {
		if (newpath != NULL) *newpath = newLocationFile;
		return YES;
	}
	return NO;
}

- (BOOL)readFromFile:(NSString *)filepath ofType:(NSString *)type
{
	if ([type isEqualToString:CMRThreadDocumentType]) {
		NSString *newFilePath = nil;
		[self setFileType:CMRThreadDocumentType];

		if ([self copyFileIfNeeded:filepath toPath:&newFilePath]) {
			[self setFileName:newFilePath];
			return YES;
		}
	}
	return NO;
}

- (BOOL)loadDataRepresentation:(NSData *)data ofType:(NSString *)aType
{
	return NO;
}

- (BOOL)writeToFile:(NSString *)fileName ofType:(NSString *)type
{
	if ([type isEqualToString:CMRThreadDocumentType]) {
		NSDictionary	*fileContents_;

		// ログ書類のフォーマットなら元のソースを読み込み、
		// 単に別の場所に保存する。
		fileContents_ = [NSDictionary dictionaryWithContentsOfFile:[self fileName]];
		if (!fileContents_) return NO;

		return [fileContents_ writeToFile:fileName atomically:YES];
	}

	return [super writeToFile:fileName ofType:type];
}

- (NSData *)dataRepresentationOfType:(NSString *)aType
{
	return nil;
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
