/**
  * $Id: ThreadsListDownloader.h,v 1.2 2005/12/10 12:39:44 tsawada2 Exp $
  * 
  * ThreadsListDownloader.h
  *
  * Copyright (c) 2003, Takanori Ishikawa.
  * See the file LICENSE for copying permission.
  */
#import <Foundation/Foundation.h>
#import "CMRDownloader.h"


//@class CMRBBSSignature;


@interface ThreadsListDownloader : CMRDownloader
//+ (id) threadsListDownloaderWithBBSSignature : (CMRBBSSignature *) signature;
//- (id) initWithBBSSignature : (CMRBBSSignature *) signature;
+ (id) threadsListDownloaderWithBBSName : (NSString *) boardName;
- (id) initWithBBSName : (NSString *) boardName;

+ (BOOL) canInitWithURL : (NSURL *) url;

//- (CMRBBSSignature *) BBSSignature;
//- (void) setBBSSignature : (CMRBBSSignature *) aBBSSignature;
- (NSString *) BBSName;
- (void) setBBSName : (NSString *) aBBSName;
@end


extern NSString *const ThreadsListDownloaderShouldRetryUpdateNotification;
extern NSString *const ThreadListDownloaderUpdatedNotification;
