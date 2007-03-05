/**
  * $Id: CMRThreadsList-DataSource.m,v 1.20 2007/03/05 10:08:25 tsawada2 Exp $
  * 
  * CMRThreadsList-DataSource.m
  *
  * Copyright (c) 2003, Takanori Ishikawa.
  * See the file LICENSE for copying permission.
  */
#import "CMRThreadsList_p.h"
#import "CMRReplyDocumentFileManager.h"
#import "CMRThreadSignature.h"
#import "NSIndexSet+BSAddition.h"
#import "BSDateFormatter.h"
// Status image
#define kStatusUpdatedImageName		@"Status_updated"
#define kStatusCachedImageName		@"Status_logcached"
#define kStatusNewImageName			@"Status_newThread"
#define kStatusHEADModImageName		@"Status_HeadModified"

/* @see objectValueTemplate:forType: */
/*enum {
	kValueTemplateDefaultType,
	kValueTemplateNewArrivalType,
	kValueTemplateNewUnknownType
};*/


@implementation CMRThreadsList(DataSource)
static id kNewThreadAttrTemplate;
static id kThreadAttrTemplate;

static NSMutableDictionary *kNewThreadCreatedDateAttrTemplate;
static NSMutableDictionary *kThreadCreatedDateAttrTemplate;
static NSMutableDictionary *kThreadModifiedDateAttrTemplate;

static NSMutableParagraphStyle	*pStyleForDateColumnWithWidth (float tabWidth)
{
	NSMutableParagraphStyle *style_;
    NSTextTab	*tab_ = [[NSTextTab alloc] initWithType: NSRightTabStopType location: tabWidth];
	
	style_ = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
	[style_ setLineBreakMode : NSLineBreakByWordWrapping];
	[style_ setTabStops: [NSArray array]];
    [style_ addTabStop: tab_];
	[tab_ release];

	return [style_ autorelease];
}

+ (void) resetDataSourceTemplateForDateColumn
{
	if (kNewThreadCreatedDateAttrTemplate == nil || kThreadCreatedDateAttrTemplate == nil || kThreadModifiedDateAttrTemplate == nil) {
		if (nil == kNewThreadAttrTemplate || nil == kThreadAttrTemplate) {
			[self resetDataSourceTemplates];
		}
		kNewThreadCreatedDateAttrTemplate = [kNewThreadAttrTemplate mutableCopy];
		kThreadCreatedDateAttrTemplate = [kThreadAttrTemplate mutableCopy];
		kThreadModifiedDateAttrTemplate = [kThreadAttrTemplate mutableCopy];
	} else {
		[kNewThreadCreatedDateAttrTemplate setObject: [CMRPref threadsListNewThreadFont] forKey: NSFontAttributeName];
		[kNewThreadCreatedDateAttrTemplate setObject: [CMRPref threadsListNewThreadColor] forKey: NSForegroundColorAttributeName];
		[kThreadCreatedDateAttrTemplate setObject: [CMRPref threadsListFont] forKey: NSFontAttributeName];
		[kThreadCreatedDateAttrTemplate setObject: [CMRPref threadsListColor] forKey: NSForegroundColorAttributeName];
		[kThreadModifiedDateAttrTemplate setObject: [CMRPref threadsListFont] forKey: NSFontAttributeName];
		[kThreadModifiedDateAttrTemplate setObject: [CMRPref threadsListColor] forKey: NSForegroundColorAttributeName];
	}
}

+ (void) resetDataSourceTemplateForColumnIdentifier: (NSString *) identifier width: (float) loc
{
    static float cachedLoc1 = 0;
    static float cachedLoc2 = 0;

	if (kNewThreadCreatedDateAttrTemplate == nil || kThreadCreatedDateAttrTemplate == nil || kThreadModifiedDateAttrTemplate == nil) {
		[self resetDataSourceTemplateForDateColumn];
	}

    if ([identifier isEqualToString: ThreadPlistIdentifierKey]) {
        if (cachedLoc1 == 0 || loc != cachedLoc1) {
            cachedLoc1 = loc;
			NSParagraphStyle	*ps = pStyleForDateColumnWithWidth(cachedLoc1);

			[kNewThreadCreatedDateAttrTemplate setObject: ps forKey: NSParagraphStyleAttributeName];
			[kThreadCreatedDateAttrTemplate setObject: ps forKey: NSParagraphStyleAttributeName];
		}
    } else if ([identifier isEqualToString: CMRThreadModifiedDateKey]) {
        if (cachedLoc2 == 0 || loc != cachedLoc2) {
            cachedLoc2 = loc;
			NSParagraphStyle	*ps2 = pStyleForDateColumnWithWidth(cachedLoc2);

			[kThreadModifiedDateAttrTemplate setObject: ps2 forKey: NSParagraphStyleAttributeName];
		}
	}
}

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

