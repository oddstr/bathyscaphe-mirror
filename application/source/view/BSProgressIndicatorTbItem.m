//
//  BSProgressIndicatorTbItem.m
//  BathyScaphe
//
//  Created by Tsutomu Sawada on 05/09/23.
//  Copyright 2005 BathyScaphe Project. All rights reserved.
//

#import "BSProgressIndicatorTbItem.h"

@implementation BSProgressIndicatorTbItem
- (void) setupItemViewWithContentView : (NSView *) aView
{
	if(aView) {
		NSSize		size_;

		[self setView : aView];

		size_ = [aView bounds].size;
		[self setMinSize : size_];
		[self setMaxSize : size_];
	}
}
@end
