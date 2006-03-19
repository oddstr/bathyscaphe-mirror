/**
  * $Id: ThreadsListTable.m,v 1.5.2.2 2006/03/19 15:09:53 masakih Exp $
  * 
  * ThreadsListTable.m
  *
  * Copyright (c) 2003, Takanori Ishikawa.
  * See the file LICENSE for copying permission.
  */
#import "ThreadsListTable.h"
#import "CMRThreadsList.h"
#import "AppDefaults.h"

#define kBrowserKeyBindingsFile		@"BrowserKeyBindings.plist"



@implementation ThreadsListTable
- (void) dealloc
{
	[allColumns release];
	[super dealloc];
}

- (void) _drawStringIn : (NSRect) rect withString : (NSString *) str
{
	NSMutableDictionary		*attr_;
	NSPoint					stringOrigin;
	NSSize					stringSize;
	
	attr_ = [[NSMutableDictionary alloc] init];

	[attr_ setObject : [NSFont boldSystemFontOfSize : 12.0 ] forKey : NSFontAttributeName];
	[attr_ setObject : [NSColor whiteColor] forKey : NSForegroundColorAttributeName];

	stringSize = [str sizeWithAttributes : attr_];
	stringOrigin.x = rect.origin.x + (rect.size.width - stringSize.width) / 2;
	stringOrigin.y = rect.origin.y + (rect.size.height - stringSize.height) / 2;
	
	[str drawAtPoint : stringOrigin withAttributes : attr_];
	
	[attr_ release];
}

- (NSImage *) _draggingBadgeForRowCount : (unsigned int) countOfRows
{
	NSImage	*anImg = [[NSImage alloc] init];
	NSRect	imageBounds;
	NSString	*str_;

	str_ = [NSString stringWithFormat : @"%i", countOfRows];

	imageBounds.origin = NSMakePoint(16.0, 15.0);
	imageBounds.size = NSMakeSize(26.0, 26.0);

	[anImg setSize : NSMakeSize(40.0, 40.0)];

	[anImg lockFocus];
	[self _drawStringIn : imageBounds withString : str_];
	[[NSImage imageAppNamed : @"DraggingBadge"] compositeToPoint : NSMakePoint(16.0, 14.0)
													   operation : NSCompositeDestinationOver];
	[[[NSWorkspace sharedWorkspace] iconForFileType : @"thread"] compositeToPoint : NSMakePoint(4.0, 0.0)
																		operation : NSCompositeDestinationOver
																		fraction : 0.7];
	[anImg unlockFocus];

	return [anImg autorelease];
}

- (NSImage*) dragImageForRows : (NSArray      *) dragRows
                        event : (NSEvent      *) dragEvent
              dragImageOffset : (NSPointPointer) dragImageOffset
{
	if ([dragRows count] == 1) {
		return [[self dataSource] isFavorites]
						? [super dragImageForRows : dragRows event : dragEvent dragImageOffset : dragImageOffset]
						: [[NSWorkspace sharedWorkspace] iconForFileType : @"thread"];
	} else {
		return [self _draggingBadgeForRowCount : [dragRows count]];
	}
}

// For Tiger or later
- (NSImage *) dragImageForRowsWithIndexes : (NSIndexSet *) dragRows
							 tableColumns : (NSArray *) tableColumns
									event : (NSEvent *) dragEvent
								   offset : (NSPointPointer) dragImageOffset
{
	if ([dragRows count] == 1) {
		return [[self dataSource] isFavorites]
						? [super dragImageForRowsWithIndexes : dragRows tableColumns : tableColumns event : dragEvent offset : dragImageOffset]
						: [[NSWorkspace sharedWorkspace] iconForFileType : @"thread"];
	} else {
		return [self _draggingBadgeForRowCount : [dragRows count]];
	}

}
	
// KeyBindings
+ (SGKeyBindingSupport *) keyBindingSupport
{
	static SGKeyBindingSupport *stKeyBindingSupport_;
	
	if(nil == stKeyBindingSupport_){
		NSDictionary	*dict;
		
		dict = [NSBundle mergedDictionaryWithName : kBrowserKeyBindingsFile];
		UTILAssertKindOfClass(dict, NSDictionary);
		
		stKeyBindingSupport_ = 
			[[SGKeyBindingSupport alloc] initWithDictionary : dict];
	}
	return stKeyBindingSupport_;
}


// [Keybinding Responder Chain]
// self --> target --> [self window]
- (BOOL) interpretKeyBinding : (NSEvent *) theEvent
{
	id	targets_[] = {
			self,
			[self target],
			[self window],
			NULL
		};
	
	id	*p;
	
	for(p = targets_; *p != NULL; p++){
		if([[[self class] keyBindingSupport] 
				interpretKeyBindingWithEvent:theEvent target:*p])
			return YES;
	}
	return NO;
}
- (void) keyDown : (NSEvent *) theEvent
{
	// デバッグ用	
	UTILDescription(theEvent);
	UTILDescUnsignedInt([theEvent modifierFlags]);
	UTILDescription([theEvent characters]);
	UTILDescription([theEvent charactersIgnoringModifiers]);
	
	if([self interpretKeyBinding : theEvent])
		return;
	
	[super keyDown : theEvent];
}

