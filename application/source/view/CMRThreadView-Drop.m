// CMRThreadView-Drop.m

#import "CMRThreadView_p.h"
#import "CMRThreadSignature.h"

@implementation CMRThreadView(NSDraggingDestination)
- (NSDragOperation) draggingEntered: (id <NSDraggingInfo>) sender
{
	NSPasteboard *pboard = [sender draggingPasteboard];

    if ([[pboard types] containsObject: BSThreadItemsPboardType]) {
		return NSDragOperationCopy;
	}

    return [super draggingEntered: sender];
}

- (NSDragOperation) draggingUpdated: (id <NSDraggingInfo>) sender
{
	NSPasteboard *pboard = [sender draggingPasteboard];

    if ([[pboard types] containsObject: BSThreadItemsPboardType]) {
		return NSDragOperationCopy;
	}

    return [super draggingUpdated: sender];
}
/*
- (void) draggingExited: (id <NSDraggingInfo>) sender
{
	NSLog(@"Dragging Exited");
}
*/
- (BOOL) prepareForDragOperation: (id <NSDraggingInfo>) sender
{
	return YES;
}

- (BOOL) performDragOperation: (id <NSDraggingInfo>) sender
{
	return YES;
}

- (void) concludeDragOperation: (id <NSDraggingInfo>) sender
{
	NSPasteboard *pboard = [sender draggingPasteboard];

    if ([[pboard types] containsObject: BSThreadItemsPboardType]) {
		id	delegate_ = [self delegate];
		id threadSignature_ = [[pboard propertyListForType: BSThreadItemsPboardType] lastObject];

		if (threadSignature_ && delegate_ && [delegate_ respondsToSelector: @selector(setThreadContentWithThreadIdentifier:)]) {
			[delegate_ setThreadContentWithThreadIdentifier: [CMRThreadSignature objectWithPropertyListRepresentation: threadSignature_]];
		}
    }

	[super concludeDragOperation: sender];
}
@end
