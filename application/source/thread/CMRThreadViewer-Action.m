//
//  CMRThreadViewer-Action.m
//  BathyScaphe
//
//  Updated by Tsutomu Sawada on 07/10/13.
//  Copyright 2005-2007 BathyScaphe Project. All rights reserved.
//  encoding="UTF-8"
//

#import "CMRThreadViewer_p.h"

#import "CMRThreadsList.h"
#import "SGLinkCommand.h"
#import "CMRReplyMessenger.h"
#import "CMRReplyDocumentFileManager.h"
#import "CMRThreadVisibleRange.h"
#import "CMRThreadDownloadTask.h"
#import "CMXPopUpWindowManager.h"
#import "BSBoardInfoInspector.h"
#import "TextFinder.h"

#import "CMRSpamFilter.h"
#import "BSNGExpression.h"

// for debugging only
#define UTIL_DEBUGGING		0
#import "UTILDebugging.h"

@implementation CMRThreadViewer(ActionSupport)
- (CMRReplyMessenger *)replyMessenger
{
	UTILAssertNotNil([self path]);
	CMRReplyMessenger *document;

	NSDocumentController *docController = [NSDocumentController sharedDocumentController];
	CMRReplyDocumentFileManager *replyDocManager = [CMRReplyDocumentFileManager defaultManager];

	NSString *replyDocPath = [replyDocManager replyDocumentFilepathWithLogPath:[self path]];

	document = [docController documentForFileName:replyDocPath];
	if (document) return document;

	[replyDocManager createDocumentFileIfNeededAtPath:replyDocPath contentInfo:[self selectedThread]];
	document = [docController openDocumentWithContentsOfFile:replyDocPath display:YES];
	if (document) {
		[self addMessenger:document];
		return document;
	}

	// Error while creating CMRReplyMessenger instance.
	return nil;
}

/*- (CMRReplyMessenger *)messenger:(BOOL)create
{
	NSDocumentController		*docc_;
	CMRReplyDocumentFileManager	*replyMgr_;
	CMRReplyMessenger			*document_;
	NSString					*reppath_;
	
	docc_ = [NSDocumentController sharedDocumentController];
	replyMgr_ = [CMRReplyDocumentFileManager defaultManager];
	reppath_ = [replyMgr_ replyDocumentFilepathWithLogPath : [self path]];
	document_ = [docc_ documentForFileName:reppath_];

	if (document_ || !create) {
		return document_;
	}

	[replyMgr_ createDocumentFileIfNeededAtPath:reppath_ contentInfo:[self selectedThread]];

	document_ = [docc_ openDocumentWithContentsOfFile:reppath_ display:YES];
	return document_;
}*/

- (void)addMessenger:(CMRReplyMessenger *)aMessenger
{
	[[NSNotificationCenter defaultCenter]
		addObserver:self
		   selector:@selector(replyMessengerDidFinishPosting:)
			   name:CMRReplyMessengerDidFinishPostingNotification
			 object:aMessenger];
}

- (void)replyMessengerDidFinishPosting:(NSNotification *)aNotification
{
	NSSound		*replyFinishedSound;
	NSString	*replyFinishedSoundName;

	UTILAssertNotificationName(aNotification, CMRReplyMessengerDidFinishPostingNotification);

	replyFinishedSoundName = [CMRPref replyDidFinishSound];
	if (replyFinishedSoundName && ![replyFinishedSoundName isEqualToString:@""]) {
		replyFinishedSound = [NSSound soundNamed:replyFinishedSoundName];
	} else {
		replyFinishedSound = nil;
	}
	
	[replyFinishedSound play];

	[self reloadIfOnlineMode:nil];
}

- (void)removeMessenger:(CMRReplyMessenger *)aMessenger
{
	[[NSNotificationCenter defaultCenter]
		removeObserver:self
				  name:CMRReplyMessengerDidFinishPostingNotification
			    object:aMessenger];
}

- (void)openThreadsInThreadWindow:(NSArray *)threads
{
	// subclass should override this method
}

- (void)openThreadsInBrowser:(NSArray *)threads
{
	NSEnumerator		*Iter_;
	NSDictionary		*threadAttributes_;
	
	Iter_ = [threads objectEnumerator];
	while (threadAttributes_ = [Iter_ nextObject]) {
		NSURL	*url_;
		url_ = [CMRThreadAttributes threadURLWithDefaultParameterFromDictionary:threadAttributes_];
		[[NSWorkspace sharedWorkspace] openURL:url_ inBackGround:[CMRPref openInBg]];
	}
}
@end


@implementation CMRThreadViewer(Action)
- (NSArray *)targetThreadsForAction:(SEL)action
{
	return [self selectedThreads];
}

