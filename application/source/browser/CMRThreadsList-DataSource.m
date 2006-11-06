/**
  * $Id: CMRThreadsList-DataSource.m,v 1.15.4.3 2006/11/06 20:24:51 tsawada2 Exp $
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
#define kStatusHEADModImageName		@"Status_HeadModified"

/* @see objectValueTemplate:forType: */
enum {
	kValueTemplateDefaultType,
	kValueTemplateNewArrivalType,
	kValueTemplateNewUnknownType
};


@implementation CMRThreadsList(DataSourceTemplates)
static id kNewThreadAttrTemplate;
static id kThreadAttrTemplate;

+ (void) resetDataSourceTemplates
{
	NSMutableParagraphStyle *style_;
	
	// 長過ぎる内容を「...」で省略
	style_ = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
	[style_ setLineBreakMode : NSLineBreakByTruncatingTail];

	// default object value:
	kThreadAttrTemplate = [[NSDictionary alloc] initWithObjectsAndKeys :
							[CMRPref threadsListFont], NSFontAttributeName,
							[CMRPref threadsListColor], NSForegroundColorAttributeName,
							style_, NSParagraphStyleAttributeName,
							nil];

	// New Arrival thread:
	kNewThreadAttrTemplate = [[NSDictionary alloc] initWithObjectsAndKeys :
								[CMRPref threadsListNewThreadFont], NSFontAttributeName,
								[CMRPref threadsListNewThreadColor], NSForegroundColorAttributeName,
								style_, NSParagraphStyleAttributeName,
								nil];

	[style_ release];
}

+ (id) objectValueTemplate : (id ) aValue
				   forType : (int) aType
{
	id		temp = nil;
	
	if(nil == aValue || [aValue isKindOfClass : [NSImage class]])
		return aValue;
	
	if (nil == kNewThreadAttrTemplate || nil == kThreadAttrTemplate)
		[self resetDataSourceTemplates];
	
	switch(aType){
	case kValueTemplateDefaultType:
		temp = [[NSMutableAttributedString alloc] initWithString : [aValue stringValue]
													  attributes : kThreadAttrTemplate];
		break;
	case kValueTemplateNewArrivalType:
		temp = [[NSMutableAttributedString alloc] initWithString : [aValue stringValue]
													  attributes : kNewThreadAttrTemplate];
		break;
	default :
		UTILUnknownSwitchCase(aType);
		break;
	}
	
	return [temp autorelease]; // autorelease しないと漏れまくり	
}
@end



@implementation CMRThreadsList(DataSource)
- (NSArray *) threadsForTableView : (NSTableView *) tableView
{
	return [self filteredThreads];
}
- (int) numberOfRowsInTableView : (NSTableView *) aTableView
{
//	return [[self threadsForTableView : aTableView] count];
	return [[self filteredThreads] count];
}

static NSImage *_statusImageWithStatus(ThreadStatus s)
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

static ThreadStatus _threadStatusForThread(NSDictionary *aThread)
{
	if(!aThread) return ThreadNoCacheStatus;

	NSNumber *statusNum_;
	statusNum_ = [aThread objectForKey : CMRThreadStatusKey];
	return [statusNum_ unsignedIntValue];
}

- (ThreadStatus) threadStatusForThread : (NSDictionary *) aThread
{
	return _threadStatusForThread(aThread);
}

- (id) objectValueForIdentifier : (NSString *) identifier
					threadArray : (NSArray  *) threadArray
						atIndex : (int       ) index
{
	NSDictionary	*thread = [threadArray objectAtIndex : index];
	ThreadStatus	s = _threadStatusForThread(thread);
	id				v = nil;
	
	if([identifier isEqualToString : CMRThreadStatusKey]){
		// ステータス画像
		v = _statusImageWithStatus(s);
		return v;

	} else if ([CMRThreadNumberOfUpdatedKey isEqualToString : identifier]){
		// 差分
		if(ThreadLogCachedStatus & s){
			int		diff_;
			
			diff_ = [CMRThreadAttributes numberOfUpdatedFromDictionary : thread];
			v = (diff_ >= 0) ? [NSNumber numberWithInt : diff_] : nil;
		}
	/*} else if ([self isFavorites] && [CMRThreadSubjectIndexKey isEqualToString : identifier]) {
		// 番号（お気に入り）
		v = [NSNumber numberWithInt : ([[[CMRFavoritesManager defaultManager] favoritesItemsIndex]
											indexOfObject : [CMRThreadAttributes pathFromDictionary : thread]]+1)];*/
	} else if ([identifier isEqualToString : ThreadPlistIdentifierKey]) {
		// スレッドの立った日付（dat 番号を変換）available in RainbowJerk and later.
		v = [NSDate dateWithTimeIntervalSince1970 : (NSTimeInterval)[[thread objectForKey : identifier] doubleValue]];
	} else {
		// それ以外
		v = [thread objectForKey : identifier];
	}
	
	// 日付
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

	// 新着スレッド／通常のスレッド
	if(v) {
		v = [[self class] objectValueTemplate : v
									  forType : ((s == ThreadNewCreatedStatus) ? kValueTemplateNewArrivalType : kValueTemplateDefaultType)];
	}
	return v;
}

