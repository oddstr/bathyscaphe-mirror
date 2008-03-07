/**
  * $Id: CMRThreadsList-DataSource.m,v 1.30 2008/03/07 15:13:43 tsawada2 Exp $
  * 
  * CMRThreadsList-DataSource.m
  *
  * Copyright (c) 2003, Takanori Ishikawa.
  * See the file LICENSE for copying permission.
  */
#import "CMRThreadsList_p.h"
#import "CMRThreadSignature.h"
#import "BSQuickLookPanelController.h"
#import "BSQuickLookObject.h"
#import "BSDateFormatter.h"
#import "DatabaseManager.h"


@implementation CMRThreadsList(DataSource)
static id kNewThreadAttrTemplate;
static id kThreadAttrTemplate;
static id kDatOchiThreadAttrTemplate;

static NSMutableDictionary *kThreadCreatedDateAttrTemplate;
static NSMutableDictionary *kThreadModifiedDateAttrTemplate;
static NSMutableDictionary *kThreadLastWrittenDateAttrTemplate;

static NSMutableParagraphStyle	*pStyleForDateColumnWithWidth (float tabWidth)
{
	NSMutableParagraphStyle *style_;
    NSTextTab	*tab_ = [[NSTextTab alloc] initWithType: NSRightTabStopType location: tabWidth];
	
	style_ = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
	[style_ setLineBreakMode : NSLineBreakByClipping];
	[style_ setTabStops: [NSArray array]];
    [style_ addTabStop: tab_];
	[tab_ release];

	return [style_ autorelease];
}

+ (void) resetDataSourceTemplateForDateColumn
{
	if (kThreadCreatedDateAttrTemplate == nil
		|| kThreadModifiedDateAttrTemplate == nil
		|| kThreadLastWrittenDateAttrTemplate == nil) {
		
		kThreadCreatedDateAttrTemplate = [[NSMutableDictionary alloc] init];
		kThreadModifiedDateAttrTemplate = [[NSMutableDictionary alloc] init];
		kThreadLastWrittenDateAttrTemplate = [[NSMutableDictionary alloc] init];
	} else {
		// do nothing.
	}
}

+ (void) resetDataSourceTemplateForColumnIdentifier: (NSString *) identifier width: (float) loc
{
    static float cachedLoc1 = 0;
    static float cachedLoc2 = 0;
	static float cachedLoc3 = 0;

	[self resetDataSourceTemplateForDateColumn];

    if ([identifier isEqualToString: ThreadPlistIdentifierKey]) {
        if (cachedLoc1 == 0 || loc != cachedLoc1) {
            cachedLoc1 = loc;
			NSParagraphStyle	*ps = pStyleForDateColumnWithWidth(cachedLoc1);

			[kThreadCreatedDateAttrTemplate setObject: ps forKey: NSParagraphStyleAttributeName];
		}
    } else if ([identifier isEqualToString: CMRThreadModifiedDateKey]) {
        if (cachedLoc2 == 0 || loc != cachedLoc2) {
            cachedLoc2 = loc;
			NSParagraphStyle	*ps2 = pStyleForDateColumnWithWidth(cachedLoc2);

			[kThreadModifiedDateAttrTemplate setObject: ps2 forKey: NSParagraphStyleAttributeName];
		}
	} else if ([identifier isEqualToString: LastWrittenDateColumn]) {
        if (cachedLoc3 == 0 || loc != cachedLoc3) {
            cachedLoc3 = loc;
			NSParagraphStyle	*ps3 = pStyleForDateColumnWithWidth(cachedLoc3);
			
			[kThreadLastWrittenDateAttrTemplate setObject: ps3 forKey: NSParagraphStyleAttributeName];
		}
	}
}

+ (void) resetDataSourceTemplates
{
	// default object value:
	kThreadAttrTemplate = [[NSDictionary alloc] initWithObjectsAndKeys :
							[CMRPref threadsListFont], NSFontAttributeName,
							[CMRPref threadsListColor], NSForegroundColorAttributeName,
							nil];

	// New Arrival thread:
	kNewThreadAttrTemplate = [[NSDictionary alloc] initWithObjectsAndKeys :
								[CMRPref threadsListNewThreadFont], NSFontAttributeName,
								[CMRPref threadsListNewThreadColor], NSForegroundColorAttributeName,
								nil];

	// Dat Ochi thread:
	kDatOchiThreadAttrTemplate = [[NSDictionary alloc] initWithObjectsAndKeys :
								[CMRPref threadsListDatOchiThreadFont], NSFontAttributeName,
								[CMRPref threadsListDatOchiThreadColor], NSForegroundColorAttributeName,
								nil];
}

