/**
  * $Id: CMRThreadUserStatus.h,v 1.1.1.1.4.2 2006/02/27 17:31:50 masakih Exp $
  * 
  * CMRThreadUserStatus.h
  *
  * Copyright (c) 2003-2004 Takanori Ishikawa, All rights reserved.
  * See the file LICENSE for copying permission.
  */
#import <Foundation/Foundation.h>
#import "CMRPropertyListCoding.h"
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

/* Available in BathyScaphe 1.2 and later. */
// Dat 落ち
- (BOOL) isDatOchiThread;
- (void) setDatOchiThread : (BOOL) flag;

// フラグ付き
- (BOOL) isMarkedThread;
- (void) setMarkedThread : (BOOL) flag;
@end


