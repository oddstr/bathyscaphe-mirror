//
//  $Id: BSSegmentedControlTbItem.m,v 1.3 2006/06/17 06:37:15 tsawada2 Exp $
//  BathyScaphe
//
//  Created by Tsutomu Sawada on 05/08/30.
//  Copyright 2005-2006 BathyScaphe Project. All rights reserved.
//

#import "BSSegmentedControlTbItem.h"

@implementation BSSegmentedControlTbItem
- (id) delegate
{
	return _delegate;
}

- (void) setDelegate: (id) aDelegate
{
	_delegate = aDelegate;
}

- (void) validate
{
	id	segmentedControl_ = [self view];
	id	myDelegate = [self delegate];
	int	i, numOfSegments;

	if(!segmentedControl_)
		return;
	
	if(!myDelegate) {
		[segmentedControl_ setEnabled: NO];
		return;
	}

	if(![myDelegate respondsToSelector: @selector(segCtrlTbItem:validateSegment:)]) {
		[segmentedControl_ setEnabled: NO];
		return;
	}

	numOfSegments = [segmentedControl_ segmentCount];
	for(i=0; i < numOfSegments; i++) {
		BOOL	validation = [myDelegate segCtrlTbItem: self validateSegment: i];
		[segmentedControl_ setEnabled: validation forSegment: i];
	}
}

- (void) dealloc
{
	[self setDelegate: nil];
	[super dealloc];
}
@end
