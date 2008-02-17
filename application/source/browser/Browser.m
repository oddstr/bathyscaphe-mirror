//
//  Browser.m
//  BathyScaphe
//
//  Updated by Tsutomu Sawada on 08/02/10.
//  Copyright 2005-2008 BathyScaphe Project. All rights reserved.
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
#import "CMRFavoritesManager.h"

#import "BSNewThreadMessenger.h"

@implementation Browser
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
	static NSString *base_ = nil;
	if (!base_) {
		base_ = [NSLocalizedStringFromTable(@"Board Info Format", @"ThreadsList", @"") retain];
	}

	BSDBThreadList		*list_ = [self currentThreadsList];
	if (!list_) return [super displayName];
	NSString *foo;

	if ([self searchString]) {
		unsigned foundNum = [list_ numberOfFilteredThreads];
		
		if (0 == foundNum) {
			foo = NSLocalizedStringFromTable(kSearchListNotFoundKey, @"ThreadsList", @"");//[self localizedString:kSearchListNotFoundKey];
		} else {
			foo = [NSString stringWithFormat:NSLocalizedStringFromTable(kSearchListResultKey, @"ThreadsList", @""), foundNum];
		}
	} else {
		foo = [NSString stringWithFormat:base_, [list_ numberOfThreads]];
	}

	return [NSString stringWithFormat:@"%@ (%@)", [list_ boardName], foo];
}

- (BOOL)readFromFile:(NSString *)fileName ofType:(NSString *)type
{
	return YES;
}

- (BOOL)loadDataRepresentation:(NSData *)data ofType:(NSString *)aType
{
	return NO;
}

- (NSData *)dataRepresentationOfType:(NSString *)aType
{
	return nil;
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
/*
- (IBAction)importFavorites:(id)sender
{
	NSOpenPanel	*panel_ = [NSOpenPanel openPanel];
	int	resultCode;

	[panel_ setCanChooseFiles:YES];
	[panel_ setCanChooseDirectories:NO];
	[panel_ setResolvesAliases:YES];
	[panel_ setAllowsMultipleSelection:NO];
	
	resultCode = [panel_ runModalForTypes:[NSArray arrayWithObject:@"plist"]];
	if (resultCode == NSOKButton) {
		NSString *path = [panel_ filename];
		if (![[CMRFavoritesManager defaultManager] importFavoritesFromFile:path]) {
			NSBeep();
			NSLog(@"Import failed - %@", path);
		}
	}
}

- (IBAction)exportFavorites:(id)sender
{
	NSSavePanel *savePanel_ = [NSSavePanel savePanel];
	int			resultCode;

	[savePanel_ setRequiredFileType:@"plist"];
	[savePanel_ setCanCreateDirectories:YES];
	[savePanel_ setCanSelectHiddenExtension:NO];

	resultCode = [savePanel_ runModalForDirectory:nil file:@"ExportedFavorites.plist"];

	if (resultCode == NSFileHandlingPanelOKButton) {
		NSString *savePath_ = [savePanel_ filename];
		if (![[CMRFavoritesManager defaultManager] exportFavoritesToFile:savePath_ atomically:YES]) {
			NSBeep();
			NSLog(@"Export failed - %@", savePath_);
		}
	}
}*/

- (BOOL)validateMenuItem:(NSMenuItem *)theItem
{
	SEL action_ = [theItem action];

	if (action_ == @selector(saveDocumentAs:)) {
		[theItem setTitle:NSLocalizedString(@"Save Menu Item Default", @"Save as...")];
		return ([self threadAttributes] != nil);
	} else if (action_ == @selector(cleanupDatochiFiles:)) {
		return [BoardListItem isBoardItem:[[self currentThreadsList] boardListItem]] && ![self searchString];
	} else if (action_ == @selector(showLocalRules:)) {
		BoardManager *bm = [BoardManager defaultManager];
		if ([BoardListItem isBoardItem:[[self currentThreadsList] boardListItem]]) {
			BOOL	 isVisible = [bm isKeyWindowForBoardName:[self boardNameAsString]];
			
			[theItem setTitle:isVisible ? NSLocalizedString(@"Hide Local Rules", @"") : NSLocalizedString(@"Show Local Rules", @"")];
			return YES;
		} else {
			[theItem setTitle:NSLocalizedString(@"Show Local Rules", @"")];
			return NO;
		}
	} else if (action_ == @selector(newThread:)) {
		return [BoardListItem isBoardItem:[[self currentThreadsList] boardListItem]];
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

- (BOOL)searchThreadsInListWithString:(NSString *)text
{
	if (![self currentThreadsList]) return NO;

	return [[self currentThreadsList] filterByString:text];
}

- (void)sortThreadsByKey:(NSString *)key
{
	[[self currentThreadsList] sortByKey:key];
}

- (void)toggleThreadsListIsAscending
{
	[[self currentThreadsList] toggleIsAscending];
}

- (void)changeThreadsFilteringMask:(int)mask
{
	[[self currentThreadsList] setFilteringMask:mask];
	[[self currentThreadsList] filterByStatus:mask];
}

- (IBAction)toggleThreadsListViewMode:(id)sender
{
	AppDefaults *pref = CMRPref;
	BSThreadsListViewModeType	newMode;

	newMode = ([pref threadsListViewMode] == BSThreadsListShowsLiveThreads) ? BSThreadsListShowsStoredLogFiles : BSThreadsListShowsLiveThreads;
	[pref setThreadsListViewMode:newMode];
	[[self currentThreadsList] setViewMode:newMode];
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

- (BOOL)removeDatochiFiles
{
	id threadsList = [self currentThreadsList];
	if (!threadsList) return YES;

	NSMutableArray	*array = [NSMutableArray array];

	NSString *folderPath = [[CMRDocumentFileManager defaultManager] directoryWithBoardName:[threadsList boardName]];
	NSDirectoryEnumerator *iter = [[NSFileManager defaultManager] enumeratorAtPath:folderPath];
	CMRFavoritesManager *fm = [CMRFavoritesManager defaultManager];
	NSString	*fileName, *filePath;
	while (fileName = [iter nextObject]) {
		if ([[fileName pathExtension] isEqualToString:@"thread"]) {
			filePath = [folderPath stringByAppendingPathComponent:fileName];
			if (![fm favoriteItemExistsOfThreadPath:filePath]) {
				unsigned int index = [threadsList indexOfThreadWithPath:filePath];
				if (index == NSNotFound) {
					[array addObject:filePath];
				}
			}
		}
	}

	if ([array count] == 0) return YES;

	NSArray	*alsoReplyFiles_ = [[CMRReplyDocumentFileManager defaultManager] replyDocumentFilesArrayWithLogsArray:array];
	return [[CMRTrashbox trash] performWithFiles:alsoReplyFiles_ fetchAfterDeletion:NO];
}

- (void)cleanupDatochiFilesAlertDidEnd:(NSAlert *)alert returnCode:(int)returnCode contextInfo:(void *)contextInfo
{
	if (returnCode == NSAlertFirstButtonReturn) {
		[self removeDatochiFiles];
	}
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
	[wc_ selectRowWhoseNameIs:boardNameStr];
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
