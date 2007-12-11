//
//  CMRFavoritesManager.m
//  BathyScaphe
//
//  Updated by Tsutomu Sawada on 07/12/09.
//  Copyright 2005-2007 BathyScaphe Project. All rights reserved.
//  encoding="UTF-8"
//

#import "CMRFavoritesManager.h"
#import "CocoMonar_Prefix.h"

#import "CMRThreadAttributes.h"
#import "CMRThreadSignature.h"
#import "CMRTrashbox.h"
#import "CMRDocumentFileManager.h"
#import "BSDBThreadList.h"
#import "DatabaseManager.h"
#import "BSThreadListItem.h"

NSString *const CMRFavoritesManagerDidLinkFavoritesNotification = @"CMRFavoritesManagerDidLinkFavoritesNotification";
NSString *const CMRFavoritesManagerDidRemoveFavoritesNotification = @"CMRFavoritesManagerDidRemoveFavoritesNotification";

static NSString *const kFavIdKey = @"identifier";
static NSString *const kFavBoardNameKey = @"boardName";
static NSString *const kFavStatusKey = @"status";
static NSString *const kFavDatOchiKey = @"isDatOchi";

static NSString *const kFavFileVersionKey = @"CMRFavoritesManager_Version";
static NSString *const kFavFileDataKey = @"Data";

@implementation CMRFavoritesManager
APP_SINGLETON_FACTORY_METHOD_IMPLEMENTATION(defaultManager);

+ (int)version
{
	return 1;
}

- (id)init
{
	if (self = [super init]) {
		[[NSNotificationCenter defaultCenter]
				 addObserver:self
					selector:@selector(trashDidPerform:)
					    name:CMRTrashboxDidPerformNotification
					  object:[CMRTrashbox trash]];
	}
	return self;
}

- (void)dealloc
{
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	[super dealloc];
}

- (void)trashDidPerform:(NSNotification *)notification
{	
	UTILAssertNotificationName(notification, CMRTrashboxDidPerformNotification);
	UTILAssertNotificationObject(notification, [CMRTrashbox trash]);
	
	NSDictionary *userInfo_ = [notification userInfo];
	if ([userInfo_ integerForKey:kAppTrashUserInfoStatusKey] != noErr) return;

	BOOL	doNotDelFav_ = [userInfo_ boolForKey:kAppTrashUserInfoAfterFetchKey];
	if (doNotDelFav_) return;

	NSArray			*pathArray_ = [userInfo_ objectForKey:kAppTrashUserInfoFilesKey];
	NSEnumerator	*iter_;
	NSString		*aPath_;

	iter_ = [pathArray_ objectEnumerator];

	while (aPath_ = [iter_ nextObject]) {
		if ([self availableOperationWithPath:aPath_] == CMRFavoritesOperationRemove) {
			[self removeFromFavoritesWithFilePath:aPath_];
		}
	}
}

- (CMRFavoritesOperation)availableOperationWithThread:(id)thread
{
	id identifier;
	id boardName = [thread valueForKey:ThreadPlistBoardNameKey];
	id boardIDs;
	
	identifier = [CMRThreadAttributes identifierFromDictionary:thread];
	boardIDs = [[DatabaseManager defaultManager] boardIDsForName:boardName];
	
	if (!identifier || !boardIDs) return CMRFavoritesOperationNone;
	
	/* TODO 
		複数存在する場合の処理
*/
	unsigned boardID;
	boardID = [[boardIDs objectAtIndex:0] unsignedIntValue];
	
	BOOL isFavorite;
	isFavorite = [[DatabaseManager defaultManager] isFavoriteThreadIdentifier:identifier onBoardID:boardID];
	
	return isFavorite ? CMRFavoritesOperationRemove : CMRFavoritesOperationLink;
}

- (CMRFavoritesOperation)availableOperationWithPath:(NSString *)filepath
{
	NSDictionary	*attr_;
	
	if (!filepath) return CMRFavoritesOperationNone;
	
	attr_ = [BSDBThreadList attributesForThreadsListWithContentsOfFile:filepath];
	// [Bug 10077] 回避のための強引な処理
	if (!attr_) {
		BOOL result_;
		result_ = [[DatabaseManager defaultManager] registerThreadFromFilePath:filepath];
		if (!result_) {
			return CMRFavoritesOperationNone;
		} else {
			return CMRFavoritesOperationLink;
		}
	}
	return [self availableOperationWithThread:attr_];
}

