//: CMRStatusLine-ViewAccessor.m
/**
  * $Id: CMRStatusLine-ViewAccessor.m,v 1.6 2005/07/08 00:59:47 tsawada2 Exp $
  * 
  * Copyright (c) 2001-2003, Takanori Ishikawa.  All rights reserved.
  * See the file LICENSE for copying permission.
  */

#import "CMRStatusLine_p.h"
#import "missing.h"

@implementation CMRStatusLine(View)

#pragma mark Accessor

- (NSView *) statusLineView
{
    return _statusLineView;
}
- (NSTextField *) statusTextField
{
    return _statusTextField;
}
- (NSTextField *) browserInfoTextField
{
    return _browserInfoTextField;
}
- (NSProgressIndicator *) progressIndicator
{
    return _progressIndicator;
}
- (NSButton *) stopButton
{
	NSLog(@"WARNING! deprecated");
    return _stopButton;
}

#pragma mark -

- (void) setInfoTextFieldObjectValue : (id) anObject
{
    id        v = anObject;
    
    if (nil == v || NO == [v isKindOfClass : [NSAttributedString class]]) {
        [[self statusTextField] setObjectValue : nil == v ? @"" : v];
        return;
    }

    [[self statusTextField] setAttributedStringValue : v];
}

- (void) setBrowserInfoTextFieldObjectValue : (id) anObject
{
    id        v = anObject;
    
    if (nil == v || NO == [v isKindOfClass : [NSAttributedString class]]) {
        [[self browserInfoTextField] setObjectValue : nil == v ? @"" : v];
        return;
    }

    [[self browserInfoTextField] setAttributedStringValue : v];
}

- (void) setupStatusLineView
{
    unsigned    autoresizingMask_;

    autoresizingMask_ = NSViewMaxYMargin;
    autoresizingMask_ |= NSViewWidthSizable;
    [[self statusLineView] setAutoresizingMask : autoresizingMask_];
}

- (void) setupUIComponents
{
    [self setupStatusLineView];
}

- (void) updateStatusLineWithTask : (id<CMRTask>) aTask;
{

    if (NO == [[CMRTaskManager defaultManager] isInProgress]) {
        [[self progressIndicator] stopAnimation : nil];
		//[[self stopButton] setHidden : YES];
        [[self browserInfoTextField] setHidden : NO];
        [[self statusTextField] setStringValue : @""];
        
    } else {
        [[self progressIndicator] startAnimation : nil];
		//[[self stopButton] setHidden : NO];
        [[self browserInfoTextField] setHidden : YES];
        [[self statusTextField] setStringValue : [aTask message] 
                                                    ? [aTask message] 
                                                    : @""];
    }
}
@end

#pragma mark -

@implementation CMRStatusLine(Notification)
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