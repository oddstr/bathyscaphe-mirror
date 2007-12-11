//:CMRThreadDocument.m
/**
  *
  * @see CMRThreadViewer.h
  * @see CMRThreadAttributes.h
  *
  * @author Takanori Ishikawa
  * @author http://www15.big.or.jp/~takanori/
  * @version 1.0.0d1 (02/09/09  10:30:19 PM)
  *
  */
#import "CMRThreadDocument_p.h"



@implementation CMRThreadDocument
- (id) initWithThreadViewer : (CMRThreadViewer *) viewer
{
	if(self = [self init]){
		[self addWindowController : viewer];
	}
	return self;
}

#pragma mark -
- (NSString *) fileType
{
	return CMRThreadDocumentType;
}
- (NSString *) fileName
{
	NSString		*fileName_;
	
	fileName_ = [[self threadAttributes] path];
	if(nil == fileName_)
		return [super fileName];
	
	return fileName_;
}

- (void) replace : (CMRThreadAttributes *) oldAttrs
			with : (CMRThreadAttributes *) newAttrs
{

	if(nil == newAttrs)
		return;
	// 最近使った項目…は、もう要らないから通知しなくてもいいだろう…
	//[[NSDocumentController sharedDocumentController]
	//			noteNewRecentDocument : self];
	{
		/* 2005-09-15 tsawada2 <ben-sawa@td5.so-net.ne.jp>
		履歴メニューを使ってスレッドを切り替えていると、windowController と document の対応にとりわけ
		注意を払う必要が出てくる。
		
		ウインドウAでスレッド foo を、ウインドウBでスレッド bar を開いており、ウインドウ B がキーウインドウだと
		しよう。ここで、「履歴」メニューからスレッド foo を選択すると、ウインドウ B の内容が foo に入れ替わる。
		しかし、ウインドウAでも foo が表示されたままである。同じスレッドが複数のウインドウで表示されてしまう。
		現在の BathyScaphe では、この状態ではレス番ずれなどのトラブルが発生しやすくなり危険。
		
		これを防ぐため、スレッド切り替え時に document の fileName を切り替え後のスレッドのそれにしっかり set する。
		これと windowAlreadyExistsForPath: でのチェックにより、スレッド foo を選択した時にウインドウ B の内容を
		入れ替えずに、ウインドウAを手前に持ってくるようにする。
		*/
		
		NSString *tmp_ = [newAttrs path];
		[self setFileName : tmp_];
	}
}



- (void) makeWindowControllers
{
	CMRThreadViewer		*viewer_;
	
	viewer_ = [[CMRThreadViewer alloc] init];
	[self addWindowController : viewer_];
	[viewer_ setThreadContentWithFilePath : [self fileName]
								boardInfo : nil];
	
	[viewer_ release];
}

