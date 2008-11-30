//
//  BSDBThreadList.m
//  BathyScaphe
//
//  Created by Hori,Masaki on 05/07/19.
//  Copyright 2005-2008 BathyScaphe Project. All rights reserved.
//  encoding="UTF-8"
//

#import "BSDBThreadList.h"

#import "CMRThreadsList_p.h"
#import "missing.h"
#import "BSDateFormatter.h"
#import "CMRThreadSignature.h"
#import "BSThreadListUpdateTask.h"
#import "BSThreadsListOPTask.h"
#import "BSBoardListItemHEADCheckTask.h"
#import "BoardListItem.h"
#import "DatabaseManager.h"
#import "BSThreadListItem.h"
#import "BSIkioiNumberFormatter.h"

NSString *BSDBThreadListDidFinishUpdateNotification = @"BSDBThreadListDidFinishUpdateNotification";


@interface BSDBThreadList(Private)
- (void)setSortDescriptors:(NSArray *)inDescs;
- (void)addSortDescriptor:(NSSortDescriptor *)inDesc;
@end


@interface BSDBThreadList(ToBeRefactoring)
@end


@implementation BSDBThreadList
// primitive
- (id)initWithBoardListItem:(BoardListItem *)item
{
	if (self = [super init]) {
		[self setBoardListItem:item];

		mCursorLock = [[NSLock alloc] init];
		mTaskLock = [[NSLock alloc] init];
	}
	
	return self;
}

+ (id)threadListWithBoardListItem:(BoardListItem *)item
{
	return [[[self alloc] initWithBoardListItem:item] autorelease];
}

- (void)dealloc
{
	[mCursor release];
	mCursor = nil;
	[mCursorLock release];
	mCursorLock = nil;
	[mBoardListItem release];
	mBoardListItem = nil;
	[mSearchString release];
	mSearchString = nil;
	
	[mTask cancel:self];
	[mTask autorelease];
	[mUpdateTask cancel:self];
	[mUpdateTask autorelease];
	[mTaskLock release];
	
	[mSortDescriptors release];
	mSortDescriptors = nil;

	[super dealloc];
}

- (void)registerToNotificationCenter
{
	NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
	CMRFavoritesManager *fm = [CMRFavoritesManager defaultManager];
	[nc addObserver:self
		   selector:@selector(favoritesManagerDidChange:)
			   name:CMRFavoritesManagerDidLinkFavoritesNotification
			 object:fm];
	[nc addObserver:self
		   selector:@selector(favoritesManagerDidChange:)
			   name:CMRFavoritesManagerDidRemoveFavoritesNotification
			 object:fm];

	[super registerToNotificationCenter];
}

- (void)removeFromNotificationCenter
{
	NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
	CMRFavoritesManager *fm = [CMRFavoritesManager defaultManager];

	[nc removeObserver:self
				  name:CMRFavoritesManagerDidLinkFavoritesNotification
				object:fm];
	[nc removeObserver:self
				  name:CMRFavoritesManagerDidRemoveFavoritesNotification
				object:fm];
	[nc removeObserver:self
				  name:BSThreadListUpdateTaskDidFinishNotification
				object:nil];

	[super removeFromNotificationCenter];
}

#pragma mark## Accessor ##
- (void)setBoardListItem:(BoardListItem *)item
{
	id temp = mBoardListItem;
	mBoardListItem = [item retain];
	[temp release];
}

- (BOOL)isFavorites
{
	return [BoardListItem isFavoriteItem:[self boardListItem]];
}

- (BOOL)isSmartItem
{
	return [BoardListItem isSmartItem:[self boardListItem]];
}

- (BOOL)isBoard
{
	return [BoardListItem isBoardItem:[self boardListItem]];
}

- (id)boardListItem
{
	return mBoardListItem;
}

- (id)searchString
{
	return mSearchString;
}

- (NSString *)boardName
{
	return [mBoardListItem name];
}

- (unsigned)numberOfThreads
{
	unsigned count;
	
	@synchronized(mCursorLock) {
		count = [mCursor count];
	}
	
	return count;
}

- (unsigned)numberOfFilteredThreads
{
	return [[self filteredThreads] count];
}

