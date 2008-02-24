//
//  CMRThreadViewer.m
//  BathyScaphe
//
//  Updated by Tsutomu Sawada on 08/02/24.
//  Copyright 2005-2008 BathyScaphe Project. All rights reserved.
//  encoding="UTF-8"
//

#import "CMRThreadViewer_p.h"

#import "CMRThreadFileLoadingTask.h"
#import "CMRThreadComposingTask.h"
#import "CMRThreadUpdatedHeaderTask.h"
#import "CMR2chDATReader.h"
#import "CMRThreadMessageBufferReader.h"
#import "CMRThreadMessageBuffer.h"
#import "CMRDownloader.h"
#import "ThreadTextDownloader.h"
#import "CMXPopUpWindowManager.h"
#import "CMRHistoryManager.h"
#import "BoardManager.h"
#import "CMRSpamFilter.h"
#import "CMRThreadPlistComposer.h"
#import "CMRNetGrobalLock.h"    /* for Locking */
#import "BSAsciiArtDetector.h"
#import "DatabaseManager.h"

#import "missing.h"

// for debugging only
#define UTIL_DEBUGGING		1
#import "UTILDebugging.h"

NSString *const CMRThreadViewerDidChangeThreadNotification  = @"CMRThreadViewerDidChangeThreadNotification";

NSString *const BSThreadViewerWillStartFindingNotification = @"BSThreadViewerWillStartFindingNotification";
NSString *const BSThreadViewerDidEndFindingNotification = @"BSThreadViewerDidEndFindingNotification";

void *kThreadViewerAttrContext = @"Lucky_Channel";

@implementation CMRThreadViewer
- (id)init
{
	if (self = [super initWithWindowNibName:[self windowNibName]]) {
		[self setInvalidate:NO];
		[self setChangeThemeTaskIsInProgress:NO];

		if (![self loadComponents]) {
			[self release];
			return nil;
		}

		[self registerToNotificationCenter];
		[self setShouldCascadeWindows:NO];
	}
	return self;
}

- (void)dealloc
{
	[CMRPopUpMgr closePopUpWindowForOwner:self];
	[[NSNotificationCenter defaultCenter] removeObserver:self];

	[m_indexingStepper release];
	[m_indexingPopupper release];
	[m_componentsView release];
	[m_undo release];
	[_layout release];
	[_history release];
	[super dealloc];
}

- (NSString *)windowNibName
{
	return @"CMRThreadViewer";
}

- (NSString *)titleForTitleBar
{
	NSString *bName_ = [self boardName];
	NSString *tTitle_ = [self title];

	if (!bName_ || !tTitle_) return nil;
	
	return [NSString stringWithFormat:@"%@ %C %@", tTitle_, 0x2014, bName_];
}

- (NSString *)windowTitleForDocumentDisplayName:(NSString *)displayName
{
	NSString *alternateName = [self titleForTitleBar];

	return (alternateName ? alternateName : displayName);
}

- (void)document:(NSDocument *)aDocument willRemoveController:(NSWindowController *)aController
{
	if ([self document] != aDocument || self != (id)aController) return;
	
	[self removeFromNotificationCenter];
	[self removeMessenger:nil];
	[CMRPopUpMgr closePopUpWindowForOwner:self];

	[self disposeThreadAttributes];
	[[self threadLayout] disposeLayoutContext];
}

#pragma mark Loading Thread
static NSDictionary *boardInfoWithFilepath(NSString *filepath)
{
	NSString				*dat_;
	NSString				*bname_;
	CMRDocumentFileManager	*dFM_ = [CMRDocumentFileManager defaultManager];
	
	bname_ = [dFM_ boardNameWithLogPath : filepath];
	dat_ = [dFM_ datIdentifierWithLogPath : filepath];
	
	UTILCAssertNotNil(bname_);
	UTILCAssertNotNil(dat_);
	
	return [NSDictionary dictionaryWithObjectsAndKeys : 
						bname_,	ThreadPlistBoardNameKey,
						dat_,	ThreadPlistIdentifierKey,
						nil];
}

