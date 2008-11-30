//
//  CMRThreadsList.m
//  BathyScaphe
//
//  Updated by Tsutomu Sawada on 07/03/18.
//  Copyright 2005-2008 BathyScaphe Project. All rights reserved.
//  encoding="UTF-8"
//

#import "CMRThreadsList_p.h"
#import "CMRThreadLayout.h"
#import "BoardManager.h"
#import "CMRDocumentFileManager.h"
#import "CMRReplyDocumentFileManager.h"
#import "missing.h"

NSString *const CMRThreadsListDidUpdateNotification = @"ThreadsListDidUpdateNotification";
NSString *const CMRThreadsListDidChangeNotification = @"ThreadsListDidChangeNotification";
NSString *const ThreadsListUserInfoSelectionHoldingMaskKey = @"ThreadsListUserInfoSelectionHoldingMaskKey";


@implementation CMRThreadsList
- (id)init
{
	if (self = [super init]) {
		[self registerToNotificationCenter];
	}
	return self;
}

- (void)dealloc
{
	[self removeFromNotificationCenter];
	
	[self setWorker:nil];
	[self setThreads:nil];
	[self setFilteredThreads:nil];

	[super dealloc];
}

- (void)startLoadingThreadsList:(CMRThreadLayout *)worker
{
	[self doLoadThreadsList:worker];
}

- (CMRThreadLayout *)worker
{
	return _worker;
}

- (void)setWorker:(CMRThreadLayout *)aWorker
{
	[aWorker retain];
	[_worker release];
	_worker = aWorker;
}

#pragma mark Abstract Methods
- (BOOL)isFavorites
{
	UTILAbstractMethodInvoked;
	return NO;
}

- (void)doLoadThreadsList:(CMRThreadLayout *)worker
{
	UTILAbstractMethodInvoked;
}

- (BOOL)isSmartItem
{
	UTILAbstractMethodInvoked;
	return NO;
}

- (BOOL)isBoard
{
	UTILAbstractMethodInvoked;
	return YES;
}

- (void)rebuildThreadsList
{
	UTILAbstractMethodInvoked;
}
@end


@implementation CMRThreadsList(AccessingList)
- (NSMutableArray *)threads
{
	return _threads;
}

- (void)setThreads:(NSMutableArray *)aThreads
{
	[aThreads retain];
	[_threads release];
	_threads = aThreads;
}

- (NSMutableArray *)filteredThreads
{
	return _filteredThreads;
}

- (void)setFilteredThreads:(NSArray *)aFilteredThreads
{
	[aFilteredThreads retain];
	[_filteredThreads release];
	_filteredThreads = aFilteredThreads;
}
@end


@implementation CMRThreadsList(Attributes)
- (NSURL *)boardURL
{
	return [[BoardManager defaultManager] URLForBoardName:[self boardName]];
}

- (unsigned)numberOfThreads
{
	if (![self threads]) {
		return 0;
	}
	return [[self threads] count];
}

- (unsigned)numberOfFilteredThreads
{
	if (![self filteredThreads]) {
		return 0;
	}
	return [[self filteredThreads] count];
}

#pragma mark Abstract Method
- (NSString *)boardName
{
	UTILAbstractMethodInvoked;
	return nil;
}
@end


@implementation CMRThreadsList(CleanUp)
/*- (BOOL)tableView:(NSTableView *)tableView removeFilesAtRowIndexes:(NSIndexSet *)rowIndexes ask:(BOOL)flag
{
	NSArray	*files = [self tableView:tableView threadFilePathsArrayAtRowIndexes:rowIndexes];
	if (flag) {
		NSAlert *alert = [[[NSAlert alloc] init] autorelease];
		[alert setAlertStyle:NSWarningAlertStyle];
		[alert setMessageText:@"Are yot sure you want to delete selected thread(s)?"];
		[alert setInformativeText:@"Log file(s) will be moved to Trash."];
		[alert addButtonWithTitle:@"Delete"];
		[alert addButtonWithTitle:@"Cancel"];
		
		[alert beginSheetModalForWindow:[tableView window]
						  modalDelegate:self
						 didEndSelector:@selector(removeFilesConfirmingDidEnd:returnCode:contextInfo:)
							contextInfo:[files retain]];
		return YES;
	}
	return [self tableView:tableView removeFiles:files delFavIfNecessary:YES];
}

- (void)removeFilesConfirmingDidEnd:(NSAlert *)alert returnCode:(int)returnCode contextInfo:(void *)contextInfo
{
	if (returnCode == NSAlertFirstButtonReturn) {
		[self tableView:nil removeFiles:(NSArray *)contextInfo delFavIfNecessary:YES];
	}
	[(id)contextInfo release];
}
*/
- (BOOL)tableView:(NSTableView *)tableView removeFiles:(NSArray *)files delFavIfNecessary:(BOOL)flag
{
	BOOL tmp;

	if (flag) {
		NSArray	*alsoReplyFiles_;

		alsoReplyFiles_ = [[CMRReplyDocumentFileManager defaultManager] replyDocumentFilesArrayWithLogsArray:files];
		tmp = [[CMRTrashbox trash] performWithFiles:alsoReplyFiles_ fetchAfterDeletion:NO];
	} else {
		tmp = [[CMRTrashbox trash] performWithFiles:files fetchAfterDeletion:YES];
	}

	return tmp;
}

- (BOOL)removeDatochiFiles
{
	NSMutableArray	*array = [NSMutableArray array];

	NSString *folderPath = [[CMRDocumentFileManager defaultManager] directoryWithBoardName:[self boardName]];
	NSDirectoryEnumerator *iter = [[NSFileManager defaultManager] enumeratorAtPath:folderPath];
	CMRFavoritesManager *fm = [CMRFavoritesManager defaultManager];
	NSString	*fileName, *filePath;
	while (fileName = [iter nextObject]) {
		if ([[fileName pathExtension] isEqualToString:@"thread"]) {
			filePath = [folderPath stringByAppendingPathComponent:fileName];
			if (![fm favoriteItemExistsOfThreadPath:filePath]) {
				unsigned int index = [self indexOfThreadWithPath:filePath ignoreFilter:YES];
				if (index == NSNotFound) {
					[array addObject:filePath];
				}
			}
		}
	}

	if ([array count] == 0) return YES;

	return [self tableView:nil removeFiles:array delFavIfNecessary:YES];
}

#pragma mark Abstract Method
- (void)cleanUpItemsToBeRemoved:(NSArray *)files
{
	UTILAbstractMethodInvoked;
}
@end


@implementation CMRThreadsList(CMRLocalizableStringsOwner)
+ (NSString *)localizableStringsTableName
{
	return APP_TLIST_LOCALIZABLE_FILE;
}
@end