#pragma mark## Sorting ##
- (NSArray *)adjustedSortDescriptors
{
	static NSSortDescriptor *cachedDescriptor = nil;

	if (![CMRPref collectByNew]) {
		return [self sortDescriptors];
	} else {
		if (!cachedDescriptor) {
			cachedDescriptor = [[NSSortDescriptor alloc] initWithKey:@"isnew" ascending:NO selector:@selector(numericCompare:)];
		}

		NSMutableArray *newArray = [[self sortDescriptors] mutableCopy];
		[newArray insertObject:cachedDescriptor atIndex:0];
		return [newArray autorelease];
	}
}

- (void)sortByDescriptors
{
	// お気に入りとスマートボードではindexは飾り
	// TODO 要変更
	if ([self isFavorites] || [self isSmartItem]) {
		if ([[(NSSortDescriptor *)[[self sortDescriptors] objectAtIndex:0] key] isEqualToString:CMRThreadSubjectIndexKey]) {
			return;
		}
	}

	
	@synchronized(mCursorLock) {
		[mCursor autorelease];
		mCursor = [[mCursor sortedArrayUsingDescriptors:[self adjustedSortDescriptors]] retain];
		[self updateFilteredThreadsIfNeeded];
	}
}

- (NSArray *)sortDescriptors
{
	return mSortDescriptors;
}

- (void)setSortDescriptors:(NSArray *)inDescs
{
	UTILAssertKindOfClass(inDescs, NSArray);
	
	id temp = mSortDescriptors;
	mSortDescriptors = [inDescs retain];
	[temp release];
}

#pragma mark## Thread item operations ##
- (void)updateCursor
{
	@synchronized(self) {
		if (mUpdateTask) {
			if ([mUpdateTask isInProgress]) {
				[mUpdateTask cancel:self];
			}
			[[NSNotificationCenter defaultCenter]
				removeObserver:self
						  name:BSThreadListUpdateTaskDidFinishNotification
						object:mUpdateTask];
			[mUpdateTask release];
			mUpdateTask = nil;
		} 
		{
			mUpdateTask = [[BSThreadListUpdateTask taskWithBSDBThreadList:self] retain];
			
			[[NSNotificationCenter defaultCenter]
			addObserver:self
			   selector:@selector(didFinishCreateCursor:)
				   name:BSThreadListUpdateTaskDidFinishNotification
				 object:mUpdateTask];
		}
		[[self worker] push:mUpdateTask];
	}
}

- (void)setCursorOnMainThread:(id)cursor
{
	if (cursor) {
		@synchronized(mCursorLock) {
			NSArray *array = [BSThreadListItem threadItemArrayFromCursor:cursor];
			[mCursor autorelease];
			mCursor = [[array sortedArrayUsingDescriptors:[self adjustedSortDescriptors]] retain];
			UTILDebugWrite1(@"cursor count -> %ld", [mCursor count]);
			[self updateFilteredThreadsIfNeeded];
		}
	}
	
	UTILNotifyName(CMRThreadsListDidChangeNotification);
	UTILNotifyName(BSDBThreadListDidFinishUpdateNotification);
}

- (void)didFinishCreateCursor:(id)notification
{
	id obj = [notification object];
	
	if (![obj isKindOfClass:[BSThreadListUpdateTask class]]) {
		return;
	}
	
	id temp = [[[obj cursor] retain] autorelease];	
	
	[self performSelectorOnMainThread:@selector(setCursorOnMainThread:)
						   withObject:temp
						waitUntilDone:YES];
}

#pragma mark## Filter ##
- (void)updateFilteredThreadsIfNeeded
{
	if (mSearchString && [mSearchString length] > 0) {
		NSPredicate *predicate = [NSPredicate predicateWithFormat:@"threadName CONTAINS[cd] %@", mSearchString];
		[self setFilteredThreads:[mCursor filteredArrayUsingPredicate:predicate]];
	} else {
		[self setFilteredThreads:mCursor];
	}
	UTILDebugWrite1(@"filteredThreads count -> %ld", [[self filteredThreads] count]);
}

- (BOOL)filterByString:(NSString *)string
{
	id tmp = mSearchString;
	mSearchString = [string retain];
	[tmp release];
	
	[self updateFilteredThreadsIfNeeded];
	return YES;
}

