//: CMXInternalMessaging.h
/**
  * $Id: CMXInternalMessaging.h,v 1.1.1.1 2005/05/11 17:51:05 tsawada2 Exp $
  * 
  * Copyright (c) 2001-2003, Takanori Ishikawa.  All rights reserved.
  * See the file LICENSE for copying permission.
  */

#ifndef CMXINTERNALMESSAGING_H_INCLUDED
#define CMXINTERNALMESSAGING_H_INCLUDED

/*!
 * @header     CMXInternalMessaging
 * @discussion CocoMonar Inter-thread messaging subsystem - Public Header
 */
#import "SGInternalMessenger.h"
#import "SGRunLoopMessenger.h"
#import "CMXWorkerContext.h"

#ifdef __cplusplus
extern "C" {
#endif



// main thread & runLoop...
extern NSThread				*CMRMainThread;
extern NSRunLoop			*CMRMainRunLoop;
extern SGInternalMessenger	*CMRMainMessenger;




#ifdef __cplusplus
}  /* End of the 'extern "C"' block */
#endif
#endif /* CMXINTERNALMESSAGING_H_INCLUDED */
