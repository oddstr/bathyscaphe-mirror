//
//  ThreadsListTable.m
//  BathyScaphe
//
//  Updated by Tsutomu Sawada on 07/10/30.
//  Copyright 2005-2008 BathyScaphe Project. All rights reserved.
//  encoding="UTF-8"
//

#import "ThreadsListTable.h"
#import "CMRThreadsList.h"
#import "AppDefaults.h"
#import <SGAppKit/SGKeyBindingSupport.h>

static NSString *const kBrowserKeyBindingsFile = @"BrowserKeyBindings.plist";

@implementation ThreadsListTable
#pragma mark Drag & Drop
- (NSDragOperation)draggingSourceOperationMaskForLocal:(BOOL)isLocal
{
	if (isLocal) return NSDragOperationEvery;

	return (NSDragOperationCopy|NSDragOperationDelete|NSDragOperationLink);
}

- (void)draggedImage:(NSImage *)anImage endedAt:(NSPoint)aPoint operation:(NSDragOperation)operation
{
	id	source;

	source = [self dataSource];
	if (source && [source respondsToSelector:@selector(tableView:didEndDragging:)]) {
		[source tableView:self didEndDragging:operation];
	}
}

- (NSImage *)dragImageForRowsWithIndexes:(NSIndexSet *)dragRows
							tableColumns:(NSArray *)tableColumns
								   event:(NSEvent *)dragEvent
								  offset:(NSPointPointer)dragImageOffset
{
	id	dataSource = [self dataSource];
	if (dataSource && [dataSource respondsToSelector:@selector(dragImageForRowIndexes:inTableView:offset:)]) {
		return [dataSource dragImageForRowIndexes:dragRows inTableView:self offset:dragImageOffset];
	}
	
	return [super dragImageForRowsWithIndexes:dragRows tableColumns:tableColumns event:dragEvent offset:dragImageOffset];
}

#pragma mark (For Future Use)
- (NSArray *)attributesArrayForSelectedRowsExceptingPath:(NSString *)exceptingPath
{
	id dataSource = [self dataSource];
	if (!dataSource || ![dataSource respondsToSelector:@selector(tableView:threadAttibutesArrayAtRowIndexes:exceptingPath:)]) {
		NSBeep();
		return nil;
	}

	return [dataSource tableView:self threadAttibutesArrayAtRowIndexes:[self selectedRowIndexes] exceptingPath:exceptingPath];
}

#pragma mark Events
+ (SGKeyBindingSupport *)keyBindingSupport
{
	static SGKeyBindingSupport *stKeyBindingSupport_;
	
	if (!stKeyBindingSupport_) {
		NSDictionary	*dict;
		
		dict = [NSBundle mergedDictionaryWithName:kBrowserKeyBindingsFile];
		UTILAssertKindOfClass(dict, NSDictionary);
		
		stKeyBindingSupport_ = [[SGKeyBindingSupport alloc] initWithDictionary:dict];
	}
	return stKeyBindingSupport_;
}

// [Keybinding Responder Chain]
// self --> target --> [self window]
- (BOOL)interpretKeyBinding:(NSEvent *)theEvent
{
	id	targets_[] = {
			self,
			[self target],
			[self window],
			NULL
		};
	
	id	*p;
	
	for (p = targets_; *p != NULL; p++) {
		if([[[self class] keyBindingSupport] interpretKeyBindingWithEvent:theEvent target:*p]) {
			return YES;
		}
	}
	return NO;
}

- (void)keyDown:(NSEvent *)theEvent
{
	// デバッグ用	
	UTILDescription(theEvent);
	UTILDescUnsignedInt([theEvent modifierFlags]);
	UTILDescription([theEvent characters]);
	UTILDescription([theEvent charactersIgnoringModifiers]);
	
	if ([self interpretKeyBinding:theEvent]) {
		return;
	}
	[super keyDown:theEvent];
}

// Cocoaはさっぱり!!! version.4 スレッドの54-55 がドンピシャだった
- (NSMenu *)menuForEvent:(NSEvent *)theEvent
{
	int row = [self rowAtPoint:[self convertPoint:[theEvent locationInWindow] fromView:nil]];

	if (row < 0) return nil;

	if (![self isRowSelected:row]) {
		[self selectRowIndexes:[NSIndexSet indexSetWithIndex:row] byExtendingSelection:NO];
	}
	
	return [self menu];
}

#pragma mark Manual-save Table columns

