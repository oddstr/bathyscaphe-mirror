//:w2chFavoriteItemList.m
/**
  *
  * @see CMRFavoritesManager.h
  *
  * @author Takanori Ishikawa
  * @author http://www15.big.or.jp/~takanori/
  * @version 1.0.0d1 (02/11/09  0:04:57 AM)
  *
  */
#import "CMRThreadsList_p.h"
#import "CMRThreadViewer.h"
#import "CMRThreadAttributes.h"
#import "ThreadTextDownloader.h"
#import "CMRThreadsUpdateListTask.h"
#import "missing.h"

/* These functions are actually implemented in CMRThreadsList-Notification.m */
extern BOOL synchronizeThreadAttributes(NSMutableDictionary*, CMRThreadAttributes*);
extern void margeThreadAttributesWithContentDict(NSMutableDictionary*, NSDictionary*);

@implementation w2chFavoriteItemList
- (void) registerToNotificationCenter
{
	[[NSNotificationCenter defaultCenter]
	     addObserver : self
	        selector : @selector(favoritesManagerDidLinkFavorites:)
	            name : CMRFavoritesManagerDidLinkFavoritesNotification
	          object : [CMRFavoritesManager defaultManager]];
	[[NSNotificationCenter defaultCenter]
	     addObserver : self
	        selector : @selector(favoritesManagerDidRemoveFavorites:)
	            name : CMRFavoritesManagerDidRemoveFavoritesNotification
	          object : [CMRFavoritesManager defaultManager]];
	
	[super registerToNotificationCenter];
}
- (void) removeFromNotificationCenter
{
	[[NSNotificationCenter defaultCenter]
	  removeObserver : self
	            name : CMRFavoritesManagerDidLinkFavoritesNotification
	          object : [CMRFavoritesManager defaultManager]];
	[[NSNotificationCenter defaultCenter]
	  removeObserver : self
	            name : CMRFavoritesManagerDidRemoveFavoritesNotification
	          object : [CMRFavoritesManager defaultManager]];
	
	[super removeFromNotificationCenter];
}

- (NSString *) boardName
{
	return CMXFavoritesDirectoryName;
}

- (NSString *) threadsListPath
{
	return nil;
}

- (NSURL *) boardURL
{
	return nil;
}
- (void) downloadThreadsList
{
	;
}

//Favorites
- (BOOL) isFavorites
{
	return YES;
}

- (BOOL) addFavoriteAtRowIndex : (int          ) rowIndex
				   inTableView : (NSTableView *) tableView
{
	return NO;
}
+ (NSString *) objectValueForBoardInfoFormatKey
{
	return @"Favorite Info Format";
}
@end


@implementation w2chFavoriteItemList(DataSource)
- (BOOL) tableView : (NSTableView *) tableView
		 writeRows : (NSArray *) rows
	  toPasteboard : (NSPasteboard *) pasteBoard
{
	[pasteBoard declareTypes : [NSArray arrayWithObjects : CMRFavoritesItemsPboardType, nil] owner : self];
	[pasteBoard setPropertyList : rows forType : @"row"];
	
	return YES;
}

- (NSDragOperation) tableView : (NSTableView *) tableView
				 validateDrop : (id <NSDraggingInfo>) info
				  proposedRow : (int) row
		proposedDropOperation : (NSTableViewDropOperation) operation
{
	NSPasteboard *pboard = [info draggingPasteboard];
	NSString	 *_identifier = [[tableView highlightedTableColumn] identifier];

	// ドラッグ＆ドロップで並べ替え可能なのは「番号」カラムでソートしているときのみ
	if (![_identifier isEqualToString : CMRThreadSubjectIndexKey]) return NSDragOperationNone;
	
	if (operation == NSTableViewDropAbove &&
			[pboard availableTypeFromArray : [NSArray arrayWithObjects : CMRFavoritesItemsPboardType, nil]] != nil)
	{
		return NSDragOperationGeneric;
	} else {
		return NSDragOperationNone;
	}
}

- (BOOL) tableView : (NSTableView *) tableView
		acceptDrop : (id <NSDraggingInfo>) info
			   row : (int) rowIndex
	 dropOperation : (NSTableViewDropOperation) operation
{
	NSPasteboard	*pboard = [info draggingPasteboard];
	NSArray			*draggedRows_ = [pboard propertyListForType: @"row"];

	int				i, s;

	if (operation == NSTableViewDropAbove &&
		[pboard availableTypeFromArray : [NSArray arrayWithObjects : CMRFavoritesItemsPboardType, nil]] != nil)
	{
		s = [[CMRFavoritesManager defaultManager] insertFavItemsTo : rowIndex
													withIndexArray : draggedRows_
													   isAscending : [self isAscending]];
		
		[self startLoadingThreadsList : [self worker]];
		[tableView deselectAll : nil];
        
		for (i = s; i < (s + [draggedRows_ count]); i++) {
				[tableView selectRow : i byExtendingSelection : YES];
		}
		return YES;

	} else {
		return NO;
	}
}
@end


