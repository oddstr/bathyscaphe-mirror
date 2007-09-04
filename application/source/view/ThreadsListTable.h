/**
  * $Id: ThreadsListTable.h,v 1.3 2007/09/04 07:45:43 tsawada2 Exp $
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

// Available in Twincam Angel.
- (IBAction)revealInFinder:(id)sender;
@end
