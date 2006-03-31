//
//  BSThreadListCollectAllThreadAttrTask.m
//  BathyScaphe
//
//  Created by Hori,Masaki on 06/03/30.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import "BSThreadListCollectAllThreadAttrTask.h"

#import "BSDBThreadList.h"
#import "BoardListItem.h"
#import "DatabaseManager.h"
#import "CMRDocumentFileManager.h"


// マルチスレッドデザインパターン Future パターン参照。

@implementation BSThreadListAllThreadAttrCollector

+ (id)collectorWithBSDBThreadList:(BSDBThreadList *)threadList
{
	return [[[[self class] alloc] initWithBSDBThreadList:threadList] autorelease];
}
- (id)initWithBSDBThreadList:(BSDBThreadList *)threadList
{
	if(self = [super init]) {
		target = [threadList retain];
	}
	
	return self;
}
- (void)dealloc
{
	[target release];
	
	[super dealloc];
}

- (id)allThread
{
	return [BSFakeThreadAttributeArray fakeArrayWithBSDBThreadList:target];
}

@end


@implementation BSFakeThreadAttributeArray


+ (id)fakeArrayWithBSDBThreadList:(BSDBThreadList *)threadList
{
	return [[[[self class] alloc] initWithBSDBThreadList:threadList] autorelease];
}
- (id)initWithBSDBThreadList:(BSDBThreadList *)threadList
{
	if(self = [super init]) {
		target = [threadList retain];
		mLock = [[NSConditionLock alloc] initWithCondition:bsFakeArrayNotReady];
		mAmountStringLock = [[NSLock alloc] init];
		
		[self setProgress:0];
		[self setAmountString:@"0"];
		[self setIdentifier:[NSValue valueWithPointer:self]];
		
		[[target worker] push:self];
	}
	
	return self;
}
- (void)dealloc
{
	[target release];
	[mLock release];
	[mAmountString release];
	[mAmountStringLock release];
	
	[super dealloc];
}

- (void) doExecuteWithLayout : (CMRThreadLayout *) layout
{
	[self collect];
}

#pragma mark-
- (NSString *) title
{
	return [NSString stringWithFormat:@"Collect Thread Attribute -- %@",[[target boardListItem] representName]];
}
- (NSString *) messageInProgress
{
    NSString        *format_;
    NSString        *title_;
    
    title_ = [self title];
    format_ = nil; //[self localizedString : @"Checking Favorites Message"];
    
    return [NSString stringWithFormat : 
					format_ ? format_ : @"%@ (%@)",
					  title_ ? title_ : @"",
		[self amountString]];
}
- (unsigned)progress
{
	return mProgress;
}
- (void)setProgress:(unsigned) new
{
	mProgress = new;
}
- (double)amount
{
	return ([self progress] <= 0) ? -1 : [self progress];
}
- (NSString *)amountString
{
	id res;
	
	[mAmountStringLock lock];
	res = [mAmountString retain];
	[mAmountStringLock unlock];
	
	return [res autorelease];;
}
- (void)setAmountString:(NSString *)new
{
	id temp;
	
	[mAmountStringLock lock];
	temp = mAmountString;
	mAmountString = [new retain];
	[temp release];
	[mAmountStringLock unlock];
}


// block while condition become bsFakeArrayReady.
- (id)objectEnumerator
{
	id result = nil;
	
	[mLock lockWhenCondition:bsFakeArrayReady];
	result = [[realizeArray retain] autorelease];
	[mLock unlock];
	
	return [result objectEnumerator];
}
-(unsigned)count
{
	return [[[target boardListItem] cursorForThreadList] rowCount];
}
-(id)objectAtIndex:(unsigned)index
{
	id result;
	[mLock lockWhenCondition:bsFakeArrayReady];
	result = [[realizeArray objectAtIndex:index] retain];
	[mLock unlock];
	
	return [result autorelease];
}