- (id)            tableView : (NSTableView   *) aTableView
  objectValueForTableColumn : (NSTableColumn *) aTableColumn
                        row : (int            ) rowIndex
{
	NSArray			*threads_;
	
	threads_ = [self filteredThreads];//[self threadsForTableView : aTableView];
	NSAssert2(
		(rowIndex >= 0 && rowIndex <= [threads_ count]),
		@"Threads Count(%u) but Accessed Index = %d.",
		[threads_ count],
		rowIndex);
		
	return [self objectValueForIdentifier : [aTableColumn identifier]
							  threadArray : threads_
								  atIndex : rowIndex];
}

- (void) updateDateFormatter {
	if (dateFormatter)
		[dateFormatter release];
	dateFormatter = [[CMXDateFormatter alloc] init];
}

#pragma mark Drag and Drop support
/*- (BOOL) tableView : (NSTableView  *) tableView
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
}*/
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
	
	filenames_ = [NSMutableArray arrayWithCapacity: [rows count]];
	readables_ = [NSMutableArray arrayWithCapacity: [rows count]];
	urls_ = [NSMutableArray arrayWithCapacity: [rows count]];
	iter_ = [rows objectEnumerator];
	
	while(indexNum_ = [iter_ nextObject]){
		NSDictionary	*thread_;
		unsigned int	index_;
		
		NSString		*path_;
		NSString		*title_;
		NSString		*readableData_;
		NSURL			*url_;

		index_  = [indexNum_ unsignedIntValue];
		thread_ = [self threadAttributesAtRowIndex : index_ inTableView : tableView];
		
		if(nil == thread_) continue;
		
		path_ = [CMRThreadAttributes pathFromDictionary : thread_];
		title_ = [thread_ objectForKey : CMRThreadTitleKey];
		url_ = [CMRThreadAttributes threadURLFromDictionary : thread_];

		readableData_ = [NSString stringWithFormat : @"%@\n%@", [url_ absoluteString], title_];
		
		[readables_ addObject: readableData_];
		[urls_ addObject: url_];
		
		if([[NSFileManager defaultManager] fileExistsAtPath : path_]){
			[filenames_ addObject: path_];
		}
	}
	
	// 書き込み
	if([filenames_ count] > 0){
		types_ = [NSArray arrayWithObjects: NSFilenamesPboardType, NSURLPboardType, NSStringPboardType, nil];
	}else if([readables_ count] > 0){
		types_ = [NSArray arrayWithObjects: NSURLPboardType, NSStringPboardType, nil];
	}else{
		return NO;
	}
	
	[pboard declareTypes: types_ owner: NSApp];

	if([filenames_ count] > 0){
        [pboard setPropertyList: filenames_ forType: NSFilenamesPboardType];
	}
	[pboard setString: [readables_ componentsJoinedByString : @"\n"] forType: NSStringPboardType];
	[[urls_ lastObject] writeToPasteboard: pboard];
	
	return YES;
}

- (NSBezierPath *) calcRoundedRectForRect: (NSRect) bgRect
{
    int minX = NSMinX(bgRect);
    int midX = NSMidX(bgRect);
    int maxX = NSMaxX(bgRect);
    int minY = NSMinY(bgRect);
    int midY = NSMidY(bgRect);
    int maxY = NSMaxY(bgRect);
    float radius = 5.0; // 試行錯誤の末の値
    NSBezierPath *bgPath = [NSBezierPath bezierPath];
    
    // Bottom edge and bottom-right curve
    [bgPath moveToPoint:NSMakePoint(midX, minY)];
    [bgPath appendBezierPathWithArcFromPoint:NSMakePoint(maxX, minY) 
                                     toPoint:NSMakePoint(maxX, midY) 
                                      radius:radius];
    
    // Right edge and top-right curve
    [bgPath appendBezierPathWithArcFromPoint:NSMakePoint(maxX, maxY) 
                                     toPoint:NSMakePoint(midX, maxY) 
                                      radius:radius];
    
    // Top edge and top-left curve
    [bgPath appendBezierPathWithArcFromPoint:NSMakePoint(minX, maxY) 
                                     toPoint:NSMakePoint(minX, midY) 
                                      radius:radius];
    
    // Left edge and bottom-left curve
    [bgPath appendBezierPathWithArcFromPoint:bgRect.origin 
                                     toPoint:NSMakePoint(midX, minY) 
                                      radius:radius];
    [bgPath closePath];
    
    return bgPath;
}