/* TODO その場しのぎ。本来はNSMutableDictionaryをNSDictionaryに変換して返すべきだが、速度的に現実的ではない。*/
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
	NSRange	range;
	
	if(nil == aValue || [aValue isKindOfClass : [NSImage class]])
		return aValue;
	
	if([aValue isKindOfClass : [NSAttributedString class]]) {
		if([aValue respondsToSelector:@selector(addAttributes:range:)]) {
			temp = [aValue retain];
		} else {
			temp = [aValue mutableCopy];
		}
	} else {
		temp = [[NSMutableAttributedString alloc] initWithString : [aValue stringValue]];
	}
	
	if (nil == kNewThreadAttrTemplate
		|| nil == kThreadAttrTemplate
		|| nil == kDatOchiThreadAttrTemplate)
		[self resetDataSourceTemplates];
	
	range = NSMakeRange(0,[temp length]);
	switch(aType){
	case kValueTemplateDefaultType:
		[temp addAttributes : kThreadAttrTemplate
					  range : range];
		break;
	case kValueTemplateNewArrivalType:
		[temp addAttributes : kNewThreadAttrTemplate
					  range : range];
		break;
	case kValueTemplateDatOchiType:
		[temp addAttributes : kDatOchiThreadAttrTemplate
					  range : range];
		break;
	default :
		UTILUnknownSwitchCase(aType);
		break;
	}
	
	return [temp autorelease];	
}
/*
- (NSArray *) threadsForTableView : (NSTableView *) tableView
{
	return [self filteredThreads];
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
*/
- (int)numberOfRowsInTableView:(NSTableView *)aTableView
{
	UTILAbstractMethodInvoked;
	return 0;
}

- (id)objectValueForIdentifier:(NSString *)identifier threadArray:(NSArray  *)threadArray atIndex:(int )index
{
	UTILAbstractMethodInvoked;
	return nil;
}

- (id)tableView:(NSTableView *)aTableView objectValueForTableColumn:(NSTableColumn *)aTableColumn row:(int )rowIndex
{
	UTILAbstractMethodInvoked;
	return nil;
}

#pragma mark Drag and Drop support
// Deprecated in Mac OS X 10.4 and later.
/*- (BOOL)tableView:(NSTableView *)tableView writeRows:(NSArray *)rows toPasteboard:(NSPasteboard *)pboard
{
	NSIndexSet *indexSet = [NSIndexSet rowIndexesWithRows:rows];
	return [self tableView:tableView writeRowsWithIndexes:indexSet toPasteboard:pboard];
}*/

- (BOOL)tableView:(NSTableView *)tableView writeRowsWithIndexes:(NSIndexSet *)rowIndexes toPasteboard:(NSPasteboard *)pboard
{
	NSArray			*types_;
	unsigned int	numOfRows, index_;
	NSMutableArray	*filenames_, *urls_, *thSigs_;
	NSRange			indexRange;
	NSMutableString	*tmp_;

	numOfRows = [rowIndexes count];
	filenames_ = [NSMutableArray arrayWithCapacity:numOfRows];
	urls_ = [NSMutableArray arrayWithCapacity:numOfRows];
	thSigs_ = [NSMutableArray arrayWithCapacity:numOfRows];
	indexRange = NSMakeRange(0, [rowIndexes lastIndex]+1);
	tmp_ = SGTemporaryString();

	while ([rowIndexes getIndexes:&index_ maxCount:1 inIndexRange:&indexRange] > 0) {
		NSDictionary	*thread_;
		NSString		*path_;
		NSURL			*url_;

		thread_ = [self threadAttributesAtRowIndex:index_ inTableView:tableView];
		
		if (!thread_) continue;
		
		path_ = [CMRThreadAttributes pathFromDictionary:thread_];
		url_ = [CMRThreadAttributes threadURLWithDefaultParameterFromDictionary:thread_];

		[CMRThreadAttributes fillBuffer:tmp_ withThreadInfoForCopying:[NSArray arrayWithObject:thread_]];
		
		[urls_ addObject:url_];
        [thSigs_ addObject:[[CMRThreadSignature threadSignatureFromFilepath:path_] propertyListRepresentation]];		

		if([[NSFileManager defaultManager] fileExistsAtPath:path_]){
			[filenames_ addObject:path_];
		}
	}

	if([filenames_ count] > 0){
		types_ = [NSArray arrayWithObjects:NSURLPboardType, NSStringPboardType, NSFilenamesPboardType, BSThreadItemsPboardType, nil];
	}else if([tmp_ length] > 0){
		types_ = [NSArray arrayWithObjects:NSURLPboardType, NSStringPboardType, BSThreadItemsPboardType, nil];
	}else{
		return NO;
	}
	
	[pboard declareTypes:types_ owner:NSApp];

	if([filenames_ count] > 0){
        [pboard setPropertyList:filenames_ forType:NSFilenamesPboardType];
	}

	[pboard setString:tmp_ forType:NSStringPboardType];
	[[urls_ lastObject] writeToPasteboard:pboard];
	[pboard setPropertyList:thSigs_ forType:BSThreadItemsPboardType];

	[tmp_ deleteCharactersInRange:[tmp_ range]];
	return YES;
}

