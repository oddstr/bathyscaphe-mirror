/**
  * $Id: CMRThreadViewer.m,v 1.15 2005/11/24 10:15:02 tsawada2 Exp $
  * 
  * CMRThreadViewer.m
  *
  * Copyright (c) 2003, Takanori Ishikawa.
  * See the file LICENSE for copying permission.
  */
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
#import "BSHistoryMenuManager.h"
#import "BSBoardInfoInspector.h"

#import "missing.h"

// for debugging only
#define UTIL_DEBUGGING		1
#import "UTILDebugging.h"

NSString *const CMRThreadViewerDidChangeThreadNotification  = @"CMRThreadViewerDidChangeThreadNotification";


@implementation CMRThreadViewer
- (id) init
{
	if (self = [super initWithWindowNibName : [self windowNibName]]) {
		[self setInvalidate : NO];
		
		if (NO == [self loadComponents]) {
			[self release];
			return nil;
		}
		[self registerToNotificationCenter];
	}
	return self;
}
- (BOOL) shouldCascadeWindows
{
	return NO;
}
- (void) dealloc
{
	[CMRPopUpMgr closePopUpWindowForOwner:self];
	[[NSNotificationCenter defaultCenter] removeObserver : self];
	
	[m_indexingStepper release];
	[m_componentsView release];
	[_layout release];
	[_textStorage release];
	
	[_history release];
	[super dealloc];
}

// NSWindowController:
- (NSString *) windowNibName
{
	return @"CMRThreadViewer";
}

- (NSString *) windowTitleForDocumentDisplayName : (NSString *) displayName
{
	NSString *bName_ = [self boardName];
	NSString *tTitle_ = [self title];

	if ((bName_ == nil) || (tTitle_ == nil))
		return displayName;

	return [NSString stringWithFormat:@"%@ - %@", tTitle_, bName_];
}

/**
  *
  * @see SGDocument.h
  *
  */
- (void)    document : (NSDocument         *) aDocument
willRemoveController : (NSWindowController *) aController;
{
	if ([self document] != aDocument || self != (id)aController)
		return;
	
	[self removeFromNotificationCenter];
	[self removeMessenger : nil];
	
	[self disposeThreadAttributes : [self threadAttributes]];
	[[self threadLayout] disposeLayoutContext];
}

// CMRThreadViewer:
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
- (void) setThreadContentWithThreadIdentifier : (id  ) aThreadIdentifier
							  noteHistoryList : (int ) relativeIndex
{
    NSString		*documentPath_;
    NSDictionary	*boardInfo_;
    
    if (NO == [aThreadIdentifier isKindOfClass : [CMRThreadSignature class]])
    	return;
    
    if ([[self threadIdentifier] isEqual : aThreadIdentifier])
    	return;
    
    if (nil == [aThreadIdentifier BBSName])
    	return;
	
	documentPath_ = [aThreadIdentifier threadDocumentPath];
	
	if (![[self document] windowAlreadyExistsForPath : documentPath_]) {
		boardInfo_ = [NSDictionary dictionaryWithObjectsAndKeys : 
						[aThreadIdentifier BBSName] ,	ThreadPlistBoardNameKey,
						[aThreadIdentifier identifier],	ThreadPlistIdentifierKey,
						nil];
		[self setThreadContentWithFilePath : documentPath_
								 boardInfo : boardInfo_
						   noteHistoryList : relativeIndex];
	}
}

