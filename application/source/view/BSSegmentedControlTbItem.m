//
//  BSSegmentedControlTbItem.m
//  BathyScaphe
//
//  Created by Tsutomu Sawada on 05/08/30.
//  Copyright 2005 BathyScaphe Project. All rights reserved.
//

#import "BSSegmentedControlTbItem.h"
#import "CMRThreadViewer_p.h"

static NSString *const st_localizableStringsTableName	= @"ThreadViewerTbItems";

static NSString *const st_historySC_seg0_ToolTipKey	= @"historySC_0_ToolTip";
static NSString *const st_historySC_seg1_ToolTipKey = @"historySC_1_ToolTip";

@implementation BSSegmentedControlTbItem
- (void) validate
{
	id	segmentedControl_ = [self view];
	id	wc_ = [self target];

	if (!segmentedControl_) return;
	
	if (!wc_) {
		[segmentedControl_ setEnabled : NO];
		return;
	}

	if(![wc_ shouldShowContents]) {
		[segmentedControl_ setEnabled : NO];
	} else {
		[segmentedControl_ setEnabled : YES];
		if ([wc_ threadIdentifierFromHistoryWithRelativeIndex : 1] != nil) {
			[segmentedControl_ setEnabled : YES forSegment : 1];
		} else {
			[segmentedControl_ setEnabled : NO forSegment : 1];
		}
		if ([wc_ threadIdentifierFromHistoryWithRelativeIndex : -1] != nil) {
			[segmentedControl_ setEnabled : YES forSegment : 0];
		} else {
			[segmentedControl_ setEnabled : NO forSegment : 0];
		}
	}
}

- (void) setupItemViewWithTarget : (id) windowController_
{
	NSSegmentedControl	*tmp_;
	id  theCell = nil;
	
	// frame の幅 53px, segment の幅 23px は現物合わせで得た値
	tmp_ = [[NSSegmentedControl alloc] initWithFrame : NSMakeRect(0,0,53,25)];

	[tmp_ setSegmentCount: 2 ];
	[tmp_ setImage: [ NSImage imageNamed: @"HistoryBack" ] forSegment: 0 ];
	[tmp_ setImage: [ NSImage imageNamed: @"HistoryForward" ] forSegment: 1 ];
	[tmp_ setWidth: 23 forSegment: 0];
	[tmp_ setWidth: 23 forSegment: 1];
	[tmp_ setTarget: windowController_];
	[tmp_ setAction: @selector(historySegmentedControlPushed:)];
	theCell = [ tmp_ cell ];
	[theCell setTrackingMode: NSSegmentSwitchTrackingMomentary ];
	[theCell setToolTip: [self localizedString : st_historySC_seg0_ToolTipKey] forSegment: 0 ];
	[theCell setToolTip: [self localizedString : st_historySC_seg1_ToolTipKey] forSegment: 1 ];

	[self setView : tmp_];
	if([self view] != nil){
		NSSize		size_;

		size_ = [tmp_ bounds].size;
		[self setMinSize : size_];
		[self setMaxSize : size_];
	}
}

+ (NSString *) localizableStringsTableName
{
	return st_localizableStringsTableName;
}
@end
