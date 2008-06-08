//
//  CMRStatusLine.m
//  BathyScaphe
//
//  Updated by Tsutomu Sawada on 08/03/14.
//  Copyright 2005-2008 BathyScaphe Project. All rights reserved.
//  encoding="UTF-8"
//

#import "CMRStatusLine.h"
#import "BSStatusLineView.h"
#import "CMRTask.h"
#import "CMRTaskManager.h"
#import "BSTaskItemValueTransformer.h"
#import "missing.h"
@class CMRDownloader;
#define kLoadNibName				@"CMRStatusView"

static NSString *const CMRStatusLineShownKey = @"Status Line Visibility";

@implementation CMRStatusLine(Private)
/*- (NSTextField *)statusTextField
{
    return _statusTextField;
}
*/
- (NSProgressIndicator *)progressIndicator
{
    return _progressIndicator;
}

- (NSObjectController *)taskObjectController
{
	return _objectController;
}
@end


@implementation CMRStatusLine
+ (void)initialize
{
	if (self == [CMRStatusLine class]) {
		id transformer = [[[BSTaskItemValueTransformer alloc] init] autorelease];
		[NSValueTransformer setValueTransformer:transformer forName:@"BSTaskItemValueTransformer"];
	}
}

- (id)initWithIdentifier:(NSString *)identifier
{
	if (self = [super init]) {
		[self setIdentifier:identifier];
		if (![NSBundle loadNibNamed:kLoadNibName owner:self]) {
			[self release];
			return nil;
		}
		[self registerToNotificationCenter];
	}
	return self;
}

- (void)awakeFromNib
{
	[self setupUIComponents];
}

- (void)dealloc
{
	[[self statusLineView] unbind:@"messageText"];
	[self removeFromNotificationCenter];
	[self setIdentifier:nil];

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

- (void)statusLineViewDidMoveToWindow
{
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

#pragma mark Notifications
- (void)registerToNotificationCenter
{
	NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc addObserver:self selector:@selector(taskWillStartNotification:) name:CMRTaskWillStartNotification object:nil];
    [nc addObserver:self selector:@selector(taskDidFinishNotification:) name:CMRTaskDidFinishNotification object:nil];
    [super registerToNotificationCenter];
}

- (void)removeFromNotificationCenter
{
	NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc removeObserver:self name:CMRTaskWillStartNotification object:nil];
    [nc removeObserver:self name:CMRTaskDidFinishNotification object:nil];
    [super removeFromNotificationCenter];
}

- (void)updateUIComponentsOnTaskStarting
{
	[[self progressIndicator] setHidden:NO];
}

- (void)updateUIComponentsOnTaskFinishing
{
	[[self progressIndicator] setHidden:YES];
}

- (void)taskWillStartNotification:(NSNotification *)theNotification
{
	UTILAssertNotificationName(theNotification, CMRTaskWillStartNotification);
	id task = [theNotification object];
	UTILAssertConformsTo(task, @protocol(CMRTask));

	[[self taskObjectController] setContent:task];
	[self updateUIComponentsOnTaskStarting];
}

- (void)taskDidFinishNotification:(NSNotification *)theNotification
{
	UTILAssertNotificationName(theNotification, CMRTaskDidFinishNotification);
	id task = [theNotification object];
	UTILAssertConformsTo(task, @protocol(CMRTask));
	
	[[self taskObjectController] setContent:nil];
	[self updateUIComponentsOnTaskFinishing];
}
@end
