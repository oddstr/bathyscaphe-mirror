/**
  * $Id: Browser.m,v 1.19 2007/10/06 21:12:32 tsawada2 Exp $
  * BathyScaphe 
  *
  * Copyright 2005-2006 BathyScaphe Project.
  * Copyright (c) 2003, Takanori Ishikawa.
  * See the file LICENSE for copying permission.
  */
#import "Browser.h"

#import "AppDefaults.h"
#import "CMRThreadViewer_p.h"
#import "CMRBrowser_p.h"
#import "CMRThreadsList.h"
#import "CMRThreadAttributes.h"
#import "BoardManager.h"
#import "CMRReplyDocumentFileManager.h"


@implementation Browser
- (void) dealloc
{	
	[[NSNotificationCenter defaultCenter] removeObserver : self];
	[self setCurrentThreadsList : nil];
	[self setThreadAttributes : nil];
	[m_searchString release];
	
	[super dealloc];
}

- (NSURL *) boardURL
{
	return [[self currentThreadsList] boardURL];
}

- (BSDBThreadList *) currentThreadsList
{
	return m_currentThreadsList;
}

- (void) setCurrentThreadsList : (BSDBThreadList *) aCurrentThreadsList
{
	id tmp;
	
	tmp = m_currentThreadsList;
	m_currentThreadsList = [aCurrentThreadsList retain];
	[tmp release];
}

- (NSString *) searchString
{
	return m_searchString;
}

- (void) setSearchString: (NSString *) text
{
	[text retain];
	[m_searchString release];
	m_searchString = text;
}

#pragma mark NSDocument

- (void) makeWindowControllers
{
	CMRBrowser		*browser_;
	
	browser_ = [[CMRBrowser alloc] init];
	[self addWindowController : browser_];
	[browser_ release];
}

- (NSString *) displayName
{
	BSDBThreadList		*list_;
	
	list_ = [self currentThreadsList];
	return list_ ? [list_ boardName] : nil;
}

- (BOOL) readFromFile : (NSString *) fileName
			   ofType : (NSString *) type
{
	return YES;
}

- (BOOL) loadDataRepresentation : (NSData   *) data
                         ofType : (NSString *) aType
{
	return NO;
}

- (NSData *) dataRepresentationOfType : (NSString *) aType
{
	return nil;
}

- (IBAction) saveDocumentAs : (id) sender
{
	if ([self threadAttributes] == nil) return;

	NSFileManager	*fM_ = [NSFileManager defaultManager];
	NSString *filePath_ = [[self threadAttributes] path];
	if (filePath_ == nil || NO == [fM_ fileExistsAtPath: filePath_]) return;

	NSSavePanel *savePanel_ = [NSSavePanel savePanel];
	int			resultCode;

	[savePanel_ setRequiredFileType : CMRThreadDocumentPathExtension];
	[savePanel_ setCanCreateDirectories : YES];
	[savePanel_ setCanSelectHiddenExtension : YES];

	resultCode = [savePanel_ runModalForDirectory: nil file: [filePath_ lastPathComponent]];

	if (resultCode == NSFileHandlingPanelOKButton) {
		NSString *savePath_ = [savePanel_ filename];
		if ([fM_ copyPath: filePath_ toPath: savePath_ handler: nil]) {
			NSDate	*curDate_ = [NSDate date];
			NSDictionary *tmp_;
			tmp_ = [NSDictionary dictionaryWithObjectsAndKeys: [NSNumber numberWithBool: [savePanel_ isExtensionHidden]], NSFileExtensionHidden,
															   curDate_, NSFileModificationDate, curDate_, NSFileCreationDate, NULL];
			[fM_ changeFileAttributes: tmp_ atPath: savePath_];
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
//		return ([self currentThreadsList] != nil);
		return [BoardListItem isBoardItem:[[self currentThreadsList] boardListItem]] && ![self searchString];
	}
	return [super validateMenuItem:theItem];
}

#pragma mark ThreadsList

- (void) reloadThreadsList
{
	[[self currentThreadsList] downloadThreadsList];
}

- (BOOL) searchThreadsInListWithCurrentSearchString
{
	if(nil == [self currentThreadsList]) return NO;

	return [[self currentThreadsList] filterByString: [self searchString]];
}

- (BOOL) searchThreadsInListWithString : (NSString *) text
{
	if(nil == [self currentThreadsList]) return NO;

	return [[self currentThreadsList] filterByString: text];
}

- (void) sortThreadsByKey : (NSString *) key
{
	[[self currentThreadsList] sortByKey : key];
}

- (void) toggleThreadsListIsAscending
{
	if(nil == [self currentThreadsList]) return;
	[[self currentThreadsList] toggleIsAscending];
}

- (void) changeThreadsFilteringMask : (int) mask
{
	if(nil == [self currentThreadsList]) return;
	[[self currentThreadsList] setFilteringMask : mask];
	[[self currentThreadsList] filterByStatus : mask];
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
	//				NSLog(@"%@", [filePath lastPathComponent]);
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

#pragma mark -

@implementation Browser(ScriptingSupport)
- (NSString *) boardURLAsString
{
	return [[self boardURL] stringValue];
}

- (NSString *) boardNameAsString
{
	return [[self currentThreadsList] boardName];
}

- (void) setBoardNameAsString : (NSString *) boardNameStr
{
	CMRBrowser *wc_ = [[self windowControllers] lastObject];
	if (wc_ == nil) return;

	[wc_ showThreadsListWithBoardName : boardNameStr];
	[wc_ selectRowWhoseNameIs : boardNameStr];
}

- (void) handleReloadListCommand : (NSScriptCommand *) command
{
	[self reloadThreadsList];
}

- (void) handleReloadThreadCommand : (NSScriptCommand *) command
{
	CMRBrowser *wc_ = [[self windowControllers] lastObject];
	if (wc_ == nil) return;

	[wc_ reloadThread : nil];
}
@end
