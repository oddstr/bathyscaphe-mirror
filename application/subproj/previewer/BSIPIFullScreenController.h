//
//  $Id: BSIPIFullScreenController.h,v 1.7 2007/04/30 17:25:59 tsawada2 Exp $
//  BathyScaphe
//
//  Created by Tsutomu Sawada on 06/01/14.
//  Copyright 2006 BathyScaphe Project. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface BSIPIFullScreenController : NSObject {
	IBOutlet NSWindow		*_baseWindow; // @ nib file
	NSWindow				*_fullScreenWindow;
	IBOutlet NSImageView	*_imageView;
	IBOutlet NSTextField	*_statusField;
	IBOutlet NSTextField	*m_noMoreField;
	id						m_delegate;
	NSArrayController		*m_cube; // do not retain/release
}

+ (id) sharedInstance;

- (id) delegate;
- (void) setDelegate: (id) aDelegate;

- (NSArrayController *) arrayController;
- (void) setArrayController: (id) aController;

- (void) startFullScreen;
- (void) startFullScreen: (NSScreen *) whichScreen;
- (void) endFullScreen;
@end

@interface NSObject(BSIPIFullScreenAdditions)
- (void) fullScreenDidEnd: (NSWindow *) fullScreenWindow;
@end

