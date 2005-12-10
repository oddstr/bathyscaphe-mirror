/**
  * $Id: ThreadsListDownloader.h,v 1.3 2005/12/10 18:05:53 tsawada2 Exp $
  * 
  * ThreadsListDownloader.h
  *
  * Copyright (c) 2003, Takanori Ishikawa.
  * See the file LICENSE for copying permission.
  */
#import <Foundation/Foundation.h>
#import "CMRDownloader.h"


@interface ThreadsListDownloader : CMRDownloader
+ (id) threadsListDownloaderWithBBSName : (NSString *) boardName;
- (id) initWithBBSName : (NSString *) boardName;

+ (BOOL) canInitWithURL : (NSURL *) url;

- (NSString *) BBSName;
//- (void) setBBSName : (NSString *) aBBSName;
@end


extern NSString *const ThreadsListDownloaderShouldRetryUpdateNotification;
extern NSString *const ThreadListDownloaderUpdatedNotification;
