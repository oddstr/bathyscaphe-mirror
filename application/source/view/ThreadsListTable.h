/**
  * $Id: ThreadsListTable.h,v 1.2 2005/10/07 00:18:50 tsawada2 Exp $
  * 
  * ThreadsListTable.h
  * スレッド一覧を表示するテーブル
  *
  * Copyright (c) 2003, Takanori Ishikawa.
  * See the file LICENSE for copying permission.
  */
#import <Cocoa/Cocoa.h>
#import <SGAppKit/SGAppKit.h>


@interface ThreadsListTable : NSTableView
{
	@private
	NSArray	*allColumns;	// added in ShortCircuit and later.
}

// ShortCircuit Additions
- (NSObject<NSCoding> *) columnState;
- (void) restoreColumnState : (NSObject *) columnState;
- (void) setColumnWithIdentifier : (id) identifier visible : (BOOL) visible;
- (BOOL) isColumnWithIdentifierVisible : (id) identifier;
- (NSTableColumn *) initialColumnWithIdentifier : (id) identifier;
- (void) removeAllColumns;
- (void) setInitialState;
@end
