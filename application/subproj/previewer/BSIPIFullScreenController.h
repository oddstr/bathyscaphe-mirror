//
//  BSIPIFullScreenController.h
//  BathyScaphe
//
//  Created by Tsutomu Sawada on 06/01/14.
//  Copyright 2006-2008 BathyScaphe Project. All rights reserved.
//  encoding="UTF-8"
//

#import <Cocoa/Cocoa.h>

@interface BSIPIFullScreenController : NSObject {
	NSWindow				*_fullScreenWindow;
	IBOutlet NSWindow		*_baseWindow;
	IBOutlet NSImageView	*_imageView;
	IBOutlet NSTextField	*m_statusField;
	IBOutlet NSTextField	*m_noMoreField;
	IBOutlet NSView			*m_noMoreView;
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