- (void)setThreadContentWithThreadIdentifier:(id)aThreadIdentifier noteHistoryList:(int)relativeIndex
{
    NSString		*documentPath;
	NSURL			*fileURL;
	NSDocument		*document;

    if (![aThreadIdentifier isKindOfClass:[CMRThreadSignature class]]) return;
    
    if ([[self threadIdentifier] isEqual:aThreadIdentifier]) return;
    
    if (![aThreadIdentifier boardName]) return;
	
	documentPath = [aThreadIdentifier threadDocumentPath];
	fileURL = [NSURL fileURLWithPath:documentPath];	
	document = [[CMRDocumentController sharedDocumentController] documentAlreadyOpenForURL:fileURL];

	if (document) {
		[document showWindows];
		return;
	} else {
		NSDictionary	*boardInfo;	
		boardInfo = [NSDictionary dictionaryWithObjectsAndKeys:[aThreadIdentifier boardName], ThreadPlistBoardNameKey,
															   [aThreadIdentifier identifier], ThreadPlistIdentifierKey, NULL];

		[self setThreadContentWithFilePath:documentPath boardInfo:boardInfo noteHistoryList:relativeIndex];
	}
}

- (void)setThreadContentWithFilePath:(NSString *)filepath boardInfo:(NSDictionary *)boardInfo noteHistoryList:(int)relativeIndex
{
	CMRThreadAttributes		*attrs_;
	
	// Browserの場合、スレッド表示部分を閉じていた場合は
	// スレッドをいちいち読み込まない。
	if (![self shouldShowContents]) return;

	if (!boardInfo || [boardInfo count] == 0) {
		boardInfo = boardInfoWithFilepath(filepath);
	}
	// 
	// loadFromContentsOfFile:で現在表示している内容は
	// 消去されるので、最後に読んだレス番号などはここで保存しておく。
	// 新しいCMRThreadAttributesを登録するとthreadWillCloseが呼ばれ、
	// 属性を書き戻す（＜かなり無駄）。
	// 
	attrs_ = [[CMRThreadAttributes alloc] initWithDictionary:boardInfo];
	[self setThreadAttributes:attrs_];
	[attrs_ release];
	
	// 自身の管理する履歴に登録、または移動
	[self noteHistoryThreadChanged:relativeIndex];
	[self loadFromContentsOfFile:filepath];
}

- (void)setThreadContentWithThreadIdentifier:(id)aThreadIdentifier
{
    [self setThreadContentWithThreadIdentifier:aThreadIdentifier noteHistoryList:0];
}

- (void)setThreadContentWithFilePath:(NSString *)filepath boardInfo:(NSDictionary *)boardInfo
{
    [self setThreadContentWithFilePath:filepath boardInfo:boardInfo noteHistoryList:0];
}

- (void)loadFromContentsOfFile:(NSString *)filepath
{
	SGFileRef			*fileRef_;
	NSString			*actualPath_;
	CMRThreadFileLoadingTask	*task_;
	
	fileRef_ = [SGFileRef fileRefWithPath:filepath];
	actualPath_ = [fileRef_ pathContentResolvingLinkIfNeeded];
	
	// 
	// ファイル参照は存在しないファイルには作られない
	// 
	UTILRequireCondition(actualPath_ != nil, FileNotExistsAutoReloadIfNeeded);

	// --------- Create New File Task ---------
	
	task_ = [CMRThreadFileLoadingTask taskWithFilepath:actualPath_];
	[task_ setIdentifier:actualPath_];
/*	[[NSNotificationCenter defaultCenter]
			addObserver : self
			selector : @selector(threadFileLoadingTaskDidLoadFile:)
			name : CMRThreadFileLoadingTaskDidLoadAttributesNotification
			object : task_];
	[self registerComposingNotification : task_];
	// 2008-02-18 */
	[task_ setDelegate:self];
	
	[[self threadLayout] clear];
	[[self threadLayout] push:task_];
	
	return;
	
	
FileNotExistsAutoReloadIfNeeded:
	if (![[self window] isVisible]) [self showWindow:self];
	
	{
		NSString *bName_;
		bName_ = [self boardName];
		
		if (bName_ && [[BoardManager defaultManager] allThreadsShouldAAThreadAtBoard:bName_]) {
			[(CMRThreadDocument *)[self document] setIsAAThread:YES];
		}
		[self updateKeywordsCache];
	}
	[self didChangeThread];
	[[self threadLayout] clear];
	[self reloadIfOnlineMode:self];
}

