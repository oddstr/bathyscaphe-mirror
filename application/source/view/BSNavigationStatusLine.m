//
//  BSNavigationStatusLine.m
//  BathyScaphe
//
//  Created by Tsutomu Sawada on 08/05/04.
//  Copyright 2008 BathyScaphe Project. All rights reserved.
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
	
	[self layoutNavigatorComponents];
}

- (void)dealloc
{
	[m_indexingStepper release];
	m_indexingStepper = nil;
	[m_indexingPopupper release];
	m_indexingPopupper = nil;
	[super dealloc];
}

- (void)updateUIComponentsOnTaskStarting
{
	id delegate = [self delegate];

	if (delegate && [delegate respondsToSelector:@selector(shouldShowContents)] && [delegate shouldShowContents]) {
		[[[self indexingStepper] contentView] setHidden:YES];
		[[[self indexingPopupper] contentView] setHidden:YES];
	}

	[super updateUIComponentsOnTaskStarting];
}

- (void)updateUIComponentsOnTaskFinishing
{
	id delegate = [self delegate];

	[super updateUIComponentsOnTaskFinishing];
	
	if (delegate && [delegate respondsToSelector:@selector(shouldShowContents)] && [delegate shouldShowContents]) {
		[[[self indexingStepper] contentView] setHidden:NO];
		[[[self indexingPopupper] contentView] setHidden:NO];
	}
}
@end