static inline id nilIfObjectIsNSNull( id obj )
{
	return obj == [NSNull null] ? nil : obj;
}
- (void)collect
{
	CFMutableArrayRef result = NULL;
	id <SQLiteCursor> cursor;
	unsigned count, i;
	
	NSString *title;
	NSString *newCount;
	NSString *dat;
	NSString *boardName;
	NSString *statusStr;
	NSNumber *status;
	NSString *modDateStr;
	NSDate *modDate = nil;
	NSString *threadPath;
		
	cursor = [[target boardListItem] cursorForThreadList];
	count = [cursor rowCount];
	result = CFArrayCreateMutable( kCFAllocatorDefault,
								   count,
								   &kCFTypeArrayCallBacks );
	if(!result) goto final;
	
	[self setProgress:0];
	[self setAmountString:[NSString stringWithFormat:@"%d/%d",0, count]];
	
	SEL valueForColumnAtRowSEL = @selector(valueForColumn:atRow:);
	IMP valueForColumnAtRowIMP = [(id)cursor methodForSelector:valueForColumnAtRowSEL];
	if(!valueForColumnAtRowIMP) goto final;
	
	id cmrDFM = [CMRDocumentFileManager defaultManager];
	SEL threadPathWithBoardNameDatIDSEL = @selector(threadPathWithBoardName:datIdentifier:);
	IMP threadPathWithBoardNameDatIDIMP = [cmrDFM methodForSelector:threadPathWithBoardNameDatIDSEL];
	if(!threadPathWithBoardNameDatIDIMP) goto final;
	
	
	for( i = 0; i < count; i++ ) {
		if( [self isInterrupted] ) goto final;
		
		id pool = [[NSAutoreleasePool alloc] init];
		CFMutableDictionaryRef aAttr;
		
		title = nilIfObjectIsNSNull(valueForColumnAtRowIMP(cursor, valueForColumnAtRowSEL, ThreadNameColumn, i));
		newCount = nilIfObjectIsNSNull(valueForColumnAtRowIMP(cursor, valueForColumnAtRowSEL, NumberOfAllColumn, i));
		dat = nilIfObjectIsNSNull(valueForColumnAtRowIMP(cursor, valueForColumnAtRowSEL, ThreadIDColumn, i));
		boardName = nilIfObjectIsNSNull(valueForColumnAtRowIMP(cursor, valueForColumnAtRowSEL, BoardNameColumn, i));
		statusStr = nilIfObjectIsNSNull(valueForColumnAtRowIMP(cursor, valueForColumnAtRowSEL, ThreadStatusColumn, i));
		modDateStr = nilIfObjectIsNSNull(valueForColumnAtRowIMP(cursor, valueForColumnAtRowSEL, ModifiedDateColumn, i));
		
		threadPath = threadPathWithBoardNameDatIDIMP( cmrDFM, threadPathWithBoardNameDatIDSEL, boardName, dat);
		
		status = [NSNumber numberWithInt : [statusStr intValue]];
		if(modDateStr) {
			modDate = [NSDate dateWithTimeIntervalSince1970 : [modDateStr doubleValue]];
		}
		
		aAttr = CFDictionaryCreateMutable(kCFAllocatorDefault,
										  7,
										  &kCFTypeDictionaryKeyCallBacks,
										  &kCFTypeDictionaryValueCallBacks);
		if(!aAttr) {
			[pool release];
			continue;
		}
		
		if(title) CFDictionaryAddValue(aAttr, CMRThreadTitleKey, title);
		if(newCount) CFDictionaryAddValue(aAttr, CMRThreadNumberOfMessagesKey, newCount);
		if(dat) CFDictionaryAddValue(aAttr, ThreadPlistIdentifierKey, dat);
		if(boardName) CFDictionaryAddValue(aAttr, ThreadPlistBoardNameKey, boardName);
		if(status) CFDictionaryAddValue(aAttr, CMRThreadUserStatusKey, status);
		if(modDate) CFDictionaryAddValue(aAttr, CMRThreadModifiedDateKey, modDate);
		if(threadPath) CFDictionaryAddValue(aAttr, CMRThreadLogFilepathKey, threadPath);
		
		CFArrayAppendValue(result, aAttr);
		CFRelease(aAttr);
		
		[self setProgress:(double)i / count * 100];
		[self setAmountString:[NSString stringWithFormat:@"%d/%d", i + 1, count]];
		
		[pool release];
	}
	
final:
	[mLock lock];
	realizeArray = (NSArray *)result;
	[mLock unlockWithCondition:bsFakeArrayReady];
}	

@end
