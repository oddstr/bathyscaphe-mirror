//
//  $Id: BSIPITableView.m,v 1.1.4.1 2006/09/01 13:46:54 masakih Exp $
//  BathyScaphe
//
//  Created by Tsutomu Sawada on 06/07/10.
//  Copyright 2006 BathyScaphe Project. All rights reserved.
//

#import "BSIPITableView.h"

@implementation BSIPITableView
- (BOOL) needsPanelToBecomeKey
{
	return YES;
}

- (BOOL) acceptsFirstResponder
{
	return YES;
}

- (BOOL) performKeyEquivalent: (NSEvent *) theEvent
{
	if([self delegate] && [[self delegate] respondsToSelector: @selector(tableView:shouldPerformKeyEquivalent:)]) {
		return [[self delegate] tableView: self shouldPerformKeyEquivalent: theEvent];
	}

	return [super performKeyEquivalent: theEvent];
}

- (unsigned int) draggingSourceOperationMaskForLocal: (BOOL)isLocal
{
	return NSDragOperationCopy;
}

- (NSMenu *) menuForEvent: (NSEvent *) theEvent
{
	int row = [self rowAtPoint: [self convertPoint: [theEvent locationInWindow] fromView: nil]];

	if(![self isRowSelected: row]) {
		[self selectRowIndexes : [NSIndexSet indexSetWithIndex: row] byExtendingSelection: NO];
	}

	if(row >= 0) {
		return [self menu];
	} else {
		return nil;
	}
}
@end
