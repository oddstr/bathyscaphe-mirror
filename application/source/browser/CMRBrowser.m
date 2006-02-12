/**
  * $Id: CMRBrowser.m,v 1.17 2006/02/12 09:10:23 tsawada2 Exp $
  * 
  * CMRBrowser.m
  *
  * Copyright (c) 2003, Takanori Ishikawa.
  * See the file LICENSE for copying permission.
  */
#import "CMRBrowser_p.h"
#import "BSBoardInfoInspector.h"

static NSString *const CMRBrowserLoadNibName              = @"Browser";

NSString *const CMRBrowserDidChangeBoardNotification = @"CMRBrowserDidChangeBoardNotification";

/*
 * current main browser instance.
 * @see CMRExports.h 
 */
//CMRBrowser *CMRMainBrowser = nil;
id CMRMainBrowser = nil;

@implementation CMRBrowser
- (id) init
{
	if (self = [super init]) {
		CMRMainBrowser = self;
	}
	return self;
}

- (NSString *) windowNibName
{
	return CMRBrowserLoadNibName;
}

- (BOOL) shouldCascadeWindows
{
	return YES;
}

- (NSString *) windowTitleForDocumentDisplayName : (NSString *) displayName
{
	NSString		*threadTitle_ = [[[self currentThreadsList] objectValueForBoardInfo] stringValue];

	if (_filterResultMessage != nil) {
		/* 2005-09-28 tsawada2 <ben-sawa@td5.so-net.ne.jp>
		   検索結果を表示している間は、それを優先し、ウインドウタイトルの変更を抑制する。*/
		return [[self window] title];
	}
	
	if (nil == threadTitle_)
		return displayName;
	
	return [NSString stringWithFormat:@"%@ (%@)", displayName, threadTitle_];
}

- (void) dealloc
{
	[[NSNotificationCenter defaultCenter] removeObserver : self];
	// dispose main browser...
	if (CMRMainBrowser == self)
		CMRMainBrowser = nil;
	
	[_filterString release];
	[_filterResultMessage release];

	[m_listSorterSheetController release];
	[m_addBoardSheetController release];
	[[[self scrollView] horizontalRulerView] release];
	
	[super dealloc];
}

- (void) didChangeThread
{
	// 履歴メニューから選択した可能性もあるので、
	// 表示したスレッドを一覧でも選択させる
	[super didChangeThread];
	[self selectRowWithCurrentThread];
}

- (id) boardIdentifier
{
	return [CMRBBSSignature BBSSignatureWithName : [[self currentThreadsList] BBSName]];
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
	
	// どこで間違ったのか、必ずTextViewがfirstResponderに
	// なってしまうため、ここで改めて、スレッド一覧をfirstResponder
	// に設定する。
	[[self window] setInitialFirstResponder : [self threadsListTable]];
	[[self window] makeFirstResponder : [self threadsListTable]];
}

// CMRThreadViewer:
/**
  * 
  * 終了処理
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
- (IBAction) showBoardInspectorPanel : (id) sender
{
	NSString			*board;
	board = [(CMRBBSSignature *)[self boardIdentifier] name];
	
	if (nil == board)
		return;

	[[BSBoardInfoInspector sharedInstance] showInspectorForTargetBoard : board];
}
@end



@implementation CMRBrowser(SelectingThreads)
- (unsigned int) numberOfSelectedThreads
{
	// 選択していないが表示している
	if (0 == [[self threadsListTable] numberOfSelectedRows] && [self shouldShowContents])
		return [super numberOfSelectedThreads];
	
	return [[self threadsListTable] numberOfSelectedRows];
}


static BOOL threadDictionaryCompare(NSDictionary *dict1, NSDictionary *dict2)
{
	NSString			*brdName1, *brdName2;
	NSString			*dat1, *dat2;
	BOOL				result = NO;
	
	if (dict1 == dict2) return YES;
	if (nil == dict1 || nil == dict2) return NO;
	
	brdName1 = [CMRThreadAttributes boardNameFromDictionary : dict1];
	dat1 = [CMRThreadAttributes identifierFromDictionary : dict1];
	
	brdName2 = [CMRThreadAttributes boardNameFromDictionary : dict2];
	dat2 = [CMRThreadAttributes identifierFromDictionary : dict2];
	
	result = brdName1 ? [brdName1 isEqualToString : brdName2] : nil == brdName2;
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
	
	// 選択していないが表示しているかもしれない
	// しかし、表示部分を閉じている場合は考えない
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
	ThreadsListTable	*table_ = [self threadsListTable];
	NSEnumerator	*indexIter_;
	NSMutableArray	*threads_;
	NSNumber		*indexNum_;
	CMRThreadsList	*threadsList_;
	
	// 選択していないが表示しているかもしれない
	// しかし、このメソッドは「真に選択されている」ものしか返さない(see selectedThreads)
	
	threads_ = [NSMutableArray array];
	indexIter_ = [table_ selectedRowEnumerator];
	threadsList_ = [self currentThreadsList];

	if (threadsList_ == nil)
		return threads_;

	while ((indexNum_ = [indexIter_ nextObject])) {
		unsigned int		rowIndex_;
		NSDictionary		*threadAttr_;
		
		rowIndex_ = [indexNum_ unsignedIntValue];
		threadAttr_ = [threadsList_ threadAttributesAtRowIndex : rowIndex_ 
												   inTableView : table_];

		if (nil == threadAttr_)
			continue;
		
		[threads_ addObject : threadAttr_];
	}
	
	return threads_;
}
@end