#pragma mark Reloading thread
- (void)reloadThread
{
	[self downloadThread:[[self threadAttributes] threadSignature]
				   title:[self title]
			   nextIndex:[[self threadLayout] numberOfReadedMessages]];
}
- (IBAction)reloadThread:(id)sender
{
	NSEnumerator		*Iter_;
	NSDictionary		*threadAttributes_;

    Iter_ = [[self targetThreadsForAction:_cmd] objectEnumerator];
	while (threadAttributes_ = [Iter_ nextObject]) {
		NSString			*path_;
		NSString			*title_;
		unsigned int		curNumOfMsgs_;
		CMRThreadSignature	*threadSignature_;
		
		path_ =  [CMRThreadAttributes pathFromDictionary:threadAttributes_];
		title_ = [threadAttributes_ objectForKey:CMRThreadTitleKey];
		curNumOfMsgs_ = [threadAttributes_ unsignedIntForKey:CMRThreadLastLoadedNumberKey];
		threadSignature_ = [CMRThreadSignature threadSignatureFromFilepath:path_];

		if ([[self threadIdentifier] isEqual:threadSignature_]) {
			if ([self checkCanGenarateContents]) {
				[self reloadThread];
			}
			continue;
		}

		[self downloadThread:threadSignature_ title:title_ nextIndex:curNumOfMsgs_];
	}
}

- (IBAction)reloadIfOnlineMode:(id)sender
{
	id<CMRThreadLayoutTask>		task;
	
	if (![CMRPref isOnlineMode] || ![self shouldShowContents]) return;

	task = [[CMRThreadDownloadTask alloc] initWithThreadViewer:self];
	[[self threadLayout] push:task];
	[task release];
}

#pragma mark Copy Thread Info
- (NSPoint)locationForInformationPopUp
{
	id			docView_;
	NSPoint		loc;
	
	docView_ = [[self textView] enclosingScrollView];
	docView_ = [docView_ contentView];
	
	loc = [docView_ frame].origin;
	loc.y = NSMaxY([docView_ frame]);
	
	docView_ = [[self textView] enclosingScrollView];
	loc = [docView_ convertPoint:loc toView:nil];
	loc = [[docView_ window] convertBaseToScreen:loc];
	return loc;
}

- (IBAction)copyThreadAttributes:(id)sender
{
	NSArray *array_ = [self targetThreadsForAction:_cmd];

	NSMutableString	*tmp;
	NSURL			*url_ = nil;
	NSPasteboard	*pboard_ = [NSPasteboard generalPasteboard];
	NSArray			*types_;
	
	tmp = SGTemporaryString();

	[CMRThreadAttributes fillBuffer:tmp withThreadInfoForCopying:array_];
	url_ = [CMRThreadAttributes threadURLFromDictionary:[array_ lastObject]];
	
	types_ = [NSArray arrayWithObjects:NSURLPboardType, NSStringPboardType, nil];
	[pboard_ declareTypes:types_ owner:nil];
	
	[url_ writeToPasteboard:pboard_];
	[pboard_ setString:tmp forType:NSStringPboardType];
	
	[tmp deleteCharactersInRange:[tmp range]];
}

- (IBAction)copySelectedResURL:(id)sender
{
	NSRange			selectedRange_;
	unsigned		index_;
	unsigned		last_;

	NSURL			*resURL_;
	CMRHostHandler	*handler_;
	
	if (![self threadAttributes]) return;
	selectedRange_ = [[self textView] selectedRange];
	if (selectedRange_.length == 0) return;
	
	handler_ = [CMRHostHandler hostHandlerForURL:[self boardURL]];
	if (!handler_) return;
	
	index_ = [[self threadLayout] messageIndexForRange:selectedRange_];
	last_ = [[self threadLayout] lastMessageIndexForRange:selectedRange_];
	if (NSNotFound == index_ || NSNotFound == last_) {
		NSBeep();
		return;
	}
	
	index_++;
	last_++;
	resURL_ = [handler_ readURLWithBoard:[self boardURL] datName:[self datIdentifier] start:index_ end:last_ nofirst:NO];
	if (!resURL_) return;
	
	[[SGCopyLinkCommand functorWithObject:resURL_] execute:self];
}

