//: SGTableViewBase.m
/**
  * $Id: SGTableViewBase.m,v 1.1 2005/05/11 17:51:26 tsawada2 Exp $
  * 
  * Copyright (c) 2001-2003, Takanori Ishikawa.  All rights reserved.
  * See the file LICENSE for copying permission.
  */

#import "SGTableViewBase_p.h"



@implementation SGTableViewBase
- (void) _updateToolTipRect
{
	int			i, cnt;
	
	[self removeAllToolTips];
	if(NO == [self showsToolTipForRow]) return;
	
	cnt = [self numberOfRows];
	for(i = 0; i < cnt; i++){
		[self addToolTipRect : [self rectOfRow : i]
					   owner : self
					userData : NULL];
	}
}
- (void) setFrameOrigin : (NSPoint)newOrigin;
{
	[super setFrameOrigin:newOrigin];
	[self _updateToolTipRect];
}

// NSView:
- (void) setFrameSize : (NSSize) newSize;
{
	[super setFrameSize : newSize];
	[self _updateToolTipRect];
}

- (void) setFrame : (NSRect) frameRect
{
	[super setFrame : frameRect];
	[self _updateToolTipRect];
}


// NSDraggingSource
- (unsigned int) draggingSourceOperationMaskForLocal : (BOOL) localFlag
{
	id				source_;
	unsigned int	mask_;
	
	source_ = [self dataSource];
	if([[self superclass] instancesRespondToSelector : _cmd])
		mask_ = [super draggingSourceOperationMaskForLocal : localFlag];
	else
		mask_ = NSDragOperationGeneric;
	
	if(source_ != nil && [source_ respondsToSelector : _cmd])
		return [source_ draggingSourceOperationMaskForLocal : localFlag];
	
	return mask_;
}

- (BOOL) ignoreModifierKeysWhileDragging
{
	id		source_;
	BOOL	ignore_;
	
	source_ = [self dataSource];
	if([[self superclass] instancesRespondToSelector : _cmd])
		ignore_ = [super ignoreModifierKeysWhileDragging];
	else
		ignore_ = NO;
	if(source_ != nil && [source_ respondsToSelector : _cmd])
		return [source_ ignoreModifierKeysWhileDragging];
	
	return ignore_;
}

- (void) draggedImage : (NSImage *) anImage
			  beganAt : (NSPoint  ) aPoint
{
	id		source_;
	
	source_ = [self dataSource];
	if([[self superclass] instancesRespondToSelector : _cmd])
		[super draggedImage:anImage beganAt:aPoint];
	if([source_ respondsToSelector : _cmd])
		[source_ draggedImage:anImage beganAt:aPoint];
}
- (void) draggedImage : (NSImage *) draggedImage
			  movedTo : (NSPoint  ) screenPoint
{
	id		source_;
	
	source_ = [self dataSource];
	if([source_ respondsToSelector : _cmd])
		[source_ draggedImage:draggedImage movedTo:screenPoint];
}
- (void) draggedImage : (NSImage	   *) anImage
			  endedAt : (NSPoint		) aPoint
			operation : (NSDragOperation) operation
{
	id		source_;
	
	source_ = [self dataSource];
	if([[self superclass] instancesRespondToSelector : _cmd])
		[super draggedImage:anImage endedAt:aPoint operation:operation];
	if([source_ respondsToSelector : _cmd])
		[source_ draggedImage:anImage endedAt:aPoint operation:operation];
}

// Subclass Implementation
- (BOOL) showsToolTipForRow
{
	return NO;
}
- (void) setShowsToolTipForRow : (BOOL) flag
{
	[self _updateToolTipRect];
}
- (NSColor *) stripedColor
{
	return nil;
}
- (void) setStripedColor : (NSColor *) aStripedColor
{
	;
}
- (BOOL) drawsStriped
{
	return NO;
}
- (void) setDrawsStriped : (BOOL) aDrawsStriped
{
	;
}
- (BOOL) drawsVerticalGrid
{
	return NO;
}
- (void) setDrowsVerticalGrid : (BOOL) flag
{
	;
}
@end



@implementation NSTableView(StripedColorDrawing)
- (void) synchronizeAllTableColumnAttributes
{
	NSEnumerator	*iter_;
	NSTableColumn	*tableColumn_;
	
	iter_ = [[self tableColumns] objectEnumerator];
	while(tableColumn_ = [iter_ nextObject]){
		[self synchronizeTableColumnAttributes : tableColumn_];
	}
}
- (void) synchronizeTableColumnAttributes : (NSTableColumn *) tableColumn;
{
	if(nil == tableColumn) return;
	
	if([[tableColumn dataCell] respondsToSelector : @selector(setFont:)] &&
			[(NSCell *)[tableColumn dataCell] type] == NSTextCellType){
		[[tableColumn dataCell] setFont : [self font]];
	}
	if([[tableColumn dataCell] respondsToSelector : @selector(setDrawsBackground:)]){
		[[tableColumn dataCell] setDrawsBackground : (NO == [self drawsStriped])];
	}
}
@end
