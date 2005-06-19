/**
  * $Id: ThreadsListTable.m,v 1.3 2005/06/19 16:44:23 tsawada2 Exp $
  * 
  * ThreadsListTable.m
  *
  * Copyright (c) 2003, Takanori Ishikawa.
  * See the file LICENSE for copying permission.
  */
#import "ThreadsListTable.h"
#import "CMRThreadsList.h"
#import "CMXTemplateResources.h"


#define kBrowserKeyBindingsFile		@"BrowserKeyBindings.plist"



@implementation ThreadsListTable
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
	/*
	UTILDescription(theEvent);
	UTILDescUnsignedInt([theEvent modifierFlags]);
	UTILDescription([theEvent characters]);
	UTILDescription([theEvent charactersIgnoringModifiers]);
	CMRDebugWriteObject(
		[SGKeyBindingSupport keyBindingStringWithEvent:theEvent]);
	*/

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
@end
