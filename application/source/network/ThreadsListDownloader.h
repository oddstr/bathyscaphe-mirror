/**
  * $Id: ThreadsListDownloader.h,v 1.1.1.1 2005/05/11 17:51:06 tsawada2 Exp $
  * 
  * ThreadsListDownloader.h
  *
  * Copyright (c) 2003, Takanori Ishikawa.
  * See the file LICENSE for copying permission.
  */
#import <Foundation/Foundation.h>
#import "CMRDownloader.h"


@class CMRBBSSignature;


@interface ThreadsListDownloader : CMRDownloader
+ (id) threadsListDownloaderWithBBSSignature : (CMRBBSSignature *) signature;
- (id) initWithBBSSignature : (CMRBBSSignature *) signature;

+ (BOOL) canInitWithURL : (NSURL *) url;

- (CMRBBSSignature *) BBSSignature;
- (void) setBBSSignature : (CMRBBSSignature *) aBBSSignature;
@end


extern NSString *const ThreadsListDownloaderShouldRetryUpdateNotification;
extern NSString *const ThreadListDownloaderUpdatedNotification;