- (CMRFavoritesOperation)availableOperationWithSignature:(CMRThreadSignature *)signature registered:(BOOL *)boolPtr
{
	id identifier = [signature identifier];
	id boardName = [signature boardName];
	id boardIDs;

	boardIDs = [[DatabaseManager defaultManager] boardIDsForName:boardName];

	if (!identifier || !boardIDs ) return CMRFavoritesOperationNone;

	/* TODO 
		複数存在する場合の処理
*/
	unsigned boardID;
	boardID = [[boardIDs objectAtIndex:0] unsignedIntValue];
	
	BOOL isFavorite;
	isFavorite = [[DatabaseManager defaultManager] isFavoriteThreadIdentifier:identifier onBoardID:boardID];

	if (boolPtr != NULL) *boolPtr = [[DatabaseManager defaultManager] isThreadIdentifierRegistered:identifier onBoardID:boardID];
	
	return isFavorite ? CMRFavoritesOperationRemove : CMRFavoritesOperationLink;
}

- (CMRFavoritesOperation)availableOperationWithSignature:(CMRThreadSignature *)signature
{
	return [self availableOperationWithSignature:signature registered:NULL];
}

- (BOOL)canCreateFavoriteLinkFromPath:(NSString *)filepath
{
	return (CMRFavoritesOperationLink == [self availableOperationWithPath:filepath]);
}

- (BOOL)favoriteItemExistsOfThreadPath:(NSString *)filepath
{
	UTILAssertNotNil(filepath);
	return (CMRFavoritesOperationRemove == [self availableOperationWithPath:filepath]);
}

- (BOOL)favoriteItemExistsOfThreadSignature:(CMRThreadSignature *)signature registeredToDatabase:(BOOL *)boolPtr
{
	UTILAssertNotNil(signature);
	return (CMRFavoritesOperationRemove == [self availableOperationWithSignature:signature registered:boolPtr]);
}

- (BOOL)favoriteItemExistsOfThreadSignature:(CMRThreadSignature *)signature
{
	UTILAssertNotNil(signature);
	return (CMRFavoritesOperationRemove == [self availableOperationWithSignature:signature]);
}

- (BOOL)addFavoriteWithThread:(id)threadIdentifier ofBoard:(NSString *)boardName
{
	id			boardIDs; /* TODO 複数存在する場合の処理 */
	BOOL		isSuccess = NO;
	
	boardIDs = [[DatabaseManager defaultManager] boardIDsForName:boardName];
	if (!boardIDs) return NO;
	
	isSuccess = [[DatabaseManager defaultManager] appendFavoriteThreadIdentifier:threadIdentifier
																	   onBoardID:[[boardIDs objectAtIndex:0] unsignedIntValue]];
	
	if (isSuccess)
		UTILNotifyName(CMRFavoritesManagerDidLinkFavoritesNotification);
	
	return isSuccess;
}

- (BOOL)addFavoriteWithThread:(NSDictionary *)thread
{
	id identifier;
	id boardName = [thread valueForKey:ThreadPlistBoardNameKey];
	
	identifier = [CMRThreadAttributes identifierFromDictionary:thread];
	if(!identifier) return NO;
	return [self addFavoriteWithThread:identifier ofBoard:boardName];
}

- (BOOL)addFavoriteWithFilePath:(NSString *)filepath
{
	NSDictionary	*attr_;
	
	if (!filepath || ![self canCreateFavoriteLinkFromPath:filepath]) return NO;
	
	attr_ = [BSDBThreadList attributesForThreadsListWithContentsOfFile:filepath];
	if (!attr_) return NO;
	
	return [self addFavoriteWithThread:attr_];
}

- (BOOL)addFavoriteWithSignature:(CMRThreadSignature *)signature
{
	if (!signature) return NO;

	return [self addFavoriteWithThread:[signature identifier] ofBoard:[signature boardName]];
}

- (BOOL)removeFavoriteWithThread:(id)threadIdentifier ofBoard:(NSString *)boardName
{
	id			boardIDs; /* TODO 複数存在する場合の処理 */
	BOOL		isSuccess = NO;
	
	boardIDs = [[DatabaseManager defaultManager] boardIDsForName:boardName];
	if (!boardIDs) return NO;
	
	isSuccess = [[DatabaseManager defaultManager] removeFavoriteThreadIdentifier:threadIdentifier
																	   onBoardID:[[boardIDs objectAtIndex:0] unsignedIntValue]];
	
	if (isSuccess)
		UTILNotifyName(CMRFavoritesManagerDidRemoveFavoritesNotification);
	
	return isSuccess;
}

- (BOOL)removeFromFavoritesWithFilePath:(NSString *)filepath
{
	if (!filepath) return NO;
	CMRThreadSignature *signature_ = [CMRThreadSignature threadSignatureFromFilepath:filepath];
	return [self removeFromFavoritesWithSignature:signature_];
}

- (BOOL)removeFromFavoritesWithSignature:(CMRThreadSignature *)signature
{	
	if (!signature) return NO;

	return [self removeFavoriteWithThread:[signature identifier] ofBoard:[signature boardName]];
}
@end