- (BOOL) copyFileIfNeeded: (NSString *) filepath toPath: (NSString **) newpath
{
	// 2007-03-29 tsawada2<ben-sawa@td5.so-net.ne.jp>
	// ログフォルダ以外の場所にあるファイルを開くときは、
	// いったんログフォルダにコピーして、それを開くことにしてみる。
	//

	NSString *folderPath = [[filepath stringByDeletingLastPathComponent] stringByDeletingLastPathComponent];
	NSString *logFolderPath = [[CMRFileManager defaultManager] dataRootDirectoryPath];

	if ([folderPath isEqualToString: logFolderPath]) {
		// No need to copy
		if (newpath != NULL) *newpath = filepath;//[self setFileName: ddd];
		return YES;
	}

	NSDictionary	*fileContents_;
	NSString *boardName;
	NSString *datNumber;
	NSFileManager *fm = [NSFileManager defaultManager];

	fileContents_ = [NSDictionary dictionaryWithContentsOfFile: filepath];
	if(nil == fileContents_) return NO;
	boardName = [fileContents_ objectForKey: ThreadPlistBoardNameKey];
	if (nil == boardName) return NO;
	datNumber = [fileContents_ objectForKey: ThreadPlistIdentifierKey];
	if (nil == datNumber || [datNumber intValue] < 1) return NO;

	NSString *fileName = [filepath lastPathComponent];
	NSString *newLocationFolder = [logFolderPath stringByAppendingPathComponent: boardName];
	NSString *newLocationFile = [newLocationFolder stringByAppendingPathComponent: datNumber];//fileName];
	newLocationFile = [newLocationFile stringByAppendingPathExtension: @"thread"];

	if ([fm fileExistsAtPath: newLocationFile]) {
		NSAlert *alert = [[[NSAlert alloc] init] autorelease];
		[alert setAlertStyle: NSCriticalAlertStyle];
		[alert setMessageText: [NSString stringWithFormat: NSLocalizedString(@"CantCopyErrMsg", @""), fileName]];
		[alert setInformativeText: NSLocalizedString(@"CantCopyBecauseAlreadyExists", @"")];
		[alert addButtonWithTitle: NSLocalizedString(@"Cancel", @"")];
		[alert addButtonWithTitle: NSLocalizedString(@"Proceed", @"")];
		if ([alert runModal] == NSAlertSecondButtonReturn) {
			[fm removeFileAtPath: newLocationFile handler: nil];
		} else {
			return NO;
		}
	}

	if ([fm copyPath:filepath toPath: newLocationFile handler:nil]) {
		if (newpath != NULL) *newpath = newLocationFile;//[self setFileName: ddd];
		return YES;
	}
	return NO;
}

- (BOOL) readFromFile : (NSString *) filepath
			   ofType : (NSString *) type
{
	if([type isEqualToString : CMRThreadDocumentType]){
		NSString *newFilePath = nil;
		[self setFileType : CMRThreadDocumentType];

		if ([self copyFileIfNeeded: filepath toPath: &newFilePath]) {
			[self setFileName: newFilePath];
			return YES;
		}
	}
	return NO;
}

- (BOOL) loadDataRepresentation : (NSData   *) data
                         ofType : (NSString *) aType
{
	return NO;
}


- (BOOL) writeToFile : (NSString *) fileName
              ofType : (NSString *) type;
{	
	if([type isEqualToString : CMRThreadDocumentType]){
		NSDictionary	*fileContents_;

		// ログ書類のフォーマットなら元のソースを読み込み、
		// 単に別の場所に保存する。
		fileContents_ = 
			[NSDictionary dictionaryWithContentsOfFile : [self fileName]];
		if(nil == fileContents_) return NO;
		
		return [fileContents_ writeToFile:fileName atomically:YES];
	}
	
	return [super writeToFile:fileName ofType:type];
}

- (NSData *) dataRepresentationOfType : (NSString *) aType
{
	return nil;
}

#pragma mark -
+ (BOOL) showDocumentWithHistoryItem: (CMRThreadSignature *) historyItem
{
	NSDictionary	*info_;
	NSString *path_ = [historyItem threadDocumentPath];
	
	info_ = [NSDictionary dictionaryWithObjectsAndKeys: 
					[historyItem boardName], ThreadPlistBoardNameKey, [historyItem identifier], ThreadPlistIdentifierKey, nil];
	return [self showDocumentWithContentOfFile: path_ contentInfo: info_];	
}

+ (BOOL) showDocumentWithContentOfFile : (NSString     *) filepath
						   contentInfo : (NSDictionary *) contentInfo
{
	NSDocumentController	*dc_;
	NSDocument				*document_;
	
	if(nil == filepath || nil == contentInfo) return NO;
	
	dc_ = [NSDocumentController sharedDocumentController];
	document_ = [dc_ documentForFileName : filepath];
	
	if(nil == document_){
		CMRThreadViewer			*viewer_;
		
		viewer_ = [[CMRThreadViewer alloc] init];
		document_ = [[self alloc] initWithThreadViewer : viewer_];
		[document_ setFileName : filepath];
		[dc_ addDocument : document_];
		[viewer_ setThreadContentWithFilePath : filepath
									boardInfo : contentInfo];
		[viewer_ release];
		[document_ release];
	} else {
		[document_ showWindows];
	}
	
	return YES;
}
@end
