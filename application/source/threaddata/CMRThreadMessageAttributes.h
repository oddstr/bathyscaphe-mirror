//: CMRThreadMessageAttributes.h
/**
  * $Id: CMRThreadMessageAttributes.h,v 1.3 2007/01/22 02:23:29 tsawada2 Exp $
  * 
  * Copyright (c) 2001-2003, Takanori Ishikawa.  All rights reserved.
  * See the file LICENSE for copying permission.
  */

#import <Foundation/Foundation.h>
#import <CocoMonar/CMRPropertyListCoding.h>
#import <SGFoundation/SGFoundation.h>
#import "CMRThreadMessageAttributesMask.h"


@interface CMRThreadMessageAttributes : NSObject<NSCopying, CMRPropertyListCoding>
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
// flags����20bit
- (UInt32) status;
// flags 32 bit
- (UInt32) flags;

// NO == isInvisibleAboned  && NO == isTemporaryInvisible
- (BOOL) isVisible;

// ���ځ[��
- (BOOL) isAboned;

// ���[�J�����ځ[��
- (BOOL) isLocalAboned;

// �������ځ[��
- (BOOL) isInvisibleAboned;

// AA
- (BOOL) isAsciiArt;

// �u�b�N�}�[�N
// Finder like label, 3bit unsigned integer value.
- (unsigned) bookmark;

// ���̃��X�͉��Ă��܂�
- (BOOL) isInvalid;

// ���f���X
- (BOOL) isSpam;

// [Temporary Attributes]
// Visible Range
- (BOOL) isTemporaryInvisible;
//@end

//@interface CMRThreadMessageAttributes(Private)
- (void) setFlags : (UInt32) flag;
- (BOOL) flagAt : (UInt32) flag;
- (void) setFlag : (UInt32) flag
			  on : (BOOL  ) isSet;
- (void) setStatus : (UInt32) status;
@end
