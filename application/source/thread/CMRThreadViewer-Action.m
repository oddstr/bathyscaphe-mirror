/**
  * $Id: CMRThreadViewer-Action.m,v 1.22 2006/02/12 09:10:23 tsawada2 Exp $
  * 
  * CMRThreadViewer-Action.m
  *
  * Copyright (c) 2003, Takanori Ishikawa.
  * See the file LICENSE for copying permission.
  */
#import "CMRThreadViewer_p.h"

#import "CMRThreadsList.h"
#import "SGLinkCommand.h"
#import "CMRReplyMessenger.h"
#import "CMRReplyDocumentFileManager.h"
#import "CMRThreadVisibleRange.h"
#import "CMRThreadDownloadTask.h"
#import "CMXPopUpWindowManager.h"

// for debugging only
#define UTIL_DEBUGGING		0
#import "UTILDebugging.h"

#pragma mark -

@implementation CMRThreadViewer(ActionSupport)
- (CMRFavoritesOperation) favoritesOperationForThreads : (NSArray *) threadsArray
{
	NSDictionary	*thread_;
	NSString		*path_;
	
	if (nil == threadsArray || 0 == [threadsArray count])
		return CMRFavoritesOperationNone;
	
	thread_ = [threadsArray objectAtIndex : 0];
	path_ = [CMRThreadAttributes pathFromDictionary : thread_];
	UTILAssertNotNil(path_);
	
	return ([[CMRFavoritesManager defaultManager] availableOperationWithPath : path_]);
}

- (CMRReplyMessenger *) messenger : (BOOL) create
{
	NSDocumentController		*docc_;
	CMRReplyDocumentFileManager	*replyMgr_;
	CMRReplyMessenger			*document_;
	NSString					*reppath_;
	
	docc_ = [NSDocumentController sharedDocumentController];
	replyMgr_ = [CMRReplyDocumentFileManager defaultManager];
	reppath_ = [replyMgr_ replyDocumentFilepathWithLogPath : [self path]];
	document_ = [docc_ documentForFileName : reppath_];

	if ((document_ != nil) || NO == create) 
		return document_;
	
	[replyMgr_ createDocumentFileIfNeededAtPath : reppath_ contentInfo : [self selectedThread]];

	document_ = [docc_ openDocumentWithContentsOfFile : reppath_ display : YES];
	return document_;
}

- (void) addMessenger : (CMRReplyMessenger *) aMessenger
{
	[[NSNotificationCenter defaultCenter]
		addObserver : self
		   selector : @selector(replyMessengerDidFinishPosting:)
			   name : CMRReplyMessengerDidFinishPostingNotification
			 object : aMessenger];
}

- (void) replyMessengerDidFinishPosting : (NSNotification *) aNotification
{
	NSSound	*sound_ = nil;
	NSString *soundTitle_;
	UTILAssertNotificationName(
		aNotification,
		CMRReplyMessengerDidFinishPostingNotification);

	soundTitle_ = [CMRPref replyDidFinishSound];
	if (![soundTitle_ isEqualToString : @""])
		sound_ = [NSSound soundNamed : soundTitle_];
	
	if (sound_)
		[sound_ play];

	[self reloadIfOnlineMode : nil];
}

- (void) removeMessenger : (CMRReplyMessenger *) aMessenger
{
	[[NSNotificationCenter defaultCenter]
			 removeObserver : self
					   name : CMRReplyMessengerDidFinishPostingNotification
					 object : aMessenger];
}

- (void) openThreadsInThreadWindow : (NSArray *) threads {}

- (void) openThreadsInBrowser : (NSArray *) threads
{
	NSEnumerator		*Iter_;
	NSDictionary		*threadAttributes_;
	
	int aType = [CMRPref openInBrowserType];
	
	Iter_ = [threads objectEnumerator];
	while ((threadAttributes_ = [Iter_ nextObject])) {
		NSURL			*url_;
		
		switch(aType) {
		case BSOpenInBrowserLatestFifty:
			url_ = [CMRThreadAttributes threadURLWithLatestParamFromDict : threadAttributes_ resCount : 50];
			break;
		case BSOpenInBrowserFirstHundred:
			url_ = [CMRThreadAttributes threadURLWithHeaderParamFromDict : threadAttributes_ resCount : 100];
			break;
		default:
			url_ = [CMRThreadAttributes threadURLFromDictionary : threadAttributes_];
			break;
		}
		[[NSWorkspace sharedWorkspace] openURL : url_ inBackGround : [CMRPref openInBg]];
	}
}