#pragma mark Getting Thread Attributes
- (NSString *)threadFilePathAtRowIndex:(int )rowIndex inTableView:(NSTableView *)tableView status:(ThreadStatus *)status
{
	NSString		*path_;
	NSDictionary	*thread_;
	
	thread_ = [self threadAttributesAtRowIndex:rowIndex inTableView:tableView];
	if(!thread_) return nil;
	if(status != NULL){
		NSNumber *stNum_;
		
		stNum_ = [thread_ objectForKey:CMRThreadStatusKey];
		
		UTILAssertNotNil(stNum_);
		*status = [stNum_ unsignedIntValue];
	}

	path_ = [CMRThreadAttributes pathFromDictionary:thread_];
	UTILAssertNotNil(path_);

	return path_;
}

- (NSString *)threadTitleAtRowIndex:(int )rowIndex inTableView:(NSTableView *)tableView
{
	NSString		*title_;
	NSDictionary	*thread_;
	
	thread_ = [self threadAttributesAtRowIndex:rowIndex inTableView:tableView];
	if(!thread_) return nil;
	title_ = [CMRThreadAttributes threadTitleFromDictionary:thread_];
	UTILAssertNotNil(title_);

	return title_;
}

- (NSDictionary *)threadAttributesAtRowIndex:(int )rowIndex inTableView:(NSTableView *)tableView
{
	UTILAbstractMethodInvoked;
	return nil;
}

- (unsigned int)indexOfThreadWithPath:(NSString *)filepath
{
	UTILAbstractMethodInvoked;
	return 0;
}

- (CMRThreadSignature *)threadSignatureWithTitle:(NSString *)title
{
	UTILAbstractMethodInvoked;
	return nil;
}

- (NSArray *)tableView:(NSTableView *)aTableView threadAttibutesArrayAtRowIndexes:(NSIndexSet *)rowIndexes exceptingPath:(NSString *)filepath
{
	unsigned int	count = [rowIndexes count];
	if (count == 0) return nil;

	NSMutableArray	*mutableArray = [[NSMutableArray alloc] initWithCapacity:count];
	NSArray			*resultArray;

	unsigned int	element;
	NSDictionary	*dict;
	NSString		*threadPath;
	int				size = [rowIndexes lastIndex]+1;
	NSRange			e = NSMakeRange(0, size);

	while ([rowIndexes getIndexes:&element maxCount:1 inIndexRange:&e] > 0) {
		dict = [self threadAttributesAtRowIndex:element inTableView:aTableView];
		threadPath = [CMRThreadAttributes pathFromDictionary:dict];
		if (![threadPath isEqualToString:filepath]) [mutableArray addObject:dict];
	}

	resultArray = [[NSArray alloc] initWithArray:mutableArray];
	[mutableArray release];
	return [resultArray autorelease];
}

