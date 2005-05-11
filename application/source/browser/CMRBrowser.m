/**
  * $Id: CMRBrowser.m,v 1.1.1.1 2005/05/11 17:51:03 tsawada2 Exp $
  * 
  * CMRBrowser.m
  *
  * Copyright (c) 2003, Takanori Ishikawa.
  * See the file LICENSE for copying permission.
  */
#import "CMRBrowser_p.h"

static NSString *const CMRBrowserLoadNibName              = @"Browser";
static NSString *const CMRBrowserStringsOpenBoardKey      = @"Show Board List";
static NSString *const CMRBrowserStringsCloseBoardKey     = @"Hide Board List";
static NSString *const CMRBrowserStringsShowBoardSheetKey = @"Show Board Sheet";


NSString *const CMRBrowserDidChangeBoardNotification = @"CMRBrowserDidChangeBoardNotification";

/*
 * current main browser instance.
 * @see CMRExports.h 
 */
CMRBrowser *CMRMainBrowser = nil;



@implementation CMRBrowser
- (id) init
{
	if (self = [super init]) {
		CMRMainBrowser = self;
		_needToRestoreWindowSize = NO;
	}
	return self;
}

- (NSString *) windowNibName
{
	return CMRBrowserLoadNibName;
}

- (NSString *) windowTitleForDocumentDisplayName : (NSString *) displayName
{
	NSMutableString	*tmp;
	NSString		*template_;
	NSString		*boardName_   = [self boardName];
	NSString		*threadTitle_ = [self title];
	
	if (nil == threadTitle_) return displayName;
	
	template_ = CMXTemplateResource(kWindowTitleFormatKey, nil);
	UTILAssertKindOfClass(template_, NSString);
	
	tmp = SGTemporaryString();
	[tmp setString : template_];

	[tmp replaceCharacters:kWindowTitleBBSNameKey toString:boardName_];
	[tmp replaceCharacters:kWindowTitleThreadTitleKey toString:threadTitle_];
	
	// OS 10.2.6: Dock Menu�̓^�C�g�����R�s�[���Ă���Ȃ��̂ŁA
	return [[tmp copy] autorelease];
}
- (void) dealloc
{
	[[NSNotificationCenter defaultCenter] removeObserver : self];
	// dispose main browser...
	if (CMRMainBrowser == self)
		CMRMainBrowser = nil;
	
	[_filterString release];
	[m_listSorter release];
	[m_listSorterSub release];
	[m_boardListSheetController release];
	[m_listSorterSheetController release];
	
	[super dealloc];
}

- (void) didChangeThread
{
	// �������j���[����I�������\��������̂ŁA
	// �\�������X���b�h���ꗗ�ł��I��������
	[super didChangeThread];
	[self selectRowWithCurrentThread];
}

- (id) boardIdentifier
{
	return [[self currentThreadsList] BBSSignature];
}
- (id) threadIdentifier
{
	return [super threadIdentifier];
}

- (IBAction) showWindow : (id) sender
{
	BOOL	isWindowLoaded_ = [self isWindowLoaded];
	
	[super showWindow : sender];
	if (isWindowLoaded_) return;
	
	// �ǂ��ŊԈ�����̂��A�K��TextView��firstResponder��
	// �Ȃ��Ă��܂����߁A�����ŉ��߂āA�X���b�h�ꗗ��firstResponder
	// �ɐݒ肷��B
	[[self window] setInitialFirstResponder : [self threadsListTable]];
	[[self window] makeFirstResponder : [self threadsListTable]];
}

// CMRThreadViewer:
/**
  * 
  * �I������
  * 
  * @see SGDocument.h
  *
  */
- (void)    document : (NSDocument         *) aDocument
willRemoveController : (NSWindowController *) aController;
{
	[self setCurrentThreadsList : nil];
	
	if ([[self superclass] instancesRespondToSelector : _cmd])
		[super document:aDocument willRemoveController:aController];
}
- (BOOL) shouldShowContents
{
	return (NSHeight([[self textView] visibleRect]) > 0);
}
- (BOOL) shouldLoadWindowFrameUsingCache
{
	return NO;
}
@end



