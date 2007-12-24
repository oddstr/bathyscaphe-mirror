//
//  BSRTTArrayController.m
//  BathyScaphe
//
//  Created by Tsutomu Sawada on 07/12/21.
//  Copyright 2007 BathyScaphe Project. All rights reserved.
//  encoding="UTF-8"
//

#import "BSRTTArrayController.h"

static NSString *const BSReplyTemplatePboardType = @"BSReplyTemplatePboardType";

@implementation BSRTTArrayController
- (void)awakeFromNib
{
	[tableView registerForDraggedTypes:[NSArray arrayWithObject:BSReplyTemplatePboardType]];
}

- (BOOL)tableView:(NSTableView *)aTableView writeRowsWithIndexes:(NSIndexSet *)rowIndexes toPasteboard:(NSPasteboard*)pboard
{
	unsigned int row = [rowIndexes firstIndex];

	NSData *object = [NSKeyedArchiver archivedDataWithRootObject:[[self arrangedObjects] objectAtIndex:row]];
	NSData *archivedIndexes = [NSKeyedArchiver archivedDataWithRootObject:rowIndexes];
	
	if (!object || !archivedIndexes) {
		return NO;
	}

	NSArray *pboardTypes = [NSArray arrayWithObject:BSReplyTemplatePboardType];
	[pboard declareTypes:pboardTypes owner:self];	
    [pboard setPropertyList:[NSArray arrayWithObjects:object, archivedIndexes, nil] forType:BSReplyTemplatePboardType];

	return YES;
}

- (NSDragOperation)tableView:(NSTableView*)tv
				validateDrop:(id<NSDraggingInfo>)info
				 proposedRow:(int)row
	   proposedDropOperation:(NSTableViewDropOperation)op
{
	if ([info draggingSource] != tableView) {
		return NSDragOperationNone;
    }

	if (row < 1) {
		return NSDragOperationNone;
	}

	NSDragOperation dragOp = NSDragOperationNone;
	
	id pboardContent = [[info draggingPasteboard] propertyListForType:BSReplyTemplatePboardType];
	
	if (pboardContent) {
		dragOp = NSDragOperationMove;
		[tv setDropRow:row dropOperation:NSTableViewDropAbove];
	}
	
    return dragOp;
}

- (BOOL)tableView:(NSTableView*)tv
	   acceptDrop:(id<NSDraggingInfo>)info
			  row:(int)row
	dropOperation:(NSTableViewDropOperation)op
{
	id pboardContent = [[info draggingPasteboard] propertyListForType:BSReplyTemplatePboardType];
	
	if (!pboardContent) {
		return NO;
	}

	id object = [NSKeyedUnarchiver unarchiveObjectWithData:[pboardContent objectAtIndex:0]];
	NSIndexSet *startedIndexes = [NSKeyedUnarchiver unarchiveObjectWithData:[pboardContent objectAtIndex:1]];

	unsigned int startedIndex = [startedIndexes firstIndex];
	unsigned int adjustedIndex;

	if (startedIndex == row) return YES;

	if (startedIndex > row) {
		adjustedIndex = row;
	} else {
		adjustedIndex = row-1;
	}

	[self removeObjectAtArrangedObjectIndex:startedIndex];
	[self insertObject:object atArrangedObjectIndex:adjustedIndex];
	return YES;
}
@end
