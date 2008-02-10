//
//  BSThreadListItem.m
//  BathyScaphe
//
//  Created by Hori,Masaki on 07/03/18.
//  Copyright 2007 BathyScaphe Project. All rights reserved.
//

#import "BSThreadListItem.h"

#import "DatabaseManager.h"
#import "CMRDocumentFileManager.h"
#import <SGAppKit/NSImage-SGExtensions.h>

static inline BOOL searchBoardIDAndThreadIDFromFilePath( unsigned *outBoardID, NSString **outThreadID, NSString *inFilePath );
static inline NSImage *_statusImageWithStatusBSDB(ThreadStatus s);
static inline NSArray *dateTypeKeys();
static inline NSArray *numberTypeKeys();
static inline NSArray *threadListIdentifiers();
static inline BSThreadListItem *itemFromRow(id <SQLiteRow> row);

static NSString *const BSThreadListItemErrorDomain = @"BSThreadListItemErrorDomain";
#define BSThreadListItemClassMismatchError	1
#define BSThreadListItemStatusMismatchError	2

@implementation BSThreadListItem

- (id)init
{
	self = [super init];
	data = [[NSMutableDictionary alloc] init];
	
	return self;
}

- (id)initWithIdentifier:(NSString *)identifier boardID:(unsigned)boardID boardName:(NSString *)boardName
{
	if(self = [super init]) {
		if(boardID == 0) {
			[self release];
			return nil;
		}
		
		data = [[NSMutableDictionary alloc] init];
		[data  setValue:identifier forKey:[ThreadIDColumn lowercaseString]];
		[data setValue:[NSNumber numberWithUnsignedInt:boardID] forKey:[BoardIDColumn lowercaseString]];
		if(boardName) [data setValue:boardName forKey:[BoardNameColumn lowercaseString]];
	}
	
	return self;
}
+ (id)threadItemWithIdentifier:(NSString *)identifier boardID:(unsigned)boardID
{
	return [[[[self class] alloc] initWithIdentifier:identifier boardID:boardID] autorelease];
}
- (id)initWithIdentifier:(NSString *)identifier boardID:(unsigned)boardID
{
	return [self initWithIdentifier:identifier boardID:boardID boardName:nil];
}
+ (id)threadItemWithIdentifier:(NSString *)identifier boardName:(NSString *)boardName
{
	return [[[[self class] alloc] initWithIdentifier:identifier boardName:boardName] autorelease];
}
- (id)initWithIdentifier:(NSString *)identifier boardName:(NSString *)boardName
{
	NSArray *boardIDs = [[DatabaseManager defaultManager] boardIDsForName:boardName];
	unsigned boardID;
	
	boardID = [[boardIDs objectAtIndex:0] intValue];
	
	return [self initWithIdentifier:identifier boardID:boardID boardName:boardName];
}
+ (id)threadItemWithFilePath:(NSString *)path
{
	return [[[[self class] alloc] initWithFilePath:path] autorelease];
}
- (id)initWithFilePath:(NSString *)path
{
	unsigned boardID = 0;
	NSString *identifier = nil;
	
	if(!searchBoardIDAndThreadIDFromFilePath( &boardID, &identifier, path)) {
		[[super init] release];
		return nil;
	}
	
	return [self initWithIdentifier:identifier boardID:boardID];
}
- (void)dealloc
{
	[data release];
	[super dealloc];
}

+ (NSArray *)threadItemArrayFromCursor:(id <SQLiteCursor>)cursor
{
//	return [[[BSThreadListItemArray alloc] initWithCorsor:cursor] autorelease];
	
	NSMutableArray *result;
	unsigned i, count;
	
	count = [cursor rowCount];
	result = [NSMutableArray arrayWithCapacity:count];
	
	for(i = 0; i < count; i++) {
		id item = itemFromRow([cursor rowAtIndex:i]);
		[result addObject:item];
	}
	
	return result;
}

- (NSString *)description
{
	return [NSString stringWithFormat:@"%@ <%@(%d), %@(%d)>",
		NSStringFromClass([self class]), [self boardName], [self boardID], [self threadName], [self identifier]];
}

#pragma mark## Accessor ##
- (NSString *)identifier
{
	return [self cachedValueForKey:ThreadIDColumn];
}
- (NSString *)boardName
{
	return [self valueForKey:BoardNameColumn];
}
- (unsigned)boardID
{
	return [[self cachedValueForKey:BoardIDColumn] unsignedIntValue];
}
- (NSString *)threadName
{
	return [self valueForKey:ThreadNameColumn];
}
- (NSString *)threadFilePath
{
	return [[CMRDocumentFileManager defaultManager] threadPathWithBoardName:[self boardName]
															  datIdentifier:[self identifier]];
}
- (ThreadStatus)status
{
	return [[self valueForKey:ThreadStatusColumn] unsignedIntValue];
}

