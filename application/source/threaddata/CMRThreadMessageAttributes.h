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
@end
