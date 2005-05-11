/**
  * $Id: CMRNetRequestQueue.h,v 1.1.1.1 2005/05/11 17:51:06 tsawada2 Exp $
  * 
  * CMRNetRequestQueue.h
  *
  * Copyright (c) 2003, Takanori Ishikawa.
  * See the file LICENSE for copying permission.
  */

#import <Foundation/Foundation.h>
#import <SGFoundation/SGFoundation.h>
#import "CMXWorkerContext.h"



@interface CMRNetRequest : SGBaseObject <CMXRunnable>
{
	@private
	NSURL		*_requestURL;
}
- (id) initWithURL : (NSURL *) anURL;

- (NSURL *) requestURL;
- (void) setRequestURL : (NSURL *) aRequestURL;
@end



@interface CMRNetRequestQueue : NSObject
{
	@private
	CMXWorkerContext	*_worker;	/* worker thread */
}
/* Singleton per process */
+ (CMRNetRequestQueue *) defaultQueue;

- (void) enqueueRequest : (CMRNetRequest *) aRequest;


@end
