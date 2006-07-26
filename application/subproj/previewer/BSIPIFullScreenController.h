//
//  $Id: BSIPIFullScreenController.h,v 1.3 2006/07/26 16:28:25 tsawada2 Exp $
//  BathyScaphe
//
//  Created by Tsutomu Sawada on 06/01/14.
//  Copyright 2006 BathyScaphe Project. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <ApplicationServices/ApplicationServices.h>

@interface BSIPIFullScreenController : NSObject {
	IBOutlet NSWindow		*_baseWindow; // @ nib file
	NSWindow				*_fullScreenWindow;
	IBOutlet NSImageView	*_imageView;
	id						m_delegate;
}

+ (BSIPIFullScreenController *) sharedInstance;

//- (void) showPanelWithImage : (NSImage *) anImage;
//- (void) hidePanel;
- (void) setImage: (NSImage *) anImage;

- (id) delegate;
- (void) setDelegate: (id) aDelegate;

- (void) startFullScreen;
- (void) endFullScreen;
@end

@interface NSObject(BSIPIFullScreenAdditions)
- (void) fullScreenDidEnd: (NSWindow *) fullScreenWindow;
@end