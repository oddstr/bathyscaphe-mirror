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

- (BOOL) readFromFile : (NSString *) filepath
			   ofType : (NSString *) type
{
	if([type isEqualToString : CMRThreadDocumentType]){

		[self setFileType : CMRThreadDocumentType];
		[self setFileName : filepath];
		return YES;

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
@end



@implementation CMRThreadDocument(Open)
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