- (void) setThreadContentWithFilePath : (NSString     *) filepath
                            boardInfo : (NSDictionary *) boardInfo
					  noteHistoryList : (int           ) relativeIndex
{
	CMRThreadAttributes		*attrs_;
	
	// Browserの場合、スレッド表示部分を閉じていた場合は
	// スレッドをいちいち読み込まない。
	if (NO == [self shouldShowContents])
		return;

	if (nil == boardInfo || 0 == [boardInfo count])
		boardInfo = boardInfoWithFilepath(filepath);
	
	// 
	// loadFromContentsOfFile:で現在表示している内容は
	// 消去されるので、最後に読んだレス番号などはここで保存しておく。
	// 新しいCMRThreadAttributesを登録するとthreadWillCloseが呼ばれ、
	// 属性を書き戻す（＜かなり無駄）。
	// 
	attrs_ = [[CMRThreadAttributes alloc] initWithDictionary : boardInfo];
	[self setThreadAttributes : attrs_];
	[attrs_ release];
	
	// 自身の管理する履歴に登録、または移動
	[self noteHistoryThreadChanged : relativeIndex];

	[self loadFromContentsOfFile : filepath];
}

- (void) setThreadContentWithThreadIdentifier : (id) aThreadIdentifier
{
    [self setThreadContentWithThreadIdentifier:aThreadIdentifier noteHistoryList:0];
}
- (void) setThreadContentWithFilePath : (NSString     *) filepath
                            boardInfo : (NSDictionary *) boardInfo
{
    [self setThreadContentWithFilePath:filepath boardInfo:boardInfo noteHistoryList:0];
}

- (void) loadFromContentsOfFile : (NSString *) filepath
{
	SGFileRef			*fileRef_;
	NSString			*actualPath_;
	CMRThreadFileLoadingTask	*task_;
	
	fileRef_ = [SGFileRef fileRefWithPath : filepath];
	actualPath_ = [fileRef_ pathContentResolvingLinkIfNeeded];
	
	// 
	// ファイル参照は存在しないファイルには作られない
	// 
	UTILRequireCondition(
		actualPath_ != nil,
		FileNotExistsAutoReloadIfNeeded);
	
	// --------- Create New File Task ---------
	
	task_ = [CMRThreadFileLoadingTask taskWithFilepath : actualPath_];
	[task_ setIdentifier : actualPath_];
	[[NSNotificationCenter defaultCenter]
			addObserver : self
			selector : @selector(threadFileLoadingTaskDidLoadFile:)
			name : CMRThreadFileLoadingTaskDidLoadAttributesNotification
			object : task_];
	[self registerComposingNotification : task_];
	
	[[self threadLayout] clear];
	[[self threadLayout] push : task_];
	
	return;
	
	
FileNotExistsAutoReloadIfNeeded:
	if (NO == [[self window] isVisible])
		[self showWindow : self];
	
	[self didChangeThread];
	[[self threadLayout] clear];
	[self reloadIfOnlineMode : self];
}

- (void) didChangeThread
{
	NSString	*title_;
	
	// スレッド情報の更新
	// 履歴に登録してから、変更の通知
	title_ = [self title];
	if (nil == title_)
		title_ = [self datIdentifier];
		
	[[CMRHistoryManager defaultManager]
		addItemWithTitle : title_
					type : CMRHistoryThreadEntryType
				  object : [self threadIdentifier]];
	
	// 履歴メニューの更新（丸ごと書き換える）
	[[BSHistoryMenuManager defaultManager] updateHistoryMenuWithDefaultMenu];
	
	// 2004-04-10 Takanori Ishikawa <takanori@gd5.so-net.ne.jp>
	// ----------------------------------------
	//フォントの変更を反映させる。
	// Mac OS X 10.3 から TextView のフォントを変更すると、即座に
	// 結果が反映されるようになったため、内容が空のときに反映しないと
	// 既存のスレッドのフォントがすべて変更されてしまう。
	{
		NSFont	*font = [CMRPref threadsViewFont];
		
		if (NO == [[[self textView] font] isEqual : font])
			[[self textView] setFont : font];
	}
	
	UTILNotifyName(CMRThreadViewerDidChangeThreadNotification);
}
- (CMRThreadAttributes *) threadAttributes
{
	return [(CMRThreadDocument*)[self document] threadAttributes];
}