#pragma mark Deletion
- (BOOL)forceDeleteThreadAtPath:(NSString *)filepath alsoReplyFile:(BOOL)deleteReply
{
	if (![[NSFileManager defaultManager] fileExistsAtPath:filepath]) return NO;
	
	NSArray		*filePathArray_;

	filePathArray_ = [NSArray arrayWithObject:filepath];

	if (deleteReply) {
		NSArray		*alsoReplyFile_;		
		alsoReplyFile_ = [[CMRReplyDocumentFileManager defaultManager] replyDocumentFilesArrayWithLogsArray:filePathArray_];
		return [[CMRTrashbox trash] performWithFiles:alsoReplyFile_ fetchAfterDeletion:NO];
	}

	return [[CMRTrashbox trash] performWithFiles:filePathArray_ fetchAfterDeletion:YES];
}

- (IBAction)deleteThread:(id)sender
{
	if ([CMRPref quietDeletion]) {
		NSString	*path_ = [[self path] copy];
		[[self window] performClose:sender];

		if (![self forceDeleteThreadAtPath:path_ alsoReplyFile:YES]) {
			NSBeep();
			NSLog(@"Deletion failed : %@", path_);
		}

		[path_ release];
	} else {
		NSAlert *alert_;
		NSString	*tmp_ = [self localizedString:kDeleteThreadTitleKey];
		alert_ = [[[NSAlert alloc] init] autorelease];
		[alert_ setMessageText:[NSString stringWithFormat:tmp_, [self title]]];
		[alert_ setInformativeText:[self localizedString:kDeleteThreadMessageKey]];
		[alert_ addButtonWithTitle:[self localizedString:kDeleteOKBtnKey]];
		[alert_ addButtonWithTitle:[self localizedString:kDeleteCancelBtnKey]];
		if ([CMRPref isOnlineMode]) {
			NSButton	*retryBtn_;		
			retryBtn_ = [alert_ addButtonWithTitle:[self localizedString:kDeleteAndReloadBtnKey]];
			[retryBtn_ setKeyEquivalent:@"r"];
		}

		[alert_ beginSheetModalForWindow:[self window]
						   modalDelegate:self
						  didEndSelector:@selector(threadDeletionSheetDidEnd:returnCode:contextInfo:)
							 contextInfo:sender];
	}
}

