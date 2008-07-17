//
//  CMRBrowser.m
//  BathyScaphe
//
//  Updated by Tsutomu Sawada on 07/08/26.
//  Copyright 2005-2008 BathyScaphe Project. All rights reserved.
//  encoding="UTF-8"
//

#import "CMRBrowser_p.h"
#import "BSBoardInfoInspector.h"

NSString *const CMRBrowserDidChangeBoardNotification = @"CMRBrowserDidChangeBoardNotification";
NSString *const CMRBrowserThListUpdateDelegateTaskDidFinishNotification = @"CMRBrThListUpdateDelgTaskDidFinishNotification";

static void *kBrowserContext = @"Konata";
static NSString *const kObservingKey = @"isSplitViewVertical";

/*
 * current main browser instance.
 * @see CMRExports.h 
 */
CMRBrowser *CMRMainBrowser = nil;

@implementation CMRBrowser
- (id)init
{
	if (self = [super init]) {
		if (!CMRMainBrowser) {
			CMRMainBrowser = self;
		}
		m_isClosing = NO;
		[CMRPref addObserver:self forKeyPath:kObservingKey options:NSKeyValueObservingOptionNew context:kBrowserContext];
	}
	return self;
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
	if (context == kBrowserContext && object == CMRPref && [keyPath isEqualToString:kObservingKey]) {
		[self setupSplitView];
		[[self splitView] resizeSubviewsWithOldSize:[[self splitView] frame].size];
	} else {
		[super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
	}
}

- (NSString *)windowNibName
{
	return @"Browser";
}

- (NSString *)windowTitleForDocumentDisplayName:(NSString *)displayName
{
	// スーパークラス（CMRThreadViewer）が行なっている処理は CMRBrowser では不要なので、単に displayName を返す。
	return displayName;
}

- (BOOL)shouldCascadeWindows
{
	return (CMRMainBrowser != nil);
}

#pragma mark -
#pragma mark Window Cascading
- (void)exchangeOrDisposeMainBrowser
{
	NSArray *curWindows = [NSApp orderedWindows];
	if (!curWindows || [curWindows count] == 0) {
		// Dispose...
		CMRMainBrowser = nil;
		return;
	}

	NSEnumerator *iter_ = [curWindows objectEnumerator];
	NSWindow *eachItem;
	
	while (eachItem = [iter_ nextObject]) {
		NSWindowController *winController = [eachItem windowController];

		if (winController == self) {
			continue;
		}

		if ([winController isKindOfClass:[self class]] && ![(CMRBrowser *)winController isClosing]) {
			// exchange...
			CMRMainBrowser = (CMRBrowser *)winController;
			break;
		}
	}

	// Dispose...
	if (CMRMainBrowser == self) {
		CMRMainBrowser = nil;
	}
}

- (BOOL)isClosing
{
	return m_isClosing;
}

- (BOOL)windowShouldClose:(id)window
{
	m_isClosing = YES;
	return YES;
}

- (void)windowWillClose:(NSNotification *)notification
{
	if (floor(NSAppKitVersionNumber) <= NSAppKitVersionNumber10_4) {
		[CMRPref removeObserver:self forKeyPath:kObservingKey];

		// dispose main browser...
		if (CMRMainBrowser == self) {
			[self exchangeOrDisposeMainBrowser];
		}
	}
}

- (void)dealloc
{
	if (floor(NSAppKitVersionNumber) > NSAppKitVersionNumber10_4) {
		[CMRPref removeObserver:self forKeyPath:kObservingKey]; 

		// dispose main browser...
		if (CMRMainBrowser == self) {
			[self exchangeOrDisposeMainBrowser];
		}
	}
	[m_addBoardSheetController release];
	[m_editBoardSheetController release];
	[[[self scrollView] horizontalRulerView] release];
	
	[super dealloc];
}

#pragma mark -
- (void)didChangeThread
{
	[super didChangeThread];
	// 履歴メニューから選択した可能性もあるので、
	// 表示したスレッドを一覧でも選択させる
	[self selectRowWithCurrentThread];
}

- (void)document:(NSDocument *)aDocument willRemoveController:(NSWindowController *)aController
{
	[self setCurrentThreadsList:nil];
	[super document:aDocument willRemoveController:aController];
}

- (BOOL)shouldShowContents
{
	return (NSHeight([[self textView] visibleRect]) > 0);
}

- (BOOL)shouldLoadWindowFrameUsingCache
{
	return NO;
}

- (IBAction)showBoardInspectorPanel:(id)sender
{
	NSString *board = [[self currentThreadsList] boardName];
	if (board) [[BSBoardInfoInspector sharedInstance] showInspectorForTargetBoard:board];
}
@end


@implementation CMRBrowser(ThreadContents)
- (void)addThreadTitleToHistory
{
	NSString *threadTitleAndBoardName;
	BSTitleRulerView *ruler = (BSTitleRulerView *)[[self scrollView] horizontalRulerView];

	[super addThreadTitleToHistory];

	threadTitleAndBoardName = [self titleForTitleBar];
	[ruler setTitleStr:(threadTitleAndBoardName ? threadTitleAndBoardName : @"")];
	[ruler setPathStr:[self path]];
}
@end


@implementation CMRBrowser(SelectingThreads)
- (unsigned int)numberOfSelectedThreads
{
	unsigned int count = [[self threadsListTable] numberOfSelectedRows];

	// 選択していないが表示している
	if ((count == 0) && [self shouldShowContents]) {
		return [super numberOfSelectedThreads];
	}
	return count;
}


static BOOL threadDictionaryCompare(NSDictionary *dict1, NSDictionary *dict2)
{
	NSString			*brdName1, *brdName2;
	NSString			*dat1, *dat2;
	BOOL				result = NO;
	
	if (dict1 == dict2) return YES;
	if (!dict1 || !dict2) return NO;
	
	brdName1 = [CMRThreadAttributes boardNameFromDictionary:dict1];
	brdName2 = [CMRThreadAttributes boardNameFromDictionary:dict2];

	result = brdName1 ? [brdName1 isEqualToString:brdName2] : (nil == brdName2);
	if (!result) return NO;

	dat1 = [CMRThreadAttributes identifierFromDictionary:dict1];
	dat2 = [CMRThreadAttributes identifierFromDictionary:dict2];
	
	result = dat1 ? [dat1 isEqualToString:dat2] : (nil == dat2);
//	if (!result) return NO;
	
	return result;
}

- (NSArray *)selectedThreads
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

	while (indexNum_ = [indexIter_ nextObject]) {
		unsigned int		rowIndex_;
		NSDictionary		*thread_;
		
		rowIndex_ = [indexNum_ unsignedIntValue];
		thread_ = [[self currentThreadsList] threadAttributesAtRowIndex:rowIndex_ inTableView:[self threadsListTable]];
		if (!thread_) continue;

		if (threadDictionaryCompare(selected_, thread_)) selectedItemAdded_ = YES;
		
		[threads_ addObject:thread_];
	}

	if (!selectedItemAdded_ && selected_) [threads_ addObject:selected_];

	return threads_;
}

- (NSArray *)selectedThreadsReallySelected
{
/*	ThreadsListTable	*table_ = [self threadsListTable];
	NSEnumerator	*indexIter_;
	NSMutableArray	*threads_;
	NSNumber		*indexNum_;
	BSDBThreadList	*threadsList_;
	
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
	
	return threads_;*/
	NSTableView *tableView = [self threadsListTable];
	NSIndexSet	*selectedRows = [tableView selectedRowIndexes];
	CMRThreadsList	*threadsList = [self currentThreadsList];
	if (!threadsList || !selectedRows || [selectedRows count] == 0) {
		return [NSArray array];
	}

	return [threadsList tableView:tableView threadAttibutesArrayAtRowIndexes:selectedRows exceptingPath:nil];
}
@end
