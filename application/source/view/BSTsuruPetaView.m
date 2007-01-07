//
//  $Id: BSTsuruPetaView.m,v 1.3 2007/01/07 17:04:23 masakih Exp $
//  BathyScaphe -> SGAppKit
//
//  Created by Tsutomu Sawada on 06/06/22.
//  Copyright 2006 BathyScaphe Project. All rights reserved.
//

#import "BSTsuruPetaView.h"
#import <SGAppKit/NSImage-SGExtensions.h>

static NSString *const imgName = @"Spacer";

@implementation BSTsuruPetaView
static NSImage	*bgPattern;
static NSRect	bgPtnRect;

+ (void) initialize
{
	if (self == [BSTsuruPetaView class]) {
		NSSize	size_;

		bgPattern = [NSImage imageNamed: imgName loadFromBundle: [NSBundle bundleForClass: self]];
		size_ = [bgPattern size];
		
		bgPtnRect = NSMakeRect(0, 0, size_.width, size_.height);
	}
}

- (void) drawRect: (NSRect) rect
{
	[bgPattern setFlipped: [self isFlipped]];
	[bgPattern drawInRect: rect fromRect: bgPtnRect operation: NSCompositeCopy fraction: 1.0];
}

- (BOOL) isOpaque
{
	return YES; // note that by default NSView returns "NO".
}
@end