/* TODO その場しのぎ。本来はNSMutableDictionaryをNSDictionaryに変換して返すべきだが、速度的に現実的ではない。*/
+ (NSDictionary *)newThreadCreatedDateAttrTemplate
{
	return kNewThreadCreatedDateAttrTemplate;
}
+ (NSDictionary *)threadCreatedDateAttrTemplate
{
	return kThreadCreatedDateAttrTemplate;
}
+ (NSDictionary *)threadModifiedDateAttrTemplate
{
	return kThreadModifiedDateAttrTemplate;
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
	} else if ([identifier isEqualToString : ThreadPlistIdentifierKey]) {
		// スレッドの立った日付（dat 番号を変換）available in RainbowJerk and later.
		v = [NSDate dateWithTimeIntervalSince1970 : (NSTimeInterval)[[thread objectForKey : identifier] doubleValue]];
		return [[BSDateFormatter sharedDateFormatter] attributedStringForObjectValue: v
													  withDefaultAttributes: ((s == ThreadNewCreatedStatus) ? kNewThreadCreatedDateAttrTemplate
																											: kThreadCreatedDateAttrTemplate)];
	} else {
		// それ以外
		v = [thread objectForKey : identifier];
	}
	
	// 日付
	if([v isKindOfClass : [NSDate class]]) {
		return [[BSDateFormatter sharedDateFormatter] attributedStringForObjectValue: v withDefaultAttributes: kThreadModifiedDateAttrTemplate];
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
	NSArray			*threads_ = [self filteredThreads];
	NSString		*identifier_ = [aTableColumn identifier];
	NSAssert2((rowIndex >= 0 && rowIndex <= [threads_ count]),
	   @"Threads Count(%u) but Accessed Index = %d.", [threads_ count], rowIndex);

    if ([identifier_ isEqualToString: ThreadPlistIdentifierKey] ||
        [identifier_ isEqualToString: CMRThreadModifiedDateKey])
    {
        float location_ = [aTableColumn width];
        location_ -= [aTableView intercellSpacing].width * 2;
        [[self class] resetDataSourceTemplateForColumnIdentifier: identifier_ width: location_];
    }

	return [self objectValueForIdentifier: identifier_ threadArray: threads_ atIndex: rowIndex];
}

#pragma mark Drag and Drop support
// Deprecated in Mac OS X 10.4 and later.
- (BOOL) tableView : (NSTableView  *) tableView
         writeRows : (NSArray      *) rows
      toPasteboard : (NSPasteboard *) pboard
{
	NSIndexSet *indexSet = [NSIndexSet rowIndexesWithRows: rows];
	return [self tableView: tableView writeRowsWithIndexes: indexSet toPasteboard: pboard];
}

