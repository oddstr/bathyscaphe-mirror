/**
  * $Id: CMRThreadViewer.m,v 1.2 2005/05/12 20:18:57 tsawada2 Exp $
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
#import "CMRNoNameManager.h"
#import "CMRSpamFilter.h"
#import "CMRThreadPlistComposer.h"
#import "CMRNetGrobalLock.h"    /* for Locking */

#import "missing.h"

// for debugging only
#define UTIL_DEBUGGING		1
#import "UTILDebugging.h"



NSString *const CMRThreadViewerDidChangeThreadNotification  = @"CMRThreadViewerDidChangeThreadNotification";



@interface CMRThreadViewer(CMRStatusLineDelegate)
// History: ThreadSignature...
- (unsigned) historyIndex;
- (void) setHistoryIndex : (unsigned) aHistoryIndex;
- (NSMutableArray *) threadHistoryArray;

- (void) noteHistoryThreadChanged : (int) relativeIndex;
- (void) clearThreadHistories;
@end



@implementation CMRThreadViewer(CMRStatusLineDelegate)
// �A�v���P�[�V�����̃��Z�b�g
- (void) applicationWillReset : (NSNotification *) theNotification
{
	;
}
- (void) applicationDidReset : (NSNotification *) theNotification
{
	// ��������U�������A���ݕ\�����̃X���b�h��ǉ��B
	[self clearThreadHistories];
	[self noteHistoryThreadChanged : 0];
}
- (id) threadIdentifierFromHistoryWithRelativeIndex : (int) relativeIndex
{
	NSArray		*historyItems_ = [self threadHistoryArray];
	unsigned	historyIndex_  = [self historyIndex];
	unsigned	historyCount_  = [historyItems_ count];
	int			newIndex_;
	
	if (NSNotFound == historyIndex_ || 0 == historyCount_)
		return nil;
	
	newIndex_ = historyIndex_;
	newIndex_ += relativeIndex;
	
	if (newIndex_ >= 0 && newIndex_ < historyCount_)
		return [historyItems_ objectAtIndex : newIndex_];
	
	return nil;
}
- (BOOL) performHistoryWithRelativeIndex : (int) relativeIndex
{
	id		threadIdentifier_;
	
	threadIdentifier_ = [self threadIdentifierFromHistoryWithRelativeIndex : relativeIndex];
	if (nil == threadIdentifier_)
		return NO;
	
	// �u�߂�^�i�ށv�ł͎��g�̗������X�g�ɓo�^�����A
	// ����ɗ������ړ�
	[self setThreadContentWithThreadIdentifier:threadIdentifier_ noteHistoryList:relativeIndex];
	
	return YES;
}

// *** delegate: CMRStatusLine *** //
- (BOOL) statusLinePerformForward : (CMRStatusLine *) aStatusLine
{
	return [self performHistoryWithRelativeIndex : 1];
}
- (BOOL) statusLinePerformBackward : (CMRStatusLine *) aStatusLine
{
	return [self performHistoryWithRelativeIndex : -1];
}

- (BOOL) statusLineShouldPerformForward : (CMRStatusLine *) aStatusLine
{
	return ([self threadIdentifierFromHistoryWithRelativeIndex : 1] != nil);
}
- (BOOL) statusLineShouldPerformBackward : (CMRStatusLine *) aStatusLine
{
	return ([self threadIdentifierFromHistoryWithRelativeIndex : -1] != nil);
}

// No History --> NSNotFound
- (unsigned) historyIndex
{
	return _historyIndex;
}
- (void) setHistoryIndex : (unsigned) aHistoryIndex
{
	_historyIndex = aHistoryIndex;
}

// History: ThreadSignature...
- (NSMutableArray *) threadHistoryArray
{
	if (nil == _history) {
		_history = [[NSMutableArray alloc] init];
		[self setHistoryIndex : NSNotFound];
	}
	
	return _history;
}

