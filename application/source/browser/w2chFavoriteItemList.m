/**
  * $Id: w2chFavoriteItemList.m,v 1.4.2.3 2006/02/27 17:31:49 masakih Exp $
  * Copyright 2005 BathyScaphe Project. All rights reserved.
  *
  */
#import "CMRThreadsList_p.h"
#import "CMRThreadViewer.h"
#import "CMRThreadAttributes.h"
#import "ThreadTextDownloader.h"
#import "CMRThreadsUpdateListTask.h"
#import "missing.h"
#import "CMRHostHandler.h"
#import "CMRThreadSignature.h"
#import "BSFavoritesHEADCheckTask.h"

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
	if(NO == [CMRPref canHEADCheck]) {
		NSBeep();
		NSLog(@"You can't use HEADCheck now. Please wait...");
		return;
	}

	BSFavoritesHEADCheckTask		*task_;
	
	task_ = [[BSFavoritesHEADCheckTask alloc]
				initWithFavItemsArray : [[CMRFavoritesManager defaultManager] favoritesItemsArray]];
	
	// 進行状況を表示するための情報
	[task_ setBoardName : [self boardName]];
	[task_ setIdentifier : [self boardName]];
	
	// 終了通知
	[[NSNotificationCenter defaultCenter]
			addObserver : self
			selector : @selector(favoritesHEADCheckTaskDidFinish:)
			name : BSFavoritesHEADCheckTaskDidFinishNotification
			object : task_];

	[[self worker] push : task_];

	[task_ release];
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

- (void) favoritesHEADCheckTaskDidFinish : (NSNotification *) aNotification
{
	UTILAssertNotificationName(
		aNotification,
		BSFavoritesHEADCheckTaskDidFinishNotification);

	id					object_;
	NSDictionary		*userInfo_;
	NSMutableArray		*threadsArray_;
	
	object_ = [aNotification object];
	UTILAssertKindOfClass(object_, BSFavoritesHEADCheckTask);
	if(NO == [[object_ identifier] isEqual : [self boardName]])
		return;
	
	userInfo_ = [aNotification userInfo];
	
	threadsArray_	= [userInfo_ objectForKey : kBSUserInfoThreadsArrayKey];
	UTILAssertKindOfClass(threadsArray_, NSMutableArray);
	

	[[CMRFavoritesManager defaultManager] setFavoritesItemsArray : threadsArray_];
	[CMRPref setLastHEADCheckedDate : [NSDate date]];

	[self startLoadingThreadsList : [self worker]];

	[[NSNotificationCenter defaultCenter]
			removeObserver : self
			name : [aNotification name]
			object : [aNotification object]];
}

- (void) syncFavIfNeededWithAttr : (NSMutableDictionary *) thread forPath : (NSString *) filePath
{
	[super syncFavIfNeededWithAttr : thread forPath : filePath];

	[[CMRFavoritesManager defaultManager] addItemToPoolWithFilePath : filePath];
}
@end

@implementation w2chFavoriteItemList(ReadThreadsList)
- (void) _applyFavItemsPool
{
	// Nothing need to be done.
}

- (void) _syncFavItemsPool
{
	// Nothing need to be done.
}
@end

@implementation w2chFavoriteItemList(ListImport)
+ (void) clearAttributes : (NSMutableDictionary *) attributes
{
	int idx_;
	CMRFavoritesManager	*fM_ = [CMRFavoritesManager defaultManager];
	
	[super clearAttributes : attributes];

	idx_ = [[fM_ favoritesItemsIndex] indexOfObject : [CMRThreadAttributes pathFromDictionary : attributes]];

	if (idx_ != NSNotFound)
		[[fM_ favoritesItemsArray] replaceObjectAtIndex : idx_ withObject : attributes];

}
@end

@implementation w2chFavoriteItemList(CleanUp)
- (BOOL) tableView : (NSTableView	*) tableView
	   removeFiles : (NSArray		*) files
 delFavIfNecessary : (BOOL			 ) flag
{
	NSEnumerator		*iter_;
	NSString			*path_;
	
	if(NO == [super tableView : tableView removeFiles : files delFavIfNecessary : flag])
		return NO;
	
	iter_ = [files objectEnumerator];
	while(path_ = [iter_ nextObject]){
		[[CMRFavoritesManager defaultManager] addItemToPoolWithFilePath : path_];
	}

	return YES;
}
@end
