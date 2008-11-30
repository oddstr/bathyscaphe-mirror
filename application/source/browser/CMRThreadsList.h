/**
  * $Id: CMRThreadsList.h,v 1.24 2008/11/30 15:51:33 tsawada2 Exp $
  * 
  * CMRThreadsList.h
  *
  * Copyright (c) 2003, Takanori Ishikawa.
  * See the file LICENSE for copying permission.
  */
#import <Cocoa/Cocoa.h>
#import "CocoMonar_Prefix.h"

@class CMRThreadLayout;
@class CMRThreadSignature;

enum {
	kValueTemplateDefaultType,
	kValueTemplateNewArrivalType,
	kValueTemplateNewUnknownType,
	kValueTemplateDatOchiType // Available in Starlight Breaker.
};

@interface CMRThreadsList : NSObject 
{
	CMRThreadLayout			*_worker;
	
	NSMutableArray			*_threads;
	NSMutableArray			*_filteredThreads;
}
/**
  * 
  * 読み込みを開始。
  * 初期化したクラスは直後に呼び出すこと。
  * workerを保持する。
  * 
  */
- (void)startLoadingThreadsList:(CMRThreadLayout *)worker;
- (void)doLoadThreadsList:(CMRThreadLayout *)worker;
- (CMRThreadLayout *)worker;
- (void)setWorker:(CMRThreadLayout *)aWorker;

- (BOOL)isFavorites;
- (BOOL)isSmartItem;
- (BOOL)isBoard; // Available in Tenori Tiger.

- (void)rebuildThreadsList; // Available in Tenori Tiger.
@end


@interface CMRThreadsList(CleanUp)
- (void)cleanUpItemsToBeRemoved:(NSArray *)files;

// Available in BathyScaphe 1.6.2 and later.
//- (BOOL)tableView:(NSTableView *)tableView removeFilesAtRowIndexes:(NSIndexSet *)rowIndexes ask:(BOOL)flag;

- (BOOL)tableView:(NSTableView *)tableView removeFiles:(NSArray *)files delFavIfNecessary:(BOOL)flag;
- (BOOL)removeDatochiFiles;
@end


@interface CMRThreadsList(AccessingList)
- (NSMutableArray *)threads;
- (void)setThreads:(NSMutableArray *)aThreads;
- (NSMutableArray *)filteredThreads;
- (void)setFilteredThreads:(NSArray *)aFilteredThreads;
@end

 
@interface CMRThreadsList(Attributes)
- (NSString *)boardName;
- (NSURL *)boardURL;

- (unsigned)numberOfThreads;
- (unsigned)numberOfFilteredThreads;
@end



@interface CMRThreadsList(Filter)
// Available in MeteorSweeper.
- (BOOL)filterByString:(NSString *)searchString;
@end


@interface CMRThreadsList(DataSource)
+ (void)resetDataSourceTemplates;
+ (void)resetDataSourceTemplateForColumnIdentifier:(NSString *)identifier width:(float)loc;
+ (void)resetDataSourceTemplateForDateColumn;

+ (NSDictionary *)threadCreatedDateAttrTemplate;
+ (NSDictionary *)threadModifiedDateAttrTemplate;
+ (NSDictionary *)threadLastWrittenDateAttrTemplate;

+ (id)objectValueTemplate:(id)aValue forType:(int)aType;

- (NSString *)threadFilePathAtRowIndex:(int)rowIndex inTableView:(NSTableView *)tableView status:(ThreadStatus *)status;
- (NSDictionary *)threadAttributesAtRowIndex:(int)rowIndex inTableView:(NSTableView *)tableView;
- (NSString *)threadTitleAtRowIndex:(int)rowIndex inTableView:(NSTableView *)tableView;

- (CMRThreadSignature *)threadSignatureWithTitle:(NSString *)title; // Available in SilverGull and later.

- (unsigned int)indexOfThreadWithPath:(NSString *)filepath;
- (unsigned int)indexOfThreadWithPath:(NSString *)filepath ignoreFilter:(BOOL)ignores; // Available in BathyScaphe 1.6.2 and later.

- (NSArray *)tableView:(NSTableView *)aTableView threadFilePathsArrayAtRowIndexes:(NSIndexSet *)rowIndexes;
- (NSArray *)tableView:(NSTableView *)aTableView threadAttibutesArrayAtRowIndexes:(NSIndexSet *)rowIndexes exceptingPath:(NSString *)filepath;

- (void)tableView:(NSTableView *)aTableView didEndDragging:(NSDragOperation)operation; // Available in BathyScaphe 1.6.2 and later.
- (void)tableView:(NSTableView *)aTableView revealFilesAtRowIndexes:(NSIndexSet *)rowIndexes;
- (void)tableView:(NSTableView *)aTableView quickLookAtRowIndexes:(NSIndexSet *)rowIndexes;
- (void)tableView:(NSTableView *)aTableView openURLsAtRowIndexes:(NSIndexSet *)rowIndexes;
@end

@interface CMRThreadsList(DraggingImage)
- (NSImage *)dragImageForRowIndexes:(NSIndexSet *)rowIndexes
						inTableView:(NSTableView *)tableView
							 offset:(NSPointPointer)dragImageOffset;
@end


@interface CMRThreadsList(Download)
- (void)downloadThreadsList;
@end


@interface CMRThreadsList(ListImport)
+ (NSMutableDictionary *)attributesForThreadsListWithContentsOfFile:(NSString *)path;
@end

// Notification
extern NSString *const CMRThreadsListDidUpdateNotification;
extern NSString *const CMRThreadsListDidChangeNotification;
extern NSString *const ThreadsListUserInfoSelectionHoldingMaskKey;