- (NSNumber *)responseNumber
{
	return [self valueForKey:NumberOfAllColumn];
}
- (NSNumber *)readNumber
{
	return [self valueForKey:NumberOfReadColumn];
}
- (NSNumber *)delta
{
	id res = [self responseNumber];
	id read = [self readNumber];
	
	if(!res || !read) return nil;
	if(res == [NSNull null] || read == [NSNull null]) return nil;
	
	unsigned delta = [res intValue] - [read intValue];
	return [NSNumber numberWithInt:delta];
}
- (NSDate *)creationDate
{
	return [NSDate dateWithTimeIntervalSince1970:[[self identifier] doubleValue]];
}
- (NSDate *)modifiredDate
{
	return [self valueForKey:ModifiedDateColumn];
}
- (NSDate *)lastWrittenDate
{
	return [self valueForKey:LastWrittenDateColumn];
}
- (BOOL)isDatOchi
{
	return [[self valueForKey:IsDatOchiColumn] intValue];
}

- (NSNumber *)threadNumber
{
	return [self valueForKey:TempThreadThreadNumberColumn];
}

- (NSImage *)statusImage
{
	return _statusImageWithStatusBSDB([self status]);
}

- (NSDictionary *)attribute
{
	NSMutableDictionary *result = [NSMutableDictionary dictionaryWithCapacity:7];
	
	[result setValue:[self threadName] forKey:CMRThreadTitleKey];
	[result setValue:[[self responseNumber] stringValue] forKey:CMRThreadNumberOfMessagesKey];
	[result setValue:[self identifier] forKey:ThreadPlistIdentifierKey];
	[result setValue:[self boardName] forKey:ThreadPlistBoardNameKey];
	[result setValue:[NSString stringWithFormat:@"%u",[self status]]
			  forKey:CMRThreadUserStatusKey];
	[result setValue:[self modifiredDate] forKey:CMRThreadModifiedDateKey];
	[result setValue:[self threadFilePath] forKey:CMRThreadLogFilepathKey];
	
	return result;
}

- (id)threadListValueForKey:(NSString *)key
{
	if([key isEqualToString:CMRThreadTitleKey]) {
		return [self threadName];
	} else if([key isEqualToString:CMRThreadLastLoadedNumberKey]) {
		return [self readNumber];
	} else if([key isEqualToString:CMRThreadNumberOfMessagesKey]) {
		return [self responseNumber];
	} else if([key isEqualToString:CMRThreadNumberOfUpdatedKey]) {
		return [self delta];
	} else if([key isEqualToString:CMRThreadSubjectIndexKey]) {
		return [self threadNumber];
	} else if([key isEqualToString:CMRThreadStatusKey]) {
		return [self statusImage];
	} else if([key isEqualToString:CMRThreadModifiedDateKey]) {
		return [self modifiredDate];
	} else if([key isEqualToString:ThreadPlistIdentifierKey]) {
		return [self creationDate];
	} else if([key isEqualToString:ThreadPlistBoardNameKey]) {
		return [self boardName];
	}
	
	return nil;
}

- (NSArray *)directAcceptKeys
{
	NSArray *array;
	
	array = [NSArray arrayWithObjects:
			 BoardIDColumn,
			 BoardNameColumn,
			 ThreadNameColumn,
			 NumberOfAllColumn,
			 NumberOfReadColumn,
			 ModifiedDateColumn,
			 ThreadStatusColumn,
			 ThreadAboneTypeColumn,
			 ThreadLabelColumn,
			 LastWrittenDateColumn,
			 TempThreadThreadNumberColumn,
			 IsDatOchiColumn,
			 IsNewColumn,
			 nil];
	
	return array;
}

