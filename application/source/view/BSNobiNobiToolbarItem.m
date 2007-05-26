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
	[(BSNobiNobiView *)[self view] setShouldDrawBorder: [[self toolbar] customizationPaletteIsRunning]];
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

- (void) adjustTo: (NSNumber *) floatWrapper
{
	float width = [floatWrapper floatValue];
	NSSize		size_;
	size_ = NSMakeSize(width-8, 29);
	[self setMinSize : size_];
	[self setMaxSize : size_];
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
	} else {
		[[NSColor clearColor] set];
		NSRectFillUsingOperation(rect, NSCompositeSourceOver); // 枠線を確実に消すために
	}
}

- (BOOL) isOpaque
{
	return NO; // YES だとダメ
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