- (void)didChangeThread
{
	NSString *title_ = [self title];
	if (!title_) {
		NSString *boardName = [self boardName];
		NSString *identifier = [self datIdentifier];
		if (boardName && identifier) {
			title_ = [[DatabaseManager defaultManager] threadTitleFromBoardName:boardName threadIdentifier:identifier];
		}
	}

	if (title_) {
		[[CMRHistoryManager defaultManager] addItemWithTitle:title_ type:CMRHistoryThreadEntryType object:[self threadIdentifier]];
	}

	UTILNotifyName(CMRThreadViewerDidChangeThreadNotification);
}

/*
before this object add messages to its Layout object.
this delegate method would be performed on worker's thread.

cancel, if this method returns NO.
*/
- (BOOL)threadComposingTask:(CMRThreadComposingTask *)aTask willCompleteMessages:(CMRThreadMessageBuffer *)aMessageBuffer
{
	CMRThreadSignature		*threadID;
	
	threadID = [aTask identifier];
	UTILAssertKindOfClass(threadID, CMRThreadSignature);
	NSAssert2([[self threadIdentifier] isEqual:threadID],
			@"implementation error. unexpected delegation.\n"
			@"[self threadIdentifier] = %@ but\n"
			@"[task identifier] = %@",
			[self threadIdentifier], threadID);
	
	// SpamFilter
	if ([CMRPref spamFilterEnabled]) {
		[[CMRSpamFilter sharedInstance] runFilterWithMessages:aMessageBuffer with:threadID];
	}
	// AA
	if ([(CMRThreadDocument *)[self document] isAAThread]) {
		[aMessageBuffer changeAllMessageAttributes:YES flags:CMRAsciiArtMask];
	} else {
		if ([CMRPref asciiArtDetectorEnabled] || [CMRPref treatsAsciiArtAsSpam]) {
			[[BSAsciiArtDetector sharedInstance] runDetectorWithMessages:aMessageBuffer with:threadID];
		}
	}

	return YES;
}

- (void)pushComposingTaskWithThreadReader:(CMRThreadContentsReader *)aReader
{
	CMRThreadComposingTask		*task_;
	
	task_ = [CMRThreadComposingTask taskWithThreadReader:aReader];

	[task_ setThreadTitle:[self title]];
	[task_ setIdentifier:[self threadIdentifier]];
	
	[task_ setDelegate:self];
	
//	[self registerComposingNotification : task_];
	[[self threadLayout] push:task_];
}

- (void)composeDATContents:(NSString *)datContents threadSignature:(CMRThreadSignature *)aSignature nextIndex:(unsigned int)aNextIndex
{
    CMR2chDATReader *reader;
    unsigned         nMessages;
	CMRThreadLayout	*layout_ = [self threadLayout];
    
    // can't process by downloader while viewer execute.
    [[CMRNetGrobalLock sharedInstance] add:aSignature];
    
    nMessages = [layout_ numberOfReadedMessages];
    // check unexpected contetns
    if (![[self threadIdentifier] isEqual:aSignature]) {
        NSLog(@"Unexpected contents:\n"
            @"  thread:  %@\n"
            @"  arrived: %@", [self threadIdentifier], aSignature);
        return;
    }
	// 2005-11-26 様子見中
    if ((aNextIndex != nMessages) && (aNextIndex != NSNotFound)) {
        NSLog(@"Unexpected sequence:\n"
            @"  expected: %u\n"
            @"  arrived:  %u", nMessages, aNextIndex);
        return;
    }
    
    reader = [CMR2chDATReader readerWithContents:datContents];
    if (!reader) return;
    [reader setNextMessageIndex:aNextIndex];

    // updates title, created date, etc...
    if ([[self threadAttributes] needsToBeUpdatedFromLoadedContents]) {
        [[self threadAttributes] addEntriesFromDictionary:[reader threadAttributes]];
	}
    // inserts tag for new arrival messages.
    if (nMessages > 0) {
        [layout_ push:[CMRThreadUpdatedHeaderTask taskWithIndentifier:[self path]]];
    }
    
    [self pushComposingTaskWithThreadReader:reader];
    [layout_ setMessagesEdited:YES];
}