- (id)valueForUndefinedKey:(NSString *)key
{
	// 例外が発生するとやっかいなのでオーバーライド
	return nil;
}
- (id)valueForKey:(NSString *)key
{
	id result = [self cachedValueForKey:key];
	if(result == [NSNull null]) return nil;
	if(result) return result;
	
	result = [self threadListValueForKey:key];
	if(result) {
//		[self setCachedValue:result forKey:key];
		if(result == [NSNull null]) return nil;
		return result;
	}
	
	result = [[DatabaseManager defaultManager] valueForKey:key
													  boardID:[self boardID]
													 threadID:[self identifier]];
	
	if(!result) {
		NSLog(@"Can not find %@ for boardName(%@) threadID(%@)",
			  key, [self cachedValueForKey:BoardNameColumn], [self identifier]);
		result = [self valueForUndefinedKey:key];
	} else if(result == [NSNull null]) {
		[self setCachedValue:result forKey:key];
		return nil;
	}
	
	if([dateTypeKeys() containsObject:key] && ![result isKindOfClass:[NSDate class]]) {
		result = [NSDate dateWithTimeIntervalSince1970:[result doubleValue]];
	} else if([numberTypeKeys() containsObject:key] && ![result isKindOfClass:[NSNumber class]]) {
		result = [NSNumber numberWithDouble:[result doubleValue]];
	}
	
	if(result) {
		[self setCachedValue:result forKey:key];
	}
	
	return result;
}
- (void)setValue:(id)value forKey:(NSString *)key
{
	BOOL accepted = NO;
	if([[self directAcceptKeys] containsObject:key]) {
		accepted = YES;
	}
	
	if(accepted) {
		if([dateTypeKeys() containsObject:key] && ![value isKindOfClass:[NSDate class]]) {
			if([value isKindOfClass:[NSString class]] || [value isKindOfClass:[NSNumber class]]) {
				value = [NSDate dateWithTimeIntervalSince1970:[value doubleValue]];
			}
		}
		[self setCachedValue:value forKey:key];
	} else {
		[super setValue:value forKey:key];
	}
}

- (id) cachedValueForKey:(NSString *)key
{
	return [data valueForKey:[key lowercaseString]];
}

- (void) setCachedValue:(id)value forKey:(NSString *)key
{
	if([ThreadIDColumn isEqualToString:key]) return;
	if([ThreadPlistIdentifierKey isEqualToString:key]) return;
	
	NSString *cacheKey = tableNameForKey(key);
	if(cacheKey && ![CMRThreadStatusKey isEqualToString:key]) key = cacheKey;
	
	if([dateTypeKeys() containsObject:key] && ![value isKindOfClass:[NSDate class]]) {
		if([value isKindOfClass:[NSString class]] || [value isKindOfClass:[NSNumber class]]) {
			value = [NSDate dateWithTimeIntervalSince1970:[value doubleValue]];
		}
	}
	
	[data setValue:value forKey:[key lowercaseString]];
}

#pragma mark## Functions ##
static inline NSArray *dateTypeKeys()
{
	static NSArray *result = nil;
	
	if(!result) {
		@synchronized([BSThreadListItem class]) {
			if(!result) {
				result = [NSArray arrayWithObjects:
					ModifiedDateColumn,
					LastWrittenDateColumn,
					
					[ModifiedDateColumn lowercaseString],
					[LastWrittenDateColumn lowercaseString],
					nil];
				[result retain];
			}
		}
	}
	
	return result;
}
static inline NSArray *numberTypeKeys()
{
	static NSArray *result = nil;
	
	if(!result) {
		@synchronized([BSThreadListItem class]) {
			if(!result) {
				result = [NSArray arrayWithObjects:
					NumberOfAllColumn,
					NumberOfReadColumn,
					NumberOfDifferenceColumn,
					TempThreadThreadNumberColumn,
					IsNewColumn,
					
					[NumberOfAllColumn lowercaseString],
					[NumberOfReadColumn lowercaseString],
					[NumberOfDifferenceColumn lowercaseString],
					[TempThreadThreadNumberColumn lowercaseString],
					[IsNewColumn lowercaseString],
					
					nil];
				[result retain];
			}
		}
	}
	
	return result;
}
static inline NSArray *threadListIdentifiers()
{
	static NSArray *result = nil;
	
	if(!result) {
		@synchronized([BSThreadListItem class]) {
			if(!result) {
				result = [NSArray arrayWithObjects:
					CMRThreadTitleKey,
					CMRThreadLastLoadedNumberKey,
					CMRThreadNumberOfMessagesKey,
					CMRThreadNumberOfUpdatedKey,
					CMRThreadSubjectIndexKey,
					CMRThreadStatusKey,
					CMRThreadModifiedDateKey,
					ThreadPlistIdentifierKey,
					ThreadPlistBoardNameKey,
					IsNewColumn,
					nil];
				[result retain];
			}
		}
	}
	
	return result;
}