- (void)threadDeletionSheetDidEnd:(NSAlert *)alert
					   returnCode:(int)returnCode
					  contextInfo:(void*)contextInfo
{
	switch (returnCode) {
		case NSAlertFirstButtonReturn:
		{
			NSString *path_ = [[self path] copy];

			[[alert window] orderOut:nil]; 
			[[self window] performClose:nil];

			if (![self forceDeleteThreadAtPath:path_ alsoReplyFile:YES]) {
				NSBeep();
				NSLog(@"Deletion failed : %@", path_);
			}
			[path_ release];
		}
		break;
		case NSAlertThirdButtonReturn:
		{
			NSString *path_ = [[self path] copy];
			if (![self forceDeleteThreadAtPath:path_ alsoReplyFile:NO]) {
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
/* NOTE: It is a history item's action. */	 
- (IBAction)showThreadWithMenuItem:(id)sender
{
	id historyItem = nil;

	if ([sender respondsToSelector:@selector(representedObject)]) {
		id o = [sender representedObject];
		historyItem = o;
	}

	[self setThreadContentWithThreadIdentifier:historyItem];
}

// Save window frame
- (IBAction)saveAsDefaultFrame:(id)sender
{
	[CMRPref setWindowDefaultFrameString:[[self window] stringWithSavedFrame]];
}

- (void)quoteWithMessenger:(CMRReplyMessenger *)aMessenger
{
	unsigned		index_;
	NSRange			selectedRange_;
	NSString		*contents_;
	
	// 引用
	if ([[aMessenger replyMessage] length] != 0) return;
	
	selectedRange_ = [[self textView] selectedRange];
	if (0 == selectedRange_.length) return;
	index_ = [[self threadLayout] messageIndexForRange:selectedRange_];
	if (NSNotFound == index_) return;
	
	contents_ = [[[self textView] string] substringWithRange:selectedRange_];
	[aMessenger setMessageContents:contents_ replyTo:index_];
}

- (IBAction)reply:(id)sender
{
/*	NSEnumerator		*iter_;
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
		filepath_ =  [CMRThreadAttributes pathFromDictionary:threadAttributes_];
		reppath_ = [[CMRReplyDocumentFileManager defaultManager]
						replyDocumentFilepathWithLogPath:filepath_];
		document_ = [docc_ documentForFileName:reppath_];
		if (document_) {
			[document_ showWindows];
			continue;
		}

		if ([filepath_ isSameAsString:[self path]]) {
			document_ = [self messenger:YES];
			[self addMessenger:document_];
			[self quoteWithMessenger:document_];
		}
	}*/
	if (![self path]) return;
	CMRReplyMessenger *document = [self replyMessenger];

	if (!document) {
		NSBeep();
		NSLog(@"ERROR! CMRThreadViewer: -reply: Can't create CMRReplyMessenger instance.");
		return;
	}

	[document showWindows];
//	[self addMessenger:document];
	[self quoteWithMessenger:document];
}

- (IBAction)openBBSInBrowser:(id)sender
{
	NSEnumerator		*Iter_;
	NSDictionary		*threadAttributes_;
	
	Iter_ = [[self selectedThreadsReallySelected] objectEnumerator];
	while (threadAttributes_ = [Iter_ nextObject]) {
		NSURL			*boardURL_;
		
		boardURL_ =  [CMRThreadAttributes boardURLFromDictionary:threadAttributes_];
		[[NSWorkspace sharedWorkspace] openURL:boardURL_ inBackGround:[CMRPref openInBg]];
	}
}

- (IBAction)openInBrowser:(id)sender
{
	[self openThreadsInBrowser:[self targetThreadsForAction:_cmd]];
}

- (IBAction)addFavorites:(id)sender
{
	NSEnumerator			*Iter_;
	NSDictionary			*threadAttributes_;
	NSArray *selectedThreads_;
	
	CMRFavoritesManager		*fM_ = [CMRFavoritesManager defaultManager];
	
	selectedThreads_ = [self targetThreadsForAction:_cmd];
	
	Iter_ = [selectedThreads_ objectEnumerator];
	while (threadAttributes_ = [Iter_ nextObject]) {
		CMRFavoritesOperation	operation_;
		NSString *path_ = [CMRThreadAttributes pathFromDictionary:threadAttributes_];
		UTILAssertNotNil(path_);

		CMRThreadSignature *signature_ = [CMRThreadSignature threadSignatureFromFilepath:path_];
		UTILAssertNotNil(signature_);
		
		operation_ = [fM_ availableOperationWithSignature:signature_];
		if (CMRFavoritesOperationNone == operation_) {
			continue;	
		} else if (CMRFavoritesOperationLink == operation_) {
			[fM_ addFavoriteWithSignature:signature_];

		} else {
			[fM_ removeFromFavoritesWithSignature:signature_];
		}
	}
}
// make text area to be first responder
- (IBAction)focus:(id)sender
{
    [[self window] makeFirstResponder:[[self textView] enclosingScrollView]];
}

// Available in Twincam Angel and later.
- (BOOL)checkIfUsesCorpusOptionOn
{
	if ([CMRPref usesSpamMessageCorpus]) {
		return YES;
	} else {
		NSAlert *alert = [[[NSAlert alloc] init] autorelease];
		[alert setAlertStyle:NSWarningAlertStyle];
		[alert setMessageText:[self localizedString:@"Corpus Off Alert Title"]];
		[alert setInformativeText:[self localizedString:@"Corpus Off Alert Msg"]];
		[alert addButtonWithTitle:[self localizedString:@"Corpus Off Turn On Btn"]];
		[alert addButtonWithTitle:[self localizedString:@"Corpus Off Keep Off Btn"]];
		[alert setShowsHelp:YES];
		[alert setHelpAnchor:@"bs_pref_filter"];
		if ([alert runModal] == NSAlertFirstButtonReturn) {
			[CMRPref setUsesSpamMessageCorpus:YES];
			return YES;
		}
		return NO;
	}
}

- (IBAction)addToNGWords:(id)sender
{
	NSRange			selectedRange_ = [[self textView] selectedRange];
	NSString		*string_;
	BSNGExpression	*exp;
	
	string_ = [[[self textView] string] substringWithRange:selectedRange_];
	if (!string_ || [string_ isEmpty]) return;

	if (![[self threadLayout] onlySingleMessageInRange:selectedRange_]) return;

	if ([string_ rangeOfString:@"\n" options:NSLiteralSearch].length != 0) {
		NSAlert *alert = [[[NSAlert alloc] init] autorelease];
		[alert setAlertStyle:NSWarningAlertStyle];
		[alert setMessageText:[NSString stringWithFormat:[self localizedString:@"Corpus Multiple Line Alert Title"],string_]];
		[alert setInformativeText:[self localizedString:@"Corpus Multiple Line Alert Msg"]];
		NSBeep();
		[alert runModal];
		return;
	}

	exp = [[BSNGExpression alloc] initWithExpression:string_ targetMask:BSNGExpressionAtAll regularExpression:NO];
	if ([[[CMRSpamFilter sharedInstance] spamCorpus] containsObject:exp]) {
		NSAlert *alert = [[[NSAlert alloc] init] autorelease];
		[alert setAlertStyle:NSWarningAlertStyle];
		[alert setMessageText:[NSString stringWithFormat:[self localizedString:@"Corpus Duplicated Alert Title"],string_]];
		[alert setInformativeText:[self localizedString:@"Corpus Duplicated Alert Msg"]];
		NSBeep();
		[alert runModal];
		[exp release];
		return;
	}
	
	[[CMRSpamFilter sharedInstance] addNGExpression:exp];
	[exp release];

	if ([self checkIfUsesCorpusOptionOn]) {
		SystemSoundPlay(1);
		[self performSelector:@selector(askIfSpamFilterShouldBeRunImmediately:) withObject:self afterDelay:0.5];
	}	
}

- (IBAction)askIfSpamFilterShouldBeRunImmediately:(id)sender
{
	NSAlert *alert = [[[NSAlert alloc] init] autorelease];
	[alert setAlertStyle:NSWarningAlertStyle];
	[alert setMessageText:[self localizedString:@"Corpus Run Filter Alert Title"]];
	[alert addButtonWithTitle:[self localizedString:@"Corpus Run Filter Do Btn"]];
	[alert addButtonWithTitle:[self localizedString:@"Corpus Run Filter No Btn"]];
	[alert beginSheetModalForWindow:[self window]
					  modalDelegate:self
					 didEndSelector:@selector(spamFilterAlertDidEnd:returnCode:contextInfo:)
						contextInfo:nil];
}

- (void)spamFilterAlertDidEnd:(NSAlert *)alert returnCode:(int)returnCode contextInfo:(void *)contextInfo
{
	if (returnCode == NSAlertFirstButtonReturn) {
		[self runSpamFilter:nil];
	}
}

- (IBAction)showBoardInspectorPanel:(id)sender
{
	NSString			*board;
	
	board = [self boardNameArrowingSecondSource];

	[[BSBoardInfoInspector sharedInstance] showInspectorForTargetBoard:board];
}

- (IBAction)extractUsingSelectedText:(id)sender
{
	static NSArray *targets = nil;
	
	NSRange			selectedRange_ = [[self textView] selectedRange];
	NSString		*string_;
	TextFinder		*textFinder = [TextFinder standardTextFinder];
	
	string_ = [[[self textView] string] substringWithRange:selectedRange_];
	if (!string_ || [string_ isEmpty]) return;

	if (![[self threadLayout] onlySingleMessageInRange:selectedRange_]) return;

	if ([string_ rangeOfString:@"\n" options:NSLiteralSearch].length != 0) return;

	if (!targets) {
		NSNumber *trueNumber = [NSNumber numberWithBool:YES];
		NSNumber *falseNumber = [NSNumber numberWithBool:NO];
		targets = [[NSArray alloc] initWithObjects:trueNumber,trueNumber,falseNumber,falseNumber,trueNumber,nil];
	}
	[textFinder setFindString:string_];
//	[textFinder setUsesRegularExpression:NO];
	[textFinder setSearchTargets:targets display:YES];

	[self findAllByFilter:sender];
}

#pragma mark Scaling Text View
- (void)scaleTextView:(float)rate
{
	NSClipView *clipView_ = [[self scrollView] contentView];
	NSTextView *textView_ = [self textView];

	unsigned int curIndex = [[self threadLayout] messageIndexForDocuemntVisibleRect];

	NSSize	curBoundsSize = [clipView_ bounds].size;	
	NSSize	curFrameSize = [textView_ frame].size;

	[clipView_ setBoundsSize:NSMakeSize(curBoundsSize.width*rate, curBoundsSize.height*rate)];
	[textView_ setFrameSize:NSMakeSize(curFrameSize.width*rate, curFrameSize.height*rate)];

	[clipView_ setNeedsDisplay:YES]; // really need?

	[clipView_ setCopiesOnScroll:NO]; // これがキモ
	[[self threadLayout] scrollMessageAtIndex:curIndex]; // スクロール位置補正

	// テキストビューやクリップビューだけ再描画させても良さそうだが、
	// 時々ツールバーとの境界線が消えてしまうことがあるので、ウインドウごと再描画させる
	[[self window] display]; 
	[clipView_ setCopiesOnScroll:YES];
}

- (IBAction)biggerText:(id)sender
{
	[self scaleTextView: 0.8];
}

- (IBAction)smallerText:(id)sender
{
	[self scaleTextView: 1.25];
}

- (IBAction)scaleSegmentedControlPushed:(id)sender
{
	int	i;
	i = [sender selectedSegment];

	if (i == -1) {
		NSLog(@"No selection?");
	} else if (i == 1) {
		[self biggerText:nil];
	} else {
		[self smallerText:nil];
	}
}
@end
