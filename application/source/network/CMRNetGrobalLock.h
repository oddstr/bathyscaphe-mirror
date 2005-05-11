/**
  * $Id: CMRNetGrobalLock.h,v 1.1.1.1 2005/05/11 17:51:06 tsawada2 Exp $
  * 
  * CMRNetGrobalLock.h
  *
  * Copyright (c) 2004, Takanori Ishikawa.
  * See the file LICENSE for copying permission.
  */

#import <Foundation/Foundation.h>

/*
A CMRNetGrobalLock object holds requests inProgress.
(request: URLs, signature, or other)
Network object should prevent duplicate request.

IMPORTANT:
A request MUST be immutable object, conforms to NSCopying.
*/
@interface CMRNetGrobalLock : NSObject
{
    @private
    NSLock       *m_lock;
    NSMutableSet *m_requests; /* this and that */
}
+ (id) sharedInstance;

- (void) add : (id) aRequest;
- (void) remove : (id) aRequest;
- (BOOL) has : (id) aRequest;
@end