static inline BOOL searchBoardIDAndThreadIDFromFilePath(unsigned *outBoardID, NSString **outThreadID, NSString *inFilePath)
{
	CMRDocumentFileManager *dfm = [CMRDocumentFileManager defaultManager];
	unsigned boardID;
	NSString *threadID;
	
	threadID = [dfm datIdentifierWithLogPath : inFilePath];
	
	{
		NSString *boardName;
		NSArray *boardIDs;
		id boardIDstring;
		
		boardName = [dfm boardNameWithLogPath : inFilePath];
		if (!boardName) return NO;
		
		boardIDs = [[DatabaseManager defaultManager] boardIDsForName : boardName];
		if (!boardIDs || [boardIDs count] == 0) return NO;
		
		boardIDstring = [boardIDs objectAtIndex : 0];
		
		boardID = [boardIDstring unsignedIntValue];
	}
	
	id threadName = [[DatabaseManager defaultManager] valueForKey:ThreadNameColumn
														  boardID:boardID
														 threadID:threadID];
	if(!threadName) {
		[[DatabaseManager defaultManager] registerThreadFromFilePath:inFilePath];
	}
	
	if(outThreadID) {
		*outThreadID = threadID;
	}
	if(outBoardID) {
		*outBoardID = boardID;
	}
	
	return YES;
}

// Status image
#define kStatusUpdatedImageName		@"Status_updated"
#define kStatusCachedImageName		@"Status_logcached"
#define kStatusNewImageName			@"Status_newThread"
#define kStatusHEADModImageName		@"Status_HeadModified"
static inline NSImage *_statusImageWithStatusBSDB(ThreadStatus s)
{
	switch (s){
		case ThreadLogCachedStatus :
			return [NSImage imageAppNamed : kStatusCachedImageName];
		case ThreadUpdatedStatus :
			return [NSImage imageAppNamed : kStatusUpdatedImageName];
		case ThreadNewCreatedStatus :
			return [NSImage imageAppNamed : kStatusNewImageName];
		case ThreadHeadModifiedStatus :
			return [NSImage imageAppNamed : kStatusHEADModImageName];
		case ThreadNoCacheStatus :
			return nil;
		default :
			return nil;
	}
	return nil;
}

@end

static inline NSArray *mustContainsKeys()
{
	static NSArray *array = nil;
	
	if(!array) {
		array = [NSArray arrayWithObjects:
			BoardIDColumn, BoardNameColumn,
			ThreadIDColumn, ThreadNameColumn, NumberOfAllColumn,
			NumberOfReadColumn, ModifiedDateColumn, ThreadStatusColumn,
			//		ThreadLabelColumn,
			IsDatOchiColumn,
			IsNewColumn,
			nil];
		[array retain];
	}
	
	return array;
}
static inline BSThreadListItem *itemFromRow(id <SQLiteRow> row)
{
	id item = [BSThreadListItem threadItemWithIdentifier:[row valueForColumn:ThreadIDColumn]
												 boardID:[[row valueForColumn:BoardIDColumn] unsignedIntValue]];
	
	if(!item) return nil;
	
	id en = [mustContainsKeys() objectEnumerator];
	id key;
	while(key = [en nextObject]) {
		if([key isEqualTo:BoardIDColumn] || [key isEqualTo:ThreadIDColumn]) {
			continue;
		}
		[item setValue:[row valueForColumn:key] forKey:key];
	}
	
	if([row valueForColumn:TempThreadThreadNumberColumn]) {
		[item setValue:[row valueForColumn:TempThreadThreadNumberColumn]
				  forKey:TempThreadThreadNumberColumn];
	}
	
	return item;
}

unsigned indexOfIdentifier(NSArray *array, NSString *search)
{
	unsigned i, count;
	id object;
	id identifier;
	
	count = [array count];
	if(count == 0) return NSNotFound;
	
	for(i = 0; i < count; i++ ) {
		object = [array objectAtIndex:i];
		identifier = [object identifier];
		if([search isEqualTo:identifier]) {
			return i;
		}
	}
	
	return NSNotFound;
}

BSThreadListItem *itemOfTitle(NSArray *array, NSString *searchTitle)
{
	unsigned i, count;
	id object;
	NSString *title;
	NSString *adjustedSearchTitle = [searchTitle stringByAppendingString:@" "];
	
	count = [array count];
	if (count == 0) {//NSLog(@"Zero count");
	return nil;
	}
	for (i = 0; i < count; i++ ) {
		object = [array objectAtIndex:i];
//		if ([object isKindOfClass:[BSThreadListItem class]]) NSLog(@"Class OK");
		title = [object threadName];
//		NSLog(@"title check: %@", title);
		if ([adjustedSearchTitle isEqualToString:title]) {
			return object;
		}
	}
	
	return nil;
}