// �A�������G���g�����폜
- (void) compactThreadHistoryItems
{
	NSMutableArray	*items_;
	int				i;
	id				prev_ = nil;
	
	items_ = [self threadHistoryArray];
	for (i = [items_ count] -1; i >= 0; i--) {
		id	object_;
		
		object_ = [items_ objectAtIndex : i];
		// �A��
		if ([object_ isEqual : prev_]) {
			[items_ removeObjectAtIndex : i];
			continue;
		}
		prev_ = object_;
	}
}
- (void) noteHistoryThreadChanged : (int) relativeIndex
{
	NSMutableArray	*items_;
	unsigned		historyIndex_;
	unsigned		historyCount_;
	int				newIndex_;
	
	items_ = [self threadHistoryArray];
	historyIndex_ = [self historyIndex];
	historyCount_ = [items_ count];
	if (0 == relativeIndex) {
		id				identifier_;
		
		// �o�^
		identifier_ = [self threadIdentifier];
		if (nil == identifier_)
			return;
		
		if (NSNotFound == historyIndex_ || historyIndex_ == (historyCount_ -1)) {
			[items_ addObject : identifier_];
			historyCount_ = [items_ count];
			newIndex_ = historyCount_ -1;
		} else {
			newIndex_ = historyIndex_ +1;
			
			[items_ insertObject:identifier_ atIndex:newIndex_];
			historyCount_ = [items_ count];
		}
		
		// �A�������G���g���͍폜���A�C���f�b�N�X���C��
		[self compactThreadHistoryItems];
		newIndex_ = [items_ indexOfObject : identifier_];
		
		
	} else {
		// �ړ�
		if (NSNotFound == historyIndex_) return;
		
		newIndex_ = historyIndex_ + relativeIndex;
		if (newIndex_ < 0) newIndex_ = 0;
		if (newIndex_ >= historyCount_) newIndex_ = historyCount_ -1;
	}
	
	[self setHistoryIndex : newIndex_];
}
- (void) clearThreadHistories
{
	[self setHistoryIndex : NSNotFound];
	[[self threadHistoryArray] removeAllObjects];
	
}