//- (void) threadFileLoadingTaskDidLoadFile : (NSNotification *) aNotification
- (void)threadFileLoadingTaskDidLoadFile:(id)threadAttributes
{
/*	id				task_;
	UTILAssertNotificationName(
		aNotification,
		CMRThreadFileLoadingTaskDidLoadAttributesNotification);
	
	task_ = [aNotification object];
	UTILAssertNotNil(task_);
	
	
	[[NSNotificationCenter defaultCenter]
			removeObserver : self
			name : CMRThreadFileLoadingTaskDidLoadAttributesNotification
			object : task_];

	attributes_ = [aNotification userInfo];
	// 2008-02-18 */
	NSDictionary	*attributes_;
	attributes_ = (NSDictionary *)threadAttributes;
	if (attributes_) {
		// 
		// ファイルの読み込みが終了したので、
		// 記録されていたスレッドの情報で
		// データを更新する。
		// 更にCMRThreadDataDidChangeAttributesNotificationが通知されるはず。
		// (2008-02-19 追記：もはや通知されないが、-addEntriesFromDictionary: で KVO の通知が飛んでくる）。
		// また、この時点でウィンドウの領域なども設定する。
		//
		[[self threadAttributes] addEntriesFromDictionary:attributes_];
		[self synchronizeLayoutAttributes];
	}
	if (![[self window] isVisible]) {
		[self showWindow:self];
	}
	[self didChangeThread];
/*	UTILAssertRespondsTo(task_, @selector(setCallbackIndex:));
	[task_ setCallbackIndex : [[self threadAttributes] lastIndex]];*/
}

/* CMRThreadComposingDidFinishNotification
- (void) threadComposingDidFinished : (NSNotification *) aNotification
{
	id			object_;
	unsigned	nReaded = NSNotFound;
	unsigned	nLoaded = NSNotFound;

	UTILAssertNotificationName(
		aNotification,
		CMRThreadComposingDidFinishNotification);
	object_ = [aNotification object];
	UTILAssertNotNil(object_);
	
	[self removeFromComposingNotification : object_];
	
	// レイアウトの終了
	// 読み込んだレス数を更新
	nReaded = [[self threadLayout] numberOfReadedMessages];
	nLoaded = [[self threadAttributes] numberOfLoadedMessages];
	
    if (nReaded > nLoaded)
		[[self threadAttributes] setNumberOfLoadedMessages : nReaded];
	
	// update any conditions
	[self updateIndexField];
	[self setInvalidate : NO];
	
	if ([object_ isKindOfClass : [CMRThreadFileLoadingTask class]]) {
		// 
		// ファイルからの読み込み、変換が終了
		// すでにレイアウトのタスクを開始したので、
		// オンラインモードなら更新する
		//
		[self scrollToLastReadedIndex : self]; // その前に最後に読んだ位置までスクロールさせておく

		if(![(CMRThreadDocument *)[self document] isDatOchiThread]) {
			if (![self changeThemeTaskIsInProgress]) {
				[self updateKeywordsCache];
				[self reloadIfOnlineMode:self];
			} else {
				[self performSelector:@selector(updateLayoutSettings) withObject:nil afterDelay:0.5];
				[self setChangeThemeTaskIsInProgress:NO];
			}
		}
	} else {
		if ([CMRPref scrollToLastUpdated] && [self canScrollToLastUpdatedMessage])
			[self scrollToLastUpdatedIndex : self];
	}
    // remove from lock
    [[CMRNetGrobalLock sharedInstance] remove : [self threadIdentifier]];

	// 2005-11-24 オンザフライクラッシュ対策
	[[self window] invalidateCursorRectsForView : [[[self threadLayout] scrollView] contentView]];
	
	// まだ名無しさんが決定していなければ決定
	// この時点では WorkerThread が動いており、
	// プログレス・バーもそのままなので少し遅らせる
	[self performSelector: @selector(setupDefaultNoNameIfNeeded) withObject: nil afterDelay: 1.0];
}
// 2008-02-18 */
- (void)threadComposingDidFinish:(id)sender
{
	unsigned	nReaded = NSNotFound;
	unsigned	nLoaded = NSNotFound;

	UTILAssertNotNil(sender);

	// レイアウトの終了
	// 読み込んだレス数を更新
	nReaded = [[self threadLayout] numberOfReadedMessages];
	nLoaded = [[self threadAttributes] numberOfLoadedMessages];
	
    if (nReaded > nLoaded)
		[[self threadAttributes] setNumberOfLoadedMessages:nReaded];
	
	/* update any conditions */
	[self updateIndexField];
	[self setInvalidate:NO];
	
	if ([sender isKindOfClass:[CMRThreadFileLoadingTask class]]) {
		// 
		// ファイルからの読み込み、変換が終了
		// すでにレイアウトのタスクを開始したので、
		// オンラインモードなら更新する
		//
		[self scrollToLastReadedIndex:self]; // その前に最後に読んだ位置までスクロールさせておく

		if(![(CMRThreadDocument *)[self document] isDatOchiThread]) {
			if (![self changeThemeTaskIsInProgress]) {
				[self updateKeywordsCache];
				[self reloadIfOnlineMode:self];
			} else {
				[self performSelector:@selector(updateLayoutSettings) withObject:nil afterDelay:0.5];
				[self setChangeThemeTaskIsInProgress:NO];
			}
		}
	} else {
		if ([CMRPref scrollToLastUpdated] && [self canScrollToLastUpdatedMessage])
			[self scrollToLastUpdatedIndex:self];
	}
    // remove from lock
    [[CMRNetGrobalLock sharedInstance] remove:[self threadIdentifier]];

	// 2005-11-24 オンザフライクラッシュ対策
	[[self window] invalidateCursorRectsForView:[[self scrollView] contentView]];
	[self synchronizeWindowTitleWithDocumentName]; // 2008-02-19 added

	// まだ名無しさんが決定していなければ決定
	// この時点では WorkerThread が動いており、
	// プログレス・バーもそのままなので少し遅らせる
	[self performSelector:@selector(setupDefaultNoNameIfNeeded) withObject:nil afterDelay:1.0];
}

