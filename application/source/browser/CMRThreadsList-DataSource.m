/**
  * $Id: CMRThreadsList-DataSource.m,v 1.22 2007/03/25 13:11:06 masakih Exp $
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
#import "DatabaseManager.h"
// Status image
//#define kStatusUpdatedImageName		@"Status_updated"
//#define kStatusCachedImageName		@"Status_logcached"
//#define kStatusNewImageName			@"Status_newThread"
//#define kStatusHEADModImageName		@"Status_HeadModified"

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
static NSMutableDictionary *kThreadLastWrittenDateAttrTemplate;

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
	if (kNewThreadCreatedDateAttrTemplate == nil
		|| kThreadCreatedDateAttrTemplate == nil
		|| kThreadModifiedDateAttrTemplate == nil
		|| kThreadLastWrittenDateAttrTemplate == nil) {
		
		if (nil == kNewThreadAttrTemplate || nil == kThreadAttrTemplate) {
			[self resetDataSourceTemplates];
		}
		kNewThreadCreatedDateAttrTemplate = [kNewThreadAttrTemplate mutableCopy];
		kThreadCreatedDateAttrTemplate = [kThreadAttrTemplate mutableCopy];
		kThreadModifiedDateAttrTemplate = [kThreadAttrTemplate mutableCopy];
		kThreadLastWrittenDateAttrTemplate = [kThreadAttrTemplate mutableCopy];
	} else {
		[kNewThreadCreatedDateAttrTemplate setObject: [CMRPref threadsListNewThreadFont] forKey: NSFontAttributeName];
		[kNewThreadCreatedDateAttrTemplate setObject: [CMRPref threadsListNewThreadColor] forKey: NSForegroundColorAttributeName];
		[kThreadCreatedDateAttrTemplate setObject: [CMRPref threadsListFont] forKey: NSFontAttributeName];
		[kThreadCreatedDateAttrTemplate setObject: [CMRPref threadsListColor] forKey: NSForegroundColorAttributeName];
		[kThreadModifiedDateAttrTemplate setObject: [CMRPref threadsListFont] forKey: NSFontAttributeName];
		[kThreadModifiedDateAttrTemplate setObject: [CMRPref threadsListColor] forKey: NSForegroundColorAttributeName];
		
		[kThreadLastWrittenDateAttrTemplate setObject: [CMRPref threadsListFont] forKey: NSFontAttributeName];
		[kThreadLastWrittenDateAttrTemplate setObject: [CMRPref threadsListColor] forKey: NSForegroundColorAttributeName];
	}
}

+ (void) resetDataSourceTemplateForColumnIdentifier: (NSString *) identifier width: (float) loc
{
    static float cachedLoc1 = 0;
    static float cachedLoc2 = 0;

	if (kNewThreadCreatedDateAttrTemplate == nil
		|| kThreadCreatedDateAttrTemplate == nil
		|| kThreadModifiedDateAttrTemplate == nil
		|| kThreadLastWrittenDateAttrTemplate == nil) {
		
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
	} else if ([identifier isEqualToString: LastWrittenDateColumn]) {
        if (cachedLoc2 == 0 || loc != cachedLoc2) {
            cachedLoc2 = loc;
			NSParagraphStyle	*ps2 = pStyleForDateColumnWithWidth(cachedLoc2);
			
			[kThreadLastWrittenDateAttrTemplate setObject: ps2 forKey: NSParagraphStyleAttributeName];
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
+ (NSDictionary *)threadLastWrittenDateAttrTemplate
{
	return kThreadLastWrittenDateAttrTemplate;
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
/*
- (NSArray *) threadsForTableView : (NSTableView *) tableView
{
	return [self filteredThreads];
}*/
- (int) numberOfRowsInTableView : (NSTableView *) aTableView
{
//	return [[self filteredThreads] count];
	UTILAbstractMethodInvoked;
	return 0;
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
	UTILAbstractMethodInvoked;
	return nil;
}

- (id)            tableView : (NSTableView   *) aTableView
  objectValueForTableColumn : (NSTableColumn *) aTableColumn
                        row : (int            ) rowIndex
{
	UTILAbstractMethodInvoked;
	return nil;
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
	UTILAbstractMethodInvoked;
	return nil;
}

- (unsigned int) indexOfThreadWithPath : (NSString *) filepath
{
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