- (void) openThreadsLogFiles : (NSArray *) threads
{
	NSEnumerator		*Iter_;
	NSDictionary		*threadAttributes_;
	
	Iter_ = [threads objectEnumerator];
	while ((threadAttributes_ = [Iter_ nextObject])) {
		NSString			*filepath_;
		
		filepath_ =  [CMRThreadAttributes pathFromDictionary : threadAttributes_];
		[[NSWorkspace sharedWorkspace]
					openFile : filepath_
			 withApplication : @"Property List Editor.app"];
	}
}	
	
@end

#pragma mark -

//
// Show Thread's Information
//
#define kCopyThreadFormatKey		@"Thread - CopyThreadFormat"
#define kThreadInfoTempFile			@"ThreadInfoTemplate.rtf"

#define kCopyThreadBBSNameKey		@"%%%BBSName%%%"
#define kCopyThreadBBSURLKey		@"%%%BBSURL%%%"
#define kCopyThreadTitleKey			@"%%%ThreadTitle%%%"
#define kCopyThreadPathKey			@"%%%ThreadPath%%%"
#define kCopyThreadURLKey			@"%%%ThreadURL%%%"
#define kCopyThreadDATSizeKbKey		@"%%%DATSize-KB%%%"
#define kCopyThreadDATSizeKey		@"%%%DATSize%%%"
#define kCopyThreadCreatedDateKey	@"%%%CreatedDate%%%"
#define kCopyThreadModifiedDateKey	@"%%%ModifiedDate%%%"

#pragma mark -

@implementation CMRThreadViewer(Action)
/* NOTE: It is a history item's action. */	 
- (IBAction) showThreadWithMenuItem : (id) sender	 
{	 
	id historyItem = nil;

	if ([sender respondsToSelector : @selector(representedObject)]) {
		id o = [sender representedObject];
		historyItem = o;
	}
	[self setThreadContentWithThreadIdentifier : historyItem];
}

#pragma mark Reloading thread

- (IBAction) reloadThread
{
	[self downloadThread : [[self threadAttributes] threadSignature]
				   title : [self title]
			   nextIndex : [[self threadLayout] numberOfReadedMessages]];
}
- (IBAction) reloadThread : (id) sender
{
	NSEnumerator		*Iter_;
	NSDictionary		*threadAttributes_;

	Iter_ = [[self selectedThreads] objectEnumerator];
	while ((threadAttributes_ = [Iter_ nextObject])) {
		NSString			*path_;
		NSString			*title_;
		unsigned int		curNumOfMsgs_;
		CMRThreadSignature	*threadSignature_;
		
		path_ =  [CMRThreadAttributes pathFromDictionary : threadAttributes_];
		title_ = [threadAttributes_ objectForKey : CMRThreadTitleKey];
		curNumOfMsgs_ = [threadAttributes_ unsignedIntForKey : CMRThreadLastLoadedNumberKey];
		threadSignature_ = [CMRThreadSignature threadSignatureFromFilepath : path_];
		
		if ([[self threadIdentifier] isEqual : threadSignature_]) {
			if ([self checkCanGenarateContents])
				[self reloadThread];
			
			continue;
		}
		
		[self downloadThread : threadSignature_
					   title : title_
				   nextIndex : curNumOfMsgs_];//NSNotFound];
	}
}
- (IBAction) reloadIfOnlineMode : (id) sender
{
	id<CMRThreadLayoutTask>		task;
	
	if (NO == [CMRPref isOnlineMode] || NO == [self shouldShowContents])
		return;
	
	task = [[CMRThreadDownloadTask alloc] initWithThreadViewer : self];
	[[self threadLayout] push : task];
	[task release];
}

// invoke by CMRThreadDownloadTask...
// NOTE: it should be removed!
- (id) startDownload_veryPrivate
{
	/* XXX */
	[self reloadThread];
	return [NSNull null];
}

#pragma mark Show & Copy Thread Info