@implementation CMRBrowser(SelectingThreads)
- (unsigned int) numberOfSelectedThreads
{
	// �I�����Ă��Ȃ����\�����Ă���
	if (0 == [[self threadsListTable] numberOfSelectedRows] && [self shouldShowContents])
		return [super numberOfSelectedThreads];
	
	return [[self threadsListTable] numberOfSelectedRows];
}


static BOOL threadDictionaryCompare(NSDictionary *dict1, NSDictionary *dict2)
{
	CMRBBSSignature		*bbs1, *bbs2;
	NSString			*boardName_;
	NSString			*dat1, *dat2;
	BOOL				result = NO;
	
	if (dict1 == dict2) return YES;
	if (nil == dict1 || nil == dict2) return NO;
	
	boardName_ = [CMRThreadAttributes boardNameFromDictionary : dict1];
	bbs1 = [CMRBBSSignature BBSSignatureWithName : boardName_];
	dat1 = [CMRThreadAttributes identifierFromDictionary : dict1];
	
	boardName_ = [CMRThreadAttributes boardNameFromDictionary : dict2];
	bbs2 = [CMRBBSSignature BBSSignatureWithName : boardName_];
	dat2 = [CMRThreadAttributes identifierFromDictionary : dict2];
	
	result = bbs1 ? [bbs1 isEqual : bbs2] : nil == bbs2;
	if (NO == result) return NO;
	
	result = dat1 ? [dat1 isEqualToString : dat2] : nil == dat2;
	if (NO == result) return NO;
	
	return result;
}
- (NSArray *) selectedThreads
{
	NSEnumerator	*indexIter_;
	NSMutableArray	*threads_;
	NSNumber		*indexNum_;
	NSDictionary	*selected_;
	BOOL			selectedItemAdded_ = NO;
	
	// �I�����Ă��Ȃ����\�����Ă��邩������Ȃ�
	// �������A�\����������Ă���ꍇ�͍l���Ȃ�
	selected_ = [self shouldShowContents] ? [super selectedThread] : nil;
	
	threads_ = [NSMutableArray array];
	indexIter_ = [[self threadsListTable] selectedRowEnumerator];
	while ((indexNum_ = [indexIter_ nextObject])) {
		unsigned int		rowIndex_;
		NSDictionary		*thread_;
		
		rowIndex_ = [indexNum_ unsignedIntValue];
		thread_ = [[self currentThreadsList]
					threadAttributesAtRowIndex : rowIndex_ 
								   inTableView : [self threadsListTable]];
		if (nil == thread_) 
			continue;
		if (threadDictionaryCompare(selected_, thread_))
			selectedItemAdded_ = YES;
		
		[threads_ addObject : thread_];
	}
	if (NO == selectedItemAdded_ && selected_ != nil)
		[threads_ addObject : selected_];
	
	return threads_;
}
- (NSArray *) selectedThreadsReallySelected
{
	NSEnumerator	*indexIter_;
	NSMutableArray	*threads_;
	NSNumber		*indexNum_;
	
	// �I�����Ă��Ȃ����\�����Ă��邩������Ȃ�
	// �������A���̃��\�b�h�́u�^�ɑI������Ă���v���̂����Ԃ��Ȃ�(see selectedThreads)
	
	threads_ = [NSMutableArray array];
	indexIter_ = [[self threadsListTable] selectedRowEnumerator];
	while ((indexNum_ = [indexIter_ nextObject])) {
		unsigned int		rowIndex_;
		NSDictionary		*thread_;
		
		rowIndex_ = [indexNum_ unsignedIntValue];
		thread_ = [[self currentThreadsList]
					threadAttributesAtRowIndex : rowIndex_ 
								   inTableView : [self threadsListTable]];
		if (nil == thread_) 
			continue;
		
		[threads_ addObject : thread_];
	}
	
	return threads_;
}
@end



@implementation CMRBrowser(CMRLocalizableStringsOwner)
- (NSString *) localizedShowBoardSheetString
{
	return [self localizedString : CMRBrowserStringsShowBoardSheetKey];
}
- (NSString *) localizedOpenBoardString
{
	return [self localizedString : CMRBrowserStringsOpenBoardKey];
}
- (NSString *) localizedCloseBoardString
{
	return [self localizedString : CMRBrowserStringsCloseBoardKey];
}
@end
