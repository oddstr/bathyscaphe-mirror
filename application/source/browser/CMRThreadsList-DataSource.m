/**
  * $Id: CMRThreadsList-DataSource.m,v 1.1 2005/05/11 17:51:04 tsawada2 Exp $
  * 
  * CMRThreadsList-DataSource.m
  *
  * Copyright (c) 2003, Takanori Ishikawa.
  * See the file LICENSE for copying permission.
  */
#import "CMRThreadsList_p.h"
#import "CMXDateFormatter.h"
#import "CMRReplyDocumentFileManager.h"


// Status image
#define kStatusUpdatedImageName		@"Status_updated"
#define kStatusCachedImageName		@"Status_logcached"
#define kStatusNewImageName			@"Status_newThread"

/* @see resetDataSourceTemplates */
#define kThreadTemplateStringKey	@"Browser - Text(Default)"
#define kNewThreadTemplateStringKey	@"Browser - Text(NewArrival)"

/* @see objectValueTemplate:forTYpe: */
enum {
	kValueTemplateDefaultType,
	kValueTemplateNewArrivalType,
	kValueTemplateNewUnknownType
};


@implementation CMRThreadsList(DataSourceTemplates)
static id kNewThreadTemplateString;
static id kThreadTemplateString;

+ (void) resetDataSourceTemplates
{
	NSDictionary			*attrs_;
	
	kThreadTemplateString = SGTemplateResource(kThreadTemplateStringKey);
	kNewThreadTemplateString = SGTemplateResource(kNewThreadTemplateStringKey);
	UTILAssertRespondsTo(
		kThreadTemplateString,
		@selector(addAttributes:range:));
	UTILAssertRespondsTo(
		kNewThreadTemplateString,
		@selector(addAttributes:range:));
	
	// default object value:
	attrs_ = [NSDictionary dictionaryWithObjectsAndKeys :
					[CMRPref threadsListFont],
					NSFontAttributeName,
					[CMRPref threadsListColor],
					NSForegroundColorAttributeName,
					nil];
	[kThreadTemplateString addAttributes:attrs_ range:[kThreadTemplateString range]];
	
	// New Arrival thread:
	attrs_ = [NSDictionary dictionaryWithObjectsAndKeys :
					[CMRPref threadsListNewThreadFont],
					NSFontAttributeName,
					[CMRPref threadsListNewThreadColor],
					NSForegroundColorAttributeName,
					nil];
	[kNewThreadTemplateString addAttributes:attrs_ range:[kNewThreadTemplateString range]];
	
}

+ (id) objectValueTemplate : (id ) aValue
				   forTYpe : (int) aType
{
	id		temp = nil;
	
	if(nil == aValue || [aValue isKindOfClass : [NSImage class]])
		return aValue;
	
	if(nil == kNewThreadTemplateString ||
	   nil == kThreadTemplateString)
		[self resetDataSourceTemplates];
	
	switch(aType){
	case kValueTemplateDefaultType:
		temp = kThreadTemplateString;
		break;
	case kValueTemplateNewArrivalType:
		temp = kNewThreadTemplateString;
		break;
	default :
		UTILUnknownSwitchCase(aType);
		break;
	}
	
	[temp replaceCharactersInRange : [temp range]
						withString : [aValue stringValue]];
	return temp;
	
}

@end



@implementation CMRThreadsList(DataSource)
- (NSArray *) threadsForTableView : (NSTableView *) tableView
{
	return [self filteredThreads];
}
- (int) numberOfRowsInTableView : (NSTableView *) aTableView
{
	return [[self threadsForTableView : aTableView] count];
}

static NSString *statusImageNameForStatus(ThreadStatus s)
{
	switch (s){
	case ThreadLogCachedStatus :
		return kStatusCachedImageName;
	case ThreadUpdatedStatus :
		return kStatusUpdatedImageName;
	case ThreadNewCreatedStatus :
		return kStatusNewImageName;
	case ThreadNoCacheStatus :
		return nil;
	default :
		return nil;
	}
	return nil;
}
+ (NSImage *) statusImageWithStatus : (ThreadStatus) s
{
	return [NSImage imageAppNamed : statusImageNameForStatus(s)];
}

