//
//  BSNobiNobiToolbarItem.m
//  BathyScaphe
//
//  Created by Tsutomu Sawada on 07/03/27.
//  Copyright 2007 BathyScaphe Project. All rights reserved.
//

#import "BSNobiNobiToolbarItem.h"
#import "AppDefaults.h"
#import "CMRBrowser.h"

@implementation BSNobiNobiToolbarItem
- (void) validate
{
	[(BSNobiNobiView *)[self view] setShouldDrawBorder: NO];
}

- (id) copyWithZone: (NSZone *) zone
{
//	NSLog(@"copy called");
	BSNobiNobiView *nnView;
	id tmpcopy = [super copyWithZone: zone];
	nnView = (BSNobiNobiView *)[tmpcopy view];
	[tmpcopy setMinSize: NSMakeSize(48,29)];
	[tmpcopy setMaxSize: NSMakeSize(48,29)];
	[nnView setShouldFillBackground: YES];
	[nnView setShouldDrawBorder: YES];
	return tmpcopy;
}
@end

@implementation BSNobiNobiView
- (id)initWithFrame:(NSRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code here.
		m_shouldDrawBorder = NO;
		m_shouldFillBg = NO;
    }
    return self;
}

- (void)drawRect:(NSRect)rect {
    // Drawing code here.
	if ([self shouldFillBackground]) {
		[[CMRPref boardListBackgroundColor] set];
		NSRectFill(rect);
	}
	if ([self shouldDrawBorder]) {
		[[NSColor headerColor] set];
		NSFrameRect(rect);
	}
}

- (BOOL) isOpaque
{
	return YES;
}

- (BOOL) shouldDrawBorder
{
	return m_shouldDrawBorder;
}

- (void) setShouldDrawBorder: (BOOL) draw
{
	if (m_shouldDrawBorder == draw) return;
	m_shouldDrawBorder = draw;
	[self setNeedsDisplay: YES];
}

- (BOOL) shouldFillBackground
{
	return m_shouldFillBg;
}

- (void) setShouldFillBackground: (BOOL) fill
{
	m_shouldFillBg = fill;
}
@end