@implementation w2chFavoriteItemList(NotificationCenterSupport)
- (void) favoritesManagerDidLinkFavorites : (NSNotification *) notification
{
	UTILAssertNotificationName(
		notification,
		CMRFavoritesManagerDidLinkFavoritesNotification);
	UTILAssertNotificationObject(
		notification,
		[CMRFavoritesManager defaultManager]);
		
	//NSLog(@"Favorites Added...");
	[self startLoadingThreadsList : [self worker]];
}
- (void) favoritesManagerDidRemoveFavorites : (NSNotification *) notification
{
	NSString	*filepath_;
	
	UTILAssertNotificationName(
		notification,
		CMRFavoritesManagerDidRemoveFavoritesNotification);
	UTILAssertNotificationObject(
		notification,
		[CMRFavoritesManager defaultManager]);
	
	filepath_ = [[notification userInfo]
		objectForKey : kAppFavoritesManagerInfoFilesKey];
	UTILAssertNotNil(filepath_);

	//Is it OK? Hmm... (05-03-05 tsawada2)
	[self startLoadingThreadsList : [self worker]];
}

// スレッドの読み込みが完了。
- (void) threadViewerDidChangeThread : (NSNotification *) theNotification
{
	NSMutableDictionary		*thread_;
	NSString				*filepath_;
	CMRThreadAttributes		*threadAttributes_;
	
	UTILAssertNotificationName(
		theNotification,
		CMRThreadViewerDidChangeThreadNotification);
	
	
	threadAttributes_ = [[theNotification object] threadAttributes];
	filepath_ = [[theNotification object] path];
	thread_ = [self seachThreadByPath : filepath_];
	if(nil == thread_)
		return;
	
	
	// 既得数を更新
	if(synchronizeThreadAttributes(thread_, threadAttributes_)) {
		int	i;
		i = [[[CMRFavoritesManager defaultManager] favoritesItemsIndex] indexOfObject : filepath_];
		if (i != NSNotFound) {
			[[[CMRFavoritesManager defaultManager] favoritesItemsArray] replaceObjectAtIndex : i
																				  withObject : thread_];
		}

		[[CMRFavoritesManager defaultManager] addItemToPoolWithFilePath : filepath_];

		[self postListDidUpdateNotification : CMRAutoscrollWhenThreadUpdate];
	}
}
// スレッドのダウンロードが終了した。
- (void) downloaderTextUpdatedNotified : (NSNotification *) notification
{
	CMRDownloader			*downloader_;
	NSDictionary			*userInfo_;
	NSDictionary			*newContents_;
	NSMutableDictionary		*thread_;
	int	i;
	
	UTILAssertNotificationName(
		notification,
		ThreadTextDownloaderUpdatedNotification);
		

	downloader_ = [notification object];
	UTILAssertKindOfClass(downloader_, CMRDownloader);
	
	userInfo_ = [notification userInfo];
	UTILAssertNotNil(userInfo_);
	
	newContents_ = [userInfo_ objectForKey : CMRDownloaderUserInfoContentsKey];
	UTILAssertKindOfClass(
		newContents_,
		NSDictionary);

	thread_ = [self seachThreadByPath : [downloader_ filePathToWrite]];
	if(nil == thread_) return;

	margeThreadAttributesWithContentDict(thread_, newContents_);

	i = [[[CMRFavoritesManager defaultManager] favoritesItemsIndex] indexOfObject : [downloader_ filePathToWrite]];
	if (i != NSNotFound) {
		[[[CMRFavoritesManager defaultManager] favoritesItemsArray] replaceObjectAtIndex : i withObject : thread_];
	}

	[[CMRFavoritesManager defaultManager] addItemToPoolWithFilePath : [downloader_ filePathToWrite]];
	
	[self postListDidUpdateNotification : CMRAutoscrollWhenThreadUpdate];
}

- (void) _syncFavItemsPool
{
	// Nothing need to be done.
}
@end

@implementation w2chFavoriteItemList(ListImport)
- (void) _applyFavItemsPool
{
	// Nothing need to be done.
}
@end

@implementation w2chFavoriteItemList(CleanUp)
- (BOOL) tableView : (NSTableView	*) tableView
	   removeFiles : (NSArray		*) files
		deleteFile : (BOOL			 ) flag
{
	NSEnumerator		*iter_;
	NSString			*path_;
	
	if(NO == [super tableView:tableView removeFiles:files deleteFile:flag])
		return NO;
	
	iter_ = [files objectEnumerator];
	while(path_ = [iter_ nextObject]){
		[[CMRFavoritesManager defaultManager] removeFromFavoritesWithFilePath:path_];
		if (flag) {
			[[CMRFavoritesManager defaultManager] addItemToPoolWithFilePath : path_];
		}
	}
		
	
	return YES;
}
@end
