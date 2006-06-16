//
//  $Id: BSSegmentedControlTbItem.h,v 1.1.6.1 2006/06/16 00:33:11 tsawada2 Exp $
//  BathyScaphe
//
//  Created by Tsutomu Sawada on 05/08/30.
//  Copyright 2005-2006 BathyScaphe Project. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface BSSegmentedControlTbItem : NSToolbarItem {
	@private
	id	_delegate;
}
// validation は delegate が行う
- (id) delegate;
- (void) setDelegate: (id) aDelegate;
@end

@interface NSObject(BSSegmentedControlTbItemValidation)
- (BOOL) segCtrlTbItem: (BSSegmentedControlTbItem *) item
	   validateSegment: (int) segment;
@end