/*
	2005-10-07 tsawada2 <ben-sawa@td5.so-net.ne.jp>
	NSTableView の AutoSave 機能に頼らず、自力でカラムの幅、順序、表示／非表示を記憶する。
	以下のコードは http://www.cocoabuilder.com/archive/message/cocoa/2003/11/16/77603 から拝借した。
	これらのメソッドを実際にどこでどう呼び出しているかは、CMRBrowser-ViewAccessor.m, CMRBrowser-Delegate.m を
	参照のこと。
*/

/*
If that can help you, here is some code I wrote that you can add to an
NSTableView subclass to do the trick.

This code allows you to:
- hide and show columns very simply,
- save and restore the order, size and visible state of the columns
(but NOT the sorting state, since I wrote it before Panther and I had
implemented my own sorting system -- I leave that to you as an
exercise!).

Here is how to use it:
- Once your table view is set up with all its columns, call
setInitialState (you must call it before any other method provided
here).
- To retrieve the current state in order to save it, call columnState
(this gives you a codable object, which happens to be an NSArray).
- To set the current state back, call restoreColumnState:.
- To hide or show a column, call setColumnWithIdentifier:visible:. (To
query the visible state, call isColumnWithIdentifierVisible:.)
- To retrieve the NSTableColumn object of a currently column given its
identifier, call initialColumnWithIdentifier:. (This works also with
columns that are currently hidden.)

Hope this helps...


(You also have to add an instance variable of type NSArray named
"allColumns". You also have to take care about its deallocation.)
*/

- (void)dealloc
{
	[allColumns release];
	[super dealloc];
}

- (NSObject<NSCoding> *)columnState
{
	NSMutableArray	*state;
	NSArray			*columns;
	NSEnumerator	*enumerator;
	NSTableColumn	*column;

	columns = [self tableColumns];
	state = [NSMutableArray arrayWithCapacity:[columns count]];
	enumerator = [columns objectEnumerator];

	while (column = [enumerator nextObject]) {
		[state addObject:[NSDictionary dictionaryWithObjectsAndKeys: 
														[column identifier], @"Identifier",
														[NSNumber numberWithFloat:[column width]], @"Width",
														nil]];
	}

	return state;
}

- (void)restoreColumnState:(NSObject *)columnState
{
	NSArray			*state;
	NSEnumerator	*enumerator;
	NSDictionary	*params;
	NSTableColumn	*column;

	NSAssert(columnState != nil, @"nil columnState!" );
	NSAssert([columnState isKindOfClass:[NSArray class]], @"columnState is not an NSArray!" );

	state = (NSArray *)columnState;

	enumerator = [state objectEnumerator];
	[self removeAllColumns];
	while (params = [enumerator nextObject]) {
		column = [self initialColumnWithIdentifier:[params objectForKey:@"Identifier"]];

		if (column) {
			[column setWidth:[[params objectForKey:@"Width"] floatValue]];
			[self addTableColumn:column];
			[self setIndicatorImage:nil inTableColumn:column];
			[self setNeedsDisplay:YES];
		}
	}

	//[self sizeLastColumnToFit];
}

- (void)setColumnWithIdentifier:(id)identifier visible:(BOOL)visible
{
	NSTableColumn	*column;

	column = [self initialColumnWithIdentifier:identifier];

	NSAssert(column != nil, @"nil column!");

	if (visible) {
		if(![self isColumnWithIdentifierVisible:identifier]) {
			if (![CMRPref isSplitViewVertical] && ![identifier isEqualToString:CMRThreadTitleKey]) {
				float tmp;
				NSTableColumn	*tmp2;
				
				[self addTableColumn:column];
				
				tmp = [column width];
				tmp2 = [self initialColumnWithIdentifier:CMRThreadTitleKey];
				[tmp2 setWidth:([tmp2 width] - tmp)];
			} else {
				[self addTableColumn:column];	
			}
			[self sizeLastColumnToFit];
			[self setNeedsDisplay:YES];
		}
	} else {
		if ([self isColumnWithIdentifierVisible:identifier]) {
			if (![CMRPref isSplitViewVertical] && ![identifier isEqualToString:CMRThreadTitleKey]) {			
				float tmp = [column width];
				NSTableColumn	*tmp2 = [self initialColumnWithIdentifier:CMRThreadTitleKey];
				
				[self removeTableColumn:column];
				[tmp2 setWidth:([tmp2 width] + tmp)];
			} else {
				[self removeTableColumn:column];
			}
			if (![identifier isEqualToString:CMRThreadTitleKey]) {
				[self sizeLastColumnToFit];
			}
			[self setNeedsDisplay:YES];
		}
	}
}