@implementation CMRFavoritesManager(ImportAndExport)
- (NSPanel *)progressPanel
{
	if (!m_progressPanel) {
		[NSBundle loadNibNamed:@"BSFavoritesProgressPanel" owner:self];
	}
	return m_progressPanel;
}

- (BOOL)exportFavoritesToFile:(NSString *)filepath atomically:(BOOL)atomically
{
	SQLiteDB *db;
	id<SQLiteCursor> cursor;
	unsigned rowCount;

	NSMutableArray		*exportingArray;
	NSArray				*threadListItems;
	BSThreadListItem	*eachItem;
	NSEnumerator		*iter;
	NSDictionary		*dict;
	NSDictionary		*exportingDict;

	NSMutableString *query = [NSMutableString string];
	[query appendFormat:@"SELECT * FROM %@ AS a\n", BoardThreadInfoViewName];
	[query appendFormat:@"WHERE EXISTS (SELECT %@ FROM %@ AS b WHERE a.%@ = b.%@ AND a.%@ = b.%@)",
		ThreadIDColumn, FavoritesTableName, ThreadIDColumn, ThreadIDColumn, BoardIDColumn, BoardIDColumn];

	db = [[DatabaseManager defaultManager] databaseForCurrentThread];
	if (!db) {
		return NO;
	}

//	NSPanel *panel = [self progressPanel];
	NSModalSession foo = [NSApp beginModalSessionForWindow:[self progressPanel]];
	[NSApp runModalSession:foo];
	[m_progressBar setIndeterminate:YES];
	[m_progressBar startAnimation:self];

	cursor = [db performQuery:query];
	
	if (!cursor) {
		[NSApp endModalSession:foo];
	[[self progressPanel] orderOut:nil];
		return NO;
	}
	
	rowCount = [cursor rowCount];
	if (rowCount == 0 || [cursor columnCount] == 0) {
		[NSApp endModalSession:foo];
	[[self progressPanel] orderOut:nil];
		return NO;
	}

	[m_progressBar setMaxValue:(double)rowCount];
	[m_progressBar setDoubleValue:0];
	[m_progressBar stopAnimation:self];
	[m_progressBar setIndeterminate:NO];
	exportingArray = [NSMutableArray arrayWithCapacity:rowCount];
	threadListItems = [BSThreadListItem threadItemArrayFromCursor:cursor];

	iter = [threadListItems objectEnumerator];
	while (eachItem = [iter nextObject]) {
		dict = [NSDictionary dictionaryWithObjectsAndKeys:[eachItem identifier], kFavIdKey,
														  [eachItem boardName], kFavBoardNameKey,
														  [NSNumber numberWithUnsignedInt:[eachItem status]], kFavStatusKey,
														  [NSNumber numberWithBool:[eachItem isDatOchi]], kFavDatOchiKey,
														  NULL];
		if (dict) [exportingArray addObject:dict];
		[m_progressBar setDoubleValue:([m_progressBar doubleValue]+1)];
	}

	exportingDict = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:[[self class] version]], kFavFileVersionKey,
															   exportingArray, kFavFileDataKey,
															   NULL];
	BOOL	hoge = [exportingDict writeToFile:filepath atomically:atomically];
	[NSApp endModalSession:foo];
	[[self progressPanel] orderOut:nil];
	return hoge;//[exportingDict writeToFile:filepath atomically:atomically];
}

- (BOOL)importFavoritesFromFile:(NSString *)filepath
{
	NSDictionary	*dict = [NSDictionary dictionaryWithContentsOfFile:filepath];
	if (!dict) return NO;

	id	version = [dict objectForKey:kFavFileVersionKey];
	if (!version || ![version isKindOfClass:[NSNumber class]]) return NO;

	int verInt = [version intValue];
	if (verInt != 1) return NO;
	
	NSArray *array = [dict arrayForKey:kFavFileDataKey];
	if (!array) return NO;

	NSEnumerator	*iter = [array objectEnumerator];
	DatabaseManager	*dbm = [DatabaseManager defaultManager];
	NSDictionary	*eachItem;

	NSString *identifier;
	NSString *boardName;
	CMRThreadSignature	*sign;
	BOOL		isRegistered;

	while (eachItem = [iter nextObject]) {
		identifier = [eachItem objectForKey:kFavIdKey];
		boardName = [eachItem objectForKey:kFavBoardNameKey];
		sign = [CMRThreadSignature threadSignatureWithIdentifier:identifier boardName:boardName];
		if (![self favoriteItemExistsOfThreadSignature:sign registeredToDatabase:&isRegistered]) {
			if (!isRegistered) {
				NSString *threadPath = [sign threadDocumentPath];
				[dbm registerThreadFromFilePath:threadPath];
			}
			[self addFavoriteWithSignature:sign];
		} else {
			NSLog(@"Skipped importing %@ (already exists)", identifier);
		}
	}
	return YES;
}
@end
