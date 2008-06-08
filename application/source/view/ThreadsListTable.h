//
//  ThreadsListTable.h
//  BathyScaphe
//
//  Updated by Tsutomu Sawada on 07/10/30.
//  Copyright 2005-2008 BathyScaphe Project. All rights reserved.
//  encoding="UTF-8"
//

#import <Cocoa/Cocoa.h>

@interface ThreadsListTable : NSTableView {
	@private
	NSArray	*allColumns;
}

- (NSArray *)attributesArrayForSelectedRowsExceptingPath:(NSString *)exceptingPath; // Available in SilverGull and later.

// Saving Column State
- (NSObject<NSCoding> *)columnState;
- (void)restoreColumnState:(NSObject *)columnState;
- (void)setColumnWithIdentifier:(id)identifier visible:(BOOL)visible;
- (BOOL)isColumnWithIdentifierVisible:(id)identifier;
- (NSTableColumn *) initialColumnWithIdentifier:(id)identifier;
- (void)removeAllColumns;
- (void)setInitialState;

// IBActions
- (IBAction)scrollRowToTop:(id)sender;
- (IBAction)scrollRowToEnd:(id)sender;
- (IBAction)openInBrowser:(id)sender;

- (IBAction)revealInFinder:(id)sender; // Available in Twincam Angel and later.
- (IBAction)quickLook:(id)sender; // Available in SilverGull and later.
@end
