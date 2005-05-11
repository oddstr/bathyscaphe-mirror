//: SGDeepCopying.h
/**
  * $Id: SGDeepCopying.h,v 1.1 2005/05/11 17:51:45 tsawada2 Exp $
  * 
  * Copyright (c) 2001-2003, Takanori Ishikawa.  All rights reserved.
  * See the file LICENSE for copying permission.
  */

@protocol SGDeepCopying
- (id) deepCopyWithZone : (NSZone *) zone;
@end
