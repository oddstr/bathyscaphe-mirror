//
//  Browser.m
//  BathyScaphe
//
//  Updated by Tsutomu Sawada on 08/02/10.
//  Copyright 2005-2009 BathyScaphe Project. All rights reserved.
//  encoding="UTF-8"
//

#import "Browser.h"

#import "AppDefaults.h"
#import "CMRThreadViewer_p.h"
#import "CMRBrowser_p.h"
#import "CMRThreadsList.h"
#import "CMRThreadAttributes.h"
#import "BoardManager.h"
#import "CMRReplyDocumentFileManager.h"
#import "DatabaseManager.h"
#import "BSNewThreadMessenger.h"

@implementation Browser
- (id)init
{
	if (self = [super init]) {
		[[NSNotificationCenter defaultCenter] addObserver:self
			selector:@selector(updateThreadsListNow:)
				name:DatabaseDidFinishUpdateDownloadedOrDeletedThreadInfoNotification
			  object:[DatabaseManager defaultManager]];
	}
	return self;
}

- (void)updateThreadsListNow:(NSNotification *)notification
{
	[[self currentThreadsList] updateCursor];
}

- (void)dealloc
{	
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	[self setCurrentThreadsList:nil];
	[self setSearchString:nil];

	[super dealloc];
}

- (NSURL *)boardURL
{
	return [[self currentThreadsList] boardURL];
}

- (BSDBThreadList *)currentThreadsList
{
	return m_currentThreadsList;
}

- (void)setCurrentThreadsList:(BSDBThreadList *)aCurrentThreadsList
{
	[aCurrentThreadsList retain];
	[m_currentThreadsList release];
	m_currentThreadsList = aCurrentThreadsList;
}

- (NSString *)searchString
{
	return m_searchString;
}

- (void)setSearchString:(NSString *)text
{
	[text retain];
	[m_searchString release];
	m_searchString = text;
}

- (unsigned int)threadsListViewMode
{
	return [CMRPref threadsListViewMode];
}

- (void)setThreadsListViewMode:(unsigned int)type
{
	[CMRPref setThreadsListViewMode:type];
	[[self currentThreadsList] updateCursor];
}

#pragma mark NSDocument
- (void)makeWindowControllers
{
	CMRBrowser		*browser_;
	
	browser_ = [[CMRBrowser alloc] init];
	[self addWindowController:browser_];
	[browser_ release];
}

- (NSString *)displayName
{
	BSDBThreadList		*list_ = [self currentThreadsList];
	if (!list_) return [super displayName];
	NSString *foo;

	if ([self searchString]) {
		unsigned foundNum = [list_ numberOfFilteredThreads];
		
		if (0 == foundNum) {
			foo = NSLocalizedStringFromTable(kSearchListNotFoundKey, @"ThreadsList", @"");
		} else {
			foo = [NSString stringWithFormat:NSLocalizedStringFromTable(kSearchListResultKey, @"ThreadsList", @""), foundNum];
		}
	} else {
		NSString *base_ = NSLocalizedStringFromTable(@"Browser Title (Thread Mode)", @"ThreadsList", @"");
		if ([[self currentThreadsList] isBoard]) {
			BSThreadsListViewModeType type = [self threadsListViewMode];
			if (type == BSThreadsListShowsStoredLogFiles) {
				base_ = NSLocalizedStringFromTable(@"Browser Title (Log Mode)", @"ThreadsList", @"");
			}
		}
		foo = [NSString stringWithFormat:base_, [list_ numberOfThreads]];
	}

	return [NSString stringWithFormat:@"%@ (%@)", [list_ boardName], foo];
}

- (IBAction)saveDocumentAs:(id)sender
{
	if (![self threadAttributes]) return;

	NSFileManager	*fM_ = [NSFileManager defaultManager];
	NSString *filePath_ = [[self threadAttributes] path];
	if (!filePath_ || ![fM_ fileExistsAtPath:filePath_]) return;

	NSSavePanel *savePanel_ = [NSSavePanel savePanel];
	int			resultCode;

	[savePanel_ setRequiredFileType:CMRThreadDocumentPathExtension];
	[savePanel_ setCanCreateDirectories:YES];
	[savePanel_ setCanSelectHiddenExtension:YES];

	resultCode = [savePanel_ runModalForDirectory:nil file:[filePath_ lastPathComponent]];

	if (resultCode == NSFileHandlingPanelOKButton) {
		NSString *savePath_ = [savePanel_ filename];
		if ([fM_ copyPath:filePath_ toPath:savePath_ handler:nil]) {
			NSDate	*curDate_ = [NSDate date];
			NSDictionary *tmp_;
			tmp_ = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:[savePanel_ isExtensionHidden]], NSFileExtensionHidden,
															  curDate_, NSFileModificationDate, curDate_, NSFileCreationDate, NULL];
			[fM_ changeFileAttributes:tmp_ atPath:savePath_];
		} else {
			NSBeep();
			NSLog(@"Save failure - %@", savePath_);
		}
	}
}

