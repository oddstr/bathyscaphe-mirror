//
//  BSWindow.m
//  BathyScaphe
//
//  Created by Tsutomu Sawada on 05/06/12.
//  Copyright 2005 tsawada2. All rights reserved.
//

#import "BSWindow.h"

#define NSAppKitVersionNumber10_3 743	// ここに書かなくてもいいと思うが、念のため

@implementation BSWindow
- (id) initWithContentRect : (NSRect)contentRect
				 styleMask : (unsigned int) styleMask
				   backing : (NSBackingStoreType)backingType
					 defer : (BOOL)flag
{
	if (floor(NSAppKitVersionNumber) <= NSAppKitVersionNumber10_3) {
		NSLog(@"Mac OS X v10.3 or Earlier.");
	} else {
		NSLog(@"Mac OS X v10.4 or later.");
		styleMask |= NSUnifiedTitleAndToolbarWindowMask;
	}
	return [super initWithContentRect : contentRect
							styleMask : styleMask
							  backing : backingType
								defer : flag];
}
@end