/*
before this object add messages to its Layout object.
this delegate method would be performed on worker's thread.

cancel, if this method returns NO.
*/
- (BOOL) threadComposingTask : (CMRThreadComposingTask *) aTask
		willCompleteMessages : (CMRThreadMessageBuffer *) aMessageBuffer
{
	CMRThreadSignature		*threadID;
	
	threadID = [aTask identifier];
	UTILAssertKindOfClass(threadID, CMRThreadSignature);
	NSAssert2([[self threadIdentifier] isEqual : threadID],
			@"implementation error. unexpected delegation.\n"
			@"[self threadIdentifier] = %@ but\n"
			@"[task identifier] = %@",
			[self threadIdentifier], threadID);
	
	// SpamFilter
	if ([CMRPref spamFilterEnabled]) {
		[[CMRSpamFilter sharedInstance]
			runFilterWithMessages : aMessageBuffer
							 with : threadID];
	}
	// AA
	if ([self isAAThread]) {
		[aMessageBuffer changeAllMessageAttributes:YES flags:CMRAsciiArtMask];
	}
	
	// Delegate
	[aTask setDelegate : nil];
	return YES;
}
- (void) pushComposingTaskWithThreadReader : (CMRThreadContentsReader *) aReader
{
	CMRThreadComposingTask		*task_;
	
	task_ = [CMRThreadComposingTask taskWithThreadReader : aReader];

	[task_ setThreadTitle : [self title]];
	[task_ setIdentifier : [self threadIdentifier]];
	
	[task_ setDelegate : self];
	
	[self registerComposingNotification : task_];
	[[self threadLayout] push : task_];
}

- (void) composeDATContents : (NSString           *) datContents
            threadSignature : (CMRThreadSignature *) aSignature
                  nextIndex : (unsigned int        ) aNextIndex
{
    CMR2chDATReader *reader;
    unsigned         nMessages;
	CMRThreadLayout	*layout_ = [self threadLayout];
    
    // can't process by downloader while viewer execute.
    [[CMRNetGrobalLock sharedInstance] add : aSignature];
    
    nMessages = [layout_ numberOfReadedMessages];
    // check unexpected contetns
    if (NO == [[self threadIdentifier] isEqual : aSignature]) {
        NSLog(@"Unexpected contents:\n"
            @"  thread:  %@\n"
            @"  arrived: %@", [self threadIdentifier], aSignature);
        return;
    }
    if (aNextIndex != nMessages) {
        NSLog(@"Unexpected sequence:\n"
            @"  expected: %u\n"
            @"  arrived:  %u", nMessages, aNextIndex);
        return;
    }
    
    reader = [CMR2chDATReader readerWithContents : datContents];
    if (nil == reader) return;
    [reader setNextMessageIndex : aNextIndex];

    // updates title, created date, etc...
    if ([[self threadAttributes] needsToBeUpdatedFromLoadedContents]) 
        [[self threadAttributes] addEntriesFromDictionary : [reader threadAttributes]];
    
    // inserts tag for new arrival messages.
    if (nMessages > 0) {
        [layout_ push : [CMRThreadUpdatedHeaderTask taskWithIndentifier : [self path]]];
    }
    
    [self pushComposingTaskWithThreadReader: reader];
    [layout_ setMessagesEdited : YES];
}



/*** auxiliary ***/
- (BOOL) isInvalidate { return _flags.invalidate != 0; }
- (void) setInvalidate : (BOOL) flag { _flags.invalidate = flag ? 1 : 0; }



