//
//  $Id: BSIPIFullScreenController.h,v 1.10 2008/08/10 15:07:35 tsawada2 Exp $
//  BathyScaphe
//
//  Created by Tsutomu Sawada on 06/01/14.
//  Copyright 2006 BathyScaphe Project. All rights reserved.
//  encoding="UTF-8"
//

#import <Cocoa/Cocoa.h>

@interface BSIPIFullScreenController : NSObject {
	NSWindow				*_fullScreenWindow;
	IBOutlet NSWindow		*_baseWindow;
	IBOutlet NSImageView	*_imageView;
	IBOutlet NSTextField	*_statusField;
	IBOutlet NSTextField	*m_noMoreField;
	IBOutlet NSView			*m_imageInfoView;
	NSColor					*windowBackgroundColor;
	NSViewAnimation			*m_animation;

	// Do not retain/release
	id						m_delegate;
	NSArrayController		*m_cube;
}

+ (id)sharedInstance;

- (id)delegate;
- (void)setDelegate:(id)aDelegate;

- (NSArrayController *)arrayController;
- (void)setArrayController:(id)aController;

- (void)startFullScreen;
- (void)startFullScreen:(NSScreen *)whichScreen;
- (void)endFullScreen;
@end

@interface NSObject(BSIPIFullScreenAdditions)
- (void)fullScreenDidEnd:(NSWindow *)fullScreenWindow;
@end
