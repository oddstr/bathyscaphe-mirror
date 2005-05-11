//: NSTableView+CMXBrowser.h
/**
  * $Id: NSTableView+CMXBrowser.h,v 1.1 2005/05/11 17:51:05 tsawada2 Exp $
  * 
  * Copyright (c) 2001-2003, Takanori Ishikawa.  All rights reserved.
  * See the file LICENSE for copying permission.
  */

#import <Cocoa/Cocoa.h>


@interface NSTableView(CMXBrowser)
+ (NSImage *) headerSortImage : (BOOL) acsending;
+ (NSImage *) headerSortImage;
+ (NSImage *) headerReverseSortImage;

- (void) removeAllColumns;

- (id) objectValueForTableColumn : (NSTableColumn *) aColumn
						   atRow : (int            ) rowIndex;
// 各Cellの高さに合わせる
- (void) setRowHeightColumnDataCellToFit;

// 単純に背景色が白かどうか調べる
- (BOOL) drawsBackground;
- (void) setDrawsBackground : (BOOL) flag;
@end
