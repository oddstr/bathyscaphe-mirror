//
//  BSProgressIndicatorTbItem.m
//  BathyScaphe
//
//  Created by Tsutomu Sawada on 05/09/23.
//  Copyright 2005 BathyScaphe Project. All rights reserved.
//

#import "BSProgressIndicatorTbItem.h"
//#import "CMRTaskManager.h"
#import "CMRStatusLineWindowController_p.h"

@implementation BSProgressIndicatorTbItem
/*- (void) validate
{
	if ([[self toolbar] customizationPaletteIsRunning])
		[(NSProgressIndicator *)[self view] setDisplayedWhenStopped : YES];
	else
		[(NSProgressIndicator *)[self view] setDisplayedWhenStopped : NO];
}*/

- (void) setupItemViewWithTarget : (id) windowController_
{
	id	part_;

	part_ = [[(CMRStatusLineWindowController *)windowController_ statusLine] progressIndicator];
	if(part_) {
		NSSize		size_;
		[part_ retain];
		[part_ removeFromSuperviewWithoutNeedingDisplay];

		[self setView : part_];
		[part_ release];
		
		size_ = [part_ bounds].size;
		[self setMinSize : size_];
		[self setMaxSize : size_];
	}
}
@end