@end



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
	return ([self title] != nil) ? [self title] : displayName;
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
	
	bname_ = [[CMRDocumentFileManager defaultManager]
						boardNameWithLogPath : filepath];
	dat_ = [[CMRDocumentFileManager defaultManager]
						datIdentifierWithLogPath : filepath];
	
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
	boardInfo_ = [NSDictionary dictionaryWithObjectsAndKeys : 
						[aThreadIdentifier BBSName] ,	ThreadPlistBoardNameKey,
						[aThreadIdentifier identifier],	ThreadPlistIdentifierKey,
						nil];
	[self setThreadContentWithFilePath : documentPath_
							 boardInfo : boardInfo_
					   noteHistoryList : relativeIndex];
}
- (void) setThreadContentWithFilePath : (NSString     *) filepath
                            boardInfo : (NSDictionary *) boardInfo
					  noteHistoryList : (int           ) relativeIndex
{
	CMRThreadAttributes		*attrs_;
	
	// Browser�̏ꍇ�A�X���b�h�\����������Ă����ꍇ��
	// �X���b�h�����������ǂݍ��܂Ȃ��B
	if (NO == [self shouldShowContents])
		return;

	if (nil == boardInfo || 0 == [boardInfo count])
		boardInfo = boardInfoWithFilepath(filepath);
	
	// 
	// loadFromContentsOfFile:�Ō��ݕ\�����Ă�����e��
	// ���������̂ŁA�Ō�ɓǂ񂾃��X�ԍ��Ȃǂ͂����ŕۑ����Ă����B
	// �V����CMRThreadAttributes��o�^�����threadWillClose���Ă΂�A
	// �����������߂��i�����Ȃ薳�ʁj�B
	// 
	attrs_ = [[CMRThreadAttributes alloc] initWithDictionary : boardInfo];
	[self setThreadAttributes : attrs_];
	[attrs_ release];
	
	// ���g�̊Ǘ����闚���ɓo�^�A�܂��͈ړ�
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
	// �t�@�C���Q�Ƃ͑��݂��Ȃ��t�@�C���ɂ͍���Ȃ�
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
	
	// �X���b�h���̍X�V
	// �����ɓo�^���Ă���A�ύX�̒ʒm
	title_ = [self title];
	if (nil == title_)
		title_ = [self datIdentifier];
		
	[[CMRHistoryManager defaultManager]
		addItemWithTitle : title_
					type : CMRHistoryThreadEntryType
				  object : [self threadIdentifier]];
	
	// 2004-04-10 Takanori Ishikawa <takanori@gd5.so-net.ne.jp>
	// ----------------------------------------
	//�t�H���g�̕ύX�𔽉f������B
	// Mac OS X 10.3 ���� TextView �̃t�H���g��ύX����ƁA������
	// ���ʂ����f�����悤�ɂȂ������߁A���e����̂Ƃ��ɔ��f���Ȃ���
	// �����̃X���b�h�̃t�H���g�����ׂĕύX����Ă��܂��B
	{
		NSFont	*font = [CMRPref threadsViewFont];
		
		if (NO == [[[self textView] font] isEqual : font])
			[[self textView] setFont : font];
	}
	
	UTILNotifyName(CMRThreadViewerDidChangeThreadNotification);
	[[self statusLine] synchronizeHistoryTitleAndSelectedItem];
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
    
    // can't process by downloader while viewer execute.
    [[CMRNetGrobalLock sharedInstance] add : aSignature];
    
    nMessages = [[self threadLayout] numberOfReadedMessages];
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
        [[self threadAttributes] addEntriesFromDictionary : 
            [reader threadAttributes]];
    
    // inserts tag for new arrival messages.
    if (nMessages > 0) {
        [[self threadLayout] push : 
            [CMRThreadUpdatedHeaderTask taskWithIndentifier : [self path]]];
    }
    
    [self pushComposingTaskWithThreadReader: reader];
    [[self threadLayout] setMessagesEdited : YES];
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
		// �t�@�C���̓ǂݍ��݂��I�������̂ŁA
		// �L�^����Ă����X���b�h�̏���
		// �f�[�^���X�V����B
		// �X��CMRThreadDataDidChangeAttributesNotification���ʒm�����͂��B
		// 
		// �܂��A���̎��_�ŃE�B���h�E�̗̈�Ȃǂ��ݒ肷��B
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
	id		object_;
        unsigned	nReaded = NSNotFound;
        unsigned	nLoaded = NSNotFound;
	
	UTILAssertNotificationName(
		aNotification,
		CMRThreadComposingDidFinishNotification);
	object_ = [aNotification object];
	UTILAssertNotNil(object_);
	
	[self removeFromComposingNotification : object_];
	
	// ���C�A�E�g�̏I��
	// �ǂݍ��񂾃��X�����X�V
	nReaded = [[self threadLayout] numberOfReadedMessages];
	nLoaded = [[self threadAttributes] numberOfLoadedMessages];
	
    if (nReaded > nLoaded)
		[[self threadAttributes] setNumberOfLoadedMessages : nReaded];
	
	/* update any conditions */
	[self updateIndexField];
	[self setInvalidate : NO];
	

	if ([object_ isKindOfClass : [CMRThreadFileLoadingTask class]]) {
		// 
		// �t�@�C������̓ǂݍ��݁A�ϊ����I��
		// ���łɃ��C�A�E�g�̃^�X�N���J�n�����̂ŁA
		// �I�����C�����[�h�Ȃ�X�V����
		// 
		[self reloadIfOnlineMode : self];
	}
	
    // remove from lock
    [[CMRNetGrobalLock sharedInstance] remove : [self threadIdentifier]];
    
	// �܂����������񂪌��肵�Ă��Ȃ���Ό���
	// ���̎��_�ł� WorkerThread �������Ă���A
	// �v���O���X�E�o�[�����̂܂܂Ȃ̂ŏ����x�点��
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
	// �`�F�b�N�̌�ł������B
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
		
		// ���[�J�[�X���b�h���J�n
		[_layout run];
	}
	return _layout;
}


/*** ���������� ***/
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
	CMRNoNameManager	*mgr;
	NSString			*name;
	CMRBBSSignature		*board;
	
	board = [[self threadAttributes] BBSSignature];
	if (nil == board)
		board = [self boardIdentifier];
	
	if (nil == board)
		return nil;
	
	mgr = [CMRNoNameManager defaultManager];
	name = [mgr defauoltNoNameForBoard : board];
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

// board / thread signature for historyManager .etc
- (id) boardIdentifier
{
	return [[self threadAttributes] BBSSignature];
}
- (id) threadIdentifier
{
	return [[self threadAttributes] threadSignature];
}

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

	// ���ׂẴ��X��AA������ύX
	[[self threadLayout] changeAllMessageAttributes:isAA flags:CMRAsciiArtMask];
}
@end



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