/*
CMRThreadFileLoadingTaskDidLoadAttributesNotification:
*/
- (void) threadFileLoadingTaskDidLoadFile : (NSNotification *) aNotification
{
	id				task_;
	NSDictionary	*attributes_;
	
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
	if (attributes_ != nil) {
		// 
		// ファイルの読み込みが終了したので、
		// 記録されていたスレッドの情報で
		// データを更新する。
		// 更にCMRThreadDataDidChangeAttributesNotificationが通知されるはず。
		// 
		// また、この時点でウィンドウの領域なども設定する。
		// 
		[[self threadAttributes] addEntriesFromDictionary : attributes_];
		[self synchronizeLayoutAttributes];
	}
	if (NO == [[self window] isVisible])
		[self showWindow : self];
	
	UTILAssertRespondsTo(task_, @selector(setCallbackIndex:));
	[task_ setCallbackIndex : [[self threadAttributes] lastIndex]];
}

// CMRThreadComposingCallbackNotification
- (void) threadComposingCallback : (NSNotification *) aNotification
{
	UTILAssertNotificationName(
		aNotification,
		CMRThreadComposingCallbackNotification);
	
	[[NSNotificationCenter defaultCenter]
			removeObserver : self
			name : CMRThreadComposingCallbackNotification
			object : [aNotification object]];
	[self scrollToLastReadedIndex : self];
}

// CMRThreadComposingDidFinishNotification
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
	
	/* update any conditions */
	[self updateIndexField];
	[self setInvalidate : NO];
	

	if ([object_ isKindOfClass : [CMRThreadFileLoadingTask class]]) {
		// 
		// ファイルからの読み込み、変換が終了
		// すでにレイアウトのタスクを開始したので、
		// オンラインモードなら更新する
		// 
		[self reloadIfOnlineMode : self];
	}
    // remove from lock
    [[CMRNetGrobalLock sharedInstance] remove : [self threadIdentifier]];

	// 2005-11-24 オンザフライクラッシュ対策
	[[self window] invalidateCursorRectsForView : [[[self threadLayout] scrollView] contentView]];
	
	// まだ名無しさんが決定していなければ決定
	// この時点では WorkerThread が動いており、
	// プログレス・バーもそのままなので少し遅らせる
	[self performSelector:@selector(setupDefaultNoNameIfNeeded_:) 
			withObject:self
			afterDelay:1];
}

- (id) setupDefaultNoNameIfNeeded_ : (id) sender
{
	[self setupDefaultNoNameIfNeeded];
	return sender;
}

// CMRThreadTaskInterruptedNotification
- (void) threadTaskInterrupted : (NSNotification *) aNotification
{
	id			object_;
	id			identifier_;
	
	UTILAssertNotificationName(
		aNotification,
		CMRThreadTaskInterruptedNotification);
	
	object_ = [aNotification object];
	
	// 
	// チェックの後でもいい。
	// 
	[self removeFromComposingNotification : object_];
	if (NO == [object_ respondsToSelector : @selector(identifier)])
		return;
	
	identifier_ = [object_ identifier];
	
	if (NO == [[self identifierForThreadTask] isEqual : identifier_])
		return;
	
    [[CMRNetGrobalLock sharedInstance] remove : identifier_];
	[self setInvalidate : YES];
}


- (CMRThreadLayout *) threadLayout
{
	if (nil == _layout) {
		_layout = [[CMRThreadLayout alloc] initWithTextView : [self textView]];
		
		// ワーカースレッドを開始
		[_layout run];
	}
	return _layout;
}