- (ThreadStatus) threadStatusForThread : (NSDictionary *) aThread
{
	NSNumber *statusNum_;
	
	statusNum_ = [aThread objectForKey : CMRThreadStatusKey];
	return aThread ? [statusNum_ unsignedIntValue] : ThreadNoCacheStatus;
}
- (id) objectValueForIdentifier : (NSString *) identifier
					threadArray : (NSArray  *) threadArray
						atIndex : (int       ) index
{
	NSDictionary	*thread = [threadArray objectAtIndex : index];
	ThreadStatus	s = [self threadStatusForThread : thread];
	id				v = nil;
	
	if([identifier isEqualToString : CMRThreadStatusKey]){
		// ステータス画像
		v = [[self class] statusImageWithStatus : s];
	}else if([CMRThreadNumberOfUpdatedKey isEqualToString : identifier]){
		// 差分
		if(ThreadLogCachedStatus & s){
			int		diff_;
			
			diff_ = [CMRThreadAttributes numberOfUpdatedFromDictionary : thread];
			v = (diff_ >= 0) ? [NSNumber numberWithInt : diff_] : nil;
		}
	}else if([CMRThreadSubjectIndexKey isEqualToString : identifier] && [self isFavorites]){
		if ([[[CMRFavoritesManager defaultManager] favoritesItemsIndex] count] == 0) {
			NSLog(@"Resetting FavItemsIndex");
			[[CMRFavoritesManager defaultManager] setFavoritesItemsIndex : nil];
		}
		// 番号（お気に入り）
		v = [NSNumber numberWithInt : ([[[CMRFavoritesManager defaultManager] favoritesItemsIndex]
											indexOfObject : [CMRThreadAttributes pathFromDictionary : thread]]+1)];
	}else{
		// それ以外
		v = [thread objectForKey : identifier];
	}
	
	// 日付
#if PATCH
	if([v isKindOfClass : [NSDate class]]) {
#if 0 // test
		if (!dateFormatter)
			dateFormatter = [[CMXDateFormatter alloc] init];
#endif
		if (dateFormatter)
			v = [dateFormatter stringForObjectValue : v];
		else
			v = [[CMXDateFormatter sharedInstance] stringForObjectValue : v];
	}
#else
	if([v isKindOfClass : [NSDate class]])
		v = [[CMXDateFormatter sharedInstance] stringForObjectValue : v];
#endif
	
	// 新着スレッド／通常のスレッド
	v = [[self class] objectValueTemplate : v
			forTYpe : ((s == ThreadNewCreatedStatus) 
						? kValueTemplateNewArrivalType
						: kValueTemplateDefaultType)];
	
	return v;
}

- (id)            tableView : (NSTableView   *) aTableView
  objectValueForTableColumn : (NSTableColumn *) aTableColumn
                        row : (int            ) rowIndex
{
	NSArray			*threads_;
	
	threads_ = [self threadsForTableView : aTableView];
	NSAssert2(
		(rowIndex >= 0 && rowIndex <= [threads_ count]),
		@"Threads Count(%u) but Accessed Index = %d.",
		[threads_ count],
		rowIndex);
		
	return [self objectValueForIdentifier : [aTableColumn identifier]
							  threadArray : threads_
								  atIndex : rowIndex];
}

- (BOOL) tableView : (NSTableView  *) tableView
         writeRows : (NSArray      *) rows
      toPasteboard : (NSPasteboard *) pboard
{
	NSArray			*types_;
	NSMutableArray	*filenames_;
	NSMutableArray	*readables_;
	NSMutableArray	*urls_;
	
	NSEnumerator	*iter_;
	NSNumber		*indexNum_;
	
	if([self isFavorites]) return NO;
	
	
	filenames_ = [NSMutableArray arrayWithCapacity : [rows count]];
	readables_ = [NSMutableArray arrayWithCapacity : [rows count]];
	urls_ = [NSMutableArray arrayWithCapacity : [rows count]];
	iter_ = [rows objectEnumerator];
	
	while(indexNum_ = [iter_ nextObject]){
		NSDictionary	*thread_;
		unsigned int	index_;
		
		NSString		*path_;
		NSString		*title_;
		NSString		*readableData_;
		NSString		*datName_;
		NSURL			*url_;

		index_  = [indexNum_ unsignedIntValue];
		thread_ = [self threadAttributesAtRowIndex : index_ inTableView : tableView];
		
		if(nil == thread_) continue;
		
		path_ = [CMRThreadAttributes pathFromDictionary : thread_];
		datName_ = [CMRThreadAttributes identifierFromDictionary : thread_];
		title_ = [thread_ objectForKey : CMRThreadTitleKey];
		
		url_ = [CMRThreadAttributes threadURLFromDictionary : thread_];

		readableData_ = [NSString stringWithFormat : @"%@\n%@",
								[url_ absoluteString],
								title_];
		
		
		[readables_ addObject : readableData_];
		
		if(NO == [[NSFileManager defaultManager] fileExistsAtPath : path_]){
			continue;
		}
		[urls_ addObject : url_];
		[filenames_ addObject : path_];
	}
	
	// 書き込み
	if([filenames_ count] > 0){
		
		types_ = [NSArray arrayWithObjects : 
							NSFilenamesPboardType,
							NSURLPboardType,
							NSStringPboardType,
							nil];
	}else if([readables_ count] > 0){
		types_ = [NSArray arrayWithObject : NSStringPboardType];
	}else{
		return NO;
	}
	
	[pboard declareTypes : types_ 
				   owner : NSApp];
	if([filenames_ count] > 0){
		
		[pboard setPropertyList : filenames_
						forType : NSFilenamesPboardType];
		[[urls_ lastObject] writeToPasteboard : pboard];
	}
	[pboard setString : [readables_ componentsJoinedByString : @"\n"] 
			  forType : NSStringPboardType];
	
	return YES;
}




