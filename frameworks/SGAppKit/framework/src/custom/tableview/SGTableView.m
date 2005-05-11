//: SGTableView.m
/**
  * $Id: SGTableView.m,v 1.1.1.1 2005/05/11 17:51:26 tsawada2 Exp $
  * 
  * Copyright (c) 2001-2003, Takanori Ishikawa.  All rights reserved.
  * See the file LICENSE for copying permission.
  */

#import "SGTableView_p.h"
#import "SGTableViewBase_p.h"



@implementation SGTableView
- (void) dealloc
{
	[_stripedColor release];
	[_font release];
	[super dealloc];
}
- (NSFont *) font
{
	return _font;
}
- (void) setFont : (NSFont *) aFont
{
	id tmp;
	
	tmp = _font;
	_font = [aFont retain];
	[tmp release];
	
	[super setFont : aFont];
	[self synchronizeAllTableColumnAttributes];
}
- (void) addTableColumn : (NSTableColumn *) aColumn
{
	[super addTableColumn : aColumn];
	[self synchronizeTableColumnAttributes : aColumn];
}
// NSView
- (void) drawRect : (NSRect) aRect
{
	[super drawRect : aRect];
	if([self drawsStriped])
		[self drawEmptyRows];
}

// NSTableView:
- (void) drawRow : (int   ) rowIndex
		clipRect : (NSRect) clipRect
{
	if([self drawsStriped])
		[self fillWithStripedColorInRow : rowIndex];
	
	if(rowIndex < [self numberOfRows]){
		[super drawRow : rowIndex
			  clipRect : clipRect];
	}
}
- (void) drawGridInClipRect : (NSRect) aRect
{
	[self drawVerticalGridInClipRect : aRect];
}
@end



@implementation SGTableView(SGTableViewBase)
/* Accessor for _stripedColor */
- (NSColor *) stripedColor
{
	if(nil == _stripedColor)
		return [NSColor iTunesStripedColor];
	
	return _stripedColor;
}
- (void) setStripedColor : (NSColor *) aStripedColor
{
	id tmp;
	
	tmp = _stripedColor;
	_stripedColor = [aStripedColor retain];
	[tmp release];
}

- (BOOL) drawsStriped
{
	return _drawsStriped;
}
- (void) setDrawsStriped : (BOOL) aDrawsStriped
{
	_drawsStriped = aDrawsStriped;
	[self synchronizeAllTableColumnAttributes];
}

- (BOOL) showsToolTipForRow
{
	return _showsToolTipForRow;
}
- (void) setShowsToolTipForRow : (BOOL) flag
{
	_showsToolTipForRow = flag;
	[super setShowsToolTipForRow : flag];
}
@end
