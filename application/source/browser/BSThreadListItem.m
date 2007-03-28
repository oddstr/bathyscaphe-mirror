//
//  BSThreadListItem.m
//  BathyScaphe
//
//  Created by Hori,Masaki on 07/03/18.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import "BSThreadListItem.h"

#import "DatabaseManager.h"
#import "CMRDocumentFileManager.h"
#import <SGAppKit/NSImage-SGExtensions.h>

@interface BSThreadListItemArray : NSArray
{
	id <SQLiteCursor> cursor;
	id cache;
}
- (id)initWithCorsor:(id <SQLiteCursor>)cursor;
@end

static inline BOOL searchBoardIDAndThreadIDFromFilePath( unsigned *outBoardID, NSString **outThreadID, NSString *inFilePath );
static inline NSImage *_statusImageWithStatusBSDB(ThreadStatus s);
static inline NSArray *dateTypeKeys();
static inline NSArray *numberTypeKeys();
static inline NSArray *threadListIdentifiers();

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

+ (id)threadItemWithIdentifier:(NSString *)identifier boardID:(unsigned)boardID
{
	return [[[[self class] alloc] initWithIdentifier:identifier boardID:boardID] autorelease];
}
- (id)initWithIdentifier:(NSString *)identifier boardID:(unsigned)boardID
{
	if(self = [super init]) {
		if(boardID == 0) {
			[self release];
			return nil;
		}
		
		data = [[NSMutableDictionary alloc] init];
		[data setObject:identifier forKey:ThreadIDColumn];
		[data setObject:[NSNumber numberWithUnsignedInt:boardID] forKey:BoardIDColumn];
	}
	
	return self;
}
+ (id)threadItemWithIdentifier:(NSString *)identifier boardName:(NSString *)boardName
{
	return [[[[self class] alloc] initWithIdentifier:identifier boardName:boardName] autorelease];
}
- (id)initWithIdentifier:(NSString *)identifier boardName:(NSString *)boardName
{
	if(self = [super init]) {
		NSArray *boardIDs = [[DatabaseManager defaultManager] boardIDsForName:boardName];
		unsigned boardID;
		
		if(!boardIDs) {
			[self release];
			return nil;
		}
		boardID = [[boardIDs objectAtIndex:0] intValue];
		if(boardID == 0) {
			[self release];
			return nil;
		}
		
		data = [[NSMutableDictionary alloc] init];
		[data setObject:identifier forKey:ThreadIDColumn];
		[data setObject:[NSNumber numberWithUnsignedInt:boardID] forKey:BoardIDColumn];
		[data setObject:boardName forKey:BoardNameColumn];
	}
	
	return self;
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
	return [[[BSThreadListItemArray alloc] initWithCorsor:cursor] autorelease];
}

#pragma mark## Accessor ##
- (NSString *)identifier
{
	return [data objectForKey:ThreadIDColumn];
}
- (NSString *)boardName
{
	return [data objectForKey:BoardNameColumn];
}
- (unsigned)boardID
{
	return [[data objectForKey:BoardIDColumn] unsignedIntValue];
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
- (id)valueForKey:(NSString *)key
{
	id result = [data objectForKey:key];
	if(result == [NSNull null]) return nil;
	if(result) return result;
	
	if([threadListIdentifiers() containsObject:key]) {
		result = [self threadListValueForKey:key];
		if(result) {
			[data setObject:result forKey:key];
			return result;
		}
	}
	
	result = [[DatabaseManager defaultManager] valueForKey:key
													  boardID:[self boardID]
													 threadID:[self identifier]];
	
	if(!result) {
		NSLog(@"Can not find %@ for boardName(%@) threadID(%@)",
			  key, [self boardName], [self identifier]);
		result = [self valueForUndefinedKey:key];
	} else if(result == [NSNull null]) {
		return nil;
	}
	
	if([dateTypeKeys() containsObject:key] && ![result isKindOfClass:[NSDate class]]) {
		result = [NSDate dateWithTimeIntervalSince1970:[result doubleValue]];
	} else if([numberTypeKeys() containsObject:key] && ![result isKindOfClass:[NSNumber class]]) {
		result = [NSNumber numberWithDouble:[result doubleValue]];
	}
	
	if(result) {
		[data setObject:result forKey:key];
	}
	
	return result;
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

@implementation BSMutableThreadListItem
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
		nil];
	
	return array;
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
		[data setValue:value forKey:key];
	} else {
		[super setValue:value forKey:key];
	}
}
// - (id)valueForUndefinedKey:(NSString *)key;
// - (void)setValue:(id)value forUndefinedKey:(NSString *)key;
// - (void)setNilValueForKey:(NSString *)key;
@end

@implementation BSThreadListItemArray
- (id)initWithCorsor:(id <SQLiteCursor>)aCursor
{
	if(self = [super init]) {
		cursor = [aCursor retain];
		if(!cursor) {
			[self release];
			return nil;
		}
		cache = [[NSMutableDictionary alloc] init];
	}
	
	return self;
}
- (void)dealloc
{
	[cursor release];
	[cache release];
	
	[super dealloc];
}

static inline NSArray *mustContainsKeys()
{
	static NSArray *array = nil;
	
	if(!array) {
		array = [NSArray arrayWithObjects:
			BoardIDColumn, BoardNameColumn,
			ThreadIDColumn, ThreadNameColumn, NumberOfAllColumn,
			NumberOfReadColumn, ModifiedDateColumn, ThreadStatusColumn,
			//		ThreadLabelColumn,
			nil];
		[array retain];
	}
	
	return array;
}
- (BOOL)checkAtIndex:(unsigned)index
{
	NSEnumerator *enume = [mustContainsKeys() objectEnumerator];
	
	NSArray *columns = [cursor columnNames];
	id obj;
	while(obj = [enume nextObject]) {
		if(![columns containsObject:[obj lowercaseString]]) {
			return NO;
		}
	}
	
	return YES;
}
static inline BSThreadListItem *itemFromRow(id <SQLiteRow> row)
{
	id item = [BSMutableThreadListItem threadItemWithIdentifier:[row valueForColumn:ThreadIDColumn]
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

#pragma mark## primitive methods ##
- (unsigned)count
{
	return [cursor rowCount];
}
- (id)objectAtIndex:(unsigned)index
{
	id cacheKey = [NSNumber numberWithUnsignedInt:index];
	id item = [cache objectForKey:cacheKey];
	if(item) {
		return item;
	}
	
	if(![self checkAtIndex:index]) {
		return nil;
	}
	
	item = itemFromRow([cursor rowAtIndex:index]);
	if(item) {
		[cache setObject:item forKey:cacheKey];
	}
	
	return item;
}
@end


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
