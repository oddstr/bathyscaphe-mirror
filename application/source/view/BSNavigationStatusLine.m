//
//  BSNavigationStatusLine.m
//  BathyScaphe
//
//  Created by Tsutomu Sawada on 08/05/04.
//  Copyright 2008-2009 BathyScaphe Project. All rights reserved.
//  encoding="UTF-8"
//

#import "BSNavigationStatusLine.h"
#import "BSIndexingPopupper.h"
#import "CMRIndexingStepper.h"


@interface NSObject(BSNavigationStatusLineStub)
- (BOOL)shouldShowContents;
@end


@implementation BSNavigationStatusLine
- (BSIndexingPopupper *)indexingPopupper
{
	if (!m_indexingPopupper) {
		m_indexingPopupper = [[BSIndexingPopupper alloc] init];
	}
	return m_indexingPopupper;
}

- (CMRIndexingStepper *)indexingStepper
{
	if (!m_indexingStepper) {
		m_indexingStepper = [[CMRIndexingStepper alloc] init];
	}
	return m_indexingStepper;
}

- (void)layoutNavigatorComponents
{
	NSView	*popupperView, *stepperView;
	BSStatusLineView *statusLineView;
	NSRect	idxStepperFrame, idxPopupperFrame, statusBarFrame;
	NSPoint origin_;
    unsigned    autoresizingMask_;

    autoresizingMask_ = NSViewMaxYMargin;
    autoresizingMask_ |= NSViewWidthSizable;

	popupperView = [[self indexingPopupper] contentView];
	stepperView = [[self indexingStepper] contentView];
	statusLineView = [self statusLineView];

	idxStepperFrame = [stepperView frame];
	idxPopupperFrame = [popupperView frame];
	statusBarFrame = [statusLineView frame];

	origin_ = statusBarFrame.origin;
	statusBarFrame.size.width = NSWidth(statusBarFrame) - [NSScroller scrollerWidth];

	idxPopupperFrame.origin = origin_;
	idxPopupperFrame.size.width = statusBarFrame.size.width - NSWidth(idxStepperFrame);
	[popupperView setFrame:idxPopupperFrame];

	origin_.x += NSWidth(idxPopupperFrame);
	origin_.y += 1.0;
	[stepperView setFrameOrigin:origin_];
	[[self statusLineView] setRightMargin:(NSWidth([[self progressIndicator] frame]) + [NSScroller scrollerWidth] + 10)];
}

- (void)setupUIComponents
{
	[super setupUIComponents];

	[[self statusLineView] addSubview:[[self indexingStepper] contentView]];
	[[self statusLineView] addSubview:[[self indexingPopupper] contentView]];

	[[[self indexingStepper] contentView] bind:@"hidden" toObject:[self taskObjectController] withKeyPath:@"selection.isInProgress" options:nil];
	[[[self indexingPopupper] contentView] bind:@"hidden" toObject:[self taskObjectController] withKeyPath:@"selection.isInProgress" options:nil];

	[[[self indexingStepper] contentView] bind:@"hidden2" toObject:self withKeyPath:@"shouldShowNavigator" options:nil];
	[[[self indexingPopupper] contentView] bind:@"hidden2" toObject:self withKeyPath:@"shouldShowNavigator" options:nil];
	
	[self layoutNavigatorComponents];
}

- (BOOL)shouldShowNavigator
{
	id delegate = [self delegate];
	if (delegate && [delegate respondsToSelector:@selector(shouldShowContents)]) {
		return ![delegate shouldShowContents];
	}
	
	return NO;
}

- (void)statusLineWillRemoveFromWindow
{
	NSView *stepperView = [[self indexingStepper] contentView];
	NSView *popupperView = [[self indexingPopupper] contentView];
	[stepperView unbind:@"hidden2"];
	[popupperView unbind:@"hidden2"];
	[super statusLineWillRemoveFromWindow];
}

- (void)dealloc
{
	NSView *stepperView = [[self indexingStepper] contentView];
	NSView *popupperView = [[self indexingPopupper] contentView];
//	[stepperView unbind:@"hidden2"];
	[stepperView unbind:@"hidden"];
//	[popupperView unbind:@"hidden2"];
	[popupperView unbind:@"hidden"];

	[m_indexingStepper release];
	m_indexingStepper = nil;
	[m_indexingPopupper release];
	m_indexingPopupper = nil;
	[super dealloc];
}
@end
