//: SGInternalMessaging_p.h
/**
  * $Id: SGInternalMessenger_p.h,v 1.1 2005/05/11 17:51:05 tsawada2 Exp $
  * 
  * Copyright (c) 2001-2003, Takanori Ishikawa.  All rights reserved.
  * See the file LICENSE for copying permission.
  */

#import "SGInternalMessenger.h"
#import "CMXInternalMessaging_p.h"


struct message_t
{
	NSConditionLock		*resultLock;
	NSInvocation		*invocation;
};

enum {
	kNotReturnYet = 0,
	kValueReturned
};
