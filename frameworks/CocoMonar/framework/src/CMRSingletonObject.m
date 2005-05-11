//: CMRSingletonObject.m
/**
  * $Id: CMRSingletonObject.m,v 1.1.1.1 2005/05/11 17:51:19 tsawada2 Exp $
  * 
  * Copyright (c) 2001-2003, Takanori Ishikawa.  All rights reserved.
  * See the file LICENSE for copying permission.
  */

#import "CMRSingletonObject.h"


NSLock *CMRSingletonObjectFactoryLock = nil;