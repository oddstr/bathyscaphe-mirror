//
//  CMRBrowser.m
//  BathyScaphe
//
//  Updated by Tsutomu Sawada on 07/08/26.
//  Copyright 2005-2007 BathyScaphe Project. All rights reserved.
//  encoding="UTF-8"
//

#import "CMRBrowser_p.h"
#import "BSBoardInfoInspector.h"
#import "CMRAppDelegate.h"

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
		CMRAppDelegate *delegate = (CMRAppDelegate *)[NSApp delegate];

		if([delegate shouldCascadeBrowserWindow]) {
			[self setShouldCascadeWindows:YES];
		} else {
			[self setShouldCascadeWindows:NO];
			[delegate setShouldCascadeBrowserWindow:YES];
		}

		if (!CMRMainBrowser) {
			CMRMainBrowser = self;
		}

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
	NSString		*threadTitle_ = [[[self currentThreadsList] objectValueForBoardInfo] stringValue];

	if ([[self document] searchString]) {
		/* 2005-09-28 tsawada2 <ben-sawa@td5.so-net.ne.jp>
		   検索結果を表示している間は、それを優先し、ウインドウタイトルの変更を抑制する。*/
		/* 2006-12-14 masakih <masakih@users.sourceforge.jp>
		   ではここで検索結果を表示してしまえばいい。 */
		unsigned foundNum = [[self currentThreadsList] numberOfFilteredThreads];
		
		if (0 == foundNum) {
			threadTitle_ = [self localizedString:kSearchListNotFoundKey];
		} else {
			threadTitle_ = [NSString stringWithFormat:[self localizedString:kSearchListResultKey], foundNum];
		}
	}
	
	if (!threadTitle_) return displayName;
	
	return [NSString stringWithFormat:@"%@ (%@)", displayName, threadTitle_];
}

- (void)exchangeOrDisposeMainBrowser
{
	NSArray *curWindows = [NSApp orderedWindows];
	if (!curWindows || [curWindows count] == 0) {
		CMRMainBrowser = nil;
		return;
	}

	NSEnumerator *iter_ = [curWindows objectEnumerator];
	NSWindow *eachItem;
	
	while ((eachItem = [iter_ nextObject]) != nil) {
		NSWindowController *winController = [eachItem windowController];

		if (winController == self) {
			continue;
		}

		if ([winController isKindOfClass:[self class]]) {
			CMRMainBrowser = (CMRBrowser *)winController;
			break;
		}
	}

	if (CMRMainBrowser == self) {
		CMRMainBrowser = nil;
		[(CMRAppDelegate *)[NSApp delegate] setShouldCascadeBrowserWindow:NO];
	}
}

- (void)dealloc
{
	[CMRPref removeObserver:self forKeyPath:@"isSplitViewVertical"]; 

	// dispose main browser...
	if (CMRMainBrowser == self) {
		[self exchangeOrDisposeMainBrowser];
	}

	[m_listSorterSheetController release];
	[m_addBoardSheetController release];
	[m_editBoardSheetController release];
	[[[self scrollView] horizontalRulerView] release];
	
	[super dealloc];
}

- (void)didChangeThread
{
	NSString *threadTitleAndBoardName;
	BSTitleRulerView *ruler = (BSTitleRulerView *)[[self scrollView] horizontalRulerView];
	// 履歴メニューから選択した可能性もあるので、
	// 表示したスレッドを一覧でも選択させる
	[super didChangeThread];
	threadTitleAndBoardName = [self titleForTitleBar];
	[ruler setTitleStr:(threadTitleAndBoardName ? threadTitleAndBoardName : @"")];
	[ruler setPathStr:[self path]];
	[self selectRowWithCurrentThread];
}

/*- (id) boardIdentifier
{
	return [CMRBBSSignature BBSSignatureWithName : [[self currentThreadsList] BBSName]];
}*/

- (NSString *)boardNameArrowingSecondSource
{
	NSString *firstSource = [self boardName];
	if(firstSource)
		return firstSource;

	NSString *secondSource = [[self currentThreadsList] BBSName];
	return secondSource;
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
	NSString *board = [[self currentThreadsList] BBSName];
	if (board) [[BSBoardInfoInspector sharedInstance] showInspectorForTargetBoard:board];
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
	
	return threads_;
}
@end
