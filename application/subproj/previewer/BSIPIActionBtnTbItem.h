//
//  $Id: BSIPIActionBtnTbItem.h,v 1.3 2006/07/26 16:28:25 tsawada2 Exp $
//  BathyScaphe
//
//  Created by Tsutomu Sawada on 06/01/07.
//  Copyright 2006 BathyScaphe Project. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface BSIPIActionBtnTbItem : NSToolbarItem {
	@private
	id	bsIPIABTI_delegate;
}

- (id) delegate;
- (void) setDelegate: (id) aDelegate;
@end

@interface NSObject(BSIPIActionBtnTbItemValidation)
- (BOOL) validateActionBtnTbItem: (BSIPIActionBtnTbItem *) aTbItem;
@end