- (NSPoint) locationForInformationPopUp
{
	id			docView_;
	NSPoint		loc;
	
	docView_ = [[self textView] enclosingScrollView];
	docView_ = [docView_ contentView];
	
	loc = [docView_ frame].origin;
	loc.y = NSMaxY([docView_ frame]);
	
	docView_ = [[self textView] enclosingScrollView];
	loc = [docView_ convertPoint:loc toView:nil];
	loc = [[docView_ window] convertBaseToScreen : loc];
	return loc;
}
- (void) replaceKeywords : (NSMutableString *) theBuffer
              dictionary : (NSDictionary    *) theThread
{
	static NSString *const kNFStringValue = @" - ";
	id		v = nil;
	NSString	*s;
	unsigned	 bytes;
	
	SEL		messages[] = {
				@selector(boardURLFromDictionary:),
				@selector(threadURLFromDictionary:),
				@selector(boardNameFromDictionary:),
				@selector(threadTitleFromDictionary:),
				@selector(createdDateFromDictionary:),
				@selector(modifiedDateFromDictionary:),
				NULL};
	NSString *keys[] = {
				kCopyThreadBBSURLKey,
				kCopyThreadURLKey,
				kCopyThreadBBSNameKey,
				kCopyThreadTitleKey,
				kCopyThreadCreatedDateKey,
				kCopyThreadModifiedDateKey,
				nil};
	
	SEL			*mp;
	NSString	**key;
	
	for (mp = messages, key = keys; *mp != NULL && *key != nil; mp++, key++) {
		v = [CMRThreadAttributes performSelector : *mp
									  withObject : theThread];
		s = v ? [v stringValue] : kNFStringValue;
		[theBuffer replaceCharacters:*key toString:s];
	}
	
	// dat size (bytes)
	v = [theThread numberForKey : ThreadPlistLengthKey];
	s = v ? [v stringValue] : kNFStringValue;
	[theBuffer replaceCharacters:kCopyThreadDATSizeKey toString:s];
	
	// dat size (Kb)
	v = [theThread numberForKey : ThreadPlistLengthKey];
	bytes = v ? [v unsignedIntValue] : 0;
	bytes /=  1024;
	v = (0 == bytes) ? nil : [NSNumber numberWithUnsignedInt : bytes];
	s = v ? [v stringValue] :  kNFStringValue;
	[theBuffer replaceCharacters:kCopyThreadDATSizeKbKey toString:s];

	// location of thread log file
	s = [CMRThreadAttributes pathFromDictionary : theThread];
	v = s ? [SGFileRef fileRefWithPath : s] : nil;
	s = [v displayPath];
	if (nil == s) s = kNFStringValue;
	[theBuffer replaceCharacters:kCopyThreadPathKey toString:s];
}
- (void) replaceKeywords : (NSMutableString     *) theBuffer
              attributes : (CMRThreadAttributes *) theThread
{
	[self replaceKeywords:theBuffer dictionary:[theThread dictionaryRepresentation]];
}

- (NSString *) templateFilepathForInfoPopUp
{
	NSBundle	*bundles[] = {
			[NSBundle applicationSpecificBundle],
			[NSBundle mainBundle],
			nil};
	NSBundle	**p;
	NSString	*s = nil;
	
	for (p = bundles; *p != nil; p++)
		if ((s = [*p pathForResourceWithName : kThreadInfoTempFile]) != nil)
			break;
	
	return s;
}
- (NSAttributedString *) templateForInfoPopUp
{
	NSString			*filepath_;
	NSAttributedString	*template_;
	
	filepath_ = [self templateFilepathForInfoPopUp];
	template_ = filepath_ ? [NSAttributedString alloc] : nil;
	template_ = [template_ initWithPath:filepath_ documentAttributes:NULL];
	
	return [template_ autorelease];
}

- (IBAction) showThreadAttributes : (id) sender
{
	NSMutableAttributedString	*tmp;
	NSAttributedString			*template_;
	NSPoint						location_;
	
	template_ = [self templateForInfoPopUp];
	if (nil == template_)
		return NSLog(@"ThreadInfo template not found.");
	
	tmp = SGTemporaryAttributedString();
	[tmp setAttributedString : template_];
	
	location_ = [self locationForInformationPopUp];
	
	[self replaceKeywords : [tmp mutableString] 
	           attributes : [self threadAttributes]];
	[CMRPopUpMgr showPopUpWindowWithContext : tmp
								  forObject : [self path]
									  owner : self
							   locationHint : location_];
	[tmp deleteCharactersInRange : [tmp range]];
}

- (IBAction) copyThreadAttributes : (id) sender
{
	NSEnumerator	*Iter_;

	Iter_ = [[self selectedThreads] objectEnumerator];
	if (nil == Iter_) return;

	[self copyThreadInfoOf : Iter_];
}

