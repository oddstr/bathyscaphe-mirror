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
	// �ŋߎg�������ځc�́A�����v��Ȃ�����ʒm���Ȃ��Ă��������낤�c
	//[[NSDocumentController sharedDocumentController]
	//			noteNewRecentDocument : self];
	{
		/* 2005-09-15 tsawada2 <ben-sawa@td5.so-net.ne.jp>
		�������j���[���g���ăX���b�h��؂�ւ��Ă���ƁAwindowController �� document �̑Ή��ɂƂ�킯
		���ӂ𕥂��K�v���o�Ă���B
		
		�E�C���h�EA�ŃX���b�h foo ���A�E�C���h�EB�ŃX���b�h bar ���J���Ă���A�E�C���h�E B ���L�[�E�C���h�E����
		���悤�B�����ŁA�u�����v���j���[����X���b�h foo ��I������ƁA�E�C���h�E B �̓��e�� foo �ɓ���ւ��B
		�������A�E�C���h�EA�ł� foo ���\�����ꂽ�܂܂ł���B�����X���b�h�������̃E�C���h�E�ŕ\������Ă��܂��B
		���݂� BathyScaphe �ł́A���̏�Ԃł̓��X�Ԃ���Ȃǂ̃g���u�����������₷���Ȃ�댯�B
		
		�����h�����߁A�X���b�h�؂�ւ����� document �� fileName ��؂�ւ���̃X���b�h�̂���ɂ������� set ����B
		����� windowAlreadyExistsForPath: �ł̃`�F�b�N�ɂ��A�X���b�h foo ��I���������ɃE�C���h�E B �̓��e��
		����ւ����ɁA�E�C���h�EA����O�Ɏ����Ă���悤�ɂ���B
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
	// ���O�t�H���_�ȊO�̏ꏊ�ɂ���t�@�C�����J���Ƃ��́A
	// �������񃍃O�t�H���_�ɃR�s�[���āA������J�����Ƃɂ��Ă݂�B
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

		// ���O���ނ̃t�H�[�}�b�g�Ȃ猳�̃\�[�X��ǂݍ��݁A
		// �P�ɕʂ̏ꏊ�ɕۑ�����B
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
