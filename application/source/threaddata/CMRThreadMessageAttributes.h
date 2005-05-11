//: CMRThreadMessageAttributes.h
/**
  * $Id: CMRThreadMessageAttributes.h,v 1.1 2005/05/11 17:51:08 tsawada2 Exp $
  * 
  * Copyright (c) 2001-2003, Takanori Ishikawa.  All rights reserved.
  * See the file LICENSE for copying permission.
  */

#import <Foundation/Foundation.h>
#import <CocoMonar/CocoMonar.h>
#import <SGFoundation/SGFoundation.h>
#import "CMRThreadMessageAttributesMask.h"


@interface CMRThreadMessageAttributes : SGBaseObject<NSCopying, CMRPropertyListCoding>
{
	@private
	UInt32		_flags;
}
+ (id) attributesWithStatus : (UInt32) status;
- (id) initWithStatus : (UInt32) status;

- (void) addAttributes : (CMRThreadMessageAttributes *) anAttrs;

//////////////////////////////////////////////////////////////////////
////////////////////////// [ _flags ] ////////////////////////////////
//////////////////////////////////////////////////////////////////////
// flags下位20bit
- (UInt32) status;
// flags 32 bit
- (UInt32) flags;

// NO == isInvisibleAboned  && NO == isTemporaryInvisible
- (BOOL) isVisible;

// あぼーん
- (BOOL) isAboned;

// ローカルあぼーん
- (BOOL) isLocalAboned;

// 透明あぼーん
- (BOOL) isInvisibleAboned;

// AA
- (BOOL) isAsciiArt;

// ブックマーク
// Finder like label, 3bit unsigned integer value.
- (unsigned) bookmark;

// このレスは壊れています
- (BOOL) isInvalid;

// 迷惑レス
- (BOOL) isSpam;

// [Temporary Attributes]
// Visible Range
- (BOOL) isTemporaryInvisible;
@end
