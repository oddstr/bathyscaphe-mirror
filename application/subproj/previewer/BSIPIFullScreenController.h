//
//  $Id: BSIPIFullScreenController.h,v 1.1 2006/01/13 23:47:59 tsawada2 Exp $
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
}

+ (BSIPIFullScreenController *) sharedInstance;

- (void) showPanelWithImage : (NSImage *) anImage;
- (void) hidePanel;


@end