#pragma mark Detecting Nanashi-san
- (NSString *) detectDefaultNoName
{
	NSEnumerator	*iter_;
	id				item;
	NSCountedSet	*nameSet;
	NSString		*name = nil;
	
	nameSet = [[NSCountedSet alloc] init];
	iter_ = [[self threadLayout] messageEnumerator];
	while (item = [iter_ nextObject]) {
		
		if ([item isAboned] || nil == [item name])
			continue;
		
		[nameSet addObject : [item name]];
	}
	
	iter_ = [nameSet objectEnumerator];
	while (item = [iter_ nextObject]) {
		if (nil == name || [nameSet countForObject : item] > [nameSet countForObject : name])
			name = item;
	}
	
	name = [name copy];
	[nameSet release];
	
	return name ? [name autorelease] : @"";
}
- (NSString *) setupDefaultNoName : (BOOL) forceOpenInputPanel
{
	BoardManager		*mgr;
	NSString			*name;
	NSString			*board;
	
	board = [[self threadAttributes] boardName];
	if (nil == board)
		board = [(CMRBBSSignature *)[self boardIdentifier] name];
	
	if (nil == board)
		return nil;
	
	mgr = [BoardManager defaultManager];
	name = [mgr defaultNoNameForBoard : board];
	if (nil == name || forceOpenInputPanel) {
		if (nil == name)
			name = [self detectDefaultNoName];
		
		name = [mgr askUserAboutDefaultNoNameForBoard : board
							presetValue : name ? name : @""];
	}
	
	return name;
}
- (NSString *) setupDefaultNoNameIfNeeded
{
	return [self setupDefaultNoName : NO];
}
- (IBAction) openDefaultNoNameInputPanel : (id) sender
{
	[self setupDefaultNoName : YES];
}
- (IBAction) showBoardInspectorPanel : (id) sender
{
	NSString			*board;
	
	board = [[self threadAttributes] boardName];
	if (nil == board)
		board = [(CMRBBSSignature *)[self boardIdentifier] name];
	
	if (nil == board)
		return;

	[[BSBoardInfoInspector sharedInstance] showInspectorForTargetBoard : board];
}

#pragma mark board / thread signature for historyManager .etc
- (id) boardIdentifier
{
	return [[self threadAttributes] BBSSignature];
}
- (id) threadIdentifier
{
	return [[self threadAttributes] threadSignature];
}

#pragma mark Accessors
- (NSString *) path
{
	return [[self threadAttributes] path];
}
- (NSString *) title;
{
	return [[self threadAttributes] threadTitle];
}
- (NSString *) boardName
{
	return [[self threadAttributes] boardName];
}
- (NSURL *) boardURL
{
	return [[self threadAttributes] boardURL];
}
- (NSURL *) threadURL
{
	return [[self threadAttributes] threadURL];
}
- (NSString *) datIdentifier
{
	return [[self threadAttributes] datIdentifier];
}
- (NSString *) bbsIdentifier
{
	return [[self threadAttributes] bbsIdentifier];
}

- (BOOL) isAAThread
{
	return [[self threadAttributes] isAAThread];
}
- (void) setAAThread : (BOOL) isAA
{
	if ([self isAAThread] == isAA)
		return;
	
	[[self threadAttributes] setAAThread : isAA];

	// すべてのレスのAA属性を変更
	[[self threadLayout] changeAllMessageAttributes:isAA flags:CMRAsciiArtMask];
}
@end

#pragma mark -

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
						CMRThreadComposingCallbackNotification,
						nil };
SEL kComposingNotificationSelectors[] = {
								@selector(threadComposingDidFinished:),
								@selector(threadTaskInterrupted:),
								@selector(threadComposingCallback:),
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
						CMRThreadComposingCallbackNotification,
						nil };
	NSNotificationCenter	*nc = [NSNotificationCenter defaultCenter];
	NSString				**p = kComposingNotificationNames;
	
	for ( ; *p != nil; p++)
		[nc removeObserver:self name:*p object:task];
}
@end



