/**
  * $Id: CMRNetGrobalLock.m,v 1.1 2005/05/11 17:51:06 tsawada2 Exp $
  * 
  * CMRNetGrobalLock.m
  *
  * Copyright (c) 2004, Takanori Ishikawa.
  * See the file LICENSE for copying permission.
  */

#import "CMRNetGrobalLock.h"
#import "UTILKit.h"

// for debugging only
#define UTIL_DEBUGGING    1
#import "UTILDebugging.h"



static id kSharedInstance;

@implementation CMRNetGrobalLock
+ (id) sharedInstance
{
    /*
    FROM COMONA'S SOURCE COMMENT
    
    2004-05-08 Takanori Ishikawa <takanori@gd5.so-net.ne.jp>
    ---------------------------------------------------------
    In Comona, at starting write this, I decided that NEVER
    USE "double-checking idiom", because it is NOT perfect.
    Instead of that, simply pre-instanciate all singleton 
    objects before application startup, be multi-threaded.
    
    NOTE: 
    But, CMNAppGlobal itself is instanciate by NSApplicationMain(),
    (see an instance in MainMenu.nib), it's OK.
    */
    if (nil == kSharedInstance) {
        kSharedInstance = [[self alloc] init];
    }
    return kSharedInstance;
}
- (id) init
{
    if (self = [super init]) {
        m_lock = [[NSLock alloc] init];
        m_requests = [[NSMutableSet alloc] init];
    }
    return self;
}
- (void) dealloc
{
    [m_lock release];
    [m_requests release];
    [super dealloc];
}

- (void) add : (id) aRequest
{
    UTILAssertNotNil(aRequest);
    UTILAssertConformsTo(aRequest, @protocol(NSCopying));
    
    UTIL_DEBUG_WRITE1(@"  Lock::add %@", aRequest);
    [m_lock lock];
    [m_requests addObject : aRequest];
    [m_lock unlock];
}

- (void) remove : (id) aRequest
{
    UTIL_DEBUG_WRITE1(@"  Lock::remove %@", aRequest);
    [m_lock lock];
    [m_requests removeObject : aRequest];
    [m_lock unlock];
}
- (BOOL) has : (id) aRequest
{
    BOOL ret;
    
    [m_lock lock];
    ret = ([m_requests member : aRequest] != nil);
    [m_lock unlock];
    
    return ret;
}
@end
