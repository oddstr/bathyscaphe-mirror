/**
  * $Id: CMRThreadUserStatus.h,v 1.1 2005/05/11 17:51:08 tsawada2 Exp $
  * 
  * CMRThreadUserStatus.h
  *
  * Copyright (c) 2003-2004 Takanori Ishikawa, All rights reserved.
  * See the file LICENSE for copying permission.
  */
#import <Foundation/Foundation.h>
#import <CocoMonar/CocoMonar.h>
#import <SGFoundation/SGFoundation.h>
#import "CMRThreadUserStatusMask.h"



@interface CMRThreadUserStatus : SGBaseObject<NSCopying, CMRPropertyListCoding>
{
	@private
	UInt32		_flags;
}
+ (id) statusWithUInt32Value : (UInt32) flags;
- (id) initWithUInt32Value : (UInt32) flags;

- (UInt32) flags;
- (void) setFlags : (UInt32) aFlags;

// AA 
- (BOOL) isAAThread;
- (void) setAAThread : (BOOL) flag;
@end


