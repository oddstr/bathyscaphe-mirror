//
//  $Id: BSIPIImageView.h,v 1.3.2.2 2006/09/03 13:50:37 tsawada2 Exp $
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

@interface NSObject(BSIPIImageViewResponderDelegate)
- (BOOL) imageView: (BSIPIImageView *) aImageView shouldPerformKeyEquivalent: (NSEvent *) theEvent;
- (void) imageView: (BSIPIImageView *) aImageView mouseDoubleClicked: (NSEvent *) theEvent;
@end
