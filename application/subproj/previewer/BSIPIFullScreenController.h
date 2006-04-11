//
//  $Id: BSIPIFullScreenController.h,v 1.2 2006/04/11 17:31:21 masakih Exp $
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
