//: SGInternalMessenger.h
/**
  * $Id: SGInternalMessenger.h,v 1.1 2005/05/11 17:51:05 tsawada2 Exp $
  * 
  * Copyright (c) 2001-2003, Takanori Ishikawa.  All rights reserved.
  * See the file LICENSE for copying permission.
  */

/*!
 * @header     SGInternalMessenger
 * @discussion SGInternalMessenger�N���X
 */

#import <Foundation/Foundation.h>


@protocol SGInternalMessaging
- (void) invokeMessage : (NSInvocation *) anInvocation
            withResult : (BOOL          ) aResultFlag;
@end


/*!
 * @class      SGInternalMessenger
 * @abstract   �X���b�h�Ԃ̃��b�Z�[�W�ʐM���s���N���X
 *
 * @discussion SGInternalMessenger�͕ʂ̃X���b�h�Ƀ��b�Z�[�W��
 *             ����Ƃ��̃C���^�[�t�F�[�X�ƂȂ�N���X�ł��B����
 *             �N���X�̃C���X�^���X�͐������ꂽ���_�̃X���b�h��
 *             ���炩�̃R�l�N�V�������m�����܂��B����ꂽ���b�Z
 *             �[�W�͎�M���̃X���b�h�Ŏ��s����܂��B���ʂ���
 *             ���ꍇ�͎�M���̏������I������܂Ńu���b�N����
 *             �����A���ʂ𖳎�����ꍇ�̓��b�Z�[�W�𑗐M���I��
 *             �����_�ő����ɖ߂�܂��B
 */
@interface SGInternalMessenger : NSObject<SGInternalMessaging>

/*!
 * @method     currentMessenger
 * @abstract   ���݂�Thread(RunLoop)�ƒʐM����Messenger
 * @discussion ���݂�Thread(RunLoop)�ƒʐM����Messenger�C���X�^���X��Ԃ��܂��B
 *
 * @result     �C���X�^���X
 */
+ (id) currentMessenger;

- (void)  target : (id ) aTarget
 performSelector : (SEL) aSelector;

- (void)  target : (id ) aTarget
 performSelector : (SEL) aSelector
      withObject : (id ) anObject;

- (void)  target : (id ) aTarget
 performSelector : (SEL) aSelector
      withObject : (id ) anObject
      withObject : (id ) anotherObject;

- (id)    target : (id  ) aTarget
 performSelector : (SEL ) aSelector
      withResult : (BOOL) aResultFlag;

- (id)    target : (id  ) aTarget
 performSelector : (SEL ) aSelector
      withObject : (id  ) anObject
      withResult : (BOOL) aResultFlag;

- (id)    target : (id  ) aTarget
 performSelector : (SEL ) aSelector
      withObject : (id  ) anObject
      withObject : (id  ) anotherObject
      withResult : (BOOL) aResultFlag;

// �ʒm
- (void) postNotification : (NSNotification *) aNotification
			 synchronized : (BOOL            ) sync;

// �񓯊�
- (void) postNotification : (NSNotification *) aNotification;
- (void) postNotificationName : (NSString     *) aNotificationName
					   object : (id            ) anObject;
- (void) postNotificationName : (NSString     *) aNotificationName
					   object : (id            ) anObject
					 userInfo : (NSDictionary *) aUserInfo;
@end



@interface SGInternalMessenger(CMXAdditions)
- (void *)    target : (id    ) aTarget
     performSelector : (SEL   ) aSelector
            argument : (void *) param2
          withResult : (BOOL  ) aResultFlag;
- (void *)    target : (id    ) aTarget
     performSelector : (SEL   ) aSelector
            argument : (void *) param1
            argument : (void *) param2
          withResult : (BOOL  ) aResultFlag;
@end


extern NSString *const SGInternalMessengerSendException;
