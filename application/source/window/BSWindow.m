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
	if (floor(NSAppKitVersionNumber) > NSAppKitVersionNumber10_3) {
			// すでに nib ファイルでメタル or つるぺたになっている場合は、つるぺた Mask を加えない
		if ((styleMask & NSTexturedBackgroundWindowMask) == 0 & (styleMask & NSUnifiedTitleAndToolbarWindowMask) == 0) {
			styleMask |= NSUnifiedTitleAndToolbarWindowMask;
		}
	}
	return [super initWithContentRect : contentRect
							styleMask : styleMask
							  backing : backingType
								defer : flag];
}
@end
