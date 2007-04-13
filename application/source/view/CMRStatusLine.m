/**
  * $Id: CMRStatusLine.m,v 1.13 2007/04/13 12:31:41 tsawada2 Exp $
  * 
  * CMRStatusLine.m
  *
  * Copyright (c) 2003, Takanori Ishikawa.
  * See the file LICENSE for copying permission.
  */
#import "CMRStatusLine.h"

#import "CMRTask.h"
#import "CMRTaskManager.h"
#import "missing.h"

#define kLoadNibName				@"CMRStatusView"

static NSString *const CMRStatusLineShownKey = @"Status Line Visibility";

@implementation CMRStatusLine
- (id) initWithIdentifier : (NSString *) identifier
{
	if(self = [super init]){
		[self setIdentifier : identifier];
		if(NO == [NSBundle loadNibNamed : kLoadNibName
								  owner : self]){
			[self release];
			return nil;
		}
		[self registerToNotificationCenter];
	}
	return self;
}

- (void) awakeFromNib
{
	[self setupUIComponents];
	[self updateStatusLineWithTask : nil];
}
- (void) dealloc
{
	[self removeFromNotificationCenter];

	[_identifier release];
	
	// nib
	[_statusLineView release];
	
	[super dealloc];
}

#pragma mark Accessor

- (NSView *) statusLineView
{
    return _statusLineView;
}
- (NSTextField *) statusTextField
{
    return _statusTextField;
}
- (NSProgressIndicator *) progressIndicator
{
    return _progressIndicator;
}
- (NSString *) identifier
{
	return _identifier;
}
- (void) setIdentifier : (NSString *) anIdentifier
{
	id tmp;
	
	tmp = _identifier;
	_identifier = [anIdentifier retain];
	[tmp release];
}

- (id) delegate
{
	return _delegate;
}
- (void) setDelegate : (id) aDelegate
{
	_delegate = aDelegate;
}

- (void) setInfoText : (id) aText;
{
    id        v = aText;
    
    if (nil == v || NO == [v isKindOfClass : [NSAttributedString class]]) {
        [[self statusTextField] setObjectValue : nil == v ? @"" : v];
        return;
    }

    [[self statusTextField] setAttributedStringValue : v];
}

#pragma mark IBAction

- (IBAction) cancel : (id) sender
{
	[[CMRTaskManager defaultManager] cancel : sender];
}

#pragma mark Other Actions

- (void) setupUIComponents
{
    unsigned    autoresizingMask_;

    autoresizingMask_ = NSViewMaxYMargin;
    autoresizingMask_ |= NSViewWidthSizable;
    [[self statusLineView] setAutoresizingMask : autoresizingMask_];
}
	
- (void) updateStatusLineWithTask: (id<CMRTask>) aTask
{
	NSProgressIndicator *pgi = [self progressIndicator];
	
    if ([aTask isInProgress]) {
		if ([aTask amount] != -1) {
			[pgi setIndeterminate: NO];
			[pgi setDoubleValue: [aTask amount]];
		} else {
			[pgi setIndeterminate: YES];
			[pgi startAnimation: nil];
		}
		[[self statusTextField] setStringValue: ([aTask message] ? [aTask message] : @"")];
		[[self statusLineView] setHidden: NO];

		if ([self delegate] && [[self delegate] respondsToSelector: @selector(statusLineDidShowTheirViews:)]) {
			[[self delegate] statusLineDidShowTheirViews: self];
		}
    } else {
        [pgi stopAnimation: nil];
		[[self statusLineView] setHidden: YES];
		[[self statusTextField] setStringValue: @""];

		if ([self delegate] && [[self delegate] respondsToSelector: @selector(statusLineDidHideTheirViews:)]) {
			[[self delegate] statusLineDidHideTheirViews: self];
		}
    }
}

#pragma mark Notifications
- (void) registerToNotificationCenter
{
    [[NSNotificationCenter defaultCenter]
         addObserver : self
            selector : @selector(taskWillStartNotification:)
                name : CMRTaskWillStartNotification
              object : nil];
    [[NSNotificationCenter defaultCenter]
         addObserver : self
            selector : @selector(taskWillProgressNotification:)
                name : CMRTaskWillProgressNotification
              object : nil];
    [[NSNotificationCenter defaultCenter]
         addObserver : self
            selector : @selector(taskDidFinishNotification:)
                name : CMRTaskDidFinishNotification
              object : nil];
    
    [super registerToNotificationCenter];
}
- (void) removeFromNotificationCenter
{
    [[NSNotificationCenter defaultCenter]
      removeObserver : self
                name : CMRTaskWillStartNotification
              object : nil];
    [[NSNotificationCenter defaultCenter]
      removeObserver : self
                name : CMRTaskWillProgressNotification
              object : nil];
    [[NSNotificationCenter defaultCenter]
      removeObserver : self
                name : CMRTaskDidFinishNotification
              object : nil];

    [super removeFromNotificationCenter];
}


- (void) taskWillStartNotification : (NSNotification *) theNotification
{
    UTILAssertNotificationName(
        theNotification,
        CMRTaskWillStartNotification);

    [self updateStatusLineWithTask : [theNotification object]];
}
- (void) taskWillProgressNotification : (NSNotification *) theNotification
{
    UTILAssertNotificationName(
        theNotification,
        CMRTaskWillProgressNotification);

    [self updateStatusLineWithTask : [theNotification object]];
}

- (void) taskDidFinishNotification : (NSNotification *) theNotification
{
    UTILAssertNotificationName(
        theNotification,
        CMRTaskDidFinishNotification);
    UTILAssertConformsTo(
        [[theNotification object] class],
        @protocol(CMRTask));
    
    [self updateStatusLineWithTask : [theNotification object]];
}
@end
