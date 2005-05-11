//: CMRThreadMessageAttributes_p.h
/**
  * $Id: CMRThreadMessageAttributes_p.h,v 1.1 2005/05/11 17:51:08 tsawada2 Exp $
  * 
  * Copyright (c) 2001-2003, Takanori Ishikawa.
  * See the file LICENSE for copying permission.
  */
#import "CMRThreadMessageAttributes.h"
#import "UTILKit.h"




@interface CMRThreadMessageAttributes(Private)
- (void) setFlags : (UInt32) flag;
- (BOOL) flagAt : (UInt32) flag;
- (void) setFlag : (UInt32) flag
			  on : (BOOL  ) isSet;
- (void) setStatus : (UInt32) status;
@end