- (BOOL)isColumnWithIdentifierVisible:(id)identifier
{
	return ([self columnWithIdentifier:identifier] != -1);
}

- (NSTableColumn *)initialColumnWithIdentifier:(id)identifier
{
	NSEnumerator	*enumerator;
	NSTableColumn	*column = nil;

	enumerator = [allColumns objectEnumerator];

	while (column = [enumerator nextObject]) {
		if ([[column identifier] isEqual:identifier]) {
			break;
		}
	}
	return column;
}

- (void)removeAllColumns
{
	NSArray			*columns;
	NSEnumerator	*enumerator;
	NSTableColumn	*column;

	columns = [NSArray arrayWithArray:[self tableColumns]];
	enumerator = [columns objectEnumerator];

	while (column = [enumerator nextObject]) {
		[self removeTableColumn:column];
	}
}

- (void)setInitialState
{
	allColumns = [[NSArray arrayWithArray:[self tableColumns]] retain];
}

#pragma mark IBActions
- (IBAction)scrollRowToTop:(id)sender
{
	[self scrollRowToVisible:0];
}

- (IBAction)scrollRowToEnd:(id)sender
{
	[self scrollRowToVisible:([self numberOfRows]-1)];
}
/*
- (IBAction)deleteThread:(id)sender
{
	id dataSource = [self dataSource];
	if (!dataSource || ![dataSource respondsToSelector:@selector(tableView:removeFilesAtRowIndexes:ask:)]) {
		NSBeep();
		return;
	}
	[dataSource tableView:self removeFilesAtRowIndexes:[self selectedRowIndexes] ask:(![CMRPref quietDeletion])];
}
*/
- (IBAction)revealInFinder:(id)sender
{
	id dataSource = [self dataSource];
	if (!dataSource || ![dataSource respondsToSelector:@selector(tableView:revealFilesAtRowIndexes:)]) {
		NSBeep();
		return;
	}
	[dataSource tableView:self revealFilesAtRowIndexes:[self selectedRowIndexes]];
}

- (IBAction)openInBrowser:(id)sender
{
	id dataSource = [self dataSource];
	if (!dataSource || ![dataSource respondsToSelector:@selector(tableView:openURLsAtRowIndexes:)]) {
		NSBeep();
		return;
	}
	[dataSource tableView:self openURLsAtRowIndexes:[self selectedRowIndexes]];
}

- (IBAction)quickLook:(id)sender
{
	// Leopard
	if (floor(NSAppKitVersionNumber) > NSAppKitVersionNumber10_4) {	
		id dataSource = [self dataSource];
		if (!dataSource || ![dataSource respondsToSelector:@selector(tableView:quickLookAtRowIndexes:)]) {
			NSBeep();
			return;
		}
		[dataSource tableView:self quickLookAtRowIndexes:[self selectedRowIndexes]];
	}
}

#pragma mark Validations
- (BOOL)validateUserInterfaceItem:(id<NSValidatedUserInterfaceItem>)anItem
{
	SEL action = [anItem action];
	if (action == @selector(revealInFinder:)) {
//	if (action == @selector(revealInFinder:) || action == @selector(deleteThread:)) {
		int selectedRow = [self selectedRow];
		id dataSource = [self dataSource];

		if (selectedRow == -1) return NO;
//		if (!dataSource) return NO;
		if (!dataSource || ![dataSource respondsToSelector:@selector(threadFilePathAtRowIndex:inTableView:status:)]) return NO;

		ThreadStatus status;
		[dataSource threadFilePathAtRowIndex:selectedRow inTableView:self status:&status];
		return ((status & ThreadLogCachedStatus) > 0);
	} else if (action == @selector(quickLook:)) {
		return ([[self selectedRowIndexes] count] == 1);
	} else if (action == @selector(openInBrowser:)) {
		return ([[self selectedRowIndexes] count] > 0);
	}
	return [super validateUserInterfaceItem:anItem];
}

- (BOOL)validateNSControlToolbarItem:(NSToolbarItem *)item
{
	SEL action = [(NSControl *)[item view] action];
	if (action == @selector(quickLook:)) {
		return ([[self selectedRowIndexes] count] == 1);
	}
	return YES;
}
@end