@implementation CMRThreadViewer(SelectingThreads)
- (unsigned int) numberOfSelectedThreads
{
	return (nil == [self threadAttributes]) ? 0 : 1;
}
- (NSDictionary *) selectedThread
{
	NSMutableDictionary		*dict_;
	CMRThreadAttributes		*attributes_;
	
	attributes_ = [self threadAttributes];
	if (nil == attributes_) return nil;
	
	dict_ = [NSMutableDictionary dictionary];
	[dict_ setNoneNil : [attributes_ threadTitle]
			   forKey : CMRThreadTitleKey];
	[dict_ setNoneNil : [attributes_ path]
			   forKey : CMRThreadLogFilepathKey];
	[dict_ setNoneNil : [attributes_ datIdentifier]
						 forKey : ThreadPlistIdentifierKey];
	[dict_ setNoneNil : [attributes_ boardName]
			   forKey : ThreadPlistBoardNameKey];
	
	return dict_;
}
- (NSArray *) selectedThreads
{
	NSDictionary	*selected_;
	
	selected_ = [self selectedThread];
	if (nil == selected_)
		return [NSArray empty];
	
	return [NSArray arrayWithObject : selected_];
}
- (NSArray *) selectedThreadsReallySelected
{
	//subclass should override this method
	return [self selectedThreads];
}
@end



@implementation CMRThreadViewer(SaveAttributes)
- (void) threadWillClose
{
	[CMRPopUpMgr closePopUpWindowForOwner:self];
	if ([self shouldSaveThreadDataAttributes]) 
		[self synchronize];
}

- (BOOL) synchronize
{
	NSString				*filepath_ = [self path];
	NSMutableDictionary		*mdict_;
	BOOL					attrEdited_, mesEdited_;
	
	[self saveWindowFrame];
	[self saveLastIndex];
	
	attrEdited_ = [[self threadAttributes] needsToUpdateLogFile];
	mesEdited_ = [[self threadLayout] isMessagesEdited];
	if (NO == attrEdited_ && NO == mesEdited_) {
		UTIL_DEBUG_WRITE(@"Not need to synchronize");
		return YES;
	}
	
	mdict_ = [NSMutableDictionary dictionaryWithContentsOfFile : filepath_];
	if (nil == mdict_) return NO;
	
	if (attrEdited_) {
		[[self threadAttributes] writeAttributes : mdict_];
		[[self threadAttributes] setNeedsToUpdateLogFile : NO];
	}
	
	if (mesEdited_) {
		NSMutableArray			*newArray_;
		CMRThreadPlistComposer	*composer_;
		CMRThreadMessageBuffer	*mBuffer_;
		NSEnumerator			*iter;
		CMRThreadMessage		*m;
		
		newArray_ = [[NSMutableArray alloc] init];
		composer_ = [[CMRThreadPlistComposer alloc] initWithThreadsArray : newArray_];
		mBuffer_ = [[self threadLayout] messageBuffer];
		UTIL_DEBUG_WRITE1(@"compose messages count=%u", [mBuffer_ count]);
		
		iter = [[mBuffer_ messages] objectEnumerator];
		while (m = [iter nextObject]) {
			[composer_ composeThreadMessage : m];
		}
		
		[mdict_ setObject:newArray_ forKey:ThreadPlistContentsKey];
		
		[newArray_ release];
		[composer_ release];
		[[self threadLayout] setMessagesEdited : NO];
	}
	return [mdict_ writeToFile:filepath_ atomically:YES];
}

- (void) saveWindowFrame
{
	if (nil == [self threadAttributes]) return;
	if (NO == [self shouldLoadWindowFrameUsingCache]) return;
	
	[[self threadAttributes] setWindowFrame : [[self window] frame]];
}
- (void) saveLastIndex
{
	unsigned	idx;
	
	idx = [[self threadLayout] messageIndexForDocuemntVisibleRect];
	if ([[self threadLayout] isInProgress]) {
		NSLog(@"*** REPORT ***\n  "
		@" Since the layout is in progress,"
		@" didn't save last readed index(%u).", idx);
		return;
	}
	[[self threadAttributes] setLastIndex : idx];
}
@end