- (BOOL)validateMenuItem:(NSMenuItem *)theItem
{
	SEL action_ = [theItem action];

	if (action_ == @selector(saveDocumentAs:)) {
		[theItem setTitle:NSLocalizedString(@"Save Menu Item Default", @"Save as...")];
		return ([self threadAttributes] != nil);
	} else if (action_ == @selector(cleanupDatochiFiles:)) {
		return [[self currentThreadsList] isBoard] && ([self threadsListViewMode] == BSThreadsListShowsLiveThreads) && ![self searchString];
	} else if (action_ == @selector(showLocalRules:)) {
		BoardManager *bm = [BoardManager defaultManager];
		if ([[self currentThreadsList] isBoard]) {
			BOOL	 isVisible = [bm isKeyWindowForBoardName:[self boardNameAsString]];
			
			[theItem setTitle:isVisible ? NSLocalizedString(@"Hide Local Rules", @"") : NSLocalizedString(@"Show Local Rules", @"")];
			return YES;
		} else {
			[theItem setTitle:NSLocalizedString(@"Show Local Rules", @"")];
			return NO;
		}
	} else if (action_ == @selector(newThread:) || action_ == @selector(rebuildThreadsList:)) {
		return [[self currentThreadsList] isBoard];
	} else if (action_ == @selector(toggleThreadsListViewMode:)) {
		if (![[self currentThreadsList] isBoard]) {
			return NO;
		}
		BSThreadsListViewModeType type = [self threadsListViewMode];
		if (type == BSThreadsListShowsLiveThreads) {
			[theItem setTitle:NSLocalizedStringFromTable(@"Toggle View Mode To Log", @"ThreadsList", @"")];
		} else {
			[theItem setTitle:NSLocalizedStringFromTable(@"Toggle View Mode To Thread", @"ThreadsList", @"")];
		}
		return YES;
	}
	return [super validateMenuItem:theItem];
}

#pragma mark ThreadsList
- (void)reloadThreadsList
{
	[[self currentThreadsList] downloadThreadsList];
}

- (BOOL)searchThreadsInListWithCurrentSearchString
{
	if (![self currentThreadsList]) return NO;

	return [[self currentThreadsList] filterByString:[self searchString]];
}

- (IBAction)toggleThreadsListViewMode:(id)sender
{
	BSThreadsListViewModeType newType;
	BSThreadsListViewModeType type = [self threadsListViewMode];
	if (type == BSThreadsListShowsLiveThreads) {
		newType = BSThreadsListShowsStoredLogFiles;
	} else {
		newType = BSThreadsListShowsLiveThreads;
	}
	[self setThreadsListViewMode:newType];
}

- (IBAction)cleanupDatochiFiles:(id)sender
{
	NSAlert *alert = [[[NSAlert alloc] init] autorelease];
	[alert setAlertStyle:NSCriticalAlertStyle];
	[alert setMessageText:[NSString stringWithFormat:NSLocalizedStringFromTable(@"CleanupDatochiFilesAlert(BoardName %@)", @"ThreadsList", nil),
													 [[self currentThreadsList] boardName]]];
	[alert setInformativeText:NSLocalizedStringFromTable(@"CleanupDatochiFilesMessage", @"ThreadsList", nil)];
	[alert addButtonWithTitle:NSLocalizedStringFromTable(@"DragDropTrashOK", @"ThreadsList", nil)];
	[alert addButtonWithTitle:NSLocalizedStringFromTable(@"DragDropTrashCancel", @"ThreadsList", nil)];
	[alert beginSheetModalForWindow:[self windowForSheet]
					  modalDelegate:self
					 didEndSelector:@selector(cleanupDatochiFilesAlertDidEnd:returnCode:contextInfo:)
						contextInfo:NULL];
}