#pragma mark## DataSource ##
- (NSDictionary *)paragraphStyleAttrForIdentifier:(NSString *)identifier
{
	static NSMutableParagraphStyle *style_ = nil;
	
	NSDictionary *result = nil;
	
	if (!style_) {
		// 長過ぎる内容を「...」で省略
		style_ = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
		[style_ setLineBreakMode:NSLineBreakByTruncatingTail];
	}

	if ([identifier isEqualToString:ThreadPlistIdentifierKey]) {
		result = [[self class] threadCreatedDateAttrTemplate];
	} else if ([identifier isEqualToString:LastWrittenDateColumn]) {
		result = [[self class] threadLastWrittenDateAttrTemplate];
	} else if ([identifier isEqualToString:CMRThreadModifiedDateKey]) {
		result = [[self class] threadModifiedDateAttrTemplate];
	} else {
		result = [NSDictionary dictionaryWithObjectsAndKeys:style_, NSParagraphStyleAttributeName, nil];
	}

	return result;
}

- (NSDictionary *)threadAttributesAtRowIndex:(int)rowIndex inTableView:(NSTableView *)tableView
{
	BSThreadListItem *row;
	
	@synchronized(mCursorLock) {
		row = [[[[self filteredThreads] objectAtIndex:rowIndex] retain] autorelease];
	}
	
	return [row attribute];
}

- (unsigned int)indexOfThreadWithPath:(NSString *)filepath ignoreFilter:(BOOL)ignores
{
	unsigned result;
	CMRDocumentFileManager *dfm = [CMRDocumentFileManager defaultManager];
	NSString *identifier = [dfm datIdentifierWithLogPath:filepath];
	
	@synchronized(mCursorLock) {
		if (ignores) {
			result = indexOfIdentifier(mCursor, identifier);
		} else {
			result = indexOfIdentifier([self filteredThreads], identifier);
		}
	}
	
	return result;
}

- (unsigned int)indexOfThreadWithPath:(NSString *)filepath
{
	return [self indexOfThreadWithPath:filepath ignoreFilter:NO];
}

- (CMRThreadSignature *)threadSignatureWithTitle:(NSString *)title
{
	BSThreadListItem *row;

	@synchronized(mCursorLock) {
		row = itemOfTitle(mCursor, title);
	}
	
	if (!row) {
		return nil;
	}
	return [CMRThreadSignature threadSignatureWithIdentifier:[row identifier] boardName:[self boardName]];		
}

- (int)numberOfRowsInTableView:(NSTableView *)tableView
{
	UTILDebugWrite1(@"numberOfRowsInTableView -> %ld", [self numberOfFilteredThreads]);
	
	return [self numberOfFilteredThreads];
}

- (id)objectValueForIdentifier:(NSString *)identifier atIndex:(int)index
{
	BSThreadListItem *row;
	id result = nil;
	ThreadStatus s;
	
	@synchronized(mCursorLock) {
		row = [[[_filteredThreads objectAtIndex:index] retain] autorelease];
	}
	
	s = [row status];
	
	if ([identifier isEqualTo:CMRThreadSubjectIndexKey]) {
		result = [row threadNumber];
		if(!result || result == [NSNull null]) {
			result = [NSNumber numberWithInt:index + 1];
		}
	} else if ([identifier isEqualTo:BSThreadEnergyKey]) {
		result = [row valueForKey:identifier];
		UTILAssertKindOfClass(result, NSNumber);

		if ([CMRPref energyUsesLevelIndicator]) {
			double ikioi = [result doubleValue];
			ikioi = log(ikioi); // 対数を取る事で、勢いのむらを少なくする
			if (ikioi < 0) ikioi = 0;
			return [NSNumber numberWithDouble:ikioi];
		}
	} else {
		result = [row valueForKey:identifier];
	}

	// パラグラフスタイルを設定。
	if (result && ![result isKindOfClass:[NSImage class]]) {
		id attr = [self paragraphStyleAttrForIdentifier:identifier];
		if ([result isKindOfClass:[NSDate class]]) {
			result = [[BSDateFormatter sharedDateFormatter] attributedStringForObjectValue:result withDefaultAttributes:attr];
		} else if ([result isKindOfClass:[NSNumber class]]) {
			result = [[BSIkioiNumberFormatter sharedIkioiNumberFormatter] attributedStringForObjectValue:result withDefaultAttributes:attr];
		} else {
			result = [[[NSMutableAttributedString alloc] initWithString:[result stringValue] attributes:attr] autorelease];
		}
	}
	
	// Font and Color を設定。
	int type = (s == ThreadNewCreatedStatus) 
		? kValueTemplateNewArrivalType
		: kValueTemplateDefaultType;
	if ([row isDatOchi]) {
		type = kValueTemplateDatOchiType;
	}
	result = [[self class] objectValueTemplate:result forType:type];

	return result;
}