// CMRThreadTaskInterruptedNotification
//- (void) threadTaskInterrupted : (NSNotification *) aNotification
- (void)threadTaskDidInterrupt:(id)sender
{
/*	id			object_;
	
	UTILAssertNotificationName(
		aNotification,
		CMRThreadTaskInterruptedNotification);
	
	object_ = [aNotification object];
	
	// 
	// チェックの後でもいい。
	// 
	[self removeFromComposingNotification : object_];
	if (NO == [object_ respondsToSelector : @selector(identifier)])
	// 2008-02-18 */
	id			identifier_;
	if (![sender respondsToSelector:@selector(identifier)]) return;
	
/*	identifier_ = [object_ identifier];
	if (![[self identifierForThreadTask] isEqual:identifier_]) return;
	// 2008-02-18 */
	identifier_ = [sender identifier];	
	if (![[self path] isEqual:identifier_]) return;
	
    [[CMRNetGrobalLock sharedInstance] remove:identifier_];
	[self setInvalidate:YES];
}

- (CMRThreadLayout *)threadLayout
{
	if (!_layout) {
		_layout = [[CMRThreadLayout alloc] initWithTextView:[self textView]];
		// ワーカースレッドを開始
		[_layout run];
	}
	return _layout;
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
	if (context == kThreadViewerAttrContext && object == [self threadAttributes] && [keyPath isEqualToString:@"visibleRange"]) {
		[self synchronizeVisibleRange];
	} else {
		[super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
	}
}

#pragma mark Detecting Nanashi-san
- (NSString *)detectDefaultNoName
{
	NSEnumerator	*iter_;
	id				item;
	NSCountedSet	*nameSet;
	NSString		*name = nil;

	nameSet = [[NSCountedSet alloc] init];
	iter_ = [[self threadLayout] messageEnumerator];
	while (item = [iter_ nextObject]) {
		if ([item isAboned] || ![item name]) {
			continue;
		}
		[nameSet addObject:[item name]];
	}
	
	iter_ = [nameSet objectEnumerator];
	while (item = [iter_ nextObject]) {
		if (!name || [nameSet countForObject:item] > [nameSet countForObject:name])
			name = item;
	}
	
	name = [name copy];
	[nameSet release];
	
	return name ? [name autorelease] : @"";
}

- (void)setupDefaultNoNameIfNeeded
{
	BoardManager		*mgr = [BoardManager defaultManager];
	NSString			*board;

	board = [self boardName];
	if (!board) return;

	if ([mgr needToDetectNoNameForBoard:board]) {
		if (![mgr startDownloadSettingTxtForBoard:board askIfOffline:YES]) {
			NSString *nameEntry = [self detectDefaultNoName];		
			NSString *name = [mgr askUserAboutDefaultNoNameForBoard:board presetValue:nameEntry];
			if (name) [mgr addNoName:name forBoard:board];
		}
	}
}

#pragma mark Accessors
- (BOOL)isInvalidate
{
	return _flags.invalidate != 0;
}

- (void)setInvalidate:(BOOL)flag
{
	_flags.invalidate = flag ? 1 : 0;
}

- (BOOL)changeThemeTaskIsInProgress
{
	return _flags.themechangeing != 0;
}

- (void)setChangeThemeTaskIsInProgress:(BOOL)flag
{
	_flags.themechangeing = flag ? 1 : 0;
}

- (CMRThreadAttributes *)threadAttributes
{
	return [(CMRThreadDocument*)[self document] threadAttributes];
}

- (id)threadIdentifier
{
	return [[self threadAttributes] threadSignature];
}

- (NSString *)path
{
	return [[self threadAttributes] path];
}
- (NSString *)title
{
	return [[self threadAttributes] threadTitle];
}
- (NSString *)boardName
{
	return [[self threadAttributes] boardName];
}

- (NSURL *)boardURL
{
	return [[self threadAttributes] boardURL];
}

- (NSURL *)threadURL
{
	return [[self threadAttributes] threadURL];
}

- (NSString *)datIdentifier
{
	return [[self threadAttributes] datIdentifier];
}

- (NSString *)bbsIdentifier
{
	return [[self threadAttributes] bbsIdentifier];
}

- (NSArray *)cachedKeywords
{
	return [[self document] cachedKeywords];
}

- (void)setCachedKeywords:(NSArray *)array
{
	[[self document] setCachedKeywords:array];
}

#pragma mark Working with CMRAbstructThreadDocument
- (void)changeAllMessageAttributesWithAAFlag:(id)flagObject
{
	UTILAssertKindOfClass(flagObject, NSNumber);
	BOOL	flag = [flagObject boolValue];
	[[self threadLayout] changeAllMessageAttributes:flag flags:CMRAsciiArtMask];
}
@end

/*
@implementation CMRThreadViewer(ThreadTaskNotification)
- (id) identifierForThreadTask
{
	return [self path];
}

- (void) registerComposingNotification : (id) task
{
NSString *kComposingNotificationNames[] = {
						CMRThreadComposingDidFinishNotification,
						CMRThreadTaskInterruptedNotification,
						nil };
SEL kComposingNotificationSelectors[] = {
								@selector(threadComposingDidFinished:),
								@selector(threadTaskInterrupted:),
								NULL};
	NSNotificationCenter	*nc = [NSNotificationCenter defaultCenter];
	NSString				**pnm = kComposingNotificationNames;
	SEL						*psel = kComposingNotificationSelectors;
	
	for ( ; *pnm != nil && *psel != NULL; pnm++, psel++)
		[nc addObserver:self selector:*psel name:*pnm object:task];
}
- (void) removeFromComposingNotification : (id) task
{
NSString *kComposingNotificationNames[] = {
						CMRThreadComposingDidFinishNotification,
						CMRThreadTaskInterruptedNotification,
						nil };
	NSNotificationCenter	*nc = [NSNotificationCenter defaultCenter];
	NSString				**p = kComposingNotificationNames;
	
	for ( ; *p != nil; p++)
		[nc removeObserver:self name:*p object:task];
}
@end
*/

@implementation CMRThreadViewer(SelectingThreads)
- (unsigned int)numberOfSelectedThreads
{
	return (![self threadAttributes]) ? 0 : 1;
}

- (NSDictionary *)selectedThread
{
	NSMutableDictionary		*dict_;
	CMRThreadAttributes		*attributes_;
	
	attributes_ = [self threadAttributes];
	if (!attributes_) return nil;
	
	dict_ = [NSMutableDictionary dictionary];
	[dict_ setNoneNil:[attributes_ threadTitle] forKey:CMRThreadTitleKey];
	[dict_ setNoneNil:[attributes_ path] forKey:CMRThreadLogFilepathKey];
	[dict_ setNoneNil:[attributes_ datIdentifier] forKey:ThreadPlistIdentifierKey];
	[dict_ setNoneNil:[attributes_ boardName] forKey:ThreadPlistBoardNameKey];
	
	return dict_;
}

- (NSArray *)selectedThreads
{
	NSDictionary	*selected_;
	
	selected_ = [self selectedThread];
	if (!selected_) return [NSArray empty];
	
	return [NSArray arrayWithObject:selected_];
}

- (NSArray *)selectedThreadsReallySelected
{
	//subclass should override this method
	return [self selectedThreads];
}
@end


@implementation CMRThreadViewer(SaveAttributes)
- (void)threadWillClose
{
//	[CMRPopUpMgr closePopUpWindowForOwner:self];
	if ([self shouldSaveThreadDataAttributes]) [self synchronize];
}

- (BOOL)synchronize
{
	NSString				*filepath_ = [self path];
	NSMutableDictionary		*mdict_;
	BOOL					attrEdited_, mesEdited_;

	[self saveWindowFrame];
	[self saveLastIndex];
	
	attrEdited_ = [[self threadAttributes] needsToUpdateLogFile];
	mesEdited_ = [[self threadLayout] isMessagesEdited];
	if (!attrEdited_ && !mesEdited_) {
		UTIL_DEBUG_WRITE(@"Not need to synchronize");
		return YES;
	}
	
	mdict_ = [NSMutableDictionary dictionaryWithContentsOfFile:filepath_];
	if (!mdict_) return NO;
	
	if (attrEdited_) {
		[[self threadAttributes] writeAttributes:mdict_];
		[[self threadAttributes] setNeedsToUpdateLogFile:NO];
	}

	if (mesEdited_) {
		NSMutableArray			*newArray_;
		CMRThreadPlistComposer	*composer_;
		CMRThreadMessageBuffer	*mBuffer_;
		NSEnumerator			*iter;
		CMRThreadMessage		*m;
		
		newArray_ = [[NSMutableArray alloc] init];
		composer_ = [[CMRThreadPlistComposer alloc] initWithThreadsArray:newArray_];
		mBuffer_ = [[self threadLayout] messageBuffer];
		UTIL_DEBUG_WRITE1(@"compose messages count=%u", [mBuffer_ count]);
		
		iter = [[mBuffer_ messages] objectEnumerator];
		while (m = [iter nextObject]) {
			[composer_ composeThreadMessage:m];
		}
		
		[mdict_ setObject:newArray_ forKey:ThreadPlistContentsKey];
		
		[composer_ release];
		[newArray_ release];

		[[self threadLayout] setMessagesEdited:NO];
	}

	if ([CMRPref saveThreadDocAsBinaryPlist]) {
		NSData *data_;
		data_ = [NSPropertyListSerialization dataFromPropertyList:mdict_ format:NSPropertyListBinaryFormat_v1_0 errorDescription:NULL];

		if (!data_) return NO;
		return [data_ writeToFile:filepath_ atomically:YES];
	} else {
		return [mdict_ writeToFile:filepath_ atomically:YES];
	}
}

- (void)saveWindowFrame
{
	if (![self threadAttributes]) return;
	if (![self shouldLoadWindowFrameUsingCache]) return;
	
	[[self threadAttributes] setWindowFrame:[[self window] frame]];
}

- (void)saveLastIndex
{
	unsigned	idx;

	if ([CMRPref oldMessageScrollingBehavior]) {
		idx = [[self threadLayout] firstMessageIndexForDocumentVisibleRect];
	} else {
		idx = [[self threadLayout] lastMessageIndexForDocumentVisibleRect];
	}
	if ([[self threadLayout] isInProgress]) {
		NSLog(@"*** REPORT ***\n  "
		@" Since the layout is in progress,"
		@" didn't save last readed index(%u).", idx);
		return;
	}
	[[self threadAttributes] setLastIndex:idx];
}
@end


@implementation CMRThreadViewer(NotificationPrivate)
- (NSUndoManager *)myUndoManager
{
	if (!m_undo) {
		m_undo = [[NSUndoManager alloc] init];
	}
	return m_undo;
}

- (NSUndoManager *)windowWillReturnUndoManager:(NSWindow *)sender
{
	return [self myUndoManager];
}
/*
- (void)threadAttributesDidChangeAttributes:(NSNotification *)notification
{
	UTILAssertNotificationObject(
		notification,
		[self threadAttributes]);
	UTILAssertNotificationName(
		notification,
		CMRThreadAttributesDidChangeNotification);
	
	[self synchronizeAttributes];
}
*/
- (void)appDefaultsLayoutSettingsUpdated:(NSNotification *)notification
{
	UTILAssertNotificationName(notification, AppDefaultsLayoutSettingsUpdatedNotification);
	UTILAssertNotificationObject(notification, CMRPref);

	if (![self textView]) return;
	[self updateLayoutSettings];
	[[self scrollView] setNeedsDisplay:YES];
}

- (void)cleanUpItemsToBeRemoved:(NSArray *)files willReload:(BOOL)flag
{
	if (flag) {
		[[self threadLayout] clear];
		[[self threadAttributes] setLastIndex:NSNotFound];
		[self synchronizeAttributes];
/*		[[self window] invalidateCursorRectsForView:[self textView]];
		[[self textView] setNeedsDisplay:YES];
		[self updateIndexField];*/
	} else {
		[[self threadLayout] clear:self];
	}
}

- (void)threadClearTaskDidFinish:(id<CMRThreadLayoutTask>)task
{
	[self setThreadAttributes:nil];
	[[self window] invalidateCursorRectsForView:[self textView]];
	[[self textView] setNeedsDisplay:YES];
	[self updateIndexField];
}

- (void)trashDidPerformNotification:(NSNotification *)notification
{
	NSArray		*files_;
	NSNumber	*err_;
	NSNumber	*reload_;
	BOOL		shouldReload_;
	
	UTILAssertNotificationName(notification, CMRTrashboxDidPerformNotification);
	UTILAssertNotificationObject(notification, [CMRTrashbox trash]);
	
	err_ = [[notification userInfo] objectForKey:kAppTrashUserInfoStatusKey];
	if (!err_) return;
	UTILAssertKindOfClass(err_, NSNumber);
	if ([err_ intValue] != noErr) return;

	files_ = [[notification userInfo] objectForKey:kAppTrashUserInfoFilesKey];
	UTILAssertKindOfClass(files_, NSArray);
	if (![files_ containsObject:[self path]]) return;

	reload_ = [[notification userInfo] objectForKey:kAppTrashUserInfoAfterFetchKey];
	UTILAssertKindOfClass(reload_, NSNumber);
	shouldReload_ = [reload_ boolValue];

	[self cleanUpItemsToBeRemoved:files_ willReload:shouldReload_];
	if (shouldReload_) {
		[self loadFromContentsOfFile:[files_ objectAtIndex:0]];
	}
}

- (void)sleepDidEnd:(NSNotification *)aNotification
{
	if (![CMRPref isOnlineMode]) return;
	NSTimeInterval delay = [CMRPref delayForAutoReloadAtWaking];

	if ([CMRPref autoReloadViewerWhenWake] && [self threadAttributes]) {
		[self performSelector:@selector(reloadThread:) withObject:nil afterDelay:delay];
	}
}

- (void)registerToNotificationCenter
{
	NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
	[nc addObserver:self
		   selector:@selector(appDefaultsLayoutSettingsUpdated:)
			   name:AppDefaultsLayoutSettingsUpdatedNotification
			 object:CMRPref];
	[nc addObserver:self
	       selector:@selector(trashDidPerformNotification:)
			   name:CMRTrashboxDidPerformNotification
			 object:[CMRTrashbox trash]];
	[nc addObserver:self
		   selector:@selector(applicationDidReset:)
			   name:CMRApplicationDidResetNotification
			 object:nil];
	[nc addObserver:self
		   selector:@selector(threadViewerRunSpamFilter:)
			   name:CMRThreadViewerRunSpamFilterNotification
	         object:nil];
	[nc addObserver:self
		   selector:@selector(threadViewThemeDidChange:)
			   name:AppDefaultsThreadViewThemeDidChangeNotification
			 object:CMRPref];

	[[[NSWorkspace sharedWorkspace] notificationCenter]
	     addObserver:self
	        selector:@selector(sleepDidEnd:)
	            name:NSWorkspaceDidWakeNotification
	          object:nil];

	[super registerToNotificationCenter];
}

- (void)removeFromNotificationCenter
{
	NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];

	[[[NSWorkspace sharedWorkspace] notificationCenter]
	  removeObserver:self
	            name:NSWorkspaceDidWakeNotification
	          object:nil];

	[nc removeObserver:self
				  name:AppDefaultsLayoutSettingsUpdatedNotification
				object:CMRPref];
	[nc removeObserver:self
				  name:CMRTrashboxDidPerformNotification
				object:[CMRTrashbox trash]];
	[nc removeObserver:self
				  name:CMRApplicationDidResetNotification
				object:nil];
	[nc removeObserver:self
				  name:CMRThreadViewerRunSpamFilterNotification
				object:nil];
	[nc removeObserver:self
				  name:AppDefaultsThreadViewThemeDidChangeNotification
				object:CMRPref];
	[super removeFromNotificationCenter];
}

+ (NSString *)localizableStringsTableName
{
	return APP_TVIEW_LOCALIZABLE_FILE;
}
@end