- (NSAttributedString *) attributedStringFromTitle: (NSString *) threadTitle andURL: (NSString *) urlString
{
	NSMutableDictionary		*attr_, *attr2_;
	NSMutableAttributedString	*attrStr_;
	NSAttributedString	*urlStr_;
	NSFont					*boldFont_;
	
	attr_ = [NSMutableDictionary dictionary];
	attr2_ = [NSMutableDictionary dictionary];

	boldFont_ = [NSFont boldSystemFontOfSize: [NSFont smallSystemFontSize]];

	[attr_ setObject : [NSFont labelFontOfSize: 0] forKey : NSFontAttributeName];
	[attr_ setObject : [NSColor whiteColor] forKey : NSForegroundColorAttributeName];
	[attr2_ setObject: boldFont_ forKey: NSFontAttributeName];
	[attr2_ setObject: [NSColor whiteColor] forKey: NSForegroundColorAttributeName];

	attrStr_ = [[NSMutableAttributedString alloc] initWithString: threadTitle attributes: attr2_];
	urlStr_ = [[NSAttributedString alloc] initWithString: [NSString stringWithFormat: @"\n%@", urlString] attributes: attr_];
	
	[attrStr_ appendAttributedString: urlStr_];
	[urlStr_ release];

	return [attrStr_ autorelease];
}

- (NSImage *) dragImageForTheRow: (unsigned int) rowIndex inTableView: (NSTableView *) tableView offset: (NSPointPointer) dragImageOffset
{
	NSDictionary	*thread_;
	thread_ = [self threadAttributesAtRowIndex : rowIndex inTableView : tableView];
	
	if(nil == thread_) return [[NSWorkspace sharedWorkspace] iconForFileType : @"thread"];

	NSString		*path_;
	path_ = [CMRThreadAttributes pathFromDictionary : thread_];

	if([[NSFileManager defaultManager] fileExistsAtPath : path_])
		 return [[NSWorkspace sharedWorkspace] iconForFileType : @"thread"];

	NSString		*title_;
	NSAttributedString	*attrStr_;
	NSColor			*bgColor_;
	
	NSImage	*anImg = [[NSImage alloc] init];
	NSRect	imageBounds;

	title_ = [thread_ objectForKey : CMRThreadTitleKey];

	attrStr_ = [self attributedStringFromTitle: title_ andURL: [[CMRThreadAttributes threadURLFromDictionary : thread_] absoluteString]];

	NSSize strSize_ = [attrStr_ size];
	NSRect strRect_ = NSMakeRect(0, 0, strSize_.width+10.0, strSize_.height+10.0);

	imageBounds.origin = NSMakePoint(5.0, 5.0);
	imageBounds.size = strSize_;

	bgColor_ = [[NSColor alternateSelectedControlColor] colorWithAlphaComponent: 0.9];

	[anImg setSize : strRect_.size];

	[anImg lockFocus];
	[bgColor_ set];
	[[self calcRoundedRectForRect: strRect_] fill];
	[attrStr_ drawInRect: imageBounds];
	[anImg unlockFocus];

	dragImageOffset->x = strSize_.width * 0.5;
	dragImageOffset->y = 10.0;

	return [anImg autorelease];
}

#pragma mark Getting Thread Attributes
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
	//threadsArray_ = [[self threadsForTableView : tableView] retain];
	threadsArray_ = [[self filteredThreads] retain];
	
	
	if(rowIndex < 0 || rowIndex >= [threadsArray_ count])
		return nil;
	
	NSAssert2(
		(rowIndex >= 0 && rowIndex < [threadsArray_ count]),
		@"  rowIndex was over. size = %d but was %d",
		[threadsArray_ count],
		rowIndex);
	
	thread_ = [threadsArray_ objectAtIndex : rowIndex];
	
	[self _filteredThreadsUnlock];
	
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
		//threadsArray_ = [self threadsForTableView : nil];
		threadsArray_ = [self filteredThreads];
		rowIndex_ = [threadsArray_ indexOfObject : matched_];
		if(NSNotFound == rowIndex_)
			break;
	} while(0);
	[self _filteredThreadsUnlock];

	return rowIndex_;
}

- (NSArray *) threadFilePathArrayWithRowIndexSet : (NSIndexSet	*) anIndexSet
									 inTableView : (NSTableView	*) tableView
{
	NSMutableArray	*pathArray_ = [NSMutableArray array];
	unsigned int	arrayElement;
	int				size = [anIndexSet lastIndex]+1;
	NSRange			e = NSMakeRange(0, size);

	while ([anIndexSet getIndexes:&arrayElement maxCount:1 inIndexRange:&e] > 0) {
		NSString	*path_;
		path_ = [self threadFilePathAtRowIndex : arrayElement inTableView : tableView status : NULL];
		[pathArray_ addObject : path_];
	}

	return pathArray_;
}

- (NSArray *) threadFilePathArrayWithRowIndexArray : (NSArray	  *) anIndexArray
									   inTableView : (NSTableView *) tableView
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
	if(NO == (NSDragOperationDelete & operation)) {
		return;
	}
	pboard_ = [NSPasteboard pasteboardWithName : NSDragPboard];
	if(NO == [[pboard_ types] containsObject : NSFilenamesPboardType]) {
		return;
	}
	filenames_ = [pboard_ propertyListForType : NSFilenamesPboardType];
	[self tableView : nil removeFiles : filenames_ delFavIfNecessary : YES];
}
@end