- (NSString *) threadFilePathAtRowIndex : (int          ) rowIndex
							inTableView : (NSTableView *) tableView
								 status : (ThreadStatus *) status
{
	NSString		*path_;
	NSDictionary	*thread_;
	
	thread_ = [self threadAttributesAtRowIndex : rowIndex
								   inTableView : tableView];
	if(nil == thread_) return nil;
	if(status != NULL){
		NSNumber *stNum_;
		
		stNum_ = [thread_ objectForKey : CMRThreadStatusKey];
		
		UTILAssertNotNil(stNum_);
		*status = [stNum_ unsignedIntValue];
	}
	
	path_ = [CMRThreadAttributes pathFromDictionary : thread_];
	UTILAssertNotNil(path_);
	
	return path_;
}

- (NSDictionary *) threadAttributesAtRowIndex : (int          ) rowIndex
                                  inTableView : (NSTableView *) tableView
{
	NSArray			*threadsArray_;
	NSDictionary	*thread_;
	
	if(rowIndex == -1) 
		return nil;
	
	[self _filteredThreadsLock];
	threadsArray_ = [[self threadsForTableView : tableView] retain];
	[self _filteredThreadsUnlock];
	
	if(rowIndex < 0 || rowIndex >= [threadsArray_ count])
		return nil;
	
	NSAssert2(
		(rowIndex >= 0 && rowIndex < [threadsArray_ count]),
		@"  rowIndex was over. size = %d but was %d",
		[threadsArray_ count],
		rowIndex);
	
	thread_ = [threadsArray_ objectAtIndex : rowIndex];
	[thread_ retain];
	[threadsArray_ release];
	
	return [thread_ autorelease];
}


- (unsigned int) indexOfThreadWithPath : (NSString *) filepath
{
	unsigned int  rowIndex_;
	NSArray      *threadsArray_;
	NSDictionary *matched_;
		
	matched_ = [self seachThreadByPath : filepath];
	[self _filteredThreadsLock]; 
	do {
		threadsArray_ = [self threadsForTableView : nil];
		rowIndex_ = [threadsArray_ indexOfObject : matched_];
		if(NSNotFound == rowIndex_)
			break;
	} while(0);
	[self _filteredThreadsUnlock];

	return rowIndex_;
}


- (NSArray *) threadFilePathArrayWithRowIndexArray : (NSArray	  *) anIndexArray
									   inTableView : (NSTableView *)tableView
{
	NSEnumerator		*iter_;
	NSNumber			*num_;
	NSMutableArray		*pathArray_;
	
	pathArray_ = [NSMutableArray array];
	iter_ = [anIndexArray objectEnumerator];
	while(num_ = [iter_ nextObject]){
		int				rowIndex_;
		NSString		*path_;
		
		rowIndex_ = [num_ intValue];
		if(rowIndex_ < 0) continue;
		path_ = [self threadFilePathAtRowIndex : rowIndex_
								   inTableView : tableView
										status : NULL];
		[pathArray_ addObject : path_];
	}
	return pathArray_;
}

#if PATCH
-(void)updateDateFormatter {
	if (dateFormatter)
		[dateFormatter release];
	dateFormatter = [[CMXDateFormatter alloc] init];
}
#endif
@end



@implementation CMRThreadsList(NSDraggingSource)
- (unsigned int) draggingSourceOperationMaskForLocal : (BOOL) localFlag
{
	if(localFlag)
		return (NSDragOperationCopy | NSDragOperationGeneric | NSDragOperationMove | NSDragOperationDelete | NSDragOperationLink);
	
	return (NSDragOperationDelete | NSDragOperationGeneric | NSDragOperationLink);
}
- (void) draggedImage : (NSImage	   *) anImage
			  endedAt : (NSPoint		) aPoint
			operation : (NSDragOperation) operation
{
	NSPasteboard	*pboard_;
	NSArray			*filenames_;
	
	// 「ゴミ箱」への移動
	if(NO == (NSDragOperationDelete & operation))
		return;
	
	pboard_ = [NSPasteboard pasteboardWithName : NSDragPboard];
	if(NO == [[pboard_ types] containsObject : NSFilenamesPboardType])
		return;
	
	filenames_ = [pboard_ propertyListForType : NSFilenamesPboardType];
	[self tableView:nil removeFiles:filenames_ deleteFile:YES];
}
@end
