//: CMXPopUpWindowManager.h
/**
  * $Id: CMXPopUpWindowManager.h,v 1.1.1.1 2005/05/11 17:51:09 tsawada2 Exp $
  * 
  * Copyright (c) 2001-2003, Takanori Ishikawa.  All rights reserved.
  * See the file LICENSE for copying permission.
  */

/*!
 * @header     CMXPopUpWindowManager
 * @discussion �|�b�v�A�b�v�E�B���h�E�̊Ǘ�
 */
#import <Cocoa/Cocoa.h>
#import "CMXPopUpWindowController.h"


@class SGBaseCArrayWrapper;

#define CMRPopUpMgr		[CMXPopUpWindowManager defaultManager]

@interface CMXPopUpWindowManager : NSObject
{
	@private
	SGBaseCArrayWrapper		*_controllerArray;
}
/*!
 * @method      defaultManager
 * @abstract    ���L�I�u�W�F�N�g��Ԃ��B
 * @discussion  ���L�I�u�W�F�N�g��Ԃ��B
 * @result      ���L�I�u�W�F�N�g��Ԃ��B
 */
+ (id) defaultManager;

- (BOOL) isPopUpWindowVisible;
/*!
 * @method         showPopUpWindowWithContext:forObject:owner:locationHint:
 * @abstract       �|�b�v�A�b�v�E�B���h�E��\������
 * @discussion     �|�b�v�A�b�v�E�B���h�E��\������
 * @param context  �\��������e
 * @param object   �֘A�Â��̃L�[�ƂȂ�I�u�W�F�N�g
 * @param owner    delegate
 * @param point    �\���ʒu
 * 
 * @result         CMXPopUpWindowController
 */
- (id) showPopUpWindowWithContext : (NSAttributedString *) context
                        forObject : (id                  ) object
                            owner : (id                  ) owner
                     locationHint : (NSPoint             ) point;

- (BOOL) popUpWindowIsVisibleForObject : (id) object;

- (void) closePopUpWindowForOwner : (id) owner;
/*!
 * @method        performClosePopUpWindowForObject:
 * @abstract      �|�b�v�A�b�v�E�B���h�E�����
 * @discussion    �|�b�v�A�b�v�E�B���h�E�����
 * @param object  �֘A�Â��̃L�[�ƂȂ�I�u�W�F�N�g
 * @result		  �����ꍇ��YES
 */
- (BOOL) performClosePopUpWindowForObject : (id) object;



- (NSColor *) backgroundColor;
- (BOOL) isSeeThrough;
@end