- (IBAction) copyInfoFromContextualMenu : (id) sender
{
	// 2004-12-12 tsawada2
	/* 今のところ、スレッド一覧でのコンテクストメニューのみ、このアクションを呼び出す。
		真に選択されているスレッドのみ情報をコピーする。
		（これに対して、copyThreadAttributes:は「選択されていないが、3ペイン下部に表示されている」スレッドも
		含めて情報をコピーする） */
	NSEnumerator		*Iter_;
	
	Iter_ = [[self selectedThreadsReallySelected] objectEnumerator];

	[self copyThreadInfoOf : Iter_];
}

- (void) copyThreadInfoOf : (NSEnumerator *) Iter_
{
	NSMutableString	*tmp;
	NSString		*template_;
	NSURL			*url_ = nil;
	NSPasteboard	*pboard_   = [NSPasteboard generalPasteboard];
	NSArray			*types_;
	NSDictionary	*dict_;

	template_ = SGTemplateResource(kCopyThreadFormatKey);
	UTILAssertKindOfClass(template_, NSString);
	
	tmp = SGTemporaryString();
	while (dict_ = [Iter_ nextObject]) {
		[tmp appendString : template_];
		[self replaceKeywords:tmp dictionary:dict_];
		url_ = [CMRThreadAttributes threadURLFromDictionary : dict_];
	}
	
	types_ = [NSArray arrayWithObjects : 
				NSURLPboardType,
				NSStringPboardType,
				nil];
	
	[pboard_ declareTypes:types_ owner:nil];
	
	[url_ writeToPasteboard : pboard_];
	[pboard_ setString:tmp forType:NSStringPboardType];
	
	[tmp deleteCharactersInRange : [tmp range]];
}

- (IBAction) copySelectedResURL : (id) sender
{
	NSRange			selectedRange_;
	unsigned		index_;
	unsigned		last_;

	NSURL			*resURL_;
	CMRHostHandler	*handler_;
	
	if (nil == [self threadAttributes]) return;
	selectedRange_ = [[self textView] selectedRange];
	if (0 == selectedRange_.length) return;
	
	handler_ = [CMRHostHandler hostHandlerForURL : [self boardURL]];
	if (nil == handler_) return;
	
	index_ = [[self threadLayout] messageIndexForRange : selectedRange_];
	last_ = [[self threadLayout] lastMessageIndexForRange : selectedRange_];
	if (NSNotFound == index_ || NSNotFound == last_) {
		NSBeep();
		return;
	}
	
	index_++;
	last_++;
	resURL_ = [handler_ readURLWithBoard : [self boardURL]
								 datName : [self datIdentifier]
								 start : index_
								 end : last_
								 nofirst : NO];
	if (nil == resURL_)
		return;
	
	[[SGCopyLinkCommand functorWithObject : resURL_] execute : self];
}

#pragma mark Deletion

- (BOOL) forceDeleteThreadAtPath : (NSString *) filepath alsoReplyFile : (BOOL) deleteReply
{
	if (NO == [[NSFileManager defaultManager] fileExistsAtPath : filepath])
		return NO;
	
	NSArray		*filePathArray_;

	filePathArray_ = [NSArray arrayWithObject : filepath];

	if (deleteReply) {
		NSArray		*alsoReplyFile_;		
		alsoReplyFile_ = [[CMRReplyDocumentFileManager defaultManager]
								replyDocumentFilesArrayWithLogsArray : filePathArray_];
		return [[CMRTrashbox trash] performWithFiles : alsoReplyFile_];
	}

	return [[CMRTrashbox trash] performWithFiles : filePathArray_];
}

- (void) checkIfFavItemThenRemove : (NSString *) aPath
{
	CMRFavoritesManager	*favManager = [CMRFavoritesManager defaultManager];
	if ([favManager favoriteItemExistsOfThreadPath : aPath]) {
		[favManager removeFromFavoritesWithFilePath : aPath];
	}
		[favManager addItemToPoolWithFilePath : aPath]; // お気に入り項目でなくてもプールに追加する（削除ステータスを同期させるため）
}