// Cocoaはさっぱり!!! version.4 スレッドの54-55 がドンピシャだった
- (NSMenu *) menuForEvent : (NSEvent *) theEvent
{
	int row = [self rowAtPoint : [self convertPoint : [theEvent locationInWindow] fromView : nil]];

	if(![self isRowSelected : row]) [self selectRow : row byExtendingSelection : NO];
	if(row >= 0) {
		return [self menu];
	} else {
		return nil;
	}
}

- (void) scrollRowToTop : (id) sender
{
	[self scrollRowToVisible : 0];
}

- (void) scrollRowToEnd : (id) sender
{
	[self scrollRowToVisible : ([self numberOfRows]-1)];
}

#pragma mark ShortCircuit Additions

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

- (NSObject<NSCoding> *) columnState
{
	NSMutableArray	*state;
	NSArray			*columns;
	NSEnumerator	*enumerator;
	NSTableColumn	*column;

	columns = [self tableColumns];
	state = [NSMutableArray arrayWithCapacity : [columns count]];
	enumerator = [columns objectEnumerator];

	while(column = [enumerator nextObject]) {
		[state addObject : [NSDictionary dictionaryWithObjectsAndKeys : 
														[column identifier], @"Identifier",
														[NSNumber numberWithFloat : [column width]], @"Width",
														nil]];
	}

	return state;
}

- (void) restoreColumnState : (NSObject *) columnState
{
	NSArray			*state;
	NSEnumerator	*enumerator;
	NSDictionary	*params;
	NSTableColumn	*column;

	NSAssert(columnState != nil, @"nil columnState!" );
	NSAssert([columnState isKindOfClass : [NSArray class]], @"columnState is not an NSArray!" );

	state = (NSArray *)columnState;

	enumerator = [state objectEnumerator];
	[self removeAllColumns];
	while (params = [enumerator nextObject]) {
		column = [self initialColumnWithIdentifier : [params objectForKey : @"Identifier"]];

		if (column != nil) {
			[column setWidth : [[params objectForKey : @"Width"] floatValue]];
			[self addTableColumn : column];
			[self setIndicatorImage : nil inTableColumn:column];
			[self setNeedsDisplay : YES];
		}
	}

	//[self sizeLastColumnToFit];
}

- (void) setColumnWithIdentifier : (id) identifier visible : (BOOL) visible
{
	NSTableColumn	*column;

	column = [self initialColumnWithIdentifier : identifier];

	NSAssert(column != nil, @"nil column!");

	if(visible) {
		if(![self isColumnWithIdentifierVisible : identifier]) {
			
			if (![CMRPref isSplitViewVertical] && ![identifier isEqualToString : CMRThreadTitleKey]) {
				float tmp;
				NSTableColumn	*tmp2;
				
				[self addTableColumn : column];
				
				tmp = [column width];
				tmp2 = [self initialColumnWithIdentifier : CMRThreadTitleKey];
				[tmp2 setWidth : ([tmp2 width] - tmp)];
			} else {
				[self addTableColumn : column];			
			}
			[self sizeLastColumnToFit];
			[self setNeedsDisplay : YES];
		}
	} else {
		if([self isColumnWithIdentifierVisible : identifier]) {

			if (![CMRPref isSplitViewVertical] && ![identifier isEqualToString : CMRThreadTitleKey]) {			
				float tmp = [column width];
				NSTableColumn	*tmp2 = [self initialColumnWithIdentifier : CMRThreadTitleKey];
				
				[self removeTableColumn : column];
				[tmp2 setWidth : ([tmp2 width] + tmp)];
			} else {
				[self removeTableColumn : column];
			}
			if(![identifier isEqualToString : CMRThreadTitleKey])
				[self sizeLastColumnToFit];
			[self setNeedsDisplay : YES];
		}
	}
}

- (BOOL) isColumnWithIdentifierVisible : (id) identifier
{
	return [self columnWithIdentifier : identifier] != -1;
}

- (NSTableColumn *) initialColumnWithIdentifier : (id) identifier
{
	NSEnumerator	*enumerator;
	NSTableColumn	*column = nil;

	enumerator = [allColumns objectEnumerator];

	while(column = [enumerator nextObject])
		if([[column identifier] isEqual : identifier])
			break;

	return column;
}

- (void) removeAllColumns
{
	NSArray			*columns;
	NSEnumerator	*enumerator;
	NSTableColumn	*column;

	columns = [NSArray arrayWithArray : [self tableColumns]];
	enumerator = [columns objectEnumerator];

	while(column = [enumerator nextObject])
		[self removeTableColumn : column];
}

- (void) setInitialState
{
	allColumns = [[NSArray arrayWithArray : [self tableColumns]] retain];
}
@end
