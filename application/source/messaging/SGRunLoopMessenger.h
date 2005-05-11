//: SGRunLoopMessenger.h
/**
  * $Id: SGRunLoopMessenger.h,v 1.1.1.1 2005/05/11 17:51:05 tsawada2 Exp $
  * 
  * Copyright (c) 2001-2003, Takanori Ishikawa.  All rights reserved.
  * See the file LICENSE for copying permission.
  */

/*!
 * @header     SGRunLoopMessenger
 * @discussion SGRunLoopMessenger <-- SGInternalMessaging
 */

#import <Foundation/Foundation.h>
#import "SGInternalMessenger.h"


/*!
 * @class      SGRunLoopMessenger
 * @abstract   SGInternalMessenger�̃N���X�E�N���X�^����
 * @discussion SGRunLoopMessenger�̓|�[�g�ԒʐM�𗘗p���āA
 *             �قȂ�X���b�h���m�Ń��b�Z�[�W�����Ƃ肵�܂��B
 *             ��M���̃X���b�h�ɂ�RunLoop���K�v�ł��B
 */
@interface SGRunLoopMessenger : SGInternalMessenger
{
	@private
	NSPort		*_sendPort;
}

/*!            
 * @method     sendPort
 * @abstract   ���M�p�|�[�g
 * @discussion ���M�p�|�[�g�̃I�u�W�F�N�g��Ԃ�
 * @result     NSPort�C���X�^���X
 */            
- (NSPort *) sendPort;
@end