- (IBAction) deleteThread : (id) sender
{
	if ([CMRPref quietDeletion]) {
		NSString	*path_ = [[self path] copy];
		[[self window] performClose : sender];

		if ([self forceDeleteThreadAtPath : path_ alsoReplyFile : YES]) {
			[self checkIfFavItemThenRemove : path_];
		} else {
			NSBeep();
			NSLog(@"Deletion failed : %@", path_);
		}

		[path_ release];

	} else {
		NSAlert *alert_;
		NSString	*tmp_ = [self localizedString : kDeleteThreadTitleKey];
		alert_ = [[NSAlert alloc] init];
		[alert_ setMessageText : [NSString stringWithFormat : tmp_, [self title]]];
		[alert_ setInformativeText : [self localizedString : kDeleteThreadMessageKey]];
		[alert_ addButtonWithTitle : [self localizedString : kDeleteOKBtnKey]];
		[alert_ addButtonWithTitle : [self localizedString : kDeleteCancelBtnKey]];
		if ([CMRPref isOnlineMode]) {
			NSButton	*retryBtn_;		
			retryBtn_ = [alert_ addButtonWithTitle : [self localizedString : kDeleteAndReloadBtnKey]];
			[retryBtn_ setKeyEquivalent : @"r"];
		}

		//NSBeep();
		[alert_ beginSheetModalForWindow : [self window]
						   modalDelegate : self
						  didEndSelector : @selector(_threadDeletionSheetDidEnd:returnCode:contextInfo:)
							 contextInfo : sender];
		[alert_ release];
	}
}

- (void) _threadDeletionSheetDidEnd : (NSAlert *) alert
						 returnCode : (int      ) returnCode
						contextInfo : (void    *) contextInfo
{
	switch(returnCode){
	case NSAlertFirstButtonReturn:
		{
			NSString *path_ = [[self path] copy];

			[[alert window] orderOut : nil]; 
			[[self window] performClose : contextInfo];

			if ([self forceDeleteThreadAtPath : path_ alsoReplyFile : YES]) {
				[self checkIfFavItemThenRemove : path_];
			} else {
				NSBeep();
				NSLog(@"Deletion failed : %@", path_);
			}
			[path_ release];
		}
		break;
	case NSAlertThirdButtonReturn:
		{
			NSString *path_ = [[self path] copy];
			if ([self forceDeleteThreadAtPath : path_ alsoReplyFile : NO]) {
				[self reloadAfterDeletion : path_];
			} else {
				NSBeep();
				NSLog(@"Deletion failed : %@\n...So reloading operation has been canceled.", path_);
			}
			[path_ release];
		}
		break;
	default:
		break;
	}
}

#pragma mark Other IBActions

// AA
- (IBAction) toggleAAThread : (id) sender
{
	[self setAAThread : ![self isAAThread]];
}
- (IBAction) toggleDatOchiThread : (id) sender
{
	[self setDatOchiThread : ![self isDatOchiThread]];
}
- (IBAction) toggleMarkedThread : (id) sender
{
	[self setMarkedThread : ![self isMarkedThread]];
}

// Save window frame
- (IBAction) saveAsDefaultFrame : (id) sender;
{
	[CMRPref setWindowDefaultFrameString : [[self window] stringWithSavedFrame]];
}

- (void) quoteWithMessenger : (CMRReplyMessenger *) aMessenger
{
	unsigned		index_;
	NSRange			selectedRange_;
	NSString		*contents_;
	
	// 引用
	if ([[aMessenger replyMessage] length] != 0)
		return;
	
	selectedRange_ = [[self textView] selectedRange];
	if (0 == selectedRange_.length) return;
	index_ = [[self threadLayout] messageIndexForRange : selectedRange_];
	if (NSNotFound == index_) return;
	
	contents_ = [[[self textView] string] substringWithRange : selectedRange_];
	[aMessenger setMessageContents:contents_ replyTo:index_];
}

- (IBAction) reply : (id) sender
{
	NSEnumerator		*iter_;
	NSArray				*selectedThreads_;
	NSDictionary		*threadAttributes_;
	
	selectedThreads_ = [self selectedThreads];
	iter_ = [selectedThreads_ objectEnumerator];
	while ((threadAttributes_ = [iter_ nextObject])) {
		CMRReplyMessenger		*document_;
		NSDocumentController	*docc_;
		NSString				*filepath_;
		NSString				*reppath_;
		
		docc_ = [NSDocumentController sharedDocumentController];
		filepath_ =  [CMRThreadAttributes pathFromDictionary : threadAttributes_];
		reppath_ = [[CMRReplyDocumentFileManager defaultManager]
						replyDocumentFilepathWithLogPath : filepath_];
		document_ = [docc_ documentForFileName : reppath_];
		if (document_ != nil) {
			[document_ showWindows];
			continue;
		}
		
		if ([filepath_ isSameAsString : [self path]]) {
			document_ = [self messenger : YES];
			[self addMessenger : document_];
			[self quoteWithMessenger : document_];
		}
	}
}

