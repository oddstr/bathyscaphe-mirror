//
//  $Id: BSIPIImageView.h,v 1.1.2.2 2006/09/01 13:46:54 masakih Exp $
//  BathyScaphe
//
//  Created by Tsutomu Sawada on 06/01/07.
//  Copyright 2006 BathyScaphe Project. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface BSIPIImageView : NSImageView {
	@private
	id	bsIPIImageView_delegate;
}

- (id) delegate;
- (void) setDelegate: (id) aDelegate;
@end

@interface NSObject(BSIPIImageViewDraggingSource)
- (BOOL) imageView: (BSIPIImageView *) aImageView writeSomethingToPasteboard: (NSPasteboard *) pboard;
@end 
