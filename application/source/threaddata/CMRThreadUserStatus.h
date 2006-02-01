/**
  * $Id: CMRThreadUserStatus.h,v 1.3 2006/02/01 17:39:08 tsawada2 Exp $
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
// Dat —Ž‚¿
- (BOOL) isDatOchiThread;
- (void) setDatOchiThread : (BOOL) flag;

// ƒtƒ‰ƒO•t‚«
- (BOOL) isMarkedThread;
- (void) setMarkedThread : (BOOL) flag;
@end


