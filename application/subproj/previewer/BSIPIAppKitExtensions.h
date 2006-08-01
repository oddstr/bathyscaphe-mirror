#import <Cocoa/Cocoa.h>

// Extension For BSImagePreviewInspector 2.0.x

@interface BSIPISegmentedControlTbItem : NSToolbarItem {
	@private
	id	_delegate;
}

// validation は delegate が行う
- (id) delegate;
- (void) setDelegate: (id) aDelegate;
@end

@interface NSObject(BSIPISegmentedControlTbItemValidation)
- (BOOL) segCtrlTbItem: (BSIPISegmentedControlTbItem *) item
	   validateSegment: (int) segment;
@end


@interface NSCell(BSIPIExtensionFromSG)
- (void) setAttributesFromCell: (NSCell *) aCell;
@end

@interface NSWorkspace(BSIPIExtensionFromSG)
- (BOOL) openURL : (NSURL *) url_ inBackGround : (BOOL) inBG;
@end