//
//  $Id: BSTsuruPetaView.m,v 1.2 2006/06/25 17:06:42 tsawada2 Exp $
//  BathyScaphe
//
//  Created by Tsutomu Sawada on 06/06/22.
//  Copyright 2006 BathyScaphe Project. All rights reserved.
//

#import "BSTsuruPetaView.h"


@implementation BSTsuruPetaView
- (void) drawRect: (NSRect) rect
{
	NSImage *bgImage = [NSImage imageNamed: @"Spacer"];
	NSSize	tmp_ = [bgImage size];
	NSRect	imageRect = NSMakeRect(0, 0, tmp_.width, tmp_.height);
	[bgImage setFlipped: [self isFlipped]];

	[bgImage drawInRect: rect fromRect: imageRect operation: NSCompositeCopy fraction: 1.0];
}

- (BOOL) isOpaque
{
	return YES; // note that by default NSView returns "NO".
}
@end