- (BOOL) tableView: (NSTableView *) tableView writeRowsWithIndexes: (NSIndexSet *) rowIndexes toPasteboard: (NSPasteboard *) pboard
{
	NSArray			*types_;
	unsigned int	numOfRows, index_;
	NSMutableArray	*filenames_, *urls_, *thSigs_;
	NSRange			indexRange;
	NSMutableString	*tmp_;

	numOfRows = [rowIndexes count];
	filenames_ = [NSMutableArray arrayWithCapacity: numOfRows];
	urls_ = [NSMutableArray arrayWithCapacity: numOfRows];
	thSigs_ = [NSMutableArray arrayWithCapacity: numOfRows];
	indexRange = NSMakeRange(0, [rowIndexes lastIndex]+1);
	tmp_ = SGTemporaryString();

	while ([rowIndexes getIndexes: &index_ maxCount: 1 inIndexRange: &indexRange] > 0) {
		NSDictionary	*thread_;
		NSString		*path_;
		NSURL			*url_;

		thread_ = [self threadAttributesAtRowIndex : index_ inTableView : tableView];
		
		if (nil == thread_) continue;
		
		path_ = [CMRThreadAttributes pathFromDictionary: thread_];
		url_ = [CMRThreadAttributes threadURLWithDefaultParameterFromDictionary: thread_];

		[CMRThreadAttributes fillBuffer: tmp_ withThreadInfoForCopying: [NSArray arrayWithObject: thread_]];
		
		[urls_ addObject: url_];
        [thSigs_ addObject: [[CMRThreadSignature threadSignatureFromFilepath: path_] propertyListRepresentation]];		

		if([[NSFileManager defaultManager] fileExistsAtPath : path_]){
			[filenames_ addObject: path_];			
		}
	}
	
	if([filenames_ count] > 0){
		types_ = [NSArray arrayWithObjects: NSURLPboardType, NSStringPboardType,  NSFilenamesPboardType, BSThreadItemsPboardType, nil];
	}else if([tmp_ length] > 0){
		types_ = [NSArray arrayWithObjects: NSURLPboardType, NSStringPboardType, BSThreadItemsPboardType, nil];
	}else{
		return NO;
	}
	
	[pboard declareTypes: types_ owner: NSApp];

	if([filenames_ count] > 0){
        [pboard setPropertyList: filenames_ forType: NSFilenamesPboardType];
	}

	[pboard setString: tmp_ forType: NSStringPboardType];
	[[urls_ lastObject] writeToPasteboard: pboard];
	[pboard setPropertyList: thSigs_ forType: BSThreadItemsPboardType];

	[tmp_ deleteCharactersInRange : [tmp_ range]];
	return YES;
}
/*
- (NSBezierPath *) calcRoundedRectForRect: (NSRect) bgRect
{
    int minX = NSMinX(bgRect);
    int midX = NSMidX(bgRect);
    int maxX = NSMaxX(bgRect);
    int minY = NSMinY(bgRect);
    int midY = NSMidY(bgRect);
    int maxY = NSMaxY(bgRect);
    float radius = 5.0;
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

- (NSImage *) dragImageWithIconForAttributes: (NSDictionary *) attr offset: (NSPointPointer) dragImageOffset
{
	NSString	*title_ = [attr objectForKey: CMRThreadTitleKey];
	NSAttributedString	*titleAttrStr_ = [[self class] objectValueTemplate: title_ forType: kValueTemplateDefaultType];
		
	NSImage *titleImg = [[NSImage alloc] init];
	NSSize	strSize_ = [titleAttrStr_ size];
	
	[titleImg setSize: strSize_];
	[titleImg lockFocus];
	[titleAttrStr_ drawInRect: NSMakeRect(0,0,strSize_.width,strSize_.height)];
	[titleImg unlockFocus];

	NSImage	*icon_ = [[NSWorkspace sharedWorkspace] iconForFileType : @"thread"];
	[icon_ setSize : NSMakeSize(16, 16)];
	
	NSImage *finalImg = [[NSImage alloc] init];
    float dy = 0;
    float dyTitle = 0;

	float	whichHeight = [CMRPref threadsListRowHeight];
	if (whichHeight < strSize_.height) {
	   whichHeight = strSize_.height;
	} else if (whichHeight > strSize_.height) {
	   dyTitle = (whichHeight - strSize_.height)*0.5;
	}
	if (whichHeight < 16.0) {
	   whichHeight = 16.0;
	   dyTitle = (16.0 - strSize_.height)*0.5;
	} else if (whichHeight > 16.0) {
	   dy = (whichHeight - 16.0)*0.5;
	}

	NSRect	imageRect_ = NSMakeRect(0, 0, strSize_.width+19.0, whichHeight);
	[finalImg setSize: imageRect_.size];
	[finalImg lockFocus];
	[icon_ compositeToPoint: NSMakePoint(0, dy) operation: NSCompositeCopy fraction: 0.9];
	[titleImg compositeToPoint: NSMakePoint(19.0,dyTitle) operation: NSCompositeCopy fraction: 0.8];
	
	[finalImg unlockFocus];
	
	[titleImg release];

	dragImageOffset->x = imageRect_.size.width * 0.5 - 8.0;

	return [finalImg autorelease];
}	
	
- (NSImage *) dragImageForTheRow: (unsigned int) rowIndex inTableView: (NSTableView *) tableView offset: (NSPointPointer) dragImageOffset
{
	NSDictionary	*thread_;
	thread_ = [self threadAttributesAtRowIndex : rowIndex inTableView : tableView];
	
	if(nil == thread_) return nil;

	NSString		*path_;
	path_ = [CMRThreadAttributes pathFromDictionary : thread_];

	if([[NSFileManager defaultManager] fileExistsAtPath : path_])
		return [self dragImageWithIconForAttributes: thread_ offset: dragImageOffset];

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
*/
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
/*	NSArray			*threadsArray_;
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
	
	return [thread_ autorelease];*/
	UTILAbstractMethodInvoked;
	return nil;
}

- (unsigned int) indexOfThreadWithPath : (NSString *) filepath
{
/*	unsigned int  rowIndex_;
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

	return rowIndex_;*/
	UTILAbstractMethodInvoked;
	return 0;
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

#pragma mark NSDraggingSource
- (unsigned int) draggingSourceOperationMaskForLocal : (BOOL) localFlag
{
	if(localFlag)
		return NSDragOperationEvery;
	
	return (NSDragOperationCopy|NSDragOperationDelete|NSDragOperationLink);
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
