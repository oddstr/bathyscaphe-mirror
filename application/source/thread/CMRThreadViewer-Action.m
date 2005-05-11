/**
  * $Id: CMRThreadViewer-Action.m,v 1.1 2005/05/11 17:51:07 tsawada2 Exp $
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

#import "JStringAdditions.h"
#import "CMRSearchOptions.h"
#import "TextFinder.h"
#import "CMRThreadView.h"
#import "CMXTemplateResources.h"
#import "CMRHistoryManager.h"

#import "CMXPopUpWindowManager.h"
#import "CMRAttributedMessageComposer.h"


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
	
	return ([[CMRFavoritesManager defaultManager] avalableOperationWithPath : path_]);
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
	
	[replyMgr_ createDocumentFileIfNeededAtPath : reppath_
					contentInfo : [self selectedThread]];
	document_ = [docc_ openDocumentWithContentsOfFile : reppath_
											  display : YES];
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
	UTILAssertNotificationName(
		aNotification,
		CMRReplyMessengerDidFinishPostingNotification);

	[self reloadIfOnlineMode : nil];
}
- (void) removeMessenger : (CMRReplyMessenger *) aMessenger
{
	[[NSNotificationCenter defaultCenter]
			 removeObserver : self
					   name : CMRReplyMessengerDidFinishPostingNotification
					 object : aMessenger];
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
/*
 * RELOAD THREAD
 */
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
		CMRThreadSignature	*threadSignature_;
		
		path_ =  [CMRThreadAttributes pathFromDictionary : threadAttributes_];
		title_ = [threadAttributes_ objectForKey : CMRThreadTitleKey];
		threadSignature_ = [CMRThreadSignature threadSignatureFromFilepath : path_];
		
		if ([[self threadIdentifier] isEqual : threadSignature_]) {
			if ([self checkCanGenarateContents])
				[self reloadThread];
			
			continue;
		}
		
		[self downloadThread : threadSignature_
					   title : title_
				   nextIndex : NSNotFound];
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

#pragma mark -

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

	template_ = CMXTemplateResource(kCopyThreadFormatKey, nil);
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

