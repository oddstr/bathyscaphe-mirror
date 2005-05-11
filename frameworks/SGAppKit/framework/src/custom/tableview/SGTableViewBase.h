//: SGTableViewBase.h
/**
  * $Id: SGTableViewBase.h,v 1.1 2005/05/11 17:51:26 tsawada2 Exp $
  * 
  * Copyright (c) 2001-2003, Takanori Ishikawa.  All rights reserved.
  * See the file LICENSE for copying permission.
  */

#import <Cocoa/Cocoa.h>



@interface SGTableViewBase : NSTableView
@end


// 
// このカテゴリのメソッドをサブクラス側は実装
// ただ、縞模様の描画コードはSGTableView/SGOutlineView
// それぞれに移した。
// 
@interface NSTableView(SGTableViewBase)
- (BOOL) showsToolTipForRow;
- (void) setShowsToolTipForRow : (BOOL) flag;

- (NSColor *) stripedColor;
- (void) setStripedColor : (NSColor *) aStripedColor;
- (BOOL) drawsStriped;
- (void) setDrawsStriped : (BOOL) aDrawsStriped;

- (BOOL) drawsVerticalGrid;
- (void) setDrowsVerticalGrid : (BOOL) flag;
@end