- (IBAction) openInBrowser : (id) sender
{
	NSArray				*selectedThreads_;
	
	selectedThreads_ = [self selectedThreadsReallySelected];
	if (0 == [selectedThreads_ count]) {
		if (nil == [self threadURL]) {
			return;
		}
		selectedThreads_ = [self selectedThreads];
	}
	
	[self openThreadsInBrowser : selectedThreads_];
}
- (IBAction) openBBSInBrowser : (id) sender
{
	NSEnumerator		*Iter_;
	NSDictionary		*threadAttributes_;
	
	Iter_ = [[self selectedThreadsReallySelected] objectEnumerator];
	while ((threadAttributes_ = [Iter_ nextObject])) {
		NSURL			*boardURL_;
		
		boardURL_ =  [CMRThreadAttributes boardURLFromDictionary : threadAttributes_];
		[[NSWorkspace sharedWorkspace] openURL : boardURL_ inBackGround : [CMRPref openInBg]];
	}
}

- (IBAction) openLogfile : (id) sender
{
	NSArray				*selectedThreads_;
	
	selectedThreads_ = [self selectedThreadsReallySelected];
	if (0 == [selectedThreads_ count]) {
		if (nil == [self threadURL]) {
			return;
		}
		selectedThreads_ = [self selectedThreads];
	}
	
	[self openThreadsLogFiles: selectedThreads_];
}

- (IBAction) addFavorites : (id) sender
{
	NSEnumerator			*Iter_;
	NSDictionary			*threadAttributes_;
	CMRFavoritesOperation	operation_;
	NSArray *selectedThreads_;
	
	selectedThreads_ = [self selectedThreads];
	operation_ = [self favoritesOperationForThreads : selectedThreads_];
	if (CMRFavoritesOperationNone == operation_)
		return;
	
	Iter_ = [selectedThreads_ objectEnumerator];
	while ((threadAttributes_ = [Iter_ nextObject])) {
		NSString			*path_;
		
		path_ = [CMRThreadAttributes pathFromDictionary : threadAttributes_];
		
		UTILAssertNotNil(path_);
		if (CMRFavoritesOperationLink == operation_)
			if([threadAttributes_ count] < 6) {
				// Maybe added from separate document window.
				[[CMRFavoritesManager defaultManager] addFavoriteWithFilePath : path_];
			} else {
				// Maybe added from browser or 3-pain viewer.
				[[CMRFavoritesManager defaultManager] addFavoriteWithThread : threadAttributes_];
			}
		else
			[[CMRFavoritesManager defaultManager] removeFromFavoritesWithFilePath : path_];
	}
}
- (IBAction) toggleOnlineMode : (id) sender
{
	[CMRPref toggleOnlineMode : sender];
}

- (void) updateVisibleRange
{
	CMRThreadVisibleRange	*visibleRange_;
	NSNumber				*number_;
	unsigned				firstLength_, lastLength_;
	
	number_ = [[[self firstVisibleRangePopUpButton] selectedItem] representedObject];
	UTILAssertKindOfClass(number_, NSNumber);
	firstLength_ = [number_ unsignedIntValue];
	
	number_ = [[[self lastVisibleRangePopUpButton] selectedItem] representedObject];
	UTILAssertKindOfClass(number_, NSNumber);
	lastLength_ = [number_ unsignedIntValue];
	
	visibleRange_ = [CMRThreadVisibleRange 
						visibleRangeWithFirstVisibleLength : firstLength_
						lastVisibleLength : lastLength_];
	
	[[self threadAttributes] setVisibleRange : visibleRange_];
	if ([self synchronize])
		[self loadFromContentsOfFile : [self path]];
}
- (IBAction) selectFirstVisibleRange : (id) sender
{
	[self updateVisibleRange];
}
- (IBAction) selectLastVisibleRange : (id) sender
{
	[self updateVisibleRange];
}

- (IBAction) launchBWAgent : (id) sender
{
	NSBundle* mainBundle;
    NSString* fileName;

    mainBundle = [NSBundle mainBundle];
    fileName = [mainBundle pathForResource:@"BWAgent" ofType:@"app"];
	
    [[NSWorkspace sharedWorkspace] launchApplication:fileName];
}
// make text area to be first responder
- (IBAction) focus : (id) sender
{
    [[self window] makeFirstResponder : 
        [[self textView] enclosingScrollView]];
}

#pragma mark Available in SledgeHammer and Later

- (IBAction) orderFrontMainBrowser : (id) sender
{
	if (CMRMainBrowser != nil) {
		[[CMRMainBrowser window] makeKeyAndOrderFront : sender];
	}
}
@end
