//
//  BSTsuruPetaView.m
//  BathyScaphe
//
//  Created by Tsutomu Sawada on 06/06/22.
//  Copyright 2006 BathyScaphe Project. All rights reserved.
//

#import "BSTsuruPetaView.h"


@implementation BSTsuruPetaView

- (id)initWithFrame:(NSRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code here.
    }
    return self;
}

- (void)drawRect:(NSRect)rect {
	//if (![self inLiveResize]) {
	//	const NSRect	*rects;
	//	int				i, count;
		NSImage *bgImage = [NSImage imageNamed: @"Spacer"];
		NSSize	tmp_ = [bgImage size];
		NSRect	imageRect = NSMakeRect(0, 0, tmp_.width, tmp_.height);

		[bgImage setFlipped: [self isFlipped]];
	//	[self getRectsBeingDrawn:&rects count:&count];
	//	for (i = 0; i < count; i++) {
	//		[bgImage drawInRect : rects[i] fromRect : imageRect operation : NSCompositeCopy fraction : 1.0];
	//	}
	//}
	[bgImage drawInRect : rect/*NSMakeRect(rect.origin.x,rect.origin.y-1,rect.size.width,rect.size.height+1)*/ fromRect : imageRect operation : NSCompositeCopy fraction : 1.0];
}

- (void)viewDidEndLiveResize
{
	[self setNeedsDisplay: YES];
	[super viewDidEndLiveResize];
}
@end