/* NOTE: It is a history item's action. */
- (IBAction) showThreadWithMenuItem : (id) sender
{
    id historyItem = nil;
    
    if ([sender respondsToSelector : @selector(representedObject)]) {
        id o = [sender representedObject];
        
        if (nil == o || NO == [o isKindOfClass : [CMRHistoryItem class]]) {
            UTILDebugWrite1(
              @"[WARN] [sender representedObject] must be an instance"
              @" of CMRHistoryItem."
              @" at %@", UTIL_HANDLE_FAILURE_IN_METHOD);
            return;
        }
        historyItem = o;
    }
    // make text area first responder
    [self setThreadContentWithThreadIdentifier : 
        [historyItem representedObject]];
    [self focus : sender];
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

// AA
- (IBAction) toggleAAThread : (id) sender
{
	[self setAAThread : ![self isAAThread]];
}

// Save window frame
- (IBAction) saveAsDefaultFrame : (id) sender;
{
	[CMRPref setWindowDefaultFrameString : [[self window] stringWithSavedFrame]];
}

#pragma mark -

// delete thread log file
- (void) forceDeleteThreadAtPath : (NSString *) filepath
{
	if (NO == [[NSFileManager defaultManager] fileExistsAtPath:filepath])
		return;
	
	NSArray		*alsoReplyFile_;
	NSArray		*filePathArray_;
	
	filePathArray_ = [NSArray arrayWithObject : filepath];
		
	alsoReplyFile_ = [[CMRReplyDocumentFileManager defaultManager]
							replyDocumentFilesArrayWithLogsArray : filePathArray_];
		
	[[CMRTrashbox trash] performWithFiles : alsoReplyFile_];
}
- (IBAction) forceDeleteThread : (id) sender
{
	NSString *thePath_ = [self path];

	[[self window] performClose : sender];
	[self forceDeleteThreadAtPath : thePath_];
}
- (IBAction) deleteThread : (id) sender
{
	if ([CMRPref quietDeletion]) {
		[self forceDeleteThread : sender];
	} else {
		NSBeep();
		NSBeginAlertSheet(
		[self localizedString : kDeleteThreadTitleKey],
		[self localizedString : kDeleteOKBtnKey],
		[self localizedString : kDeleteCancelBtnKey],
		nil,
		[self window],
		self,
		NULL,
		@selector(_threadDeletionSheetDidDismiss:returnCode:contextInfo:),
		sender,
		[self localizedString : kDeleteThreadMessageKey]);
	}
}

/* 2004-12-13 tsawada2
	スレッド削除では、SheetDidEndではなく、SheetDidDismissのタイミングでforceDeleteThread:を
	呼び出さなければいけないだろう。なぜなら、forceDeleteThread:ではスレのウインドウを閉じる動作が含まれる。
	しかし、SheetDidEndのタイミングで呼ぶと、ウインドウを閉じることが出来ない（まだシートが消えていないから！）のだ。
*/
- (void) _threadDeletionSheetDidDismiss : (NSWindow *) sheet
							 returnCode : (int       ) returnCode
							contextInfo : (void     *) contextInfo
{
	switch(returnCode){
	case NSAlertDefaultReturn:
		[self forceDeleteThread : contextInfo];
		break;
	default:
		break;
	}
}

#pragma mark -

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
	NSEnumerator		*Iter_;
	NSDictionary		*threadAttributes_;
	
	int aType = [CMRPref openInBrowserType];
	
	Iter_ = [[self selectedThreads] objectEnumerator];
	while ((threadAttributes_ = [Iter_ nextObject])) {
		NSURL			*boardURL_;
		
		switch(aType)
		{
		case 0:
			boardURL_ =  [CMRThreadAttributes threadURLFromDictionary : threadAttributes_ withParamStr : @"l50"];
			break;
		case 1:
			boardURL_ =  [CMRThreadAttributes threadURLFromDictionary : threadAttributes_ withParamStr : @"-100"];
			break;
		default:
			boardURL_ =  [CMRThreadAttributes threadURLFromDictionary : threadAttributes_];
		}
		[[NSWorkspace sharedWorkspace] openURL : boardURL_ inBackGround : [CMRPref openInBg]];
	}
}
- (IBAction) openBBSInBrowser : (id) sender
{
	NSEnumerator		*Iter_;
	NSDictionary		*threadAttributes_;
	
	Iter_ = [[self selectedThreads] objectEnumerator];
	while ((threadAttributes_ = [Iter_ nextObject])) {
		NSURL			*boardURL_;
		
		boardURL_ =  [CMRThreadAttributes boardURLFromDictionary : threadAttributes_];
		[[NSWorkspace sharedWorkspace] openURL : boardURL_ inBackGround : [CMRPref openInBg]];
	}
}

- (IBAction) openLogfile : (id) sender
{
	NSEnumerator		*Iter_;
	NSDictionary		*threadAttributes_;
	
	Iter_ = [[self selectedThreads] objectEnumerator];
	while ((threadAttributes_ = [Iter_ nextObject])) {
		NSString			*filepath_;
		
		filepath_ =  [CMRThreadAttributes pathFromDictionary : threadAttributes_];
		[[NSWorkspace sharedWorkspace]
					openFile : filepath_
			 withApplication : @"Property List Editor.app"];
	}
}

- (IBAction) addFavorites : (id) sender
{
	NSEnumerator			*Iter_;
	NSDictionary			*threadAttributes_;
	CMRFavoritesOperation	operation_;
	
	operation_ = [self favoritesOperationForThreads : [self selectedThreads]];
	if (CMRFavoritesOperationNone == operation_)
		return;
	
	Iter_ = [[self selectedThreads] objectEnumerator];
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

- (IBAction) customizeBrdListTable : (id) sender
{
	[[CMRPref sharedBoardListEditor] showWindow : sender];
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
@end
