//
//  CMRStatusLine.m
//  BathyScaphe
//
//  Updated by Tsutomu Sawada on 08/03/14.
//  Copyright 2005-2009 BathyScaphe Project. All rights reserved.
//  encoding="UTF-8"
//

#import "CMRStatusLine.h"
#import "BSStatusLineView.h"
#import "CMRTask.h"
#import "CMRTaskManager.h"
#import "BSTaskItemValueTransformer.h"

#define kLoadNibName				@"CMRStatusView"

static NSString *const CMRStatusLineShownKey = @"Status Line Visibility";


@implementation CMRStatusLine
+ (void)initialize
{
	if (self == [CMRStatusLine class]) {
		id transformer = [[[BSTaskItemValueTransformer alloc] init] autorelease];
		[NSValueTransformer setValueTransformer:transformer forName:@"BSTaskItemValueTransformer"];
	}
}

//- (id)initWithIdentifier:(NSString *)identifier
- (id)initWithDelegate:(id)delegate
{
	if (self = [super init]) {
//		[self setIdentifier:identifier];

		if (![NSBundle loadNibNamed:kLoadNibName owner:self]) {
			[self release];
			return nil;
		}
		[self setDelegate:delegate];
		[[self taskObjectController] bind:@"content" toObject:[CMRTaskManager defaultManager] withKeyPath:@"currentTask" options:nil];
	}
	return self;
}

- (void)dealloc
{
//	[self setIdentifier:nil];
	[self setDelegate:nil];

	// nib top-level objects
	[_statusLineView release];
	_statusLineView = nil;
	[_objectController release];
	_objectController = nil;

	[super dealloc];
}

- (void)setupUIComponents
{
    unsigned    autoresizingMask_;

    autoresizingMask_ = NSViewMaxYMargin;
    autoresizingMask_ |= NSViewWidthSizable;
    [[self statusLineView] setAutoresizingMask:autoresizingMask_];
	[[self statusLineView] bind:@"messageText" toObject:[self taskObjectController] withKeyPath:@"selection.message" options:nil];
}

- (void)statusLineWillRemoveFromWindow
{
	[[self statusLineView] unbind:@"messageText"];
	[[self taskObjectController] unbind:@"content"];
}

- (void)statusLineViewDidMoveToWindow
{
	[self setupUIComponents];
	BOOL indicatorShown = [[[self statusLineView] window] showsResizeIndicator];
	if (!indicatorShown) return;

	NSPoint origin = [[self progressIndicator] frame].origin;
	origin.x -= [NSScroller scrollerWidth];
	[[self progressIndicator] setFrameOrigin:origin];
}

#pragma mark Accessors
- (BSStatusLineView *)statusLineView
{
    return _statusLineView;
}

- (NSProgressIndicator *)progressIndicator
{
    return _progressIndicator;
}

- (NSObjectController *)taskObjectController
{
	return _objectController;
}
/*
- (NSString *)identifier
{
	return _identifier;
}

- (void)setIdentifier:(NSString *)anIdentifier
{
	[anIdentifier retain];
	[_identifier release];
	_identifier = anIdentifier;
}
*/
- (id)delegate
{
	return _delegate;
}

- (void)setDelegate:(id)aDelegate
{
	_delegate = aDelegate;
}

#pragma mark IBAction
- (IBAction)cancel:(id)sender
{
	[[CMRTaskManager defaultManager] cancel:sender];
}
@end
