//
//  ThreadsListTable.h
//  BathyScaphe
//
//  Updated by Tsutomu Sawada on 07/10/30.
//  Copyright 2005-2007 BathyScaphe Project. All rights reserved.
//  encoding="UTF-8"
//

#import <Cocoa/Cocoa.h>

@interface ThreadsListTable : NSTableView
{
	@private
	NSArray	*allColumns;	// added in ShortCircuit and later.
}

// ShortCircuit Additions
- (NSObject<NSCoding> *)columnState;
- (void)restoreColumnState:(NSObject *)columnState;
- (void)setColumnWithIdentifier:(id)identifier visible:(BOOL)visible;
- (BOOL)isColumnWithIdentifierVisible:(id)identifier;
- (NSTableColumn *) initialColumnWithIdentifier:(id)identifier;
- (void)removeAllColumns;
- (void)setInitialState;

// Available in Twincam Angel.
- (IBAction)revealInFinder:(id)sender;
// Available in SilverGull.
- (IBAction)quickLook:(id)sender;
@end