- (id)tableView:(NSTableView *)aTableView objectValueForTableColumn:(NSTableColumn *)aTableColumn row:(int)rowIndex
{
	NSString		*identifier_ = [aTableColumn identifier];
	
    if ([identifier_ isEqualToString:ThreadPlistIdentifierKey] ||
        [identifier_ isEqualToString:CMRThreadModifiedDateKey] || [identifier_ isEqualToString:LastWrittenDateColumn])
    {
        float location_ = [aTableColumn width];
        location_ -= [aTableView intercellSpacing].width * 2;
        [[self class] resetDataSourceTemplateForColumnIdentifier:identifier_ width:location_];
    }

	return [self objectValueForIdentifier:identifier_ atIndex:rowIndex];
}

- (void)tableView:(NSTableView *)aTableView sortDescriptorsDidChange:(NSArray *)oldDescriptors
{
	UTILDebugWrite(@"Received tableView:sortDescriptorsDidChange: message");

	[self setSortDescriptors:[aTableView sortDescriptors]];
	[self sortByDescriptors];
	[aTableView reloadData];
}

#pragma mark## Notification ##
- (void)favoritesManagerDidChange:(NSNotification *)notification
{
	UTILAssertNotificationObject(
								 notification,
								 [CMRFavoritesManager defaultManager]);
	[self updateCursor];
	
	UTILNotifyName(CMRThreadsListDidChangeNotification);
}

#pragma mark## SearchThread ##
+ (NSMutableDictionary *)attributesForThreadsListWithContentsOfFile:(NSString *)filePath
{
	return [[[[BSThreadListItem threadItemWithFilePath:filePath] attribute] mutableCopy] autorelease];
}
@end

@implementation BSDBThreadList(ToBeRefactoring)
#pragma mark## Download ##
- (void)loadAndDownloadThreadsList:(CMRThreadLayout *)worker forceDownload:(BOOL)forceDL rebuild:(BOOL)flag
{
	//　既に起動中の更新タスクを強制終了させる
	[mTaskLock lock];
	if (mTask) {
		if ([mTask isInProgress]) {
			[mTask cancel:self];
		}
		[mTask release];
		mTask = nil;
	}
	[mTaskLock unlock];
	
	if ([self isFavorites] || [self isSmartItem]) {
		if (forceDL) {
			[mTaskLock lock];
			mTask = [[BSBoardListItemHEADCheckTask alloc] initWithThreadList:self];
			[worker push:mTask];
			[mTaskLock unlock];
		} else {
			[self updateCursor];
		}
	} else {
		[mTaskLock lock];
		mTask = [[BSThreadsListOPTask alloc] initWithThreadList:self forceDownload:forceDL rebuild:flag];
		[worker push:mTask];
		[mTaskLock unlock];
	}
}

- (void)doLoadThreadsList:(CMRThreadLayout *)worker
{
	[self setWorker:worker]; // ????
	[self loadAndDownloadThreadsList:worker forceDownload:NO rebuild:NO];
}

- (void)downloadThreadsList
{
	[self loadAndDownloadThreadsList:[self worker] forceDownload:YES rebuild:NO];
}

- (void)rebuildThreadsList
{
	unsigned boardId = [[self boardListItem] boardID];
	if (![[DatabaseManager defaultManager] deleteAllRecordsOfBoard:boardId]) {
		return;
	}

	[self loadAndDownloadThreadsList:[self worker] forceDownload:YES rebuild:YES];
}
@end