- (NSArray *)tableView:(NSTableView *)aTableView threadFilePathsArrayAtRowIndexes:(NSIndexSet *)rowIndexes
{
	NSMutableArray	*pathArray_ = [NSMutableArray arrayWithCapacity:[rowIndexes count]];
	unsigned int	arrayElement;
	int				size = [rowIndexes lastIndex]+1;
	NSRange			e = NSMakeRange(0, size);

	while ([rowIndexes getIndexes:&arrayElement maxCount:1 inIndexRange:&e] > 0) {
		NSString	*path_;
		path_ = [self threadFilePathAtRowIndex:arrayElement inTableView:aTableView status:NULL];
		[pathArray_ addObject:path_];
	}

	return pathArray_;
}

- (void)tableView:(NSTableView *)aTableView revealFilesAtRowIndexes:(NSIndexSet *)rowIndexes
{
	NSArray *filePaths = [self tableView:aTableView threadFilePathsArrayAtRowIndexes:rowIndexes];
	[[NSWorkspace sharedWorkspace] revealFilesInFinder:filePaths];
}

- (void)tableView:(NSTableView *)aTableView quickLookAtRowIndexes:(NSIndexSet *)rowIndexes
{
	unsigned int rowIndex = [rowIndexes firstIndex];
	BSQuickLookPanelController *qlc = [BSQuickLookPanelController sharedInstance];
	[qlc showWindow:self];

	if ([[qlc window] isVisible]) {
		NSString *path = [self threadFilePathAtRowIndex:rowIndex inTableView:aTableView status:NULL];
		NSString *title = [self threadTitleAtRowIndex:rowIndex inTableView:aTableView];

		CMRThreadSignature *foo = [CMRThreadSignature threadSignatureFromFilepath:path];
		BSQuickLookObject	*bar = [[BSQuickLookObject alloc] initWithThreadTitle:title signature:foo];
		[[qlc objectController] setContent:bar];
		[bar release];
	}
}

- (void)tableView:(NSTableView *)aTableView openURLsAtRowIndexes:(NSIndexSet *)rowIndexes
{
	NSMutableArray	*urls = [NSMutableArray arrayWithCapacity:[rowIndexes count]];

	unsigned int	element;
	NSDictionary	*dict;
	NSURL			*url;
	int				size = [rowIndexes lastIndex]+1;
	NSRange			e = NSMakeRange(0, size);

	while ([rowIndexes getIndexes:&element maxCount:1 inIndexRange:&e] > 0) {
		dict = [self threadAttributesAtRowIndex:element inTableView:aTableView];
		url = [CMRThreadAttributes threadURLWithDefaultParameterFromDictionary:dict];
		if (url) [urls addObject:url];
	}

	[[NSWorkspace sharedWorkspace] openURLs:urls inBackground:[CMRPref openInBg]];
}

#pragma mark NSDraggingSource
- (BOOL)userWantsToMoveToTrash
{
	if (![self isFavorites]) return YES;

	NSAlert *alert = [[[NSAlert alloc] init] autorelease];
	[alert setAlertStyle:NSWarningAlertStyle];
	[alert setMessageText:[self localizedString:@"DragDropTrashAlert"]];
	[alert setInformativeText:[self localizedString:@"DragDropTrashMessage"]];
	[alert addButtonWithTitle:[self localizedString:@"DragDropTrashOK"]];
	[alert addButtonWithTitle:[self localizedString:@"DragDropTrashCancel"]];
	return ([alert runModal] == NSAlertFirstButtonReturn);
}
/*
- (unsigned int)draggingSourceOperationMaskForLocal:(BOOL)localFlag
{
	if (localFlag) return NSDragOperationEvery;

	return (NSDragOperationCopy|NSDragOperationDelete|NSDragOperationLink);
}
*/
- (void)tableView:(NSTableView *)aTableView didEndDragging:(NSDragOperation)operation
{
	NSPasteboard	*pboard_;

	// 「ゴミ箱」への移動でなければ終わり
	if (NO == (NSDragOperationDelete & operation)) {
		return;
	}

	pboard_ = [NSPasteboard pasteboardWithName:NSDragPboard];
	if(![[pboard_ types] containsObject:NSFilenamesPboardType]) {
		return;
	}

	if ([self userWantsToMoveToTrash]) {
		NSArray	*files = [pboard_ propertyListForType:NSFilenamesPboardType];
		[self tableView:aTableView removeFiles:files delFavIfNecessary:YES];
	}
}
@end