@implementation CMRThreadViewer(NotificationPrivate)
- (void) threadAttributesDidChangeAttributes : (NSNotification *) notification
{
	UTILAssertNotificationObject(
		notification,
		[self threadAttributes]);
	UTILAssertNotificationName(
		notification,
		CMRThreadAttributesDidChangeNotification);
	
	[self didChangeThread];
	[self synchronizeAttributes];
}
- (void) appDefaultsLayoutSettingsUpdated : (NSNotification *) notification
{
	UTILAssertNotificationName(
		notification,
		AppDefaultsLayoutSettingsUpdatedNotification);
	UTILAssertNotificationObject(
		notification,
		CMRPref);
	
	if (nil == [self textView]) return;
	[self updateLayoutSettings];
	[[self scrollView] setNeedsDisplay : YES];
}
- (void) cleanUpItemsToBeRemoved : (NSArray *) files
{
	if (NO == [files containsObject : [self path]]) return;
	
	[[self threadLayout] clear];
	[[self threadAttributes] setLastIndex:NSNotFound];
	[self synchronizeAttributes];
	
	[[self window] invalidateCursorRectsForView : [self textView]];
	[[self textView] setNeedsDisplay : YES];
	[self updateIndexField];
}
- (void) trashDidPerformNotification : (NSNotification *) notification
{
	NSArray		*files_;
	NSNumber	*err_;
	
	UTILAssertNotificationName(
		notification,
		CMRTrashboxDidPerformNotification);
	UTILAssertNotificationObject(
		notification,
		[CMRTrashbox trash]);
	
	err_ = [[notification userInfo] objectForKey : kAppTrashUserInfoStatusKey];
	if (nil == err_) return;
	UTILAssertKindOfClass(err_, NSNumber);
	if ([err_ intValue] != noErr) return;
	
	files_ = [[notification userInfo] objectForKey : kAppTrashUserInfoFilesKey];
	UTILAssertKindOfClass(files_, NSArray);
	
	[self cleanUpItemsToBeRemoved : files_];
}

- (void) registerToNotificationCenter
{
	[[NSNotificationCenter defaultCenter]
	  addObserver : self
	     selector : @selector(appDefaultsLayoutSettingsUpdated:)
	         name : AppDefaultsLayoutSettingsUpdatedNotification
	       object : CMRPref];
	[[NSNotificationCenter defaultCenter]
	  addObserver : self
	     selector : @selector(trashDidPerformNotification:)
	         name : CMRTrashboxDidPerformNotification
	       object : [CMRTrashbox trash]];
	[[NSNotificationCenter defaultCenter]
	  addObserver : self
	     selector : @selector(applicationWillReset:)
	         name : CMRApplicationWillResetNotification
	       object : nil];
	[[NSNotificationCenter defaultCenter]
	  addObserver : self
	     selector : @selector(applicationDidReset:)
	         name : CMRApplicationDidResetNotification
	       object : nil];
	[[NSNotificationCenter defaultCenter]
	  addObserver : self
	     selector : @selector(threadViewerRunSpamFilter:)
	         name : CMRThreadViewerRunSpamFilterNotification
	       object : nil];
	[super registerToNotificationCenter];
}
- (void) removeFromNotificationCenter
{
	[[NSNotificationCenter defaultCenter]
	  removeObserver : self
	            name : AppDefaultsLayoutSettingsUpdatedNotification
	          object : CMRPref];
	[[NSNotificationCenter defaultCenter]
	  removeObserver : self
	            name : CMRTrashboxDidPerformNotification
	          object : [CMRTrashbox trash]];
	[[NSNotificationCenter defaultCenter]
	  removeObserver : self
	            name : CMRApplicationWillResetNotification
	          object : nil];
	[[NSNotificationCenter defaultCenter]
	  removeObserver : self
	            name : CMRApplicationDidResetNotification
	          object : nil];
	[[NSNotificationCenter defaultCenter]
	  removeObserver : self
	            name : CMRThreadViewerRunSpamFilterNotification
	          object : nil];
	[super removeFromNotificationCenter];
}
+ (NSString *) localizableStringsTableName
{
	return APP_TVIEW_LOCALIZABLE_FILE;
}
@end
