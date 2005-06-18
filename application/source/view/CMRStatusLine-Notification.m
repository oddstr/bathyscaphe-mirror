/**
  * $Id: CMRStatusLine-Notification.m,v 1.2 2005/06/18 19:09:16 tsawada2 Exp $
  * 
  * CMRStatusLine-Notification.m
  *
  * Copyright (c) 2003, Takanori Ishikawa.
  * See the file LICENSE for copying permission.
  */
#import "CMRStatusLine_p.h"

#import "missing.h"
//#import "CMRHistoryManager.h"
//#import "CMRMainMenuManager.h" 

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
    /*[[NSNotificationCenter defaultCenter]
         addObserver : self
            selector : @selector(appDefaultsLayoutSettingsUpdated:)
                name : AppDefaultsLayoutSettingsUpdatedNotification
              object : CMRPref];
    [[NSNotificationCenter defaultCenter]
         addObserver : self
            selector : @selector(applicationWillReset:)
                name : CMRApplicationWillResetNotification
              object : nil];
    [[NSNotificationCenter defaultCenter]
         addObserver : self
            selector : @selector(applicationDidReset:)
                name : CMRApplicationDidResetNotification
              object : nil];*/
    
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
    /*[[NSNotificationCenter defaultCenter]
      removeObserver : self
                name : AppDefaultsLayoutSettingsUpdatedNotification
              object : CMRPref];
    [[NSNotificationCenter defaultCenter]
      removeObserver : self
                name : CMRApplicationWillResetNotification
              object : nil];
    [[NSNotificationCenter defaultCenter]
      removeObserver : self
                name : CMRApplicationDidResetNotification
              object : nil];*/

    [super removeFromNotificationCenter];
}

/*- (void) appDefaultsLayoutSettingsUpdated : (NSNotification *) theNotification
{
    UTILAssertNotificationName(
        theNotification,
        AppDefaultsLayoutSettingsUpdatedNotification);
    UTILAssertNotificationObject(
        theNotification,
        CMRPref);
    
    [self setupProgressIndicator];
    [self updateToolbarUIComponents];
    [self updateStatusLinePosition];
    [self setupStatusLineView];
    
    [self synchronizeHistoryTitleAndSelectedItem];
    [[self statusLineView] setNeedsDisplay : YES];
}*/

#pragma mark -

- (void) taskWillStartNotification : (NSNotification *) theNotification
{
    UTILAssertNotificationName(
        theNotification,
        CMRTaskWillStartNotification);
    [[self progressIndicator] startAnimation : self];
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