- (IBAction)newThread:(id)sender
{
	NSString				*boardName = [[self currentThreadsList] boardName];
	BSNewThreadMessenger	*document;
	NSDocumentController	*docController = [NSDocumentController sharedDocumentController];

	UTILAssertNotNil(boardName);

	document = [[BSNewThreadMessenger alloc] initWithBoardName:boardName];

	if (document) {
		[docController addDocument:document];
		[document makeWindowControllers];
		[document showWindows];
	}
}

- (IBAction)rebuildThreadsList:(id)sender
{
	NSAlert *alert = [[[NSAlert alloc] init] autorelease];
	[alert setAlertStyle:NSCriticalAlertStyle];
	[alert setMessageText:[NSString stringWithFormat:NSLocalizedStringFromTable(@"RebuildThreadsListAlert(BoardName %@)", @"ThreadsList", nil),
													 [[self currentThreadsList] boardName]]];
	[alert setInformativeText:NSLocalizedStringFromTable(@"RebuildThreadsListMessage", @"ThreadsList", nil)];
	[alert addButtonWithTitle:NSLocalizedStringFromTable(@"DragDropTrashOK", @"ThreadsList", nil)];
	[alert addButtonWithTitle:NSLocalizedStringFromTable(@"DragDropTrashCancel", @"ThreadsList", nil)];
	[alert beginSheetModalForWindow:[self windowForSheet]
					  modalDelegate:self
					 didEndSelector:@selector(rebuildThreadsListAlertDidEnd:returnCode:contextInfo:)
						contextInfo:NULL];
}

- (void)cleanupDatochiFilesAlertDidEnd:(NSAlert *)alert returnCode:(int)returnCode contextInfo:(void *)contextInfo
{
	if (returnCode == NSAlertFirstButtonReturn) {
		[[self currentThreadsList] removeDatochiFiles];
	}
}

- (void)rebuildThreadsListAlertDidEnd:(NSAlert *)alert returnCode:(int)returnCode contextInfo:(void *)contextInfo
{
	if (returnCode != NSAlertFirstButtonReturn) {
		// Canceled. Nothing to do.
		return;
	}

	NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
	[nc addObserver:self selector:@selector(rebuildingDidEnd:) name:CMRThreadsListDidChangeNotification object:[self currentThreadsList]];

	if (!m_modalWindow) {
		[NSBundle loadNibNamed:@"BSModalStatusWindow" owner:self];
	}

	[[alert window] orderOut:nil];

	NSModalSession session = [NSApp beginModalSessionForWindow:m_modalWindow];
	[m_fakeIndicator startAnimation:nil];
	[[self currentThreadsList] rebuildThreadsList];
	while (1) {
		if ([NSApp runModalSession:session] != NSRunContinuesResponse) {
			break;
		}
	}
	[m_fakeIndicator stopAnimation:nil];
	[NSApp endModalSession:session];
}

- (void)rebuildingDidEnd:(NSNotification *)notification
{
	[[NSNotificationCenter defaultCenter] removeObserver:self name:CMRThreadsListDidChangeNotification object:nil];
	[NSApp abortModal];
	[m_modalWindow orderOut:nil];

	NSAlert *alert = [[[NSAlert alloc] init] autorelease];
	[alert setAlertStyle:NSInformationalAlertStyle];
	[alert setMessageText:NSLocalizedStringFromTable(@"RebuildingEndAlert", @"ThreadsList", nil)];
	[alert beginSheetModalForWindow:[self windowForSheet] modalDelegate:self didEndSelector:NULL contextInfo:NULL];
}
@end


@implementation Browser(ScriptingSupport)
- (NSTextStorage *)selectedText
{
	return [super selectedText];
}

- (NSString *)boardURLAsString
{
	return [[self boardURL] stringValue];
}

- (NSString *)boardNameAsString
{
	return [[self currentThreadsList] boardName];
}

- (void)setBoardNameAsString:(NSString *)boardNameStr
{
	CMRBrowser *wc_ = [[self windowControllers] lastObject];
	if (!wc_) return;

	[wc_ showThreadsListWithBoardName:boardNameStr];
	[wc_ selectRowOfName:boardNameStr forceReload:NO];
}

- (void)handleReloadListCommand:(NSScriptCommand *)command
{
	[self reloadThreadsList];
}

- (void)handleReloadThreadCommand:(NSScriptCommand *)command
{
	CMRBrowser *wc_ = [[self windowControllers] lastObject];
	if (!wc_) return;

	[wc_ reloadThread:nil];
}
@end
